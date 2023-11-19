	.286
	.model tiny
	.stack 100h
	.data
		msg db "Hello, World!", "$"
		spell_error db "Incorrect input!$"
		main_menu_msg db "This is a word game!", 13, 10, "Enter command from list:", 13, 10, "	- exit", 13, 10, "	- game$";, 13, 10,"$"; "	- add word(addw)$"
		initial_msg db "Enter word to play.$"
		your_word_msg db "Your word is: $"
		start_game_msg db "Let's get started!", 13, 10,"Rules:	You need type as many words as possible,", 13, 10,"	but only with letters of your main word!", 13, 10, "	Type ", 3, " to return to main menu", 13, 10, "Good luck!$"
		wellcome db ">>> $"
		no_such_command_err db "Unknown command!$"		
		not_in_dict db "Word is not in dict!$"
		not_implemented_yet db "not implemented.. Yet ;)$"	

		quit_game_msg db "You quited game! Your score: $"
		

		exit_program_msg db "Exiting word game! Bye... ;)$"
		debug_msg db "You typed: $"
	
		max_len		EQU 100 

		game_word	db max_len dup("$")
		game_work	db max_len dup("$")
		;player_word	db max_len dup("$")
		buffer 		db max_len
		buffer_len	db ?
		buffer_str	db max_len + 4 dup("$")
		;debug_buffer	db max_len*3 dup("$")
	
		score	db 0
	
		command_list label byte
		cexit	db "EXIT", 0dh
		cgame	db "GAME", 0dh
		caddw	db "ADDW", 0dh
		
		chword db "cat", 0dh

		dict_len db 10
		end_dict_ptr dw offset w10
		dict_words label byte	
		w1	db "CAT", 0dh
		w2	db "DOG", 0dh
		w3	db "BAT", 0dh
		w4	db "BAD", 0dh
		w5	db "SUN", 0dh
		w6	db "TOP", 0dh
		w7	db "RULE", 0dh
		w8	db "SOUP", 0dh
		w9	db "PLANE", 0dh
		w10	db "LOOK", 0dh
			db 300 dup(0dh)

		dictionary label word
			dw offset w1 
			dw offset w2
			dw offset w3
			dw offset w4
			dw offset w5
			dw offset w6
			dw offset w7
			dw offset w8
			dw offset w9
			dw offset w10
			dw 100 dup(0dh)
include d:\print.asm

strcmp_check	db	"Check$"
equal_msg	db	"in$"
nequal_msg	db	"out$"
st_w	db "LOOK", 0dh
nd_w	db "DOG", 0dh


;TODO: You need to write docs. What if you will forget about something?...

	.code
start:	mov 	ax, @data
	mov 	ds, ax
	mov 	es, ax

main_menu:
	lea 	dx, main_menu_msg
	println
get_main_menu_command:
	lea	dx, wellcome
	print_str
	lea	dx, buffer
	call get_correct_word
	cmp	al, 0
	je 	assert_main_menu_command
	lea	dx, spell_error
	println
	jmp 	get_main_menu_command

assert_main_menu_command:
chexit:	lea	di, buffer_str	
	lea	si, cexit
	call strcmp
	cmp 	al, 0
	jne 	chgame
	lea	dx, exit_program_msg
	println
	pause
	exit
chgame:	lea	si, cgame
	call strcmp	
	cmp	al, 0
	je 	game_start
chaddw:	;lea	si, caddw
	;call strcmp
	;je	add_word_dict
	;lea	dx, no_such_command_err	
	;println
	jmp	get_main_menu_command

add_word_dict:
	lea	dx, not_implemented_yet
	println
	jmp get_main_menu_command

game_start:
	lea	di, score	
	mov	al, [di]
	mov 	al, 0
	mov	[di], al
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
	mov	byte ptr [di], "$"

	lea 	dx, your_word_msg
	print_str
	lea	dx, game_word
	println
	lea	dx, start_game_msg
	println
	jmp 	game_input
game_input_error:
	lea	dx, spell_error
	println

game_loop:
game_input:	
	lea	dx, wellcome
	print_str
	lea 	dx, buffer
	call get_correct_word	; really complicated function
				; TODO: *!really!* need docs for it
	; TODO: rewrite without get correct word
	; it makes thing harder, than it may were

	cmp	al, 0
	je	game_continue	
	cmp 	al, 1	
	je	game_input_error
	lea 	dx, quit_game_msg	
	print_str
	; TODO: print score
	lea	di, score
	mov	dl, [di]
	add 	dl, "0"
	putchar
	newline
	jmp main_menu

game_continue:
	;lea	dx, debug_msg
	;print_str
	;lea	dx, buffer_str
	;println	
	lea 	dx, buffer_str
	call is_in_dict
	cmp 	al, 0
	je	add_game_score
	lea	dx, not_in_dict
	println
	jmp game_loop
add_game_score:
	lea	di, score	
	mov	al, [di]
	inc	al
	mov	[di], al

	jmp game_loop
	
	pause
	exit

;===========================================================
;========-PROCS-============================================
;===========================================================

	is_of_letters proc ; compares word with game_word
		push cx
		push si
		push di
		push dx
		mov 	cx, 99 
		lea	si, game_word
		lea	di, game_work
		rep movsb		
		
		mov 	si, di
		dec dx
letters_loop:	inc dx
		mov	si, di
		
	

		pop dx
		pop di
		pop si
		pop cx
		ret
	endp

	is_in_dict proc ; checks if word in dict
			; word in ds:dx
			; al = 1 => not in dict
			; al = 0 => in dict
		push di
		push dx
		push cx
		push si
		push bx
		lea 	bx, dictionary
		lea 	di, dict_len
		xor 	cx, cx
		mov	cl, [di]
		mov	di, dx
check_dict_loop:mov	si, [bx]
		call strcmp
		cmp 	al, 0
		je	chd_exit
		add 	bx, 2
		loop check_dict_loop
chd_exit:	;mov	dl, "A"
		;putchar
		pop bx	
		pop si
		pop cx
		pop dx
		pop di
		ret
	endp
	strcmp	proc	; compares strings from DS:SI and DS:DI 
			; returnes 0 in al if equal	
			; and non-0 in al if not equal
	; мб использовать строковые команды?
		push bx
		push si
		push di
		mov 	al, 0
		dec si
		dec di
strcmp_loop:	inc si
		inc di
		mov 	bh, [si]
		mov 	dl, bh
		;putchar
		mov 	bl, [di]
		mov 	dl, bl
		;putchar
		;newline
		;pause	
		mov 	dl, bh
		mov 	dl, bl
		cmp 	bl, 0dh
		je 	pre_exit_cmp
		cmp	bh, bl
		je	strcmp_loop
		mov	al, 1

pre_exit_cmp:	cmp 	bh, bl
		je	strcmp_exit
		mov 	al, 1
strcmp_exit:	pop di
		pop si
		pop bx
		ret
	endp


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
		push cx
		mov 	bx, dx
correct_input:	mov	bx, dx
		mov 	dx, bx
		get_clear
		mov	di, dx		; проверка на символ выхода
		add 	di, 2
		mov 	cl, [di]
		cmp 	cl, 3
		jne 	continue
		mov	al, 2
		jmp 	correct_good
continue:	lea 	dx, buffer_str	
		call to_upper
		call check_spell	
		cmp 	al, 0
		je	correct_good
correct_good:	pop cx
		pop di
		pop dx
		pop bx
		ret
	endp

	end start 


