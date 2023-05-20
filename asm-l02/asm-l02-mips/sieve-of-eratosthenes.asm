.data
    N:	.word  100
    numall:	.space 400
    primes:	.space 400
    nprimes:	.word  0
.text
    # 1|_________________________________________________________________
    # Wype�nij tablic� liczbami od 1 do N
    
    # $t0 - counter (i)
    # $t1 - przesuniecie numall do konkretnej kom�rki
    # $t2 - N
    
    lw $t2, N
    wypelnij:
        bge $t0, $t2, end_wypelnij # p�tla do czasu az counter < N
        sll $t1, $t0, 2	 # przesuniecie = counter * 4(dlugosc slowa w bajtach)
        addi $t0, $t0, 1 	 # inkrementuj� counter
        sw $t0, numall($t1)	 # zapisuj� liczb� (counter) do tablicy
        j wypelnij	 # skok na pocz�tek p�tli
    end_wypelnij:
    
    
    # 2|________________________________________________________________
    # Wykre�l z tablicy wszystkie wielokrotno�ci liczby n
    
    # $t0 - counter (i)
    # $t1 - przesuniecie numall do konkretnej komorki
    # $t2 - N
    # $t3 - N/2
    # $t4 - counter (j)
    
    li $t0, 2		# ustawiam counter na 2
    div $t3, $t2, 2	# obliczam N/2
    
    # Powtarzaj dla n=2, ... N/2:
    powtarzaj:
        bgt $t0, $t3, end_powtarzaj	# dop�ki counter (i) <= N/2        
        add $t4, $t0, $t0		# ustawiam counter (j) na i + i 
        # Wykre�l z tablicy wszystkie wielokrotno�ci liczby n 
        wykresl:
            bgt $t4, $t2, end_wykresl 	# dop�ki counter (j) <= N
            sll $t1, $t4, 2		# przesuni�cie = counter (j) * 4(dlugosc slowa w bajtach)
            sub $t1, $t1, 4		# przesuniecie cofam o jedno aby dostac indeks numall
            sw $zero, numall($t1)		# wykre�lenie
            add $t4, $t4, $t0		# inkrementacja counter(j) o counter(i)
            j wykresl		# skok na pocz�tek p�tli wykre�l
        end_wykresl:
        addi $t0, $t0, 1		# inkrementacja counter(i) o 1
        j powtarzaj		# skok na pocz�tek p�tli powtarzaj
    end_powtarzaj:
    
    # 3|________________________________________________________________
    # zliczanie i zapisywanie do tablicy wy��cznie z liczbami pierwszymi
    
    # $t0 - counter (i)
    # $t1 - przesuniecie numall do konkretnej komorki
    # $t2 - N
    # $t3 - N/2
    # $t4 - nprimes
    # $t5 - przesuniecie primes do konkretnej komorki
    # $t6 - numall[i]
    
    li $t0, 1		# ustawiam counter na 1
    li $t4, 0		# zeruj� rejestr $t4 na zliczanie liczb pierwszych
    
    zapisywanie:
        bge $t0, $t3, end_zapisywanie	# dop�ki counter(i) >= N/2
        sll $t1, $t0, 2		# przesuniecie = counter(i) * 4(dlugosc slowa w bajtach)
        lw $t6, numall($t1)		# �aduj� do rejestru kolejn� liczb� - numall[i]
        beqz $t6, after_storing		# je�li jest r�wna zero to pomi� nast�pne 3 linie
        sll $t5, $t4, 2		# przesuniecie = counter * 4(dlugosc slowa w bajtach)
        sw $t6, primes($t5)		# zapisuj� numall[i] do tablicy primes
        addi $t4, $t4, 1		# inkrementacja licznika nprimes
        after_storing: 		# 
        addi $t0, $t0, 1		# inkrementacja counter(i) o 1
        j zapisywanie		# skok na pocz�tek p�tli zapisywanie
    end_zapisywanie:
    sw $t4, nprimes		# zapisz do .data ilo�� liczb pierwszych
    
    # 4|________________________________________________________________
    # wypisywanie
    
    # $t0 - counter (i)
    # $t1 - primes[i]
    # $t2 - N
    # $t3 - N/2
    # $t4 - nprimes
    
    li $t0, 0			# resetuj� counter(i)
    
    wypisywanie:
        beq $t0, $t4, end_wypisywanie	# dop�ki counter(i) != nprimes
        sll $t1, $t0, 2		# przesuniecie = counter(i) * 4(dlugosc slowa w bajtach)
        
        li $v0, 1		# typ syscall - print integer
        lw $a0, primes($t1)		# �aduj� primes[i] do argumentu syscalla
        syscall			# wywolanie systemowe
        
        li $v0, 11		# typ syscall - print ascii
        li $a0, 32		# �aduj� whitespace do argumentu syscalla
        syscall			# wywolanie systemowe
        
        addi $t0, $t0, 1		# inkrementacja counter(i)
        j wypisywanie		# skok na pocz�tek p�tli wypisywanie
    end_wypisywanie:
    
    
    # zakoncz poprawnie program
    end:
    li $v0, 10		# serwis exit
    syscall		# wywolanie systemowe