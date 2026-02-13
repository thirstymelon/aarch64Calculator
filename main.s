.text
.global _main
.p2align 2

_main:

				adrp	x1, first@PAGE
				add		x1, x1, first@PAGEOFF
				mov		x2, #firstLen
				bl		write                   // print first prompt

				adrp	x1, num1@PAGE
				add		x1, x1, num1@PAGEOFF
				mov		x2, #64
				bl		read                    // read first number

				adrp	x0, num1@PAGE
				add		x0, x0, num1@PAGEOFF
				bl		parse_int
				sxtw	x22, w0					// store first operand



				adrp	x1, second@PAGE
				add		x1, x1, second@PAGEOFF
				mov		x2, #secondLen
				bl		write                   // print second prompt

				adrp	x1, num2@PAGE
				add		x1, x1, num2@PAGEOFF
				mov		x2, #64
				bl		read                    // read second number

				adrp	x0, num2@PAGE
				add		x0, x0, num2@PAGEOFF
				bl		parse_int
				sxtw	x23, w0					// store second operand



				adrp	x1, operator@PAGE
				add		x1, x1, operator@PAGEOFF
				mov		x2, #operatorLen
				bl		write                   // print operator prompt

				adrp	x1, oper@PAGE
				add		x1, x1, oper@PAGEOFF
				mov		x2, #2
				bl		read                    // read operator

				adrp	x3, oper@PAGE
				add		x3, x3, oper@PAGEOFF
				ldrb	w4, [x3]                // load operator char


				cmp		w4, #'+'
				b.eq	add_them

				cmp		w4, #'-'
				b.eq	sub_them

				cmp		w4, #'*'
				b.eq	mul_them

				cmp		w4, #'/'
				b.eq	div_them

				b		default                 // invalid operator



add_them:
				add		x24, x22, x23           // x24 = a + b
				b		print_result

sub_them:
				sub		x24, x22, x23           // x24 = a - b
				b		print_result

mul_them:
				mul		x24, x22, x23           // x24 = a * b
				b		print_result

div_them:
				cmp		x23, #0
				beq		div_err                 // check divide by zero
				sdiv	x24, x22, x23           // x24 = a / b
				b		print_result



print_result:
				mov		x0, x24                 // number to convert
				adrp	x1, result_buf@PAGE
				add		x1, x1, result_buf@PAGEOFF
				bl		int_to_ascii            // convert to string

				mov		x2, x0                  // x2 = length
				adrp	x1, result_buf@PAGE
				add		x1, x1, result_buf@PAGEOFF
				bl		write                   // print result

				b		exit



// x0 = pointer to input string
// returns w0 = signed 32-bit integer
parse_int:
				mov		x4, x0                  // pointer walker
				mov		w5, #0                  // result accumulator
				mov		w6, #0                  // sign flag

				ldrb	w7, [x4]
				cmp		w7, #'-'
				b.ne	parse_loop

				mov		w6, #1                  // mark negative
				add		x4, x4, #1

parse_loop:
				ldrb	w7, [x4], #1
				cmp		w7, #'\n'
				beq		parse_done              // stop at newline

				cmp		w7, #'0'
				blt		parse_done
				cmp		w7, #'9'
				bgt		parse_done

				sub		w7, w7, #'0'
				mov		w8, #10
				mul		w5, w5, w8
				add		w5, w5, w7
				b		parse_loop

parse_done:
				cmp		w6, #1
				b.ne	ret_parse
				neg		w5, w5                  // apply sign

ret_parse:
				mov		w0, w5
				ret



// x0 = signed 64-bit number
// x1 = output buffer
// returns x0 = string length
int_to_ascii:
				mov		x2, x0                  // working copy
				mov		x3, x1                  // buffer pointer
				mov		x4, #0                  // length
				mov		x5, #0                  // sign flag

				cmp		x2, #0
				b.ge	convert

				mov		x5, #1                  // negative
				neg		x2, x2

convert:
				cbz		x2, zero_case

loop:
				mov		x6, #10
				udiv	x7, x2, x6
				msub	x8, x7, x6, x2          // remainder
				add		x8, x8, #'0'
				strb	w8, [x3, x4]            // store digit (reverse)
				add		x4, x4, #1
				mov		x2, x7
				cbnz	x2, loop
				b		reverse

zero_case:
				mov		w6, #'0'
				strb	w6, [x3]
				mov		x4, #1

reverse:
				mov		x9, #0
				sub		x10, x4, #1

rev_loop:
				cmp		x9, x10
				b.ge	sign

				ldrb	w11, [x3, x9]
				ldrb	w12, [x3, x10]
				strb	w12, [x3, x9]
				strb	w11, [x3, x10]
				add		x9, x9, #1
				sub		x10, x10, #1
				b		rev_loop

sign:
				cbz		x5, done

				mov		x9, x4

shift:
				cbz		x9, put_minus
				sub		x9, x9, #1
				ldrb	w10, [x3, x9]
				add		x11, x9, #1
				strb	w10, [x3, x11]
				b		shift

put_minus:
				mov		w10, #'-'
				strb	w10, [x3]
				add		x4, x4, #1

done:
				mov		x0, x4
				ret



default:
				adrp	x1, default_str@PAGE
				add		x1, x1, default_str@PAGEOFF
				mov		x2, #default_len
				bl		write                   // print invalid operator
				b		exit

div_err:
				adrp	x1, diverr_str@PAGE
				add		x1, x1, diverr_str@PAGEOFF
				mov		x2, #diverr_str_len
				bl		write                   // print divide-by-zero



exit:
				mov		x0, #0                  // exit status
				mov		x16, #1
				svc		0

write:
				mov		x0, #1                  // stdout
				mov		x16, #4
				svc		0
				ret

read:
				mov		x0, #0                  // stdin
				mov		x16, #3
				svc		0
				ret



.section __TEXT,__const

first:			.ascii	"Enter first number: "
firstLen=		. - first

second:		.ascii	"Enter second number: "
secondLen=		. - second

operator:		.ascii	"Select operator (+ - * /): "
operatorLen=	. - operator

diverr_str:	.ascii	"Cannot divide by zero\n"
diverr_str_len=	. - diverr_str

default_str:	.ascii	"Invalid operator\n"
default_len=	. - default_str


.bss
num1:			.skip	64
num2:			.skip	64
oper:			.skip	2
result_buf:		.skip	32
