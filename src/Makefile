# kakeidoscope - rainbow brackets for kakoune
# see LICENSE file for copyright and license details.

.POSIX:

include config.mk

OBJ = kakeidoscope.o

all: kakeidoscope

.c.o:
	$(CC) -o $@ -c $(KAKCFLAGS) $<

kakeidoscope: $(OBJ)
	$(CC) $(OBJ) -o $@

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
