# Maze Game - NxN grid
# controls: w=up s=down a=left d=right
# change gridSize to resize (maze data must match)

.data

# 0=wall 1=open
maze: .word 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,0,1,0,1,0,1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,0,1,0,1,1,1,0,1,1,0,1,1,1,0,1,1,1,0,1,0,0,1,0,0,0,1,0,1,0,0,0,1,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,0,0,1,0,0,0,1,1,1,1,1,0,1,1,1,0,1,1,1,1,1,0,1,1,0,0,1,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,1,0,0,1,1,1,1,1,0,1,1,1,0,1,1,1,1,1,0,1,1,0,0,1,0,0,0,1,0,1,0,0,0,1,0,0,0,1,0,0,1,0,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,0,0,0,0,1,0,0,0,1,0,1,0,0,0,1,0,0,0,1,0,0,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1,0,0,1,0,1,0,1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,0,1,1,1,0,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
gridSize: .word 20


#current user location
px:  .word 1
py:  .word 1

#goal location
gx:  .word 8
gy:  .word 1

#prev pixel location
ppx: .word 1
ppy: .word 1

.text
.globl main

main:
    jal  drawInit
    j    loop

loop:
    addi $v0, $0, 12
    syscall
    add  $t2, $0, $v0

    la   $t0, px
    lw   $s0, 0($t0)
    la   $t0, py
    lw   $s1, 0($t0)

    add  $s2, $0, $s0
    add  $s3, $0, $s1

    addi $t3, $0, 119
    beq  $t2, $t3, do_up
    addi $t3, $0, 115
    beq  $t2, $t3, do_down
    addi $t3, $0, 97
    beq  $t2, $t3, do_left
    addi $t3, $0, 100
    beq  $t2, $t3, do_right
    j    loop

do_up:
    addi $s3, $s3, -1
    j    try_move
do_down:
    addi $s3, $s3, 1
    j    try_move
do_left:
    addi $s2, $s2, -1
    j    try_move
do_right:
    addi $s2, $s2, 1

try_move:
    # bounds check col
    slt  $t7, $s2, $0
    bne  $t7, $0, loop
    la   $t0, gridSize
    lw   $t0, 0($t0)
    slt  $t7, $s2, $t0
    beq  $t7, $0, loop

    # bounds check row
    slt  $t7, $s3, $0
    bne  $t7, $0, loop
    slt  $t7, $s3, $t0
    beq  $t7, $0, loop

    # check maze[row*gridSize + col]
    mult $s3, $t0
    mflo $t1
    add  $t1, $t1, $s2

    la   $t0, maze
    sll  $t1, $t1, 2
    add  $t0, $t0, $t1
    lw   $t1, 0($t0)
    beq  $t1, $0, loop

    # save old pos, write new pos
    la   $t0, px
    la   $t1, ppx
    lw   $t2, 0($t0)
    sw   $t2, 0($t1)
    sw   $s2, 0($t0)

    la   $t0, py
    la   $t1, ppy
    lw   $t2, 0($t0)
    sw   $t2, 0($t1)
    sw   $s3, 0($t0)

    # check if player reached goal
    la   $t0, gx
    lw   $t0, 0($t0)
    bne  $s2, $t0, not_goal
    la   $t0, gy
    lw   $t0, 0($t0)
    bne  $s3, $t0, not_goal
    j    end

not_goal:
    lui  $t6, 65535
    ori  $t6, $t6, 61472

    # draw new player cell blue
    la   $t0, px
    lw   $t1, 0($t0)
    la   $t2, py
    lw   $t3, 0($t2)

    sll  $t1, $t1, 2
    addi $t1, $t1, 100
    sll  $t3, $t3, 2
    addi $t3, $t3, 100

    addi $t4, $0, 255

    jal  draw_block_4x4

    # erase old player cell green
    la   $t0, ppx
    lw   $t1, 0($t0)
    la   $t2, ppy
    lw   $t3, 0($t2)

    sll  $t1, $t1, 2
    addi $t1, $t1, 100
    sll  $t3, $t3, 2
    addi $t3, $t3, 100

    lui  $t4, 0
    ori  $t4, $t4, 21760

    jal  draw_block_4x4
    j    loop

end:
    lui  $t4, 65535
    ori  $t4, $t4, 0

    addi $v0,$0,11
    addi $a0,$0,89 #character Y
    syscall

    
    addi $v0,$0,11
    addi $a0,$0,111 #character o
    syscall

    
    addi $v0,$0,11
    addi $a0,$0,117 #character u
    syscall
    
    addi $v0,$0,11
    addi $a0,$0,32 #character space
    syscall
    
    addi $v0,$0,11
    addi $a0,$0,87 #character W
    syscall
    
    addi $v0,$0,11
    addi $a0,$0,105 #character i
    syscall
    
    addi $v0,$0,11
    addi $a0,$0,110 #character n
    syscall
    
    addi $v0,$0,11
    addi $a0,$0,33 #character !
    syscall

    addi $v0, $0, 10
    syscall

draw_block_4x4:
    add  $t8, $t1, $0
    add  $t9, $t3, $0

    addi $s4, $0, 0

y_loop:
    addi $t7, $0, 4
    beq  $s4, $t7, done_block

    addi $s5, $0, 0

x_loop:
    addi $t7, $0, 4
    beq  $s5, $t7, next_row

    add  $t0, $t8, $s5
    add  $t1, $t9, $s4

    sw   $t0, 0($t6)
    sw   $t1, 4($t6)
    sw   $t4, 8($t6)
    sw   $zero, 12($t6)

    addi $s5, $s5, 1
    j    x_loop

next_row:
    addi $s4, $s4, 1
    j    y_loop

done_block:
    jr   $ra

drawInit:
    add  $s6, $0, $ra   # save ra, non-leaf function

    lui  $t6, 65535
    ori  $t6, $t6, 61472

    la   $t4, px
    lw   $t4, 0($t4)
    la   $t5, py
    lw   $t5, 0($t5)

    # load goal col into $a1, goal row into $a2
    la   $a1, gx
    lw   $a1, 0($a1)
    la   $a2, gy
    lw   $a2, 0($a2)

    # load gridSize into $s7 for loop bounds
    la   $s7, gridSize
    lw   $s7, 0($s7)

    addi $t0, $0, 0

draw_row:
    beq  $t0, $s7, draw_done

    addi $t1, $0, 0

draw_col:
    beq  $t1, $s7, draw_next_row

    # default floor green
    lui  $a0, 0
    ori  $a0, $a0, 21760

    # goal cell? paint red
    bne  $t1, $a1, check_player
    bne  $t0, $a2, check_player
    lui  $a0, 255
    ori  $a0, $a0, 0
    j    draw_pixels

check_player:
    # player cell?
    bne  $t1, $t4, check_wall
    bne  $t0, $t5, check_wall
    addi $a0, $0, 255
    j    draw_pixels

check_wall:
    # index = row*gridSize + col
    mult $t0, $s7
    mflo $t2
    add  $t2, $t2, $t1

    la   $t3, maze
    sll  $t2, $t2, 2
    add  $t3, $t3, $t2
    lw   $t2, 0($t3)

    bne  $t2, $0, draw_pixels

    # wall grey
    lui  $a0, 170
    ori  $a0, $a0, 43690

draw_pixels:
    sll  $t2, $t1, 2
    addi $t2, $t2, 100

    sll  $t3, $t0, 2
    addi $t3, $t3, 100

    addi $s5, $0, 0

pixel_row:
    addi $t7, $0, 4
    beq  $s5, $t7, draw_next_cell

    addi $s4, $0, 0

pixel_col:
    addi $t7, $0, 4
    beq  $s4, $t7, pixel_next_row

    add  $t7, $t2, $s4
    sw   $t7, 0($t6)

    add  $t7, $t3, $s5
    sw   $t7, 4($t6)

    sw   $a0, 8($t6)
    sw   $zero, 12($t6)

    addi $s4, $s4, 1
    j    pixel_col

pixel_next_row:
    addi $s5, $s5, 1
    j    pixel_row

draw_next_cell:
    addi $t1, $t1, 1
    j    draw_col

draw_next_row:
    addi $t0, $t0, 1
    j    draw_row

draw_done:
    add  $ra, $0, $s6
    jr   $ra