#ifndef config_def_h_INCLUDED
#define config_def_h_INCLUDED

#include "matching-brackets/src/util.h"

/* faces to cycle between for each bracket nest level. always leave at least one
 * face.
 */
static const char *faces[] = {
    "red", "yellow", "green", "cyan", "blue", "magenta"
};

#endif
