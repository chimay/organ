" vim: set ft=vim fdm=indent iskeyword&:

" Stair
"
" Indent helpers

" ---- script constants

if exists('s:indent_pattern')
	unlockvar s:indent_pattern
endif
let s:indent_pattern = organ#crystal#fetch('pattern/indent')
lockvar s:indent_pattern

if exists('s:rep_one_char')
	unlockvar s:rep_one_char
endif
let s:rep_one_char = organ#crystal#fetch('filetypes/repeated_one_char_heading')
lockvar s:rep_one_char

" ---- generic

fun! organ#stair#info (...)
	" Various info about indent
	if a:0 > 0
		let object = a:1
	else
		let object = line('.')
	endif
	if type(object) == v:t_number
		let linum = object
		let line = getline(linum)
	elseif type(object) == v:t_string
		let line = object
	endif
	if a:0 > 1
		let tabstop = a:2
	else
		let tabstop = &tabstop
	endif
	if a:0 > 2
		let shiftwidth = a:3
	else
		let shiftwidth = shiftwidth ()
	endif
	let indent = {}
	let indent.tabstop = tabstop
	let indent.shiftwidth = shiftwidth
	let indent.string = line->matchstr(s:indent_pattern)
	let indent.tabs = indent.string->count("\t")
	let indent.spaces = indent.string->count(' ')
	let indent.total = indent.tabs * indent.tabstop + indent.spaces
	let indent.level = indent.total / shiftwidth
	let indent.remainder = indent.total % shiftwidth
	return indent
endfun

fun! organ#stair#tabspaces (indentnum, ...)
	" Indent string with tab & spaces adding up to indentnum
	let indentnum = a:indentnum
	if a:0 > 0
		let tabstop = a:1
	else
		let tabstop = &tabstop
	endif
	if a:0 > 1
		let shiftwidth = a:2
	else
		let shiftwidth = shiftwidth ()
	endif
	let indent = {}
	let indent.tabstop = tabstop
	let indent.shiftwidth = shiftwidth
	let indent.tabs = indentnum / tabstop
	let indent.spaces = indentnum % tabstop
	let indent.total = indentnum
	let indent.level = indent.total / shiftwidth
	let indent.remainder = indent.total % shiftwidth
	let indent.string = repeat("\t", indent.tabs) .. repeat(' ', indent.spaces)
	return indent
endfun

fun! organ#stair#basic_level_pattern (minlevel = 1, maxlevel = s:maxlevel)
	" Pattern of indent between minlevel and maxlevel
	let min = (a:minlevel - 1) * &tabstop
	let max = (a:maxlevel - 1) * &tabstop
	" ---- pattern
	let pattern = '\m'
	let tabnum = 0
	while v:true
		let pattern ..= '^\t\{' .. tabnum .. '}'
		let pattern ..= ' \{' .. min .. ',' .. max .. '}\S'
		let tabnum += 1
		let min -= &tabstop
		let max -= &tabstop
		let min = max([min, 0])
		if max >= 0
			let pattern ..= '\|'
		else
			break
		endif
	endwhile
	return pattern
endfun

" --- indent headlines

fun! organ#stair#is_indent_headline_file ()
	" Whether headlines are indent defined in current file
	return s:rep_one_char->index(&filetype) < 0 && &foldmethod ==# 'indent'
endfun

fun! organ#stair#is_on_headline ()
	" Whether current line is an indent headline
	let linum = line('.')
	if linum == 1
		return v:true
	endif
	let current = organ#stair#info ()
	let next = organ#stair#info (linum + 1)
	return current.total < next.total
endfun

fun! organ#stair#level_pattern (minlevel = 1, maxlevel = s:maxlevel)
	" Indent headline pattern, level between minlevel and maxlevel
	let minlevel = a:minlevel
	let maxlevel = a:maxlevel
	" ---- indent options
	let tabstop = &tabstop
	let shiftwidth = shiftwidth ()
	" ---- mix of spaces and tabs ?
	let mixed = v:true
	if &expandtab
		let mixed = v:false
	endif
	" ---- pattern
	let first_indentnum = (minlevel - 1) * shiftwidth
	let second_indentnum = first_indentnum + shiftwidth
	let pattern = '\m'
	for level in range(minlevel, maxlevel)
		let first_tabs = first_indentnum / tabstop
		let first_spaces = first_indentnum % tabstop
		let second_tabs = second_indentnum / tabstop
		let second_spaces = second_indentnum % tabstop
		let pattern ..= '^\%(^ \{' .. first_indentnum .. '}\|'
		let pattern ..= '^\t\{' .. first_tabs .. '}'
		let pattern ..= ' \{' .. first_spaces .. '}\)\ze'
		let pattern ..= '\S.*\n'
		let pattern ..= '\%(^ \{' .. second_indentnum .. '}\|'
		let pattern ..= '^\t\{' .. second_tabs .. '}'
		let pattern ..= ' \{' .. second_spaces .. '}\)'
		let pattern ..= '\S'
		if level < maxlevel
			let pattern ..= '\|'
		endif
		let first_indentnum += shiftwidth
		let second_indentnum += shiftwidth
	endfor
	return pattern
endfun

fun! organ#stair#subtree_tail_level_pattern (minlevel = 1, maxlevel = s:maxlevel)
	" Indent subtree tail pattern, level between minlevel and maxlevel
	let minlevel = a:minlevel
	let maxlevel = a:maxlevel
	" ---- indent options
	let tabstop = &tabstop
	let shiftwidth = shiftwidth ()
	" ---- mix of spaces and tabs ?
	let mixed = v:true
	if &expandtab
		let mixed = v:false
	endif
	" ---- pattern
	let first_indentnum = minlevel * shiftwidth
	let second_indentnum = first_indentnum - shiftwidth
	let pattern = '\m'
	for level in range(minlevel, maxlevel)
		let first_tabs = first_indentnum / tabstop
		let first_spaces = first_indentnum % tabstop
		let second_tabs = second_indentnum / tabstop
		let second_spaces = second_indentnum % tabstop
		let pattern ..= '^\%(^ \{' .. first_indentnum .. '}\|'
		let pattern ..= '^\t\{' .. first_tabs .. '}'
		let pattern ..= ' \{' .. first_spaces .. '}\)'
		let pattern ..= '\S.*\n'
		let pattern ..= '\%(^ \{' .. second_indentnum .. '}\|'
		let pattern ..= '^\t\{' .. second_tabs .. '}'
		let pattern ..= ' \{' .. second_spaces .. '}\)\zs'
		let pattern ..= '\S'
		if level < maxlevel
			let pattern ..= '\|'
		endif
		let first_indentnum += shiftwidth
		let second_indentnum += shiftwidth
	endfor
	return pattern
endfun

fun! organ#stair#subtree_tail (properties)
	" Tail linum of indent subtree
	let properties = a:properties
	let linum = properties.linum
	let level = properties.level
	call cursor(linum, 1)
	let tail_pattern = organ#stair#subtree_tail_level_pattern (1, level)
	let flags = organ#utils#search_flags ('forward', 'dont-move', 'dont-wrap')
	let forward_linum = search(tail_pattern, flags)
	if forward_linum == 0
		return line('$')
	endif
	return forward_linum
endfun
