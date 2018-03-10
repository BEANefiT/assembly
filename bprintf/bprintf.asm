global start

section		.data



	msg:	db	"Hello %sld", 10
	.len:	equ	$ - msg

	st:	db	"wor%"

	buf	times 32 db '%'

section		.text

start:

	mov 	rdi, 1
	mov 	rsi, msg
	mov 	rbx, msg.len

	mov	rax, st
	sub	rax, msg.len
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

	.next:

		cmp byte	[rsi], '%'	; checking for '%' symb
		je 		.printstack

		mov 		rdx, 1		; write str with length = 1 (write symb)
		mov 		rax, 0x2000004	; 'write' convention for syscallt
		syscall
	
		inc 		rsi			; next symb
		dec 		rbx
		add 		rbx, 0xf00
		jmp 		.contin

		.printstack:
			
			inc 	rsi		; next symb
			dec 	rbx
			cmp 	bl, 0
			je 	.error	; if no letter after '%' symb

			cmp byte	[rsi], 'c'
			je		.print_c

			cmp byte	[rsi], 's'
			je 		.print_s

			cmp rsi, 'd'
		;	je .print_d

			cmp rsi, 'o'
		;	je .print_o

			cmp rsi, 'x'
		;	je .print_x

			cmp rsi, 'b'
		;	je .print_b

			jmp .error	; if incorrect letter after '%'
			

		.contin:
		
			cmp bl, 0
			jne .next
	
	shr rbx, 8
	mov rax, rbx			; bprintf rets written value
	ret

	.error:

		mov rax, 0xffffffff	; ret (-1)
		ret

	.print_c:

		push	rsi
		call	print_c
		pop	rsi

		add	rbp, 8

		cmp	rax, 1
		jne	.error

		mov 	rdx, 1
		inc 	rsi
		dec 	rbx

		jmp 	.contin

	.print_s:
		
		push	rsi
		call	print_s
		pop	rsi

		add	rbp, 8

		cmp	rax, 0
		jb	.error

		mov	rdx, 1
		inc	rsi
		dec	rbx

		jmp	.contin

;************************bprintf******************************

;---------------------------------;
; 				  ;
; |===========print_c===========| ;
; | Entry:			| ;
; |	rdi <== output dest	| ;
; | Destr:			| ;
; |	rdx, rsi		| ;
; | Ret:			| ;
; | 	num of written symbs	| ;
; |=============================| ;
;				  ;
;---------------------------------;

	
print_c:

	mov 		rsi, buf
	
	mov		rax, [rbp]
	mov		[rsi], rax
	mov 		rdx, 1
	mov 		rax, 0x2000004
	syscall
	mov byte	[rsi], '%'

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
