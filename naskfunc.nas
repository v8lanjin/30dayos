; naskfunc
; TAB=4

[FORMAT "WCOFF"]	; 制作目标文件的模式
[INSTRSET "i486p"]	; 
[BITS 32]			; 32bit 

; the object file info
[FILE "naskfunc.nas"]	; source file's name
		
		GLOBAL		_io_hlt, _write_mem8	; function name
		GLOBAL		_io_cli, _io_sti, _io_stihlt
		GLOBAL		_io_in8,  _io_in16,  _io_in32
		GLOBAL		_io_out8, _io_out16, _io_out32
		GLOBAL		_io_load_eflags, _io_store_eflags
		GLOBAL		_load_gdtr, _load_idtr
		GLOBAL		_load_cr0, _store_cr0
		GLOBAL 		_asm_inthandler21, _asm_inthandler27, _asm_inthandler2c
		GLOBAL		_memtest_sub_nas
		EXTERN 		_inthandler21, _inthandler27, _inthandler2c
[SECTION .text]

_io_hlt:		; void io_hlt(void);
		HLT
		RET

_write_mem8:	; void write_mem8(int addr, int data);
		MOV		ECX, [ESP + 4]
		MOV		AL, [ESP + 8]
		MOV		[ECX], AL
		RET

_io_cli:		;void io_cli(void);
		CLI
		RET
_io_sti:		;void io_sti(void);
		STI 
		RET

_io_stihlt:		;void io_stihlt(void)
		STI
		HLT
		RET

_io_in8:		;int io_in8(int port);
		MOV		EDX, [ESP + 4]
		MOV		EAX, 0
		IN 		AL, DX
		RET
_io_in16:
		MOV		EDX, [ESP + 4]
		MOV		EAX, 0
		IN 		AX, DX
		RET

_io_in32:
		MOV		EDX, [ESP + 4]
		MOV 	EAX, 0
		IN 		EAX, DX
		RET

_io_out8:
		MOV		EDX, [ESP + 4]
		MOV		EAX, [ESP + 8]
		OUT 	DX, AL
		RET
_io_out16:
		MOV		EDX, [ESP + 4]
		MOV		EAX, [ESP + 8]
		OUT 	DX, AX
		RET
_io_out32:
		MOV		EDX, [ESP + 4]
		MOV		EAX, [ESP + 8]
		OUT 	DX, EAX
		RET

_io_load_eflags:		;int io_load_eflags(void)
		PUSHFD
		POP		EAX
		RET
		
_io_store_eflags:		;void io_store_eflags(int eflags)
		MOV		EAX, [ESP + 4]
		PUSH 	EAX
		POPFD
		RET

_load_gdtr:		; void load_gdtr(int limit, int addr);
		MOV		AX,[ESP+4]		; limit
		MOV		[ESP+6],AX
		LGDT	[ESP+6]
		RET

_load_idtr:		; void load_idtr(int limit, int addr);
		MOV		AX,[ESP+4]		; limit
		MOV		[ESP+6],AX
		LIDT	[ESP+6]
		RET

_load_cr0:		; int load_cr0();
		MOV		EAX, CR0
		RET
_store_cr0:		; void store_cr0(int cr0);
		MOV		EAX, [ESP+4]
		MOV 	CR0, EAX
		RET


_asm_inthandler21:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler21
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD

_asm_inthandler27:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler27
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD

_asm_inthandler2c:
		PUSH	ES
		PUSH	DS
		PUSHAD
		MOV		EAX,ESP
		PUSH	EAX
		MOV		AX,SS
		MOV		DS,AX
		MOV		ES,AX
		CALL	_inthandler2c
		POP		EAX
		POPAD
		POP		DS
		POP		ES
		IRETD 
		
_memtest_sub_nas: 	;unsigned int memtest_sub(uint start, uint end);
		push edi
		push esi
		push ebx
		mov esi, 0xaa55aa55
		mov edi, 0x55aa55aa		
		MOV		EAX, [ESP+ 12 + 4] ; get start
mts_loop:
		mov ebx, eax
		add ebx, 0xffc
		mov edx, [ebx]
		mov [ebx], esi
		xor dword [ebx], 0xffffffff
		cmp [ebx], edi
		jne mts_fin
		xor dword [ebx], 0xffffffff
		cmp [ebx], esi
		jne mts_fin
		mov [ebx], edx
		add eax, 0x1000
		cmp eax, [esp+12+8]
		
		jbe mts_loop
		pop ebx
		pop esi
		pop edi
		ret
mts_fin:
		mov [ebx], edx
		pop ebx
		pop esi
		pop edi
		ret
		
		
		