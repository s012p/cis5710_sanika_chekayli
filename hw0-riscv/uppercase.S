        .section .data
input_string:   .asciz "Hello world!"

        # tohost/fromhost are data locations used by Spike
        .align 8
tohost: .byte 0
        .align 8
fromhost: .byte 0

        
        .section .text
        .globl _start
_start:
        # Load the address of the input string into a0
        la a0, input_string

        # Your code here!
loop: 
        lb t0, 0(a0)
        beqz t0, end_program

        # determine whether lowercase letter, else skip
        li t1, 0x61 
        li t2, 0x7A
        blt t0, t1, next_char
        blt t2, t0, next_char

        # if lowercase letter, make uppercase
        addi t0, t0, -0x20
        sb t0, 0(a0)

next_char: 
        addi a0, a0, 1
        j loop
        
end_program:
        # jump here when you're done
        j end_program

