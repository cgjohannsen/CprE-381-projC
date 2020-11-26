#
# Second part of the Lab 3 test program
# Include support for beq, bne, j, jal, jr
#

# data section
.data
arr:.word 0, 1, 2, 3

# code/instruction section
.text

# Loads
lui $1,4097
sll  $0, $0, 0
sll  $0, $0, 0
sll  $0, $0, 0
lw   $2, 4($1)
sll  $0, $0, 0
sll  $0, $0, 0
sll  $0, $0, 0
addi $3, $2, 3
sll  $0, $0, 0
sll  $0, $0, 0
sll  $0, $0, 0
sw   $3, 8($1)
lw   $4, 8($1)

# Arithmetic
addi  $1,  $0,  1 		# Place “1” in $1
addi  $2,  $0,  2		# Place “2” in $2
addi  $3,  $0,  3		# Place “3” in $3
addi  $10, $0,  10		# Place “10” in $10
sll  $0, $0, 0
add   $11, $1,  $2		# $11 = $1 + $2
sll  $0, $0, 0
sll  $0, $0, 0
sll  $0, $0, 0
sub   $12, $11, $3 		# $12 = $11 - $3

# slt instructions
slt   $16, $1, $2
slt   $16, $2, $1
slti  $16, $2, 1
slti  $16, $2, 3
sltiu $16, $2, 1
sltiu $16, $2, 3
sltu  $16, $1, $2
sltu  $16, $2, $1

# Shifts
addi $1, $0, 15
lui  $2, 0xFFFF
sll  $0, $0, 0
sll  $0, $0, 0
sll  $17, $1, 31 
srl  $17, $2, 31
sra  $17, $2, 31
sllv $17, $1, $10
srlv $17, $2, $10
srav $17, $2, $10

# Logical operators
# Each operation acts as a truth table
addi $1, $0, 10
addi $2, $0, 12
sll  $0, $0, 0
sll  $0, $0, 0
sll  $0, $0, 0
and  $3, $1, $2
andi $3, $1, 12
nor  $3, $1, $2
xor  $3, $1, $2
xori $3, $1, 12
or   $3, $1, $2
ori  $3, $1, 12

# Control flow
j testBEQ
sll  $0, $0, 0

routine: and $t1, $t1, $zero
sll  $0, $0, 0
sll  $0, $0, 0
sll  $0, $0, 0
addi $t1, $t1, 15
sll  $0, $0, 0
sll  $0, $0, 0
jr $ra
sll  $0, $0, 0

testJAL: jal routine
sll  $0, $0, 0
j END
sll  $0, $0, 0

testBNE: and $t1, $t1, $zero
sll  $0, $0, 0
sll  $0, $0, 0
and $t2, $t2, $zero
sll  $0, $0, 0
sll  $0, $0, 0
addi $t1, $t1, 1
addi $t2, $t2, 2
sll  $0, $0, 0
sll  $0, $0, 0
sll  $0, $0, 0
bne $t1, $t2, testJAL # Check bne
sll  $0, $0, 0

testBEQ: and $t1, $t1, $zero
and $t2, $t2, $zero
sll  $0, $0, 0
sll  $0, $0, 0
addi $t1, $t1, 1
addi $t2, $t2, 1
sll  $0, $0, 0
sll  $0, $0, 0
sll  $0, $0, 0
beq $t1, $t2, testBNE # Check beq
sll  $0, $0, 0

END: addi  $2,  $0,  10         # Place "10" in $v0 to signal an "exit" or "halt"
sll  $0, $0, 0
sll  $0, $0, 0
sll  $0, $0, 0
syscall                         # Actually cause the halt
