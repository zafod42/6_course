	.286
	.model tiny
	.stack 100h
	.data
		msg db "Hello, World!", "$"
		spell_error db "Incorrect input!$"
		initial_msg db "This is a word game! Enter word to play.$"
		your_word_msg db "Your word is: $"
		start_game_msg db "Let's get started!", 13, 10,"Rules:	You need type as many words as possible,", 13, 10,"	but only with letters of your main word!", 13, 10, "Good luck!$"
		wellcome db ">>> $"

		quit_game_msg db "You quited game! Your score: $"
		
		debug_msg db "You typed: $"
	
		max_len		EQU 100 

		game_word	db max_len dup("$")
		;player_word	db max_len dup("$")
		buffer 		db max_len
		buffer_len	db ?
		buffer_str	db max_len + 4 dup("$")
		;debug_buffer	db max_len*3 dup("$")
		
		dict_len db 10
		dict_words label byte	
			db "word$"
			db "summary$"
			db "summ$"
			db "loop$"
			db "sun$"
			db "reallity$" 
			db "summarise$"
			db "course$"
			db "credit$"
			db "sleep$"
			db 300 dup(?)

		dictionary label word
			dw offset dict_words
			dw offset dict_words + 1
			dw offset dict_words + 2
			dw offset dict_words + 3
			dw offset dict_words + 4
			dw offset dict_words + 5
			dw offset dict_words + 6
			dw offset dict_words + 7
			dw offset dict_words + 8
			dw offset dict_words + 9
			dw 100 dup(?)
include d:\print.asm




;TODO: You need to write docs. What if you will forget about something?...

	.code
start:	mov 	ax, @data
	mov 	ds, ax
	mov 	es, ax

main_menu:

game_start:
	lea	dx, initial_msg
	println

game_initial_input:
	lea 	dx, wellcome
	print_str
	lea 	dx, buffer
	get_clear
	lea	dx, buffer_str
	call to_upper
	call check_spell	
	cmp 	al, 0
	je	game_correct_good
	lea	dx, spell_error
	println
	jmp 	game_initial_input
game_correct_good:
	lea	di, buffer_len
	mov 	cl, [di]
	lea	si, buffer_str
	lea	di, game_word
	rep movsb	
	mov	[di], "$"

	lea 	dx, your_word_msg
	print_str
	lea	dx, game_word
	println
	lea	dx, start_game_msg
	println
game_loop:
game_input:	
	lea 	dx, buffer
	call get_correct_word	; really complicated function
				; TODO: *!really!* need docs for it
	; TODO: rewrite without get correct word
	; it makes thing harder, than it may were

	cmp	al, 0
	je	game_continue	
	lea 	dx, quit_game_msg	
	print_str
	; TODO: print score
	newline
	jmp main_menu

game_continue:
	lea	dx, debug_msg
	print_str
	lea	dx, buffer_str
	println	
	jmp game_loop


	pause
	exit

;===========================================================
;========-PROCS-============================================
;===========================================================

	to_upper proc ; converts buffer in DX to upper_case
		push di
		push dx
		push bx
		mov 	di, dx
		dec 	di
to_upper_main:	inc 	di
		mov 	bl, [di]
		cmp	bl, "$"
		je	exit_to_upper
		cmp	bl, "Z"
		jle	to_upper_main
		sub	bl, 20h
		mov	[di], bl
		jmp 	to_upper_main			
exit_to_upper:	pop bx
		pop dx
		pop di		
		ret
	endp

	clear_buffer proc ; checks vudder at DS:DX
		push dx
		push di
		push bx
		mov 	di, dx
		mov 	cx, max_len
		mov 	bl, "$"
clear_buffer_l: mov 	[di], bl
		inc 	di	
		loop 	clear_buffer_l
exit_clear_buff:pop bx
		pop di
		pop dx	
		ret
	endp
	check_spell proc ; checks string at DS:DX and leaves answer in al
		push cx
		push di
		mov 	al, 0
		lea 	di, buffer_len
		mov 	cl, [di]
		mov 	di, dx
		dec 	di
my_loop:	inc 	di
		mov 	dl, [di] 
		cmp 	dl, "A"
		jl	set_false
		cmp	dl, "Z"
		jg	set_false
		loop my_loop
		jmp 	exit_check_sp
set_false:	mov 	al, 1
		jmp 	exit_check_sp
exit_check_sp:	pop di
		pop cx	
		ret
	endp

	get_correct_word proc	;rewrite without it
				; срочно!!
			; Чтобы ты помнил: эта фигня полностью контрлит
			; ввод всего! Поэтому перепиши без неё
			; либо перепиши вход	
		push bx
		push dx	
		push di
		mov 	bx, dx
correct_input:	mov	bx, dx
		lea	dx, wellcome
		print_str
		mov 	dx, bx
		get_clear
		mov	di, dx
		add 	di, 2
		mov 	cl, [di]
		cmp 	cl, 3
		jne 	continue
		mov	al, 1
		jmp 	correct_good
continue:	lea 	dx, buffer_str
		call to_upper
		call check_spell	
		cmp 	al, 0
		je	correct_good
		lea	dx, spell_error
		println
		mov	dx, bx
		jmp 	correct_input	
correct_good:	pop di
		pop dx
		pop bx
		ret
	endp

	end start 


