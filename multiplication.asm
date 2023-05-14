.data
     licz1:       .word 0
     licz2:       .word 0
     wyn:         .word 0
     msg_mnozna:  .asciiz "Mnozna: "
     msg_mnoznik: .asciiz "Mnoznik: "
     msg_out:     .asciiz "Wynik: "

.text
     # wprowadzanie danych
     li $v0, 4		#wypisz zapytanie
     la $a0, msg_mnozna	#zapytanie o mnozna
     syscall		#wywolanie systemowe

     li $v0, 5		#wprowadz mnozna
     syscall		#wywolanie systemowe
     move $t0, $v0	#wrzucam mnozna do rejestru t0

     li $v0, 4		#wypisz zapytanie
     la $a0, msg_mnoznik	#zapytanie o mnoznik
     syscall		#wywolanie systemowe
     
     li $v0, 5		#wprowadz mnoznik
     syscall		#wywolanie systemowe
     move $t1, $v0	#przenosze mnoznik do rejestru t1 
     
     #mnozna: $t0, 
     #mnoznik: $t1,
     #wynik: $t2
     #counter: $t3
     #maska na ostatni bit mnoznej: $t4
     #dlugosc slowa: $t5
      
     
     
     #operacja mnozenia
     li $t3, 0		#counter
     li $t5, 30		#dlugosc slowa
     loop:
     beq $t5, $t3, end	# jesli przejdzie przez dlugosc mnoznej 32 miejsca bitowo
     and $t4, $t1, 1	# maska na ostatni bit mnoznika
     beq $t4, 0, shift	# jesli ostatni bit mnoznika jest 0 to przeskocz
     add $t2, $t2, $t0	# dodaj mnozna do wyniku
     shift:
     sll $t0, $t0, 1	# przesuwam w lewo mnozna, bo mnoze przez kolejny bit mnoznika
     srl $t1, $t1, 1	# przesuwam w prawo mnoznik aby dostac lsb
     addi $t3, $t3, 1	# inkrementuje counter
     j loop
     end:
     
     # wrzuc wynik do data wynik
     sw $t2, wyn
     
     #wypisz komunikat z wynikiem      
     li $v0, 4		#wypisz
     la $a0, msg_out	#wypisz "Wynik: "
     syscall		#wywolanie systemowe
     
     #wyprowadz wynik
     li $v0, 1
     lw $t0, wyn
     move $a0, $t0
     syscall
             
     # zakoncz poprawnie program                                               
     li $v0, 10
     syscall
	