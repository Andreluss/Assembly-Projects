Sets of equivalent sequences
---------------------------

The task is to implement in C language a dynamically loaded library that supports sets of sequences with an equivalence relation. The elements of the sets are non-empty sequences whose elements are numbers `0`, `1` and `2`. In the implementation, we represent a sequence as a string. For example, the sequence `{0, 1, 2}` is represented as the string `"012"`. Abstract classes can be given names.

Library interface
-----------------

The functions and type name that the library should provide are declared in the file `seq.h` attached to the task description. The declarations are described below. A correct representation of a sequence is a non-empty string consisting of characters `0`, `1` or `2` and is terminated by a terminal zero. A correct name of an abstract class is a non-empty string terminated by a terminal zero. Additional details of the library's operation, in particular information on what is an incorrect parameter, should be inferred from the file `seq_example.c` attached to the task description, which is an integral part of the specification. The term used below that the set of sequences has not changed means that the observable state of the set of sequences has not changed.

    typedef struct seq seq_t;
    

This is the name of a structural type representing a set of sequences with an equivalence relation. This type must be defined (implemented) as part of this task.

    seq_t * seq_new(void);
  

The function `seq_new` creates a new empty set of sequences.

Function result:

*   pointer to a structure representing a set of sequences or
*   `NULL` - if there was an error allocating memory; the function then sets `errno` to `ENOMEM`.

    void seq_delete(seq_t *p);
    

The function `seq_delete` deletes a set of sequences and frees all memory used by it. It does nothing if it is called with a pointer `NULL`. After executing this function, the pointer passed to it becomes invalid.

Function parameter:

*   `p` - pointer to a structure representing a set of sequences.

    int seq_add(seq_t *p, char const *s);
    

The function `seq_add` adds to the set of sequences the given sequence and all non-empty subsequences that are its prefix.

Function parameters:

*   `p` - pointer to a structure representing a set of sequences;
*   `s` - pointer to a string representing a non-empty sequence.

Function result:

*   `1` - if at least one new sequence has been added to the set;
*   `0` - if the set of sequences has not changed;
*   `-1` - if any of the parameters is incorrect or there was an error allocating memory; the function then sets `errno` accordingly to `EINVAL` or `ENOMEM`.

    int seq_remove(seq_t *p, char const *s);
    

The function `seq_remove` removes from the set of sequences the given sequence and all sequences that are its prefix.

Function parameters:

*   `p` - pointer to a structure representing a set of sequences;
*   `s` - pointer to a string representing a non-empty sequence.

Function result:

*   `1` - if at least one sequence has been removed from the set;
*   `0` - if the set of sequences has not changed;
*   `-1` - if any of the parameters is incorrect; the function then sets `errno` to `EINVAL`.

    int seq_valid(seq_t *p, char const *s);
    

The function `seq_valid` checks whether the given sequence belongs to the set of sequences.

Function parameters:

*   `p` - pointer to a structure representing a set of sequences;
*   `s` - pointer to a string representing a non-empty sequence.

Function result:

*   `1` - if the sequence belongs to the set of sequences;
*   `0` - if the sequence does not belong to the set of sequences;
*   `-1` - if any of the parameters is incorrect; the function then sets `errno` to `EINVAL`.


    int seq_set_name(seq_t *p, char const *s, char const *n);
    
The function `seq_set_name` sets or changes the name of the abstract class to which the given sequence belongs. The given name should be copied, because the string pointed to by the pointer `n` may cease to exist after the end of this function.

Function parameters:

*   `p` - pointer to a structure representing a set of sequences;
*   `s` - pointer to a string representing a non-empty sequence;
*   `n` - pointer to a string with a new non-empty name.

Function result:

*   `1` - if the name of the abstract class has been assigned or changed;
*   `0` - if the sequence does not belong to the set of sequences or the name of the abstract class has not been changed;
*   `-1` - if any of the parameters is incorrect or there was an error allocating memory; the function then sets `errno` accordingly to `EINVAL` or `ENOMEM`.

    char const * seq_get_name(seq_t *p, char const *s);
    

The function `seq_get_name` gives a pointer to a string containing the name of the abstract class to which the given sequence belongs. The memory pointed to by this pointer must not be modified. This pointer may become invalid after any change in the structure of the set of sequences.

Function parameters:

*   `p` - pointer to a structure representing a set of sequences;
*   `s` - pointer to a string representing a non-empty sequence.

Function result:

*   pointer to a string containing the name or
*   `NULL`- if the sequence does not belong to the set of sequences or the abstract class containing this sequence does not have an assigned name; the function then sets `errno` to `0`.
*   `NULL`- if any of the parameters is incorrect; the function then sets `errno` to `EINVAL`.

    int seq_equiv(seq_t *p, char const *s1, char const *s2);
    

The function `seq_equiv` merges into one abstract class the abstract classes represented by the given sequences. If both abstract classes do not have an assigned name, then the new abstract class also does not have an assigned name. If exactly one of the abstract classes has an assigned name, then the new abstract class gets that name. If both abstract classes have assigned different names, then the name of the new abstract class is created by combining those names. If both abstract classes have assigned the same name, then that name remains as the name of the new abstract class.

Function parameters:

*   `p` - pointer to a structure representing a set of sequences;
*   `s1` - pointer to a string representing a non-empty sequence;
*   `s2` - pointer to a string representing a non-empty sequence.

Function result:

*   `1` - if a new abstract class has been created;
*   `0` - if no new abstract class has been created, because the given sequences already belong to the same abstract class or one of them does not belong to the set of sequences;
*   `-1` - if any of the parameters is incorrect or there was an error allocating memory; the function then sets `errno` accordingly to `EINVAL` or `ENOMEM`.

Note: strings representing sequences may cease to exist after the end of the function.


Requirements
------------

As a solution to the task, you should upload to Moodle an archive containing the file `seq.c` and optionally other files `*.h` and `*.c` with the implementation of the library, and the file `makefile` or `Makefile`. The archive should not contain any other files or subdirectories, in particular it should not contain any binary files. The archive should be compressed with the program `zip`, `7z` or `rar`, or a pair of programs `tar` and `gzip`. After unpacking the archive, all files should be found in the current directory.

The file `makefile` or `Makefile` provided in the solution should contain the target `libseq.so`, so that after executing the command `make libseq.so` the library compilation is run and the file `libseq.so` is created in the current directory. This command should also compile and link to the library the file `memory_tests.c` attached to the task description. The command `make clean` should delete all files created during compilation. The file `makefile` or `Makefile` may also contain other targets, for example a target that compiles and links with the library an example of its use contained in the file `seq_example.c` attached to the task description, or a target that runs tests.

You should use `gcc` to compile. The library should compile in the computer lab under Linux. Files with the implementation of the library should be compiled with options:

    -Wall -Wextra -Wno-implicit-fallthrough -std=gnu17 -fPIC -O2
    

Files with the implementation of the library should be linked with options:

    -shared -Wl,--wrap=malloc -Wl,--wrap=calloc -Wl,--wrap=realloc -Wl,--wrap=reallocarray -Wl,--wrap=free -Wl,--wrap=strdup -Wl,--wrap=strndup
    

The options `-Wl,--wrap=` cause calls to functions `malloc`, `calloc` etc. to be intercepted by functions `__wrap_malloc`, `__wrap_calloc` etc. respectively. The intercepting functions are implemented in the file `memory_tests.c` attached to the task description.

The implementation of the library must not leak memory or leave the data structure in an inconsistent state, even when there was an error allocating memory. The correctness of the implementation will be checked using the program `[valgrind](https://moodle.mimuw.edu.pl/mod/page/view.php?id=109614 "Valgrind")`. The implementation must not contain artificial limitations on the size of stored data - the only limitations are the size of memory available on the computer and the size of machine word used by the computer.

Evaluation
----------

For a fully correct solution of the task that implements all requirements, you can get 20 points, of which 14 points will be awarded based on automatic tests, and 6 points are an assessment of code quality. For problems with compiling the solution or not meeting formal requirements, you can lose all points. For warnings issued by the compiler, up to 2 points may be deducted.

**Solutions must be implemented independently under penalty of failing the course. Both using someone else's code and privately or publicly sharing your own code is prohibited.**

Attachments
-----------

The following files are attached to the task description:

*   `seq.h` - declaration of library interface;
*   `memory_tests.h` - declaration of interface of library module used to test reaction of implementation to failure of allocating memory;
*   `memory_tests.c` - implementation of library module used to test reaction of implementation to failure of allocating memory;
*   `seq_example.c` - example tests of library.

You must not modify the file `seq.h`. We reserve the right to change tests and contents of files `memory_tests.h` and `memory_tests.c` during testing solutions.

[```memory_tests.c```](https://github.com/Andreluss/Low-level-Programming/blob/main/seq/attachments/memory_tests.c)
[```memory_tests.h```](https://github.com/Andreluss/Low-level-Programming/blob/main/seq/attachments/memory_tests.h)
[```seq.h```](https://github.com/Andreluss/Low-level-Programming/blob/main/seq/attachments/seq.h)
[```seq_example.c```](https://github.com/Andreluss/Low-level-Programming/blob/main/seq/attachments/seq_example.c)
