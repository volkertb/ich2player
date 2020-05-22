comment %

Non platform specific utilites.


%
        .DOSSEG
        .MODEL  small, c, os_dos

.386
.CODE

        INCLUDE constant.inc

;----------------------------------------------------------------------------
;       delay1_4ms - Delay for 1/4 millasecond.
;		    1mS = 1000us
;       Entry:
;         None
;       Exit:
;	  None
;
;       Modified:
;         None
;
PORTB			EQU	061h
  REFRESH_STATUS	EQU	010h		; Refresh signal status
delay1_4ms PROC public
        push    ax 
        push    cx
        mov     cx, 16			; close enough.
	in	al,PORTB
	and	al,REFRESH_STATUS
	mov	ah,al			; Start toggle state
	or	cx, cx
	jz	@f
	inc	cx			; Throwaway first toggle
;
@@:	
	in	al,PORTB		; Read system control port
	and	al,REFRESH_STATUS	; Refresh toggles 15.085 microseconds
	cmp	ah,al
	je	@b			; Wait for state change
;
	mov	ah,al			; Update with new state
	dec	cx
	jnz	@b
;
        pop     cx
        pop     ax
        ret
delay1_4ms     ENDP
End
