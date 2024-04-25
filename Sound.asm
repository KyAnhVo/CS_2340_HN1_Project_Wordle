.macro done
li	$v0,	10
syscall
.end_macro
.globl	wrongSound, rightSound

.text
mainDebugSound:
	jal	wrongSound
	jal	rightSound
	done


wrongSound:
	addi	$sp,	$sp,	-16
	sw	$a0,	($sp)
	sw	$a1,	4($sp)
	sw	$a2,	8($sp)
	sw	$a3,	12($sp)
	
	li	$a1,	2000
	li	$a2,	84
	li	$a3,	127
	li	$v0,	33
	
	li	$a0,	60
	syscall
	
	lw	$a0,	($sp)
	lw	$a1,	4($sp)
	lw	$a2,	8($sp)
	lw	$a3,	12($sp)
	addi	$sp,	$sp,	16
	jr	$ra
	
rightSound:
	addi	$sp,	$sp,	-16
	sw	$a0,	($sp)
	sw	$a1,	4($sp)
	sw	$a2,	8($sp)
	sw	$a3,	12($sp)
	
	li	$a1,	2000
	li	$a2,	1
	li	$a3,	127
	li	$v0,	31
	
	li	$a0,	60
	syscall
	li	$a0,	64
	syscall
	li	$a0,	67
	syscall
	li	$a0,	72
	syscall
	
	lw	$a0,	($sp)
	lw	$a1,	4($sp)
	lw	$a2,	8($sp)
	lw	$a3,	12($sp)
	addi	$sp,	$sp,	16
	jr	$ra
