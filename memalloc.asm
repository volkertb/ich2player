comment %

 memory management routines

%



        .DOSSEG
        .MODEL  small, c, os_dos

.386
.CODE

        INCLUDE constant.inc





memAlloc proc near public
; input: AX = # of paragraphs required
; output: AX = segment of block to use

	push	bx
	mov	bx, ax
	mov	ah, 48h
	int	21h
	pop	bx
	ret
memAlloc endp


	

FreeMem	proc
; deallocate a memory block 
; input AX=segment of block to free
; output CY set if failure

	push	ax
	push	es
	mov	es, ax
	mov	ah, 49h
	int	21h
	pop	es
	pop	ax
	ret
Freemem	endp



;-- SETFREE: Release memory not used  ----------------
;-- Input    : ES = address of PSP
;-- Output   : none
;-- Register : AX, BX, CL and FLAGS are changed 
;-- Info     : Since the stack-segment is always the last segment in an 
;              EXE-file, ES:0000 points to the beginning and SS:SP
;              to the end of the program in memory. Through this the
;              length of the program can be calculated 
; call this routine once at the beginning of the program to free up memory
; assigned to it by DOS.

setFree   proc near public

          mov  bx,ss              ;first subtract the two segment addresses
          mov  ax,es              ;from each other. The result is
          sub  bx,ax              ;number of paragraphs from PSP
                                  ;to the beginning of the stack
          mov  ax,sp              ;since the stackpointer is at the end of
          mov  cl,4               ;the stack segment, its content indicates
          shr  ax,cl              ;the length of the stack
          add  bx,ax              ;add to current length
          inc  bx                 ;as precaution add another paragraph

          mov  ah,4ah             ;pass new length to DOS
          int  21h
@@:
          ret                     ;back to caller

setFree   endp
end
