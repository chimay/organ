" vim: set ft=vim fdm=indent iskeyword&:

" Tree
"
" Operations on orgmode or markdown headings hierarchy

" ---- current heading only

fun! organ#tree#promote ()
	" Promote heading
	let properties = organ#bird#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ tree promote heading : headline not found'
		return v:false
	endif
	if properties.level == 1
		echomsg 'organ tree promote heading : already at top level'
		return v:false
	endif
	let line = properties.line
	let line = line[1:]
	call setline(linum, line)
	return v:true
endfun

fun! organ#tree#demote ()
	" Demote heading
	let properties = organ#bird#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ tree demote heading : headline not found'
		return v:false
	endif
	let line = properties.line
	let filetype = &filetype
	if filetype == 'org'
		let line = '*' .. line
	elseif filetype == 'markdown'
		let line = '#' .. line
	endif
	call setline(linum, line)
	normal! zv
	return v:true
endfun

" ---- subtree

fun! organ#tree#promote_subtree ()
	" Promote subtree
	let properties = organ#bird#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ tree promote subtree : headline not found'
		return v:false
	endif
	if properties.level == 1
		echomsg 'organ tree promote subtree : already at top level'
		return v:false
	endif
	let line = properties.line
	let line = line[1:]
	call setline(linum, line)
	return v:true
endfun

fun! organ#tree#demote_subtree ()
	" Demote subtree
	let properties = organ#bird#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ tree demote subtree : headline not found'
		return v:false
	endif
	let line = properties.line
	let filetype = &filetype
	if filetype == 'org'
		let line = '*' .. line
	elseif filetype == 'markdown'
		let line = '#' .. line
	endif
	call setline(linum, line)
	normal! zv
	return v:true
endfun

