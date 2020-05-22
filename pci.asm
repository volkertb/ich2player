comment %

	PCI device register reader/writers.
%


        .DOSSEG
        .MODEL  small, c, os_dos

.386
.CODE

        INCLUDE constant.inc

;===============================================================
; 8/16/32bit PCI reader
;
; Entry: EAX=PCI Bus/Device/fn/register number
;           BIT30 set if 32 bit access requested
;           BIT29 set if 16 bit access requested
;           otherwise defaults to 8bit read
;
; Exit:  DL,DX,EDX register data depending on requested read size
;
; Note: this routine is meant to be called via pciRegRead8, pciRegread16,
;	or pciRegRead32, listed below.
;
; Note2: don't attempt to read 32bits of data from a non dword aligned reg
;	 number.  Likewise, don't do 16bit reads from non word aligned reg #
;        
pciRegRead proc public

	push	ebx
	push	cx
        mov     ebx, eax                        ; save eax, dh
        mov     cl, dh
        and     eax, NOT PCI32+PCI16            ; clear out data size request
        or      eax, BIT31                      ; make a PCI access request
        and     al, NOT 3                       ; force index to be dword

        mov     dx, PCI_INDEX_PORT
        out     dx, eax                         ; write PCI selector

        mov     dx, PCI_DATA_PORT
        mov     al, bl
        and     al, 3                           ; figure out which port to
        add     dl, al                          ; read to

	in      eax, dx                         ; do 32bit read
        test    ebx, PCI32
        jz      @f

        mov     edx, eax                        ; return 32bits of data
@@:
	mov     dx, ax                          ; return 16bits of data
        test    ebx, PCI32+PCI16
        jnz     @f
        mov     dh, cl                          ; restore dh for 8 bit read
@@:
        mov     eax, ebx                        ; restore eax
        and     eax, NOT PCI32+PCI16            ; clear out data size request
	pop	cx
	pop	ebx
	ret
pciRegRead      endp


public pciRegRead8 
public pciRegRead16
public pciRegRead32 

pciRegRead8:
        and     eax, NOT PCI16+PCI32            ; set up 8 bit read size
        jmp     pciRegRead			; call generic PCI access

pciRegRead16:
        and     eax, NOT PCI16+PCI32		; set up 16 bit read size
        or      eax, PCI16			; call generic PCI access
        jmp     pciRegRead

pciRegRead32:
        and     eax, NOT PCI16+PCI32		; set up 32 bit read size
        or      eax, PCI32			; call generic PCI access
        jmp     pciRegRead




;===============================================================
; 8/16/32bit PCI writer
;
; Entry: EAX=PCI Bus/Device/fn/register number
;           BIT31 set if 32 bit access requested
;           BIT30 set if 16 bit access requested
;           otherwise defaults to 8bit read
;        DL/DX/EDX data to write depending on size
;
;
; note: this routine is meant to be called via pciRegWrite8, pciRegWrite16,
; 	or pciRegWrite32 as detailed below.
;
; Note2: don't attempt to write 32bits of data from a non dword aligned reg
;	 number.  Likewise, don't do 16bit writes from non word aligned reg #
;
pciRegWrite proc

	push	ebx
	push	cx
        mov     ebx, eax                        ; save eax, dx
        mov     cx, dx
        or      eax, BIT31                      ; make a PCI access request
        and     eax, NOT PCI16                  ; clear out data size request
        and     al, NOT 3                       ; force index to be dword

        mov     dx, PCI_INDEX_PORT
        out     dx, eax                         ; write PCI selector

        mov     dx, PCI_DATA_PORT
        mov     al, bl
        and     al, 3                           ; figure out which port to
        add     dl, al                          ; write to

        mov     eax, edx                        ; put data into eax
        mov     ax, cx

        out     dx, al
        test    ebx, PCI16+PCI32                ; only 8bit access? bail
        jz      @f

        out     dx, ax                          ; write 16 bit value
        test    ebx, PCI16                      ; 16bit requested?  bail
        jnz     @f

        out     dx, eax                         ; write full 32bit
@@:
        mov     eax, ebx                        ; restore eax
        and     eax, NOT PCI32+PCI16            ; clear out data size request
        mov     dx, cx                          ; restore dx
	pop	cx
	pop	ebx
	ret
pciRegWrite      endp


public  pciRegWrite8
public  pciRegWrite16
public  pciRegWrite32

pciRegWrite8:
        and     eax, NOT PCI16+PCI32		; set up 8 bit write size
        jmp     pciRegWrite			; call generic PCI access

pciRegWrite16:
        and     eax, NOT PCI16+PCI32		; set up 16 bit write size
        or      eax, PCI16			; call generic PCI access
        jmp     pciRegWrite

pciRegWrite32:
        and     eax, NOT PCI16+PCI32		; set up 32 bit write size
        or      eax, PCI32			; call generic PCI access
        jmp     pciRegWrite





;===============================================================
; PCIFindDevice: scan through PCI space looking for a device+vendor ID
;
; Entry: EAX=Device+vendor ID
;
;  Exit: EAX=PCI address if device found
;        CY clear if found, set if not found. EAX invalid if CY set.
;
; [old stackless] Destroys: ebx, edx, esi, edi, cl
;
pciFindDevice proc  near public

	push	cx
	push	edx
	push	esi
	push	edi

        mov     esi, eax                ; save off vend+device ID
        mov     edi, (80000000h - 100h) ; start with bus 0, dev 0 func 0

nextPCIdevice:
        add     edi, 100h
        cmp     edi, 80fff800h		; scanned all devices?
        stc
        jz      PCIscanExit             ; not found

        mov     eax, edi                ; read PCI registers
        call    pciRegRead32
        cmp     edx, esi                ; found device?
        jnz     nextPCIDevice
        clc

PCIScanExit:
	pushf
	mov	eax, edi		; return found PCI address
	and	eax, NOT BIT31		; return only bus/dev/fn #
	popf

	pop	edi
	pop	esi
	pop	edx
	pop	cx
	ret
pciFindDevice endp


End
