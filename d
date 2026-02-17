[1mdiff --git a/test1.asm b/test1.asm[m
[1mindex fc1fc06..9ffe223 100644[m
[1m--- a/test1.asm[m
[1m+++ b/test1.asm[m
[36m@@ -1,17 +1,17 @@[m
[31m-          .data [m
[31m-          .text [m
[31m-          .globl main[m
[31m-# Simple test - basic arithmetic, one negative immediate[m
[31m-main:[m
[31m-    addi $t0, $0, 10[m
[31m-    addi $t1, $0, 98[m
[31m-    sll $t2, $t1, 5[m
[31m-    srl $t8, $t1, 3[m
[31m-    mult $t1, $t1[m
[31m-    mflo $t3[m
[31m-    div $t2, $t0[m
[31m-    mfhi $s6[m
[31m-    slt $s2, $t1, $t0[m
[31m-    addi $s3, $s6, -3[m
[31m-    addi $v0, $zero, 10[m
[32m+[m[32m          .data[m[41m [m
[32m+[m[32m          .text[m[41m [m
[32m+[m[32m          .globl main[m[41m[m
[32m+[m[32m# Simple test - basic arithmetic, one negative immediate[m[41m[m
[32m+[m[32mmain:[m[41m[m
[32m+[m[32m    addi $t0, $0, 10[m[41m[m
[32m+[m[32m    addi $t1, $0, 98[m[41m[m
[32m+[m[32m    sll $t2, $t1, 5[m[41m[m
[32m+[m[32m    srl $t8, $t1, 3[m[41m[m
[32m+[m[32m    mult $t1, $t1[m[41m[m
[32m+[m[32m    mflo $t3[m[41m[m
[32m+[m[32m    div $t2, $t0[m[41m[m
[32m+[m[32m    mfhi $s6[m[41m[m
[32m+[m[32m    slt $s2, $t1, $t0[m[41m[m
[32m+[m[32m    addi $s3, $s6, -3[m[41m[m
[32m+[m[32m    addi $v0, $zero, 10[m[41m[m
     syscall #End the program[m
\ No newline at end of file[m
[1mdiff --git a/test2.asm b/test2.asm[m
[1mindex ab277a9..47198a8 100644[m
[1m--- a/test2.asm[m
[1m+++ b/test2.asm[m
[36m@@ -1,20 +1,20 @@[m
[31m-.data[m
[31m-    barray: .word 4 f[m
[31m-    array: .word 3 4 5 #This comment must be ignored[m
[31m-    [m
[31m-.text[m
[31m-.globl main[m
[31m-main:[m
[31m-  #This comment must be ignored[m
[31m-  addi $s0, $zero, 100 #this comment needs to be ignored[m
[31m-loop:[m
[31m-  add $a0, $s0, $0 #call f with parameter i[m
[31m-  jal f[m
[31m-  addi $s0, $v0, 0 #i = f(i)[m
[31m-  bne $s0, $zero, loop[m
[31m-  addi $v0, $0, 10[m
[31m-  syscall[m
[31m-f:[m
[31m-  la $t0, array[m
[31m-  srl $v0, $a0, 1[m
[32m+[m[32m.data[m[41m[m
[32m+[m[32m    barray: .word 4 f[m[41m[m
[32m+[m[32m    array: .word 3 4 5 #This comment must be ignored[m[41m[m
[32m+[m[41m    [m
[32m+[m[32m.text[m[41m[m
[32m+[m[32m.globl main[m[41m[m
[32m+[m[32mmain:[m[41m[m
[32m+[m[32m  #This comment must be ignored[m[41m[m
[32m+[m[32m  addi $s0, $zero, 100 #this comment needs to be ignored[m[41m[m
[32m+[m[32mloop:[m[41m[m
[32m+[m[32m  add $a0, $s0, $0 #call f with parameter i[m[41m[m
[32m+[m[32m  jal f[m[41m[m
[32m+[m[32m  addi $s0, $v0, 0 #i = f(i)[m[41m[m
[32m+[m[32m  bne $s0, $zero, loop[m[41m[m
[32m+[m[32m  addi $v0, $0, 10[m[41m[m
[32m+[m[32m  syscall[m[41m[m
[32m+[m[32mf:[m[41m[m
[32m+[m[32m  la $t0, array[m[41m[m
[32m+[m[32m  srl $v0, $a0, 1[m[41m[m
   jr $ra[m
\ No newline at end of file[m
[1mdiff --git a/test4.asm b/test4.asm[m
[1mindex 2a2da9e..ed811ce 100644[m
[1m--- a/test4.asm[m
[1m+++ b/test4.asm[m
[36m@@ -1,2 +1,2 @@[m
[31m-.main[m
[32m+[m[32m.main[m[41m[m
 addi $s0, $t6, -20[m
\ No newline at end of file[m
[1mdiff --git a/test51.asm b/test51.asm[m
[1mindex 9a7a4c7..37604ca 100644[m
[1m--- a/test51.asm[m
[1m+++ b/test51.asm[m
[36m@@ -1,13 +1,13 @@[m
[31m-.data[m
[31m-    methodtable: .word function2[m
[31m-    array1: .word 10 20 30[m
[31m-    .text[m
[31m-    .globl main[m
[31m-main:[m
[31m-    addi $a0, $0, 10[m
[31m-    jal function[m
[31m-    la $t0, array3[m
[31m-    lw $t0, 0($t0)[m
[31m-    add $s0, $v0, $t0[m
[31m-    addi $v0, $0, 10[m
[32m+[m[32m.data[m[41m[m
[32m+[m[32m    methodtable: .word function2[m[41m[m
[32m+[m[32m    array1: .word 10 20 30[m[41m[m
[32m+[m[32m    .text[m[41m[m
[32m+[m[32m    .globl main[m[41m[m
[32m+[m[32mmain:[m[41m[m
[32m+[m[32m    addi $a0, $0, 10[m[41m[m
[32m+[m[32m    jal function[m[41m[m
[32m+[m[32m    la $t0, array3[m[41m[m
[32m+[m[32m    lw $t0, 0($t0)[m[41m[m
[32m+[m[32m    add $s0, $v0, $t0[m[41m[m
[32m+[m[32m    addi $v0, $0, 10[m[41m[m
     syscall[m
\ No newline at end of file[m
[1mdiff --git a/test52.asm b/test52.asm[m
[1mindex 0ab306c..8f9d7c0 100644[m
[1m--- a/test52.asm[m
[1m+++ b/test52.asm[m
[36m@@ -1,15 +1,15 @@[m
[31m-.data[m
[31m-.text[m
[31m-function:[m
[31m-    addi $sp, $sp, -4[m
[31m-    sw $ra, 0($sp)[m
[31m-[m
[31m-    la $t0, methodtable[m
[31m-    lw $t0, 0($t0) #address of methodtable[0][m
[31m-    jalr $t0 #jump to that method[m
[31m-    la $t0, array1[m
[31m-    lw $t0, 4($t0)[m
[31m-    add $v0, $v0, $t0[m
[31m-[m
[31m-    lw $ra, 0($sp)[m
[32m+[m[32m.data[m[41m[m
[32m+[m[32m.text[m[41m[m
[32m+[m[32mfunction:[m[41m[m
[32m+[m[32m    addi $sp, $sp, -4[m[41m[m
[32m+[m[32m    sw $ra, 0($sp)[m[41m[m
[32m+[m[41m[m
[32m+[m[32m    la $t0, methodtable[m[41m[m
[32m+[m[32m    lw $t0, 0($t0) #address of methodtable[0][m[41m[m
[32m+[m[32m    jalr $t0 #jump to that method[m[41m[m
[32m+[m[32m    la $t0, array1[m[41m[m
[32m+[m[32m    lw $t0, 4($t0)[m[41m[m
[32m+[m[32m    add $v0, $v0, $t0[m[41m[m
[32m+[m[41m[m
[32m+[m[32m    lw $ra, 0($sp)[m[41m[m
     addi $sp, $sp, 4[m
\ No newline at end of file[m
