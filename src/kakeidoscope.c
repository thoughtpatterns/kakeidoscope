/* see LICENSE file for copyright and license details. */

#include "config.h"
#include "matching-brackets/src/matching-brackets.h"
#include "matching-brackets/src/util.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUF_START 64
#define DECIMAL 10
#define HL_OFFSET 7

static void make_hl(struct Bracket *);
static size_t max_face_length(void);
static size_t num_length(size_t);
static size_t strtoul_s(const char *);
static void usage(void);

/* the primary highlighter output format is
 *     set window kakeidoscope_range %val{timestamp} '<y>.<x>+1|<face>'...
 * thus, when checking whether to realloc s, we add HL_OFFSET to its length
 */

static void make_hl(struct Bracket *first)
{
	size_t f = max_face_length(), l = 0, m = 0, n = BUF_START;
	char *s = calloc_s(n, sizeof *s);

	for (struct Bracket *b = first, *v = b; b; b = b->next, v = b) {
		l = strlen(s);
		m = l + f + num_length(b->y) + num_length(b->x) + HL_OFFSET;
		if (m > n)
			s = realloc_s(s, sizeof s * (m + (n *= 2)));

		sprintf(s + l, " '%zu.%zu+1|%s'", b->y, b->x,
		    faces[b->n % LENGTH(faces)]);

		free(v);
	}

	printf("set window kakeidoscope_range %%val{timestamp}%s\n", s);

	free(s);
}

static size_t max_face_length(void)
{
	size_t l, m = 0;

	for (int i = 0; i < LENGTH(faces); ++i) {
		l = strlen(faces[i]);
		if (m < l)
			m = l;
	}

	return m;
}

static size_t num_length(size_t n)
{
	int i = !n;

	for (; n; ++i)
		n /= 10;

	return i;
}

static size_t strtoul_s(const char *s)
{
	char *e;
	size_t n = strtoul(s, &e, DECIMAL);

	if (e != s + strlen(s))
		usage();

	return n;
}

static void usage(void)
{
	die("usage: kakeidoscope <filename> <window_y> <window_x>");
}

int main(int argc, char **argv)
{
	if (argc != 4)
		usage();

	make_hl(matching_brackets(argv[1], strtoul_s(argv[2]), strtoul_s(argv[3])));

	return EXIT_SUCCESS;
}
