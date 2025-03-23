#ifndef config_def_h_INCLUDED
#define config_def_h_INCLUDED

#include "util.h"

struct BracketType {
	const char l, r;
};

/* bracket pairs to check for. it's recommended to order types by expected
 * frequency.
 */
static const struct BracketType brackets[] = {
    {'{', '}'},
    {'(', ')'},
    {'[', ']'},
 /* {'<', '>'}, */
};

/* faces to cycle between for each bracket nest level. always leave at least one
 * face.
 */
static const char *faces[] = {
    "red", "yellow", "green", "cyan", "blue", "magenta"
};

#endif
