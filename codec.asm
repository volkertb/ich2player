; codec configuration code.  Not much here really.
;
;
; improvements to be made:  Adjustable volume control for output.  Code
; below just maxes everything out (I commented it out so you don't blame me
; for blowing up your speakers)
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
        extern  delay1_4ms:NEAR

        include codec.inc


; enable codec, unmute stuff, set output rate to 44.1
; entry: ax = desired sample rate
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

;
;
; This stuff that's commented out sets the volume to MAXIMUM.
; be careful if you use it this way.
;


  ;      mov     dx, ds:[NAMBAR]
  ;      add     dx, CODEC_MASTER_VOL_REG        ;2 
  ;      xor     ax, ax
  ;      out     dx, ax
  ;
  ;      call    delay1_4ms                      ; delays cuz codecs are slow
  ;      call    delay1_4ms
  ;      call    delay1_4ms
  ;      call    delay1_4ms
  ;
  ;
  ;      mov     dx, ds:[NAMBAR]
  ;      add     dx, CODEC_PCM_OUT_REG           ; 18
  ;      out     dx, ax
  ;
  ;      call    delay1_4ms
  ;      call    delay1_4ms
  ;      call    delay1_4ms
  ;      call    delay1_4ms

        pop     dx
        pop     ax
        ret
codecConfig endp











end
