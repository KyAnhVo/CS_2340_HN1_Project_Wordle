# Demo low_grade wordle no I/O

.data
userInput:	.asciiz		"abcde"
guess:		.asciiz		"guess:\n"
explainSymbol:	.asciiz		"^ is right location, * is wrong location, X is not in word.\n"
ansPrompt:	.asciiz		"Answer: "
seperator:	.asciiz		"------------------"
buffer:		.space		100		# safety precaussion

.text

# Note: user input stored in $s0, correct word stored in $s1, checker in $s2, guess time current in $s3, guess time max in $s4
main:
	li	$s3,	0
	li	$s4,	4
	# get random word stored in $s0
	la	$a0,	wordFilePath
	jal	openFileReadOnly
	move	$a0,	$v0
	li	$a1,	14854
	jal	getRandWord
	move	$s1,	$v0
	# Print explain prompt
	la	$a0,	explainSymbol
	li	$v0,	4
	syscall
LoopGetInput:	
	
	# get user input stored in $s1
	jal	input
	move	$s0,	$v0
	
	# get checker string
	move	$a0,	$s0
	move	$a1,	$s1
	jal	checkWord
	move	$s2,	$v0

	# print newline
	li	$a0,	'\n'
	li	$v0,	11
	syscall
	
	# print checker string
	move	$a0,	$s2
	li	$v0,	4
	syscall
	
	# print newline
	li	$a0,	'\n'
	li	$v0,	11
	syscall
	
	# print seperator
	la	$a0,	seperator
	li	$v0,	4
	syscall
	
	# print newline
	li	$a0,	'\n'
	li	$v0,	11
	syscall
	
	addi	$s3,	$s3,	1
	bne	$s3,	$s4,	LoopGetInput

# Done
	
	la	$a0,	ansPrompt
	li	$v0,	4
	syscall
	
	move	$a0,	$s1
	li	$v0,	4
	syscall
	
	li	$v0,	10
	syscall
	
	
# address of input in $v0
input:	
	addi	$sp,	$sp,	-8
	sw	$a0,	0($sp)
	sw	$a1,	4($sp)
	# Get user input
	la	$a0,	userInput
	li	$a1,	6
	li	$v0,	8
	syscall
	# store input address at $v0, return register, jump to callee
	move	$v0,	$a0
	lw	$a0,	0($sp)
	lw	$a1,	4($sp)
	addi	$sp,	$sp,	8
	jr	$ra
	
.include	"ReadFile.asm"
.include	"CheckWord.asm"
.include	"Display.asm"
