decl -hidden int kakeidoscope_timestamp 0
decl -hidden int-list kakeidoscope_window 0 0 0 0

# the kakeidoscope binary takes arguments "<filename> <window_y>"
# and prints a command of the following form.
#     set window kakeidoscope_range %val{timestamp} '<y>.<x>+1|<face>'...
def -hidden -docstring "color each selection" kakeidoscope-selections %{
	eval -draft -itersel -no-hooks %sh{
		y="${kak_selection_desc%%.*}"
		t="$(mktemp "${TMPDIR:-/tmp}/kakeidoscope.XXXXXX")"
		printf "%s" "$kak_selection" > "$t"

		[ "$?" -eq 0 ] \
			&& printf "%s\n" "$(kakeidoscope "$t" "$y")" \
			|| printf "fail kakeidoscope exited with non-zero status $?\n"

		rm -f "$t"
	}
}

# %val{window_range} is zero-indexed, so we add an offset of one
def -hidden -docstring "color the current view" kakeidoscope-view %{
	eval -draft %sh{
		set -- $kak_window_range
		printf "%s\n%s\n" "select $(($1 + 1)).1,$(($1 + $3 + 1)).1" "kakeidoscope-selections"
	}
}

def -hidden -docstring "color the entire buffer" kakeidoscope-buffer %{
	eval -draft %{
		exec "%%"
		kakeidoscope-selections
	}
}

# if the timestamp and the view have changed, recolor the buffer; if only the
# timestamp has changed, instead recolor just the view.
def -hidden -docstring "choose whether to color the view or the buffer" kakeidoscope-color %{
	eval %sh{
		[ "$kak_opt_kakeidoscope_timestamp" -eq "$kak_timestamp" ] && return

		set -- $kak_opt_kakeidoscope_window $kak_window_range
		{ [ "$1" -ne "$5" ] || [ "$3" -ne "$7" ]
		} && printf "kakeidoscope-buffer\n" || printf "kakeidoscope-view\n"
	}
	set window kakeidoscope_timestamp %val{timestamp}
	set window kakeidoscope_window %val{window_range}
}

def -docstring "enable kakeidoscope at window scope" kakeidoscope-enable-window %{
	hook -group kakeidoscope window NormalIdle .* kakeidoscope-color
	hook -group kakeidoscope window InsertIdle .* kakeidoscope-color
	addhl window/kakeidoscope ranges kakeidoscope_range
	kakeidoscope-buffer
}

def -docstring "disable kakeidoscope at window scope" kakeidoscope-disable-window %{
	rmhooks window kakeidoscope
	rmhl window/kakeidoscope
	unset window kakeidoscope_range
}

def -hidden -docstring "initialize kakeidoscope" kakeidoscope-init %{
	decl range-specs kakeidoscope_range
	hook global -group kakeidoscope WinCreate .* kakeidoscope-enable-window
}

hook -group kakeidoscope -once global KakBegin .* kakeidoscope-init
