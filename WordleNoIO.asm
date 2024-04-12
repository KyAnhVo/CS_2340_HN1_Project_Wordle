# Demo low_grade wordle no I/O

.data
correctWord:	.asciiz		"abcde"
userInput:	.asciiz		"abcde"
guess:		.asciiz		"guess:"
buffer:		.space		100		# safety precaussion

.text

main:

getUserInput:
	addi	$sp,	$sp,	8
	sw	$a0,	0($sp)
	sw	$s0,	4($sp)
	
	
	# Print "guess: "
	la	