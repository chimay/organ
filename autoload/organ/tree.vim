" vim: set ft=vim fdm=indent iskeyword&:

" Tree
"
" Operations on org hierarchy

" ---- script constants

if ! exists('s:plain_list_line_pattern')
	let s:plain_list_line_pattern = organ#crystal#fetch('plain_list/line_pattern')
	lockvar s:plain_list_line_pattern
endif

" ---- headers

fun! organ#tree#promote_header ()
	" Promote header
	let line = getline('.')
	let header_pattern = '^\*'
	if line !~ header_pattern
		call search(header_pattern, 'bs')
	endif
	let line = getline('.')
	if line !~ header_pattern
		echomsg 'organ tree promote header : header not found'
		return v:false
	endif
	let level = line->count('*')
	if level <= 1
		echomsg 'organ tree promote header : already at top level'
		return v:false
	endif
	let level -= 1
	let line = line[:level-1] .. line[level+1:]
	call setline('.', line)
	return v:true
endfun

fun! organ#tree#demote_header ()
	" Demote header
	let line = getline('.')
	let header_pattern = '^\*'
	if line !~ header_pattern
		call search(header_pattern, 'bs')
	endif
	let line = getline('.')
	if line !~ header_pattern
		echomsg 'organ tree demote header : header not found'
		return v:false
	endif
	let line = '*' .. line
	call setline('.', line)
	return v:true
endfun

" ---- list items

fun! organ#tree#promote_list_item ()
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

fun! organ#tree#demote_list_item ()
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

" ---- generic

fun! organ#tree#promote ()
	" Promote header or list item
	let line = getline('.')
	if line =~ s:plain_list_line_pattern
		call organ#tree#promote_list_item ()
	else
		call organ#tree#promote_header ()
	endif
endfun

fun! organ#tree#demote ()
	" Demote header or list item
	let line = getline('.')
	if line =~ s:plain_list_line_pattern
		call organ#tree#demote_list_item ()
	else
		call organ#tree#demote_header ()
	endif
endfun
