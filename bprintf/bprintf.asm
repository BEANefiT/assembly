global start

section		.data



	msg:	db	"Hell%c world", 10
	.len:	equ	$ - msg

	st:	db	"wor%"

	err:	db	"rorerrorerrorerr1oerror", 10

section		.text

start:

	mov 	rdi, 1
	mov 	rsi, msg
	mov 	rbx, msg.len

	;mov	rax, 'l'
	;push	rax
	;mov	rax, st
	;sub	rax, msg.len
	;push	rax
	mov	rax, 'o'
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

		;	cmp rsi, 'o'
		;	je .print_o

		;	cmp rsi, 'x'
		;	je .print_x

		;	cmp rsi, 'b'
		;	je .print_b

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
