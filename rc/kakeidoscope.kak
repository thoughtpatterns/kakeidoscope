### Begin public options.
declare-option str-list kakeidoscope_faces red yellow green cyan blue magenta
declare-option str-list kakeidoscope_pairs "{" "}" "(" ")" "[" "]" # For speed's sake, this variable should not be changed once set.
### End public options.

declare-option -hidden str kakeidoscope_regex %sh{
	printf %s "$kak_opt_kakeidoscope_pairs" | awk '{
		for (i = 1; i <= NF; ++i) {
			gsub(/</,      "\x01",  $i) # Use "\x01" as a placeholder, to prevent "<lt> -> <lt<gt>".
			gsub(/>/,      "<gt>",  $i)
			gsub(/\x01/,   "<lt>",  $i)
			gsub(/[\\\]]/, "\\\\&", $i)
			regex = regex $i
		}
		print "[" regex "]"
	}'
}

declare-option -hidden range-specs kakeidoscope_range 0
declare-option -hidden int kakeidoscope_running_sum 0
declare-option -hidden int kakeidoscope_timestamp 0

define-command -docstring "enable kakeidoscope at window scope" kakeidoscope-enable-window %{
	add-highlighter window/kakeidoscope ranges kakeidoscope_range
	hook -group kakeidoscope window NormalIdle .* kakeidoscope-highlight
	hook -group kakeidoscope window InsertIdle .* kakeidoscope-highlight
}

define-command -docstring "disable kakeidoscope at window scope" kakeidoscope-disable-window %{
	remove-hooks window kakeidoscope
	remove-highlighter window/kakeidoscope
	unset-option window kakeidoscope_range
	unset-option window kakeidoscope_timestamp
}

define-command -params 2 -hidden kakeidoscope-greater-or-equal %{
	set-option window kakeidoscope_running_sum %arg{1}
	set-option -add window kakeidoscope_running_sum "-%arg{2}"
	evaluate-commands -draft %{ echo %opt{kakeidoscope_running_sum} }
}

define-command -docstring "generate a bracket highlighter for the active buffer" kakeidoscope-highlight %{
	try %{
		kakeidoscope-greater-or-equal %opt{kakeidoscope_timestamp} %val{timestamp} # '>=' acts as '==', as the former cannot be greater than the latter.
	} catch %{
		try %{ kakeidoscope-highlight-impl }
	}

	set-option window kakeidoscope_timestamp %val{timestamp}
}

define-command -hidden kakeidoscope-highlight-impl %{
	evaluate-commands -draft -no-hooks %{
		execute-keys "%%s%opt{kakeidoscope_regex}<ret>)"
		evaluate-commands %sh{
			root="$(mktemp -d)"
			selections="$root/selections"
			selections_desc="$root/selections_desc"
			mkfifo "$selections" "$selections_desc"

			printf %s "
				echo -to-file '$selections' %val{selections}
				echo -to-file '$selections_desc' %val{selections_desc}
			" > "$kak_command_fifo"

			kakeidoscope highlight                  \
				--faces $kak_opt_kakeidoscope_faces \
				--pairs $kak_opt_kakeidoscope_pairs \
				--selections "$selections"          \
				--selections-desc "$selections_desc"

			rm -rf "$root"
		}
	}
}
