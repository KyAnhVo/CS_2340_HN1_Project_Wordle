.globl printString, strDisplay

.data
strDisplay	.asciiz		"|x|x|x|x|x|"

# Print string
# Input:
# $a0: address to first char of null-terminated string to print
# Output:
# $v0: str

getStrDisplay:
	la	$v0,	strDisplay
	lw	$t0,	