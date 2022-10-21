.eqv BMP_FILE_SIZE 90122 # 600 * 50 * 3 
.eqv BYTES_PER_ROW 1800	# 600*3

	.data
.align 4		#???
res:	.space 2
image:	.space BMP_FILE_SIZE
prompt: .string "  "
enter: .string " \n"
error_msg_check_sum: .string " invalid check sum "
error_msg_not_found: .string " char not found "
tabCode:  .half 1740, 1644, 1638, 1176, 1164, 1100, 1224, 1220, 1124, 1608, 1604, 1572, 1436, 1244, 1230, 1484, 1260, 1254, 1650, 1628, 1614, 1764, 1652, 1902, 1868, 1836, 1830, 1892, 1844, 1842, 1752, 1734, 1590, 1304, 1112, 1094, 1416, 1128, 1122, 1672, 1576, 1570, 1464, 1422, 1134, 1496, 1478, 1142, 1910, 1678, 1582, 1768, 1762, 1774, 1880, 1862, 1814, 1896, 1890, 1818, 1818, 1914, 1602, 1930, 1328, 1292, 1200, 1158, 1068, 1062, 1424, 1412
tabBMP:	.space	600 

fname:	.asciz "1.bmp"

	.text
main:
	jal	read_bmp #wywolanie funkcji
	li	t5, 0 # pointer
	li	a2, 1024 # potega
	li	a5, 0 # liczba dziesietna
	li	a4, 0 # znalezienie szerokoœci paska
	li	t1, 0x00000000 # czarny - 1
	li	a6, 104 # suma kontrolna
	li 	t0, 0 #zeby zapamietal poprzednia odkodowana wartosc

	
find_start:
	#get pixel color - $a0=x, $a1=y, result $v0=0x00RRGGBB
	mv	a0, t5		#x
	li	a1, 24		#y
	jal     get_pixel
	
	addi	t5, t5, 1
	bne	a0, t1, find_start 

something:
	addi	t5, t5, -1 # cofniecie zeby potem pobrac caly znak startu

get_first_black:
	mv	a0, t5		
	li	a1, 24		
	jal     get_pixel
	
	li	t1, 0x00000000 # czarny - 1
	
	addi	t5, t5, 1
	addi 	a4, a4, 1
	beq	a0, t1, get_first_black
	
	srli	a4, a4, 1 # dzielimy przez 2 - mamy szerokosc
	
	li 	a3, 9

skip_start_code:
	
	add	t5, t5, a4 # kolejny pixel
	addi	a3, a3, -1
	bnez	a3, skip_start_code
	
	li	a3, -1 # counter do sumy kontrolnej
	
	##jesli sie nie zgadza to wyjatek!
	
start_getting_char:
	li	a2, 2048 # reset potêgi
	li	a5, 0 # reset dzisietnej
	li	t6, 1 # do porownywania i konczenia petli
	
	li	t1, 0x00000000 # czarny - 1

	
	
get_char: ## a4 - szerokosc paska, a5 - liczba dziesietna, a2 - potega

	mv	a0, t5
	li	a1, 24
	jal     get_pixel
	
	add	t5, t5, a4 # kolejny pixel
	srli	a2, a2, 1 # zmniejszenie wartosci potegi

	
	beq	a2, t6, exit_getting_char
	bne	a0, t1, get_char # jak bialy - 0

	add	a5, a5, a2 # a5 - liczba dziesietna
	

	bne	a2, t6, get_char
	

exit_getting_char:
	##

start_find_code:
	la	t6, tabCode # pobranie CodePointera
	li	t1, 1594 # zalodowanie kodu znaku stop  -- 1.bmp - 1594, 3.bmp -1412, 2.bmp - 1412
	#lh	a2, (t6)	# laduje wartosc dziesietna code, potem i tak naprawi sie a2
	beq	a5, t1, exit # jak znak stopu to zakoncz
	
	# jesli nie to wyswietl poprzednia -----------------------
	mv	a0, t0	# wyswietl znaleziona wartosc
	li 	a7, 11
	ecall 
	
	# aktualizacja sumy kontrolnej
	addi	a3, a3, 1 # zwieksz counter do sumy kontrolnej
	mv	t2, a3 # skopiuj sobie counter do sumy kontrolnej
	li	t1, 0 # rozpoczecie liczenia indeksu
	
	beqz	t2, find_code
	addi	t0, t0, -32 # wroc do numeracji z code 128
	
count_check_sum:
	add	a6, a6, t0 # zwieksz sume o nowa wartosc (odleglosc)
	addi	t2, t2, -1
	bnez	t2, count_check_sum
	
find_code:
	
	li	t3, 94
	beq	t1, t3, error_not_found # jesli dojdzie do konca i nie znalazl to error 
	
	lh	a2, (t6)	# laduje wartosc dziesietna code, potem i tak naprawi sie a2
	
	addi	t6, t6, 2	# zwiekszenie CodePointera
	addi	t1, t1, 1 # zwiekszenie indeksu
	
	bne 	a2, a5, find_code	# porownanie z wlasciwa #jak nie ma to blad!!!!!!!!
	
	addi	t1, t1, 31 # -1 usuwamy to co niepotrzebnie dodalismy +32 dodajemy zeby naprawic ascii

	

	mv	t0, t1 # zapamietaj znaleziona literke

	j	start_getting_char
	#bnez	a3, start_getting_char  -----
	
error_check_sum:
	la	a0, error_msg_check_sum
	li	a7, 4
	ecall
	
	li 	a7,10		#Terminate the program
	ecall
	
error_not_found:
	la	a0, error_msg_not_found
	li	a7, 4
	ecall

	
	li 	a7,10		#Terminate the program
	ecall
	

exit:	
	#mv	a0, a5	# wyswietl liczbe dziesietna
	#li 	a7, 1 
	#ecall
	
	
	# sprawdzenie czy znak rowny sumie kontrolnej
	mv	t3, a6, #zapamietaj sume kontrolna
	li 	t2, 103 # do modulo
	rem	t3, t3, t2
	
	#addi	t3, t3, 33
	addi	t3, t3, 32
	
	#la	a0, enter
	#li	a7, 4
	#ecall
	
	#mv	a0, t0
	#li	a7, 1
	#ecall
	
	#addi	t3, t3, 1  #--------
	
	#la	a0, enter
	#li	a7, 4
	#ecall
	
	bne	t0, t3, error_check_sum # jesli poprzednia wartosc nie jest rowna oczekiwanej sumie kontrolnej to blad
	
	#beq	t1, t3, exit

	

	li 	a7,10		#Terminate the program
	ecall

# ============================================================================
read_bmp:
#description: 
#	reads the contents of a bmp file into memory
#arguments:
#	none
#return value: none
	addi sp, sp, -4		#push $s1
	sw s1, 0(sp)
#open file
	li a7, 1024
        la a0, fname		#file name 
        li a1, 0		#flags: 0-read file
        ecall
	mv s1, a0      # save the file descriptor
	
#check for errors - if the file was opened
#...

#read file
	li a7, 63	# 63 - read from file
	mv a0, s1
	la a1, image
	li a2, BMP_FILE_SIZE
	ecall

#close file
	li a7, 57	# 57 - read from file
	mv a0, s1
        ecall
	
	lw s1, 0(sp)		#restore (pop) s1
	addi sp, sp, 4	# usuwam miejsce na s1
	jr ra	# skok bez warunkowy na œlad

# ============================================================================


get_pixel:
#description: 
#	returns color of specified pixel
#arguments:
#	a0 - x coordinate
#	a1 - y coordinate - (0,0) - bottom left corner
#return value:
#	a0 - 0RGB - pixel color

	la t1, image		#adress of file offset to pixel array
	addi t1,t1,10
	lw t2, (t1)		#file offset to pixel array in $t2
	la t1, image		#adress of bitmap
	add t2, t1, t2		#adress of pixel array in $t2
	
	#pixel address calculation
	li t4,BYTES_PER_ROW
	mul t1, a1, t4 		#t1= y*BYTES_PER_ROW
	mv t3, a0		
	slli a0, a0, 1
	add t3, t3, a0		#$t3= 3*x
	add t1, t1, t3		#$t1 = 3x + y*BYTES_PER_ROW
	add t2, t2, t1	#pixel address 
	
	#get color
	lbu a0,(t2)		#load B
	lbu t1,1(t2)		#load G
	slli t1,t1,8
	or a0, a0, t1
	lbu t1,2(t2)		#load R
        slli t1,t1,16
	or a0, a0, t1
					
	jr ra

# ============================================================================
