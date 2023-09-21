// AKSO Zadanie Zaliczeniowe 1
// Autor: Andrzej Jabłoński

#include "seq.h"
#include "trie.h"
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

// Struktura seq przechowuje tylko jeden wskaznik do poczatku drzewa Trie wszystkich ciagow,
// ktore z kolei tworzy i zawiera tez wskazniki do ich klas abstrakcji
struct seq {
    trie* trie_root;
};

seq_t *seq_new(void) {
    // 1) tworzymy nowy zbior ciagow
    seq_t* new_seq = (seq_t*)malloc(sizeof(seq_t));
    if(!new_seq) {
        errno = ENOMEM;
        return NULL;
    }

    // 2) tworzymy poczatek drzewa trie (ktory bedzie usuniety dopiero na samym koncu programu)
    new_seq->trie_root = trie_create_node(NULL); // klasa abstrakcji to NULL, ale zaraz to zmienimy
    if(new_seq->trie_root == NULL) {
        free(new_seq); // zwalniamy (1)
        errno = ENOMEM;
        return NULL;
    }

    // 3) tworzymy poczatek naszej listy wszystkich klas abstrakcji,
    // do ktorej bedziemy dodawac nowe klasy (funkcja a_class_list_add(list, name))
    new_seq->trie_root->ac = (a_class*) malloc(sizeof(a_class));
    if(new_seq->trie_root->ac == NULL) {
        free(new_seq->trie_root); // zwalniamy (2)
        free(new_seq); // zwalniamy (1)
        errno = ENOMEM;
        return NULL;
    }
    a_class* ac_list = new_seq->trie_root->ac;
    // i jeszcze inicjalizacja
    ac_list->name = NULL;
    ac_list->rep = ac_list;
    ac_list->rank = 0;
    ac_list->next = NULL;

    return new_seq;
}

void seq_delete(seq_t *p) {
    // 0) nic nie robimy jesli p == NULL
    if(p == NULL) return;

    // 1) usuwamy strukture klas abstrakcji
    a_class_list_delete(p->trie_root->ac);
    p->trie_root->ac = NULL;

    // 2) usuwamy cale drzewo trie
    if(p->trie_root != NULL) {
        trie_remove_all(p->trie_root);
        free(p->trie_root);
        p->trie_root = NULL;
    }

    // 3) ostatecznie zwalniamy p
    free(p);
}

// Funkcja s_is_valid(s)
// Zwraca:
//   1 jesli ciag s istnieje, jest niepusty i zlozony tylko ze znakow 0, 1 lub 2
//   0 w.p.p.
static int s_is_valid(const char* s) {
    if(s == NULL) return 0;
    // jesli s jest pusty
    if(*s == '\0') return 0;

    int only012 = 1;
    while(*s) {
        // jesli aktualny znak jest poza zakresem
        if(*s < '0' || '2' < *s) {
            only012 = 0;
            break;
        }
        s++;
    }
    return only012;
}

// Funkcja seq_add dodaje do zbioru ciągów podany ciąg i wszystkie niepuste podciągi będące jego prefiksem
int seq_add(seq_t *p, const char *s) {
    if(p == NULL || !s_is_valid(s)) {
        errno = EINVAL;
        return -1;
    }
    int result = trie_add(p->trie_root, s);
    if(result == -1) {
        errno = ENOMEM;
    }
    return result;
}

// Funkcja seq_remove usuwa ze zbioru ciągów podany ciąg i wszystkie ciągi, których jest on prefiksem.
int seq_remove(seq_t *p, const char *s) {
    if(p == NULL || !s_is_valid(s)) {
        errno = EINVAL;
        return -1;
    }
    int result = trie_remove(p->trie_root, s);
    return result;
}

int seq_valid(seq_t *p, const char *s) {
    if(p == NULL || !s_is_valid(s)) {
        errno = EINVAL;
        return -1;
    }
    int exists = trie_exists(p->trie_root, s);
    return exists;
}

int seq_set_name(seq_t *p, const char *s, const char *n) {
    if(p == NULL || !s_is_valid(s) || n == NULL || *n == '\0') {
        errno = EINVAL;
        return -1; // ktorys z parametrow jest niepoprawny
    }

    // znajdujemy odpowiadajacy ciagowi s wierzcholek w trie
    trie* node = trie_find(p->trie_root, s);

    if(node == NULL) {
        return 0; // ciag nie nalezy do zbioru ciagow
    }

    // znajdujemy reprezentanta klasy abstrakcji tego wierzcholka
    assert(node->ac != NULL);
    a_class* rep = a_class_fu_find(node->ac);
    assert(rep != NULL);

    // jesli nowa nazwa dla klasy abstrakcji jest taka sama, jak obecna
    if(rep->name != NULL && strcmp(rep->name, n) == 0) {
        return 0; // nazwa klasy abstrakcji nie zostala zmieniona
    }

    // usuwamy i zwalniamy poprzednia nazwe (jesli istniala)
    if(rep->name != NULL) {
        free(rep->name);
        rep->name = NULL;
    }

    rep->name = strdup(n);
    if(rep->name == NULL) {
        errno = ENOMEM;
        return -1; // wystapil blad alokacji
    }

    return 1; // nazwa klasy abstrakcji zostala przypisana lub zmieniona
}

char const *seq_get_name(seq_t *p, const char *s) {
    if(p == NULL || !s_is_valid(s)) {
        errno = EINVAL;
        return NULL;
    }
    // znajdujemy odpowiadajacy ciagowi s wierzcholek w trie
    trie* node = trie_find(p->trie_root, s);
    if(node == NULL) {
        // nie ma takiego ciagu w trie
        errno = 0;
        return NULL;
    }

    // znajdujemy reprezentanta klasy abstrakcji tego wierzcholka
    assert(node->ac != NULL);
    a_class* rep = a_class_fu_find(node->ac);
    assert(rep != NULL);
    if(rep->name == NULL) {
        // klasa abstrakcji zwierajaca ten ciag nie ma przypisanej nazwy
        errno = 0;
        return NULL;
    }
    return rep->name;
}

int seq_equiv(seq_t *p, const char *s1, const char *s2) {
    if(p == NULL || !s_is_valid(s1) || !s_is_valid(s2)) {
        errno = EINVAL;
        return -1;
    }

    trie* node1 = trie_find(p->trie_root, s1);
    trie* node2 = trie_find(p->trie_root, s2);
    // jesli ktoregos ciagu nie ma
    if(node1 == NULL || node2 == NULL) {
        return 0;
    }

    assert(node1->ac != NULL && node2->ac != NULL);
    int result = a_class_fu_union(node1->ac, node2->ac);
    if(result == -1) {
        errno = ENOMEM;
    }
    return result; // czyli 0 jesli ciagi byly juz w jednym zbiorze,
    // 1 jesli zostaly polaczone lub -1 w przypadku bledu alokacji
}

