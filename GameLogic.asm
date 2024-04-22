.data

errorInp:	.asciiz		"Please type alphabet (or backspace)"

.text

# Enter a letter into the bitmap at square number $a2 and
# return -1 or 0 or 1 as described below
# input:
# - $a0: ascii code of char
# - $a1: starting address of bitmap buffer
# - $a2: current square number
# - $a3: string to be edited
# ouput:
# - $v0: -1 if backspace, 1 if alphabet, 0 otherwise
 
enterLetter:
	# stack stuff
	addi	$sp,	$sp,	-24
	sw	$a0,	0($sp)
	sw	$a1,	4($sp)
	sw	$a2,	8($sp)
	sw	$a3,	12($sp)
	sw	$ra,	16($sp)
	sw	$t0,	20($sp)
	
	# calculate address of byte to be edited in the string store in $t0
	# note: if backspace, -1. if char or error: no change
	li	$t0,	5
	div	$a2,	$t0
	mfhi	$t0
	add	$t0,	$t0,	$a3
	
	# if branch
	jal	isBackspace
	bne	$v0,	$zero,	enterLetterBacks
	jal	isUppercase
	bne	$v0,	$zero,	enterLetterUpper
	jal	isLowercase
	bne	$v0,	$zero,	enterLetterLower
	
	# print error then return
	la	$a0,	errorInp
	li	$a1,	1
	li	$v0,	55
	syscall
	li	$v0,	0
	j	enterLetterReturn
enterLetterUpper:
	jal	makeUppercase
	move	$v0,	$a0
	sw	$a0,	($t0)
	lw	$a3,	pre
	jal	drawChar
	li	$v0,	1
	j	enterLetterReturn
enterLetterLower:
	sw	$a0,	($t0)
	lw	$a3,	pre
	jal	drawChar
	li	$v0,	1
	j	enterLetterReturn
enterLetterBacks:
	li	$v0,	-1
	beq	$a2,	$zero,	enterLetterReturn	# if square 0, cant go back
	subi	$a2,	$a2,	1
	li	$a0,	91
	lw	$a3,	pre
	jal	drawChar
	li	$v0,	-1
	j	enterLetterReturn
enterLetterReturn:
	lw	$a0,	0($sp)
	lw	$a1,	4($sp)
	lw	$a2,	8($sp)
	lw	$a3,	12($sp)
	lw	$ra,	16($sp)
	lw	$t0,	20($sp)
	addi	$sp,	$sp,	24
	jr	$ra

.include	"CheckWord.asm"
.include	"IO_Bitmap.asm"

