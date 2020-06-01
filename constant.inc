;constants of stuff that seem hard to remember at times.

TRUE  EQU 1
FALSE EQU 0

ENABLED  EQU 1
DISABLED EQU 0

BIT0  EQU 1
BIT1  EQU 2
BIT2  EQU 4
BIT3  EQU 8
BIT4  EQU 10h
BIT5  EQU 20h
BIT6  EQU 40h
BIT7  EQU 80h
BIT8  EQU 100h
BIT9  EQU 200h
BIT10 EQU 400h
BIT11 EQU 800h
BIT12 EQU 1000h
BIT13 EQU 2000h
BIT14 EQU 4000h
BIT15 EQU 8000h
BIT16 EQU 10000h
BIT17 EQU 20000h
BIT18 EQU 40000h
BIT19 EQU 80000h
BIT20 EQU 100000h
BIT21 EQU 200000h
BIT22 EQU 400000h
BIT23 EQU 800000h
BIT24 EQU 1000000h
BIT25 EQU 2000000h
BIT26 EQU 4000000h
BIT27 EQU 8000000h
BIT28 EQU 10000000h
BIT29 EQU 20000000h
BIT30 EQU 40000000h
BIT31 EQU 80000000h


;special characters
NUL     EQU 0
NULL    EQU 0
BELL    EQU 07
BS      EQU 08
TAB     EQU 09
LF      EQU 10
CR      EQU 13
ESCAPE  EQU 27           ;ESC is a reserved word....


;file stuff
READONLY  EQU   BIT0
HIDDEN    EQU   BIT1
SYSTEM    EQU   BIT2
VOLUME    EQU   BIT3         ;ignored for file access
DIRECTORY EQU   BIT4         ;must be 0 for file access
ARCHIVE   EQU   BIT5
SHAREABLE EQU   BIT7         ;for novell networks
OPEN	EQU	2		; open existing file
CREATE	EQU	1		; create new file


; PCI equates
; PCI function address (PFA)
; bit 31 = 1
; bit 23:16 = bus number     (0-255)
; bit 15:11 = device number  (0-31)
; bit 10:8 = function number (0-7)
; bit 7:0 = register number  (0-255)

IO_ADDR_MASK    EQU     0FFFEh          ; mask off bit 0 for reading BARs
PCI_INDEX_PORT  EQU     0CF8h
PCI_DATA_PORT   EQU     0CFCh
PCI32           EQU     BIT31           ; bitflag to signal 32bit access
PCI16           EQU     BIT30           ; bitflag for 16bit access

PCI_FN0         EQU     (0 shl 8)
PCI_FN1         EQU     (1 shl 8)
PCI_FN2         EQU     (2 shl 8)
PCI_FN3         EQU     (3 shl 8)
PCI_FN4         EQU     (4 shl 8)
PCI_FN5         EQU     (5 shl 8)
PCI_FN6         EQU     (6 shl 8)
PCI_FN7         EQU     (7 shl 8)

PCI_CMD_REG		EQU	04h		; reg 04, command reg
PCI_SUBSYS_REG	EQU 2Ch 	; reg 2C, subsystem reg
 IO_ENA			EQU	BIT0		; i/o decode enable
 MEM_ENA		EQU	BIT1		; memory decode enable
 BM_ENA			EQU BIT2		; bus master enable

PCI_BIOS_INT     EQU 1Ah      ; PCI BIOS interface interrupt
PCI_BIOS_PRESENT EQU 0B101h   ; PCI BIOS funcion to check for presence of PCI BIOS