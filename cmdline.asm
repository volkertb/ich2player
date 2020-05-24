;	Simple command line examination routine.


        .DOSSEG
        .MODEL  small, c, os_dos

.386
.CODE

        INCLUDE constant.inc

; parse the command line
; entry: none
; exit: DS:DX to the 1st supplied item on the command line
;                    (other than an optional "/V" or "/v" before it)
;       AH = "Y" if a "/V" or "/v" parameter was specified as the first parameter
;       AH = "N" if no more than one parameter was specified
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
        cmp     al, "/"                 ; found a slash?
        jnz     no_slash
        call forward_slash_detected
no_slash:
        cmp     al, " "                 ; found a space?
        jz      cmdlineloop

        ; must be the filename here.
exitpc:
        dec     si                      ; point to start of filename
        mov     dx, si
        pop     si
        pop     bx

        ; Store the value of change_volume in AH before returning
        push ds
        mov ax,@data
        mov ds,ax
        mov ah,byte ptr[change_volume]
        pop ds

        ret
processCmdline endp

forward_slash_detected:

        ; read the character right after the slash
        lodsb

        cmp     al, "v"                 ; /v ?
        jz     volume_change_requested
        cmp     al, "V"                 ; /V ?
        jz     volume_change_requested
        jmp slash_parameter_evaluated

        volume_change_requested:
            push ds
            push ax
            push dx

            ; Print message acknowledging volume change request
            lea dx, volume_change_requested_msg
            mov ax,@data
            mov ds,ax
            mov ah, 9
            int 21h

            ; Set change_volume variable to YES
            mov byte ptr[change_volume],"Y"

            pop dx
            pop ax
            pop ds

        slash_parameter_evaluated:

            ; read the next character before returning
            lodsb

        ret

.DATA
volume_change_requested_msg db  "Volume change requested.",CR,LF,"$"
; Variable that determines whether or not to adjust the sound output volume
change_volume               db  "N"

end
