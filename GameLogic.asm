.data

.text

# Enter a letter into the bitmap at square number $a1 and
# return the next square to be edited (3 cases: user presses an alphabet,
# user presses a backspace, and user presses something else)
# input:
# - 
# - $a1: starting address of bitmap buffer
# - $a2: current square number
# - $a3: 
enterLetter:


.include	"CheckWord.asm"
.include	"IO_Bitmap.asm"

