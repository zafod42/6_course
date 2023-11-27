	.286
	.model tiny
	.stack 100h
	.data
	
;TODO: You need to write docs. What if you will forget about something?...

include d:\print.asm
	info 	db "By default, timer counts with 18hz", 13, 10
		db "	it is about 0.06 seconds", 13, 10
		db "We can increase rate of timer with ...(write)", 13, 10
 		db "$"
	first_msg db "Calculate time with [0x046C]$" 
	f_mem_val db "	(1) At [0x46C] = $"
	s_mem_val db "	(2) At [0x46C] = $"
	delta	   db "	(2) - (1) = $"
	f_count_val db "	(3) Count value from 40h = $"
	s_count_val db "	(4) Count value from 40h = $"
	count_delta db "	(3) - (4) = $"
	second_msg db "Calculate time with increasing rate of irq0 up to 60Hz$"	
	third_msg db "Calculate time with 0 channel of timer$"
	values_msg db "Values of:$"
	f_val	db "	[0x46C] = $"
	s_val	db "	[0x46D]	= $"
	t_val	db "	[0x46E] = $"
	fo_val	db "	[0x46F] = $"
	new_timer_cw db 00110110b
	new_timer_counter dw 0FFFFh


set_timer macro counter
	push	di
	push	ax
	lea	di, new_timer_cw
	mov	al, [di]
	out	43h, al
	mov	ax, counter
	out	40h, al
	shr	ax, 8
	out 	40h, al
	pop	ax
	pop 	di
endm

get_counter macro	; time located in ax
	mov	al, 0
	out	43h, al
	in	al, 40h
	mov	ah, al
	in	al, 40h
	xchg	ah, al
endm

perform_test macro message 
	lea	dx, message
	println 
	lea	dx, f_mem_val
	print_str
	push	[es:6ch]
	call 	print_hex
	newline
	lea 	dx, s_mem_val
	print_str
	call 	test_func
	push	[es:6ch]
	call 	print_hex
	newline
	lea	dx, delta
	print_str
	pop 	ax
	pop	bx
	sub	ax, bx
	push	ax
	call	print_hex
	newline
	newline
	add	sp, 2

endm

;	- [x] [0x046c] timer
;	- [x] increasing of timer frequency
;	- [x] 0 channel of timer withno interrupt
;	- [x] make program beautiful
; EVERYTHING IS MADE NOW YAWHOOOOOO
	.code
start:	mov 	ax, @data
	mov	ds, ax
	mov	ax, 40h
	mov	es, ax

	lea	dx, info
	println
	
	perform_test first_msg

	set_timer 9b6ch	
	perform_test second_msg	

	set_timer 0ffffh	
	
	lea	dx, third_msg
	println
	push	[es:6ch]
	lea 	dx, f_mem_val
	print_str	
	call 	print_hex
	newline
	get_counter
	push	ax
	lea	dx, f_count_val
	print_str
	call	print_hex
	newline

	call 	test_func

	get_counter
	mov	si, ax
	pop 	bx
	sub	bx, ax
	mov	di, bx
	push 	dx
	lea 	dx, s_mem_val
	print_str	
	pop 	dx
	push 	[es:6ch]
	call 	print_hex
	newline
	push	dx
	lea	dx, s_count_val
	print_str
	pop 	dx
	push	si	
	call 	print_hex
	newline
	add 	sp, 2

	pop	ax
	pop	bx
	sub	ax, bx
	lea	dx, delta
	print_str
	push	ax
	call 	print_hex
	push	di
	newline
	lea	dx, count_delta
	print_str
	call 	print_hex
	newline
	add 	sp, 4

	newline
	lea	dx, values_msg
	println
	lea	dx, f_val
	print_str
	push 	[es:6ch]
	call 	print_hex
	newline
	lea	dx, s_val
	print_str
	push	[es:6dh]
	call	print_hex
	newline
	lea	dx, t_val	
	print_str
	push 	[es:6eh]
	call 	print_hex
	newline
	lea	dx, fo_val	
	print_str
	push	[es:6fh]
	call	print_hex
	newline
	add	sp, 8
	pause
	exit

include d:\procs.asm
include d:\ph.asm

end start
