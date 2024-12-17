# kakeidoscope - rainbow brackets for kakoune
# see LICENSE file for copyright and license details.

.POSIX:

include config.mk

CFG = config.h $(MB)/config.h
LIB = $(MB)/matching-brackets.h
SRC = kakeidoscope.c $(MB)/matching-brackets.c
OBJ = $(SRC:.c=.o)

all: kakeidoscope

.c.o:
	$(CC) -o $@ -c $(KAKCFLAGS) $<

config.h:
	cp config.def.h $@

$(MB)/config.h:
	cp $(MB)/config.def.h $@

$(OBJ): $(CFG)

kakeidoscope: $(OBJ)
	$(CC) $(LIB) $(OBJ) -o $@

clean:
	rm -f kakeidoscope $(OBJ)

install: all
	mkdir -p "$(DESTDIR)$(PREFIX)/bin"
	cp -f kakeidoscope "$(DESTDIR)$(PREFIX)/bin"
	chmod 755 "$(DESTDIR)$(PREFIX)/bin/kakeidoscope"
	mkdir -p "$(DESTDIR)$(MANPREFIX)/man1"
	cp -f kakeidoscope.1 "$(DESTDIR)$(MANPREFIX)/man1"
	chmod 644 "$(DESTDIR)$(MANPREFIX)/man1/kakeidoscope.1"

uninstall:
	rm -f "$(DESTDIR)$(PREFIX)/bin/kakeidoscope"
	rm -f "$(DESTDIR)$(MANPREFIX)/man1/kakeidoscope.1"

.PHONY: all clean install uninstall
