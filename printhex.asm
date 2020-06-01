; SPDX-License-Identifier: CC-BY-SA-3.0
;
; Author: Dirk Wolfgang Glomp
; Source: https://stackoverflow.com/a/22897576
;
; DOS Print 32 bit value stored in EAX with hexadecimal output (for 80386+)
; (on 64 bit OS use DOSBOX)
;
; Entry: EAX=32 bit value (0 - FFFFFFFF) for example
;
        .DOSSEG
        .MODEL  small, c, os_dos

.386
.CODE

print32BitHexValue proc public
    push ds

    push ax             ;
    mov ax,@DATA        ; get the address of the data segment
    mov ds,ax           ; store the address in the data segment register
    pop ax              ; EAX should now contain the entry argument again

    pusha               ; Push all 16-bit general purpose registers
;-----------------------
; convert the value in EAX to hexadecimal ASCIIs
;-----------------------
    mov di,OFFSET ASCII32 ; get the offset address
    mov cl,8            ; number of ASCII
P32_1: rol eax,4           ; 1 Nibble (start with highest byte)
    mov bl,al
    and bl,0Fh          ; only low-Nibble
    add bl,30h          ; convert to ASCII
    cmp bl,39h          ; above 9?
    jna short P32_2
    add bl,7            ; "A" to "F"
P32_2: mov [di],bl         ; store ASCII in buffer
    inc di              ; increase target address
    dec cl              ; decrease loop counter
    jnz P32_1              ; jump if cl is not equal 0 (zeroflag is not set)
;-----------------------
; Print string
;-----------------------
    mov dx,OFFSET ASCII32 ; DOS 1+ WRITE STRING TO STANDARD OUTPUT
    mov ah,9            ; DS:DX->'$'-terminated string
    int 21h             ; maybe redirected under DOS 2+ for output to file
                        ; (using pipe character">") or output to printer

    popa
    pop ds

  ; return to caller...
    ret
print32BitHexValue      endp

print16BitHexValue proc public
    push ds

    push ax             ;
    mov ax,@DATA        ; get the address of the data segment
    mov ds,ax           ; store the address in the data segment register
    pop ax              ; AX should now contain the entry argument again

    pusha               ; Push all 16-bit general purpose registers
;-----------------------
; convert the value in AX to hexadecimal ASCIIs
;-----------------------
    mov di,OFFSET ASCII16 ; get the offset address
    mov cl,4            ; number of ASCII
P16_1: rol ax,4            ; 1 Nibble (start with highest byte)
    mov bl,al
    and bl,0Fh          ; only low-Nibble
    add bl,30h          ; convert to ASCII
    cmp bl,39h          ; above 9?
    jna short P16_2
    add bl,7            ; "A" to "F"
P16_2: mov [di],bl         ; store ASCII in buffer
    inc di              ; increase target address
    dec cl              ; decrease loop counter
    jnz P16_1              ; jump if cl is not equal 0 (zeroflag is not set)
;-----------------------
; Print string
;-----------------------
    mov dx,OFFSET ASCII16 ; DOS 1+ WRITE STRING TO STANDARD OUTPUT
    mov ah,9            ; DS:DX->'$'-terminated string
    int 21h             ; maybe redirected under DOS 2+ for output to file
                        ; (using pipe character">") or output to printer

    popa
    pop ds

  ; return to caller...
    ret
print16BitHexValue      endp

print8BitHexValue proc public
    push ds

    push ax             ;
    mov ax,@DATA        ; get the address of the data segment
    mov ds,ax           ; store the address in the data segment register
    pop ax              ; AL should now contain the entry argument again

    pusha               ; Push all 16-bit general purpose registers
;-----------------------
; convert the value in EAX to hexadecimal ASCIIs
;-----------------------
    mov di,OFFSET ASCII8 ; get the offset address
    mov cl,2            ; number of ASCII
P8_1: rol al,4            ; 1 Nibble
    mov bl,al
    and bl,0Fh          ; only low-Nibble
    add bl,30h          ; convert to ASCII
    cmp bl,39h          ; above 9?
    jna short P8_2
    add bl,7            ; "A" to "F"
P8_2: mov [di],bl         ; store ASCII in buffer
    inc di              ; increase target address
    dec cl              ; decrease loop counter
    jnz P8_1              ; jump if cl is not equal 0 (zeroflag is not set)
;-----------------------
; Print string
;-----------------------
    mov dx,OFFSET ASCII8 ; DOS 1+ WRITE STRING TO STANDARD OUTPUT
    mov ah,9            ; DS:DX->'$'-terminated string
    int 21h             ; maybe redirected under DOS 2+ for output to file
                        ; (using pipe character">") or output to printer

    popa
    pop ds

  ; return to caller...
    ret
print8BitHexValue      endp

.DATA
ASCII32 DB "00000000h",0Dh,0Ah,"$" ; buffer for ASCII string
ASCII16 DB "0000h",0Dh,0Ah,"$" ; buffer for ASCII string
ASCII8 DB "00h",0Dh,0Ah,"$" ; buffer for ASCII string

End
