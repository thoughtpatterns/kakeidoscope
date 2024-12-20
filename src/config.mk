# see LICENSE file for copyright and license details.

VERSION = 1.0

MB = matching-brackets/src

PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man

KAKCFLAGS = -std=c99 -O3 -g -D_POSIX_C_SOURCE=200809L -Wall -Wextra -Werror \
	-pedantic -Wshadow -Wdeclaration-after-statement -Wunused-macros \
	-Wno-unused-parameter

# fortify
KAKCFLAGS += -Wno-stringop-overflow

CC = cc
