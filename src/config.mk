PREFIX = /usr/local
MB = matching-brackets/src

KAKCFLAGS = -std=c99 -O3 -g -D_POSIX_C_SOURCE=200809L -Wall -Wextra -Werror \
	-pedantic -Wshadow -Wdeclaration-after-statement -Wunused-macros \
	-Wno-unused-parameter

CC = cc
