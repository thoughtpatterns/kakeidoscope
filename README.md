# kakeidoscope

A plugin for Kakoune which implements simple rainbow bracket highlighting ---
it does not parse language features and will thus highlight comments.

## Installation

```bash
cargo install kakeidoscope
```

## Configuration

To load the necessary options and some useful functions for `kakeidoscope`,
place the following snippet into your Kakoune configuration, which loads the
file located at `rc/kakeidoscope.kak`.

```
evaluate-commands %sh{ kakeidoscope init }
```

The following snippet will additonally automatically highlight all windows.

```
hook global WinCreate .* kakeidoscope-enable-window
```

The following options are passed to `kakeidoscope` via the Kakoune command
`kakeidoscope-highlight`. Configuring these should be enough if you rely only
on `kakeidoscope-highlight` and `kakeidoscope-enable-window` to highlight. For
more detail on the CLI options, see `kakeidoscope help highlight`.

```
declare-option str-list kakeidoscope_faces red yellow green cyan blue magenta
declare-option str-list kakeidoscope_brackets "{" "}" "(" ")" "[" "]"
```
