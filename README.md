# kakeidoscope

A plugin for Kakoune which implements simple rainbow bracket highlighting.
It does not parse language features and will thus highlight comments.

## Installation

```
cargo install kakeidoscope
```

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
declare-option str-list kakeidoscope_pairs "{" "}" "(" ")" "[" "]"
```

For speed's sake, `kakeidoscope_pairs` should not be modified once set.

### Examples

- Given `{(])}`, the `{}` and `()` pair would be highlighted (with `{}` as
  top-level and `()` as once-nested), and the `]` would be ignored, as it does
  not close a pair.
- Given `{([)}`, the `{`, `(`, and `[` would be highlighted (with `{` as
  top-level, `(` as once-nested, and `[` as twice-nested), and the `)` and `}`
  would be ignored, as neither closes a pair.

Note that this plugin's behavior is not identical to Kakoune's `show-matching`
highlighter, as the former uses stricter rules to find a pair.
