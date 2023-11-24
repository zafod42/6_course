; print_hex - prints one word as hex number

hex_string label byte
hex_buffer db "0000"
hex_end	   db "h$", "$", "$"

print_hex proc
	push	bp
	mov	bp, sp
	sub	sp, 6; two bytes in local stack
	mov	ax, [bp + 4]
	push 	di
	lea	di, hex_buffer
	mov	cx, 4
_convert_hex_loop:
	mov	bx, ax
	and	bx, 0f000h
	shr 	bh, 4
	cmp 	bh, 9
	jbe	_print_hex_write
	add	bh, 7
_print_hex_write:
	add 	bh, "0"
	mov	[di], bh 
	shl	ax, 4	
	inc 	di
	dec 	cx
	mov 	bh, [di]
	cmp	cx, 0	
	je	_print_hex_main
	jmp	_convert_hex_loop	
_print_hex_main:
	push 	dx
	lea 	dx, hex_buffer	
	print_str
	pop 	dx
_print_hex_end:
	pop 	di
	mov	sp, bp
	pop 	bp
	ret
endp

