
.data
maze:   .word 0 0 0 0 0 0 1 1 1 0 0 1 0 1 0 0 1 1 1 0 0 0 0 0 0

px:     .word 1
py:     .word 1

.text
.globl main

main:
    jal draw

loop:
    addi $v0, $0, 12
    syscall
    add  $t2,$0,$v0
    la $s0,px
    lw $s0,0($s0)

    la $s1,py
    lw $s1,0($s1)




    add $s2,$0,$s0
    add $s3,$0,$s1

    addi $t3,$0,119
    beq $t2,$t3,up
    addi $t3,$0,115
    beq $t2,$t3,down
    addi $t3,$0,97
    beq $t2,$t3,left
    addi $t3,$0,100
    beq $t2,$t3,right
    j loop

up:     addi $s3,$s3,-1
        j try
down:   addi $s3,$s3,1
        j try
left:   addi $s2,$s2,-1
        j try
right:  addi $s2,$s2,1

try:
    slt $t7,$s2,$0
    bne $t7,$0,loop
    slt $t7,$s3,$0
    bne $t7,$0,loop

    addi $t0,$0,5
    slt $t7,$s2,$t0
    beq $t7,$0,loop
    slt $t7,$s3,$t0
    beq $t7,$0,loop

    sll $t1,$s3,2
    add $t1,$t1,$s3
    add $t1,$t1,$s2

    la  $t0,maze
    sll $t1,$t1,2
    add $t0,$t0,$t1
    lw  $t1,0($t0)

    beq $t1,$0,loop


    la $s2,px
    sw $s2,0($s2)
    
    la $s3,py
    sw $s3,0($s3)


    jal draw
    j loop

draw:
    lui $t6,65535
    ori $t6,$t6,61480


    la $t4,px
    lw $t4,0($t4)
    la $t5,py
    lw $t5,0($t5)


    addi $t0,$0,0
row:
    addi $t7,$0,5
    beq $t0,$t7,done

    addi $t1,$0,0
col:
    beq $t1,$t7,next_row

    # li $a0,0x005500  (too big for addi)
    lui $a0,0
    ori $a0,$a0,21760

    bne $t1,$t4,chk_floor
    bne $t0,$t5,chk_floor

    # li $a0,0x0000FF
    addi $a0,$0,255
    j draw_cell

chk_floor:
    sll $t2,$t0,2
    add $t2,$t2,$t0
    add $t2,$t2,$t1
    la  $t3,maze
    sll $t2,$t2,2
    add $t3,$t3,$t2
    lw  $t2,0($t3)
    beq $t2,$0,draw_cell

    # li $a0,0xAAAAAA (too big)
    lui $a0,170
    ori $a0,$a0,43690

draw_cell:
    sll $t2,$t1,2
    addi $t2,$t2,100
    sll $t3,$t0,2
    addi $t3,$t3,100

    addi $t8,$0,0
py_loop:
    addi $t9,$0,4
    beq $t8,$t9,next_cell

    addi $s4,$0,0
px_loop:
    beq $s4,$t9,next_py

    add $s5,$t2,$s4
    sw  $s5,0($t6)

    add $s5,$t3,$t8
    sw  $s5,4($t6)

    sw  $a0,8($t6)
    sw  $zero,12($t6)

    addi $s4,$s4,1
    j px_loop

next_py:
    addi $t8,$t8,1
    j py_loop

next_cell:
    addi $t1,$t1,1
    j col

next_row:
    addi $t0,$t0,1
    j row

done:
    jr $ra