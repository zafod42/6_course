	
	pause_string db	"Press any key to continue.$"

	pause macro 
		pusha
		lea 	dx, pause_string
		println
		mov 	ah, 1
		int 	21h
		popa
	endm


	exit macro
		mov ax, 4c00h
		int 21h
	endm


	putchar macro		; puts char from dl
		push ax
		mov 	ah, 2
		int	21h
		pop ax
	endm

	newline macro	; just prints \n
		push ax
		push dx

		mov 	ah, 2
		mov	dl, 13
		int 21h
		mov 	dl, 10
		int 21h

		pop dx
		pop ax
	endm

	print_str_0d proc	;prints str from dx
		push 	di
		push 	dx
		push 	bx
		mov	di, dx	
		dec di
print0dh_loop:	inc di
		mov 	dl, [di]
		putchar
		mov	bl, [di]
		cmp 	bl, 0dh
		jne 	print0dh_loop
		
		pop 	bx
		pop 	dx
		pop 	di
		ret	
	endp
		
	println macro	; prints string from DX and puts new line after it
		print_str
		newline
	endm

	print_str macro		; prints string from DX
		push	ax
		mov 	ah, 9	; 
		int 	21h
		pop 	ax
	endm

	get_str macro		; gets string
		push ax
		mov 	ah, 0ah	; and writes it to buffer located in DS:DX
		int 	21h
		pop ax 	
	endm
	
	gets macro
		get_str
		newline
	endm
	get_clear macro	; unsafe very unsafe!
		add	dx, 2
		call clear_buffer
		sub 	dx, 2
		gets
	endm

