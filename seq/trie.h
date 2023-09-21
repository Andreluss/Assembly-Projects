#ifndef TRIE_H
#define TRIE_H

#include "a_class.h"

// Struktura trie przechowuje ciagi z zadania jako wierzcholki drzewa Trie
// Na poczatku kazdy z nich ma wskaznik do swojej klasy abstrakcji
// Laczenie wierzcholkow w klasy abstrakcji jest realizowane przez laczenie ich klas abstrakcji
typedef struct trie trie;
struct trie {
    trie* next[3];
    a_class* ac;
};

// Funkcja trie_create_node(ac)
//   tworzy nowy wierzcholek dla drzewa trie,
//   z wskaznikiem do klasy abstrakcji ac
//   gotowy do podpiecia w drzewie
// Zwraca:
//   wskaznik na nowy wiercholek, jesli udalo sie go stworzyc
//   NULL, jesli wystapil blad alokacji
trie* trie_create_node(a_class* ac);

// Funkcja trie_remove_all(trie_root)
//   usuwa wszystkie poddrzewa w trie wychodzace z wierzcholka trie_root,
//   uwaga: funkcja oszczedza ten wierczcholek :)
// Warunki:
//   trie_root != NULL
void trie_remove_all(trie* trie_root);

// Funkcja trie_next_node(current_node, next_character)
//   zwraca oryginalny wskaznik (czyli wskaznik do wskaznika) do nastepnego wierzcholka w drzewie trie,
//   reprezentujacego ciag z wierzcholka current_node z dodanym na koncu znakiem next_character
// Warunki:
//   current_node != NULL
//   next_character \in {'0', '1', '2'}
// Zwraca:
//   wskaznik do nastepnego wierzcholka, jesli taki instnieje
//   NULL, w przeciwnym przypadku
trie** trie_next_node(trie* current_node, char next_character);


// Funkcja trie_remove(trie_root, s)
//   usuwa ciag s (i wszystkie jego sufiksy)
//   z drzewa trie zakorzenionego w trie_root
// Warunki:
//   trie_root != NULL
//   s jest poprawnym ciagiem z zadania (w szczeg. niepustym!)
// Zwraca:
//   1 jesli cos zostalo usuniete
//   0 jesli nic nie zostalo usuniete
int trie_remove(trie* root, const char* s);

// Funkcja trie_add(trie_root, s)
//   dodaje ciag s (i wszystkie jego prefiksy) do drzewa trie ukorzenionego w trie_root
// Warunki:
//   trie_root != NULL
//   s != NULL i s zawiera same {'0', '1', '2'}
// Zwraca:
//   1 jesli aktualizacja drzewa trie zakonczyla sie sukcesem, i zbior ciagow sie zmienil
//   0 jesli aktualizacja drzewa trie zakonczyla sie sukcesem, ale nic nie dodano
//   -1 jesli wystapil blad alokacji
int trie_add(trie* root, const char* s);

// Funkcja trie_find(trie_root, s)
//   szuka w drzewie trie (zakorzenionym w trie_root) ciagu s
// Warunki:
//   trie_root != NULL
//   s jest poprawnym, niepustym ciagiem
// Zwraca:
//   wskaznik do wierzcholka reprezentujacego ciag s, jesli jest w drzewie
//   NULL, jesli takiego ciagu nie ma
trie* trie_find(trie* trie_root, const char* s);

// Funkcja trie_exists(trie_root, s)
//   sprawdza, czy w drzewie trie zakorzenionym w trie_root znajduje sie ciag s
// Warunki:
//   trie_root != NULL
//   s jest poprawnym ciagiem z zadania
// Zwraca:
//   1 jesli szukany ciag jest w zbiorze
//   0 jesli go nie ma
int trie_exists(trie* root, const char* s);


#endif //TRIE_H
