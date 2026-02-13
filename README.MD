# AArch64 Calculator (Apple Silicon - macOS)

A minimal command-line calculator written entirely in **ARM64 assembly** for Apple Silicon (M1/M2/M3).

This program runs directly on macOS using Darwin system calls and does not depend on libc or any C runtime. Every part of the program — input handling, integer parsing, arithmetic, and output formatting — is implemented manually in assembly.

---

## Overview

The calculator:

- Uses raw macOS syscalls (`read`, `write`, `exit`)
- Parses signed integers from ASCII input
- Performs 64-bit arithmetic
- Converts integers back to ASCII manually
- Handles division by zero
- Uses no external libraries

It demonstrates low-level systems programming on AArch64.

---

## Program Flow (Step-by-Step Execution)

When executed, the program performs the following:

1. Prints `"Enter first number: "`
2. Reads user input into a memory buffer (`num1`)
3. Converts the ASCII string to a signed integer using `parse_int`
4. Repeats the same process for the second number
5. Prints `"Select operator (+ - * /): "`
6. Reads a single operator character
7. Compares the operator and branches to the correct arithmetic routine
8. Performs 64-bit arithmetic
9. Converts the result into a decimal ASCII string using `int_to_ascii`
10. Prints the result
11. Exits using the `exit` syscall

---

## Core Components Explained

### 1. System Calls (Darwin / macOS ARM64)

This program directly invokes kernel syscalls.

| Syscall | x16 value |
|----------|------------|
| `read`   | `3` |
| `write`  | `4` |
| `exit`   | `1` |

Example:

```asm
mov x0, #1      // stdout
mov x16, #4     // write
svc 0
```

No C library wrappers are used.

---

### 2. Memory Layout

The program uses:

- `.bss` section for input buffers
- `.const` section for prompt strings
- Registers for computation

Buffers:

- `num1` (64 bytes)
- `num2` (64 bytes)
- `oper` (2 bytes)
- `result_buf` (32 bytes)

---

### 3. Register Usage

| Register | Purpose |
|----------|----------|
| `x22` | First operand |
| `x23` | Second operand |
| `x24` | Arithmetic result |
| `x0`  | Function argument / return value |
| `x1`  | Buffer pointer |
| `x2`  | Length parameter |
| `x16` | Syscall selector |

All arithmetic is performed using **64-bit registers (`x`)** to avoid truncation and ensure correct signed behavior.

---

## Integer Parsing (`parse_int`)

This routine converts an ASCII string into a signed integer.

Algorithm:

1. Check if first character is `'-'`
2. If negative, mark sign and skip it
3. Loop through digits
4. For each digit:
   ```
   result = result * 10 + digit
   ```
5. Stop when newline or non-digit is reached
6. Apply sign if needed
7. Return result in `w0`

Example input:

```
"-123\n"
```

Produces:

```
-123
```

---

## Arithmetic Handling

After parsing:

- Addition: `add x24, x22, x23`
- Subtraction: `sub x24, x22, x23`
- Multiplication: `mul x24, x22, x23`
- Division: `sdiv x24, x22, x23`

Division includes a zero check:

```asm
cmp x23, #0
beq div_err
```

---

## Integer to ASCII Conversion (`int_to_ascii`)

This function converts a signed 64-bit integer to a decimal string.

Algorithm:

1. Detect if number is negative
2. Convert to positive if needed
3. Repeatedly divide by 10:
   - Extract remainder
   - Convert remainder to ASCII digit
4. Digits are generated in reverse order
5. Reverse digits in-place
6. Insert `-` if needed
7. Return string length

This function replaces standard library functions like `sprintf` or `itoa`.

---

## Example Execution

```
Enter first number: 10
Enter second number: -5
Select operator (+ - * /): *
-50
```

---

## Build Instructions

Use Apple’s assembler and clang:

```bash
as main.s -o main.o
clang main.o -o main
./main
```

---

## What This Project Demonstrates

- Raw syscall usage on macOS
- AArch64 instruction set fundamentals
- Manual parsing of ASCII numbers
- Manual integer formatting
- Signed 64-bit arithmetic
- Branch-based control flow
- Memory addressing in ARM64
- Working without libc

---

## Potential Improvements

- Detect arithmetic overflow
- Remove digit-shifting in `int_to_ascii`
- Support floating-point numbers
- Add exponentiation or modulus operator
- Add proper stack frame & ABI compliance
- Optimize register usage further
- Improve input validation

---



This project is a practical demonstration of writing complete standalone programs in ARM64 assembly on Apple Silicon without relying on high-level runtime libraries.
