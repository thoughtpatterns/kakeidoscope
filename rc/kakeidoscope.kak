### Begin public options.
declare-option str-list kakeidoscope_faces red yellow green cyan blue magenta
declare-option str-list kakeidoscope_pairs "{" "}" "(" ")" "[" "]"
### End public options.

declare-option range-specs kakeidoscope_range 0
declare-option int kakeidoscope_timestamp 0

define-command -docstring "generate a bracket highlighter for the active buffer" kakeidoscope-highlight %{
	evaluate-commands %sh{
		if [ "$kak_opt_kakeidoscope_timestamp" -eq "$kak_timestamp" ]
		then
			exit
		fi

		fifo()
		{
			mkfifo "$(mktemp -u "${TMPDIR-/tmp}/kakeidoscope.XXXXXX" | tee "$kak_response_fifo")" &
			cat "$kak_response_fifo"
		}

		regex()
		{
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

		selections="$(fifo)"
		selections_desc="$(fifo)"

		printf %s "evaluate-commands -draft -no-hooks %{
			try %{
				execute-keys '%s$(regex)<ret>)'
				echo -to-file '$selections' %val{selections}
				echo -to-file '$selections_desc' %val{selections_desc}
			} catch %{
				echo -to-file '$selections'
				echo -to-file '$selections_desc'
			}
		}" > "$kak_command_fifo"

		kakeidoscope highlight                  \
			--faces $kak_opt_kakeidoscope_faces \
			--pairs $kak_opt_kakeidoscope_pairs \
			--selections "$selections"          \
			--selections-desc "$selections_desc"

		rm "$selections" "$selections_desc"
	}

	set window kakeidoscope_timestamp %val{timestamp}
}

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
