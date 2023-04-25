" vim: set ft=vim fdm=indent iskeyword&:

" Bush
"
" Operations on orgmode or markdown lists hierarchy

" ---- script constants

if ! exists('s:indent_length')
	let s:indent_length = organ#crystal#fetch('list/indent/length')
	lockvar s:indent_length
endif

" ---- new list item

fun! organ#bush#new ()
	" New list item
	" TODO
	let properties = organ#colibri#properties ()
	let level = properties.level
	let line = organ#bird#char()->repeat(level)
	let line ..= ' '
	let linelist = [line, '']
	call append('.', linelist)
	let linum = line('.') + 1
	call cursor(linum, 1)
	let colnum = col('$')
	call cursor(linum, colnum)
	startinsert!
endfun

" ---- promote & demote

" -- current only

fun! organ#bush#promote ()
	" Promote list item
	let line = getline('.')
	if line =~ '^\s\+\*'
		let line = substitute(line, '*', '+', '')
	elseif line =~ '^\s*+'
		let line = substitute(line, '+', '-', '')
	elseif line =~ '^\s*-'
		let line = substitute(line, '-', '*', '')
	endif
	let spaces = repeat(' ', &tabstop)
	let line = substitute(line, '	', spaces, 'g')
	if line[:1] == s:list_indent
		let line = line[2:]
	endif
	call setline('.', line)
	return v:true
endfun

fun! organ#bush#demote ()
	" Demote list item
	let line = getline('.')
	if line =~ '^\s*-'
		let line = substitute(line, '-', '+', '')
	elseif line =~ '^\s*+'
		let line = substitute(line, '+', '*', '')
	elseif line =~ '^\s\+\*'
		let line = substitute(line, '*', '-', '')
	endif
	let spaces = repeat(' ', &tabstop)
	let line = substitute(line, '	', spaces, 'g')
	let line = s:list_indent .. line
	call setline('.', line)
	return v:true
endfun

" -- subtree

fun! organ#bush#promote_subtree ()
	" Promote list item subtree
endfun

fun! organ#bush#demote_subtree ()
	" Demote list item subtree
endfun

" ---- move

fun! organ#bush#move_subtree_backward ()
	" Move subtree backward
endfun

fun! organ#bush#move_subtree_forward ()
	" Move_subtree_forward
endfun
