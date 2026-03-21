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
    @Published var midiChannel: Int = 1 {
        didSet { UserDefaults.standard.set(midiChannel, forKey: Self.defaultsKeyChannel) }
    }

    @Published var messageLog: [String] = []
    @Published var interMessageDelayMs: Double = 40 {
        didSet { UserDefaults.standard.set(interMessageDelayMs, forKey: Self.defaultsKeyDelay) }
    }
    @Published var sendStopped: Bool = false

    private static let defaultsKeyDelay = "VFXCtrl.midi.interMessageDelayMs"
    private static let defaultsKeyInputName = "VFXCtrl.midi.lastInputName"
    private static let defaultsKeyOutputName = "VFXCtrl.midi.lastOutputName"
    private static let defaultsKeyChannel = "VFXCtrl.midi.channel"

    /// Called when SysEx is received (after logging). Set by app to parse and load into editor.
    var onReceiveSysEx: ((Data) -> Void)?

    private var clientRef: MIDIClientRef = 0
    private var inputPortRef: MIDIPortRef = 0
    private var outputPortRef: MIDIPortRef = 0
    private var sendQueue: [Data] = []
    private var sendTask: Task<Void, Never>?
    private let sendLock = NSLock()

    init() {
        loadMIDIPreferences()
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
            guard let s = self else { return }
            s.availableInputs = inputs
            s.availableOutputs = outputs
            let savedInput = UserDefaults.standard.string(forKey: Self.defaultsKeyInputName)
            let savedOutput = UserDefaults.standard.string(forKey: Self.defaultsKeyOutputName)
            if let name = savedInput, let match = inputs.first(where: { $0.1 == name }) {
                s.selectedInputRef = match.0
                s.inputName = match.1
                s.connectInput()
            } else if s.selectedInputRef == 0, let first = inputs.first {
                s.selectedInputRef = first.0
                s.inputName = first.1
                s.connectInput()
            }
            if let name = savedOutput, let match = outputs.first(where: { $0.1 == name }) {
                s.selectedOutputRef = match.0
                s.outputName = match.1
            } else if s.selectedOutputRef == 0, let first = outputs.first {
                s.selectedOutputRef = first.0
                s.outputName = first.1
            }
        }
    }

    private func loadMIDIPreferences() {
        let d = UserDefaults.standard
        let delay = d.double(forKey: Self.defaultsKeyDelay)
        if delay >= 10 && delay <= 200 {
            interMessageDelayMs = delay
        }
        let ch = d.integer(forKey: Self.defaultsKeyChannel)
        if ch >= 1 && ch <= 16 {
            midiChannel = ch
        }
    }

    private func saveMIDIPreferences() {
        UserDefaults.standard.set(inputName, forKey: Self.defaultsKeyInputName)
        UserDefaults.standard.set(outputName, forKey: Self.defaultsKeyOutputName)
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
        saveMIDIPreferences()
    }

    func selectOutput(_ ref: MIDIEndpointRef) {
        selectedOutputRef = ref
        outputName = getEndpointName(ref)
        saveMIDIPreferences()
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

    func sendSysEx(_ data: Data, quiet: Bool = false) {
        LiveDebugLog.log("MIDI.sendSysEx(\(data.count) bytes, quiet=\(quiet)) START")
        sendLock.lock()
        sendQueue.append(data)
        let queueCount = sendQueue.count
        sendLock.unlock()
        LiveDebugLog.log("MIDI.sendSysEx queueCount=\(queueCount) after append")
        if !quiet {
            logWithTimestamp("TX", data.map { String(format: "%02X", $0) }.joined(separator: " "))
        }
        startSendLoop()
        LiveDebugLog.log("MIDI.sendSysEx END")
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
        LiveDebugLog.log("MIDI.startSendLoop SPAWN")
        sendTask = Task.detached(priority: .utility) { [weak self] in
            guard let self else { return }
            LiveDebugLog.log("MIDI.sendLoop RUNNING")
            let delayNs = UInt64(self.interMessageDelayMs * 1_000_000)
            var iter = 0
            while !Task.isCancelled {
                self.sendLock.lock()
                let next = self.sendQueue.first
                if next == nil {
                    self.sendQueue.removeAll()
                    self.sendLock.unlock()
                    LiveDebugLog.log("MIDI.sendLoop EXIT (queue empty) iters=\(iter)")
                    break
                }
                self.sendQueue.removeFirst()
                let count = next!.count
                self.sendLock.unlock()
                if self.sendStopped { continue }
                iter += 1
                LiveDebugLog.log("MIDI.sendLoop iter=\(iter) sendOneSysEx(\(count) bytes)")
                self.sendOneSysEx(next!)
                LiveDebugLog.log("MIDI.sendLoop sleep \(self.interMessageDelayMs)ms")
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
        let requestPtr = UnsafeMutablePointer<MIDISysexSendRequest>.allocate(capacity: 1)
        // RefCon holds only our allocated pointers; completion must not read from the request (CoreMIDI may overwrite it).
        let refCon = UnsafeMutablePointer<SysexSendRefCon>.allocate(capacity: 1)
        refCon.initialize(to: SysexSendRefCon(requestPtr: requestPtr, dataPtr: buffer))
        requestPtr.initialize(to: MIDISysexSendRequest(
            destination: selectedOutputRef,
            data: buffer,
            bytesToSend: UInt32(count),
            complete: false,
            reserved: (0, 0, 0),
            completionProc: sysexCompletionProc,
            completionRefCon: UnsafeMutableRawPointer(refCon)
        ))
        MIDISendSysex(requestPtr)
    }

    private static let timestampFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private func logWithTimestamp(_ direction: String, _ hex: String) {
        let ts = Self.timestampFormatter.string(from: Date())
        log("[\(ts)] \(direction) \(hex)")
    }

    private static let maxLogLines = 500

    private func log(_ text: String) {
        DispatchQueue.main.async {
            self.messageLog.append(text)
            if self.messageLog.count > Self.maxLogLines {
                self.messageLog.removeFirst(self.messageLog.count - Self.maxLogLines)
            }
        }
    }

    func clearLog() {
        messageLog.removeAll()
    }

    // MARK: - MIDI Channel Messages

    /// Send a MIDI Control Change message (3-byte short message).
    func sendCC(channel: UInt8, controller: UInt8, value: UInt8, quiet: Bool = false) {
        guard selectedOutputRef != 0, outputPortRef != 0 else { return }
        let status: UInt8 = 0xB0 | (channel & 0x0F)
        var packet = MIDIPacket()
        packet.timeStamp = 0
        packet.length = 3
        let bytes = (status, controller & 0x7F, value & 0x7F)
        withUnsafeMutableBytes(of: &packet.data) { ptr in
            ptr[0] = bytes.0
            ptr[1] = bytes.1
            ptr[2] = bytes.2
        }
        var packetList = MIDIPacketList(numPackets: 1, packet: packet)
        MIDISend(outputPortRef, selectedOutputRef, &packetList)
        if !quiet {
            logWithTimestamp("TX CC", String(format: "ch=%d cc=%d val=%d", channel + 1, controller, value))
        }
    }

    // MARK: - Sequencer Transport (via Virtual Button SysEx)

    func sequencerPlay() {
        let msgs = LiveSysExBuilder.buildVirtualButtonPair(buttonNumber: 91, channel: midiChannel - 1)
        for msg in msgs { sendSysEx(msg) }
    }

    func sequencerStop() {
        let msgs = LiveSysExBuilder.buildVirtualButtonPair(buttonNumber: 92, channel: midiChannel - 1)
        for msg in msgs { sendSysEx(msg) }
    }

    func sequencerRecord() {
        let msgs = LiveSysExBuilder.buildVirtualButtonPair(buttonNumber: 89, channel: midiChannel - 1)
        for msg in msgs { sendSysEx(msg) }
    }

    func sequencerTap() {
        // Tap tempo via MIDI clock is preferable; placeholder for future implementation
    }

    // MARK: - Virtual Button

    func sendVirtualButton(_ buttonNumber: Int) {
        let msgs = LiveSysExBuilder.buildVirtualButtonPair(buttonNumber: buttonNumber, channel: midiChannel - 1)
        for msg in msgs { sendSysEx(msg) }
    }

    // MARK: - Dump Requests (Command Type only, per spec sections 3.1.6–3.1.15)

    func requestCurrentProgram() {
        let data = LiveSysExBuilder.buildParameterChange(voice: 0, page: 0, slot: 0, valueLo: 0, channel: midiChannel - 1)
        var bytes: [UInt8] = [0xF0, 0x0F, 0x05, 0x00, UInt8((midiChannel - 1) & 0x0F), 0x02]
        bytes.append(0xF7)
        sendSysEx(Data(bytes))
    }
}

/// Owned pointers for SysEx send; freed in completion. Do not read from the request in the completion—CoreMIDI may overwrite it.
private struct SysexSendRefCon {
    let requestPtr: UnsafeMutablePointer<MIDISysexSendRequest>
    let dataPtr: UnsafeMutablePointer<UInt8>
}

private func sysexCompletionProc(_ request: UnsafeMutablePointer<MIDISysexSendRequest>) {
    LiveDebugLog.log("MIDI.sysexCompletionProc CALLED thread=\(Thread.isMainThread ? "main" : "bg")")
    guard let refConRaw = request.pointee.completionRefCon else { return }
    let refCon = refConRaw.assumingMemoryBound(to: SysexSendRefCon.self)
    let ctx = refCon.pointee
    ctx.dataPtr.deallocate()
    ctx.requestPtr.deallocate()
    refCon.deallocate()
}
