global _bprintf

%macro det_sym 2				; macro determines symb after '%'
	
	cmp byte	[rsi], %1
	je		%2

%endmacro

%macro	print_call 1				; macro calls print_% funcs

	push	rsi
	call	%1
	pop	rsi

	add	rbp, 8

	cmp	rax, 0
	jb	.error

	mov	rdx, 0
	inc	rsi
	dec	rbx

	jmp	.next


%endmacro

%macro reg_to_stack 1

	%1	r9
	%1	r8
	%1	rcx
	%1	rdx
	%1	rsi

%endmacro


section		.data

	buf:			times 32 db '%'

	__UNIX_write_syscall__	equ	0x2000004

section		.text

_bprintf:

	pop	rax

	reg_to_stack push

	mov 	rsi, rdi
	mov 	rdi, 1

	mov	rbp, rsp
	call 	bprint

	reg_to_stack pop

	push	rax
	xor 	rdi, rdi
	mov 	rax, 0x2000001
	syscall


;---------------------------------;
; 				  ;
; |===========bprint============| ;
; | Entry:			| ;
; |	rdi <== output dest	| ;
; |	rsi <== buffer addr	| ;
; | Destr:			| ;
; |	rdx			| ;
; | Ret:			| ;
; | 	num of written symbs	| ;
; |=============================| ;
;				  ;
;---------------------------------;

bprint:

	mov 		rdx, 0				; parameter of 0x2000004 syscall
	.next:

		cmp byte	[rsi + rdx], '%'	; checking for '%' symb
		je 		.printstack

		cmp byte	[rsi + rdx], 0
		je		.ret

	
		add 		rbx, 0xf00		; return value in 'bh'
		inc		rdx			; parameter of 0x2000004 syscall
		jmp 		.next

		.printstack:
			
			push	rdx			; write str until '%'
			mov	rax, __UNIX_write_syscall__
			syscall
			pop	rdx

			inc	rsi			; skip '%'
			add	rsi, rdx		; now just a part of prev str

			det_sym		'c', .print_c

			det_sym		's', .print_s

			det_sym		'd', .print_d

			det_sym		'o', .print_o

			det_sym		'x', .print_x

			det_sym		'b', .print_b

			jmp .error			; if incorrect letter after '%'

	.ret:

		mov	rax, __UNIX_write_syscall__
		syscall

		shr rbx, 8					; get return value from 'bh'

		mov rax, rbx					; bprintf rets written value
		ret

	.error:

		mov rax, 0xffffffff	; ret (-1)

		ret

	.print_c:
		print_call	print_c
		
	.print_s:
		print_call	print_s

	.print_d:
		print_call	print_d

	.print_b:
		print_call	print_b

	.print_o:
		print_call	print_o

	.print_x:
		print_call	print_x

;*************************bprint******************************

;---------------------------------;
; 				  ;
; |===========print_c===========| ;
; | Entry:			| ;
; |	rdi <= output dest	| ;
; | Destr:			| ;
; |	-			| ;
; | Ret:			| ;
; | 	num of written symbs	| ;
; |=============================| ;
;				  ;
;---------------------------------;

	
print_c:
	
	mov		rsi, buf

	mov		rax, [rbp]
	mov byte	[rsi], al

	mov		rax, __UNIX_write_syscall__
	mov		rdx, 1
	syscall

	mov 		rax, 1
	ret

;**********************print_c********************************

;---------------------------------;
; 				  ;
; |===========print_s===========| ;
; | Entry:			| ;
; |	rdi <== output dest	| ;
; | Destr:			| ;
; |	rdx, rsi		| ;
; | Ret:			| ;
; | 	num of written symbs	| ;
; |=============================| ;
;				  ;
;---------------------------------;

print_s:
	
	mov	rdx, 0
	mov	rsi, [rbp]

	.next:

		cmp byte	[rsi + rdx], '%'
		je		.contin

		cmp byte	[rsi + rdx], '\'
		je		.exptn

		inc		rdx
		jmp		.next

	.exptn:

		times 2 inc	rdx
		jmp 		.next

.contin:
		
	mov	rax, __UNIX_write_syscall__
	syscall

	mov	rax, rdx

	ret

;*************************print_s******************************

;---------------------------------;
; 				  ;
; |===========print_b===========| ;
; | Entry:			| ;
; |	rdi <== output dest	| ;
; | Destr:			| ;
; |	rdx, rsi, r9b, r11	| ;
; | Ret:			| ;
; | 	num of written symbs	| ;
; |=============================| ;
;				  ;
;---------------------------------;

print_b:

	mov	rsi, buf

	mov	r10, [rbp]

	mov	r9b, 0x40

	.count:
		
		shl		r10, 1
		dec		r9b
		jc		.setcount
		jmp		.count

	.setcount:

		mov byte	[rsi], 0x31
		inc		rsi

		mov byte	r12b, r9b
		inc		r12b

	.next:

		xor		al, al
		shl		r10, 1
		adc		al, '0'
		mov byte	[rsi], al
		inc		rsi
		dec		r9b
		cmp		r9b, 0
		ja		.next

	mov		rsi, buf
	xor		dx, dx
	mov byte	dl, r12b
	mov		rax, __UNIX_write_syscall__
	push		rdx
	syscall
	pop		rdx

	mov rax, rdx
	ret

;****************************print_b***********************************

;---------------------------------;
; 				  ;
; |===========print_o===========| ;
; | Entry:			| ;
; |	rdi <== output dest	| ;
; | Destr:			| ;
; |	rsi, r12, rdx, r13, r14	| ;
; | Ret:			| ;
; | 	num of written symbs	| ;
; |=============================| ;
;				  ;
;---------------------------------;

print_o:

	mov	rsi, buf
	add	rsi, 0x1e

	mov	r14, [rbp]

	mov	rdx, 0

	.block:

		xor	r12, r12
		xor	r13, r13

		.next:

			xor	rax, rax
			shr	r14, 1
			adc	rax, 0
			push	r12
			call	pow
			pop	r12
			add	r13, rax
			inc	r12
			cmp	r12, 2
			ja	.contin
			jmp	.next
				
	.contin:

		add		r13, '0'
		mov byte	[rsi], r13b
		inc		rdx
		cmp		r14, 0
		je		.ret
		dec		rsi
		jmp		.block

	.ret:

		mov 	rax, __UNIX_write_syscall__
		push	rdx
		syscall
		pop	rdx

		mov	rax, rdx
		ret

;*******************************print_o**********************************

;---------------------------------;
; 				  ;
; |===========print_x===========| ;
; | Entry:			| ;
; |	rdi <== output dest	| ;
; | Destr:			| ;
; |	rsi, r12, rdx, r13, r14	| ;
; | Ret:			| ;
; | 	num of written symbs	| ;
; |=============================| ;
;				  ;
;---------------------------------;

print_x:

	mov	rsi, buf
	add	rsi, 0x1e

	mov	r14, [rbp]

	mov	rdx, 0

	.block:

		xor	r12, r12
		xor	r13, r13

		.next:

			xor	rax, rax
			shr	r14, 1
			adc	rax, 0
			push	r12
			call	pow
			pop	r12
			add	r13, rax
			inc	r12
			cmp	r12, 3
			ja	.contin
			jmp	.next
				
	.contin:

		cmp		r13, 0xa
		jae		.letter
		add		r13, '0'
		jmp		.putc

		.letter:
			add	r13, 'a' - 0xa
		
		.putc:
			mov byte	[rsi], r13b
			inc		rdx
			cmp		r14, 0
			je		.ret
			dec		rsi
			jmp		.block

	.ret:

		mov 	rax, __UNIX_write_syscall__
		push	rdx
		syscall
		pop	rdx

		mov	rax, rdx
		ret

;*******************************print_x**********************************

;---------------------------------;
; 				  ;
; |===========print_d===========| ;
; | Entry:			| ;
; |	rdi <== output dest	| ;
; | Destr:			| ;
; |	rsi, rdx, r9, r10	| ;
; | Ret:			| ;
; | 	num of written symbs	| ;
; |=============================| ;
;				  ;
;---------------------------------;

print_d:

	mov	rsi, buf
	add	rsi, 0x1e

	mov	rax, [rbp]

	xor	r9, r9
	mov	r10, 10

	.next:
		
		xor		rdx, rdx
		div		r10
		add		rdx, '0'
		dec		rsi
		mov byte	[rsi], dl
		inc		r9
		cmp		rax, 0
		ja		.next

	mov	rax, __UNIX_write_syscall__
	mov	rdx, r9
	syscall

	mov	rax, r9
	ret

;***************************print_d*******************************

;---------------------------------;
; 				  ;
; |=============pow=============| ;
; | Entry:			| ;
; |	r12 <== power		| ;
; |	rax <== num		| ;
; | Destr:			| ;
; |	r12			| ;
; | Ret:			| ;
; | 	pow (rax, r12)		| ;
; |=============================| ;
;				  ;
;---------------------------------;

pow:

	.contin:

		cmp	r12, 0
		ja	.next
		jmp	.ret

	.next:
	
		dec	r12
		shl	rax, 1
		jmp	.contin

	.ret:

		ret

;**************************pow**************************
