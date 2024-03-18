# openFile: 		input is a string containing path to file, then returns file handler
# getRandWord:	 	input is a file handler of format Word1Word2...Wordn where every word is 5 chars long
#			then returns a random letter in that file.
# closeFile:		input is a file handler, close the file with no output.

.globl	openFileReadOnly, closeFile, getRandWord

.data
wordFilePath:	.asciiz		"./words.txt"	# path of file
fileErr:	.asciiz		"File open error"

.text

# For debug purposes
	
main:	la	$a0,	wordFilePath
	jal	openFileReadOnly
	beq	$v0,	-1,	Err1
	move	$s7,	$v0		# store file descriptor in $s7
	move	$a0,	$v0
	li	$a1,	14855
	jal	getRandWord
	move	$s2,	$v0
	# print newline
	li	$v0,	11
	li	$a0,	10
	syscall
	# Print string
	move	$a0,	$s2
	li	$v0,	4
	syscall
	# Close file, end program
	move	$a0,	$s7
	jal	closeFile
	li	$v0,	10
	syscall
Err1:	la	$a0,	fileErr
	li	$v0,	55
	li	$a1,	0
	syscall
	li	$v0,	10
	syscall

#
	
# openFileReadOnly
#
# Input:
# - a0: address of null-terminated string of file path
# Output:
# - v0: file descriptor, or -1 if error

openFileReadOnly:

	# Store $ra, $a0, $a1, $a2 to stack
	addi	$sp, 	$sp, 	-8
	sw	$a1, 	0($sp)
	sw	$a2, 	4($sp)
	
	# open file (descriptor stored in $v0)
	li	$a1,	0	# a1 stores flag: read only
	li	$a2,	0	# a2 stores mode (not applicable for read only)
	li	$v0,	13	# open file syscall code
	syscall
	
	# return $ra, $a0, $a1, $a2 from stack then return to 
	lw	$a1,	0($sp)
	lw	$a2,	4($sp)
	addi	$sp,	$sp,	8
	bge	$v0,	$zero,	noErrOpenFile	# check if file is actually opened
	li 	$v0,	-1
noErrOpenFile:
	jr	$ra
	
# getRandWord:
# Receives input as a file descriptor of a file with words length 5 in the form
# Word1
# Word2
# Word3
# ...
# Wordn
# then returns a 5-character word
#
# Note: file ends with a newline.
# 
# Input:
# - a0: file descriptor (reset to start)
# - a1: Amount of words
# Output:
# - $v0: address of a 5-word character

# NOTE: NOT DONE

# GitHubDemo

getRandWord:
	
	# store arguments in stack
	addi	$sp,	$sp,	-20
	sw	$a0,	0($sp)		# File descriptor
	sw	$a1,	4($sp)		# Word amount
	sw	$s0,	8($sp)
	sw	$s1,	12($sp)
	sw	$s2,	16($sp)
	
	# get random number in range from 0 to #words - 1
	
	# get rand number
	lw	$a1,	4($sp)
	li	$v0,	42
	syscall
	# load this number into $s0
	move	$s0,	$a0
	
	# Allocate space for word, address of first char in $s2
	li	$a0,	6
	li	$v0,	9
	syscall
	move	$s2,	$v0
	
	# choose the ($s0 + 1)th word
	
	# Loop through the first $s0 words
	move	$s1,	$zero
For1:	beq	$s1,	$s0,	Exit1
	lw	$a0,	0($sp)
	move	$a1,	$s2
	li	$a2,	5
	li	$v0,	14
	syscall				# read the word Word
	lw	$a0,	0($sp)
	move	$a1,	$s2
	addi	$a1,	$a1,	5
	li	$a2,	1
	li	$v0,	14
	syscall				# read the newline character
	
	addi	$s1,	$s1,	1
	j	For1
	# Get the intended word, then add \0 at then end
Exit1:	lw	$a0,	0($sp)
	move	$a1,	$s2
	li	$a2,	5
	syscall
	sb	$zero,	5($s2)
	
	# Restore registers and return
	move	$v0,	$s2
	lw	$a0,	0($sp)		# File descriptor
	lw	$a1,	4($sp)		# Word amount
	lw	$s0,	8($sp)
	lw	$s1,	12($sp)
	lw	$s2,	16($sp)
	addi	$sp,	$sp,	20
	jr	$ra
	

# closeFile
#
# Input:
# - a0: file descriptor
# Output:
# - N/A
	
closeFile:
	li	$v0,	16
	syscall
	jr 	$ra

