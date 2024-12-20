/* see LICENSE file for copyright and license details. */

#include "config.h"
#include "matching-brackets/src/matching-brackets.h"
#include "matching-brackets/src/util.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void make_hl(struct Bracket *, size_t);
static size_t num_length(size_t);
static size_t strtoul_s(const char *);
static void usage(void);

static void make_hl(struct Bracket *head, size_t y)
{
	const size_t hl_offset = 7; /* non-var chars in <spc>'<y>.<x>+1|<face>' */
	size_t n = 64 /* arbitrary */, j = 0, k = 0, f, yy;
	char *s = calloc_s(n, sizeof *s);

	size_t l[length_faces];
	for (size_t i = 0; i < length_faces; ++i)
		l[i] = strlen(faces[i]);

	for (struct Bracket *b = head, *v; b; b = v) {
		f = b->n % length_faces, yy = b->y + y,
		k += (j = num_length(yy) + num_length(b->x) + l[f] + hl_offset);

		if (k > n)
			s = realloc_s(s, sizeof s * (n = k * 2));
		sprintf(s + k - j, " '%zu.%zu+1|%s'", yy, b->x, faces[f]);

		v = b->next;
		free(b);
	}

	printf("set window kakeidoscope_range %%val{timestamp}%s\n", s);
	free(s);
}

static size_t num_length(size_t n)
{
	size_t l = 1;

	for (size_t p = 10; p <= n; p *= 10)
		++l;

	return l;
}

static size_t strtoul_s(const char *s)
{
	char *e;
	size_t n = strtoul(s, &e, 10);

	if (e != s + strlen(s)) /* s doesn't entirely comprise a number */
		usage();

	return n;
}

static void usage(void) { die("usage: kakeidoscope <filename> <window_y>"); }

int main(int argc, char **argv)
{
	if (argc != 3)
		usage();

	make_hl(matching_brackets(argv[1]), strtoul_s(argv[2]));

	return EXIT_SUCCESS;
}
