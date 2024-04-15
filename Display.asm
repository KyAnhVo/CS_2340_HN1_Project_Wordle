.globl getStrDisplay

.data
strDisplay:	.asciiz		"+-+-+-+-+-+\n|x|x|x|x|x|\n+-+-+-+-+-+"
strTest:	.asciiz		"testi"

# Print string
# Input:
# $a0: address to first char of null-terminated string to print
# Output:
# $v0: str
# Note: Please use as read-only since multiple displays use the same address with already-set-up display system.

.text
mainDebugDisplay:
	la	$a0,	strTest
	jal	getStrDisplay
	move	$t0,	$a0
	move	$a0,	$v0
	li	$v0,	4
	syscall
	li	$v0,	10
	syscall

getStrDisplay:
	addi	$sp,	$sp,	-16
	sw	$s0,	0($sp)
	sw	$s1,	4($sp)
	sw	$s2,	8($sp)
	sw	$s3,	12($sp)
	
	la	$v0,	strDisplay
	li	$s0,	0
	move	$s1,	$v0
	addi	$s1,	$s1,	13
	move	$s2,	$a0
	li	$s3,	5
	
L1Disp:	lb	$t0,	($s2)
	sb	$t0,	($s1)
	addi	$s2,	$s2,	1
	addi	$s1,	$s1,	2
	addi	$s0,	$s0,	1
	bne	$s0,	$s3,	L1Disp
	
	lw	$s0,	0($sp)
	lw	$s1,	4($sp)
	lw	$s2,	8($sp)
	lw	$s3,	12($sp)
	addi	$sp,	$sp,	16
	jr 	$ra
	
