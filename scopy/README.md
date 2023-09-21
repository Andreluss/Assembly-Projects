Special file copying
--------------------

Implement in assembly a program `scopy`, which takes two parameters that are file names:

    ./scopy in_file out_file
    

The program checks the number of parameters. If their number is different from 2, the program ends with code `1`.

The program tries to open the file `in_file` for reading. If it fails, the program ends with code `1`.

The program tries to create a new file `out_file` for writing with permissions `-rw-r--r--`. If it fails, because for example such a file already exists, the program ends with code `1`.

The program reads from the file `in_file` and writes to the file `out_file`. If there was an error reading or writing, the program ends with code `1`.

For each byte read from the file `in_file`, whose value is the ASCII code of the letter `s` or `S`, it writes this byte to the file `out_file`.

For each maximum non-empty sequence of bytes read from the file `in_file` that does not contain a byte whose value is the ASCII code of the letter `s` or `S`, it writes to the file `out_file` a 16-bit number containing the number of bytes in this sequence modulo 65536. It writes this number binary in little-endian order.

At the end, the program closes the files and if everything succeeds, it ends with code `0`.

Additional requirements and hints
---------------------------------

The program should use Linux system functions: `sys_open`, `sys_read`, `sys_write`, `sys_close`, `sys_exit`. The program should check the correctness of executing system functions (except for `sys_exit`). If a system function call ends with an error, the program should end with code `1`. In any situation, the program should explicitly call the function `sys_close` for each file that it opened before ending.

For obtaining a satisfactory speed of the program's operation, reads and writes should be buffered. Optimal buffer sizes should be selected and information about this should be placed in a comment.

Submitting the solution
----------------------

As a solution, you should insert a file named `scopy.asm` into Moodle.

Compiling
---------

The solution will be compiled with commands:

    nasm -f elf64 -w+all -w+error -o scopy.o scopy.asm
    ld --fatal-warnings -o scopy scopy.o
    

The solution must compile and work in the computer laboratory.

Example usage
-------------

An example usage can be found in the attached files `example1.in`, `example1.out`. The contents of these files can be viewed with the command `hexdump -C`.

Grading
-------

The grade will consist of two parts.

1.  The compliance of the solution with the specification will be assessed using automatic tests, for which you can receive up to 7 points. In this task, the priority is the speed of the program's operation, but the code size is also important. A threshold for the size of section `.text` will be set. Exceeding this threshold will result in subtracting from the grade a value proportional to the value of this excess. For an incorrect file name, we will subtract one point.
    
2.  For code quality and programming style, you can get up to 3 points. The traditional style of programming in assembly is to start labels from the first column, and mnemonics of commands from a selected fixed column. No other indents are used. This style is used by examples shown in classes. The code should be well commented, which means, among other things, that each block of code should be accompanied by information on what it does. The purpose of registers should be described. Comments are required for all key or non-trivial lines of code. In the case of assembly, it is not an exaggeration to comment on almost every line of code, but comments describing what is visible should be avoided.
    

Issuing a grade may depend on a personal explanation of the details of how the program works to the instructor.

**Solutions must be implemented independently under penalty of failing the course. Both using someone else's code and privately or publicly sharing your own code is prohibited.**

Attachments
---------

[example1.in](https://github.com/Andreluss/Low-level-Programming/blob/main/scopy/attachments/example1.in)

[example1.out](https://github.com/Andreluss/Low-level-Programming/blob/main/scopy/attachments/example1.out)
