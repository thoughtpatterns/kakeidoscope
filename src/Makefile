# kakeidoscope - rainbow brackets for kakoune

.POSIX:

include config.mk

CFG = config.h
LIB = matching-brackets.h util.h
SRC = kakeidoscope.c matching-brackets.c util.c
OBJ = $(SRC:.c=.o)

all: kakeidoscope

debug: KAKCFLAGS += -ggdb -Og
debug: kakeidoscope

.c.o:
	$(CC) -c -o $@ $(KAKCFLAGS) $<

$(CFG):
	cp $(@:.h=.def.h) $@

$(OBJ): $(CFG)

kakeidoscope: $(OBJ)
	$(CC) -o $@ $(KAKCFLAGS) $^

clean:
	rm -f kakeidoscope $(OBJ)

install: all
	mkdir -p "$(DESTDIR)$(PREFIX)/bin"
	cp -f kakeidoscope "$(DESTDIR)$(PREFIX)/bin"
	chmod 755 "$(DESTDIR)$(PREFIX)/bin/kakeidoscope"

uninstall:
	rm -f "$(DESTDIR)$(PREFIX)/bin/kakeidoscope"

.PHONY: all debug clean install uninstall
