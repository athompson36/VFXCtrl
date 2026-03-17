import Foundation
import CoreMIDI

final class MIDIDeviceManager: ObservableObject {
    @Published var inputName: String = "Not Connected"
    @Published var outputName: String = "Not Connected"
    @Published var availableInputs: [(id: MIDIEndpointRef, name: String)] = []
    @Published var availableOutputs: [(id: MIDIEndpointRef, name: String)] = []
    @Published var selectedInputRef: MIDIEndpointRef = 0
    @Published var selectedOutputRef: MIDIEndpointRef = 0

    /// MIDI channel the VFX-SD is set to (1-based). Used for channel voice / request messages if needed.
    @Published var midiChannel: Int = 1

    @Published var messageLog: [String] = []
    @Published var interMessageDelayMs: Double = 40
    @Published var sendStopped: Bool = false

    /// Called when SysEx is received (after logging). Set by app to parse and load into editor.
    var onReceiveSysEx: ((Data) -> Void)?

    private var clientRef: MIDIClientRef = 0
    private var inputPortRef: MIDIPortRef = 0
    private var outputPortRef: MIDIPortRef = 0
    private var sendQueue: [Data] = []
    private var sendTask: Task<Void, Never>?
    private let sendLock = NSLock()

    init() {
        setupClient()
    }

    deinit {
        if inputPortRef != 0 { MIDIPortDispose(inputPortRef) }
        if outputPortRef != 0 { MIDIPortDispose(outputPortRef) }
        if clientRef != 0 { MIDIClientDispose(clientRef) }
    }

    private func setupClient() {
        let status = MIDIClientCreateWithBlock("VFXCtrl" as CFString, &clientRef) { [weak self] _ in
            self?.refreshDevices()
        }
        guard status == noErr else {
            log("[MIDI] Client create failed: \(status)")
            return
        }
        MIDIInputPortCreateWithBlock(clientRef, "VFXCtrl In" as CFString, &inputPortRef) { [weak self] packetList, _ in
            self?.handlePacketList(packetList)
        }
        MIDIOutputPortCreate(clientRef, "VFXCtrl Out" as CFString, &outputPortRef)
        refreshDevices()
    }

    func refreshDevices() {
        var inputs: [(MIDIEndpointRef, String)] = []
        var outputs: [(MIDIEndpointRef, String)] = []
        let srcCount = MIDIGetNumberOfSources()
        let dstCount = MIDIGetNumberOfDestinations()
        for i in 0..<srcCount {
            let ref = MIDIGetSource(i)
            let name = getEndpointName(ref)
            inputs.append((ref, name))
        }
        for i in 0..<dstCount {
            let ref = MIDIGetDestination(i)
            let name = getEndpointName(ref)
            outputs.append((ref, name))
        }
        DispatchQueue.main.async { [weak self] in
            self?.availableInputs = inputs
            self?.availableOutputs = outputs
            if let s = self {
                if s.selectedInputRef == 0, let first = inputs.first {
                    s.selectedInputRef = first.0
                    s.inputName = first.1
                    s.connectInput()
                }
                if s.selectedOutputRef == 0, let first = outputs.first {
                    s.selectedOutputRef = first.0
                    s.outputName = first.1
                }
            }
        }
    }

    private func getEndpointName(_ ref: MIDIEndpointRef) -> String {
        var name: Unmanaged<CFString>?
        let status = MIDIObjectGetStringProperty(ref, kMIDIPropertyName, &name)
        guard status == noErr, let endpointName = name?.takeRetainedValue() as String? else {
            return "Endpoint \(ref)"
        }
        return endpointName
    }

    func selectInput(_ ref: MIDIEndpointRef) {
        selectedInputRef = ref
        inputName = getEndpointName(ref)
        connectInput()
    }

    func selectOutput(_ ref: MIDIEndpointRef) {
        selectedOutputRef = ref
        outputName = getEndpointName(ref)
    }

    private var connectedInputRef: MIDIEndpointRef = 0

    private func connectInput() {
        if connectedInputRef != 0 {
            MIDIPortDisconnectSource(inputPortRef, connectedInputRef)
            connectedInputRef = 0
        }
        if selectedInputRef == 0 { return }
        MIDIPortConnectSource(inputPortRef, selectedInputRef, nil)
        connectedInputRef = selectedInputRef
    }

    private func handlePacketList(_ packetList: UnsafePointer<MIDIPacketList>) {
        let list = packetList.pointee
        let firstPacketOffset = 4 // numPackets (UInt32) before first MIDIPacket
        var packetPtr = UnsafeMutableRawPointer(mutating: packetList).advanced(by: firstPacketOffset).assumingMemoryBound(to: MIDIPacket.self)
        for _ in 0..<list.numPackets {
            let packet = packetPtr.pointee
            let length = Int(packet.length)
            withUnsafeBytes(of: packet.data) { ptr in
                let bytes = ptr.baseAddress!.assumingMemoryBound(to: UInt8.self)
                let data = Data(bytes: bytes, count: length)
                parseAndDispatchSysEx(data)
            }
            packetPtr = MIDIPacketNext(packetPtr)
        }
    }

    private var sysexBuffer: [UInt8] = []

    private func parseAndDispatchSysEx(_ packetData: Data) {
        for byte in packetData {
            if byte == 0xF0 {
                sysexBuffer = [0xF0]
            } else if !sysexBuffer.isEmpty {
                sysexBuffer.append(byte)
                if byte == 0xF7 {
                    let data = Data(sysexBuffer)
                    sysexBuffer = []
                    DispatchQueue.main.async { [weak self] in
                        self?.receiveSysEx(data)
                    }
                }
            }
        }
    }

    func receiveSysEx(_ data: Data) {
        let hex = data.map { String(format: "%02X", $0) }.joined(separator: " ")
        logWithTimestamp("RX", hex)
        onReceiveSysEx?(data)
    }

    func sendSysEx(_ data: Data) {
        sendLock.lock()
        sendQueue.append(data)
        sendLock.unlock()
        logWithTimestamp("TX", data.map { String(format: "%02X", $0) }.joined(separator: " "))
        startSendLoop()
    }

    func stopSends() {
        sendStopped = true
        sendLock.lock()
        sendQueue.removeAll()
        sendLock.unlock()
        DispatchQueue.main.async { [weak self] in
            self?.sendStopped = false
        }
    }

    private func startSendLoop() {
        guard sendTask == nil else { return }
        sendTask = Task { [weak self] in
            guard let self else { return }
            let delayNs = UInt64(self.interMessageDelayMs * 1_000_000)
            while !Task.isCancelled {
                self.sendLock.lock()
                let next = self.sendQueue.first
                if next == nil {
                    self.sendQueue.removeAll()
                    self.sendLock.unlock()
                    break
                }
                self.sendQueue.removeFirst()
                self.sendLock.unlock()
                if self.sendStopped { continue }
                self.sendOneSysEx(next!)
                try? await Task.sleep(nanoseconds: delayNs)
            }
            await MainActor.run { self.sendTask = nil }
        }
    }

    private func sendOneSysEx(_ data: Data) {
        guard selectedOutputRef != 0, outputPortRef != 0 else { return }
        let count = data.count
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
        data.copyBytes(to: buffer, count: count)
        var request = MIDISysexSendRequest(
            destination: selectedOutputRef,
            data: buffer,
            bytesToSend: UInt32(count),
            complete: false,
            reserved: (0, 0, 0),
            completionProc: sysexCompletionProc,
            completionRefCon: UnsafeMutableRawPointer(buffer)
        )
        MIDISendSysex(&request)
    }

    private func logWithTimestamp(_ direction: String, _ hex: String) {
        let ts = ISO8601DateFormatter().string(from: Date())
        log("[\(ts)] \(direction) \(hex)")
    }

    private func log(_ text: String) {
        DispatchQueue.main.async {
            self.messageLog.append(text)
        }
    }

    // MARK: - Sequencer (placeholders until VFX-SD transport SysEx is verified)
    func sequencerPlay() {
        // TODO: send VFX-SD Play SysEx when format known
    }
    func sequencerStop() {
        // TODO: send VFX-SD Stop SysEx when format known
    }
    func sequencerRecord() {
        // TODO: send VFX-SD Record SysEx when format known
    }
    func sequencerTap() {
        // TODO: send or derive tap tempo when format known
    }
}

private func sysexCompletionProc(_ request: UnsafeMutablePointer<MIDISysexSendRequest>) {
    guard let refCon = request.pointee.completionRefCon else { return }
    UnsafeMutablePointer<UInt8>(OpaquePointer(refCon)).deallocate()
}
