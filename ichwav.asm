comment %

        DOS based .WAV player using AC'97 and codec interface.


%

       	.DOSSEG
        .MODEL  small, c, os_dos

.386


        .CODE
        INCLUDE constant.inc
        INCLUDE ich2ac97.inc

        extern  filehandle:WORD
	extern	BDL_BUFFER:WORD
	extern	WAV_BUFFER1:WORD
	extern	WAV_BUFFER2:WORD
	extern	NAMBAR:WORD
	extern	NABMBAR:WORD

; player internal variables and other equates.
FILESIZE        equ     64 * 1024       ; 64k file buffer size.
ENDOFFILE       equ     BIT0            ; flag for knowing end of file


;===========================================================================
; entry: none.  File is already open and [filehandle] filled.
; exit:  not until the song is finished or the user aborts.
;
playWav proc public
	

       ; load 64k into buffer 1

        mov     ax, ds:[WAV_BUFFER1]
        call    loadFromFile


       ; and 64k into buffer 2

        mov     ax, ds:[WAV_BUFFER2]
        call    loadFromFile


;
; register reset the DMA engine.  This may cause a pop noise on the output
; lines when the device is reset.  Prolly a better idea to mute output, then
; reset.
;
        mov     dx, ds:[NABMBAR]
        add     dx, PO_CR_REG                  ; set pointer to Cntl reg
        mov     al, RR                         ; set reset
        out     dx, al                         ; self clearing bit
;
;
; write last valid index to 31 to start with.
; The Last Valid Index register tells the DMA engine when to stop playing.
; 
; As we progress through the song we change the last valid index to always be
; something other than the index we're currently playing.  
;
        mov     al, 1
        call    setLastValidIndex


; create Buffer Descriptor List
;
; A buffer descriptor list is a list of pointers and control bits that the
; DMA engine uses to know where to get the .wav data and how to play it.
;
; I set it up to use only 2 buffers of .wav data, and whenever 1 buffer is
; playing, I refresh the other one with good data.
;
;
; For the control bits, you can specify that the DMA engine fire an interrupt
; after a buffer has been processed, but I poll the current index register
; to know when it's safe to update the other buffer.
;
; I set the BUP bit, which tells the DMA engine to just play 0's (silence)
; if it ever runs out of data to play.  Good for safety.
;
        push    es
        mov     ax, ds:[BDL_BUFFER]             ; get segment # for BDL
        mov     es, ax

        mov     cx, 32 / 2                      ; make 32 entries in BDL
        xor     di, di                          
@@:

; set buffer descriptor 0 to start of data file in memory
        movzx   eax, ds:[WAV_BUFFER1]
        shl     eax, 4                          ; convert seg:off ->0:offset
        stosd                                   ; store pointer to wavbuffer1

;
; set length to 32k samples.  1 sample is 16bits or 2bytes.
; Set control (bits 31:16) to BUP, bits 15:0=number of samples.
; 
        xor     eax, eax                        ;
        or      eax, BUP                        ;
        mov     ax,  FILESIZE / 2               ; 64k of data at 16bit each
        stosd                                   ; is 32k samples.  


; 2nd buffer:


        movzx   eax, ds:[WAV_BUFFER2]
        shl     eax, 4                          ; convert seg:off ->0:offset
        stosd                                   ; store pointer to wavbuffer2

; set length to 64k (32k of two 16 bit samples)
; Set control (bits 31:16) to BUP, bits 15:0=number of samples
; 
        xor     eax, eax
        or      eax, BUP
        mov     ax, FILESIZE / 2                ; 64k / 2 samples
        stosd                                   ; make size 64k, no IRQs

        loop    @b
        pop     es

;
; tell the DMA engine where to find our list of Buffer Descriptors.
; this 32bit value is a flat mode memory offset (ie no segment:offset)
;
; write NABMBAR+10h with offset of buffer descriptor list
;
        movzx   eax, ds:[BDL_BUFFER]
        mov     dx, ds:[NABMBAR]
        add     dx, PO_BDBAR_REG                ; set pointer to BDL
        shl     eax, 4                          ; convert seg:off to 0:off
        out     dx, eax                         ; write to AC97 controller
;
;
; All set.  Let's play some music.
;
;
        mov     dx, ds:[NABMBAR]
        add     dx, PO_CR_REG                   ; DCM out control register
        mov     al, RPBM
        out     dx, al                          ; set start!



;
; while DMA engine is running, examine current index and wait until it hits 1
; as soon as it's 1, we need to refresh the data in wavbuffer1 with another
; 64k.  Likewise when it's playing buffer 2, refresh buffer 1 and repeat.
;
   	        
tuneLoop:
	mov	dx, ds:[NABMBAR]
	add	dx, PO_CIV_REG
@@:	
        call    updateLVI               ; set LVI != CIV
        call    check4keyboardstop      ; keyboard halt?
        jc      exit                    ; 
        call    getCurrentIndex         ; read CIV to see if we can refresh.
	test	al, BIT0
        jz      @b                      ; loop if not ready yet.

  
	; refresh buffer 0
	mov     ax, ds:[WAV_BUFFER1]
        call    loadFromFile            ; refresh buffer 1 with new data
        jc      exit        		; exit if we ran out of data to play
       
@@:	
        call    updateLVI               ; same loop as above
        call    check4keyboardstop
        jc      exit
	call	getCurrentIndex
	test	al, BIT0
	jnz	@b

	; refresh buffer 1
	mov     ax, ds:[WAV_BUFFER2]
        call    loadFromFile
        jnc     tuneloop
        
exit:
        mov     dx, ds:[NABMBAR]        ; finshed with song, stop everything
        add     dx, PO_CR_REG           ; DCM out control register
        mov     al, 0
        out     dx, al                  ; stop player
	ret

playWav endp


; load data from file in 32k chunks.  Would be nice to load 1 64k chunk,
; but in DOS you can only load FFFF bytes at a time.
;
; entry: ax = segment to load data to
; exit: CY set if end of file reached.
; note: last file buffer is padded with 0's to avoid pops at the end of song.
; assumes file is already open.  uses [filehandle]
;
loadFromFile proc public
        push    ax
        push    cx
        push    dx
	push	es
	push	ds
	
	push	ds				; copy es->ds since we
	pop	es				; mess with DS

        test    es:[flags], ENDOFFILE		; have we already read the
        stc					; last of the file?
        jnz     endLFF
        
	mov     ds, ax
        xor     dx, dx                          ; load file into memory
        mov     cx, (FILESIZE / 2)              ; 32k chunk
	mov	ah, 3fh
	mov	bx, cs:[filehandle]
	int	21h
        
	clc
        cmp	ax, cx
	jz	@f

        or      es:[flags], ENDOFFILE           ; flag end of file
        call    padfill                         ; blank pad the remainder
        clc                                     ; don't exit with CY yet.
        jmp	endLFF
@@:
        add     dx, ax

        mov     cx, (FILESIZE / 2)              ; 32k chunk
	mov	ah, 3fh
	mov	bx, cs:[filehandle]
	int	21h
        clc
        cmp     ax, cx
        jz      endLFF

        or      es:[flags], ENDOFFILE           ; flag end of file
        call    padfill                         ; blank pad the remainder
        clc                                     ; don't exit with CY yet.
endLFF:
        pop	ds
	pop	es
	pop     dx
        pop     cx
        pop     ax
        ret
loadFromFile endp

; entry ds:ax points to last byte in file
; cx=target size
; note: must do byte size fill
; destroys bx, cx
;
padfill proc
        push    bx
        sub     cx, ax
        mov     bx, ax
        xor     al, al
@@:
        mov     byte ptr ds:[bx], al
        inc     bx
        loop    @b
        pop     bx
        ret
padfill endp



; examines the CIV and the LVI.  When they're the same, we set LVI <> CIV
; that way, we never run out of buffers to play.
;
updateLVI proc
	push	ax
	push	dx
	mov	dx, ds:[NABMBAR]
        add     dx, PO_CIV_REG          ; read Current Index Value
        in      ax, dx                  ; and Last Valid Index value together.

        cmp     al, ah                  ; are we playing the last index?
        jnz     @f                      ; no, never mind

        call    setNewIndex             ; set it to something else.
@@:
	pop	dx
	pop	ax
   	ret
updateLVI endp



; set the last valid index to something other than what we're currently
; playing so that we never end.
;
; this routine just sets the last valid index to 1 less than the index
; that we're currently playing, thus keeping it in and endless loop
; input: none
; outpt: none
;
setNewIndex proc
	push	ax
        call    getCurrentIndex                 ; get CIV
        test    ds:[flags], ENDOFFILE
        jnz     @f
        ; not at the end of the file yet.
        dec     al                              ; make new index <> current
        and     al, INDEX_MASK                  ; make sure new value is 0-31
@@:
        call    setLastValidIndex               ; write new value
        clc
        pop	ax
	ret
setNewIndex endp



; returns AL = current index value
getCurrentIndex proc
	push	dx
	mov	dx, ds:[NABMBAR]      		
	add	dx, PO_CIV_REG
	in	al, dx
	pop	dx
	ret
getCurrentIndex endp

; input AL = index # to stop on
setLastValidIndex proc
	push	dx
	mov	dx, ds:[NABMBAR]
	add	dx, PO_LVI_REG
        out     dx, al
	pop	dx
	ret
setLastValidIndex endp

; checks if either shift key has been pressed.  Exits with CY if so.
; 
check4keyboardstop proc

        push    ds
        push    0
        pop     ds		       ; examine BDA for keyboard flags
        test    byte ptr ds:[417h], (BIT0 OR BIT1)
        pop     ds
        stc
        jnz     @f
        clc
@@:
        ret
check4keyboardstop endp




.DATA
flags   dd      0
End

