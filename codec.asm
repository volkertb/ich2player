; codec configuration code.  Not much here really.
;
;
; improvements to be made:  Adjustable volume control for output.  Code
; below just maxes everything out (It has been made optional, so you don't
; blame me for blowing up your speakers)
;
; The delay1_4ms routines are just wait loops to let the codec handle the request.
; I think there's a status bit somewhere you can poll to know when it's safe
; to talk to the mixer registers, but a little waiting never hurt anyone.
;
;
       	.DOSSEG
        .MODEL  small, c, os_dos

.386


        .CODE

        extern  NAMBAR:word
        extern  NABMBAR:WORD
        extern  DETECTED_PCI_DEV:DWORD
        extern  delay1_4ms:NEAR

        include codec.inc
        include ich2ac97.inc


; enable codec, unmute stuff, set output rate to 44.1
; entry: ax = desired sample rate
;        bh = Y to change the output volume (sets it to MAXIMUM, be careful!)
;        (output volume will remain untouched if bh has any other value)
;
codecConfig proc public
        push    ax
        push    dx

        mov     dx, ds:[NAMBAR]                 ; get mixer base address
        add     dx, CODEC_PCM_FRONT_DACRATE_REG ; register 2ch
        out     dx, ax                          ; out sample rate

        call    delay1_4ms
        call    delay1_4ms
        call    delay1_4ms
        call    delay1_4ms

        ; Skip volume adjustment if not requested
        cmp bh,"Y"
        jnz skip_volume_adjustment

; If the detected device is a SiS7012, apply device-specific unmute quirk:
        mov eax,dword ptr[DETECTED_PCI_DEV]
        cmp eax,(SIS_7012_DID shl 16) + SIS_VID
        jne noSis7012QuirksNeeded
        call unmuteSis7012

noSis7012QuirksNeeded:

;
;
; This stuff sets the volume to MAXIMUM.
; be careful if you use it this way.
;

        mov     dx, ds:[NAMBAR]
        add     dx, CODEC_MASTER_VOL_REG        ;2
        xor     ax, ax
        out     dx, ax

        call    delay1_4ms                      ; delays cuz codecs are slow
        call    delay1_4ms
        call    delay1_4ms
        call    delay1_4ms


        mov     dx, ds:[NAMBAR]
        add     dx, CODEC_PCM_OUT_REG           ; 18
        out     dx, ax

        call    delay1_4ms
        call    delay1_4ms
        call    delay1_4ms
        call    delay1_4ms

skip_volume_adjustment:

        pop     dx
        pop     ax
        ret
codecConfig endp

; Unmute quirk specifically for the SiS7012
unmuteSis7012 proc public
        push    ax
        push    dx

        mov     dx, ds:[NABMBAR]
        add     dx, CUSTOM_SIS_7012_REG
        in      ax, dx
        or      ax, 00000001b
        out     dx, ax

        pop     dx
        pop     ax
        ret
unmuteSis7012 endp










end
