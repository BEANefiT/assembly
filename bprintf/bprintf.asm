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

	add	rbx, rax
	xor	rdx, rdx
	inc	rsi

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

	buf:			times 32 db '%'		; buffer

	__UNIX_write_syscall__	equ	0x2000004	; 0x04 syscall

section		.text

_bprintf:

	pop	rbx					; ret addr of main()

	reg_to_stack push				; all params -> stack

	push	rbx					; push ret of main()

	mov 	rsi, rdi				; string ptr from main.c
	mov 	rdi, 1					; stdout
	
	mov	rbp, rsp
	add	rbp, 8
	call 	bprint

	pop	rbx					; clean stack, care about ret addr
	reg_to_stack pop
	push	rbx

	ret


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

	xor 		rdx, rdx			; parameter of 0x2000004 syscall
	xor		rbx, rbx			; ret value
	.next:

		cmp byte	[rsi + rdx], '%'	; checking for '%' symb
		je 		.printstack

		cmp byte	[rsi + rdx], 0		; end of str
		je		.ret

	
		add 		rbx, 1			; return value in 'bh'
		inc		rdx			; parameter of 0x2000004 syscall
		jmp 		.next

		.printstack:
			
			cmp	rdx, 0			; don't call syscall with !rdx
			je 	.empty

			push	rdx			; write str until '%'
			mov	rax, __UNIX_write_syscall__
			syscall
			pop	rdx
		.empty:
			inc	rsi			; skip '%'
			add	rsi, rdx		; now just a part of prev str
			xor	rdx, rdx

			det_sym		'%', .printstack ;%% -> %

			det_sym		'c', .print_c

			det_sym		's', .print_s

			det_sym		'd', .print_d

			det_sym		'o', .print_o

			det_sym		'x', .print_x

			det_sym		'b', .print_b

			jmp .error			; if incorrect letter after '%'

	.ret:

		mov	rax, __UNIX_write_syscall__	; write end of line
		syscall

		mov rax, rbx				; bprintf rets written value
		ret

	.error:

		mov rax, 0xffffffff			; ret (-1)

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
; |	rsi, rdx		| ;
; | Ret:			| ;
; | 	num of written symbs	| ;
; |=============================| ;
;				  ;
;---------------------------------;

	
print_c:
	
	mov		rsi, buf			; get buf addr

	mov		rax, [rbp]			; get symb from stack
	mov byte	[rsi], al			; put symb to buf

	mov		rax, __UNIX_write_syscall__
	mov		rdx, 1
	syscall

	ret

;**********************print_c********************************

;---------------------------------;
; 				  ;
; |===========print_s===========| ;
; | Entry:			| ;
; |	rdi <== output dest	| ;
; | Destr:			| ;
; |	rdx, rsi, rbx		| ;
; | Ret:			| ;
; | 	num of written symbs	| ;
; |=============================| ;
;				  ;
;---------------------------------;

print_s:
	
	xor	rdx, rdx				; counter of str chars
	mov	rsi, [rbp]				; get str addr

	.next:

		cmp byte	[rsi + rdx], 0		; look for end of str
		je		.contin

		inc		rdx
		jmp		.next

.contin:
		
	mov	rax, __UNIX_write_syscall__
	syscall

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

	mov	rsi, buf				; get buf addr

	mov	r10, [rbp]				; get number

	mov	r9b, 0x40				; max length of bin 64 bit number

	.count:
		
		shl		r10, 1			; delete first zeroes
		dec		r9b
		jc		.setcount
		jmp		.count

	.setcount:

		mov byte	[rsi], '1'		; don't forget first deleted '1'
		inc		rsi

		mov byte	r12b, r9b		; save number length
		inc		r12b

	.next:

		xor		al, al
		shl		r10, 1			; get digit
		adc		al, '0'
		mov byte	[rsi], al		; put digit in buf
		inc		rsi
		dec		r9b
		cmp		r9b, 0			; end of number
		ja		.next

	mov		rsi, buf			; put buf addr
	xor		rdx, rdx
	mov byte	dl, r12b			; length of num
	mov		rax, __UNIX_write_syscall__
	syscall

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

	mov	rsi, buf			; put buf addr
	add	rsi, 0x1e

	mov	r14, [rbp]			; get num

	xor	rdx, rdx			; length of num

	.block:

		xor	r12, r12		; current power of block
		xor	r13, r13		; current value of block

		.next:

			xor	rax, rax	; current digit value
			shr	r14, 1
			adc	rax, 0
			push	r12
			call	pow		; rax^r12
			pop	r12
			add	r13, rax
			inc	r12
			cmp	r12, 2		; end of block
			ja	.contin
			jmp	.next
				
	.contin:

		add		r13, '0'	; value of block
		mov byte	[rsi], r13b
		inc		rdx
		cmp		r14, 0		; end of num
		je		.ret
		dec		rsi
		jmp		.block

	.ret:

		mov 	rax, __UNIX_write_syscall__
		syscall

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

	mov	rsi, buf			; put buf addr
	add	rsi, 0x1e			; leave space in the head of buff

	mov	r14, [rbp]			; get num

	xor	rdx, rdx

	.block:

		xor	r12, r12		; current power of block
		xor	r13, r13		; current value of block

		.next:

			xor	rax, rax	; current value of digit
			shr	r14, 1
			adc	rax, 0
			push	r12
			call	pow		; rax^r12
			pop	r12
			add	r13, rax
			inc	r12
			cmp	r12, 3		; end of block
			ja	.contin
			jmp	.next
				
	.contin:

		cmp		r13, 0xa	; 'a' != a + '0'
		jae		.letter
		add		r13, '0'
		jmp		.putc

		.letter:
			add	r13, 'a' - 0xa
		
		.putc:
			mov byte	[rsi], r13b ; put %x digit to buff
			inc		rdx
			cmp		r14, 0
			je		.ret
			dec		rsi
			jmp		.block

	.ret:

		mov 	rax, __UNIX_write_syscall__
		syscall

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

	mov	rsi, buf			; put buf addr
	add	rsi, 0x1e			; leave space in the head of buf

	mov	rax, [rbp]			; get num

	xor	r9, r9				; length of %d num
	mov	r10, 10				; diviver))

	.next:
		
		xor		rdx, rdx	; rdx:rax/r10
		div		r10
		add		rdx, '0'	; rdx - reminder after div
		dec		rsi
		mov byte	[rsi], dl	; put %d digit into buf
		inc		r9
		cmp		rax, 0		; end of num
		ja		.next

	mov	rax, __UNIX_write_syscall__
	mov	rdx, r9
	syscall

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

pow:					; mov cx, r12 -->  rep shl rax, 1

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
