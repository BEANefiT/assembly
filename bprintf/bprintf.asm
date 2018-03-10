global start

section		.data



	msg:	db	"H%c%so%b %sld%b", 10
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

	;mov	rax, 'l'
	;push	rax
	mov	rax, 0xf
	push	rax
	mov	rax, st
	sub	rax, msg.len
	push	rax
	mov	rax, 0x5
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

		;	cmp rsi, 'o'
		;	je .print_o

		;	cmp rsi, 'x'
		;	je .print_x

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

	mov	r9b, 0x20

	.count:
		
		shl		r11d, 1
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
		shl		r11d, 1
		adc		al, 0x30
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
