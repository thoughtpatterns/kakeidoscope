# kakeidoscope

A plugin for Kakoune which implements simple rainbow bracket highlighting via
[matching-brackets](https://git.sr.ht/~orchid/matching-brackets). kakeidoscope
does not parse language features and will thus highlight comments. Each type of
bracket is colored independently --- by default, kakeidoscope colors `{} () []`.

kakeidoscope is fast enough to be used with idle hooks:

```
10000 balanced braces:
        0.00 real         0.00 user         0.00 sys

10000 left braces:
        0.00 real         0.00 user         0.00 sys

10000 right braces:
        0.00 real         0.00 user         0.00 sys
```

## Installation

### Install

```bash
cd ~/.config/kak/autoload
git clone --recurse-submodules https://git.sr.ht/~orchid/kakeidoscope
cd kakeidoscope/src
make install # with elevated privileges
```

### Uninstall

```bash
make uninstall # with elevated privileges
rm ~/.config/kak/autoload/kakeidoscope.kak
```

## Configuration

kakeidoscope offers two options: the faces it cycles through with each nest
level, found in `src/config.def.h`, and the bracket pairs it searches for, found
in `src/matching-brackets/src/config.def.h`. `make` will create copies of these
files as `config.h` and `src/matching-brackets/src/config.h`, which can be
edited --- then reinstalling via `make install` will update your configuration.

## Usage

`kakeidoscope.kak` will enable the necessary hooks and highlighters to
dynamically process either the current view or the entire buffer at a time. If
you'd prefer to handle highlighting separately, comment out the last line of
`kakeidoscope.kak`, then use `kakeidoscope-enable-window` and
`kakeidoscope-disable-window`.

## Debugging

_Very_ simple tests can be found in `test/` and are used only to find leaks and
manage runtime regression. Running `make debug` will enable relevant compiler
flags (if wanted, edit the `Makefile` flag `-glldb` to suit your debugger).
