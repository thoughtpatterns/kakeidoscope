# kakeidoscope

A plugin for Kakoune which implements simple rainbow bracket highlighting.
It does not parse language features, and will thus highlight comments. See
See `/CHANGELOG.md` for history.

## Installation

```
cargo install kakeidoscope
```

## Usage

To load the necessary options and wrapper functions for `kakeidoscope`,
place the below snippet into your configuration, which loads
`/rc/kakeidoscope.kak`. Note that the `init` subcommand requires the _default_
cargo feature, `init`.

```
evaluate-commands %sh{ kakeidoscope init }
```

The below snippet will additonally automatically highlight all windows.

```
hook global WinCreate '.*' kakeidoscope-enable-window
```

The below options are passed to `kakeidoscope` via the Kakoune command
`kakeidoscope-highlight`.

```
declare-option int kakeidoscope_faces red yellow green cyan blue magenta
declare-option regex kakeidoscope_regex '[()[\]{}]'
```

For pre-`v1.0.0` configurations, change the `kakeidoscope_pairs` option to
a regex option, `kakeidoscope_regex`, as above. `kakeidoscope_regex` should
contain only characters in "`()[]{}<>`", as others will be ignored.

See `kakeidoscope help highlight` for detail on the binary's command-line
options.

## Examples

- Given `{(])}`, the `{}` and `()` pair would be highlighted (with `{}` as
  top-level and `()` as once-nested), and the `]` would be ignored, as it does
  not close a pair.
- Given `{([)}`, the `{`, `(`, and `[` would be highlighted (with `{` as
  top-level, `(` as once-nested, and `[` as twice-nested), and the `)` and `}`
  would be ignored, as neither closes a pair.

Note that this plugin's behavior is not identical to Kakoune's `show-matching`
highlighter, as we use stricter rules to find a pair.
