.text
.global _main
.p2align 2

_main:
                # prints first string
                mov     x0,     #1
                adrp    x1,     first@PAGE
                add     x1, x1, first@PAGEOFF
                mov     x2,     #firstLen
                bl      write


                # takes first input
                mov     x0,     #0
                adrp    x1,     num1@PAGE
                add     x1, x1, num1@PAGEOFF
                mov     x2,     #2
                bl      read

                # stores length of first input
                mov     x19,    x0


                # prints second string
                mov     x0,     #1
                adrp    x1,     second@PAGE
                add     x1, x1, second@PAGEOFF
                mov     x2,     #secondLen
                bl      write


                # takes second input
                mov     x0,     #0
                adrp    x1,     num2@PAGE
                add     x1, x1, num2@PAGEOFF
                mov     x2,     #2
                bl      read

                # stores length of second input
                mov     x20,    x0


                # prints operator string
                mov     x0,     #1
                adrp    x1,     operator@PAGE
                add     x1, x1, operator@PAGEOFF
                mov     x2,     #operatorLen
                bl      write


                # takes operator as input
                mov     x0,     #0
                adrp    x1,     oper@PAGE
                add     x1, x1, oper@PAGEOFF
                mov     x2,     #2
                bl      read

                # storing length of the operator
                mov     x21,    x0


                # handle switch case
                # -------- Code Incomplete ----------


                # prints first input
                mov     x0,     #1
                adrp    x1,     num1@PAGE
                add     x1, x1, num1@PAGEOFF
                mov     x2,     x19
                bl      write


                # prints second input
                mov     x0,     #1
                adrp    x1,     num2@PAGE
                add     x1, x1, num2@PAGEOFF
                mov     x2,     x20
                bl      write

                b       exit


write:
                movz    x16, 0x1900, lsl #16
                movk    x16, 4
                svc     0
                ret


read:
                movz    x16, 0x1900, lsl #16
                movk    x16, 3
                svc     0
                ret


exit:
                mov     x0,     #0
                movz    x16,    0x1900,     lsl #16
                movk    x16,    1
                svc     0


.section __TEXT, __const
first:          .ascii  "Enter first number: "
firstLen=       . - first

second:         .ascii  "Enter second number: "
secondLen=      . - second

operator:       .ascii  "Select the operator ( +, -, *, /): "
operatorLen=    . - operator


.bss
num1:           .skip   64
num2:           .skip   64
oper:           .skip   64
