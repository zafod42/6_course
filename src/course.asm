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
	first_msg db "Calculate time with 0x046C$" 
	second_msg db "Calculate time with increasing rate of irq0$"	
	third_msg db "Calculate time with 0 channel of timer$"

	new_timer_cw db 00110110b
	new_timer_counter dw 0FFFFh



; TODO: value of counter from 0 channel of timer
;	- [x] [0x046c] timer
;	- [x] increasing of timer frequency
;	- [ ] 0 channel of timer withno interrupt
;	- [ ] make program beautiful
	.code
start:	mov 	ax, @data
	mov	ds, ax
	mov	ax, 40h
	mov	es, ax

	push	[es:6ch]
	call 	print_hex
	newline
	call 	test_func
	push	[es:6ch]
	call 	print_hex
	newline
	pop 	ax
	pop	bx
	sub	ax, bx
	push	ax
	call	print_hex
	newline
	add	sp, 2
	xor 	ax, ax	
	
	lea	di, new_timer_cw
	mov	al, [di]
	out	43h, al
	mov	ax, 09b5ch
	out	40h, al
	shr	ax, 8
	out 	40h, al

	push	[es:6ch]
	call 	print_hex
	newline
	call 	test_func
	push	[es:6ch]
	call 	print_hex
	newline
	pop 	ax
	pop	bx
	sub	ax, bx
	push	ax
	call	print_hex
	newline
	add	sp, 2

	pause
	exit

include d:\procs.asm
include d:\ph.asm

end start
