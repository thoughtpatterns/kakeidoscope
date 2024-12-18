# see LICENSE file for copyright and license details.

VERSION = 1.0

MB = matching-brackets/src

PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man

KAKCFLAGS = -std=c99 -g -Og -D_POSIX_C_SOURCE=200809L -Wall -Wextra -Werror \
	-pedantic -Wshadow -Wdeclaration-after-statement -Wunused-macros \
	-Wfloat-conversion -Wno-unused-parameter -Wno-uninitialized

CC = cc
