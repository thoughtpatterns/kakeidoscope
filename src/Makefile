# kakeidoscope - rainbow brackets for kakoune
# see LICENSE file for copyright and license details.

.POSIX:

include config.mk

CFG = config.h $(MB)/config.h
LIB = $(MB)/matching-brackets.h $(MB)/util.h
SRC = kakeidoscope.c $(MB)/matching-brackets.c $(MB)/util.c
OBJ = $(SRC:.c=.o)

all: kakeidoscope

debug: KAKCFLAGS += -Og
debug: kakeidoscope

.c.o:
	$(CC) -o $@ -c $(KAKCFLAGS) $<

$(CFG):
	cp $(@:.h=.def.h) $@

$(OBJ): $(CFG)

kakeidoscope: $(OBJ)
	$(CC) $(LIB) $(OBJ) -o $@

clean:
	rm -f kakeidoscope $(OBJ)

install: all
	mkdir -p "$(DESTDIR)$(PREFIX)/bin"
	cp -f kakeidoscope "$(DESTDIR)$(PREFIX)/bin"
	chmod 755 "$(DESTDIR)$(PREFIX)/bin/kakeidoscope"

uninstall:
	rm -f "$(DESTDIR)$(PREFIX)/bin/kakeidoscope"

.PHONY: all debug clean install uninstall
