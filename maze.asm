
# ============================================================
#  MAZE GAME - MIPS Assembly
#  10x10 grid. Player starts at (1,1).
#  Controls: w=up  s=down  a=left  d=right
#
#  RGB Screen memory map:
#    0xFFFFF020  X coordinate       -> sw $t7, 0($t6)
#    0xFFFFF024  Y coordinate       -> sw $t7, 4($t6)
#    0xFFFFF028  RGB color          -> sw $a0, 8($t6)
#    0xFFFFF02C  Write signal       -> sw $zero, 12($t6)
#
#  Maze encoding: 1 = open/walkable, 0 = wall
#
#  Index formula (word addressed, stride = 10):
#    index = row*10 + col
#    row*10 = (row<<3) + (row<<1)
#    la gives word address so no byte shift needed on index
#
#  draw_full is non-leaf (calls drawInit via jal).
#  $ra saved into $s6 — stack not used since it may be
#  uninitialized when main first runs.
#
#  10x10 maze layout (0=wall, 1=open):
#    0 0 0 0 0 0 0 0 0 0   row 0
#    0 1 1 0 1 1 1 0 1 0   row 1
#    0 1 0 0 1 0 1 0 1 0   row 2
#    0 1 0 1 1 0 1 1 1 0   row 3
#    0 1 0 1 0 0 0 0 1 0   row 4
#    0 1 1 1 1 1 1 0 1 0   row 5
#    0 0 0 0 1 0 1 0 1 0   row 6
#    0 1 1 1 1 0 1 1 1 0   row 7
#    0 1 0 0 0 0 0 0 1 0   row 8
#    0 0 0 0 0 0 0 0 0 0   row 9
# ============================================================
 
.data
 
maze: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
 
px:  .word 1
py:  .word 1
 
.text
.globl main
 
# ============================================================
#  MAIN
# ============================================================
main:
    jal  drawInit
    j    loop
 
# ============================================================
#  LOOP - read one character and process it
# ============================================================
loop:
    addi $v0, $0, 12
    syscall
    add  $t2, $0, $v0       # $t2 = ASCII key
 
    la   $t0, px
    lw   $s0, 0($t0)        # $s0 = current col
    la   $t0, py
    lw   $s1, 0($t0)        # $s1 = current row
 
    add  $s2, $0, $s0       # proposed col = current col
    add  $s3, $0, $s1       # proposed row = current row
 
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
 
# ============================================================
#  TRY_MOVE - validate ($s2,$s3) and commit if legal
# ============================================================
try_move:
    # --- Bounds: 0 <= col < 10 ---
    slt  $t7, $s2, $0
    bne  $t7, $0, loop
    addi $t0, $0, 10
    slt  $t7, $s2, $t0
    beq  $t7, $0, loop
 
    # --- Bounds: 0 <= row < 10 ---
    slt  $t7, $s3, $0
    bne  $t7, $0, loop
    slt  $t7, $s3, $t0
    beq  $t7, $0, loop
 
    # --- Maze check: maze[row*10 + col] must be 1 ---
    # row*10 = (row<<3) + (row<<1)
    sll  $t1, $s3, 3        # row * 8
    sll  $t7, $s3, 1        # row * 2
    add  $t1, $t1, $t7      # row * 10
    add  $t1, $t1, $s2      # row * 10 + col
 
    la   $t0, maze
    sll  $t1, $t1, 2        # byte shift (lw uses byte address internally)
    add  $t0, $t0, $t1
    lw   $t1, 0($t0)
    beq  $t1, $0, loop      # 0 = wall, reject
 
    # --- Commit move ---
    la   $t0, px
    sw   $s2, 0($t0)
    la   $t0, py
    sw   $s3, 0($t0)
 
    jal  drawInit
    j    loop
 
# ============================================================
#  DRAWINIT - render full 10x10 grid
#
#  Non-leaf: saves $ra into $s6 before inner pixel loops.
#  No stack used (may be uninitialized at startup).
#
#  Registers:
#    $t0  row counter
#    $t1  col counter
#    $t2  scratch / screen_x base
#    $t3  scratch / screen_y base
#    $t4  player col
#    $t5  player row
#    $t6  display base (0xFFFFF020)
#    $t7  scratch
#    $a0  color
#    $s4  dx (inner pixel col loop)
#    $s5  dy (inner pixel row loop)
#    $s6  saved $ra
# ============================================================
drawInit:
    add  $s6, $0, $ra           # save $ra - this fn is non-leaf
 
    lui  $t6, 65535
    ori  $t6, $t6, 61472        # $t6 = 0xFFFFF020
 
    la   $t4, px
    lw   $t4, 0($t4)            # $t4 = player col
    la   $t5, py
    lw   $t5, 0($t5)            # $t5 = player row
 
    addi $t0, $0, 0             # row = 0
 
draw_row:
    addi $t7, $0, 10
    beq  $t0, $t7, draw_done    # exit when row == 10
 
    addi $t1, $0, 0             # col = 0
 
draw_col:
    addi $t7, $0, 10
    beq  $t1, $t7, draw_next_row
 
    # --- Default color: floor green ---
    lui  $a0, 0
    ori  $a0, $a0, 21760        # 0x005500
 
    # --- Player cell? ---
    bne  $t1, $t4, check_wall
    bne  $t0, $t5, check_wall
    addi $a0, $0, 255           # 0x0000FF blue
    j    draw_pixels
 
check_wall:
    # index = row*10 + col
    # row*10 = (row<<3) + (row<<1)
    sll  $t2, $t0, 3            # row * 8
    sll  $t3, $t0, 1            # row * 2
    add  $t2, $t2, $t3          # row * 10
    add  $t2, $t2, $t1          # row * 10 + col
 
    la   $t3, maze
    sll  $t2, $t2, 2            # byte shift (lw uses byte address internally)
    add  $t3, $t3, $t2
    lw   $t2, 0($t3)
 
    bne  $t2, $0, draw_pixels   # 1 = open, keep green
 
    # Wall: grey
    lui  $a0, 170
    ori  $a0, $a0, 43690        # 0xAAAAAA
 
draw_pixels:
    # screen_x = col*4 + 100,  screen_y = row*4 + 100
    sll  $t2, $t1, 2
    addi $t2, $t2, 100          # screen_x base for this cell
 
    sll  $t3, $t0, 2
    addi $t3, $t3, 100          # screen_y base for this cell
 
    addi $s5, $0, 0             # dy = 0
 
pixel_row:
    addi $t7, $0, 4
    beq  $s5, $t7, draw_next_cell
 
    addi $s4, $0, 0             # dx = 0
 
pixel_col:
    addi $t7, $0, 4
    beq  $s4, $t7, pixel_next_row
 
    add  $t7, $t2, $s4
    sw   $t7, 0($t6)            # X -> 0xFFFFF020
 
    add  $t7, $t3, $s5
    sw   $t7, 4($t6)            # Y -> 0xFFFFF024
 
    sw   $a0, 8($t6)            # color -> 0xFFFFF028
    sw   $zero, 12($t6)         # write  -> 0xFFFFF02C
 
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
    add  $ra, $0, $s6           # restore $ra
    jr   $ra
 
