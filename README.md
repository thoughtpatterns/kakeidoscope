# kakeidoscope

A plugin for Kakoune which implements simple rainbow bracket highlighting via
[matching-brackets](https://git.sr.ht/~orchid/matching-brackets). kakeidoscope
does not parse language features and will thus highlight comments; it will,
however, ignore unmatched right brackets. Each type of bracket is colored
independently.

kakeidoscope is fast enough to be used with idle hooks --- you can find _very_
simple tests in `time/`.

```
10000 balanced braces:
real    0m 0.02s
user    0m 0.01s
sys     0m 0.00s

10000 unbalanced braces:
real    0m 0.00s
user    0m 0.00s
sys     0m 0.00s
```

## Installation

### Install

```bash
git clone --recurse-submodules https://git.sr.ht/~orchid/kakeidoscope
cd kakeidoscope/src
make install # with elevated privileges
cd ..
cp rc/kakeidoscope.kak ~/.config/kak/autoload
```

### Uninstall

```bash
make uninstall # with elevated privileges
rm ~/.config/kak/autoload/kakeidoscope.kak
```

## Configuration

kakeidoscope offers two options: the faces it cycles through with each nest
level, found in `src/config.def.h`; and the bracket pairs it searches for, found
in `src/matching-brackets/src/config.def.h`. Edit each file accordingly, then
reinstall.

## Usage

`kakeidoscope.kak` will enable the necessary hooks and highlighters --- if
you'd prefer to handle this separately, use `kakeidoscope-enable-window` and
`kakeidoscope-disable-window`.
