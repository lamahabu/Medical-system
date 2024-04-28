# Title: Medical Test Management System			 	Filename: project1.asm
# Author: Sami Moqbel 1200751 - Lama Abdelmohsen 1201138	Date: 14/4/2024
# Description:
# Input:
# Output:
################# Data segment #####################
.data
menu: .asciiz "\nMedical Test Management System Menu:\n"
firstChoice: .asciiz "1- Add a new medical test\n"
secondChoice: .asciiz "2- Search for a test by patient ID\n"
thirdChoice: .asciiz "3- Search for unnormal tests\n"
fourthChoice: .asciiz "4- Print Average test value\n"
fivthChoice: .asciiz "5- Update an existing test result\n"
sixthChoice: .asciiz "6- Delete a test\n"
seventhChoice: .asciiz "7- Exit!\n"
pickChoice: .asciiz "Select an option: " 

inputFile: .asciiz "medical_records.txt"
inputBuffer: .space 1024

enteredS: .asciiz "\nPARSING STARTED\n"
convertingS: .asciiz "\nConversing STARTED\n"
printRecords:.asciiz "\nNumber of records:"
printSearchEnded:.asciiz "\nSearch Ended!\n"
printIdFound:.asciiz "\nID found:"
.align 2
patient_info: .space 120       # Array to store patients information 
record_counter: .space 0

temp_buffer:
    .space 256           # Allocate space for temporary buffer (adjust size as needed)


temp: .asciiz "temp\ttemp\ttemp\n"
temp1: .asciiz "\n=============================\n"
split:.asciiz "|"
comma:.asciiz ","
colon:.asciiz ":"
newLineSym:.asciiz "\n"
temp2: .asciiz "\n-----------------------------------\n"

ID_prompt: .asciiz "\nEnter patient ID: "
name_prompt: .asciiz "\nEnter test name: "
date_prompt: .asciiz "\nEnter test Date: "
result_prompt: .asciiz "\nEnter test Result: "
success_prompt: .asciiz "\nTest added successfully!\n"

ID_search:.asciiz "\nEnter patient ID: "

line_buffer: .space 50

testName: .space 4
testDate: .space 8
testRes: .space 8
#. . .
################# Code segment #####################
.text
.globl main
main: # main program entry

la $a0, inputFile #Load File Name Address
li $a1, 0 # Set Read-Only Mode
li $a2, 0 #ignored
li $v0, 13 # syscall for open file
syscall

move $s0, $v0 # save file descriptor in saved-temp

move $a0, $s0
la $a1, inputBuffer
li $a2, 1024 # hardcoded buffer length
li $v0, 14 # syscall for reading from file
syscall


#Test Output
la	$a0, inputBuffer
li	$v0, 4
syscall

j READ_FILE
# START PARSING 
# t1 => ID , $t5 => name.address, $t6 => date.address, $t7 => result.address





MENU:
la $a0, menu
li $v0, 4 # Print String
syscall

la $a0, firstChoice
li $v0, 4 # Print String
syscall

la $a0, secondChoice
li $v0, 4 # Print String
syscall

la $a0, thirdChoice
li $v0, 4 # Print String
syscall

la $a0, fourthChoice
li $v0, 4 # Print String
syscall

la $a0, fivthChoice
li $v0, 4 # Print String
syscall

la $a0, sixthChoice
li $v0, 4 # Print String
syscall

la $a0, seventhChoice
li $v0, 4 # Print String
syscall

la $a0, pickChoice
li $v0, 4 # Print String
syscall

li $v0, 5 # Read Integer
syscall

move $t0, $v0 # t0 = Choice

#move $a0, $t0
#li $v0, 1 # Print Integer
#syscall

beq $t0, 1, ADD
beq $t0, 2, SEARCH_ID
beq $t0, 3, SEARCH_T
beq $t0, 4, PRINT
beq $t0, 5, UPDATE
beq $t0, 6, DELETE
beq $t0, 7, EXIT
j MENU


ADD: #add new test
	la $a0, temp1
	li $v0, 4 # Print String
	syscall

# Prompt the user for test information

    # Prompt for patient ID
    la $a0, ID_prompt
    li $v0, 4   # Print String
    syscall
    li $v0, 5   # Read Integer
    syscall
    move $t1, $v0  # Store patient ID

    # Prompt for test name
    la $a0, name_prompt
    li $v0, 4   # Print String
    syscall
    la $a0, testName
    li $a1, 4  # Max length of test name
    li $v0, 8   # Read String
    syscall
    
    # Prompt for test date
    la $a0, date_prompt
    li $v0, 4   # Print String
    syscall
    la $a0, testDate
    li $a1, 8  # Max length of test date
    li $v0, 8   # Read String
    syscall

    # Prompt for test result
    la $a0, result_prompt
    li $v0, 4   # Print String
    syscall
    la $a0, testRes
    li $a1, 8  # Max length of test result
    li $v0, 8   # Read String
    syscall
    
    lw $t8, record_counter
	# Loop through stored records to find the matching ID
	la $t4, patient_info # Load base address of patient information
	li $t5, 0 # Initialize counter for number of records
	
getLast:
	lw $t6, ($t4) # Load current ID from patient_info
	addi $t4, $t4, 16   # Move to next record
	addi $t5, $t5, 1     # Increment counter
	blt $t5, $t8, getLast # If not reached total records, continue searching
	
addPatient:
	move $a0,$t1
	sw $a0, 0($t4)                    # Store patient ID
	
	la $a0, testName
	sw $a0, 4($t4)
	
	la $a0, testDate
	sw $a0, 8($t4)
	
	la $a0, testRes
	sw $a0, 12($t4)
	
	addi $t8, $t8, 1
	sw $t8, record_counter      
	 
    # Display confirmation message
    la $a0, success_prompt
    li $v0, 4   # Print String
    syscall

	j MENU

UPDATE:

search:
	la $a0, search
	li $v0, 4   # Print String
	syscall
	li $v0, 5   # Read Integer
	syscall
	move $s1, $v0   # Store the entered ID in $s1

	# Load the record counter
	lw $t8, record_counter

	# Loop through stored records to find the matching ID
	la $t4, patient_info # Load base address of patient information
	
	li $t5, 0 # Initialize counter for number of records

updateLoop:
	lw $t6, ($t4) # Load current ID from patient_info
	beq $t6, $s1, foundId # If ID matches, jump to found_id
	addi $t4, $t4, 16   # Move to next record
	addi $t5, $t5, 1     # Increment counter
	blt $t5, $t8, updateLoop # If not reached total records, continue searching
	j MENU             # Return to menu

foundId:
	# Print "ID found" message
	la $a0, printIdFound
	li $v0, 4           # Print String
	syscall

	# Print the patient ID	
	lw $a0, ($t4)      # Load the patient ID
	li $v0, 1          # Print Integer
	syscall
	
	la $a0, split
	li $v0, 4 # Print String
	syscall
	
	# Load name address into $a0
	lw $a0, 4($t4)                   # Load the address of testName from memory into $a0
	# Load the string from the address
	li $v0, 4                        # Print string syscall
	syscall
	
	la $a0, split
	li $v0, 4 # Print String
	syscall
	
	# Load name address into $a0
	lw $a0, 8($t4)                   # Load the address of testName from memory into $a0
	# Load the string from the address
	li $v0, 4                        # Print string syscall
	syscall
	
	la $a0, split
	li $v0, 4 # Print String
	syscall
	
	# Load name address into $a0
	lw $a0, 12($t4)                   # Load the address of testName from memory into $a0
	# Load the string from the address
	li $v0, 4                        # Print string syscall
	syscall
    
	addi $t4, $t4, 16   
	j search_loop

j MENU

DELETE:
la $a0, temp1
li $v0, 4 # Print String
syscall
j MENU

PRINT:
la $a0, temp1
li $v0, 4 # Print String
syscall
j MENU

SEARCH_ID:

	la $a0, ID_search
	li $v0, 4   # Print String
	syscall
	li $v0, 5   # Read Integer
	syscall
	move $s1, $v0   # Store the entered ID in $s1

	# Load the record counter
	lw $t8, record_counter

	# Loop through stored records to find the matching ID
	la $t4, patient_info # Load base address of patient information
	
	li $t5, 0 # Initialize counter for number of records

search_loop:
	lw $t6, ($t4) # Load current ID from patient_info
	beq $t6, $s1, found_id # If ID matches, jump to found_id
	addi $t4, $t4, 16   # Move to next record
	addi $t5, $t5, 1     # Increment counter
	blt $t5, $t8, search_loop # If not reached total records, continue searching

    # If reached total records and ID not found, print message
	la $a0, printSearchEnded
	li $v0, 4          # Print String
	syscall
	j MENU             # Return to menu

found_id:
	# Print "ID found" message
	la $a0, printIdFound
	li $v0, 4           # Print String
	syscall

	# Print the patient ID	
	lw $a0, ($t4)      # Load the patient ID
	li $v0, 1          # Print Integer
	syscall
	
	la $a0, split
	li $v0, 4 # Print String
	syscall
	
	# Load name address into $a0
	lw $a0, 4($t4)                   # Load the address of testName from memory into $a0
	# Load the string from the address
	li $v0, 4                        # Print string syscall
	syscall
	
	la $a0, split
	li $v0, 4 # Print String
	syscall
	
	# Load name address into $a0
	lw $a0, 8($t4)                   # Load the address of testName from memory into $a0
	# Load the string from the address
	li $v0, 4                        # Print string syscall
	syscall
	
	la $a0, split
	li $v0, 4 # Print String
	syscall
	
	# Load name address into $a0
	lw $a0, 12($t4)                   # Load the address of testName from memory into $a0
	# Load the string from the address
	li $v0, 4                        # Print string syscall
	syscall
    
	addi $t4, $t4, 16   
	j search_loop

SEARCH_T:
la $a0, temp1
li $v0, 4 # Print String
syscall
# Read the patient ID entered by the user
li $v0, 5 # Read Integer
syscall
move $s1, $v0 # Store the entered ID in $s1
j MENU

#############################
# Parse the line
READ_FILE:
	la $t0, inputBuffer      # Load address of buffer into $t0
	li $t1, 0           # Initialize register for address
	la $t4, patient_info        # Load base address of patient information
	lw $t8, record_counter
	j parse_ID
	
parse_ID:
    lb $t2, 0($t0)      # Load byte from buffer into $t2
    beq $t2, ':', found_ID_end  # If colon (':') is found, exit loop
    sub $t2, $t2, '0'   # Convert ASCII to integer
    mul $t1, $t1, 10    # Multiply address by 10
    add $t1, $t1, $t2   # Add digit to address
    addi $t0, $t0, 1    # Move to next character in buffer
    j parse_ID     # Repeat until colon is found

found_ID_end:
	addi $t0, $t0, 2    # Move past colon and space
	
	move $a0,$t1
	sw $a0, 0($t4)                    # Store patient ID
	
	la $a0, temp2
	li $v0, 4 # Print String
	syscall
	
	#print id
	lw $t5, ($t4)  
	move $a0, $t5  
	li $v0, 1       
	syscall     
	li $t3, 0
	
	# Allocate memory for the name
    li $v0, 9            # syscall 9 - sbrk (allocate memory)
    li $a0, 8            # Allocate 8 bytes for the name (adjust size as needed)
    syscall              # Allocate memory, address returned in $v0
    
    move $t9, $v0
    move $t5, $v0
    
	j parse_Name
    
parse_Name:
	lb $t2, 0($t0)      # Load byte from buffer into $t2
	beq $t2, ',', found_name_end  # If comma (',') is found, exit loop
	sb $t2, 0($t9)
	addi $t9, $t9, 1
	addi $t0, $t0, 1
	j parse_Name
          
found_name_end:
	addi $t0, $t0, 2    # Move past comma and space
	
	sw $t5, 4($t4)                   # Store name address (4 bytes offset from patient ID)+

	la $a0, split
	li $v0, 4 # Print String
	syscall
	
	# Load name address into $a0
	lw $a0, 4($t4)                   # Load the address of testName from memory into $a0
	# Load the string from the address
	li $v0, 4                        # Print string syscall
	syscall
	
	# Allocate memory for the name
    	li $v0, 9            # syscall 9 - sbrk (allocate memory)
    	li $a0, 8            # Allocate 8 bytes for the name (adjust size as needed)
    	syscall              # Allocate memory, address returned in $v0
    
    	move $t9, $v0
    	move $t6, $v0
	
	j parse_Date
    
parse_Date:
	lb $t2, 0($t0)      # Load byte from buffer into $t2
	beq $t2, ',', found_Date_end  # If comma (',') is found, exit loop
	sb $t2, 0($t9)
	addi $t9, $t9, 1
	addi $t0, $t0, 1
	j parse_Date
      
found_Date_end:
	addi $t0, $t0, 2    # Move past comma and space
	
	sw $t6, 8($t4)                   # Store name address (4 bytes offset from patient ID)+
	
	la $a0, split
	li $v0, 4 # Print String
	syscall
	
	# Load date address into $a0
	lw $a0, 8($t4)                   # Load the address of testName from memory into $a0

	# Load the string from the address
	li $v0, 4                        # Print string syscall
	syscall
	
	# Allocate memory for the name
    li $v0, 9            # syscall 9 - sbrk (allocate memory)
    li $a0, 8            # Allocate 8 bytes for the name (adjust size as needed)
    syscall              # Allocate memory, address returned in $v0
    
    move $t9, $v0
    move $t7, $v0
	
	j parse_Res
	
    
parse_Res:
	lb $t2, 0($t0)      # Load byte from buffer into $t2

	
	beq $t2, $zero, found_Res_end # If end of file
	beq $t2, '\n',found_Res_end   # If new Line
	sb $t2, 0($t9)
	addi $t9, $t9, 1
	addi $t0, $t0, 1
	j parse_Res
		
found_Res_end:

	sw $t7, 12($t4)                   # Store name address (4 bytes offset from patient ID)
	
	la $a0, split
	li $v0, 4 # Print String
	syscall
	
	# Load date address into $a0
	lw $a0, 12($t4)                   # Load the address of testName from memory into $a0

	# Load the string from the address
	li $v0, 4                        # Print string syscall
	syscall
	addi $t8, $t8, 1
	beq $t2, $zero, close_file # If end of file
	beq $t2, '\n',newLine  # If new Line
	
close_file:
 	sw $t8, record_counter
	# Close the file
	li $v0, 16       # syscall for close
	move $a0, $s0    # file descriptor
	syscall          # close the file
	
	
	 # Print the number of records
    	la $a0, printRecords
    	li $v0, 4       # Print String
    	syscall

    	lw $a0, record_counter
    	li $v0, 1       # Print Integer
    	syscall
	j MENU
	
	
newLine:
	addi $t4,$t4,16
	addi $t0, $t0, 1    # Move past new Line
	li $t1, 0 # i did this just to check and this to reset ID again
	j parse_ID
            
EXIT:
	la $a0, temp1
	li $v0, 4 # Print String
	syscall

	la $t4, patient_info             # Load base address of patient information
	lw $a0, 60($t4)                   # Load the address of testName from memory into $a0
	li $v0, 4                       # Print string syscall
	syscall
	
	li $v0, 10 # Exit program
	syscall
