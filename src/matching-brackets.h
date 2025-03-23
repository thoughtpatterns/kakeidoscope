#ifndef matching_brackets_h_INCLUDED
#define matching_brackets_h_INCLUDED

#include "config.h"
#include <stddef.h>

enum Chirality { Achiral, Left, Right };

struct Bracket {
	enum Chirality h;
	size_t t /* bracket type */, y, x;
	int n; /* nest level */
	struct Bracket *next;
};

/* NOTE: if using matching_brackets to read a file view, add the view's y-offset
 * to each Bracket's y value in the output.
 */
struct Bracket *matching_brackets(const char *);

#endif
