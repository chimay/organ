" vim: set ft=vim fdm=indent iskeyword&:

" Tree
"
" Operations on orgmode or markdown headings hierarchy

" ---- headings

fun! organ#tree#promote ()
	" Promote heading
	let level = organ#bird#level ()
	if level <= 1
		echomsg 'organ tree promote heading : already at top level'
		return v:false
	endif
	let line = getline('.')
	let line = line[1:]
	call setline('.', line)
	return v:true
endfun

fun! organ#tree#demote ()
	" Demote heading
	if ! organ#bird#first_line ()
		return v:false
	endif
	let line = getline('.')
	let filetype = &filetype
	if filetype == 'org'
		let line = '*' .. line
	elseif filetype == 'markdown'
		let line = '#' .. line
	endif
	call setline('.', line)
	normal! zv
	return v:true
endfun

