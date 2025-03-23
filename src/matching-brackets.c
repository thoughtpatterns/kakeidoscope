#include "matching-brackets.h"
#include "config.h"
#include "util.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* helpers */

static FILE *open_file(const char *);
static struct Bracket *read_file(FILE *);

FILE *open_file(const char *path)
{
	FILE *f;

	if (!(f = fopen(path, "r")))
		die("fopen(%s):", path);

	return f;
}

struct Bracket *read_file(FILE *f)
{
	enum Chirality h = Achiral;
	int n, nest[LENGTH(brackets)] = {0};
	size_t u = LENGTH(brackets), x = 1, y = 0;
	struct Bracket *head = NULL, *new = NULL;

	for (int c; (c = getc(f)) != EOF; ++x) {
		if (c == '\n') {
			++y, x = 0;
			continue;
		}

		for (size_t t = 0; t < LENGTH(brackets); ++t) {
			h = (c == brackets[t].l)   ? Left
			    : (c == brackets[t].r) ? Right
			                           : Achiral;
			/* either we have a left bracket, or a right bracket which matches
			 * the newest unmatched left bracket.
			 */
			if (!(h == Left || (h == Right && t == u)))
				continue;

			if (h == Left)
				n = nest[t]++, u = t;
			else {
				/* for a right bracket, we work backward to find the closest
				 * unmatched bracket (and set u to its type if found, and
				 * LENGTH(brackets) otherwise).
				 */
				n = --nest[t], u = LENGTH(brackets);
				for (struct Bracket *b = head; b; b = b->next) {
					if (nest[b->t] - 1 == b->n && b->h == Left) {
						u = b->t;
						break;
					}
				}
			}

			new = malloc_s(sizeof *new);
			*new = (struct Bracket){h, t, y, x, n, head};
			head = new;

			break;
		}
	}

	return head;
}

/* header */

struct Bracket *matching_brackets(const char *path)
{
	return read_file(open_file(path));
}
