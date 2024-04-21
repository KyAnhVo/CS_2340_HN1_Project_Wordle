# Before starting program:
#
# 1.
# Tools -> Keyboard and Display MMIO Simulator
# Confirm that the middle bar says Fixed transmitter delay, select using slider
#
# 2.
# Tools -> Bitmap Display
#
# In Bitmap Display extension, set:
# - Unit Width/Height in Pixels to 16 (or 8).
# - Display Width in Pixels to 1024 (or 512), Display Height in Pixels to 512 (or 256)
# - Base address for display to 0x10040000 (heap).
# And then press "Reset" then press "Connect to MIPS" before doing anything



# include
.include	"ReadFile.asm"
.include	"CheckWord.asm"
.include	"IO_Bitmap.asm"