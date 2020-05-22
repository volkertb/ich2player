comment %


Intel ICH2 equates.  It is assumed that ICH0 and plain ole ICH are compatible.


%


; PCI stuff

INTEL_VID       equ     8086h           ; Intel's PCI vendor ID
ICH_DID         equ     2415h           ; ICH device ID
ICH0_DID        equ     2425h           ; ICH0
ICH2_DID        equ     2445h           ; ICH2  I think there are more ICHes.
                                        ; they all should be compatible.

NAMBAR_REG      equ     10h             ; native audio mixer BAR
 NAM_SIZE       equ     256             ; 256 bytes required.

NABMBAR_REG     equ     14h             ; native audio bus mastering BAR
 NABM_SIZE      equ     64              ; 64 bytes



; BUS master registers, accessed via NABMBAR+offset

; ICH supports 3 different types of register sets for three types of things
; it can do, thus:
;
; PCM in (for recording) aka PI
; PCM out (for playback) aka PO
; MIC in (for recording) aka MC

PI_BDBAR_REG            equ     0       ; PCM in buffer descriptor BAR
PO_BDBAR_REG            equ     10h     ; PCM out buffer descriptor BAR
MC_BDBAR_REG            equ     20h     ; MIC in buffer descriptor BAR

; each buffer descriptor BAR holds a pointer which has entries to the buffer
; contents of the .WAV file we're going to play.  Each entry is 8 bytes long
; (more on that later) and can contain 32 entries total, so each BAR is
; 256 bytes in length, thus:

BDL_SIZE                equ     32*8    ; Buffer Descriptor List size
INDEX_MASK              equ     31      ; indexes must be 0-31



PI_CIV_REG              equ     4       ; PCM in current Index value (RO)
PO_CIV_REG              equ     14h     ; PCM out current Index value (RO)
MC_CIV_REG              equ     24h     ; MIC in current Index value (RO)
;8bit read only
; each current index value is simply a pointer showing us which buffer
; (0-31) the codec is currently processing.  Once this counter hits 31, it
; wraps back to 0.
; this can be handy to know, as once it hits 31, we're almost out of data to
; play back or room to record!


PI_LVI_REG              equ     5       ; PCM in Last Valid Index
PO_LVI_REG              equ     15h     ; PCM out Last Valid Index
MC_LVI_REG              equ     25h     ; MIC in Last Valid Index
;8bit read/write
; The Last Valid Index is a number (0-31) to let the codec know what buffer
; number to stop on after processing.  It could be very nasty to play audio
; from buffers that aren't filled with the audio we want to play.


PI_SR_REG               equ     6       ; PCM in Status register
PO_SR_REG               equ     16h     ; PCM out Status register
MC_SR_REG               equ     26h     ; MIC in Status register
;16bit read/write
; status registers.  Bitfields follow:

FIFO_ERR                equ     BIT4    ; FIFO Over/Underrun W1TC.

BCIS                    equ     BIT3    ; buffer completion interrupt status.
                                        ; Set whenever the last sample in ANY
                                        ; buffer is finished.  Bit is only
                                        ; set when the Interrupt on Complete
                                        ; (BIT4 of control reg) is set.

LVBCI                   equ     BIT2    ; Set whenever the codec has processed
                                        ; the last buffer in the buffer list.
                                        ; Will fire an interrupt if IOC bit is
                                        ; set. Probably set after the last
                                        ; sample in the last buffer is
                                        ; processed.  W1TC

                                        ; 
CELV                    equ     BIT1    ; Current buffer == last valid.
                                        ; Bit is RO and remains set until LVI is
                                        ; cleared.  Probably set up the start
                                        ; of processing for the last buffer.


DCH                     equ     BIT0    ; DMA controller halted.
                                        ; set whenever audio stream is stopped
                                        ; or something else goes wrong.


PI_PICB_REG             equ     8       ; PCM in position in current buffer(RO)
PO_PICB_REG             equ     18h     ; PCM out position in current buffer(RO)
MC_PICB_REG             equ     28h     ; MIC in position in current buffer (RO)
;16bit read only
; position in current buffer regs show the number of dwords left to be
; processed in the current buffer.
; 





PI_PIV_REG              equ     0ah     ; PCM in Prefected index value
PO_PIV_REG              equ     1ah     ; PCM out Prefected index value
MC_PIV_REG              equ     2ah     ; MIC in Prefected index value
;8bit, read only
; Prefetched index value register.
; tells which buffer number (0-31) has be prefetched.  I'd imagine this
; value follows the current index value fairly closely. (CIV+1)
;


PI_CR_REG               equ     0bh     ; PCM in Control Register
PO_CR_REG               equ     1bh     ; PCM out Control Register
MC_CR_REG               equ     2bh     ; MIC in Control Register
; 8bit
; Control register *MUST* only be accessed as an 8bit value.
; Control register.  See bitfields below.
;


IOCE                    equ     BIT4    ; interrupt on complete enable.
                                        ; set this bit if you want an intrtpt
                                        ; to fire whenever LVBCI is set.
FEIFE                   equ     BIT3    ; set if you want an interrupt to fire
                                        ; whenever there is a FIFO (over or
                                        ; under) error.
LVBIE                   equ     BIT2    ; last valid buffer interrupt enable.
                                        ; set if you want an interrupt to fire
                                        ; whenever the completion of the last
                                        ; valid buffer.
RR                      equ     BIT1    ; reset registers.  Nukes all regs
                                        ; except bits 4:2 of this register.
                                        ; Only set this bit if BIT 0 is 0
RPBM                    equ     BIT0    ; Run/Pause
                                        ; set this bit to start the codec!


GLOB_CNT_REG            equ     2ch     ; Global control register
SEC_RES_EN              equ     BIT5    ; secondary codec resume event 
                                        ; interrupt enable.  Not used here.
PRI_RES_EN              equ     BIT4    ; ditto for primary. Not used here.
ACLINK_OFF              equ     BIT3    ; Turn off the AC97 link
ACWARM_RESET            equ     BIT2    ; Awaken the AC97 link from sleep.
                                        ; registers preserved, bit self clears
ACCOLD_RESET            equ     BIT1    ; Reset everything in the AC97 and
                                        ; reset all registers.  Not self clearing

GPIIE                   equ     BIT0    ; GPI Interrupt enable.
                                        ; set if you want an interrupt to
                                        ; fire upon ANY of the bits in the
                                        ; GPI (general pursose inputs?) not used.

GLOB_STS_REG            equ     30h     ; Global Status register (RO)

MD3                     equ     BIT17   ; modem powerdown status (yawn)
AD3                     equ     BIT16   ; Audio powerdown status (yawn)
RD_COMPLETE_STS         equ     BIT15   ; Codec read timed out. 0=normal
BIT3SLOT12              equ     BIT14   ; shadowed status of bit 3 in slot 12
BIT2SLOT12              equ     BIT13   ; shadowed status of bit 2 in slot 12
BIT1SLOT12              equ     BIT12   ; shadowed status of bit 1 in slot 12
SEC_RESUME_STS          equ     BIT11   ; secondary codec has resumed (and irqed)
PRI_RESUME_STS          equ     BIT10   ; primary codec has resumed (and irqed)
SEC_CODEC_RDY           equ     BIT9    ; secondary codec is ready for action
PRI_CODEC_RDY           equ     BIT8    ; Primary codec is ready for action
                                        ; software must check these bits before
                                        ; starting the codec!
MIC_IN_IRQ              equ     BIT7    ; MIC in caused an interrupt
PCM_OUT_IRQ             equ     BIT6    ; One of the PCM out channels IRQed
PCM_IN_IRQ              equ     BIT5    ; One of the PCM in channels IRQed
MODEM_OUT_IRQ           equ     BIT2    ; modem out channel IRQed
MODEM_IN_IRQ            equ     BIT1    ; modem in channel IRQed
GPI_STS_CHANGE          equ     BIT0    ; set whenever GPI's have changed.
                                        ; BIT0 of slot 12 also reflects this.


ACC_SEMA_REG            equ     34h     ; Codec write semiphore register
CODEC_BUSY              equ     BIT0    ; codec register I/O is happening
                                        ; self clearing



;
; Buffer Descriptors List
; As stated earlier, each buffer descriptor list is a set of (up to) 32 
; descriptors, each 8 bytes in length.  Bytes 0-3 of a descriptor entry point
; to a chunk of memory to either play from or record to.  Bytes 4-7 of an
; entry describe various control things detailed below.
; 
; Buffer pointers must always be aligned on a Dword boundry.
;
;

IOC                     equ     BIT31   ; Fire an interrupt whenever this
                                        ; buffer is complete.

BUP                     equ     BIT30   ; Buffer Underrun Policy.
                                        ; if this buffer is the last buffer
                                        ; in a playback, fill the remaining
                                        ; samples with 0 (silence) or not.
                                        ; It's a good idea to set this to 1
                                        ; for the last buffer in playback,
                                        ; otherwise you're likely to get a lot
                                        ; of noise at the end of the sound.

;
; Bits 15:0 contain the length of the buffer, in number of samples, which
; are 16 bits each, coupled in left and right pairs, or 32bits each.
; Luckily for us, that's the same format as .wav files.
;
; A value of FFFF is 65536 samples.  Running at 44.1Khz, that's just about
; 1.5 seconds of sample time.  FFFF * 32bits is 1FFFFh bytes or 128k of data.
;
; A value of 0 in these bits means play no samples.
;



