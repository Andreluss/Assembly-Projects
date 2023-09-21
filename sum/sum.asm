; AKSO Zadanie Zaliczeniowe 2
; Autor rozwiazania: Andrzej Jablonski 448257

global sum

section .text

; void sum(int64_t *x, size_t n);
; Argumenty:
; rdi - adres tablicy x
; rsi - wartosc n

sum: 
	mov r10, 1 		; r10 = 1
	xor r11, r11 	; r11 = 0 - ostatni indeks aktualnej liczby-wyniku w x[]

loop_i:
	; Sprawdzamy warunek petli
	cmp r10, rsi	; sprawdzamy, czy r10 < rsi (czyli czy i < n)
	jge loop_i_end 	; koniec petli jesli r10 >= rsi
	
	; Obliczamy pozycje (64 * i * i / n) dla x[i]
	mov rax, r10 	; rax = r10
	mul r10 		; rax = r10 * r10
	shl rax, 6 		; rax = 64 * r10 * r10
	xor rdx, rdx 	; rdx = 0 zeby dzielenie przebieglo poprawnie
	div rsi 		; rax = 64 * r10 * r10 / rsi
	
	; Obliczamy ilosc bitow i indeks wstawienia dla dolnej czesci x[i] (low)
	mov rcx, 64 
	xor rdx, rdx	; rdx = 0 zeby dzielenie przebieglo poprawnie
	div rcx 		; rdx = rax % 64, rax = rax / 64

	; Wstawiamy wyniki do innych rejestrow
	mov rcx, rdx 	; rcx = rax % 64; 
	mov r8, rax		; r8 - indeks wstawienia low
	
	; ---------------------------------------------------------------
	; Aktualne rejestry:                                            ;					
	; r8 - indeks wstawienia low (*)                                ;
	; rcx - przesuniecie bitowe                                     ;
	; r10, r11 - indeksy petli i konca wyniku                       ;
	; ---------------------------------------------------------------
	
	; Po wykonaniu ponizszego bloku kodu chcemy miec w rejestach:
	; r9 - high (gorna czesc x[i])
	; r8 - low (dolna czesc x[i])
	; rcx - indeks, w ktorym dodamy low (high dodamy do rcx + 1)
	; ======================= 
	mov rax, [rdi + 8*r10] 	; rax = x[r10]
	cqo						; rdx - wyzsze 64 bity rax w zapisie 128 bitowym
	shld rdx, rax, cl		; przesun rdx w lewo, a z prawej strony 
							; uzupelnij bitami skopiowanymi z lewej strony rax
	mov r9, rdx				; r9 = rdx to nasze high
	shl rax, cl				; rax <<= cl
	mov rcx, r8				; rcx = r8 - indeks wstawienia low (kopiujemy z r8 (*))
	mov r8, rax				; r8 = rax to nasze low 
	; ======================= 
	
	; ---------------------------------------------------------------
	; Aktualne rejestry: 											;
	; r8 - low														;
	; r9 - high														;
	; rcx - indeks wstawienia low									;
	; r10 - indeks aktualnego x[i]									;
	; r11 - ostatni indeks liczby-wyniku zapisanego w x[]			;
	; ---------------------------------------------------------------

	; Rozszerzamy wynik na kolejne indeksy w x[], zeby r11 >= min(rcx + 2, r10)
	; Z monotonicznosci i oraz rcx wynika, ze po kazdym wykonaniu tej petli 
	; r11 bedzie rowne dokladnie min(r10, rcx + 2)
	inc rcx					; zeby latwiej sprawdzac warunek, rcx = rcx + 1 (rcx')
							; wtedy r11 == rcx' + 1 = rcx + 2 <=> r11 > rcx'
loop_extend_r11:
	cmp r11, rcx			
	jg loop_extend_r11_end 	; koniec petli, jesli r11 = rcx + 1
	cmp r11, r10 
	je loop_extend_r11_end 	; koniec petli, jesli r11 == r10 
	
	mov rax, [rdi + r11*8] 	; rax = x[r11] - najwyzsze 8 bajtow wyniku 
	cqo 					; rdx bedziemy wstawiac do x[r11+1]
	inc r11					; r11 ++
	mov [rdi + r11*8], rdx	; rozszerzylismy wynik o jeden indeks 
	
	jmp loop_extend_r11
loop_extend_r11_end:
	dec rcx					; przywracamy originalna wartosc rcx

	; Teraz r11 = min(r10, rcx + 2). 
	; Ponadto mozna zauwazyc, ze r10 >= rcx + 1, wiec r11 >= rcx + 1 (**)

	; Dodajemy low (mozemy, bo z (**) wiemy, ze rcx <= r11 - 1)
	add [rdi + rcx*8], r8	; dodajemy low (byc moze zostalo jakies carry)
	inc rcx					; rcx ++

	; Dodajemy high (mozemy, bo rcx <= r11)
	adc [rdi + rcx*8], r9	; dodajemy high z carry
	inc rcx					; rcx ++
	
	; Kopiujemy carry do r8
	mov r8, 0				; r8 = 0
	adc r8, 0				; kopiujemy carry do r8
	
	; Sprawdzamy, czy rcx <= r11 (tak naprawde to czy rcx = r11), 
	; czyli czy mozemy wykonac dodawanie na jeszcze jednej pozycji
	cmp rcx, r11
	ja high_extra_skip 		; jesli nie, to nic nie robimy

	; Obliczamy high_extra - przedluzenie high do 128 bitow
	mov rax, r9				; rax = r9, czyli high
	cqo						; rdx to nasze high_extra

	; Przywracamy carry
	clc 					; carry = 0
	cmp r8, 0
	jz high_extra_carry_set	; jesli carry ma byc 0
	stc 					; carry = 1
high_extra_carry_set:

	; Dodajemy high_extra (bo wiemy, ze rcx <= r11)
	adc [rdi + rcx*8], rdx	; dodajemy high_extra z carry

high_extra_skip:
	
	inc r10
	jmp loop_i				; wykonujemy kolejny obrot petli
loop_i_end:
	
	ret
