; AKSO Zadanie Zaliczeniowe 3
; Autor rozwiązania: Andrzej Jabłoński 448257

global _start

STDIN equ 0
STDOUT equ 1
STDERR equ 2

SYS_EXIT equ 60
SYS_READ equ 0
SYS_WRITE equ 1
SYS_OPEN equ 2
SYS_CLOSE equ 3               
O_CREAT equ 00000100o          ; Flaga - stwórz plik, jeśli nie istnieje.
O_EXCL equ 00000200o           ; Flaga - błąd, kiedy plik już istnieje.
O_RDONLY equ 00000000o         ; Flaga - plik tylko do odczytu.
O_WRONLY equ 00000001o         ; Flaga - plik tylko do zapisu.

; Moje własne flagi mówiące, co program ma zrobić pod koniec.
; Będa one ustawiane w rejestrze r10 przed wykonaniem skoku exit:
E1 equ 1 ; "return error code 1"
CI equ 2 ; "close input"
CO equ 4 ; "close output"

; Rozmiar buforów wyliczony na podstawie testowych uruchomień programu na dużych danych.
BF_IN equ 4096                ; Rozmiar bufora do wczytywania z pliku 
BF_OUT equ 4096               ; Rozmiar bufora do pisania do pliku.

ASCII_S equ 0x53              ; Kod ASCII litery S
ASCII_s equ 0x73              ; Kod ASCII litery s

section .bss
buffer_in resb BF_IN          ; Bufor wejściowy.
buffer_out resb BF_OUT        ; Bufor wyjściowy.


section .text

; Funkcja write_r12_bytes_to_r9_file służy jako makro do: 
; 1) wypisania (BF_OUT - r12 bajtów) z bufora wyjściowego do pliku o deskryptorze r9,
; 2) ustawienia flag, co zrobić po ewentualnym wystąpieniu błędu.
; Po wykonaniu, kod błędu znajdzie się w rejestrze rax.
write_r12_bytes_to_r9_file:
  ; Wykorzystamy 2 pomocnicze rejestry.
  push    r12
  push    rbx

  ; Oblicz r12 = BF_OUT - r12. Teraz rejestr r12 zawiera ilość bajtów do wypisania z bufora.
  mov     rbx, BF_OUT
  sub     rbx, r12
  mov     r12, rbx

  ; Ilość wypisanych już bajtów trzymamy w rejestrze rbx.
  xor     rbx, rbx

loop_write_r12_bytes_to_r9_file:
  mov     rax, SYS_WRITE
  mov     rdi, r9             ; Ustaw deskryptor na r9 (plik wyjściowy). 
  lea     rsi, [rel buffer_out + rbx] ; Wypisz z bufora buffer_out od pozycji rbx.
  mov     rdx, r12            ; Ilość bajtów do wypisania w pliku
  sub     rdx, rbx            ; to (r12 - rbx).
  syscall

  mov     r10, E1 | CI | CO   ; Jeśli wystąpi błąd, to:  
  cmp     rax, -4096          ; ustaw kod 1, zamknij plik wejściowy i wyjściowy.
  ja      return_write_r12_bytes_to_r9_file
  
  ; Zaktualizuj licznik wypisanych bajtów i sprawdź, czy to już wszystkie. 
  add     rbx, rax            
  cmp     rbx, r12
  je      return_write_r12_bytes_to_r9_file

  jmp     loop_write_r12_bytes_to_r9_file

return_write_r12_bytes_to_r9_file:
  pop     rbx
  pop     r12
  ret                         


; Funkcja write_2_bytes_length_to_buffer służy jako makro do 
; 1) zapisania w buforze wyjściowym 2 bajtów opisujących długość ciągu liter różnych od s i S,
; 2) LUB nie zrobienia niczego, jeśli ten ciąg był pusty (jego długość przechowuje rejestr r14).
write_2_byte_string_length_to_buffer_if_not_empty:
  cmp     r14, 0              ; Sprawdź, czy poprzedni  ciąg zwykłych liter (nie S i s) miał dodatnią długość.
  jz      return              ; Jeśli nie, to nic nie rób.
  
  mov     rcx, r14            ; Skopiuj informacje o długości ciągu zwykłych liter do rcx.

  mov     byte [r13], cl      ; Wpisz pod adres r13 tylko dolne 8 bitów rejestru rcx.
  inc     r13                 ; Przesuń adres w r13 na następny wolny element w buffer_out.
  dec     r12                 ; Zmniejsz ilość wolnych bajtów w buffer_out.

  shr     rcx, 8              ; Przesuń rejestr rcx o 8 bitów w prawo.
  mov     byte [r13], cl      ; Wpisz pod adres r13 kolejne 8 bitów rejestru rcx.
  inc     r13
  dec     r12

return:
  ret


; Główna funkcja w programie.
_start:
  ; Sprawdź poprawność argumentów. 
  mov     rcx, [rsp]          ; Ładuj do rcx liczbę argumentów.
  cmp     rcx, 3              ; (Pierwszy argument to zawsze nazwa programu.)   
  mov     r10, E1             ; Przed zakończeniem: ustaw kod 1. 
  jne     exit                ; Jeśli nie podano 2 argumentów, to program ma się zakończyć kodem 1.


  ; Załaduj nazwy plików do r8, r9.
  mov     r8, [rsp + 16]      ; Ładuje do r8 adres pierwszego parametru (nazwa pliku z wejściem).
  mov     r9, [rsp + 24]      ; Ładuje do r9 adres drugiego parametru (nazwa pliku z wyjściem).


  ; Otwórz plik wejściowy.
  mov     rax, SYS_OPEN
  mov     rdi, r8             ; Załaduj nazwę pliku z wejściem.
  mov     rsi, O_RDONLY       ; Ustaw flagę RDONLY.   
  mov     rdx, 444o           ; Ustaw tryb na r--r--r--.               
  syscall                     
  mov     r8, rax             ; Zapisz deskryptor pliku (lub kod błędu sys_open) w r8.
  ; Trikowe sprawdzenie, czy wystąpił błąd z otwieraniem pliku wejściowego. 
  mov     r10, E1             ; Przed zakończeniem: ustaw kod 1. 
  cmp     rax, -4096          ; Sprawdź, czy w rax jest wartość
  ja      exit                ; pomiędzy -1 a -4095. Tak to robią w libc.


  ; Otwórz plik wyjściowy. 
  mov     rax, SYS_OPEN
  mov     rdi, r9             ; Załaduj nazwę pliku z wyjściem.
  mov     rsi, O_CREAT | O_EXCL | O_WRONLY ; Ustaw flagi CREAT, WRONLY, EXCL.
  mov     rdx, 644o           ; Ustaw tryb na -rw-r--r--.
  syscall
  mov     r9, rax             ; Zapisz deskryptor (lub kod błędu) w r9.
  ; Trikowe sprawdzenie, czy wystąpił błąd. 
  mov     r10, E1 | CI        ; Przed zakończeniem: ustaw kod 1, zamknij plik wejściowy.
  cmp     rax, -4096          ; Sprawdź, czy w rax jest wartość
  ja      exit                ; pomiędzy -1 a -4095. Tak to robią w libc.



  ; ---------------------------------------------------------------

  ; -----------------------------------
  ; Aktualne rejestry:
  ; r8 - deskryptor inputu
  ; r9 - deskryptor outputu
  ; r10 - flagi, co zrobić na końcu programu
  ; -----------------------------------

  ; Rozpocznij algorytm z zadania. 

  ; Potrzebujemy jeszcze kilku rejestrów do iterowania się po buforach.
  push    rbx                 ; Ten rejestr trzyma adres aktualnego wolnego miejsca w buffer_in
  push    r12                 ; Ten rejestr mówi nam, ile jeszcze wolnych bajtów zostało w buforze buffer_out.
  mov     r12, BF_OUT
  push    r13                 ; Ten rejestr będzie trzymał adres aktualnego wolnego miejsca w buffer_out.
  lea     r13, [rel buffer_out]
  push    r14                 ; Ten rejestr będzie przechowywał informację, ile znaków != S/s
  xor     r14, r14            ; wystąpiło od poprzedniego wystąpienia S/s. Ustawiamy r14 = 0.

loop_read:
  ; Wczytaj kolejną część danych z pliku wejściowego do bufora buffer_in.
  mov     rax, SYS_READ 
  mov     rdi, r8             ; Ustaw deskryptor na r8 (plik wejściowy). 
  lea     rsi, [rel buffer_in]; Wczytuj do bufora buffer_in (adresowanie względne).
  mov     rdx, BF_IN          ; Maksymalna ilość bajtów = BF_IN.
  syscall
  ; Trikowe sprawdzenie, czy wystąpił błąd. 
  mov     r10, E1 | CI | CO   ; Przed zakończeniem: ustaw kod 1, zamknij plik wejściowy i wyjściowy. 
  cmp     rax, -4096          ; Sprawdź, czy w rax jest wartość
  ja      exit                ; pomiędzy -1 a -4095. Tak to robią w libc.

  ; Sprawdź, czy już skończyły się bajty w pliku wejściowym.
  cmp     rax, 0              ; Jeśli do bufora wczytano 0 bajtów, 
  jz      loop_read_end       ; to zakończ pętlę. 

  ; Ustaw rejestry dotyczące bufora wejściowego.
  lea     rbx, [rel buffer_in]; Wpisz adres bufora do rejestru rbx. 
                              ; Będziemy się po nim iterować, przesuwając go rax razy. 

  ; Przejdź po buforze, przeglądając kolejne litery.
loop_scan_buffer:
  ; Sprawdź, czy aktualna litera to S lub s.
  cmp     byte [rbx], ASCII_S
  je      case_Ss
  cmp     byte [rbx], ASCII_s
  je      case_Ss

  ; Jeśli nie...
  inc     r14                 ; Zwiększ licznik liter w ciągu.
  jmp     case_end            ; Przeskocz dalej w pętli, pomijając kod dla przypadku Ss.

case_Ss:
  ; Jeśli tak...
  
  ; W tym kroku będziemy pisać do buffer_out. Chcemy, żeby po każdej naszej operacji 
  ; buffer_out miał wolne jeszcze min. 2 bajty na ewentualny zapis na końcu programu.
  ; Maksymalnie dodamy do niego 1 + 2 + 2 (być może na końcu programu) = 5 bajtów. 
  ; Sprawdzimy więc, czy na pewno się one zmieszczą, a jeśli jest szansa, że nie, 
  ; to wykonamy zapis do pliku i zresetujemy bufor.

  ; Zapewniamy, że zawsze po zakończeniu głównej pętli w programie 
  ; zostanie nam zapasowe miejsce w buforze wyjściowym,
  ; np. na dopisanie ewentualnych 2 bajtów opisujących długość ciągu liter różnych od S i s
  ; znajdujących się na końcu pliku wejściowego.

  cmp     r12, 8              
  jae     buffer_out_reset_end; Jeśli jest >= 5 wolnych bajtów, to nie resetujemy.

  ; Zapisz zawartość bufora buffer_out do pliku wyjściowego. 
buffer_out_reset:
  push    rax                 ; Chwilowo wrzucamy rax na stos, bo jest tam ilość bajtów do przejrzenia.
  call    write_r12_bytes_to_r9_file
  ; Trikowe sprawdzenie, czy wystąpił błąd. 
  cmp     rax, -4096          ; Sprawdź, czy w rax jest wartość
  pop     rax                 ; (przywracamy wartość rax)
  ja      exit                ; pomiędzy -1 a -4095. Tak to robią w libc.
  
  ; Resetuj informacje o buforze wyjściowym.
  mov     r12, BF_OUT         ; Na nowo ustawiamy ilość wolnych bajtów w buffer_out.
  lea     r13, [rel buffer_out] ; I adres aktualnego wolnego elementu w buffer_out.

buffer_out_reset_end:
  ; Teraz na pewno możemy dopisać do bufora długość ciągu zwykłych liter (jeśli w ogóle jakieś były).
  call    write_2_byte_string_length_to_buffer_if_not_empty
  xor     r14, r14            ; Zresetuj licznik liter w ciągu.
  
  ; Przepisz jeszcze do bufora kod ASCII aktualnej litery s/S.
  mov     rcx, 0
  mov     rcx, [rbx]     ; Skopiuj kod aktualnego znaku (S lub s) z bufora do rcx. 
  mov     byte [r13], cl      ; Wpisz pod adres r13 tylko jednobajtowy kod. 
  inc     r13
  dec     r12

case_end: 

  inc     rbx                 ; Przesuń się na następny bajt bufora wejściowego. 
  dec     rax                 ; Zmniejsz licznik bajtów do przejrzenia.
  cmp     rax, 0              ; Jeśli już wszystkie przejrzeliśmy,
  je      loop_scan_buffer_end; zakończ pętlę przeglądającą bufor,
  jmp     loop_scan_buffer    ; w.p.p. wykonaj kolejny obrót pętli.

loop_scan_buffer_end:
  
  jmp loop_read               ; Wykonaj następny krok pętli głównej, 
                              ; wczytującej do bufora kolejne bajty z wejścia.

loop_read_end:

  ; Po zakończeniu głównej pętli trzeba jeszcze: 
  ; 1) sprawdzić, czy nie został nam ciąg zwykłych liter, 
  ;    którego jeszcze nawet nie wpisaliśmy do bufora,
  ; 2) przepisać resztki bufora do pliku wyjściowego.

  ; Krok 1) 
  ; Jeśli nie było takiego ciągu, bo np. dane wejściowe kończyły się na 's', to nic nie rób.
  ; Jeśli taki ciąg był, to wykonaj zapis do bufora informacji o liczbie bajtów w tym ciągu.
  ; Ta informacja zmieści sie w buforze, bo wcześniej zagwarantowaliśmy, że zostaną w nim min. 2 wolne bajty.
  ; print "Na koniec r12: ", r12
  call     write_2_byte_string_length_to_buffer_if_not_empty

  ; Krok 2) 
  call    write_r12_bytes_to_r9_file  ; Zapisz bajty z bufora wyjściowego w pliku wyjściowym. 
  ; Trikowe sprawdzenie, czy wystąpił błąd. 
  cmp     rax, -4096          ; Sprawdź, czy w rax jest wartość
  ja      exit                ; pomiędzy -1 a -4095. Tak to robią w libc.


  ; ---------------------------------------------------------------

  ; Co zrobić po poprawnym wykonaniu programu.
  mov     r10, CI | CO        ; Przed zakończeniem: zamknij plik wejściowy i wyjściowy.

exit:
close_I:
  ; Obsłuż zamknięcie pliku z wejściem.
  test    r10, CI             ; Sprawdź, czy plik powinien zostać zamknięty.
  jz      close_O             ; Jeśli nie, to przejdź do następnego kroku.
  mov     rax, SYS_CLOSE
  mov     rdi, r8             ; Załaduj nazwę pliku wejściowego z rejestru r8.
  syscall                     

  ; Trikowe sprawdzenie, czy wystąpił błąd. 
  cmp     rax, -4096          ; Sprawdź, czy w rax jest wartość
  jbe     skip_1

  or      r10, E1
skip_1:      

close_O:
  ; Obsłuż zamknięcie pliku z wyjściem.
  test    r10, CO             ; Sprawdź, czy plik powinien zostać zamknięty.
  jz      error_code          ; Jeśli nie, to przejdź do następnego kroku.
  mov     rax, SYS_CLOSE
  mov     rdi, r9             ; Załaduj nazwę pliku wyjściowego z rejestru r9.
  syscall 

  ; Trikowe sprawdzenie, czy wystąpił błąd. 
  cmp     rax, -4096          ; Sprawdź, czy w rax jest wartość
  jbe     skip_2

  or      r10, E1
skip_2:      

error_code:
  ; Obsłuż ustawienie kodu błędu.
  xor     rdi, rdi            ; Domyślnie ustaw rdi = 0.
  test    r10, E1             ; Sprawdz, czy program powinien się zakończyć z kodem błędu 1.
  jz      sys_exit            ; Jeśli nie, to przejdź do następnego kroku.
  mov     rdi, 1              ; Ustaw rdi = 1, jeśli flaga błędu jest ustawiona.
  
sys_exit:
  ; Przywróć rejestry.
  pop     r14
  pop     r13
  pop     r12
  pop     rbx              
  ; Zakończ program z kodem ustawionym w rdi.
  mov     eax, SYS_EXIT
  syscall
