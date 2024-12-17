/* see LICENSE file for copyright and license details. */

#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* clear clangd warning for macro defined in config.mk */
#ifndef VERSION
#define VERSION
#endif

void die(const char *fmt, ...);
void open_file(void);

void die(const char *fmt, ...)
{
	va_list ap;

	va_start(ap, fmt);
	vfprintf(stderr, fmt, ap);
	va_end(ap);

	if (fmt[0] && fmt[strlen(fmt) - 1] == ':') {
		fputc(' ', stderr);
		perror(NULL);
	} else {
		fputc('\n', stderr);
	}

	exit(1);
}

void open_file(void) {}

int main(void)
{
	puts("kak-"VERSION);
	return EXIT_SUCCESS;
}
