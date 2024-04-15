.globl		checkWord

.data
rightPos:	.byte		94		# ^
wrongPos:	.byte		42		# *
noChar:		.byte		88		# X
answerStr:	.asciiz		"XXXXX"		# For answer

# from here are datas for debug.
debugCorr:	.asciiz		"realm"
debugInp:	.asciiz		"raile"
debugMssg1:	.asciiz		"Before"
debugMssg2:	.asciiz		"After"

.text

# obviously debug function.
mainDebugCheckWord:
	la	$s0,	debugInp
	la	$s1,	debugCorr
	move	$a0,	$s0
	move	$a1,	$s1
	jal	checkWord
	move	$s2,	$v0
	
	move	$a0,	$s1
	li	$v0,	4
	syscall
	
	li	$a0,	10
	li	$v0,	11
	syscall
	
	move	$a0,	$s0
	li	$v0,	4
	syscall
	
	li	$a0,	10
	li	$v0,	11
	syscall
	
	move	$a0,	$s2
	li	$v0,	4
	syscall
	
	li	$a0,	10
	li	$v0,	11
	syscall
	
	li	$v0,	10
	syscall
	

# checkWord: Gets 2 words, check wordle correspondence
#
# Input
# - $a0: address of nullterminated string of length 5 for input word
# - $a1: address of nullterminated string of length 5 for correct word
# Output:
# - $v0: address of ullterminated string of length 5 that indicates the result where
#  	^: correct position
#	*: in word, wrong position
#	X: not in word
#
#
# Idea: (Assume $a0 is inputWord and $a1 is correctWord)
# char* checkWord(char* inputWord, char* correctWord) {
# |	char* answerStr = new char; // just for syntax purpose
# |	for (int i = 0; i < 5; i++) {			F1
# |	|	int notInWord = 1;
# |	|	t0 = correctWord + i;
# |	|	if (*inputWord == *t0) {		I1
# |	|	|	*answerStr = '^';
# |	|	|	continue;
# |	|	}
# |	|	for (int j = 0; j < 5; j++) {		F2
# |	|	|	t1 = correctWord + j;
# |	|	|	if (*inputWord == *t1) {	I2
# |	|	|	|	*answerStr = '*';
# |	|	|	|	notInWord = 0;
# |	|	|	|	break;
# |	|	|	}
# |	|	}
# |	|	if (notInWord)				I3
# |	|		*answerStr = 'X';
# |	|	inputWord = inputWord + 1;
# |	|	answerStr = answerStr + 1
# |	}
# |	return answerStr;
# }
#
# Let $s0 be i, $s1 be j, $s2 be notInWord, and $s3 be 5 (loop comparision stuff)
# Note: This is pass by value so registers $a0 and $a1 WILL be changed.

checkWord:

	# Subroutine Stuffs
	addi	$sp,	$sp,	-24
	sw	$s0,	0($sp)
	sw	$s1,	4($sp)
	sw	$s2,	8($sp)
	sw	$s3,	12($sp)
	sw	$t0,	16($sp)
	sw	$t1,	20($sp)
	
	# Let $s0 be i, $s1 be j, $s2 be notInWord, and $s3 be 5 (loop comparision stuff)
	add	$s0,	$zero,	$zero
	add	$s1,	$zero,	$zero
	addi	$s2,	$zero,	1		# int notInWord = 1;
	addi	$s3,	$zero,	5
	
	#load address of answerStr into return reg $v0
	la	$v0,	answerStr
	
L1:	# Outside loop
	addiu	$s2,	$zero,	1
	add	$t1,	$a1,	$s0
	lb	$t0,	($a0)
	lb	$t1,	($t1)
	bne	$t1,	$t0,	I1F
I1T:	lb	$t0,	rightPos
	sb	$t0,	($v0)
	j	L1Cond
I1F:	add	$s1,	$zero,	$zero	# reset loop condition for inner loop

L2:	# Inside loop
	add	$t1,	$a1,	$s1
	lb	$t1,	($t1)
	lb	$t0,	($a0)
	bne	$t0,	$t1,	I2F
I2T:	lb	$t0,	wrongPos
	sb	$t0,	($v0)
	add	$s2,	$zero,	$zero
	j	L2E
I2F:	nop
L2Cond:	addi	$s1,	$s1,	1
	bne	$s1,	$s3,	L2
	
L2E:	# Inner loop end
	beq	$s2,	$zero,	I3F
I3T:	lb	$t0,	noChar
	sb	$t0,	($v0)
I3F:	nop
L1Cond:	addi	$a0,	$a0,	1
	addi	$v0,	$v0,	1
	addi	$s0,	$s0,	1
	bne	$s0,	$s3,	L1
	
L1E:	# End outside loop
	la	$v0,	answerStr

	# Subroutine stuffs
	lw	$s0,	0($sp)
	lw	$s1,	4($sp)
	lw	$s2,	8($sp)
	lw	$s3,	12($sp)
	lw	$t0,	16($sp)
	lw	$t1,	20($sp)
	addi	$sp,	$sp,	24
	jr	$ra
	
	
# Note on for/if label notation:
# For:
# 	Ln:  	for loop #n
#	LnE: 	end for loop #n
#	LnCond:	update condition and check for for loop #n
# If:
# 	InT: if #n is true
#	InF: if #n is false
