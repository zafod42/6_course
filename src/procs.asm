
test_func proc
	push 	bx
	push	cx
	push	ax
	mov	bx, 10
_ya_loop:
	mov	cx, 65535
_test_loop:
	add	ax, ax
	add	ax, ax
	add	ax, ax
	add	ax, ax
	add	ax, ax
	add	ax, ax
	add	ax, ax
	add	ax, ax
	add	ax, ax
	add	ax, ax
	loop 	_test_loop
	dec	bx
	jnz	_ya_loop
	pop 	ax
	pop 	cx
	pop 	bx
	ret
endp

