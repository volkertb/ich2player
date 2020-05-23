;
; file support routines.
;
;

	.DOSSEG
        .MODEL  small, c, os_dos

.CODE

        INCLUDE constant.inc


;open or create file
;
;input: ds:dx-->filename (asciiz)
;       al=file Mode (create or open)
;output: none  cs:[filehandle] filled
;
openFile proc public
	push	ax
	push	cx
	mov	ah, 3bh			; start with a mode
	add	ah, al			; add in create or open mode
	xor	cx, cx
	int	21h
	jc	@f
	mov	cs:[filehandle], ax
@@:
	pop	cx
	pop	ax
	ret
public filehandle
filehandle	dw	?

openFile endp


; close the currently open file
; input: none, uses cs:[filehandle]
closeFile proc public
	push	ax
	push	bx
	cmp	cs:[filehandle], -1
	jz	@f
	mov     bx, cs:[filehandle]  
	mov     ax,3e00h
        int     21h              ;close file
@@:
	pop	bx
	pop	ax
	ret
closeFile endp


getSampleRate proc public
; reads the sample rate from the .wav file.
; entry: none - assumes file is already open
; exit: ax = sample rate in hex
;
        push    bx
        push    cx
        push    dx
        push    ds

        mov     ah, 42h
        mov     al, 0                           ; from start of file
        mov     bx, cs:[filehandle]
        xor     cx, cx
        mov     dx, 18h                         ; jump past .wav/riff header
        int     21h

        push    cs
        pop     ds
        lea     dx, sampleRateBuffer
        mov     cx, 2                           ; 2 bytes
	mov	ah, 3fh
        int     21h

        mov     ax, [sampleRateBuffer]		; return rate in AX
        pop     ds
        pop     dx
        pop     cx
        pop     bx
        ret
sampleRateBuffer        dw      0
getSampleRate endp


end
