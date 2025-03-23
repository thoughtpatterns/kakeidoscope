#ifndef util_h_INCLUDED
#define util_h_INCLUDED

#include <stddef.h>

#define LENGTH(X) (int)(sizeof(X) / sizeof(X)[0])

void die(const char *, ...);
void *calloc_s(size_t, size_t);
void *malloc_s(size_t);
void *realloc_s(void *, size_t);

#endif
