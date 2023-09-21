#ifndef A_CLASS_H
#define A_CLASS_H

// Struktura a_class przechowuje bazowe reprezentacje klas abstrakcji w strukturze Find Union
// dla poszczegolnych wierzcholkow w drzewie trie (reprezentujacych ciagi z zadania)
// dodatkowo, wszystkie klasy abstrakcji sa polaczone w jedna list, ktora na koncu programu jest usuwana
typedef struct a_class a_class;
struct a_class {
    char* name; // nazwa klasy abstrakcji, domyślnie NULL
    a_class* rep; // wskaznik do reprezentanta w Find Union
    int rank; // ranga w Find Union
    a_class* next; // nastepna klasa w liscie
};

// Funkcja a_class_list_add(list, name)
//   dodaje nowa klase abstrakcji (o nazwie name - byc moze NULL)
//   do listy (list) wszystkich klas abstrakcji
//   klasa jest wstawiana na pozycje miedzy [list] i [list->next]
// Warunki:
//   list != NULL
// Zwraca:
//   wskaznik do nowej klasy abstrakcji wstawionej na liste, jesli nie bylo bledow
//   NULL, jesli wystapil blad alokacji
a_class* a_class_list_add(a_class* list, char* name);

// Funkcja a_class_list_delete(list)
//   zwalnia pamiec i usuwa cala liste klas abstrakcji (lacznie z poczatkiem listy)
//   uwaga: wstaznik list staje sie niewazny
void a_class_list_delete(a_class* list);

// Funkcja a_class_fu_find(ac)
//   znajduje reprezentanta klasy abstrakcji ac w strukturze Find Union
// Warunki:
//   ac != NULL
// Zwraca:
//   wskaznik do reprezentanta
a_class* a_class_fu_find(a_class* ac);


// Funkcja a_class_fu_new_name(name1, name2, new_name)
//   1) przyjmuje wskazniki do zmiennych przechowujacych odpowiednie (byc moze rowne NULL) napisy:
//   - nazwe 1szej klasy abstrakcji (name1)
//   - nazwe 2giej klasy abstrakcji (name2)
//   - NULL, tutaj zostanie wstawiony wskaznik na napis z nowa nazwa klasy abstrakcji (new_name)
//   2) ac nastepnie oblicza nowa nazwe i zapisuje ja do *new_name,
//   w razie potrzeby kopiujac lub przenoszac pamiec z name1 i name2
//   uwaga: po wykonaniu, (jesli nie bylo bledow) wskazniki *name1 oraz *name2 beda rowne NULL,
//          a ich wczesniejsza zawartosc zostanie zwolniona lub przekazana do new_name
// Warunki:
//   name1, name2, new_name != NULL
//   *new_name == NULL
// Zwraca:
//   0 jesli udalo sie obsluzyc zmiany nazw
//   -1 jesli wystapil blad alokacji pamieci
int a_class_fu_new_name(char** name1, char** name2, char** new_name);

// Funkcja a_class_fu_union(ac1, ac2)
//   sprawdza, czy klasy ac1 i ac2 sa w roznych zbiorach w Find Union,
//   jesli sa, to laczy je w strukturze Find Union
//   oraz zgodnie z warunkami zadania laczy tez ich nazwy
// Warunki:
//   ac1, ac2 != NULL
// Zwraca:
//   0 jesli ac1 i ac2 juz byly w jednym zbiorze
//   1 jesli zostaly polaczone
//   -1 jesli wystapil blad alokacji
int a_class_fu_union(a_class* ac1, a_class* ac2);

#endif //A_CLASS_H
