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
lui $sp, 0x03FF

syscall0:

j __SYSCALL_EndOfFile__
syscall1:

jr $k0
syscall5:

jr $k0
syscall9:

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


__SYSCALL_EndOfFile__:



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
