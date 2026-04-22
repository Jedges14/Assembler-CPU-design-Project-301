#checks what value is in v0 and jumps to appropiate syscall method
addi $k1, $0,0
beq $v0, $k1,syscall0
addi $k1, $0,1
beq $v0, $k1,syscall1
addi $k1, $0,5
beq $v0, $k1,syscall5
addi $k1, $0,9
beq $v0, $k1,syscall9
addi $k1, $0,10
beq $v0, $k1,syscall10
addi $k1, $0,11
beq $v0, $k1,syscall11
addi $k1, $0,12
beq $v0, $k1,syscall12


#catches illegal syscalls
jr $k0

syscall0:
lui $sp, 0x03FF
la $k1, _END_OF_STATIC_MEMORY_
lui $k0, 0xFFFF
ori $k0, $k0, 0xF004
sw $k1, 0($k0)
j __SYSCALL_EndOfFile__


syscall1:
# handle 0 case
beq $a0, $0, printZero


# allocate stack space
addi $sp, $sp, -40
add  $v0, $sp, $zero     # v0 = stack pointer

extract:
addi $k1, $zero, 10      # k1 = 10
div  $a0, $k1
mfhi $k1                 # remainder
mflo $a0                 # quotient

addi $k1, $k1, 48        # ASCII
sw   $k1, 0($v0)
addi $v0, $v0, 4

bne  $a0, $zero, extract

#  terminal address 
lui $k1, 0xFFFF
ori $k1, $k1, 0xF000

printLoop:
addi $v0, $v0, -4
lw   $a0, 0($v0)
sw   $a0, 0($k1)

bne  $v0, $sp, printLoop

addi $sp, $sp, 40
jr $k0


printZero:
lui $k1, 0xFFFF
ori $k1, $k1, 0xF000

addi $v0, $zero, 48
sw   $v0, 0($k1)

jr $k0

syscall5:

    # result will be stored in $v0
    addi $v0, $0, 0          # result = 0

readLoop:
#Puts cur character from keyboard into k1
lui $k1, 0xFFFF
ori $k1, $k1, 0xF014
lw $k1,0($k1) 

# check if $k1 is a digit
addi $a3, $0, 48         
slt  $a3, $k1, $a3       
bne  $a3, $0, endReadLoop

addi $a3, $0, 58         
slt  $a3, $k1, $a3       
beq  $a3, $0, endReadLoop

# convert ASCII to digit 
addi $k1, $k1, -48      

#result = result * 10 + digit
addi $a3,$0,10
mult  $v0,$a3
mflo $v0	
add  $v0, $v0, $k1

# read next character into $k1 
#loading address
lui $k1, 0xFFFF
ori $k1, $k1, 0xF010
#Moves next character to front of buffer
sw $0,0($k1) 


j readLoop

endReadLoop:
jr $k0
syscall9:

# load address where heap pointer is stored (0xFFFFF004)
lui $k1, 0xFFFF
ori $k1, $k1, 0xF004

# load current heap pointer
lw $v0, 0($k1)
# compute new heap pointer = old + requested bytes
add $v0, $v0, $a0

# store updated heap pointer
sw $v0, 0($k1)

# return current heap pointer
sub $v0, $v0, $a0


jr $k0
syscall10:
#ends the program in effect
infLoop:
j infLoop

syscall11:

#adding address for terminal write and then writing
lui $k1, 0xFFFF
ori $k1, $k1, 0xF000
sw $a0,0($k1)

jr $k0


syscall12:

#loading address
checkKeyboard:
lui $k1, 0xFFFF
ori $k1, $k1, 0xF010
#Puts avalbility bit into k1

lw $k1,0($k1) 
beq $k1, $0,checkKeyboard

#Puts cur character from keyboard into v0
lui $k1, 0xFFFF
ori $k1, $k1, 0xF014
lw $v0,0($k1) 


jr $k0





#Template code

#Puts cur character from keyboard into k1
lui $k1, 0xFFFF
ori $k1, $k1, 0xF014
lw $k1,0($k1) 

#loading address
lui $k1, 0xFFFF
ori $k1, $k1, 0xF010
#Moves next character to front of buffer
sw $0,0($k1) 




__SYSCALL_EndOfFile__:
