global start

section		.data

	msg:	db	"Hello %corld", 10
	.len:	equ	$ - msg

	buf:	times 32 db '%'

section		.text

start:

	mov	rax, 'q'
	mov 	rdi, 1
	mov 	rsi, msg
	mov 	rbx, msg.len
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

			cmp rsi, 's'
		;	je .print_s

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
		push rbp
		ret

	.print_c:

		mov r8, rsi
		mov rsi, buf
		
		push	rbp
		mov 	rbp, rsp
		call print_c
		pop	rbp
		cmp rax, 1
		jne .error

		mov rsi, r8
		mov rdx, 1
		inc rsi
		dec rbx

		jmp .contin

;************************bprintf******************************

;---------------------------------;
; 				  ;
; |===========print_c===========| ;
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

	
print_c:

	mov		rax, [rbp + 16]
	mov		[rsi], rax
	mov 		dx, 1
	mov 		rax, 0x2000004
	syscall

	mov 		rax, 1

	ret
