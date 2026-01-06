## v1.0.0

* Switch to semantic versioning :)
* Fixed KakouneScript issue for which a buffer which once had brackets, and
  which no longer does, would retain a single-character erroneous highlighter
  which would persist until another bracket was inserted.
* Added simple tests to the binary, to be run with `cargo test`.
* Removed a dependency on `itertools`.
* Moved the `init` subcommand behind a (default) feature.
* Changed the user interface.
  * Before, we had
    ```
    declare-option str-list kakeidoscope_faces red green
    declare-option str-list kakeidoscope_pairs { } ( )
    ```
    and `kakeidoscope_pairs` could not be changed at runtime, as it'd be used
    at startup to construct a regex with which to find selections to pass to
    the `kakeidoscope` binary.
  * Now, we have
    ```
    declare-option int kakeidoscope_faces red green
    declare-option regex kakeidoscope_regex '[()[\]{}]'
    ```
    where, rather than define pairs with which to construct a regex, etc.,
    we define a regex, and whichever selections it finds are passed to
    `kakeidoscope`. Note that `kakeidoscope_regex` should now only find
    characters in "`()[]{}<>`", as others will be ignored.

## v0.3.2

* FIFOs are now cleaned up correctly.

## v0.3.1

* Fix long-standing occasional freeze issue.
* Reduce shell calls.

## v0.3.0

* Accept selections and selection descriptions, rather than full buffers, to
  allow as much processing as possible to happen in Kakoune.

## v0.2.3

* Fix freezes when the buffer is '-'.
