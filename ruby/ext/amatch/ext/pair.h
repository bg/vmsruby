#ifndef PAIR_H_INCLUDED
#define PAIR_H_INCLUDED

#include "ruby.h"

enum { PAIR_ACTIVE = 1, PAIR_INACTIVE = 2 };

typedef struct PairStruct {
    char fst;
    char snd;
    char status;
    char _align_;
} Pair;

typedef struct PairArrayStruct {
    Pair *pairs;
    int len;
} PairArray;

PairArray *PairArray_new(VALUE tokens);
#define pair_equal(a, b) \
    ((a).fst == (b).fst && (a).snd == (b).snd && ((a).status & (b).status & PAIR_ACTIVE))
double pair_array_match(PairArray *self, PairArray *other);
void pair_array_destroy(PairArray *pair_array);
void pair_print(Pair pair);
void pair_array_reactivate(PairArray *self);

#endif
  /* vim: set et cindent sw=4 ts=4: */ 
