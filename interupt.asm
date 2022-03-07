# NOTE : Each key stroke will trigger one run of interupt handler (i.e. handler will run 4 times in our problem).
.data

.text
main:
   lui $t0, 0xffff   # $t0 stores address of receiver control
   lw $t1, 0($t0)   # $t1 stores entire contents of receiver control
   ori $t1, $t1, 0x0002   # sets 2nd bit in receiver control to 1
   sw $t1, 0($t0)   # $t1 stored back in receiver control 
loop:
   addi $t1, $t1, 0
   beq $0, $0, loop
   li $v0, 10
   syscall   # end of program
   
   
.kdata
   _k_save_at : .word 0
   _k_save_ra : .word 0
   _k_save_t0 : .word 0
   _k_save_t1 : .word 0
   _k_save_t2 : .word 0
   _k_save_t3 : .word 0
   expbuff: .space 80    # allocates space for 20 characters
   explen: .word 0       # expected length stored
   asciiZero: .byte '0'

.ktext 0x80000180
# 1) Code block for save registers
   sw $at, _k_save_at
   sw $ra, _k_save_ra
   sw $t0, _k_save_t0
   sw $t1, _k_save_t1
   sw $t2, _k_save_t2
   sw $t3, _k_save_t3
# 2) Read one character from the receiver
   lui $t0, 0xffff   # loads start address
   lw $t1, 0($t0)    # $t1 stores receiver control's contents
   andi $t1, $t1, 0x0001   # $t1 is now ready bit
   beq $t1, $0, recover   #not ready; send back to main
   lw $t3, 4($t0)   # $t3 stores the character that the user touched on the keyboard
   
   la $t0, explen   # $t0 contains the address of explen
   lw $t1, 0($t0)   # $t1 stores contents of explen
   beq $t1, 0, interupt1   # get strings 1st character
   beq $t1, 1, interupt2   # get strings 2nd character
   beq $t1, 2, interupt3   # get strings 3rd character
   beq $t1, 3, interupt4   # get strings 4th character
   
interupt1:
   la $t1, expbuff   # $t0 holds the address of the array
   sb $t3, 0($t1)   # the first number was storred into the array
   li $t0, 1   # length of explen is increased to 1
   sw $t0, explen
   b recover   # go back to main

interupt2:
   la $t1, expbuff   # $t0 holds the address of the array
   sb $t3, 4($t1)   # the + character was storred into the array
   li $t0, 2   # length of explen is increased to 2
   sw $t0, explen
   b recover   # go back to main

interupt3:
   la $t1, expbuff   # $t0 holds the address of the array
   sb $t3, 8($t1)   # the second number was storred into the array
   li $t0, 3   # length of explen is increased to 3
   sw $t0, explen
   b recover   # go back to main

interupt4:
   la $t1, expbuff   # $t0 holds the address of the array
   sb $t3, 12($t1)   # the = character was storred into the array
   li $t0, 4   # length of explen is increased to 4
   sw $t0, explen
   
# array now contains all the necessary characters to complete the calculation: print to screen

Calculate:
   # array now contains numbers at the first and third index. Retrieve these numbers, compute their sum, and print to the screen
   la $t3, expbuff   # loads the array of the address 
   lb $a0, 0($t3)   # load first number to $a0
   jal char2num   # passes first number stored in $a0. This char is converted to a number and stored in $v0
   move $t1, $v0   # first number (X) is stored in $t1
   lb $a0, 8($t3)   # load second number to $a0
   jal char2num   # passes second number stored in $a0. This char is converted to a number and stored in $v0
   move $t2, $v0   # second number (Y) is stored in $t2
   add $t1, $t1, $t2   # $t1 = X + Y
   div $t2, $t1, 10   # $t2 determins if $t1 is 1 or 2 digits
   li $k0, 0   # $k0 will be used for comparison
   bgt $t2, $k0, DoubleDigitSum   # if $t2 > $k0, that means $t1 >= 10
   j SingleDigitSum   # we didn't branch before, therefore sum is a single digit
   
DoubleDigitSum:
   li $a0, 1   # the sum will always be <20, so if its not a single digit, the first digit will always be a 1
   jal num2char
   move $t0, $v0   # $t0 holds 1 in char form
   sb $t0, 16($t3)   # store the 1 char in the array
   subi $t1, $t1, 10   # subtract 10 from sum; result is last char
   move $a0, $t1   # Move sum to $a0 to convert to char
   jal num2char
   move $t0, $v0   # $t0 holds 1 in char form
   sb $t0, 20($t3)   # store the 1 char in the array
   j Print
   
SingleDigitSum:
   move $a0, $t1   # Move sum to $a0 to convert to char
   jal num2char
   move $t0, $v0   # $t0 holds 1 in char form
   sb $t0, 16($t3)   # store the 1 char in the array

Print:
   lui $t0, 0xffff   # $t0 stores address of transmitter control.
   la $t3, expbuff   # $t7 is reset to the front of the array
   lb $t1, 0($t3)   # $t1 holds char at beginning of array
pollingPrint:
   beq $t1, $zero, recover
   sb $t1, 12($t0)   # data in $t4 is sent to the transmitter (and eventually printed)
Loop2:
   lw $k0, 8($t0)   # load transmitter controll to $k0
   andi $t2, $k0, 0x0001   # $t2 stores the ready bit
   beq $t2, $zero, Loop2   # continue to loop if not ready
   addi $t3, $t3, 4   # increment to next char in array
   lb $t1, 0($t3)   # $t1 = char in array at current index
   j pollingPrint
   
# 3) Code block for recover registers
recover:
   lw $at, _k_save_at
   lw $ra, _k_save_ra
   lw $t0, _k_save_t0
   lw $t1, _k_save_t1
   lw $t2, _k_save_t2
   lw $t3, _k_save_t3
   
   eret 
   
char2num:
lb $t0, asciiZero
subu $v0, $a0, $t0
jr $ra

num2char:
lb $t0, asciiZero
addu $v0, $a0, $t0
jr $ra   
   
   
   
   
