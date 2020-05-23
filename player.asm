;
; Intel 81x ICHx .wav player for DOS.
;
;
; Notice:  This program was generated for the ICH2 southbridge AC97 audio
;	 device.  It is assumed that ICH0 and ICH1's are compatible.
;
;	 The software does a PCI scan looking for the ICH2 device ID (2445)
;	 and only this device.  Code will have to be modified to support
;	 other ICH devices.
;

       	.DOSSEG
        .MODEL  small, c, os_dos

.386


        .CODE


        INCLUDE constant.inc
        INCLUDE ich2ac97.inc

	extern	setFree:NEAR
        extern  pciFindDevice:NEAR
        extern  pciRegRead16:NEAR
        extern  pciRegRead8:NEAR
        extern  pciRegWrite8:NEAR
        extern  codecConfig:NEAR
	extern	memAlloc:NEAR
        extern  processCmdline:NEAR
        extern  openFile:NEAR
        extern  closeFile:NEAR
        extern  filehandle:WORD
        extern  playWav:NEAR
        extern  getSampleRate:NEAR


; player internal variables and other equates.
FILESIZE        equ     64 * 1024       ; 64k file buffer size.




        .STARTUP

; memory allocation

        call    setFree                         ; deallocate unused DOS mem



; allocate 256 bytes of data for DCM_OUT Buffer Descriptor List. (BDL)

        mov     ax, BDL_SIZE / 16
        call    memAlloc
        mov     ds:[BDL_BUFFER], ax             ; segment 



; allocate 2 buffers, 64k each for now.

        mov     ax, FILESIZE / 16               ; 64k for .WAV file
        call    memAlloc
        mov     ds:[WAV_BUFFER1], ax            ; segment

	mov	ax, FILESIZE / 16
	call	memAlloc
	mov	ds:[WAV_BUFFER2], ax



; Detect/reset AC97 
; I have an ICH2 on my board, you might have an ICH0 or ICH4 or whatever.
; You may need to change this ICH2 device ID scan to match your hardware, or
; better yet, change it to support multiple devices.
;
        mov     eax, (ICH2_DID shl 16) + INTEL_VID
        call    pciFindDevice
        jnc     @f



; couldn't find the audio device!

	push	cs
	pop	ds
        lea     dx, noICH2Msg
        mov     ah, 9
        int     21h
        jmp     exit

noICH2Msg db "Error: Unable to find intel ICH2 based audio device!",CR,LF,"$"

@@:



; get ICH base address regs for mixer and bus master

        mov     al, NAMBAR_REG
        call    pciRegRead16			; read PCI registers 10-11
        and     dx, IO_ADDR_MASK 		; mask off BIT0

        mov     ds:[NAMBAR], dx                 ; save audio mixer base addy

        mov     al, NABMBAR_REG
        call    pciRegRead16
        and     dx, IO_ADDR_MASK

        mov     ds:[NABMBAR], dx                ; save bus master base addy

        
        mov     al, PCI_CMD_REG
        call    pciRegRead8                     ; read PCI command register
        or      dl, IO_ENA+BM_ENA               ; enable IO and bus master
        call    pciRegWrite8



; check the command line for a file to play

        push    ds
        call    processCmdline			; get the filename


; open the file
        
        mov     al, OPEN                        ; open existing file
        call    openFile                        ; no error? ok.
        pop     ds
        jnc     @f

; file not found!

        push    cs
        pop     ds
        lea     dx, noFileErrMsg
        mov     ah, 9
        int     21h
        jmp     exit

noFileErrMsg  db "Error: file not found.",CR,LF,"$"

@@:


        call    getSampleRate                   ; read the sample rate
                                                ; pass it onto codec.

; setup the Codec (actually mixer registers) 
        call    codecConfig                     ; unmute codec, set rates.

;
; position file pointer to start in actual wav data
; MUCH improvement should really be done here to check if sample size is
; supported, make sure there are 2 channels, etc.  
;

        mov     ah, 42h
        mov     al, 0                           ; from start of file
        mov     bx, cs:[filehandle]
        xor     cx, cx
        mov     dx, 44                          ; jump past .wav/riff header
        int     21h

; play the .wav file.  Most of the good stuff is in here.

        call    playWav



; close the .wav file and exit.

        call    closeFile

exit:
	
        mov     ax, 4c00h
	int 	21h



.DATA
public  BDL_BUFFER                      ; 256 byte buffer for descriptor list
public  WAV_BUFFER1,WAV_BUFFER2         ; 64k buffers for wav file storage
public  NAMBAR                          ; PCI BAR for mixer registers
public  NABMBAR                         ; PCI BAR for bus master registers

BDL_BUFFER      dw      0               ; segment of our 256byte BDL buffer
WAV_BUFFER1     dw      0               ; segment of our WAV storage
WAV_BUFFER2	dw	0		; segment of 2nd wav buffer
NAMBAR          dw      0               ; BAR for mixer
NABMBAR         dw      0               ; BAR for bus master regs

End


