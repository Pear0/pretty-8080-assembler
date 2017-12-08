		; 🐟 рисования линии алгоритмом Брезенхема в режиме 256х256
		; Тест и бенчмарк
		; 
		; Для запуска бенчмарка нажать УС / СС / РУСЛАТ
		; (в среднем 246 линий в секунду)
		;
		; Точка входа процедуры рисования: 
		; 	line
		; Входные параметры:
		; 	line_x0, line_y0, line_x1, line_y1
		; Рисование происходит в плоскости 0x8000
		;
		; на время рисовании линий прерывания запрещаются (потом разрешаются)
		;
		; Вячеслав Славинский и Иван Городецкий, 2017
                ;

                .nodump
                .binfile line-ei.rom
                .tape v06c-rom
		.org 100h

		di
start:
		xra	a
		out	10h
		lxi	sp,100h
		mvi	a,0C3h
		sta	0
		lxi	h,Restart
		shld	1

		call	Cls
		mvi	a,0C9h
		sta	38h
		ei
		hlt
		lxi	h, colors+15
colorset:
		mvi	a, 88h
		out	0
		mvi	c, 15
colorset1:	mov	a, c
		out	2
		mov	a, m
		out	0Ch
		dcx	h
		out	0Ch
		out	0Ch
		dcr	c
		out	0Ch
		out	0Ch
		out	0Ch
		jp	colorset1
		mvi	a,255
		out	3


Restart:
		call	Cls

		call SetPixelModeOR
		
;рамка по краю		
		lxi h,00000h
		shld line_x0
		lxi h,00FFh
		shld line_x1
		call line
		lxi h,00000h
		shld line_x0
		lxi h,0FF00h
		shld line_x1
		call line
		
		lxi h,0FFFFh
		shld line_x0
		lxi h,00FFh
		shld line_x1
		call line
		lxi h,0FFFFh
		shld line_x0
		lxi h,0FF00h
		shld line_x1
		call line

;внутреняя рамка
		lxi h,01010h
		shld line_x0
		lxi h,010F0h
		shld line_x1
		call line
		lxi h,01010h
		shld line_x0
		lxi h,0F010h
		shld line_x1
		call line

		lxi h,0F0F0h
		shld line_x0
		lxi h,0F010h
		shld line_x1
		call line
		lxi h,0F0F0h
		shld line_x0
		lxi h,010F0h
		shld line_x1
		call line

;уголки		
		lxi h,00808h
		shld line_x0
		lxi h,00908h
		shld line_x1
		call line
		lxi h,00808h
		shld line_x0
		lxi h,00809h
		shld line_x1
		call line

		lxi h,0F8F8h
		shld line_x0
		lxi h,0F8F7h
		shld line_x1
		call line
		lxi h,0F8F8h
		shld line_x0
		lxi h,0F7F8h
		shld line_x1
		call line
		
		lxi h,008F8h
		shld line_x0
		lxi h,009F8h
		shld line_x1
		call line
		lxi h,008F8h
		shld line_x0
		lxi h,008F7h
		shld line_x1
		call line

		lxi h,0F808h
		shld line_x0
		lxi h,0F809h
		shld line_x1
		call line
		lxi h,0F808h
		shld line_x0
		lxi h,0F708h
		shld line_x1
		call line

;точки
		lxi h,02020h
		shld line_x0
		shld line_x1
		call line

		lxi h,0DF20h
		shld line_x0
		shld line_x1
		call line

		lxi h,020DFh
		shld line_x0
		shld line_x1
		call line

		lxi h,0DFDFh
		shld line_x0
		shld line_x1
		call line
		
		lxi h,circl
circloop:
		push h
		lxi h,8080h
		shld line_x0
		pop h
		mov a,m
		ora a
		jz benchmark
		sta line_x1
		inx h
		mov a,m
		sta line_y1
		inx h
		push h
		call line
		pop h
		jmp circloop

circl:
		.db 228,128
		.db 220,166
		.db 199,199
		.db 166,220
		.db 128,228
		.db 90,220
		.db 57,199
		.db 36,166
		.db 28,128
		.db 36,90
		.db 57,57
		.db 90,36
		.db 128,28
		.db 166,36
		.db 199,57
		.db 220,90
		.db 0

benchmark
		in 1
		rlc
		jnc benchmark_go
		rlc
		jnc benchmark_go
		rlc
		jc benchmark

benchmark_go
		call SetPixelModeXOR

		call rnd16
		shld line_tail
foreva:
		lhld line_tail
		shld line_x0

		call rnd16
		mov d, h
		mov e, l
		inx d
		mov a, d
		ora e
		jz foreva_nomoar
		shld line_x1
		shld line_tail

		call line
		jmp foreva
foreva_nomoar
		jmp Restart

line_tail:	.dw 0

		; аргументы line()
line_x0		.db 100
line_y0		.db 55
line_x1		.db 0
line_y1		.db 50 

		; эти четыре байта должны идти в таком порядке, а то
line_y		.db 0
line_x		.db 0
line_dx 	.db 0
line_dy		.db 0

SetPixelModeOR:
		mvi a,0B1h			;ora c
		sta SetPixelMode_g1
		mvi a,0B6h			;ora m
		sta SetPixelMode_s2
		sta SetPixelMode_g2
		sta SetPixelMode_g3
		mvi a,0F6h			;ori D8
		sta SetPixelMode_s1
		ret

SetPixelModeXOR:
		mvi a,0A9h			;xra c
		sta SetPixelMode_g1
		mvi a,0AEh			;xra m
		sta SetPixelMode_s2
		sta SetPixelMode_g2
		sta SetPixelMode_g3
		mvi a,0EEh			;xri D8
		sta SetPixelMode_s1
		ret

PixelMask:
		.db 10000000b
		.db 01000000b
		.db 00100000b
		.db 00010000b
		.db 00001000b
		.db 00000100b
		.db 00000010b
		.db 00000001b
line:		; вычислить line_dx, line_dy и приращение Y
		; line_dx >= 0, line_dy >= 0, line1_mod_yinc ? [-1,1]
		call line_calc_dx 
		call line_calc_dy

		; проверяем крутизну склона:
		; dy >= 0, dx >= 0
		;  	dy <= dx 	?	пологий
		;	dy > dx 	?	крутой
		lhld line_dx 	        ; l = dx, h = dy
		mov a, l 
		cmp h		        ;если dy<=dx
		jnc  line_gentle	;то склон пологий
		
		; если склон крутой,
		; то меняем местами x0 и y0
		lhld line_x0 		;  l = x, h = y
		mov d, l 	 	;  d = y
		mov e, h 	 	;  e = x
		xchg		 	;  l = y, h = x
		shld line_x0
		; и меняем местами x1 и y1
		lhld line_x1 		;  l = x, h = y
		mov d, l 		;  d = y
		mov e, h 		;  e = x
		xchg			;  l = y, h = x
		shld line_x1
		; крутой склон: переводим стрелку на цикл S
		mvi a,0C3h		; jmp
		.db 21h			; lxi h, - пропускаем переключение на line_gentle
line_gentle:
		; склон пологий: стрелка на цикле G
		mvi a,011h		; lxi d,
		sta line1_switch
		; если теперь получилось так, что x0 > x1,
		; надо изменить направление рисования линии
		lda line_x0
		mov b, a		;b = x0
		lda line_x1		;a = x1
		cmp b
		jnc line_ltr 	        ; x0 <= x1, не надо переворачивать 

		; поменять концы линии местами
		lhld line_x0	        ;l=x0, h=y0
		xchg 			;e=x0, d=y0
		lhld line_x1	        ;l=x1, h=y1
		shld line_x0
		xchg
		shld line_x1

line_ltr:	; пересчитать dx, dy
 		; приращения, 
		; начальные координаты
		; потому что мы поменяли местами X и Y
		call line_calc_dx
		call line_calc_dy

line1:
		; начальное значение D
		; D = 2 * dy - dx
		lda line_dx
		cma
		mov e,a
		mvi d,0FFh
		inx d			; de = -dx

		lhld line_dy
		mvi h,0
		dad h
		shld line1_mod_dy_g+1   ; сохранить 2*dy константой
		shld line1_mod_dy_s+1	; сохранить 2*dy константой

		dad d			; hl = 2 * dy - dx
		push h			; поместить в стек значение D = 2 * dy - dx
		xchg			; hl = -dx
		
		dad h
		xchg			; de = -2*dx
		lhld line1_mod_dy_g+1	; hl = 2*dy
		dad d 			; hl = 2 * dy - 2 * dx
		shld line1_mod_dydx_s+1	; сохранить как конст
		shld line1_mod_dydx_g+1	; сохранить как конст

                ;! в стеке осталось значение D = 2 * dy - dx

		; основной цикл рисования линии
		; цикл раздвоен: одна версия для пологого склона (_g)
		; вторая для крутого склона (_s)
		; переключаются они при оценке крутизны записью 
		; адреса в line1_switch
		; -----------------------------		
		lhld line_x
		mov c,l		;для пологого это x (а для крутого цикла это y)
		lda line_y	;для пологого это y (а для крутого цикла это x)

		; переход внутрь тела цикла
line1_switch	jmp line1_enter_s	; изменяемый код (lxi d если пологий/jmp если крутой)

line1_enter_g
		mov b,h		        ;line_dx
		sta line_yx_g+1
		; подготовить начальное значение регистра c
		mvi a, 111b 		; сначала вычисляем смещение 
		ana c 			; пикселя в PixelMask (с = x)
		adi PixelMask&255
		mov l,a
		mvi a,PixelMask>>8
		aci 0
		mov h,a			; hl - адрес маски в PixelMask
		mvi a,11111000b
		ana c
		rrc
		rrc
		stc
		rar
		sta line_yx_g+2	        ; 0x80 | (x >> 3), l = y

		xra a
		cmp b			; dx=0?
		mov a,m			; маска
		pop d			; de = 2 * dy - dx
		jz setlastpixel_g	; если dx=0, то ставим одну точку
		di
		lxi h,0
		dad sp
		shld restore_sp_g+1
		xchg		        ; hl = 2 * dy - dx
line_yx_g:
		lxi d, 0 	        ; de указывает в экран
		
		jmp line1_loop_g	; если dx<>0, то переход на обычное рисование линии

		;------ пологий цикл (g/gentle) -----
line1_then_g:
line1_mod_dydx_g:		
		lxi sp, 0ffffh 		; изменяемый код: 2*(dy-dx)
		dad sp 			; D = D + 2*(dy-dx)
line1_mod_yinc_g:
		inr e			; изменяемый код: line_y += yinc или line_y -= yinc
		
		mov a,c
		rrc 			; сдвинуть вправо (следующий X)
		jnc $+4 		; если не провернулся через край
		inr d			; line_x += 1

		dcr b			; dx -= 1
		jz setlastpixel_g2
line1_loop_g:	; <--- точка входа в пологий цикл --->
		mov c,a			; сохраняем значение бита
		ldax d
SetPixelMode_g1:
		xra c
		stax d			; записать в память

		; if D > 0
		xra a
		ora h
		jp line1_then_g
line1_else_g: 	; else от if D > 0
line1_mod_dy_g
		lxi sp, 0ffffh 		; изменяемый код (2*dy)
		dad sp			; D = D + 2*dy

		mov a,c
		rrc 			; сдвинуть вправо (следующий X)
		jnc $+4 		; если не провернулся через край
		inr d			; line_x += 1
		
		dcr b			; dx -= 1
		jnz line1_loop_g
		; --- конец тела пологого цикла ---
setlastpixel_g2:
		xchg
SetPixelMode_g2:
		xra m
		mov m,a 		; записать в память
restore_sp_g:
		lxi sp,0
		ei
		ret

setlastpixel_g:
		lhld line_yx_g+1 ; hl указывает в экран
SetPixelMode_g3:
		xra m
		mov m,a 		; записать в память
		ret


line1_enter_s:
		sta set_x+1		; x
		ani 111b 		; вычислить начальное значение адреса колонки ...
		adi PixelMask&255
		mov l,a
		mvi a,PixelMask>>8
		aci 0
		mov h,a			; hl - адрес маски в PixelMask
		mvi a,11111000b
set_x
		ani 0
		rrc
		rrc 
		stc 
		rar 
		mov b,a			; координата x: 0x8000 | (a / 8)

		lda line_x1
		sta last_y_s1+1
		sta last_y_s2+1
		mov a,m 		; начальное значение пикселя
		sta bit_set_s+1
		pop d			; de = 2 * dy - dx

		di
		lxi h,0
		dad sp
		shld restore_sp_s+1
		xchg			; hl = 2 * dy - dx
line1_mod_dydx_s:		
		lxi d, 0ffffh 		; изменяемый код: 2*(dy-dx)
line1_mod_dy_s:
		lxi sp, 0ffffh 		; изменяемый код (2*dy)
		
		jmp line1_loop_s

		;------ крутой цикл (s/steep) -----
line1_then_s:
;line1_mod_dydx_s:		
;		lxi d, 0ffffh 		; изменяемый код: 2*(dy-dx)
		dad d 			; D = D + 2*(dy-dx)
		inr c			; y = y + 1
		lda bit_set_s+1		; one-hot бит пикселя
line1_mod_xinc_s1:
		rrc 			; изменяемый код: xincLo
		sta bit_set_s+1 
		jnc $+4
line1_mod_xinc_s2:
		inr b			; изменяемый код: xincHi
		
last_y_s1:
		mvi a,0
		cmp c
		jz setlastpixel_s

line1_loop_s:	; <--- точка входа в крутой цикл --->
		ldax b
SetPixelMode_s1:
bit_set_s:
		xri 0
		stax b	 		; записать в память результат с измененным пикселем

		; if D > 0
		xra a
		ora h
		jp line1_then_s
line1_else_s: 	; else от if D > 0
;line1_mod_dy_s:
;		lxi d, 0ffffh 		; изменяемый код (2*dy)
;		dad d 			; D = D + 2*dy
		dad sp 			; D = D + 2*dy
		inr c			; y = y + 1
last_y_s2:
		mvi a,0
		cmp c
		jnz line1_loop_s
		; --- конец тела крутого цикла ---
setlastpixel_s:
		lxi h, bit_set_s+1 ; указатель на текущую маску пикселя
		ldax b
SetPixelMode_s2:
		xra m
		stax b			; записать в память результат с измененным пикселем
restore_sp_s:
		lxi sp,0
		ei
		ret
		; --- конец line() ---
		

		; вычисление расстояния по X (dx)
line_calc_dx:
		; проверить, что x0 <= x1
		lda line_x0
		sta line_x
		mov b, a		;b = x0
		lda line_x1
		sub b			;a = x1 - x0
		jnc line_x_positive ;если x0 <= x1, то переход

		;если x0 > x1, то пришли сюда
		cma
		inr a			; -(x1-x0)=x0-x1

line_x_positive:
		sta line_dx		; сохранили dx (он положительный)
		ret

		; вычисление расстояния по Y (dy)
line_calc_dy:
		; если y0 <= y1
		lda line_y0
		sta line_y
		mov b, a		;b = y0
		lda line_y1
		sub b			;a = y1 - y0
		jnc line_y_positive	;если y0 <= y1, то переход

		;если y0 > y1, то пришли сюда
		cma
		inr a			; -(y1-y0)= y0 - y1
		sta line_dy		; сохранили dy (он положительный)
		
		; приращение y = -1
		mvi a, 01Dh 		; dcr e
		sta line1_mod_yinc_g
		mvi a, 005h		; dcr b
		sta line1_mod_xinc_s2
		mvi a, 007h 		; rlc
		sta line1_mod_xinc_s1
		ret

line_y_positive:
		sta line_dy	        ; y1 - y0

		mvi a, 01Ch 		; inr e
		sta line1_mod_yinc_g
		mvi a, 004h		; inr b
		sta line1_mod_xinc_s2
		mvi a, 00Fh 		; rrc
		sta line1_mod_xinc_s1
		ret


Cls:
		lxi	h,08000h
		mvi	e,0
		xra	a
ClrScr:
		mov	m,e
		inx	h
		cmp	h
		jnz	ClrScr
		ret

		; выход:
		; HL - число от 1 до 65535
rnd16:
		lxi h,65535
		dad h
		shld rnd16+1
		rnc
		mvi a,00000001b ;перевернул 80h - 10000000b
		xra l
		mov l,a
		mvi a,01101000b	;перевернул 16h - 00010110b
		xra h
		mov h,a
		shld rnd16+1
		ret

colors:
		.db 00000000b,00001001b,00010010b,00011011b,00100100b,00101101b,00110110b,00111111b
		.db 11111111b,00001001b,00010010b,00011011b,00100100b,00101101b,00110110b,00111111b

		.end
