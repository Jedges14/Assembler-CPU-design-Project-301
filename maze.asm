.data
    maze:   .word 0 0 0 0 0 0 1 1 1 0 0 1 0 1 0 0 1 1 1 0 0 0 0 0 0
    px:     .word 1
    py:     .word 1
    drawn:  .word 0

.text
.globl main

main:
    jal draw  
loop:
    addi $v0, $0, 12
    syscall
    add  $t2, $0, $v0

    # load px
    lui $t0, 0
    ori $t0, $t0, px
    lw  $s0, 0($t0)

    # load py
    lui $t0, 0
    ori $t0, $t0, py
    lw  $s1, 0($t0)

    add $s2,$0,$s0
    add $s3,$0,$s1

    addi $t3, $0, 119
    beq $t2, $t3, up
    addi $t3, $0, 115
    beq $t2, $t3, down
    addi $t3, $0, 97
    beq $t2, $t3, left
    addi $t3, $0, 100
    beq $t2, $t3, right
    j loop

up:     addi $s3, $s3, -1
        j try
down:   addi $s3, $s3, 1
        j try
left:   addi $s2, $s2, -1
        j try
right:  addi $s2, $s2, 1

# check valid move
try:
    slt $t7, $s2, $0
    bne $t7, $0, loop
    slt $t7, $s3, $0
    bne $t7, $0, loop

    addi $t0, $0, 5
    slt $t7, $s2, $t0
    beq $t7, $0, loop
    slt $t7, $s3, $t0
    beq $t7, $0, loop

    # index = y*5 + x
    sll $t1, $s3, 2
    add $t1, $t1, $s3
    add $t1, $t1, $s2

    lui $t0, 0
    ori $t0, $t0, maze

    sll $t1, $t1, 2
    add $t0, $t0, $t1
    lw  $t1, 0($t0)

    beq $t1, $0, loop   # wall check

    # store the old position t6 and t7
    lui $t0, 0
    ori $t0, $t0, px
    lw  $t6, 0($t0)

    lui $t0, 0
    ori $t0, $t0, py
    lw  $t7, 0($t0)

    # update position
    sw $s2, px
    sw $s3, py

    # update only player
    add $a0, $0,$t6   # old x
    add $a1,$0, $t7   # old y
    add $a2,$0, $s2   # new x
    add $a3, $0,$s3   # new y
    jal update_player

    j loop

draw:
    lui $t0, 0
    ori $t0, $t0, drawn
    lw  $t1, 0($t0)
    bne $t1, $0, done

    # mark drawn = 1
    addi $t1, $0, 1
    sw $t1, 0($t0)

    # fall through to full draw

#frame buffer
    lui $t6, 65535
    ori $t6, $t6, 61480

    # load player
    lw $t4, px
    lw $t5, py

    addi $t0, $0, 0

row:
    addi $t7, $0, 5
    beq $t0, $t7, done

    addi $t1, $0, 0

col:
    beq $t1, $t7, next_row

    # check maze
    sll $t2, $t0, 2
    add $t2, $t2, $t0
    add $t2, $t2, $t1

    lui $t3, 0
    ori $t3, $t3, maze
    sll $t2, $t2, 2
    add $t3, $t3, $t2
    lw  $t2, 0($t3)

    beq $t2, $0, floor
    lui $a0, 170
    ori $a0, $a0, 43690
    j check_player

floor:
    lui $a0, 0
    ori $a0, $a0, 21760

check_player:
    bne $t1, $t4, draw_cell
    bne $t0, $t5, draw_cell
    addi $a0, $0, 255

draw_cell:
    # simplified pixel draw
    sw $a0, 0($t6)

    addi $t1, $t1, 1
    j col

next_row:
    addi $t0, $t0, 1
    j row

done:
    jr $ra


update_player:
     lui $t6, 65535
    ori $t6, $t6, 61480

    add $t0, $0, $a1   # old y
    add $t1, $0, $a0   # old x

    addi $a0, $0, 0     # floor color
    sw $a0, 0($t6)

    add $t0, $0, $a3   # new y
    add $t1, $0, $a2   # new x

    addi $a0, $0, 255   # player color
    sw $a0, 0($t6)

    jr $ra

old_floor:
    lui $a0, 0
    ori $a0, $a0, 21760

draw_old:
    sw $a0, 0($t6)

    # draw new player
    add $t0, $0, $a3
    add $t1,$0, $a2

    addi $a0, $0, 255
    sw $a0, 0($t6)

    jr $ra