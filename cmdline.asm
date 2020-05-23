;	Simple command line examination routine.


        .DOSSEG
        .MODEL  small, c, os_dos

.386
.CODE

        INCLUDE constant.inc

; parse the command line
; entry: none
; exit: DS:DX to the 1st supplied item on the command line 
processCmdline proc public

        
        push    bx
        push    si


        mov     ah, 51h
        int     21h
        mov     ds, bx

        mov     si, 80h
        movzx   bx, byte ptr[si]
        add     si, bx
        inc     si

        mov     byte ptr[si], NULL             ;zero terminate

        mov     si, 81h

cmdlineloop:

        lodsb

        cmp     al, NULL                ; found end of line?
        jz      exitpc
        cmp     al, " "                 ; found a space?
        jz      cmdlineloop

        ; must be the filename here.
exitpc:
        dec     si                      ; point to start of filename
        mov     dx, si
        pop     si
        pop     bx
        
        ret
processCmdline endp


end
