section	.text
global	decode128

;rdi - zachowanie wskaźnika do tablicy bajtow BMP
;rsi - zachowanie wskaźnika do tablicy z kodami
;rdx - zachowanie wskaźnika na text zdekodowany

decode128:
	; prolog
	push rbp
	push rbx ; wrzucam rejestry zachowywane
	push r12 
	push r13
	push r14
	push r15
	;push rbp, rsp

	xor r14, r14 ; szerokosc paska
	xor r12, r12 
	xor r13, r13 
	xor r14, r14 
	xor r15, r15
	xor rcx, rcx
	
	xor r11, r11
	xor r10, r10
	mov r10, 0 ; wartosc poczatkowa tego co po przednio
	
	xor r9, r9
	mov r9, 104 ; ustawienie sumy kontrolnej
	xor r8, r8 
	mov r8b, 0 ; ustaweinie licznika sumy kontrolnej

find_start:

get_pixel:
	mov r13b, [rdi] ; pobranie znaku
	add rdi, 1
	;add r12, 1
	test r13b, r13b ; sprawdz czy w r13w jest zero (czarny)
	jnz get_pixel ; szukaj do momentu jak znajdziesz czarny
	
	
get_first_black:
	mov r13b, [rdi] ; pobranie znaku
	add rdi, 1
	add r14, 1 ; zwiekszenie szerokosci
	
	test r13b, r13b ; sprawdz czy w r13w jest zero (czarny)
	jz get_first_black ; szukaj do momentu jak skonczysz pobierac czarny 
	
	sar r14, 1 ; dzielimy przez dwa, mamy szerokosc paska	
	
	
skip_start_code:
	add	rdi, r14 ; dodaje szerokosc paska
	sub rdi, 1 ; zmniejszam o 1 - ominiecie czesciowo wzietego bialego
	
	mov r15, 8
	
skip_char:
	add rdi, r14 ; dodaje szerokosc paska
	sub r15, 1
	test r15, r15
	jnz skip_char


start_getting_char:
	xor cl, cl
	mov cl, 11 ;ile razy pobrac pixel by pobrac caly symbol
	xor r12, r12
	
get_char:
	xor r13, r13
	
	test cl, cl
	jz start_find_code
	
	mov r13b, [rdi] ; pobranie znaku
	add	rdi, r14 ; dodaje szerokosc paska


	sub cl, 1 ; zmniejsz licznik
	
	test r13b, r13b ; jesli bialy to nic nie dodaje
	jnz get_char
	xor r13b, r13b
	mov r13, 1 ;wrzucam jedynke zeby bylo co mnozyc
	sal r13, cl ; da rade jak nie cl ????
	
	add r12, r13
	
	jmp get_char

	
start_find_code:
	cmp r12, 1594 ; porownaj czy to znak stopu
	je before_exit ; zakoncz
	
	;;jesli nie to wyswietl poprzednia
	mov [rdx], r10 ; przekazujemy poprzednia
	add rdx, 1 ; zwiekszenie wskaznika na text

	xor rbx, rbx,
	mov rbx, rsi ; zapamietanie rsi
	
	xor r11, r11 ; indeks odleglosc w tabCode
	
find_code:

	xor r15, r15 ;wartosc dziesietna
	
	mov r15w, [rsi] ; pobierz wartosc z tabCode
	add rsi, 2 ; zwiekszenie codePointera
	add r11, 1; zwiekszenie indeksu odleglosci
	
	cmp r12, r15
	jne find_code
	
	xor r10, r10
	mov r10, r11 ; zachowanie ostatniego kodu(odleglosc) literki
	mov rsi, rbx ;odnowienie rsi
	
	;aktualizacja sumy kontrolnej
	
	sub r11, 1 ; zmniejszenie indeksu odleglosci
	
	add r8b, 1 ; zwieksz counter do sumy kontrolnej
	xor r13, r13
	mov r13b, r8b ; chwilowa kopia
	xor rbx, rbx ;????

count_check_sum:
	add r9, r11 ;zwieksz sume o nowa wartosc (odleglosc)
	add rbx, r11 ; liczymy ile dodajemy zeby potem odjac jakby to byla suma kontrolna
	sub r13b, 1
	test r13b, r13b
	jnz count_check_sum
	
	xor r13, r13
	
	jmp start_getting_char


error_check_sum:
	mov rdx, r15 ; odzyskanie rdx
	xor rbx, rbx 
	mov rbx, 1 ; daj wartosc niemozliwa zeby moc odczytac error
	mov [rdx], rbx ; przeniesienie do result text
	jmp exit

before_exit:
	;sprawdzenie czy znak równy sumie kontrolnej
	
	mov r15, rdx ; zapamietanie rdx
	
	sub r9, rbx ; odjecie wartosci z poprzedniej literki
	sub r10, 1 ; odjecie od ostatniej literki
	
	xor rdx, rdx
	xor rax, rax
	xor rbx, rbx
	
	
	mov rax, r9 ; przeniesienie sumy kontrolnej
	mov rbx, QWORD 103
	div rbx
	
	; reszta w edx
	cmp rdx, r10 ; porowanie z literka
	jne error_check_sum

exit:
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	xor rax, rax ; rax - wartosc zwracana
	ret


	

	
	