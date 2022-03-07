# NOTE : Addition will execute once the string is ready to be processed (i.e. will run 1 time)
.data
asciiZero: .byte '0'
exp: .space 30

.text
main:
   la $t7, exp # loads the array of the address
   lui $t0, 0xffff   # $t0 stores address of receiver control.
   li $s0, 0
   li $s1, 4

Polling:
   bge $s0, $s1, Calculate
Loop:
   lw $t1, 0($t0)   # load receiver to $t1
   andi $t2, $t1, 0x0001   # $t2 stores the ready bit
   beq $t2, $zero, Loop   # continue to loop if not ready
   lw $t3, 4($t0)   # $t3 holds the byte received from receiver
   sb $t3, 0($t7)   # store content of $t3 into the array
   addi $t7, $t7, 1   # increment to the next index in the array
   addi $s0, $s0, 1   # increase $s0 to update loop counter
   j Polling
   
Calculate:
   # array now contains numbers at the first and third index. Retrieve these numbers, compute their sum, and print to the screen
   la $t7, exp   # loads the array of the address 
   lb $a0, 0($t7)   # load first number to $a0
   addi $t7, $t7, 2   # move index to third element in array (i.e. second number)
   jal char2num   # passes first number stored in $a0. This char is converted to a number and stored in $v0
   move $t3, $v0   # first number (X) is stored in $t3
   lb $a0, 0($t7)   # load second number to $a0
   jal char2num   # passes second number stored in $a0. This char is converted to a number and stored in $v0
   move $t4, $v0   # second number (Y) is stored in $t4
   add $t3, $t3, $t4   # $t3 = X + Y
   div $t4, $t3, 10   # $t4 determins if $t3 is 1 or 2 digits
   li $s0, 0   # $s0 will be used for comparison
   bgt $t4, $s0, DoubleDigitSum   # if $t4 > $s0, that means $t3 >= 10
   j SingleDigitSum   # we didn't branch before, therefore sum is a single digit
   
DoubleDigitSum:
   li $a0, 1   # the sum will always be <20, so if its not a single digit, the first digit will always be a 1
   jal num2char
   move $t5, $v0   # $t5 holds 1 in char form
   addi $t7, $t7, 2   # move to 5th index in array
   sb $t5, 0($t7)   # store the 1 char in the array
   subi $t3, $t3, 10   # subtract 10 from sum; result is last char
   subi $t7, $t7, 1   # reduce index by 1 so we add to index 6 in line 53
   
SingleDigitSum:
   move $a0, $t3   # Move sum to $a0 to convert to char
   jal num2char   # char of sum stored in $v0
   move $t5, $v0   # get digit in char form
   addi $t7, $t7, 2   # move to the 5th (or 6th) index
   sb $t5, 0($t7)   # store char in the array. Array now contains all the characters needed
   
   lui $t0, 0xffff   # $t0 stores address of transmitter control.
   la $t7, exp   # $t7 is reset to the front of the array
   lb $t4, 0($t7)   # $t4 holds char at beginning of array
Print:
   beq $t4, $zero, Exit
   sb $t4, 12($t0)   # data in $t4 is sent to the transmitter (and eventually printed)
Loop2:
   lw $t1, 8($t0)   # load transmitter controll to $t1
   andi $t2, $t1, 0x0001   # $t2 stores the ready bit
   beq $t2, $zero, Loop2   # continue to loop if not ready
   addi $t7, $t7, 1   # increment to next char in array
   lb $t4, 0($t7)   # $t4 = char in array at current index
   j Print

Exit:
   li $v0, 10
   syscall   # end of program

char2num: # converts a character to a number 
lb $t0, asciiZero
subu $v0, $a0, $t0
jr $ra

num2char: # converts a number to a character
lb $t0, asciiZero
addu $v0, $a0, $t0
jr $ra
   
