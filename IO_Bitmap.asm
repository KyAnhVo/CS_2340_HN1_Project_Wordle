# To use Bitmap:
# datas for bitmap display
# Note:
# Tools -> Bitmap Display
#
# In Bitmap Display extension, set:
# - Unit Width/Height in Pixels to 8.
# - Display Width in Pixels to 512, Display Height in Pixels to 512
# - Base address for display to 0x10040000 (heap).
# And then press "Reset" then press "Connect to MIPS" before doing anything
# Note: Please run function allocateBitmapHeapMemory first thing before using any additional heap memory
# since bitmap display extension is set to such that its memory for DMA is the first address in the heap.

.globl right, wrong, none, pre, allocateBitmapHeapMemory, blacken, drawChar

.data

# Color codes

right:		.word	0x00228b22	# correct position,	green
wrong:		.word	0x00ffff00	# wrong position,	yellow
none:		.word	0x00a9a9a9	# not in word,		grey
pre:		.word	0x00ffffff	# before check,		white
checkerDebug:	.asciiz	"^^X*X"
inputDebug:	.asciiz	"BCDEF"

# Character chart, so each 2 words represent how to draw a char in a 8x8 square
# so a 0 in binary means no draw and 1 means draw
#
# Example:
# Imagine drawing a 8x8 square with 0xff8181b9, 0xa9bd81ff (1 is black, 0 is background color)
#
# 1 1 1 1 1 1 1 1	ff
# 1 0 0 0 0 0 0 1	81
# 1 0 0 0 0 0 0 1	81
# 1 0 1 1 1 0 0 1	b9
# 1 0 1 0 1 0 0 1	a9
# 1 0 1 1 1 1 0 1	bd
# 1 0 0 0 0 0 0 1	81
# 1 1 1 1 1 1 1 1	ff
#
# Note: chart contains 26 chars + a blank square at the end.

character:
	.word	0xff8181b9,	0xa9bd81ff	# A
	.word	0xff81a1b9,	0xa9b981ff	# B
	.word	0xff81bda1,	0xa1bd81ff	# C
	.word	0xff8189b9,	0xa9bd81ff	# D
	.word	0xff81b9a9,	0xb1b981ff	# E
	.word	0xff819991,	0xb99181ff	# F
	.word	0xff81b9a9,	0xb98999ff	# G
	.word	0xff81a1a1,	0xb9a981ff	# H
	.word	0xff819181,	0x919181ff	# I
	.word	0xff819181,	0x9191a1ff	# J
	.word	0xff81a1a9,	0xb1a981ff	# K
	.word	0xff81a1a1,	0xa1b181ff	# L
	.word	0xff8181fd,	0xd5d581ff	# M
	.word	0xff8181b9,	0xa9a981ff	# N
	.word	0xff8181b9,	0xa9b981ff	# O
	.word	0xff8181b9,	0xa9b9a1ff	# P
	.word	0xff8181b9,	0xa9b989ff	# Q
	.word	0xff8181b9,	0xa9a181ff	# R
	.word	0xff81b1a1,	0xb191b1ff	# S (looks a tat ugly)
	.word	0xff8191b9,	0x919981ff	# T
	.word	0xff8181a9,	0xa9b981ff	# U
	.word	0xff8181a9,	0xa99181ff	# V
	.word	0xff8181c5,	0xd5fd81ff	# W
	.word	0xff8181a9,	0x91a981ff	# X
	.word	0xff8181a9,	0xa991a1ff	# Y
	.word	0xff81bd89,	0x91bd81ff	# Z
	.word	0xff818181,	0x818181ff	# Blank square 26

# address of square, which means big square #x's top left corner
# is at square unit squareAdress[x] and big square ranges from
# 0 to 19 (4 guesses, 5 words per guess)

squareAddress:
	.word	520, 528, 536, 544, 552
	.word	1032, 1040, 1048, 1056, 1064
	.word	1544, 1552, 1560, 1568, 1576
	.word	2056, 2064, 2072, 2080, 2088
	.word	2568, 2576, 2584, 2592, 2600
	.word	3080, 3088, 3096, 3104, 3112

.text
mainDebug:
	jal	allocateBitmapHeapMemory
	move	$s0,	$v0
	
	move	$a1,	$s0
	la	$a0,	inputDebug
	li	$a2,	4
	la	$a3,	checkerDebug
	jal	printWordWithCheck
	
	li	$v0,	10
	syscall

# allocateBitmapBuffer
# input:
# - None
# output:
# - $v0: address of first byte of heap memory allocated
#
# Note: Please run function allocateBitmapHeapMemory first thing before using any additional heap memory
# since bitmap display extension is set to such that its memory for DMA is.

allocateBitmapHeapMemory:
	addi	$sp,	$sp,	-4
	sw	$a0,	0($sp)
	li	$a0,	4096		# (512 / 16) * (1024 / 16)
	sll	$a0,	$a0,	2	# shift left 2 since each pixel has size 4 bytes
	li	$v0,	9		# allocate heap memory
	syscall
	lw	$a0,	0($sp)
	addi	$sp,	$sp,	4
	jr	$ra

# reset the whole canvas into all blank squares
# Input:
# - $a0: starting address of bitmap
# Output:
# - None

resetCanvas:
	# stack stuff
	addi	$sp,	$sp,	-24
	sw	$a0,	($sp)
	sw	$a1,	4($sp)
	sw	$a2,	8($sp)
	sw	$a3,	12($sp)
	sw	$ra,	16($sp)
	sw	$s0,	20($sp)
	
	# setup
	move	$a1,	$a0
	li	$a0,	91
	li	$a2,	25
	lw	$a3,	pre
resetCanvasLoop:
	addi	$a2,	$a2,	-1
	jal	drawChar
	bne	$a2,	$zero,	resetCanvasLoop

	li	$s0,	30
	lw	$a3,	right	
	li	$a2,	25
resetCanvasLoop2:
	jal	drawChar
	addi	$a2,	$a2,	1
	bne	$a2,	$s0,	resetCanvasLoop2

	# restore reg and return
	lw	$a0,	($sp)
	lw	$a1,	4($sp)
	lw	$a2,	8($sp)
	lw	$a3,	12($sp)
	lw	$ra,	16($sp)
	lw	$s0,	20($sp)
	addi	$sp,	$sp,	24
	jr	$ra
	
	

# Change the whole canvas to black
# Input:
# - $a0: starting address of bitmap
# Output:
# - None

blacken:
	addi	$sp,	$sp,	-12
	sw	$s0,	($sp)
	sw	$s1,	4($sp)
	sw	$t0,	8($sp)
	# setup
	li	$s0,	2048
	sll	$s0,	$s0,	2
	add	$s0,	$s0,	$a0
	move	$s1,	$zero			# black
	move	$t0,	$a0
	
	# loop to draw
blackL:	sw	$s1,	($t0)
	addi	$t0,	$t0,	4
	bne	$t0,	$s0, 	blackL
	
	lw	$s0,	($sp)
	lw	$s1,	4($sp)
	lw	$t0,	8($sp)
	addi	$sp,	$sp,	12
	jr	$ra

# drawChar
# input:
# - $a0: ascii code of char (must be between A (65 or 0x41) and Z (90 or 0x5a) + 91 for blank)
# - $a1: starting address of bitmap buffer
# - $a2: square number (between 0 and 29)
# - $a3: color code (right, wrong, none, pre)
# output:
# - None

drawChar:
	# store registers on stack
	addi	$sp,	$sp,	-32
	sw	$a0,	0($sp)
	sw	$a1,	4($sp)
	sw	$a2,	8($sp)
	sw	$a3,	12($sp)
	sw	$s0,	16($sp)
	sw	$s1,	20($sp)
	sw	$s2,	24($sp)
	sw	$ra,	28($sp)
	
	# Begin writeChar
	
	# $s0 is 1st word of the character, $s1 is the 2nd word of the character
	subi	$s0,	$a0,	65	# since a is 0 is character bitmap table and ascii of a is 65
	sll	$s0,	$s0,	3	# double-word aligned (since 2 words = 1 character bitmap)
	addi	$s1,	$s0,	4	# 2nd word of character
	lw	$s0,	character($s0)	
	lw	$s1,	character($s1)
	
	# calculate starting address of square
	sll	$a2,	$a2,	2
	lw	$s2,	squareAddress($a2)
	sll	$s2,	$s2,	2
	add	$s2,	$s2,	$a1
	
	# first word
	move	$a0,	$s2
	move	$a1,	$s0
	move	$a2,	$a3
	jal	drawWord
	
	# second word
	addi	$a0,	$a0,	1024
	move	$a1,	$s1
	jal	drawWord
	# store registers on stack
	lw	$a0,	0($sp)
	lw	$a1,	4($sp)
	lw	$a2,	8($sp)
	lw	$a3,	12($sp)
	lw	$s0,	16($sp)
	lw	$s1,	20($sp)
	lw	$s2,	24($sp)
	lw	$ra,	28($sp)
	addi	$sp,	$sp,	32
	jr	$ra

# drawWord
# Input:	
# - $a0: starting address
# - $a1: word to draw
# - $a2: background color
# Output:
# - $v0: word to draw sll 16

drawWord:
	#store stuffs in stack
	addi	$sp,	$sp,	-32
	sw	$s0,	($sp)
	sw	$s1,	4($sp)
	sw	$s2,	8($sp)
	sw	$t0,	12($sp)
	sw	$t1,	16($sp)
	sw	$a0,	20($sp)
	sw	$a1,	24($sp)
	sw	$ra,	28($sp)
	
	# setup: $s0 contains address, $s1 contains color black,
	# $s2 contains loop cond, $t0 contains loop var
	move	$s0,	$a0
	move	$s1,	$zero
	li	$s2,	4	# loop condition
	move	$t0,	$zero	# loop variable
	
	# Start loop
dWordL:	jal	drawRow
	addi	$a0,	$a0,	256	# 1024 (pixels) / 16 (unit squares per pixel) * 4 (bytes per unit square)
	move	$a1,	$v0		# next row (8 bits)
	addi	$t0,	$t0,	1
	bne	$t0,	$s2,	dWordL
	
	# load stuffs in stack
	lw	$s0,	($sp)
	lw	$s1,	4($sp)
	lw	$s2,	8($sp)
	lw	$t0,	12($sp)
	lw	$t1,	16($sp)
	lw	$a0,	20($sp)
	lw	$a1,	24($sp)
	lw	$ra,	28($sp)
	addi	$sp,	$sp,	32
	jr	$ra
	
	
	
# Input:	
# - $a0: starting address
# - $a1: word to draw
# - $a2: background color
# Output:
# - $v0: word to draw sll 8

drawRow:
	# store in stack
	addi	$sp,	$sp,	-16
	sw	$s0,	0($sp)
	sw	$s1,	4($sp)
	sw	$t0,	8($sp)
	sw	$t1,	12($sp)
	
	# setup: $v0 contains word draw, $t0 contains loop variable
	# $s0 contains max loop var, $s1 contains color black, $t2 contains address
	move	$v0,	$a1
	move	$t0,	$zero
	li	$s0,	8	
	move	$s1,	$zero
	
	# Start loop
dRowL:	andi	$t1,	$v0,	0x80000000
	beq	$t1,	$zero,	drBkgr
drBlck:	sw	$s1,	($a0)			# store rgb code black in data mapping location
	j	endDrw
drBkgr:	sw	$a2,	($a0)			# Same, but background
endDrw:	addi	$a0,	$a0,	4		# move address to draw up by a word (4 bytes)
	sll	$v0,	$v0,	1
	addi	$t0,	$t0,	1
	bne	$t0,	$s0,	dRowL
	
	# return $a0 back to original
	
	addi	$a0,	$a0,	-32
	
	# load from stack then return
	lw	$s0,	0($sp)
	lw	$s1,	4($sp)
	lw	$t0,	8($sp)
	lw	$t1,	12($sp)
	addi	$sp,	$sp,	16
	jr	$ra

# Input:
# - $a0: word string
# - $a1: bitmap buffer
# - $a2: line number, line goes from 0 - 5
# - $a3: checker string
# Output:
# - None

printWordWithCheck:
	# stack stuff
	addi	$sp,	$sp,	-32
	sw	$a0,	($sp)
	sw	$a1,	4($sp)
	sw	$a2,	8($sp)
	sw	$a3,	12($sp)
	sw	$t0,	16($sp)
	sw	$s0,	20($sp)
	sw	$s1,	24($sp)
	sw	$s2,	28($sp)
	sw	$ra,	32($sp)

	mul	$a2,	$a2,	5		# starting square of this line
	addi	$t0,	$a2,	5		# for [for loop]
	move	$s0,	$a0			# input
	move	$s1,	$a3			# checker
	
PWWCLo:	lb	$a0,	($s0)			# input character
	andi	$a0,	$a0,	0x000000ff	# because lb sign-extend
	
	# determine color
	lb	$a3,	($s1)			# check character
	li	$s2,	'^'
	beq	$a3,	$s2,	PWWCRight
	li	$s2,	'*'
	beq	$a3,	$s2,	PWWCWrong
PWWCNone:
	lw	$a3,	none
	j	PWWCEndCheck
PWWCRight:
	lw	$a3,	right
	j	PWWCEndCheck
PWWCWrong:
	lw	$a3,	wrong
PWWCEndCheck:
	jal	drawChar
	addi	$s0,	$s0,	1
	addi	$s1,	$s1,	1
	addi	$a2,	$a2,	1
	bne	$a2,	$t0,	PWWCLo
	
	# stack stuff
	lw	$a0,	($sp)
	lw	$a1,	4($sp)
	lw	$a2,	8($sp)
	lw	$a3,	12($sp)
	lw	$t0,	16($sp)
	lw	$s0,	20($sp)
	lw	$s1,	24($sp)
	lw	$s2,	28($sp)
	lw	$ra,	32($sp)
	addi	$sp,	$sp,	36
	jr	$ra
