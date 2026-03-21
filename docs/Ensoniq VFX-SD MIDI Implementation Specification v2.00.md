再   
***VFXSD*** Musician's ***Manual*** 

**Appendix A**   
**Appendix *A* \- *VFXS MIDI Specification*** 

**VFXSD MIDI Implementation Specification version 2.00** 

1 **Introduction and Overview** 

This **section** describes **the MIDI** System Exclusive **(SysEx**) communication protocol used **when the** VFXSD is communicating with an **external** computer (EXT). The protocol is designed to aid the implementation of editing programs running on EXT**,** and so this information **is** especially **relevant** to **designers** and programmers *of* editing programs. **The** commands **described here allow** editor/**librarian** programs to collect and alter information about **presets**, programs, and **the tracks** within **the** VFXŜD 

1.1 **Universal System Exclusive Device Inquiry Message**   
**The** VFXSD supports **the** MIDI Device Inquiry **message which** allows instruments and computers **to** ascertain **the identity of** the unit**(s**) to **which they** are connected via **MIDI**. **The** VFXSD **responds** to **the** following **Identity** Request **message by** sending an Identity **Reply message**. **The** VFXSD will respond to the inquiry if **the** channel information in the message contains either the base MIDI **channel of the** VFXSD or the all **channel** broadcast **code** ($7F). 

**System** Exclusive **status** byte **Non Real** Time message code   
11110000   
**FO** 

01111110 

0000nnnn 

**or** 

01111111 

00000110 

00000001 

11110111   
F7   
OHN HOME   
**7E** 

0x   
**Base MIDI channel** number 

7F 

06 

**01**   
**All Channel Broadcast code** 

**General** Information **message** code Identity Request **message** code End **of** System Exclusive 

**1.2 System** Exclusive **Device Identity Reply** Message   
**The following** Identity **Reply message** contains information about **the VFXSD,** and is transmitted in response to **an** Identity **Request.** 

**Note:**   
**System Exclusive status byte Non Real** Time **message** code **Base MIDI** channel number 

**General** Information message code **Identity Reply** message code **ENSONIQ manufacturer's** Code 

**VFX** Product **Family** ID **code** \- **LSByte** VFX Product **Family** ID **code \- MSByte**   
11110000   
**FO** 

01111110   
7E 

0000nnnn   
**0x** 

00000110   
06 

00000010   
02 

00001111   
OF 

00000101   
05 

00000000   
00 

00000000   
01 

00000000   
00 

00000000   
00 

00000000   
00   
**(**not **used)** 

Onnnnnnn   
NN 

Onnnnnnn   
**NN** 

11110111   
F7   
VFXSD **Family** Member (Model ID) code LSByte VFXSD **Family** Member (Model ID) code **MSByte Software revision** information 

**Major Version** Number (integer portion**)**   
**Minor Version** Number **(**decimal fraction portion) End of System Exclusive 

The VFXSD Version II Family **Member (**Model ID) code LSByte \= 02 to identify **the new** model. This difference is only in this **Identity Reply** message**;** all **other messages have** the standard VFXSD **header information.** 

**Appendix A \- 1**   
***Appendix*** **A** \- ***VFXSD MIDI Specification*** 

**2 MIDI System Exclusive Packet** Pieces   
***VFXSD Musician's Manual*** 

A packet **is** a bunch of information, i.e. a **message**, in the form **of a** MIDI data stream. Each packet can **be** divided into three sections or **pieces**. **The** first and last **packet pieces** form the frame for a **message**. The **message** contains **the** commands **described** in section 3\. Every message must be preceded with a **SysEx head** and followed **with a** SysEx **tail.** A **complete packet looks like this:** 

**SysEx** Head.   
**Message** 

**2.1 MIDI System Exclusive Packet** Head   
**SysEx Tail** 

**This is the** common **MIDI** system exclusive **header** which must be used on **all system** exclusive messages to and from **the VFXSD**. **These** six **bytes** are **always sent** preceding **the message** portion of the **packet**. **The** VFXSD **Model** ID Code in **this header** is **different** from the VFXSD Family Member (Model ID) code in **the** Device ID **message** in order to allow transfer of common **messages between** a VFX **and** a VFXSD**.** All **messages which are** not common to **both machines will be** ignored. 

11110000   
**FO**   
**System** Exclusive status **byte** 

00001111   
OF   
ENSONIQ Code 

00000101   
05   
VFX Family ID Code 

00000000   
00 

0000nnnn   
**0x** 

00000nnn   
0x   
VFXSD **Model** ID **Code** 

**Base MIDI channel** number **Message Type (**see section **3)** 

**2.2 MIDI System Exclusive Packet Tail**   
For every head **there** is a tail. The tail **follows the message** portion, and is **the** last byte **of every complete** SysEx **packet.** 

11110111   
**F7**   
End **of** System Exclusive 

**2.3 Message** Format   
The **VFXSD message** format within **the** packet frame **allows 8** bit data bytes to be **transmitted** and received using the **7** bit **data of MIDI**. The **MSB** of **the data** bytes must **always** be a zero, **so the bytes** are converted to two **4 bit** nybbles**.** These **nybbles** are converted to **bytes whose** upper four bits are all zero for transmission. **This is a** description **of** the format **of** all **data bytes within** the packet frame **as they** are transmitted or received via MIDI. The **details of each message are** given in **section** 3\. 

0000HHHH 

0000LLLL   
H \= Hi **4 bits** of **data** byte \- **transmitted first L** \= Lo **4 bits** of **data** byte 

This represents **how the 8** bit **byte** HHHHLLLL would be **transmitted**. 

**2.4 Receiver Errors** 

If the **message received** by **the** VFXSD **is** not understood, then an informative error message **will** be **displayed** and an error **message will** be sent **as** described in **section 3.2**. Errors typically occur **when the** MIDI **cable** is **accidentally** unplugged **during a long** dump **message** such **as an** All **Programs** Dump message**.** If EXT cannot handle the error **message, then the displayed message** will prompt the user to retransmit the original message after re-connecting **the MIDI cable** or otherwise correcting **the** cause of the error. 

**Appendix A \- 2**   
1   
***VFXSD*** Musician's ***Manual*** 

**3 Message Type List**   
**Appendix A \- *VFXSD MIDI Specification*** 

**The** next **few sections** describe the messages to be used **between** EXT and VFXSD. **The message type** corresponds to the last **byte** of the **system** exclusive **packet head** described in **section** 2.1**.** 

Note: The *SysEx messages **outlined** below* **appear** as **an *ordered description*** *of bytes **which** do* not ***necessarily represent*** the ***MIDI format** described* in ***section 2.3***. ***Remember***, *full **8\-bit** data* bytes ***are always*** sent as *two "nybble**\-ized" bytes**. **Message types*** are ***part*** of the *head **and are** sent* as ***bytes*****, *but*** Command ***types are*** **considered *data*** and ***are sent*** as two ***nybbles***. 

**3.1 Command Messages (Message Type** 00)   
All **messages** which need some interpretation **by** the receiver **are called** *command* messages. Every command message **is** transmitted **using the message format** described in **section 2.3**. The **first** byte of each command **message** is **the** command type byte**, which** follows **the message** type byte **in the** packet **head**. The command type **is shown** in **the** section **headings**. 

**3.1.1 Virtual** Buttons **(Command** Type   
**00\)**   
EXT **can** simulate button **presses** from **the** front panel **of the** VFXSD by **sending** this command**.** Sending **the listed** button numbers in a command will simulate a **single** button down **being held** down. **Button *up*** commands add an **offset** of **96 to the the** button down numbers**.** The button number follows **the** command **type byte** in **the message. Remember to send** a button up command for **every** button down command **that is sent.** Button up commands were implemented in version 2.01 **and above. *Note*:** a ***delay** of* 2-300 ***msecs between** button* commands***, or*** **at *least pairs of button* commands,** is ***recommended***. 

**3.1.1.1 Button** Numbers 

***Standard VFX button numbers***: 

**Logical**   
**Front** Panel 

Number   
**Button** Name   
Logical Number   
**Front** Panel 

**Button Name**   
0   
unnamed bank **0**   
**29**   
**Wave**   
1   
**unnamed bank 1**   
**33**   
**Pitch**   
**2**   
**unnamed bank 2**   
**34**   
**Pitch Mod**   
**3**   
unnamed **bank 3**   
**35**   
**Filters**   
**4**   
unnamed **bank 4**   
**37**   
Output   
5   
**unnamed bank 5** 

6   
**unnamed** bank **6** 

7   
unnamed **bank 7** 

**8**   
**unnamed bank 8** 

**9**   
**unnamed bank 9** 

10   
**Cart** 

11   
**Sounds** 

12 

**13**   
**Presets** Storage   
14   
**up arrow**, **INC**   
15   
down **arrow,** DEC 

16   
soft **key 0**, top **left**   
12222237   
**17**   
soft **key** 1, top middle   
**18**   
**soft key 2,** top **right**   
19   
soft **key 3,** bottom **left**   
20   
soft **key 4,** bottom **middle**   
soft **key 5,** bottom right 

**28**   
**25**   
**Master** 

MIDI **Control** 

Program **Control**   
Mod **Mixer**   
**81**   
\*\*\*2\***2**\*898AROS-SHAABB\!   
**40**   
LFO 

**42**   
**Envi** 

**45**   
**Env2** 

**48**   
**Env3** 

**51**   
**Effects** (Programming)   
**60** 

**61**   
**Copy** 

**62**   
**Write** 

**63** 

64 

65   
**Select Voice** 

Compare Volume 

**Pan** 

**66**   
Timbre 

**67** 

**68** 

69   
**Key Zone Transpose**   
**Release** 

**70**   
**Patch Select** 

**73**   
**MIDI (Performance**)   
76 

**80**   
Multi A 

Multi B 

**83**   
**Effects** (Performance**)** 

**Replace** Program 

**Appendix A \- 3**   
***Appendix A*** \- ***VFXSD MIDI Specification***   
***VFXSD*** Musician's ***Manual*** 

***VFXSD \- sequencer specific*** button ***numbers:*** 

**Logical Number**   
**Front Panel Button Name Seq Control Click**   
**Front Panel** Button **Name** Edit **Seq**   
TE TR   
**Logical** Number 

**85 86** 

**89** 

Sequence **Bank Select**   
**90** 

Edit Song   
92   
**Play** Stop   
Locate   
Edit **Track Record** 

**3.1.2 Parameter Change (Command Type \= 01**)   
Single parameters **can be** edited by EXT **using this** command**. Since this** is a short **message relative to** the much longer bulk dump **length** of a **complete program**, program editors running on EXT **can** change **single** parameters by **using this** command **faster** than by sending a complete **program** dump when **only** one or **a few** parameters change. 

Absolute parameter **values depend** on the parameter **page and slot** numbers **which** uniquely define **each** parameter. **Slot** numbers **are equivalent to** soft button numbers. **See section 5** of this appendix for the **page** and slot definitions**.** Most parameter values **are** in **the low** byte of **the** absolute **value** word**; key** range parameter types use **the** whole **word**. 

Command **Type Voice** Number**,** \[0..5\]   
Parameter **Page Number, \[**0..31\]   
00000001 01 

00000nnn   
0x 

000nnnnn   
0x 

00000nnn   
0x 

HHHHLLLL   
**HL** 

hhhhl111   
**hl**   
**Parameter Slot** Number**, \[0..5\] Absolute** Value Hi **Byte, \[0..255\] Absolute Value** Lo **Byte**, **\[0..255\]** 

**3.1.3 Edit Change Status (**Command **Type** \= **02\)**   
**This** command is **only *transmitted* by the** VFXSD**; it** is not received**.** It allows **the** external editor to **retain** synchronization with the compare buffer in **the VFXSD**. **The** edit change status command **is sent whenever** an edit operation **initiated** from **the** front panel of **the** VFXSD **causes** more than **one** parameter to **change**. The edit **change status** command will always **be** preceded **by at least one** parameter **change** message**.** Although **the** VFXSD will send **parameter change** messages**, it may not** be **able** to send the **new value of** every parameter **that changed**, due **to** the **complexities** of internal **editing**. **When** EXT **receives** this **message, it** should request **a complete** program **dump to re-establish** editing **sync.** The command **type is** the only byte in **this** command**.** 

**3.1.4 ESP Microcode Program Load (Command Type \= 03**)   
**The** ESP **is the** audio **effects** processor **of the VFXSD**. ESP microcode can be downloaded using this command which **can** facilitate creating new effect programs. This command is currently not **implemented**, and **is** reserved for future use. 

**3.1.5 Poke Byte** to **RAM or Cartridge (**Command **Type** \= **04\)**   
This command **is** not implemented on **the** VFXSD. **It is** used by **the** VFX only for making demo **cartridges**. 

**Appendix A \- 4**   
\!   
***VFXSD Musician's Manual***   
**Appendix** A \- ***VFXSD MIDI Specification*** 

***Note**: **The VFXSD*** does not transmit the ***following*** Dump ***Request*** commands ***(command types*** 05 to ***0A*****)**. The command ***type*** is the *only **byte*** in these ***commands***. 

**3.1.6 Single Program Dump Request (Command Type** \= **05\)**   
**The** VFXSD will dump **the** current **program** using **the** bulk dump **message** described in **section 3.3.1 when it receives this** command**. If the** current program is **being** edited, **the edited** version of **the** program will be transmitted. 

**3.1.7 Single Preset Dump** Request **(Command Type**   
**06**)   
**The** VFXSD will dump **the** current **preset** using **the** bulk dump **message** described in section 3.3.3 when it receives this command. **If the** current **preset** is **being** edited, **the edited** version of **the preset** will be transmitted**.** 

**3.1.8 Track Parameter Dump** Request **(Command Type**   
\= 07**) The** VFXSD will dump **the** track parameters **using the bulk** dump **message** described in section **3.3.7 when it receives this command.** 

**3.1.9 Dump Everything Request** (**Command** Type **\= 08\)**   
**The** VFXSD will dump the internal RAM program banks**,** the internal RAM preset banks, and **the track parameters using the bulk** dump messages described in section 3.3 when it **receives this** command. Each **dump is** a separate message, i.e. the messages **are** not combined **into** one. 

**09)**   
**3.1.10 Internal Program Bank Dump Request (Command Type The** VFXSD will dump **the** internal RAM program banks using the bulk dump message **described in section 3.3.2 when** it **receives** this **command.** 

**3.1.11 Internal Preset Bank Dump Request** (**Command Type \= 0A)** The VFXSD will dump the internal **RAM preset** banks **using** the bulk dump **message described in** section **3.3.4 when it receives this command**. 

**Appendix A \-** 5   
***Appendix*** A \- ***VFXSD MIDI Specification***   
***VFXSD Musician's Manual*** 

***Sequence Dump Protocol***: Since the ***receiver*** of **a sequence *dump* message** must *be **prepared to store the*** sequence ***data*****,** sequence ***dumps are** performed* **using** two messages from the **transmitter *and*** a handshaking **message from** *the **receiver**. The **transmitter*** sends *the* dump **command *which informs*** *the **receiver** of* the next ***message***. ***The receiver** should **respond** with* **an** *error **message containing*** **an *ACK or NAK*** *error* **code *(see section 3.2.1***). ***If*** the ***receiver** does* not ***respond within*** one ***second***, *the* **transmitter *will send*** *the* dump ***message anyway***. ***This*** timeout ***feature allows "***dumb***" System*** Exclusive ***recorders*** **to** store ***VFXSD*** **sequence** data*. **If*** the ***receiver responds*** with a ***NAK*** error *code, the* **transmitter** should ***not send** the* **dump *message***. 

***Note***: ***If*** the *VFX **sequencer software*** is not ***loaded*****,** the ***receiving VFX will** respond* with a ***NAK*** error message to ***any sequence dump*** command. 

**3.1.12 Single Sequence Dump (Command Type**   
(B**)**   
This message **is the** first **message of a** sequence dump. **The message** contains **the size** of the sequence data **which** will follow in the **single sequence** dump message.   
00001011 

HHHHHHHH   
ов 

HH 

hhhhhhhh   
hh 

LLLLLLLL 11111111   
LL 11   
Command Type   
Sequence Data Size in bytes Hi **Byte** Hi Word Sequence Data Size in bytes Lo **Byte** Hi Word Sequence Data Size **in** bytes Hi Byte Lo Word Sequence Data Size in bytes Lo Byte Lo Word 

***Note***: A *Track* **Parameter** *bulk* **dump message will *be* transmitted *after*** the *completion **of*** the ***single sequence*** dump**. *This*** will ***allow*** a ***receiving VFX*** to ***be configured for*** sound ***expansion, i.e. any sequence*** track in the ***VFXSD*** can have a ***MIDI*** **status *which will allow*** the ***receiving VFX*** to ***respond properly***. 

\= **0C)**   
**3.1.13 All Sequence Memory Dump (Command Type This message is the** first message of a **complete sequence** memory dump. The message **contains the size** of the sequence data **which will** follow **in the** all **sequence** dump **message**. 

00001100   
**ос**   
Command **Type**   
HHHHHHHH 

hhhhhhhh 

LLLLLLLL 11111111   
HH hh 

**LL** 

11   
Sequence **Data** Size in **bytes** Hi Byte Hi **Word** Sequence Data **Size** in bytes Lo Byte Hi **Word** Sequence Data Size in **bytes** Hi Byte Lo Word **Sequence** Data Size in bytes Lo Byte Lo **Word** 

**3.1.14 Single Sequence Dump Request (Command Type \= 0D)** The VFXSD will dump the **currently** selected sequence using the bulk dump message described in section **3.1.12 when** it receives **this** command**. The** command type is **the** only byte in **this command.** 

**3.1.15 All Sequence Dump Request (Command Type** \= **0E**)   
**The** VFXSD will dump all sequence memory using the **bulk** dump **message** described in **section** 3.1.13 **when** it **receives this** command**.** The command type **is the** only **byte** in **this command.** 

**Appendix A \- 6**   
*VFXSD Musician's **Manual*** 

**3.2 Error Messages (Message Type** \= **01)**   
***Appendix*** A \- ***VFXSD MIDI Specification*** 

Error **messages are** transmitted by **the** VFXSD **when** an error occurs **while** processing **any** of the command **messages** described in **section 3.1**. The VFXSD ignores error **messages** unless a sequence dump is being **processed**. 

**3.2.1 Command Message Error Codes These** codes are the data byte of error **messages**. 

**Code Name** 

00   
**NAK** 

01   
**INVALID** 

PARAMETER 

PARAMETER   
NUMBER 

02   
**INVALID** 

VALUE 

**03**   
INVALID BUTTON 

NUMBER 

04   
**ACK**   
**Meaning**   
The preceding command **message** could not be processed. **The** receiver is busy or the **message** is unintelligible. The preceding **dump** command **is** not **acceptable**. 

**The parameter voice**, page, **or** slot in **the** preceding parameter value **message** doesn't make **sense.** 

The parameter value in **the** preceding **parameter** value **message is** out of **range**. 

**The** button number **in** the preceding virtual button **message doesn't** correspond to any **real button number**. 

The preceding dump command is **acceptable**. 

**3.3 Bulk Dumps of Programs, Presets, Track Parameters**, **and** Sequences Bulk dump data **messages are** transmitted **using** the message format described **in section 2.3.** The **message** type byte**,** which **is** part of **the system exclusive** header**, is given** in **hexadecimal** with **the** name **of** the dump **message.** The **actual** data **bytes** for **programs**, **presets,** and sequences are described in section 4\. **The** MIDI data byte **lengths are** listed in decimal for each **message** type. 

**3.3.1 One Program (Message Type**   
**02\)**   
MIDI Data byte **length** \= 1060+ head and tail \= 1067   
**The** current **selected** program **is transmitted.** If **the** compare buffer is **active (the** Compare LED is on**),** then **the** program in **the** compare **buffer** will be transmitted. **If this message** is **received**, the **new** program will **be** put in the **compare** buffer so it **can be written** to internal or cartridge memory**.** Remember that the compare buffer is **over-**written by **the** incoming **data** and its previous contents **are** lost. 

**3.3.2 All Programs (Message Type \= 03\)**   
MIDI Data **byte length \=** 1060\*60 \= 63600+ **head** and **tail \=** 63607   
All 60 programs in **the** 10 internal RAM program banks are contained in this message. 

**Appendix A \- 7**   
***Appendix*** A \- *VFXSD **MIDI Specification*** 

**3.3.3 One Preset** (Message **Type \=** 04\)   
MIDI Data byte **length \= 96 \+ head** and **tail \= 103**   
***VFXSD*** Musician's ***Manual*** 

The **current selected** preset **is transmitted**. **If this** message **is** received, **the new preset** will **be** put in the **preset** buffer so it **can be written** to any **preset** location. If **presets** are being edited (**the preset** LED on**,** but **no preset** number LEDs are on**),** then the **received preset** will become **the** current **preset**. 

**3.3.4 All Presets (Message Type \= 05)**   
MIDI Data byte **length** \= **96\*20 1920+ head** and **tail \= 1927**   
All 20 **presets** in **the 2 internal** RAM preset banks are contained in this **message**. 

**3.3.5 Single Sequence Dump (Message Type** \= **09)**   
MIDI Data byte **length \= variable** depending on amount of sequence data   
**This message is transmitted** according to **the** sequence dump protocol described before section **3.1.12.** It **contains sequence** data and track parameters. 

**3.3.6 All Sequence Dump** (Message **Type** \= **0A)**   
MIDI **Data** byte **length \= variable** depending on amount **of** sequence data   
This **message** is transmitted according to **the** sequence dump protocol described before **section 3.1.12.** It contains global sequence **parameters,** sequence data, and **sequence** track   
**parameters.** 

**3.3.7 Track Parameters (**Message **Type**   
OB**)**   
MIDI Data **byte length \= 22\*12264** \+ **12 \+** 11+ **head** and **tail** \= 294   
All track parameter data for **the 12** tracks, the track **status array,** and **the** tracks **effect** parameters are **transmitted**. 

**Appendix A \- 8**   
***VFXSD** Musician's **Manual*** 

**4 Parameter Block Data Descriptions**   
***Appendix*** **A \- *VFXSD MIDI Specification*** 

**This** is a description of **the** parameter blocks **transmitted** using **the** bulk dump **messages** described **in section 3.3**. The names **and** byte offsets of **each block** parameter are **given**. The parameter value ranges are included in section 5\. **The** following byte layout is the internal representation and not **the** MIDI **byte** format **which is** described in **section 2.3.** 

**4.1** Program **Parameters**   
**The** first group of parameters **through** byte **offset 82** describe one **of the** six possible **voices** in a program. All of **the** global program parameters are at **the** bottom **of this list**. **When the**   
program has **a** custom pitch table installed, voices **5** and 6 are replaced with **the pitch** table data. In **this case, starting** at **the beginning of voice 5, there** is **a packed list** of fourteen bit records **consisting** of a **7** bit MIDI **key** number and **7 bits of** pitch fine **tune. There** are **88** records for **the complete keyrange** A0 \- **Č8**. 

**Byte Offset**   
Parameter **Name** 

**0**   
**Envl Initial Level** 

**1**   
**Env1 Attack Time** 

2   
**Env1** Peak **Level** 

**3**   
**Envl Decay Time 1** 

4   
Env1 Breakpoint 1   
**5**   
**Env1 Decay** Time **2**   
**6**   
Env1 **Breakpoint 2**   
*7*   
**Env1 Decay** Time **3**   
**8**   
**Envl Sustain Level** 

**9**   
**Envl Release** Time 

10   
Env1 Level Velocity **Sensitivity**   
11 

**12**   
**Env1 Attack** Time Velocity **Sensitivity**   
**Env1 Keyboard** Tracking   
**13**   
**Env1 Mode** (hi **nybble)** and Velocity Curve (lo **nybble)**   
**14**   
**Env2 Initial Level** 

15   
**Env2** Attack **Time** 

16   
Env2 Peak Level 

**17**   
**Env2 Decay** Time **1**   
**18**   
**Env2 Breakpoint 1**   
19   
**Env2 Decay** Time **2** 

**20**   
**Env2** Breakpoint **2** 

21   
Env2 Decay Time **3** 

**22**   
**Env2 Sustain Level** 

**23**   
**Env2 Release Time** 

**24**   
**Env2** Level Velocity Sensitivity   
**25**   
**Env2 Attack** Time Velocity **Sensitivity**   
26 

**27**   
**Env2 Keyboard** Tracking   
**Env2 Mode (**hi **nybble) and Velocity** Curve (lo **nybble)**   
**28**   
**Env3 Initial** Level 

**29**   
**Env3** Attack **Time** 

**30**   
**Env3 Peak Level** 

**31**   
**Env3** Decay Time **1** 

**32**   
**Env3** Breakpoint **1**   
**33**   
wwww...   
Env3 **Decay Time 2** 

**34**   
**Env3** Breakpoint **2** 

**35**   
**Env3 Decay** Time **3** 

**36**   
**Env3 Sustain Level** 

**37**   
**Env3 Release Time** 

**Appendix A \- 9**   
***Appendix*** **A \- *VFXSD MIDI Specification***   
***VFXSD Musician's Manual*** 

**Byte Offset**   
**Parameter Name** 

**38** 

**39** 

**40** 

41 

**42**   
**Env3 Level** Velocity **Sensitivity**   
**Env3 Attack Time Velocity Sensitivity**   
**Env3 Keyboard** Tracking   
**Env3** Mode **(hi nybble)** and **Velocity** Curve **(**lo **nybble)**   
**Pitch** Root **Key**   
**43**   
**Pitch Fine** Tune 

**44**   
**Pitch Table** 

45   
Pitch **Env1 Modulation Amount** 

**46** 

**47** 

**48** 

49 

**50** 

51 

**52** 

**53** 

**54**   
Pitch LFO **Modulation Amount** 

**Pitch** Glide **(hi nybble)** and **Pitch** Modulation Source (lo nybble**)** Pitch **Modulation Amount** 

Filter **\#**1 **Cutoff** 

Filter \#**1 Keyboard** Modulation Amount   
Filter **\#**1 **Env2 Modulation Amount** 

**Filter** Mode (hi **nybble)** and Filter **\#1** Modulation Source Filter **\#1 Modulation** Amount 

Filter **\#2** Cutoff 

**55**   
Filter **\#*2* Keyboard Modulation** Amount   
56   
**Filter \#2 Env2 Modulation Amount** 

**57**   
**Filter \#2 Modulation Source** 

**58**   
Filter \#**2 Modulation Amount** 

**59**   
**Volume** Fade **Shape**   
**60**   
Volume **Fade Key** Zone Low 

**61**   
Volume Fade **Key** Zone **High**   
**62** 

**63** 

**64** 

**65** 

**66** 

**67** 

**68** 

**69** 

70 

71 

***72***   
Volume and Pre**\-Gain Switch** (**MSB)**   
**Pan** Mod Source (**hi nybble)** and Volume Mod Source (lo **nybble)** Volume **Modulation** Amount 

**Pan** 

**Pan** Modulation **Amount** 

**Voice** Priority (hi **nybble)** and Output **Routing (lo nybble)**   
LFO **Waveshape (**hi **nybble)** and LFO Mod Source (lo **nybble)** LFO Depth   
LFO **Restart** Mode **(**hi **nybble)** and LFO **Speed** Mod Source (lo **nybble**) LFO Speed Modulation Amount   
LFO Speed   
**73**   
LFO **Delay Time**   
**74**   
**Waveform** 

**75**   
**Wave Class** (hi **nybble)** and **Wave** Mod Source (lo **nybble)**   
76   
**Wave Mod Amount** 

77   
**Wave** Start **Index** 

**78**   
**Noise** Source **Rate** 

**79**   
**Wave** Delay Time 

**81**   
888888   
**80** 

**82**   
Mixer **Curve** (hi **nybble)** and Mixer Mod Source \#1 (lo **nybble)** Mixer **Scaler** (**hi nybble)** and Mixer Mod Source **\#2** (lo **nybble) Velocity** Threshold 

**(**end of **Voice \#1** structure**)** 

**Appendix A \- 10**   
*VFXSD Musician's **Manual***   
**Appendix A** \- ***VFX MIDI Specification*** 

**Byte**   
**Parameter Name** 

**Offset** 

**83**   
Voice \#2   
**(same** structure **as Voice** \#**1\)**   
**166**   
Voice \#**3**   
**(**same structure **as Voice \#1)**   
**249**   
Voice \#4   
**(same** structure **as** Voice **\#1)**   
**332**   
Voice **\#5** 

415 

**498** 

509   
**(same as** Voice **\#1** or program **pitch table** data, **if enabled**) Voice \#6 **(same as Voice** \#**1** or program **pitch table** data, if **enabled**) Program Name **\-** (11 **bytes** or characters**)**   
Program **Patch \#1 (lo 6 bits)**   
Program Pressure **(**Performance **parameter) \- (hi 2 bits)**   
510   
Program **Patch \#2** (lo 6 **bits)** 

511   
Program **Patch** \#3 (lo **6 bits)**   
512   
Program **Patch** \#4 (**lo 6 bits**)   
**513** 

514 

515 

**516** 

**517** 

**518** 

519 

**527**   
***reserved*** **(hi nybble)** and Pitch **Table** Switch (lo **nybble) Program** Glide Time 

Program **Delay** Factor (hi **nybble) and** Global **Bend Range** (lo **nybble**) Program **Restrike** 

**Program** Timbre **(**Performance **parameter)**   
Program **Release (**Performance **parameter)** Program Effect Parameters **1 to 8**   
Program Effect FX1 Mix 

**528**   
Program Effect **FX2** Mix   
**529**   
**Program** Effect **Select** 

**4.2 Preset Parameters** 

**4.2.1 Track Parameter Structure** 

**The parameters** from each of the three individual tracks of a **Preset are stored as** an **array of variable** size bit **fields** packed into 11 consecutive **bytes**.   
***Note***: *the* **internal** *packing* scheme ***actually*** inverts ***each of*** the *individual **bytes***. ***When** they **are received***, they *will **appear*** to *be inverted (mirror* images) *of* the *bit* masks **as *described below.*** They must be **transmitted** in the ***inverted state***.   
UAW   
**Byte Offset**   
**Bit Mask** 

**0**   
**VVVVVVVC** 

**1**   
**CCCSSTTT** 

2   
**TTTTXXXX** 

**3**   
**XXXXLLLL** 

**4**   
LLLHHHHя 

**5**   
**HHSSSPPP** 

6   
**PPPPRRLL** 

**7**   
**LLLLLLPP** 

**8**   
**PPPPPPET** 

9   
ESXXXXXX 

10   
**iiiiiiii**   
**Parameter** Name 

**Volume (7 bits**) and first bit **of MIDI Channel** MIDI Channel (lo **3 bits),** Status **(2 bits), and** Timbre controller **value** (**hi 3 bits)**   
**Timbre** controller **value** (lo 4 **bits)** and X**(transpose)** (**hi 4 bits)** 

X(transpose**) (**lo **4** bits**)** and Low **key (hi** 4 bits**) Low key (lo 3 bits) and** High **key** (**hi 5** bits**)**   
**High key** (lo **2 bits), patch Select** (3 **bits), and** MIDI **Program** number **(hi 3** bits)   
MIDI **Program** number (lo **4 bits)**, **pressure** type **(2 bits),** and **reLease** time **(hi 2 bits**)   
**reLease time** (lo 6 bits) and **Pan (hi 2 bits)**   
**Pan (lo 6 bits)** and **Effect** routing (**hi 2** bits)   
Effect routing (**lo bit)** and **Sustain** pedal on/off (1 bit) x **\= spare bits reserved** for future **use internal** program number 

**Appendix A \- 11** 

1   
**1**   
***Appendix A*** \- ***VFXSD MIDI Specification***   
***VFXSD Musician's Manual*** 

**4.2.2 Preset Effect Parameter Structure The**   
parameters from the **preset** effect **are** stored as an **array of variable size** bit **fields** packed into 11 consecutive bytes. **The** effect **select** and mix values are packed into **7 bits** each, and **the parameters** are packed **as 8** bit numbers**.**   
***Note*****:** the ***internal packing*** scheme ***actually*** inverts each of the *individual **bytes. When*** they ***are received***, ***they*** will ***appear*** to *be **inverted (mirror images*****) *of*** *the **bit*** masks as ***described*** below. **They** must ***be*** transmitted in the ***inverted state*****.** 

**Byte Offset** 

0 

1 

**2** 

**3** 

4 

6 

7 

**8** 

9 

10   
**Bit** Mask 

EEEEEEEM MMMMMMmm **mmmmm 1 11 11111222** 

22222333 

33333444 

44444555 **55555666** 66666777 **77777888** 88888xxx   
Parameter Name 

Effect **select (7 bits**) and hi **bit** of FX1 **Mix** FX1 **Mix (lo 6 bits) and hi 2 bits** of FX2 mix FX2 **mix** (lo **5 bits)** and **param 1** (**hi 3 bits**) **param 1 (lo 5 bits) and param 2 (hi 3 bits)** param **2 (lo 5 bits)** and **param 3 (hi 3 bits)** param **3** (lo 5 **bits)** and **param 4 (hi 3** bits) **param 4 (lo 5** bits**)** and param **5** (**hi 3 bits**) param **5** (**lo 5 bits)** and param **6** (**hi 3** bits**) param 6** (**lo 5 bits**) and param **7 (hi 3** bits) **param 7 (lo 5 bits**) and param **8** (hi **3 bits**) **param 8 (lo 5 bits)** and **3** spare bits **(x**) 

**4.2.3 Preset Dump Structure**   
A complete **preset** dump is composed of three **sets** of packed track **parameters (**33 **bytes),** followed **by a 3 bytes** track status **array containing** information about layering**, an** effect definition **(11 bytes),** and **a spare** byte for a total **of 48 bytes**. 

**Byte Offset** 

0 

**11** 

22 

**33** 

**36** 

**47**   
2385   
**Parameter Name** Preset Track 0 parameters **Preset** Track 1 parameters **Preset** Track **2** parameters **Preset** Track status array **Preset** Effect parameters **spare** (reserved for future **use)** 

**Appendix A \- 12**   
}   
1   
*VFXSD* Musician's *Manual* 

**4.3 Track Parameters**   
***Appendix*** **A \- *VFXSD MIDI Specification*** 

**This message** consists of specific track **parameters** from **the 12 tracks, the** track status **array,** and **an effect** definition. 

**Byte Offset**   
**Byte** 

4 

6 

**8** 

10 

12 

**13** 

14 

15 

16 

17 

**18** 

19 

**20**   
182   
**Parameter** Name 

**Track** 1 **Program** number **and pointer (4** bytes **\= NPPP)** N\= **First byte \= Program** number **0..179**   
P **\= Next 3 bytes \=** 24 bit pointer to program data. **This** pointer will be recalculated **based on the** program number **when** the dump **is** received by **the** VFXSD. 

**Track 1** Timbre 

**Track 1 Release Track 1 Mix** 

Track 1 Effect Routing Override Track 1 **Patch Select override** Track 1 **Sustain Enable** switch **Track 1** MIDI **Channel** 

Track **1 MIDI** Program number   
Track 1 MIDI Pressure type **(**off,mono**,**poly**) Track** 1 MIDI Status (local**,**midi,**both) Track 1 Key** Zone low **key**   
Track **1 Transpose**   
**Track 1 Key** Zone high **key Track** 1 **Pan** 

**(end** of Track 1 structure**)** 

22 

44 

66 

88 

110 

**132** 

**154** 

176 

**198**   
Track **2** parameters **(**same structure as Track **1\)** Track **3** parameters **(**same structure as Track 1**)** Track 4 parameters **(**same structure as Track **1)** Track **5** parameters **(**same structure **as Track 1**) *Track* **6 parameters (same** structure **as Track** 1) Track **7** parameters **(**same structure **as Track 1**) Track **8 parameters (**same structure **as** Track 1\) Track **9 parameters (same** structure **as Track 1)** Track 10 **parameters (same structure as Track 1)** Track 11 parameters **(same structure as Track** 1\) Track **12** parameters **(same** structure **as** Track 1**)** Multi Track status **array**   
**Tracks Effect** Parameters **1 to 8**   
**220** 

**242** 

**264** 

276 

284 

**285**   
**Tracks** Effect FX2 **Mix** 

286   
**Tracks Effect Select**   
Tracks **Effect FX1 Mix** 

**Appendix A 13**   
• 

**Appendix A \- 14**   
***Appendix*** **A \- *VFXSD MIDI Specification***   
***VFXSD*** Musician's ***Manual*** 

***Note*****:** The sequencer ***data*** format is not ***currently*** **documented*,* so** *these blocks **are** only **described*** in **general** *terms*. 

**4.4 Single Sequence Dump Parameters**   
This message consists of the data from **one** sequence and **the** sequence **header**. 

**Parameter** Name   
**Byte Offset** 

0   
Sequence Data 

n   
**Sequence** Header 

**4.5 All Sequence Dump Parameters**   
**This** message consists of **the** data from one **sequence, the** sequence **header**, and **the** global **sequencer parameters.** 

**Byte Offset** 

0 

**239** 

n   
**Parameter Name** 

Sequence Data Pointer Offsets **\-** each **offset** is a long word from **the** beginning of the parameter **block**. There are **60 offsets**, one   
for **each sequence**/song.   
Sequence Data   
Sequence Header 

**n\+header\_size** Global Parameters   
}   
***VFXSD*** Musician's ***Manual*** 

**5 Parameter Page and Slot Definitions**   
Appendix A **\- *VFXSD MIDI Specification*** 

**This is** a **table** of all **parameter** page and slot (or soft button**)** numbers for **voice** and **system parameters** including the parameter value **ranges. Note** that in **cases** where more than **one** slot number is assigned to a **parameter that** the ***highest*** number should be used in **all** Parameter **Change messages (**section **3.1.2**). **Messages containing the alternate slot** numbers will **be ignored**. 

**Page Slot Range**   
**Parameter** Name **and Description** 

0..4   
**Touch: \-** SOFT,MED,FIRM,**HARD** 1-4 **System Bend Range**   
**undefined** 

**FS1 Auxiliary** Footswitch Configuration:   
\- **UNUSED**,ŠOSTENU**,PATCH** L,ADVANCE   
**FS2 Footswitch** Configuration**: \- SUSTAIN,**PATCH **R** undefined   
Master **pages**   
**0**   
0   
**\-128**..+**127**   
Master Tune 

0   
**1**   
0..15 

0   
**2**   
**0..12** 

0   
3 

0   
**4** 

0   
5   
0,1 

**1**   
0 

1   
1 0,1 

1   
**2**   
**0,1** 

1   
3,4 

1   
**5**   
0.1 

**2**   
0 

2   
**1,2**   
**0,1** 

**2**   
3,4 

**2**   
**5**   
**0,1**   
2 222 22 2 £   
**0..127**   
Slider mode**: \- NORMAL**, **TIMBRE**   
**CV Pedal** Configuration: **\-** VOL,MOD undefined 

System **Pitch Table: \-** CUSTOM**,**NORMAL Maximum **Keyboard** Velocity   
MIDI track **naming: \-** OFF,**ON**   
Voice **Muting: \-** OFF,ON   
**Keyboard** naming**: \-** OFF,ON 

MIDI Control pages   
en **en en en** en   
**3**   
0   
0..15   
**MIDI Base Channel** 

**3** 

**3** 

**3** 

**3** 

**3** 

4 

**4** 

**4** 

4 

**4** 

4   
\#NM4VNO-NM stin   
**1** 

2   
0,1 

**3**   
0..4 

0..2 

5   
0..95 

0   
0,1   
MIDI Loop **Switch**: **\-** OFF,ON   
1   
0,1 

**2**   
**0.1** 

**3**   
0,1 

**4**   
**0,1** 

5   
**0..2** 

Program Control page   
**10 10 10 10 In**   
**5** 

**5**   
2 

5   
3 

5   
4 

5   
**5**   
MAWNO'd   
0,1   
0,1 

0..13 

**0..3** 

0..99 

0..99 

Mod Mixer **page**   
6   
0   
**undefined** 

MIDI **Send Channel: \- BASE**,**TRACK**   
**MIDI Mode: \- OMNI**,POLY**,**MULTI**,**MONO **A,**MONO B MIDI Transpose**: \-** SEND**,RECV**,BOTH   
**MIDI** External **Controller** number 

MIDI Controllers **enable flag: \-** OFF,**ON** MIDI Song **Select enable flag: \-** OFF,**ON**   
MIDI **Send** Start**/**Stop flag**: \-** OFF,ON   
MIDI System Exclusive **enable flag**: **\-** OFF,ON MIDI **Program Change enable flag: \-** OFF**,ON**,NEW 

**Pitch Table enable flag: \-** OFF,ON Program **Bend Range** (**13\=**global) **Delay Multiplier: \-X1,***X2*,X4**,X8 Program Restrike Delay** Time **Program** Glide **Time** 

**undefined** 

**6**   
**1**   
0..15   
**Mod** Mixer **Mod** Source **\#1** 

**6**   
**2**   
0..15   
**Mod** Mixer **Mod** Source **\#2** 

**6**   
**3.4** 0..15   
Mod Mixer Scaler 

**6**   
5   
0..15   
**Mod** Mixer **Shape** 

**Appendix A \- 15**   
***VFXSD Musician's Manual***   
Appendix ***A*** **\- *VFXSD MIDI Specification*** 

**Page Slot Range**   
**Parameter Name and Description** 

**Select Voice** (voice **status) page**   
**38**   
0-5 0..2   
**Voice Status: \-** OFF,ON**,**SOLO 

**Wave Page** pages **7-10 are used** for all wave types or **classes** but **there** are different interpretations *of* parameters depending on the current **wave class**. **When** changing **wave page parameters**, be sure **the wave class is** set first, otherwise parameter **values may be invalid**. When the **wave class** is changed, the other **wave parameters** are reset to **default values. *Note*** these ***are*** always ***output*** as ***page** 7, but **should** be **input*** as ***pages 7..10**, **depending** on **wave class***.   
7..10 0 0..140 **Wave Name** (**0..147 for** VFXSD **Version** II)   
**Wave** Class (**0..12 for** VFXSD **Version** II)   
7..10 1   
0..11 

7..10 **2**   
0..251   
**Delay** Time (251**\=key up)** 

The following slots **are for the** sampled wave **classes (strings,** brass**, bass**, **breath,** tuned **percussion,** and **percussion)**.   
7   
3 

7   
**4**   
**0..127** \-127..127   
**Wave Start Index** 

**Wave** Velocity Start Mod   
7   
5   
0,1   
**Wave** Direction**: \- FORWARD**,REVERSE 

**The following slots are** specifically **for TRANSWAVE class (6)**   
**8** 

**8**   
4 **5**   
0..15 **\-127**..+127   
**Wave Mod Source** 

**Wave Mod Amount** 

The following **slots are** specifically for **the WAVEFORM** and INHARMONIC **classes** (7 and 8, **respectively**) 

9   
3-5   
undefined 

The following slots are **specifically** for **the looping** MULTI**\-**WAVE **class (9**)   
10 **3** 0..249   
Loop **Wave** Start number   
10   
**4**   
**1..243**   
Loop Length   
10   
5   
0.1   
Loop Direction**: \- FORWARD,**REVERSE 

Pitch page   
11   
0   
**\-4..+4**   
**Pitch Octave** 

11   
1   
**\-12**..+**12**   
Pitch **Semitone** 

11   
2   
**\-127..127**   
Pitch **Fine Tune** 

11   
3,4 0..2   
**11**   
5   
**Pitch Table** type: **\-** SYSTEM,ALL\-C4**,**CUSTOM **undefined** 

Pitch Mod page 

**12** 

12 

**12**   
0\-**NM4 IN**   
1222   
1   
0..15   
**undefined** 

**Pitch Mod** Source 

**2** 

**12 3**   
**\-99**..+99 0..4   
**Pitch** Mod **Amount** 

**\-127**..+**127**   
**Glide Mode: \-** NONE,PEDAL**,**MONO,LEGATO,TRIGGER 

**Pitch Env1 Mod** Amount 

5   
\-127..+127   
**Pitch** LFO **Mod Amount** 

**Appendix A \- 16** 

0,1 0..127 

13 **2**   
**\-127..+127** 

**13**   
**3**   
0..15 

**13**   
**\-127**..+**127** 

13   
**5**   
**\-127**..+127 

14 0   
**0..3** 

**14** 

14 

**14** 

14 

14   
LAWN F   
**1**   
0..127   
*VFXSD Musician's **Manual*** 

**Page Slot Range** 

Filter **pages**   
13 **0** 

**13** 1   
OHNM4no   
***Appendix A*** \- ***VFXTM MIDI** Specification* 

**Parameter Name and Description** 

Filter \#1 Type**:** \- LO-**PASS*/***2,LO\-**PASS**/3 **Filter \#**1 Cutoff 

Filter \#**1 Keyboard** Tracking Amount 

**Filter \#1 Mod** Source 

Filter \#**2 Type:**   
HI**\-PASS/2,HI-PASS**/1,LO-**PASS*/2***,LO-**PASS/1** 

Filter **\#2** Cutoff   
Filter \#**1 Mod Amount** 

Filter **\#1 Env2 Mod Amount** 

**2**   
\-127..+127   
Filter **\#2** Keyboard **Tracking** Amount 

3   
0..15   
Filter **\#2 Mod Source** 

**4**   
**\-127**..+**127**   
Filter **\#2 Mod Amount** 

5   
**\-127**..**\+127**   
Filter **\#*2* Env2** Mod **Amount** 

Output pages 

15   
0   
0..127 

15   
**1**   
0..15   
**Volume** 

Volume **Mod Source** 

15   
2   
**\-127**..**\+127**   
Volume Mod Amount 

15   
**3**   
**\-128..+127** 

15   
4,5   
21..108 

16   
0 

16 

16   
**3** 

16   
4 

16   
**5** 

17 0 

**17** 

**17**   
**3** 

17   
AWNOUA WE   
**1,2**   
**0..3** 

0..127   
**Keyboard** Scaling amount (**\-128=**ZONE) **Scaling Key Range** (**low** and high **keys) undefined** 

Output Destination**: \-** DRY,FX1**,FX2**,AUX Pan 

0..15   
**Pan Mod Source** 

**\-127**..+127 

0.1 

**1,2**   
0..2 

4,5   
**Pan Mod** Amount 

**Voice Pre-Gain Switch: \-** OFF,ON **Voice Priority:** \- LO,MED,HI **undefined** 

\-127..+127 Voice **Velocity Threshold** 

LFO **pages**   
18   
0   
0..99   
LFO Rate 

18 1   
**0..15**   
LFO **Rate Mod Source** 

**18** 2   
**\-127**..+127   
LFO **Rate** Mod Amount 

**18 3**   
**0..127**   
LFO **Depth** 

18   
4   
0..15   
LFO Depth Mod **Source** 

**18**   
**5**   
0.99   
LFO **Delay** 

19   
0,1   
**0..6** 

19   
**2**   
0,1 

**19**   
3,4,5 **0..127**   
LFO **Waveshape:** \-TRIANGLE,**SINE,**SINE/**TRI,** 

LFO **Restart Switch: \-** OFF,ON 

**Noise** Source **Rate**   
POS**/SIN,**SAWTOOTH,SQUARE 

**Appendix A 17**   
}   
{   
Envelope **pages**   
**20** 

**20** 

**20** 

**20** 

**20** 

**20** 

**21** 

**21** 

21 

21 

**21** 

21 

**22** 

**22** 

**22** 

22 

**22** 

23 

23 

**23** 

**23** 

**23** 

**24** 

**24** 

**24** 2 

**24** 

**24** 

**25** 

25 

25 

**25** 

**25** 

**26** 

26 

26 

26 

26 

26 

27   
OHNMIKO-NM4NOHMANO-NMTVO**\-**NMeno-MoHNM**&**No   
**0**   
***Appendix*** A \- ***VFXSD MIDI Specification*** 

**Page Slot Range**   
**Parameter** Name **and Description** 

**undefined**   
***VFXSD*** **Musician's *Manual*** 

**1**   
**0..127**   
**Env1 Initial Level** 

2   
0..127   
**Env1 Peak Level** 

**3**   
**0..127**   
**Env1** Breakpoint 1 Level 

0..127   
**Env1** Breakpoint **2 Level**   
5   
0..127   
Envi **Sustain** Level 

0   
undefined 

**1**   
0..99   
**Env1 Attack Time** 

**2** 

**3** 

5   
UAWN   
0..99   
**Env1 Decay 1** Time 

0..99   
Env1 Decay **2** Time 

0..99   
**Env1 Decay 3** Time 

\-100..+99   
**Env1 Release Time** 

0   
\-127..+**127**   
**Env1 Keyboard** Tracking   
**1,2**   
0..9 

**3**   
0..2 

**0..127** 

5   
**0..127** 

**0**   
**Env1** Velocity **Curve**   
**Env1** Mode**: \- NORMAL**,FINISH,REPEAT **Env1** Level Velocity **Sensitivity**   
**Env1 Attack Time** Velocity **Sensitivity undefined** 

**1**   
**0..127**   
**Env2 Initial** Level 

**23** 2 0..127   
**Env2 Peak** Level 

**3**   
0..127   
**Env2 Breakpoint** 1 **Level** 

**0..127**   
**Env2 Breakpoint 2** Level   
**5**   
**0..127**   
**Env2 Sustain Level** 

**0**   
undefined 

**1**   
0..99   
**Env2 Attack Time** 

5 

0   
NOVAWN.   
0..99   
Env2 Decay **1** Time   
24 **3** 0..99   
**Env2** Decay **2** Time   
0.99 \-100..+99   
**Env2 Decay 3** Time 

**Env2 Release Time** 

**\-127..+127**   
**Env2 Keyboard Tracking**   
1,2   
0..9   
**Env2** Velocity Curve   
3   
0..2 

4   
0..127   
**Env2 Mode: \-** NORMAL,FINISH**,**REPEAT **Env2** Level **Velocity Sensitivity**   
5   
**0..127** 

0   
**Env2 Attack** Time **Velocity Sensitivity undefined** 

1   
0..127   
**Env3** Initial **Level** 

**2**   
**0..127**   
**Env3 Peak** Level 

**3**   
**0..127**   
**Env3 Breakpoint** 1 Level 

0..127   
Env3 **Breakpoint 2** Level   
5   
**0.127**   
**Env3 Sustain Level** 

0   
**undefined** 

27   
**1**   
0..99   
**Env3 Attack** Time 

**27** 2 0..99   
**Env3 Decay 1** Time 

27 3   
0..99   
**Env3 Decay 2 Time** 

**27** 4   
0..99   
**Env3 Decay 3** Time 

**27**   
5   
**\-100..**\+99   
**Env3 Release** Time 

**28**   
0   
**\-127..**\+127   
**Env3 Keyboard** Tracking   
**28**   
**1,2**   
0..9 

28   
**3**   
0..2 

**28**   
**4**   
0..127   
**Env3 Velocity** Curve 

**Env3 Mode: \-** NORMAL,FINISH**,**REPEAT **Env3** Level **Velocity Sensitivity**   
**28**   
**5**   
0..127   
**Env3 Attack** Time **Velocity** Sensitivity 

**Appendix A \- 18**   
1 

1   
*VFXSD **Musician's Manual***   
**Appendix A \- *VFXSD MIDI Specification*** 

The effect parameter **pages are dependent on** the currently selected *effect*. When **changing** effect **page** parameters**, be** sure the **effect** type **is selected** first, otherwise parameter **values may be** invalid. When **the effect** type is changed, the other **effect** parameters assume preset **values.** The first four **slots** \[0..3**\]** of page 29 are common to all **effects** and exceptions are noted in **the** rotary **speaker** simulators. The following **table interprets the** values of Effect Type **(page 29,** slot 0,1). **The Parameter** Set Name corresponds to the parameter descriptions on **the** following **pages**. 

**Effect Type Preset Name** 

0 

1 

2 

**3** 

4 

5 

6 

7 

**8** 

9 

10 

11 

12 

**13** 

14 

**15** 

16 

17 

18 

19 

**20** 

**21**   
**LARGE.HALL.REVRB** 

ROOM.REVERB.1 

**DYNAMIC.REVERB** 

**8**\-**VOICE.CHORUS.1** 

CHORUS**\+REVERB.1** 

FLANGER**\+REVERB.1 SMALL HALL.REVRB** 

**ROOM.REVERB.2** CHORUS**\+REVERB.2 FLANGER**\+**REVERB.2** DELAY\+**REVERB.1** DELAY+REVERB.2 

FLANGE+**DLY\+**REV.1 

**FLANGE**\+DLY**\+REV.2** 

ROTO-SPKR\+DELAY 

CONCERT **REVERB** WARM CHAMBER GATED+ROOM.VERBS **DIRTY\-**ROTO+DELAY 

DYNAMIC.HALL 

**8\-VOICE.CHORUS.2** 

DLY+FLANGE\+HALL   
**Parameter Set Name Hall Reverb** 

**Hall** Reverb 

Dynamic **Reverb Multi\-Voice** Chorus **Chorus and Reverb Flanger** and **Reverb** Hall **Reverb Hall Reverb** 

**Chorus and Reverb Flanger** and **Reverb Delay** and Reverb **Delay** and Reverb 

**Flanger**, **Delay,** and **Reverb Flanger**, **Delay,** and **Reverb Rotary Speaker** Simulator Hall **and Room Reverb Hall and Room** Reverb 

**Gated and Room** Reverb 

**Rotary Speaker** Simulator with Distortion   
**Dynamic Reverb** 

**Multi-**Voice **Chorus** 

**Flanger**, **Delay,** and **Reverb** 

**Hall Reverb** 

**Page Slot Range** 29 0,1 0..15   
Parameter **Name and Description**   
**Effect** Type 

**Reverb** (**FX2)** Mix 

**undefined**   
29   
**2** 

29   
3 

**29**   
**4** 

**29**   
5 

30 

30   
2 

30   
**3**   
vmanöamfod   
**0..99**   
**Decay** Time 

**undefined** 

**0..127**   
**Reverb (FX1)** Mix 

**0..127** 

0,1 

**0..250** 

30 4,5 **0..127** 

**31**   
0 

1,2 0,1   
31 

**31**   
**3** 

**31** 4,5 0..99   
**Pre-delay Time** 

**undefined** 

Early **Reflection undefined** 

**FX2 Mode:** 

**\- NORMAL.STEREO.SEND**,LEFT.WET**/**RIGHT.DRY **undefined** 

**High** Frequency Damping 

**Appendix A \- 19**   
***Appendix*** **A \- *VFXSD MIDI Specification*** 

**Dynamic Reverb**   
***VFXSD Musician's Manual*** 

**Reverb (FX2) Mix** 

**Decay** Modulation Amount 

Pre-**delay** Time   
**Page Slot** Range   
**Parameter Name and Description**   
**29**   
4   
**0..127**   
**Reverb (FX1)** Mix 

**29**   
5   
**0..127** 

**30**   
**0,1**   
**\-128..127** 

**30**   
**2**   
0..250 

**30**   
3   
**0..11**   
**Decay** Modulation **Source**   
**30**   
4,5   
**0..127**   
ww **ww**   
**31**   
**0**   
**undefined** 

1,2   
0,1 

3 

**4,5** 0..99 

**Multi-Voice Chorus** 

**Page Slot Range**   
Early **Reflection** 

**FX2 Mode:** 

**\-** NORMAL.STEREO.SEND,LEFT.WET**/**RIGHT.DRY undefined 

**High** Frequency Damping 

Parameter **Name and Description**   
29 4 0..127   
**Chorus** (FX1) **Mix**   
**29**   
5   
**0..127**   
Chorus (FX2) Mix   
**30**   
**0**   
0.99   
**Chorus Rate** 

**30** 

30 2 

**30**   
**3** 

30   
AWN-   
0..127   
Chorus **Depth**   
**0..100**   
Chorus **Delay** Time 

**\-128..127** 

4,5 

**31**   
0 

**31**   
1,2   
0,1 

**31**   
**3-5**   
**Chorus Feedback** 

**undefined** 

**undefined** 

**FX2 Mode:** 

**NORMAL.STEREO.SEND** LEFT.WET**/RIGHT.DRY**   
**undefined** 

**Chorus and Reverb** 

**Page Slot Range**   
**Parameter Name and Description** 

29   
**29** 4 **0..127** 

**5**   
Chorus (FX1**) to Reverb Mix**   
**0..127**   
**Reverb** (**FX2)** Mix   
30 0   
0..99   
**Chorus Rate** 

30   
1   
0..127   
Chorus **Depth**   
30 **2** 

30   
**3** 

**30**   
4 

30   
5 

**31** 0,1 **31** 2 

**31**   
**3**   
NMANÖNM   
0..250   
Chorus **Delay** Time 

**\-128..127**   
**Chorus Rate Modulation** Amount 

**\-128..127**   
Chorus Depth Modulation Amount   
0..127   
**Chorus Mix** 

0,1   
LFO **Waveshape**   
0..11   
**Chorus Mod** Source 

**undefined** 

**31**   
**4,5**   
0,1   
**Reverb** High Frequency Cut Switch: **\-** OFF,ON 

VFXSD **version 2.00** added a **new** variation **of the** Chorus and **Reverb effect**, **which** includes a distortion parameter and eliminates **the** LFO **Waveshape** parameter. 

**Chorus and Reverb with Distortion** 

**31** 

**31**   
0,1 **3** 

**Appendix A \- 20**   
0..15   
**undefined** 

Overdrive Output Level (16 **values** from 00..99) 

1   
*VFXSD Musician's **Manual*** 

**Flanger and Reverb** 

**Page Slot Range** 

29 4 0..127   
Appendix ***A*** \- ***VFXSD MIDI** Specification* 

**Parameter Name and Description**   
**Flanger** (FX1) to **Reverb** Mix 

29 5   
0..127   
**Reverb** (**FX2)** Mix 

30 0   
0..99   
Flanger **Rate**   
**30**   
**1**   
0..127   
Flanger Minimum 

30 **2**   
0..127   
**Flanger** Maximum 

30   
**3**   
0..11 

30 4   
**\-128..127** 

**30** 5   
**\-128..127** 

**31**   
0   
0..15 

**31**   
**1** 

**31**   
2 **\-128..127** 

**31**   
**3** 

**31**   
4,5 0,1   
Flanger Rate Modulation Source 

Flanger Minimum Modulation Amount 

Flanger Maximum Modulation Amount Flanger Mix **Level** 

**undefined** 

Flanger Feedback 

undefined 

**Reverb** High **Frequency** Cut Switch: **\-** OFF,ON 

**Delay and Reverb** 

**Page Slot Range** 

29 4   
0..127 

29 **5**   
0..127 

30 0   
0..250 

**30**   
1   
**\-128..127** 

30 **2** 

**30**   
**3**   
**\-128..127** 

**30**   
4   
\-128..127 

**30**   
5   
0..127 

**31**   
0,1 

**31**   
**2**   
0..11 

**31**   
3 

**31** 4,5 0,1 

**Flanger, Delay, and Reverb** 

**Page Slot Range**   
**Parameter Name and Description**   
**Delay (**FX1) **to Reverb** Mix 

**Reverb (FX2)** Mix   
**Delay** Time 

**Delay** Regeneration 

undefined 

**Delay** Time Modulation Amount 

**Delay** Regeneration Modulation Amount **Delay Mix** 

undefined 

**Delay** Modulation Source 

**undefined** 

**Reverb High** Frequency **Cur Switch**: **\-** OFF,ON 

Parameter **Name and Description** 

Flanger and **Delay (FX1)** to Reverb Mix **Reverb (FX2)** Mix   
Flanger Rate   
29 4 0..127 29 5 30 0   
0..127 

0.99 

30 1   
0..127   
**Flanger** Minimum 

30   
**2**   
0..127   
**Flanger Maximum**   
30   
**3**   
**\-128..127**   
**Flanger** Feedback   
..   
**30**   
4,5   
**undefined** 

**31**   
0   
**0.200** 

**31**   
1   
\-128..127   
**Delay Regeneration** 

**31** 2   
**0..127** 

31   
**3** 

**31**   
4,5 0,1   
**Delay** Time 

**Delay Mix** 

**undefined** 

**Reverb High** Frequency **Cut Switch: \-** OFF,ON 

**Appendix A \-**   
**21**   
Appendix *A* \- ***VFXSD MIDI Specification*** 

**Rotary Speaker Simulator**   
***VFXSD*** Musician's ***Manual*** 

**Parameter Name and Description** Delay Time   
**Rotating** Speaker (FX1) to **Delay Mix** 

Lo-Rotor **Switch**: **\-** OFF.ON   
Page **Slot Range**   
29   
**2**   
0..250 

29   
**4**   
**0..127** 

29   
5   
0..127   
**Delay (FX2)** Mix   
30 0   
0..99   
Rotor **Speed** Low   
30   
1   
0..99   
Rotor **Speed High**   
**30**   
**2**   
0.1 

30   
3,4   
0..11 

30   
5   
0..2 

**31**   
0   
0..100 

**31**   
1 

31   
**2**   
**\-128..127**   
**Delay Repeats**   
**31**   
**3**   
**\-128..127**   
**31**   
4,5   
**0..127**   
**Stereo Width**   
**Rotor Speed** Modulation Source   
Motor **Mode: \- CONTIN,**SWITCH,TOGGLE Feedback **Lag**   
**undefined** 

**Feedback** Lag Amount 

**Hall and Room Reverb** 

31 

**31** 

31   
8888888mm   
29 **29** 5 30 0   
4 0..127   
Reverb (**FX1)** Mix   
0..127 

30 1   
**0..127**   
**Reverb** (FX2) Mix **undefined Diffusion**   
**30**   
2   
0..250   
Pre-**delay** Time   
**30**   
3,4   
0..127   
Early Reflection Level   
**30**   
5   
0..200   
Early **Reflection** Time   
0 

**1,2**   
0,1   
**31**   
**3**   
**\-128**..\+**127**   
4,5   
0.99 

**Gated and Room Reverb**   
**undefined** 

**FX2 Mode:\- NORMAL** STEREO.SEND LEFT.WET/RIGHT.DRY   
Low Frequency **Decay**   
**High** Frequency **Damping** 

**Reverb** (**FX1) Mix** Reverb (FX2**)** Mix   
29 29 5   
4 **0..127** 

0..127   
30 0   
0..200   
**Gate Time**   
30 1   
0..100   
**Slope**   
**30**   
**2**   
**0..127**   
30   
3,4 0..200   
**Threshold** 

Pre-**delay** Time   
**30**   
5   
0.200   
**Release** Time   
31   
0   
undefined 

31   
**1,2**   
0..250   
**Pre**\-**delay** Time   
**31**   
**3**   
**undefined** 

**31**   
4,5 0..99   
**High Frequency Damping** 

**Rotary Speaker Simulator with** Distortion   
8888888   
29 2 

**29** 

29 5 

**30** 

**30** 

**30** 

**30** 

**30** 5 

**31 31**   
N4KOHNMNOHNM   
0..250   
**Delay Time**   
0..127   
**Rotating Speaker** (FX1**)** to **Delay Mix**   
0..127   
**Delay (FX2)** Mix   
**0**   
0.99   
Rotor Speed Low   
1   
0..99   
Rotor Speed **High**   
**2**   
0..15   
**Overdrive** 

**3.4**   
0..11 

0..2 

0   
0..100 

1 

31 3 **31**   
**4,5**   
\-128..127 0..15   
**31** 2 \-128..127   
Rotor **Speed Modulation** Source   
Motor **Mode: \- CONTIN,SWITCH**, TOGGLE Feedback **Lag**   
**undefined** 

**Delay Repeats**   
Feedback Lag Amount   
Low **Rotor** Volume 

**Appendix A \- 22**   
*VFXSD Musician's Manual*   
***Appendix*** **B** \- ***VFXSD MIDI*** Implementation Chart 

**Appendix** B **VFXSD MIDI Implementation Chart** 

**MODEL: VFX-SD** 

**Function...**   
**MIDI Implementation** Chart   
**Version: 1.0** 

Recognized   
Remarks   
Transmitted 

Basic   
Default   
**1** 

Channel   
Channel   
1-16 

Default 

Mode   
Messages Altered   
**XX**   
**1** 

**1-16** 

1**, 3**, **4, Multi**   
**memorized** 

**(Global** Controllers **In MONO Mode)** 

**Note**   
**True** Voice   
Number   
21 \- **108**   
**21** \- **108** 

**Velocity**   
**Note ON** Note **OFF** 

After 

Touch   
Key's **Ch's** 

Pitch **Bender**   
0100 хо   
O 

X 

**Control Change** 

**Prog Change**   
True **\#** 

**System** Exclusive 

**System** Common   
**:** Song Pos **: Song Sel** 

**: Tune**   
**1.95** 

1 Mod **Wheel** 4 **Foot** 

**7** Volume 

**10** Pan 

**70** Momentary **Patch** Select **71** Timbre Parameter 72 Release Parameter 100 Registered **Param** Select 101 Registered Param **Select** 

0-127 

**O**   
**XXXX** │|00|X00|0   
**1-95** 

1 **Mod Wheel** 

4 Foot 

**7** Volume 

**10** Pan 

**70** Momentary Patch **Select 71** Timbre Parameter 72 Release Parameter **100** Registered **Param Select** 101 Registered **Param** Select 

**0 \- 119**, **124 \- 127**   
OOOX00   
**System Real** Time   
**: Clock**   
● Clock   
O Clock   
**:** Commands   
Start, **Stop, Cont**   
◇ **Start**, **Stop**, **Cont** 

Aux **Mes-** 

**sages**   
**: Local On/Off** 

**:** All Notes **Off** 

: Active Sense 

**:** Reset 

**Notes**   
\* A Note Off velocity **of** 64 is **always sent** for **all keys**. 

**Mode 1: OMNI ON**, **POLY** 

**Mode 3:** OMNI OFF, **POLY**   
Mode **2**: OMNI **ON**, MONO **Mode** 4: OMNI OFF **MONO**   
**programmable**   
**OX**   
: **YES** 

X **: NO** 

**Appendix** B **1** 