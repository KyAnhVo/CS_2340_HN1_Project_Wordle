.data

.text

# Enter a letter into the bitmap at square number $a1 and
# return the next square to be edited (3 cases: user presses an alphabet,
# user presses a backspace, and user presses something else)
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
	
	
enterLetterUpper:
	
enterLetterLower:

enterLetterBacks:

.include	"CheckWord.asm"
.include	"IO_Bitmap.asm"

