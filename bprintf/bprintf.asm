global start

section		.text




;-------------------------------;
;============bprintf============;
;Entry:
;	rdi <== output dest	
;	rsi <== buffer addr
;	rbx <== str size
;Destr:
;	rdx, 
;
;-------------------------------;

bprintf		proc

	@@next:

		cmp rsi[0], '%'		; checking for '%' symb
		jne @@printstack

		mov rdx, 1		; write str with length = 1 (write symb)
		mov rax, 0x2000004	; 'write' convention for 0x80 interrupt
		int 0x80
	
		inc rsi			; next symb
		dec rbx
		add rbx, 0x256
		jmp @@contin

		@@printstack:
		
		@@contin:
		
			cmp rbl, 0
			jne @@next
	
	shr rbx, 8
	mov rax, rbx			; bprintf rets written value
	ret
