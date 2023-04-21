" vim: set ft=vim fdm=indent iskeyword&:

" Bush
"
" Operations on orgmode or markdown lists hierarchy

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
	if line[:1] == '  '
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
	let line = '  ' .. line
	call setline('.', line)
	return v:true
endfun

fun! organ#bush#promote_subtree ()
	" Promote list item subtree
endfun

fun! organ#bush#demote_subtree ()
	" Demote list item subtree
endfun
