#
# Bubble sort algorithm
#

# data 
.data
arr:.word 13, 54, 8, 2, 101, 67, 20

# code
.text

main: 
# $t0 as i, $t1 as j, $t3 as temp, $t5 as address of arr,
# $t8, $t9 flag registers, $s0 with n-i-1
# $s1, $s2 as arr elements

lui $t5, 0x1001

outer: 	slti $t8, $t0, 7 # CHANGE TO LENGTH OF ARR
	sll $0, $0, 0
	sll $0, $0, 0
	sll $0, $0, 0
	beq $zero, $t8, END # while i < n
	sll $0, $0, 0

inner:	li $s0, 6 # n-1 CHANGE WHEN ALTERING ARR
	sll $0, $0, 0
	sll $0, $0, 0
	sll $0, $0, 0
	sub $s0, $s0, $t0 # $t9 = (n-1) - i
	sll $0, $0, 0
	sll $0, $0, 0
	sll $0, $0, 0
	slt $t9, $t1, $s0
	sll $0, $0, 0
	sll $0, $0, 0
	sll $0, $0, 0
	beq $zero, $t9, endOuter # while j < n-i-1
	sll $0, $0, 0

	lw $s1, 0($t5) # arr[j]
	lw $s2, 4($t5) # arr[j+1]
	sll $0, $0, 0
	sll $0, $0, 0
	sll $0, $0, 0
	slt $k0, $s2, $s1 # if arr[j] > arr[j+1]
	sll $0, $0, 0
	sll $0, $0, 0
	sll $0, $0, 0
	bne $k0, $zero, swap
	sll $0, $0, 0

endInner: 
	addi $t1, $t1, 1
	addi $t5, $t5, 4
	sll $0, $0, 0
	j inner
	sll $0, $0, 0

swap: 	lw $t3, 0($t5) # temp = arr[j]
	sw $s2, 0($t5) # arr[j] = arr[j+1]
	sll $0, $0, 0
	sll $0, $0, 0
	sw $t3, 4($t5) # arr[j+1] = temp
	j endInner
	sll $0, $0, 0

endOuter: 
	addi $t0, $t0, 1
	li $t1, 0
	lui $t5, 0x1001
	sll $0, $0, 0
	j outer
	sll $0, $0, 0
	
END: 
	addi $2, $0, 10 # Place "10" in $v0 to signal an "exit" or "halt"
	sll $0, $0, 0
	sll $0, $0, 0
	sll $0, $0, 0
	syscall    
