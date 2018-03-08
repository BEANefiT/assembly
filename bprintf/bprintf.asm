global start

section		.data

	msg:	db "Hello world", 10
	len	equ $ - msg

section		.text

mov rdi, 0x1
mov rsi, msg
mov rbx, len
call bprintf

mov rax, 0x2000001
mov rdi, 0
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

		cmp byte [rsi], '%'	; checking for '%' symb
		jne .printstack

		mov rdx, 0x1		; write str with length = 1 (write symb)
		mov rax, 0x2000004	; 'write' convention for 0x80 interrupt
		syscall
	
		inc rsi			; next symb
		dec rbx
		add rbx, 0x256
		jmp .contin

		.printstack:
			
			inc rsi		; next symb
			dec rbx
			cmp rbx, 0x0
		;	je .error	; if no letter after '%' symb

			cmp byte [rsi], 'c'
		;	je .print_c

			cmp byte [rsi], "s"
		;	je .print_s

			cmp byte [rsi], "d"
		;	je .print_d

			cmp byte [rsi], "o"
		;	je .print_o

			cmp byte [rsi], "x"
		;	je .print_x

			cmp byte [rsi], "b"
		;	je .print_b

			jmp .error	; if incorrect letter after '%'
			

		.contin:
		
			cmp bl, 0x0
			jne .next
	
	shr rbx, 0x8
	mov rax, rbx			; bprintf rets written value
	ret

	.error:

		mov rax, 0xffffffff	; ret (-1)
		ret
		
