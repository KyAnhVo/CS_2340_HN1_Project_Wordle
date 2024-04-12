.data

# datas for bitmap display
dataRegisterDp:	.word	0xffff0000
bitmapBuffer:	.space	0x00100000
bufferSize:	.word	0x00100000
green:		.word	0x00228b22	# correct position
yellow:		.word	0x00ffff00	# wrong position
grey:		.word	0x00a9a9a9	# not in word

# datas for keyboard input
dataRegisterKb:	.word	0xffff0004
ctrlRegisterKb:	.word	0xffff0000