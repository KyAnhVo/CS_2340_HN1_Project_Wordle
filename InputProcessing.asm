# Tools -> Keyboard and Display MMIO Simulator
# Confirm that the middle bar says Fixed transmitter delay, select using slider

.globl	isUppercase, isLowercase, isBackspace, getCharInput, makeUppercase

.data
ctrlReg:	.word	0xffff0000
dataReg:	.word	0xffff0004

.text
IOkbMainDebug:
	jal	getCharInput
	
	move	$a0,	$v0
	li	$v0,	11
	syscall
	
	li	$v0,	10
	syscall

# checks if given ascii code is backspace
# input:
# - $a0: char
# output:
# - $v0: is backspace ? 1 : 0

isBackspace:
	subi	$a0,	$a0,	8
	bne	$a0,	$0,	ibsF
	move	$v0,	$zero
	j	endifIbs
ibsF:	li	$v0,	1
endifIbs:
	addi	$a0,	$a0,	8
	jr	$ra
	

# checks if given ascii code is upercase
# input:
# - $a0: char
# output:
# - $v0: is uppercase ? 1 : 0

isUppercase:
	li	$t0,	65
	blt	$a0,	$t0,	notUpU
	li	$t0,	90
	bgt	$a0,	$t0,	notUpU
	li	$v0,	1
	jr	$ra
notUpU:	move	$v0,	$zero
	jr	$ra
	
# checks if given ascii code is lowercase
# input:
# - $a0: char
# output:
# - $v0: is lowercase ? 1 : 0

isLowercase:
	li	$t0,	97
	blt	$a0,	$t0,	notUpL
	li	$t0,	122
	bgt	$a0,	$t0,	notUpL
	li	$v0,	1
	jr	$ra
notUpL:	move	$v0,	$zero
	jr	$ra

# if char is alphabet, return its uppercase counterpart
# else return -1
# input:
# - $a0: ascii code
# output:
# - $v0: ($a0 is alphabet) ? (make $a0 uppercase) : -1

makeUppercase:
	# stack stuffs
	addi	$sp,	$sp,	-4
	sw	$ra,	($sp)
	
	# Check if $a0 is lowercase
	jal	isLowercase
	beq	$v0,	$0,	notLoC
	
	# $a0 is lowercase
	subi	$v0,	$a0,	32
	j	EIfMU
	# $a0 is not lowecase
notLoC:	
	# Check if $a0 is uppercase
	jal	isUppercase
	beq	$v0,	$0,	notUpC
	
	# $a0 is uppercase
	move	$v0,	$a0
	j	EIfMU
	
	# $a0 is neither
notUpC:	li	$v0,	-1
	
	# endif
EIfMU:	lw	$ra,	($sp)
	addi	$sp,	$sp,	4
	jr	$ra
		
# wait and get ascii code from keyboard simulator
# input:
# - None
# output:
# - $v0: ascii code of char entered

getCharInput:
	# wait for ctrlReg to turn to 1
waitL:	lw	$v0,	ctrlReg
	lw	$v0,	($v0)
	beq	$v0,	$0,	waitL
	# set $v0 to whatever it is in data register
	lw	$v0,	dataReg
	lw	$v0,	($v0)
	jr	$ra
