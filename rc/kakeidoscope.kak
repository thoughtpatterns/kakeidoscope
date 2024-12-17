decl bool kakeidoscope_enabled true
decl str-list kakeidoscope_colors red yellow green cyan blue magenta

decl -hidden int kakeidoscope_timestamp 0
decl -hidden int-list kakeidoscope_window 0 0 0 0

def -docstring "enable kakeidoscope at window scope" kakeidoscope-enable-window %{
	hook -group kakeidoscope window NormalIdle .* kakeidoscope-color
	hook -group kakeidoscope window InsertIdle .* kakeidoscope-color
	addhl window/kakeidoscope ranges kakeidoscope
	kakeidoscope-color
}

def -docstring "disable kakeidoscope at window scope" kakeidoscope-disable-window %{
	rmhooks window kakeidoscope
	rmhl window/kakeidoscope
}

def -docstring "color the view or buffer" kakeidoscope-color %{
	eval %sh{
		# if the timestamp and the view have changed, recolor the buffer
		# if only the timestamp has changed, instead recolor just the view

		[ "$kak_opt_kakeidoscope_timestamp" -eq "$kak_timestamp" ] && return

		set -- $kak_opt_kakeidoscope_window $kak_window_range
		while [ "$#" -gt 0 ]; do
			[ "$1" -ne "$5" ] && printf "kakeidoscope-buffer\n" && return
			shift 2 # check only <coord_y> and <height>
		done
		printf "kakeidoscope-view\n"
	}
	set window kakeidoscope_timestamp %val{timestamp}
	set window kakeidoscope_window %val{window_range}
}

# the kakeidoscope binary takes arguments "<window_y> <window_h> <colors>..."
# and returns a command of the following form:
#    decl range-specs 
#    <x>.<y>+1|<color>

def -docstring "color the current view" kakeidoscope-view %{
	nop
}

def -docstring "color the entire buffer" kakeidoscope-buffer %{
	nop
}

