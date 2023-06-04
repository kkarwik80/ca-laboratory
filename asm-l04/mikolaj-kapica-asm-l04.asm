#=============================================
.eqv STACK_SIZE 2048
#=============================================
.data

# obszar na zapami�tanie adresu stosu systemowego
sys_stack_addr: .word 0

# deklaracja w�asnego obszaru stosu
stack: .space STACK_SIZE

# tablica int global_array[10] = { 1,2,3,4,5,6,7,8,9,10 };
global_array: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

# ============================================
.text

# czynno�ci inicjalizacyjne
    sw $sp, sys_stack_addr   # zachowanie adresu stosu systemowego
    la $sp, stack+STACK_SIZE # zainicjowanie obszaru stosu
     
# pocz�tek programu programisty - zak�adamy, �e main
# wywo�ywany jest tylko raz
main:
    # cia�o programu . . .
    # umieszcza na stosie kolejne argumenty funkcji - od lewej do prawej 
    subi $sp, $sp, 8     # 8 = 2 * sizeof( int )
    li $t1, 10           # drugi argument sum
    sw $t1, ($sp)        # na stos
    la $t1, global_array # pierwszy argument sum
    sw $t1, 4($sp)
    
    # wywo�uje funkcj� rozkazem
    jal sum
    
    lw $a0, ($sp) # pobiera ze stosu warto�� zwr�con� przez wywo�any podprogram
    addi $sp, $sp, 12 # przesuwa wska�nik stosu tak aby usun�� z niego warto�� zwracan� 
                      # oraz argumenty podprogramu po�o�one na stos przed jego wywo�aniem
    
    # print
    li $v0, 1
    syscall
    
    # koniec podprogramu main:
    lw $sp, sys_stack_addr # odtworzenie wska�nika stosu
                           # systemowego
    li $v0, 10
    syscall
    
sum:
    subi $sp, $sp, 8 # przesuwa adres wierzcho�ka stosu tak aby zrobi� miejsce na warto�� zwracan�
                     # [oraz na $ra] 8 = 2 * sizeof( int )
    sw $ra, ($sp)    # umieszcza na wierzcho�ku stosu adres powrotu z rejestru $ra
    subi $sp, $sp, 8 # przesuwa adres wierzcho�ka stosu tak aby zrobi� miejsce na zmienne lokalne 
                     # 8 = 2 * sizeof( int )
    
    # stos wyglada teraz tak:
    # 20($sp) int *array
    # 16($sp) int array_size
    # 12($sp) wartosc zwracana
    # 8($sp)  $ra,
    # 4($sp)  int i
    # 0($sp)  int s 
                     
    # s := 0
    sw $zero, ($sp) 
    
    # i := array_size - 1
    lw $t0, 16($sp)    # $t0 := array_size
    subi $t0, $t0, 1 # $t0 := $t0 - 1
    sw $t0, 4($sp)   # zapisz $t0 do i
    
    while:
        lw $t0, 4($sp)   # zapisuj� do $t0 warto�� i   
        bltz $t0, end_while # while ( i >= 0 )
        lw $t1, ($sp)    # zapisuj� do $t1, warto�� s
        
        lw $t2, 20($sp) # $t2 := int *array
        sll $t3, $t0, 2 # $t3 := i * 4 (offset do indeksu w tablicy)
        add $t2, $t2, $t3 # $t2 - adres kom�rki w tablicy
        lw $t2, ($t2) # $t2 - warto�� kom�rki w tablicy
        
        add $t1, $t1, $t2 # s := s + array[i]
        sw $t1, ($sp) # zapis s na stosie
        subi $t0, $t0, 1  # i = i - 1
        sw $t0, 4($sp) # zapis i na stosie
        j while
    end_while:
    
    sw $t1, 12($sp)  # zapisuje na stosie ( w miejscu poprzednio zarezerwowanym do tego celu) warto�� zwracan�
                    
    addi $sp, $sp, 8 # przesuwa wska�nik stosu tak aby usun�� ze stosu zmienne lokalne
    lw $ra, ($sp)      # pobiera ze stosu adres powrotu i umieszcza go w rejestrze $ra
    addi $sp, $sp, 4 # przesuwa wska�nik stosu tak aby na wierzcho�ku stosu znalaz�a si� warto�� zwracana
    jr $ra