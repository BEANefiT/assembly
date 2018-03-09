global start

section		.data

	msg:	db "Hello world", 10
	.len:	equ $ - msg

section		.text

start:

	mov rdi, 1
	mov rsi, msg
	mov rbx, msg.len
	call bprintf

	mov rax, 0x2000001
	xor rdi, rdi
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

		cmp rsi, '%'	; checking for '%' symb
		je .printstack

		mov rdx, 1		; write str with length = 1 (write symb)
		mov rax, 0x2000004	; 'write' convention for syscallt
		syscall
	
		inc rsi			; next symb
		dec rbx
		add rbx, 0x256
		jmp .contin

		.printstack:
			
			inc rsi		; next symb
			dec rbx
			cmp rbx, 0
		;	je .error	; if no letter after '%' symb

			cmp byte [rsi], 'c'
		;	je .print_c

			cmp byte [rsi], 's'
		;	je .print_s

			cmp byte [rsi], 'd'
		;	je .print_d

			cmp byte [rsi], 'o'
		;	je .print_o

			cmp byte [rsi], 'x'
		;	je .print_x

			cmp byte [rsi], 'b'
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
		
