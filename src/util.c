#include "util.h"
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

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

	exit(EXIT_FAILURE);
}

void *calloc_s(size_t n, size_t s)
{
	void *p;

	if (!(p = calloc(n, s)))
		die("calloc:");

	return p;
}

void *malloc_s(size_t s)
{
	void *p;

	if (!(p = malloc(s)))
		die("malloc:");

	return p;
}

void *realloc_s(void *p, size_t s)
{
	void *t;

	if (!(t = realloc(p, s)))
		die("realloc:");

	return t;
}
