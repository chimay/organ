" vim: set ft=vim fdm=indent iskeyword&:

" Table
"
" Table operations

" ---- helpers

fun! organ#table#char ()
	" Tables column char
	return '|'
endfun

fun! organ#table#generic_pattern ()
	" Generic table line pattern
	let pattern = '\m^\s*|'
	let pattern ..= '\%([^|]*|\)\+'
	return pattern
endfun

fun! organ#table#is_in_table ()
	" Whether current line is in a table
	let line = getline('.')
	return line =~ organ#table#generic_pattern ()
endfun

fun! organ#table#head (move = 'dont-move')
	" First line of table
	let move = a:move
	let not_table_pattern = '\m^[^|]*$'
	let flags = organ#utils#search_flags ('backward', move, 'dont-wrap')
	let linum = search(not_table_pattern, flags)
	if linum == 0
		echomsg 'organ table head : not found'
		return 1
	endif
	return linum + 1
endfun

fun! organ#table#tail (move = 'dont-move')
	" Last line of table
	let move = a:move
	let not_table_pattern = '\m^[^|]*$'
	let flags = organ#utils#search_flags ('forward', move, 'dont-wrap')
	let linum = search(not_table_pattern, flags)
	if linum == 0
		echomsg 'organ table tail : not found'
		return line('$')
	endif
	return linum - 1
endfun

" ---- alignment

fun! organ#table#align (char = '|')
	" Align char in all table lines
endfun
