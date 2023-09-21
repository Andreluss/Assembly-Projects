#include "a_class.h"
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <assert.h>

a_class* a_class_list_add(a_class* list, char* name) {
    // tworzymy nowa klase - nowy (niepodpiety jeszcze) element listy
    a_class* node = (a_class*) malloc(sizeof(a_class));
    if(node == NULL) {
        return NULL;
    }

    // 1) ustawiamy nazwe klasy
    if(name != NULL) {
        node->name = strdup(name);
        if(node->name == NULL) {
            free(node);
            return NULL;
        }
    }
    else {
        node->name = NULL;
    }

    // 2) ustawiamy reprezentanta na samego siebie
    node->rep = node;

    // 3) ustawiamy range na 0
    node->rank = 0;

    // 4) wstawiamy miedzy [list] ac [list->next]
    node->next = list->next;
    list->next = node;

    return node; // funkcja zakonczyla sie sukcesem
}

void a_class_list_delete(a_class* list) {
    if(list == NULL) return;

    // usuwamy wszystkie nastepne
    a_class_list_delete(list->next);
    list->next = NULL; // nie zostawiamy dangling pointer'ac

    // usuwamy nazwe klasy, jesli jest wpisana
    if(list->name != NULL) {
        free(list->name);
        list->name = NULL;
    }

    free(list);
}

a_class* a_class_fu_find(a_class* ac) {
    if(ac->rep != ac)
        ac->rep = a_class_fu_find(ac->rep);
    return ac->rep;
}

int a_class_fu_new_name(char** name1, char** name2, char** new_name) {
    if(*name1 != NULL) {
        if(*name2 != NULL) {
            // przypadek [str] [str]

            if(strcmp(*name1, *name2) == 0) {
                // jesli nazwy sa takie same
                *new_name = *name1;

                *name1 = NULL;

                free(*name2);
                *name2 = NULL;
            }
            else {
                // jesli nazwy sa rozne
                size_t len1 = strlen(*name1);
                size_t len2 = strlen(*name2);
                *new_name = (char*) malloc(sizeof(char) * (len1 + len2 + 1));
                if(*new_name == NULL) {
                    return -1;
                }
                strcpy(*new_name, *name1);
                strcat(*new_name, *name2);

                free(*name1);
                *name1 = NULL;

                free(*name2);
                *name2 = NULL;
            }
        }
        else {
            // przypadek [str] [null]
            *new_name = *name1;
            *name1 = NULL;
        }
    }
    else {
        if(*name2 != NULL) {
            // przypadek [null] [str]
            *new_name = *name2;
            *name2 = NULL;
        }
        else {
            // przypadek [null] [null]
            *new_name = NULL;
            // wlaciwie bez zmian
        }
    }
    return 0;
}

int a_class_fu_union(a_class* ac1, a_class* ac2) {
    // znajdujemy reprezentantow
    ac1 = a_class_fu_find(ac1);
    ac2 = a_class_fu_find(ac2);

    // jesli juz sa polaczeni
    if(ac1 == ac2)
        return 0;

    // obslugujemy zmiane nazw
    char* new_name = NULL;
    if(a_class_fu_new_name(&(ac1->name), &(ac2->name), &new_name) == -1) {
        errno = ENOMEM;
        return -1;
    }
    assert(ac1->name == NULL && ac2->name == NULL); // TODO: DEBUG

    // aktualizujemy reprezentanta
    if(ac1->rank <= ac2->rank) { // ac1 --> ac2
        ac1->rep = ac2;
        ac2->name = new_name;

        if(ac1->rank == ac2->rank)
            ac2->rank++;
    }
    else { // ac1 <-- ac2
        ac2->rep = ac1;
        ac1->name = new_name;
    }

    return 1;
}
