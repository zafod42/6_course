  
Data_string db 34 dup("$")
NumberSymbolsAD dw 10

    ;*******************************************************
    ;*  ПРЕОБРАЗОВАНИЕ ЧИСЛА С ПЛАВАЮЩЕЙ ЗАПЯТОЙ В СТРОКУ  *
    ;* Число имеет формат с удвоенной точностью, результат *
    ;* выдается в десятичном коде, в "бытовом" формате с   *
    ;* фиксированным количеством знаков после запятой.     *
    ;* Входные параметры:                                  *
    ;* Data_Double - преобразуемое число;                  *
    ;* NumberSymbolsAD - количество знаков после           *
    ;*                   запятой (0-17).                   *
    ;* Выходные параметры:                                 *
    ;* Data_String - строка-результат.                     *
    ;*******************************************************
    DoubleFloat_to_String proc near
            pusha  
            push    DS
            push    ES
            mov     AX, 0
            mov     DS,AX
            mov     ES,AX
            ; Результат записывать в строку Data_String
            mov     DI,offset Data_String
     
            ; Сдвигаем число влево на NumberSymbolsAD
            ; десятичных разрядов
            fninit                 ;сброс сопроцессора
            fld     [Data_Double] ;загрузить число
            mov     BX,[NumberSymbolsAD]
            cmp     BX,0
            je      @@NoShifts     ;нет цифр после запятой
            jl      @@Error        ;ошибка
            dec     BX
            shl     BX,3           ;умножаем на 8
            add     BX,offset MConst
            fmul    [qword ptr BX] ;умножить на константу
    @@NoShifts:
            ; Извлечь число в коде BCD
            fbstp   [Data_BCD]
    ; Проверить результат на переполнение
            mov     AX,[offset Data_BCD + 8]
            cmp     AX,0FFFFh  ;"десятичное" переполнение?
            je      @@Overflow
    ; Выделить знак числа и записать его в ASCII-коде
	    push	di
	    lea	di, Data_BCD + 8
   	    inc di 
            mov     AL,[di]
	    pop 	di
            and     AL,AL
            jz      @@NoSign
            mov     AL,'-'
            stosb
    @@NoSign:
    ; Распаковать число в код ASCII
            mov     BX,8     ;смещение последней пары цифр
            mov     CX,9     ;счетчик пар цифр
            ; Определить позицию десятичной точки в числе
            mov     DX,18
            sub     DX,[NumberSymbolsAD]
            js      @@Error  ;ошибка, если отрицательная
            jz      @@Error  ;или нулевая позиция
    @@NextPair:
            ; Загрузить очередную пару разрядов
            mov     AL,[BX + offset Data_BCD]
            mov     AH,AL
            ; Выделить, перевести в ASCII и
            ; сохранить старшую тетраду
            shr     AL,4
            add     AL,'0'
            stosb
            dec     DX
            jnz     @@N0
            mov     AL,'.'
            stosb
    @@N0:   ; Выделить, перевести в ASCII и
            ; сохранить младшую тетраду
            mov     AL,AH
            and     AL,0Fh
            add     AL,'0'
            stosb
            dec     DX
            jnz     @@N1
            mov     AL,'.'
            stosb
    @@N1:   dec     BX
            loop    @@NextPair
            mov     AL,0
            stosb
     
    ; Убрать незначащие нули слева
            mov     DI,offset Data_String
            mov     SI,offset Data_String
            ; Пропустить знак числа, если он есть
            cmp     [byte ptr SI],'-'
            jne     @@N2
            inc     SI
            inc     DI
    @@N2:   ; Загрузить в счетчик цикла количество разрядов
            ; числа плюс 1 (байт десятичной точки)
            mov     CX,18+1+1
            ; Пропустить незначащие нули
    @@N3:   cmp     [byte ptr SI],'0'
            jne     @@N4
            cmp     [byte ptr SI+1],'.'
            je      @@N4
            inc     SI
            loop    @@N3
            ; Ошибка - нет значащих цифр
            jmp short @@Error
    ; Скопировать значащую часть числа в начало строки
    @@N4:   rep movsb
            jmp short @@End
     
    ; Ошибка
    @@Error:
            mov     AL,'E'
            stosb
            mov     AL,'R'
            stosb
            mov     AL,'R'
            stosb
            xor     AL,AL
            stosb
            jmp short @@End
    ; Переполнение разрядной сетки
    @@Overflow:
            mov     AL,'#'
            stosb
            xor     AL,AL
            stosb
    ; Конец процедуры
    @@End:  pop     ES
            pop     DS
            popa
            ret
    ENDP
