#include <malloc.h>
#include <assert.h>
#include "trie.h"

trie* trie_create_node(a_class* ac) {
    trie* node = (trie*) malloc(sizeof(trie));
    if(!node) {
        return NULL;
    }

    node->next[0] = node->next[1] = node->next[2] = NULL;
    node->ac = ac;

    return node;
}

void trie_remove_all(trie* trie_root) {
    for(int i = 0; i < 3; i++) {
        if(trie_root->next[i] != NULL) {
            trie_remove_all(trie_root->next[i]);
            free(trie_root->next[i]);
            trie_root->next[i] = NULL;
        }
    }
}

trie** trie_next_node(trie* current_node, char next_character) {
    return &(current_node->next[next_character - '0']);
}

int trie_remove(trie* root, const char* s) {
    // z zalozenia wiemy, ze s jest niepusty, wiec mozemy wyliczyc:
    trie** next = trie_next_node(root, *s);
    if(*next == NULL) // jesli ciagu s nawet nie ma w zbiorze
        return 0;

    // jesli jestesmy przy ostatnim znaku ciagu s
    if(*(s+1) == '\0') {
        // 1) usuwamy wszystkie slowa, ktorych prefiksem jest s
        trie_remove_all(*next);
        // 2) wiemy, ze *next (reprezentujacy dokladnie slowo s)
        // to ostatni wierzcholek, ktory jeszcze zostal, wiec usuwamy go
        free(*next);
        *next = NULL;
        return 1;
    }

    // niezmiennik: *(s+1) != '\0'
    int remove_result = trie_remove(*next, s + 1);
    return remove_result;
}

int trie_add(trie* root, const char* s) {
    assert(root);
    if(*s == '\0') return 0;
    trie** next = trie_next_node(root, *s);
    if(*next == NULL) {
        assert(root->ac);
        a_class* new_a_class = a_class_list_add(root->ac, NULL);
        if(new_a_class == NULL) {
            return -1;
        }

        *next = trie_create_node(new_a_class);
        if(*next == NULL) {
            return -1;
        }

        // teraz juz cos dodalismy do drzewa, wiec jesli reszta sie powiedzie, to mozna zwrocic 1
        if(trie_add(*next, s+1) == -1) {
            // jesli byl blad to musimy usunac czesciowo utworzony ciag
            // niezmiennik: *next jest ostatnim wierzcholkiem w stworzonym dopiero poddrzewie

            free(*next);
            *next = NULL;

            return -1;
        }
        return 1;
    }
    else {
        // wstawiamy kolejne znaki ciagu s i propagujemy informacje o wyniku funkcji
        return trie_add(*next, s + 1);
    }
}

trie* trie_find(trie* trie_root, const char* s) {
    if(*s == '\0')
        return trie_root;
    trie** next = trie_next_node(trie_root, *s);
    if(*next == NULL)
        return NULL;
    return trie_find(*next, s + 1);
}

int trie_exists(trie* root, const char* s) {
    return trie_find(root, s) != NULL;
}