.data
correct_word:         .asciiz "hello"         # Null-terminated correct word
msg_prompt:           .asciiz "\nEnter your guess (5 characters): "
msg_correct:          .asciiz "Congratulations! You guessed correctly.\n"
msg_wrong:            .asciiz "Sorry, your guess is incorrect.\n"
msg_feedback:         .asciiz "Feedback: "
correct_position_msg: .asciiz "Letters in correct position: "
wrong_position_msg:   .asciiz "\nLetters in wrong position: "
not_in_word_msg:      .asciiz "\nLetters not in the word: "
guess:                .space 6
feedback:             .space 20
newline:              .asciiz "\n"            # Newline character

.text
.globl main

main:
    li $t0, 6                           # Initialize guess count to 6

get_guess:
    # Print prompt
    li $v0, 4
    la $a0, msg_prompt
    syscall

    # Read user input
    li $v0, 8
    la $a0, guess
    li $a1, 6                           # Maximum number of characters to read (including null terminator)
    syscall

    # Compare the guess with the correct word
    la $t1, correct_word                # Load address of the correct word
    la $t2, guess                       # Load address of the user's guess
    li $t3, 0                           # Initialize index

# checkWord:
#
# Input
# - $a0: address of nullterminated string of length 5 for correct word
# - $a1: address of nullterminated string of length 5 for user-input word
# Output:
# - $v0: address of ullterminated string of length 5 that indicates the result where
#  	^: correct position
#	*: in word, wrong position
#	X: not in word

# aabbc
# bacde
# *^*XX

compare_loop:
    lb $s4, 0($t2)                     # Load character from guess
    beq $s4, $zero, end_comparison      # If end of string, exit loop

    lb $s5, 0($t1)                     # Load character from correct word
    beq $s5, $zero, wrong_guess         # If end of string, jump to wrong_guess

    bne $s4, $s5, check_next            # If characters don't match, check next character
    addi $t1, $t1, 1                   # Move to next character in correct word
    addi $t2, $t2, 1                   # Move to next character in guess
    addi $t3, $t3, 1                   # Increment index
    j compare_loop                     # Repeat for next character

check_next:
    li $t6, 0                           # Initialize flag for wrong position
    move $t7, $t3                       # Copy index to $t7

    # Check if the current character in guess exists in the correct word
check_next_loop:
    slti $t8, $t7, 5                    # Check if index is less than 5 (length of correct word)
    beq $t8, $zero, not_in_word         # If index exceeds length, jump to not_in_word

    lb $t8, 0($t2)                     # Load character from guess
    lb $t9, 0($t1)                     # Load character from correct word
    beq $t9, $zero, not_in_word         # If end of correct word, jump to not_in_word
    bne $t8, $t9, next_char             # If characters don't match, check next character

    sb $t8, feedback($t3)               # Store character in feedback buffer
    addi $t3, $t3, 1                    # Increment index for feedback buffer

next_char:
    addi $t7, $t7, 1                    # Increment counter
    addi $t1, $t1, 1                    # Move to next character in correct word
    j check_next_loop                   # Repeat loop

not_in_word:
    li $t6, 1                            # Set flag for wrong position

wrong_guess:
    # Print feedback
    li $v0, 4
    la $a0, msg_feedback
    syscall

    li $v0, 4
    la $a0, feedback
    syscall

    # Print each guess feedback on a new line
    li $v0, 4
    la $a0, newline
    syscall

    # Print "correct position" feedback
    li $v0, 4
    la $a0, correct_position_msg
    syscall
    li $v0, 11
    la $a0, ($s5)
    syscall
    	
 
    # Print "wrong position" feedback
    li $v0, 4
    la $a0, wrong_position_msg
    syscall
    li $v0, 11
    la $a0, ($s4)
    syscall
    
    # Print "not in word" feedback
    li $v0, 4
    la $a0, not_in_word_msg
    syscall
    li $v0, 11
    la $a0, ($s4)
    syscall
    
    # Decrement guess count
    addi $t0, $t0, -1
    beqz $t0, out_of_guesses

    # Repeat loop for next guess
    j get_guess

end_comparison:
    # Print feedback
    li $v0, 4
    la $a0, msg_feedback
    syscall

    li $v0, 4
    la $a0, feedback
    syscall

    # Print correct message
    li $v0, 4
    la $a0, msg_correct
    syscall

    # Exit program
    li $v0, 10
    syscall

out_of_guesses:
    # Print message for running out of guesses
    li $v0, 4
    la $a0, msg_wrong
    syscall

    # Exit program
    li $v0, 10
    syscall
