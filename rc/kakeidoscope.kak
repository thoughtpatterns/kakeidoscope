### public:

declare-option str-list kakeidoscope_faces red yellow green cyan blue magenta
declare-option regex kakeidoscope_regex '[()[\]{}]'

### private:

declare-option -hidden range-specs kakeidoscope_range 0
declare-option -hidden int kakeidoscope_running_sum 0
declare-option -hidden int kakeidoscope_timestamp 0

define-command -docstring 'enable kakeidoscope at window scope' kakeidoscope-enable-window %{
	add-highlighter window/kakeidoscope ranges kakeidoscope_range
	hook -group kakeidoscope window NormalIdle '.*' kakeidoscope-highlight
	hook -group kakeidoscope window InsertIdle '.*' kakeidoscope-highlight
}

define-command -docstring 'disable kakeidoscope at window scope' kakeidoscope-disable-window %{
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

define-command -docstring 'generate a bracket highlighter for the active buffer' kakeidoscope-highlight %{
	try %{
		# We use '>=' as '==', as, here, the left operand cannot be greater than the right.
		kakeidoscope-greater-or-equal %opt{kakeidoscope_timestamp} %val{timestamp}
	} catch %{
		kakeidoscope-highlight-impl
	} catch %{}

	set-option window kakeidoscope_timestamp %val{timestamp}
}

define-command -hidden kakeidoscope-highlight-impl %{
	try %{ evaluate-commands -draft -save-regs / -no-hooks %{
		set-register / %opt{kakeidoscope_regex}
		execute-keys '%s<ret>)' # If we have no brackets, go to `catch` block.

		evaluate-commands %sh{
			root="$(mktemp -d)"
			selections="$root/selections"
			selections_desc="$root/selections_desc"
			mkfifo "$selections" "$selections_desc"

			printf %s "
				echo -to-file '$selections' %val{selections}
				echo -to-file '$selections_desc' %val{selections_desc}
			" > "$kak_command_fifo"

			eval set -- "$kak_quoted_opt_kakeidoscope_faces"

			kakeidoscope highlight             \
				--faces "$@"               \
				--selections "$selections" \
				--selections-desc "$selections_desc"

			rm -rf "$root"
		}
	}} catch %{
		# Without this fallback, if a buffer has a pair of brackets at any point, and all brackets are then
		# removed, a highlighter will persist to highlight an unrelated character, until another bracket is
		# re-inserted into thte buffer.
		set-option window kakeidoscope_range %val{timestamp}
	}
}
