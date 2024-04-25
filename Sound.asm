# Purpose of this module is to add sound to the game
# If the user's guess is incorrect, play a low pitched noise
# If the user's guesss is correct, play a higher pitched tune

.macro done
li	$v0,	10
syscall
.end_macro
.globl	wrongSound, rightSound

.text
mainDebugSound:
	jal	wrongSound
	jal	rightSound
	done

# Function to play a sound when user's guess is incorrect
wrongSound:
	# Save old content or the registers to stack
	addi	$sp,	$sp,	-16
	sw	$a0,	($sp)
	sw	$a1,	4($sp)
	sw	$a2,	8($sp)
	sw	$a3,	12($sp)
	
	# update argument registers to the specified pitch, duration, instrument, and volume
	li	$a1,	2000 # duration in ms
	li	$a2,	84   # instrument -> Synth Lead
	li	$a3,	127  # volume (max)
	li	$v0,	33
	
	li	$a0,	60   # pitch
	syscall
	
	# Save content of the registers to stack
	lw	$a0,	($sp)
	lw	$a1,	4($sp)
	lw	$a2,	8($sp)
	lw	$a3,	12($sp)
	addi	$sp,	$sp,	16
	jr	$ra

# Function to play a sound when user's guess is correct	
rightSound:
	# Save content of the registers to stack
	addi	$sp,	$sp,	-16
	sw	$a0,	($sp)
	sw	$a1,	4($sp)
	sw	$a2,	8($sp)
	sw	$a3,	12($sp)
	
	# update argument registers to the specified pitch, duration, instrument, and volume
	li	$a1,	2000  # duration in ms
	li	$a2,	1     # instrument -> Synth Lead
	li	$a3,	127   # volume (max)
	li	$v0,	31
	
	li	$a0,	60   # pitch
	syscall
	li	$a0,	64   # increase pitch
	syscall
	li	$a0,	67   # increase pitch
	syscall
	li	$a0,	72   # increase pitch
	syscall

	# Save content of the registers to stack
	lw	$a0,	($sp)
	lw	$a1,	4($sp)
	lw	$a2,	8($sp)
	lw	$a3,	12($sp)
	addi	$sp,	$sp,	16
	jr	$ra
