decl -hidden int kakeidoscope_timestamp 0
decl -hidden int-list kakeidoscope_window 0 0 0 0

# the kakeidoscope binary takes arguments "<filename> <window_y> <window_x>"
# and prints a command of the form
#     set window kakeidoscope_range %val{timestamp} '<y>.<x>+1|<face>'...

def -docstring "color each selection" kakeidoscope-selections %{
	eval -draft -itersel -save-regs "f|" -no-hooks %{
		reg f nop
		reg pipe %{
			set -- $kak_window_range

			t="$(mktemp "${TMPDIR:-/tmp}/kakeidoscope.XXXXXX")"
			cat > "$t"

			[ "$?" -eq 0 ] \
				&& printf "%s\n" "$(kakeidoscope "$t" "$1" "$2")" \
				|| printf "reg f fail kakeidoscope exited with non-zero status $?\n" > "$kak_command_fifo"

			rm -f "$t"
		}
		exec '|<ret>":y:<ret>'
		%reg{f}
	}
}

def -docstring "color the current view" kakeidoscope-view %{
	eval -draft %sh{
		set -- $kak_window_range
		printf "%s\n%s\n" "select $(($1 + 1)).1,$(($1 + $3 + 1)).1" "kakeidoscope-selections"
	}
}

def -docstring "color the entire buffer" kakeidoscope-buffer %{
	eval -draft %{
		exec "%%"
		kakeidoscope-selections
	}
}

# if the timestamp and the view have changed, recolor the buffer; if only the
# timestamp has changed, instead recolor just the view

def -docstring "choose whether to color the view or the buffer" kakeidoscope-color %{
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
	kakeidoscope-color
}

def -docstring "disable kakeidoscope at window scope" kakeidoscope-disable-window %{
	rmhooks window kakeidoscope
	rmhl window/kakeidoscope
	unset kakeidoscope_range window
}

def -docstring "initialize kakeidoscope" kakeidoscope-init %{
	decl range-specs kakeidoscope_range
	hook global -group kakeidoscope WinCreate .* kakeidoscope-enable-window
}

# hook -once global KakBegin .* kakeidoscope-init
