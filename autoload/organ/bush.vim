" vim: set ft=vim fdm=indent iskeyword&:

" Bush
"
" Operations on orgmode or markdown lists hierarchy

fun! organ#bush#promote_list_item ()
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

fun! organ#bush#demote_list_item ()
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