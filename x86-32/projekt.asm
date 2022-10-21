section	.text
global	decode128
decode128:
	push ebp
	mov	ebp, esp
	;sub	esp,	16 ;???
	mov	eax, DWORD [ebp+8] ;zachowanie wskaźnika do tablicy bajtow BMP
	mov	ebx, DWORD [ebp+12] ;zachowanie wskaźnika do tablicy z kodami
	mov ecx, DWORD [ebp+16] ; zachowanie wskaźnika na text zdekodowany

	
load_arguments:
	mov [ebp-4], eax ;zachowanie wskaźnika do tablicy bajtow BMP
	mov [ebp-8], ebx ;zachowanie wskaźnika do tablicy z kodami
	mov [ebp-12], ecx ; zachowanie wskaźnika na text zdekodowany
	mov [ebp-16], DWORD 104 ; zachowanie sumy kontrolnej
	mov [ebp-20], BYTE 0 ; counter do sumy kontrolnej ;-1????
	;mov [ebp-24], ebx ; zachowanie szerokosci paska
	mov [ebp-28], DWORD 0 ; zachowanie ostatniego kodu(odleglosc) literki
	
	;mov edi, 6 ; counter ile literek pobrac
	
	xor esi, esi ; do sprawdzenia gdzie jestem
	

find_start:

get_pixel:	 
	mov dl, [eax]
	add eax, 1
	add esi, 1
	test dl, dl ; sprawdz czy w edx jest zero (czarny)
	jnz get_pixel ; szukaj do momentu jak znajdziesz czarny
	

	xor ebx, ebx
	
get_first_black: ;edx - pobrany znak, eax - index TabBMP, ebx, ecx, esi - dlugosc czarnego
	;mov ecx, [ebp-4] ; zdobadz licznik wskaznika do tablicy bajtow BMP
	mov dl, [eax] ; pobranie znaku
	add esi, 1 ;zwiekszenie dlugosci
	add ebx, 1
	add eax, 1 ;zwiekszenie licznika (plus 1 czy plus 2)
	;mov [ebp-4], ecx ; odlozen ie licznika na sterte
		; w edx bialy lub czarny 
	
	test dl, dl ; sprawdz czy w edx jest zero (czarny)
	jz get_first_black ; szukaj do momentu jak skonczysz pobierac czarny
	
	sar  ebx, 1 ; dzielimy przez dwa, mamy szerokosc paska		; eax - szerokosc paska, edx - pobrany znak
	
	mov [ebp-24], ebx ; zachowanie szerokosci paska
	
	mov edi, 8
	
skip_start_code:
	;add esi, 17 ;zwiekszenie dlugosci
	add eax, ebx ; dodaje szerokosc paska
	sub eax, 1 ; zmniejszam o 1 - ominiecie czesciowo wzietego bialego

skip_char:
	add eax, ebx 
	sub edi, 1
	test edi, edi
	jnz skip_char
	
	;add eax, 17 ;zwiekszenie licznika (plus 1 czy plus 2)
;	


	
;dl - pobrany znak, eax - index TabBMP, dh - szerokosc paska , ecx-wskaznik na result text, esi-znak binarnie
start_getting_char:		; eax - szerokosc paska, edx - pobrany znak, esi - to bedzie przechowywany znak binarnie, ebx - licznik instrukcji
	;;hmmm
	mov cl,11 ; ile razy mamy pobrac pixel i zwiekszyc index by pobrac caly char
	xor esi, esi ;wyzerowanie esi
	
get_char:
	test cl, cl
	jz start_find_code
	
	xor edx, edx
	;mov ecx, [ebp-4] ; zdobadz licznik wskaznika do tablicy bajtow BMP
	mov dl, [eax] ; pobranie znaku
	add eax, ebx ; zwiekszenie licznika o (plus 1 czy plus 2)*szerokosc_paska
	sub cl, 1
	
	test dl, dl ; jesli bialy to nic nie dodaje
	jnz get_char
	;add eax, [ebp-13]; zwiekszenie licznika o (plus 1 czy plus 2)*szerokosc_paska
	mov edx, 1 ;wrzucam jedynke zeby bylo co mnozyc
	;mov [ebp-4], ecx ; odlozenie licznika na sterte
	sal edx, cl
	add esi, edx
	
	jmp get_char
	
	


start_find_code:	
	mov [ebp-4], eax ;zachowanie wskaźnika do tablicy bajtow BMP
	mov eax, [ebp-8] ; zdobadz licznik wskaznika do tablicy code
	
	cmp esi, 1594 ; porownaj czy to znak stopu
	je before_exit; ; zakoncz
	
	
	;;jesli nie to wyswietl poprzednia
	mov ebx, [ebp-28] ; zdobycie ostatniego kodu(odleglosc) literki

	mov ecx, [ebp-12] ; zdobycie wskaźnika na text zdekodowany
	mov [ecx], ebx
	add ecx, 1 ; zwiekszenie wskaznika na text
	mov [ebp-12], ecx ; zachowanie wskaznika
	

	
	
	xor ebx, ebx ; licznik odleglosci w tablicy code


	
find_code:
	;;error_not_found
	xor ecx, ecx
	
	mov cx, [eax] ; ecx to bedzie wartosc dziesietna z code
	add eax, 2 ; zwiekszenie codePointera (plus 1 czy 2?)????
	add ebx, 1; zwiekszenie indeksu odleglosci
	
	cmp esi, ecx ; porownujemy 
	jne find_code
	

return: ;ebx - wynik (odleglosc)
	mov [ebp-28], ebx ; zachowanie ostatniego kodu(odleglosc) literki

	xor ecx, ecx
	xor edi, edi
	
	
	;;aktualizacja sumy kontrolnej ---------------------------------------
	sub ebx, 1; zmniejszenie indeksu odleglosci
	
	xor esi, esi
	mov esi, [ebp-16] ; zdobycie sumy kontrolnej
	mov ch, [ebp-20] ; zdobycie counter do sumy kontrolnej
	
	add ch, 1 ; zwieksz counter do sumy kontrolnej
	mov [ebp-20], ch ; zachowanie counter do sumy kontrolnej

count_check_sum:
	add esi, ebx ;zwieksz sume o nowa wartosc (odleglosc)
	add edi, ebx ; liczymy ile dodajemy zeby potem odjac jakby to byla suma kontrolna
	sub ch, 1
	test ch, ch
	jnz count_check_sum
	
	mov [ebp-16], esi ; zachowanie sumy kontrolnej
	;--------------------------------------------------------------
	
	mov eax, [ebp-4] ;zdobycie wskaźnika do tablicy bajtow BMP
	mov ebx, [ebp-24] ; zdobycie szerokosci paska
	xor ecx, ecx
	

	jmp start_getting_char
	

;error_check_sum:
;	jmp error_check_sum

before_exit:
	;sprawdzenie czy znak rowny sumie kontrolnej
	
	xor eax, eax
	xor edx, edx
	mov esi, [ebp-28] ; zdobycie ostatniego kodu(odleglosc) literki
	
	mov eax, [ebp-16] ; zdobycie sumy kontrolnej
	sub eax, edi
	
	sub eax, 1
	sub esi, 1
	
	mov ebx, DWORD 103
	div ebx
	
	;reszta w edx
;	cmp edx, esi
;	jne error_check_sum


;error_check_sum:	
	

exit:
	mov	eax, edx
	pop	ebp
	ret
	
	