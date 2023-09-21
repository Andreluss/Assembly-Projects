Summing
-------

Implement in assembly a function called from the C language with the following declaration:

    void sum(int64_t *x, size_t n);
    

The arguments of this function are a pointer `x` to a non-empty array of 64-bit integers in two's complement representation and the size `n` of this array. The function's behavior is defined by the following pseudocode:

    y = 0;
    for (i = 0; i < n; ++i)
      y += x[i] * (2 ** floor(64 * i * i / n));
    x[0, ..., n-1] = y;
    

where `**` means exponentiation, and `y` is a `(64 * n)`\-bit number in two's complement representation. The function should store the result in the array `x` in little-endian order. The function should perform the calculation "in place", using only the memory pointed to by `x`, and should not use any additional memory.

It is allowed to assume that the pointer `x` is correct and that `n` has a positive value less than 2 to the power of 29.

Submitting the solution
----------------------

As a solution, you should insert a file named `sum.asm` into Moodle.

Compiling
---------

The solution will be compiled with the command:

    nasm -f elf64 -w+all -w+error -o sum.o sum.asm
    

The solution must compile in the computer laboratory.

Example usage
-------------

An example usage can be found in the attached file `sum_example.c`. It can be compiled and consolidated with the solution using the commands:

    gcc -c -Wall -Wextra -std=c17 -O2 -o sum_example.o sum_example.c
    gcc -z noexecstack -o sum_example sum_example.o sum.o
    

Grading
-------

The grade will consist of two parts.

1.  The compliance of the solution with the specification will be assessed using automatic tests, for which you can get up to 7 points. Compliance with ABI rules, correctness of memory references and memory occupancy will also be checked. From the result of automatic tests, a value proportional to the size of additional memory used by the solution (sections `.bss`, `.data`, `.rodata`, stack, heap) will be subtracted. In addition, a threshold for the size of section `.text` will be set. Exceeding this threshold will result in subtracting from the grade a value proportional to the value of this excess. An additional criterion for automatic evaluation of the solution will be its speed. A solution that is too slow will not get the maximum grade. For an incorrect file name, we will subtract one point.
    
2.  For code quality and programming style, you can get up to 3 points. The traditional style of programming in assembly is to start labels from the first column, and mnemonics of commands from a selected fixed column. No other indents are used. This style is used by examples shown in classes. The code should be well commented, which means, among other things, that each block of code should be accompanied by information on what it does. The purpose of registers should be described. Comments are required for all key or non-trivial lines of code. In the case of assembly, it is not an exaggeration to comment on almost every line of code, but comments describing what is visible should be avoided.
    

Issuing a grade may depend on a personal explanation of the details of how the program works to the instructor.

**Solutions must be implemented independently under penalty of failing the course. Both using someone else's code and privately or publicly sharing your own code is prohibited.**

Attachment
---------
[```sum_example.c```](https://github.com/Andreluss/Low-level-Programming/blob/main/sum/attachments/sum_example.c)
