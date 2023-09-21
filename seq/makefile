CC       = gcc
CFLAGS   = -Wall -Wextra -Wno-implicit-fallthrough -std=gnu17 -fPIC -O2
LDFLAGS  = -Wl,--wrap=malloc -Wl,--wrap=calloc -Wl,--wrap=realloc \
           -Wl,--wrap=reallocarray -Wl,--wrap=free -Wl,--wrap=strdup \
	   -Wl,--wrap=strndup

.PHONY: all clean

all: libseq.so

memory_tests.o: memory_tests.c memory_tests.h
a_class.o: a_class.c a_class.h
trie.o: trie.c trie.h
seq.o: seq.c seq.h

libseq.so: a_class.o trie.o seq.o memory_tests.o
	gcc -shared $(LDFLAGS) -o $@ $^

my_test: seq_example.c libseq.so
	gcc -L. -o $@ $< -lseq

clean:
	rm -rf *.so *.o my_test


# Linijka do uruchomienia: 
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.
