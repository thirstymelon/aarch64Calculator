.text
.global _main
.p2align 2

_main:
                adrp    x1,     first@PAGE                  // prints first string
                add     x1, x1, first@PAGEOFF
                mov     x2,     #firstLen
                bl      write

                adrp    x1,     num1@PAGE                   // takes first input
                add     x1, x1, num1@PAGEOFF
                mov     x2,     #2
                bl      read

                mov     x19,    x0                          // stores length of first input

                adrp    x1,     second@PAGE                 // prints second string
                add     x1, x1, second@PAGEOFF
                mov     x2,     #secondLen
                bl      write


                adrp    x1,     num2@PAGE                   // takes second input
                add     x1, x1, num2@PAGEOFF
                mov     x2,     #2
                bl      read

                mov     x20,    x0                          // stores length of second input


                adrp    x1,     operator@PAGE               // prints operator string
                add     x1, x1, operator@PAGEOFF
                mov     x2,     #operatorLen
                bl      write


                adrp    x1,     oper@PAGE                   // takes operator as input
                add     x1, x1, oper@PAGEOFF
                mov     x2,     #2
                bl      read

                # storing length of the operator
                mov     x21,    x0

                adrp    x3,     oper@PAGE                   // loading the operator to register for switch case
                add     x3, x3, oper@PAGEOFF
                ldrb    w4,     [x3]

                cmp     w4,     #'+'
                b.eq    add_them

                cmp     w4,     #'-'
                b.eq    sub_them

                cmp     w4,     #'*'
                b.eq    mul_them

                cmp     w4,     #'/'
                b.eq    div_them

                b       default


                # handle switch case
                # -------- Code Incomplete ----------


                adrp    x1,     num1@PAGE                   // prints first input
                add     x1, x1, num1@PAGEOFF
                mov     x2,     x19
                bl      write

                adrp    x1,     num2@PAGE                   // prints second input
                add     x1, x1, num2@PAGEOFF
                mov     x2,     x20
                bl      write

                b       exit



add_them:       b       exit
sub_them:       b       exit
mul_them:       b       exit
div_them:
                adrp    x4,     num2@PAGE
                add     x4, x4, num2@PAGEOFF

                ldrb    w5,     [x4]
                sub     w5, w5, #'0'                // checks if num2 = 0

                cmp     w5,     #0
                beq     div_err                     // jump to div_err if num2 == 0

default:        b       exit

write:
                mov     x0,     #1
                mov     x16,    #4
                svc     0
                ret


read:
                mov     x0,     #0
                mov     x16,    #3
                svc     0
                ret


div_err:
                mov     x0,     #1
                adrp    x1,     diverr_str@PAGE
                add     x1, x1, diverr_str@PAGEOFF
                mov     x2,     #diverr_str_len
                bl      write

exit:
                mov     x0,     #0
                mov     x16,    #1
                svc     0


.section __TEXT, __const
first:          .ascii  "Enter first number: "
firstLen=       . - first

second:         .ascii  "Enter second number: "
secondLen=      . - second

operator:       .ascii  "Select the operator ( +, -, *, /): "
operatorLen=    . - operator

diverr_str:     .ascii  "Cannot Divide by zero\n"
diverr_str_len= . - diverr_str


.bss
num1:           .skip   64
num2:           .skip   64
oper:           .skip   64
