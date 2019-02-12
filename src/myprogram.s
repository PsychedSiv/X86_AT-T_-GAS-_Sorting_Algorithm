.include "alloc.s"
.include "file_handling.s"
.include "parsing.s"
.include "print.s"

.section .data
	hello: .string "Hello worle\n"

.section .text

.globl _start


_start:

	#open file syscall
	movq $2, %rax
	movq 16(%rsp), %rdi
	movq $0, %rsi
	movq $0, %rdx
	syscall
	
	#move the file descriptor
	movq %rax, %rdi 
	push %rax 	#push file descriptor to stack

	#get size of file from %rdi to %rax
	call get_file_size
	movq %rax, %rdi
	push %rax 	#push size of file to stack

	#alloc memory size %rdi and return pointer to %rax
	call alloc_mem	
	push %rax 	#push raw data buffer pointer to stack

	#get stdin from file and put content in the allocated buffer
	movq $0, %rax
	pop %rsi
	pop %rdx
	pop %rdi
	push %rsi	#push buffer pointer to stack
	push %rdx 	#push size of file to stack
	syscall

	#get amount of numbers in buffer. returned in %rax
	pop %rsi
	pop %rdi
	push %rsi	#push size of that buffer
	push %rdi	#push pointer to text buffer
	call get_number_count
	movq %rax, %r15 #mov amount of numbers to %r15

	#alloc memory for new integer buffer pointer(returned in %rax) 8bytes * (amount of numbers)
	imulq $8, %rax
	movq %rax, %rdi
	call alloc_mem

	#convert char numbers in buffer to int numbers in new buffer (returned in %rax)
	pop %rdi	#pointer to text buffer
	pop %rsi	#size of text buffer
	movq %rax, %rdx	#pointer to integer buffer 
	call parse_number_buffer	

	#%rdx 	buffer pointer to stack
	#%r15 	amount of numbers in buffer to stack
	call selection_sort
	
        #exit syscall
        movq $60, %rax
        movq $0, %rdi
        syscall



#have to use the stack so the memory used will not be currupted
selection_sort:

	# Function Prologue (enter)
	push %rbp
	movq %rsp,%rbp

	# to get 5th number in buffer, -8*5(%rax)	

	# %rdx = pointer_to_buffer
	# %r15 = size_of_buffer
	# %r9 = smallest_num
	# %r10 = divider 
	# %r11 = current_num

	#setting the variables
	movq %r15, %r9 #smallest num
	movq %r15, %r10 #divider (Seperates sorted and unsorted list)
	movq %r15, %r11 #current_num

	sort_loop:
		
		call find_smallest_num		#puts smallest num in %r9	

						#swaps the new smallest num with num after divider, 
		call swap_num_in_buffer		#and increments divider

		#call find_smallest_num

		#call swap_num_in_buffer
		
		#check if we have sorted the whole buffer
		cmp $0, %r10
		jg sort_loop


	# Function Epilogue (leave)
	movq %rbp, %rsp
	pop %rbp

	ret


find_smallest_num:
	
	# Function Prologue (enter)
	push %rbp
	movq %rsp,%rbp

	# %rdx = pointer_to_buffer
	# %r15 = size_of_buffer
	# %r9 = smallest_num
	# %r10 = divider
	# %r11 = current_num
	
	buffer_loop:

		#we need negative displacement
		negq %r11
		negq %r9
		movq (%rdx, %r11, 8), %rbx 	#set current buffer num = %r11
		movq (%rdx, %r9, 8), %r14	#set smallest num in %r14 
		
		cmp %rbx, %r14			#cmp smallest num & current num
		jg set_smallest			#if current num < smallest num
		exit_set_smallest:

		negq %r9			#we have to reverse the negation
		negq %r11			#we have to reverse the negation
		subq $1, %r11			#itterate current index

		cmp $0, %r11			#if reach end of buffer
		jg buffer_loop 
	
	# Function Epilogue (leave)
	movq %rbp, %rsp
	pop %rbp

	ret

set_smallest:
	movq %r11, %r9
	jmp exit_set_smallest


swap_num_in_buffer:

	# Function Prologue (enter)
	push %rbp
	movq %rsp,%rbp

	negq %r9
	negq %r10

	movq (%rdx, %r9, 8), %rdi
	#movq (%rdx, %r11, 8), %rdi
	#movq (%rdx, %r10, 8), %rdi

	push %rdx
	push %r15
	push %r9
	push %r10
	push %r11

	call print_number

	pop %r11
	pop %r10
	pop %r9
	pop %r15
	pop %rdx
	
	#swap the smallest num and first num in buffer
	push (%rdx, %r9, 8)
	push (%rdx, %r10, 8)
	pop (%rdx, %r9, 8)
	pop (%rdx, %r10, 8)

	negq %r9
	negq %r10

	subq $1, %r10		#itterate the divider
	movq %r10, %r9		#set new smallest num to first num of unsorted list
	movq %r10, %r11 	#set current num to new first num of unsorted list

	# Function Epilogue (leave)
	movq %rbp, %rsp
	pop %rbp

	ret



