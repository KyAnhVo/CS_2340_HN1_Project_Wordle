.data
# datas for bitmap display
# Note:
# Tools -> Bitmap Display
#
# In Bitmap Display extension, set:
# - Unit Width/Height in Pixels to 16.
# - Display Width in Pixels to 1024, Display Height in Pixels to 512
# - Base address for display to 0x10040000 (heap).
# And then press "Reset" then press "Connect to MIPS" before doing anything

green:		.word	0x00228b22	# correct position
yellow:		.word	0x00ffff00	# wrong position
grey:		.word	0x00a9a9a9	# not in word
white:		.word	0x00ffffff	# before check
black:		.word	0x00000000	# to write word

# Character chart, so each 2 words represent how to draw a char in a 8x8 square
# so a 0 in binary means no draw and 1 means draw
# For any word, draw one pixel at a time by:
# andi	$t0,	$s0,	0x80000000
# sll	$s0,	$s0,	1
# some drawing algorithm with $t0
character:
	.word	0xff8181b9,	0xa9bd81ff	#A
	.word	0xff81a1b9,	0xa9b981ff	#B
	.word	0xff81bda1,	0xa1bd81ff	#C
	.word	0xff8189b9,	0xa9bd81ff	#D
	.word	0xff81b9a9,	0xb1b981ff	#E
	.word	0xff819991,	0xb99181ff	#F
	.word	0xff81b9a9,	0xb98999ff	#G
	.word	0xff81a1a1,	0xb9a981ff	#H
	.word	0xff819181,	0x919181ff	#I
	.word	0xff81a1a9,	0xb1a981ff	#K
	.word	0xff81a1a1,	0xa1b181ff	#L
	.word	0xff818181
.text

mainDebug:
	jal	allocateBitmapHeapMemory
	move	$s0,	$v0

	li	$v0,	10
	syscall

# allocateBitmapBuffer
# input:
# - None
# output:
# - $v0: address of first byte of heap memory allocated
#
# Note: Please run this function allocateBitmapHeapMemory first thing before using any additional heap memory
# since bitmap display extension is set to such that its memory for DMA is.

allocateBitmapHeapMemory:
	addi	$sp,	$sp,	-4
	sw	$a0,	0($sp)
	li	$a0,	2048		# (512 / 16) * (1024 / 16)
	sll	$a0,	$a0,	2	# shift left 2 since each pixel has size 4 bytes
	li	$v0,	9		# allocate heap memory
	syscall
	lw	$a0,	0($sp)
	addi	$sp,	$sp,	4
	jr	$ra

# writeChar
# input:
# - $a0: ascii code of char (must be between A (65 or 0x41) and Z (90 or 0x5a))
# - $a1: starting address of bitmap buffer
# - $a2: pixel number of top left corner (top left is 0, bottom right is 127)
# - $a3: -1 for wrong location, 0 for not in word, 1 for right location, 2 for not checked yet
# output:
# - None

writeChar:
	# store registers on stack
	
	# Begin writeChar
	
	subi	$s0,	$a0,	65
	sll	$s0,	$s0,	8
	addi	$s1,	$s0,	4
	lw	$s0,	character($s0)	
	lw	$s1,	character($s1)
	
	# Determine color scheme from $a3
	# $s2 is background, $s3 is black
	li	$t0,	-1
	beq	$a3,	$t0,	wcIfn1
	addi	$t0,	$t0,	1
	beq	$a3,	$t0,	wcIf0
	addi	$t0,	$t0,	1
	beq	$a3,	$t0,	wcIfP1
	addi	$t0,	$t0,	1
	beq	$a3,	$t0,	wcIfNC
wcIfN1:	lw	$s2,	yellow
	j	outIf
wcIf0:	lw	$s2,	grey
	j	outIf
wcIfP1:	lw	$s2,	green
	j	outIf
wcIfNC:	lw	$s2,	white
	j	outIf
outIf:	lw	$s3,	black
	
	# Loop register $s0
	add	$s4,	$a1,	$a2
	addi	$s4,	$s4,	-65
	li	$s5,	4		# max for outside loop
	li	$s6,	8		# max for inside loop
	li	$t0,	0		# outside loop iterative var
	li	$t1,	0		# inside loop iterative var
ouLWC1:	# out loop write char 1
	move	$t1,	$zero
inLWC1:	# in loop write char 1
	andi	$t2,	$s0,	0x80000000
	bne	$t2,	$zero,	wrBackg
wrBlac:	
wrBckg:	
aftWr:
	bne	$t1,	$s6,	inLWC1	# end inside loop
	
	bne	$t0,	$s5,	ouLWC1 # end outside loop
	
	
