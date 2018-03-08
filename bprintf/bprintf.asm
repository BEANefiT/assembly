global _main

section		.data

	msg:	db "Hello world", 10
	.len:	equ $ - msg

section		.text

_main:

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

		cmp byte [rel + rsi], '%'	; checking for '%' symb
		jne .printstack

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

			cmp byte [rel + rsi], 'c'
		;	je .print_c

			cmp byte [rel + rsi], 's'
		;	je .print_s

			cmp byte [rel + rsi], 'd'
		;	je .print_d

			cmp byte [rel + rsi], 'o'
		;	je .print_o

			cmp byte [rel + rsi], 'x'
		;	je .print_x

			cmp byte [rel + rsi], 'b'
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
		
