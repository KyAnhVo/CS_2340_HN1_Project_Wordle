# Demo low_grade wordle no I/O

.data
correctPrompt:  		.asciiz		"\nCorrect! "
errorMessageNotEnoughChar:	.asciiz		"\nPlease enter 5 characters.\n"
errorMessageSymbolInput:	.asciiz		"\nInput can only be alphabet.\n"
userInput:			.asciiz		"abcde"
guess:				.asciiz		"guess:\n"
explainSymbol:			.asciiz		"Welcome to Wordle! green represents right location, yellow represents right word but wrong location, and grey means not in word at all.\n"
ansPrompt:			.asciiz		"\nThe answer is: "
seperator:			.asciiz		"------------------"
offset:         		.word		0
allright:			.asciiz		"^^^^^"
correctGuess:			.asciiz 	"\nCorrect!"

.text

# Note: user input stored in $s0, correct word stored in $s1, checker in $s2, guess time current in $s3, guess time max in $s4
main:
	jal	allocateBitmapHeapMemory
	li	$a0,	0x10040000
	jal	resetCanvas
	li	$s3,	0
	li	$s4,	5
	# get random word stored in $s0
	la	$a0,	wordFilePath
	jal	openFileReadOnly
	move	$a0,	$v0
	li	$a1,	14854
	jal	getRandWord
	move	$s1,	$v0
	
	# turn the whole checker string into its uppercased version
	addi	$t9,	$s1,	5
LUOg:	lb	$t6,	($s1)
	andi	$t6,	$t6,	0x000000ff
	subi	$t6,	$t6,	32
	sb	$t6,	($s1)
	addi	$s1,	$s1,	1
	bne	$s1,	$t9,	LUOg
	subi	$s1,	$s1,	5
	
	li $v0, 4
	move $a0, $s1
	syscall
	
	# print newline
	li	$a0,	'\n'
	li	$v0,	11
	syscall
	
	# Print explain prompt
	la	$a0,	explainSymbol
	li	$v0,	4
	syscall


LoopGetInput:	
	# get user input stored in $s1
	jal	input
	move 	$t6,	$v0	# $t6 == input address
	li 	$t8,	0
	li 	$t9,	5
	li	$s0,	10	# newline ascii code

# check if user input is exactly 5 characters long, and if those chars are alphabets
#if not, ask for input again without increasing the count of total used attempts
CheckLengthLoop:
	lb 	$t3, 	0($t6)
	andi	$t3,	$t3,	0x000000ff
	
	# Check if character is null or newline
	beq 	$t3, 	$zero, 	GetInputAgainNotEnoughChar
	beq	$t3,	$s0,	GetInputAgainNotEnoughChar
	
	# check if user inputs is alphabet
	move	$a0,	$t3
	jal	makeUppercase
	addi	$v0,	$v0,	1
	beq	$v0,	$zero,	GetInputAgainSymbolInput
	
	# put uppercase-d version of char back into address
	subi	$v0,	$v0,	1
	sb	$v0,	($t6)
	
	addi 	$t6, 	$t6, 	1
	addi 	$t8, 	$t8, 	1
	beq 	$t8, 	$t9, 	AfterLengthCheck
	bne 	$t8, 	$t9, 	CheckLengthLoop

GetInputAgainNotEnoughChar:
	# Print Error Message
	li $v0, 4
	la $a0, errorMessageNotEnoughChar
	syscall
	
	# Go back and try to get valid input again
	j LoopGetInput

GetInputAgainSymbolInput:
	# Print Error Message
	li $v0, 4
	la $a0, errorMessageSymbolInput
	syscall
	
	# Go back and try to get valid input again
	j LoopGetInput

AfterLengthCheck:
	subi	$t6,	$t6,	5
	move	$s0,	$t6
	# get checker string
	move	$a0,	$s0
	move	$a1,	$s1
	jal	checkWord
	move 	$s7, 	$v0
	
	la $a0, userInput
	jal console_display
	la $a0, ($s7)
	jal console_display
	
	move	$a0,	$s0
	move	$a3,	$s7
	li	$a1,	0x10040000
	move	$a2,	$s3
	jal	printWordWithCheck
	
CheckGuess: # Check if the guess is already correct, even before all the attempts are finished. If so, quit the loop early as no more attempts are needed
	li $t6, 0
	sw $t6, offset
	li $t9, 5
CheckerLoop: # Loop through each character and see if the symbol is "^", meaning that it was guessed properly
	lb $t7, 0($s7)
	lb $t8, rightPos
	bne $t7, $t8, NotFullyGuessed 
	
	addi $t6, $t6, 1
	addi $s7, $s7, 1
	sw $t6, offset
	beq $t6, $t9, GuessedCorrectly
	bne $t6, $t9, CheckerLoop

GuessedCorrectly:
# If guessed correctly, the prompt "Correct!"
# Will be displayed, and the PC will jump towards the end of the program
# since there are no more attempts needed
	
	j Done

NotFullyGuessed:

	move	$a0,	$s0
	
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
	jal wrongSound
	
	bne	$s3,	$s4,	LoopGetInput

# Done
Done:	
	li	$a1,	0x10040000
	la	$a3,	allright
	li	$a2,	5
	move	$a0,	$s1
	jal	printWordWithCheck
	
	la $a0, correctGuess
	jal print_final_prompt
	la $a0, ansPrompt
	jal print_final_prompt
	move $a0, $s1
	jal print_final_prompt
	
	jal rightSound
	
	li $v0,	10
	syscall
	
print_final_prompt:
	li $v0, 4
	syscall
	jr $ra

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
	
console_display:
	addi $sp, $sp, -16
	sw $a0, ($sp)
	sw $ra, 4($sp)
	sw $s0, 8($sp)
	sw $t0, 12($sp)
	
	move $s0, $a0
	
	li $v0, 11
	li $a0, '\n'
	syscall
	
	move $a0, $s0
	jal	getStrDisplay
	move $a0, $v0
	li	$v0,	4
	syscall
	
	lw $a0, ($sp)
	lw $ra, 4($sp)
	lw $s0, 8($sp)
	lw $t0, 12($sp)
	addi $sp, $sp, 16
	
	jr $ra 

.include	"ReadFile.asm"
.include	"CheckWord.asm"
.include	"IO_Bitmap.asm"
.include	"InputProcessing.asm"
.include	"Display.asm"
.include 	"Sound.asm"
