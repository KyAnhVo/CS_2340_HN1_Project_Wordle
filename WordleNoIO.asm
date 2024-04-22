# Demo low_grade wordle no I/O

.data
correctPrompt:  .asciiz         "\nCorrect! "
errorMessage:   .asciiz         "Please enter 5 characters\n"
userInput:	.asciiz		"abcde"
guess:		.asciiz		"guess:\n"
explainSymbol:	.asciiz		"Welcome to Wordle! ^ represents right location, * represents right word but wrong location, and X means not in word at all.\n"
ansPrompt:	.asciiz		"\nThe answer is: "
seperator:	.asciiz		"------------------"
buffer:		.space		100		# safety precaussion
offset:         .word           0

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
	move $t6, $v0
	li $t8, 0
	li $t9, 5
	
CheckLengthLoop: # check if user input is exactly 5 characters long; if not, ask for input again without increasing the count of total used attempts
	lb $t3, 0($v0)
	beq $t3, $zero, GetInputAgain
	addi $v0, $v0, 1
	addi $t8, $t8, 1
	beq $t8, $t9, AfterLengthCheck
	bne $t8, $t9, CheckLengthLoop

GetInputAgain:
	# Print Error Message
	li $v0, 4
	la $a0, errorMessage
	syscall
	
	# Go back and try to get valid input again
	j LoopGetInput

AfterLengthCheck:
	move	$s0,	$t6
		
	# get checker string
	move	$a0,	$s0
	move	$a1,	$s1
	jal	checkWord
	
CheckGuess: # Check if the guess is already correct, even before all the attempts are finished. If so, quit the loop early as no more attempts are needed
	li $t6, 0
	sw $t6, offset
	li $t9, 5
	move $s7, $v0
CheckerLoop: # Loop through each character and see if the symbol is "^", meaning that it was guessed properly
	lb $t7, 0($v0)
	lb $t8, rightPos
	bne $t7, $t8, NotFullyGuessed 
	
	addi $t6, $t6, 1
	addi $v0, $v0, 1
	sw $t6, offset
	beq $t6, $t9, GuessedCorrectly
	bne $t6, $t9, CheckerLoop

GuessedCorrectly:
	li $v0, 4
	la $a0, correctPrompt
	syscall
	
	j Done

NotFullyGuessed:
	# print newline
	li	$a0,	'\n'
	li	$v0,	11
	syscall
	
	# print checker string withe enhanced format
	
	la	$a0,	($s7)
	jal	getStrDisplay
	move	$t0,	$a0
	move	$a0,	$v0
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
Done:	
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
