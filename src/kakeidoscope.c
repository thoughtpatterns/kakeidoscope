/* see LICENSE file for copyright and license details. */

#include "config.h"
#include "matching-brackets/src/config.h"
#include "matching-brackets/src/matching-brackets.h"
#include <stdio.h>
#include <stdlib.h>

/* clear clangd warning for macro defined in config.mk */
#ifndef VERSION
#define VERSION
#endif

int main(void)
{
	puts("kakleidoscope-" VERSION);
	return EXIT_SUCCESS;
}
