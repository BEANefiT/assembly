global start

section		.data



	msg:	db	"H%c%so%x %sld%b", 10
	.len:	equ	$ - msg

	st:	db	"wor%"

	sw:	db	"ll%"

	err:	db	"rorerrorerrorerr1oerror", 10

	buf:	times 32 db '%'

section		.text

start:

	mov 	rdi, 1
	mov 	rsi, msg
	mov 	rbx, msg.len

	mov	rax, 0xfffffffffffffffe
	push	rax
	mov	rax, st
	sub	rax, msg.len
	push	rax
	mov	rax, 0xcef
	push	rax
	mov	rax, sw
	sub	rax, msg.len
	sub	rax, 4
	push	rax
	mov	rax, 'e'
	push	rax

	mov	rbp, rsp
	call 	bprintf
	mov 	rax, 0x2000001
	xor 	rdi, rdi
	syscall


;---------------------------------;
; 				  ;
; |===========bprintf===========| ;
; | Entry:			| ;
; |	rdi <== output dest	| ;
; |	rsi <== buffer addr	| ;
; |	rbx <== str size	| ;
; | Destr:			| ;
; |	rdx			| ;
; | Ret:			| ;
; | 	num of written symbs	| ;
; |=============================| ;
;				  ;
;---------------------------------;

bprintf:

	mov 		rdx, 0
	.next:

		cmp byte	[rsi + rdx], '%'	; checking for '%' symb
		je 		.printstack

	
		dec 		rbx
		add 		rbx, 0xf00
		inc		rdx
		jmp 		.contin

		.printstack:
			
			mov	rax, 0x2000004
			push	rdx
			syscall
			pop	rdx

			inc	rsi
			add	rsi, rdx
			dec 	rbx
			cmp 	bl, 0
			je 	.error	; if no letter after '%' symb

			cmp byte	[rsi], 'c'
			je		.print_c

			cmp byte	[rsi], 's'
			je 		.print_s

		;	cmp rsi, 'd'
		;	je .print_d

			cmp byte	[rsi], 'o'
			je		.print_o

			cmp byte	[rsi], 'x'
			je		.print_x

			cmp byte	[rsi], 'b'
			je		.print_b

			jmp .error	; if incorrect letter after '%'
			

		.contin:
		
			cmp bl, 0
			jne .next
	
	shr rbx, 8

	mov rax, 0x2000004
	syscall 

	mov rax, rbx			; bprintf rets written value
	ret

	.error:

		mov rax, 0xffffffff	; ret (-1)

		mov	rax, 0x2000004
		mov	rdx, 6
		mov	rsi, err
		syscall

		ret

	.print_c:

		call	print_c

		add	rbp, 8

		cmp	rax, 1
		jne	.error

		mov	rdx, 0
		jmp 	.contin

	.print_s:
		
		push	rsi
		call	print_s
		pop	rsi

		add	rbp, 8

		cmp	rax, 0
		jb	.error

		mov	rdx, 0
		inc	rsi
		dec	rbx

		jmp	.contin

	.print_b:

		push	rsi
		push	r9
		push	r11
		call	print_b
		pop	r11
		pop	r9
		pop	rsi

		add	rbp, 8

		cmp	rax, 0
		jb	.error

		mov	rdx, 0
		inc	rsi
		dec	rbx

		jmp	.contin

	.print_o:

		push	rsi
		push	r12
		push	r13
		push	r14
		call	print_o
		pop	r14
		pop	r13
		pop	r12
		pop	rsi

		add	rbp, 8

		cmp	rax, 0
		jb	.error

		mov	rdx, 0
		inc	rsi
		dec	rbx

		jmp	.contin

	.print_x:

		push	rsi
		push	r12
		push	r13
		push	r14
		call	print_x
		pop	r14
		pop	r13
		pop	r12
		pop	rsi

		add	rbp, 8

		cmp	rax, 0
		jb	.error

		mov	rdx, 0
		inc	rsi
		dec	rbx

		jmp	.contin

;************************bprintf******************************

;---------------------------------;
; 				  ;
; |===========print_c===========| ;
; | Entry:			| ;
; |	rsi <= 'c' location	| ;
; | Destr:			| ;
; |	-			| ;
; | Ret:			| ;
; | 	num of written symbs	| ;
; |=============================| ;
;				  ;
;---------------------------------;

	
print_c:

	mov		rax, [rbp]
	mov byte	[rsi], al

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
		
	mov	rax, 0x2000004
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
	sub	rsi, msg.len
	sub	rsi, 0x1f

	mov	r11, [rbp]

	mov	r9b, 0x40

	.count:
		
		shl		r11, 1
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
		shl		r11, 1
		adc		al, '0'
		mov byte	[rsi], al
		inc		rsi
		dec		r9b
		cmp		r9b, 0
		ja		.next

	mov		rsi, buf
	sub		rsi, 0x1f
	sub		rsi, msg.len
	xor		dx, dx
	mov byte	dl, r12b
	mov		rax, 0x2000004
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
	sub	rsi, msg.len
	dec	rsi

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

		mov 	rax, 0x2000004
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
	sub	rsi, msg.len
	dec	rsi

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

		mov 	rax, 0x2000004
		push	rdx
		syscall
		pop	rdx

		mov	rax, rdx
		ret

;*******************************print_x**********************************

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
