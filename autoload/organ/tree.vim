" vim: set ft=vim fdm=indent iskeyword&:

" Tree
"
" Operations on org hierarchy


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
endfun

fun! organ#tree#demote_list_item ()
	" Demote list item
endfun

" ---- generic

fun! organ#tree#promote ()
	" Promote header or list item
	let line = getline('.')
	if line =~ '^\s*[-+]'
		call organ#tree#promote_list_item ()
	elseif line =~ '^\s\+\*'
		call organ#tree#promote_list_item ()
	else
		call organ#tree#promote_header ()
	endif
endfun

fun! organ#tree#demote ()
	" Demote header or list item
	let line = getline('.')
	if line =~ '^\s*[-+]'
		call organ#tree#demote_list_item ()
	elseif line =~ '^\s\+\*'
		call organ#tree#demote_list_item ()
	else
		call organ#tree#demote_header ()
	endif
endfun
