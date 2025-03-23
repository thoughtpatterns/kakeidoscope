declare-option range-specs kakeidoscope_range 0
declare-option int kakeidoscope_timestamp 0
declare-option str-list kakeidoscope_faces red yellow green cyan blue magenta
declare-option str-list kakeidoscope_brackets "{" "}" "(" ")" "[" "]"

define-command -docstring "generate a bracket highlighter for the active buffer" kakeidoscope-highlight %{
	evaluate-commands %sh{
		set -eu

		if [ "$kak_opt_kakeidoscope_timestamp" -eq "$kak_timestamp" ]
		then
			exit
		fi

		printf %s "evaluate-commands -draft -no-hooks %{
			execute-keys '%'
			echo -to-file '$kak_response_fifo' %val{selection}
		}" > "$kak_command_fifo"

		~/.local/src/kakeidoscope/target/debug/kakeidoscope highlight \
			--faces $kak_opt_kakeidoscope_faces \
			--brackets $kak_opt_kakeidoscope_brackets \
			--filename "$kak_response_fifo"
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
	unset window kakeidoscope_range
	unset window kakeidoscope_timestamp
}
