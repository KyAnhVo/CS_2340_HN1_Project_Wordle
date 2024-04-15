.data
# datas for bitmap display
bitmapBuffer:	.space	0x00100000
dataRegisterDp:	.word	0xffff0000
bufferSize:	.word	0x00100000
green:		.word	0x00228b22	# correct position
yellow:		.word	0x00ffff00	# wrong position
grey:		.word	0x00a9a9a9	# not in word

# consts

# datas for keyboard input
dataRegisterKb:	.word	0xffff0004
ctrlRegisterKb:	.word	0xffff0000

.text
	la	$s0,	bitmapBuffer
	li	$s1,	0x00100000
	li	$s2,	0
LL:	lw	$t0,	green
	sw	$t0,	bitmapBuffer($s2)
	addi	$s2,	$s2,	4
	bne	$s2,	$s1,	LL
	li	$v0,	10
	syscall
	
drawA(red, startingLocation