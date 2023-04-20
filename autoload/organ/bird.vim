" vim: set ft=vim fdm=indent iskeyword&:

" Bird
"
" Navigation on orgmode or markdown hierarchy

fun! organ#bird#top_line ()
	" Find current header top line
	let line = getline('.')
	let filetype = &filetype
	if filetype == 'org'
		let header_pattern = '^\*'
	elseif filetype == 'markdown'
		let header_pattern = '^#'
	endif
	call search(header_pattern, 'bcs')
	let line = getline('.')
	if line !~ header_pattern
		echomsg 'organ bird previous header : not found'
		return v:false
	endif
	return v:true
endfun

fun! organ#bird#previous_header ()
	" Previous header
	let linum = line('.')
	call cursor(linum, 1)
	let line = getline('.')
	let filetype = &filetype
	if filetype == 'org'
		let header_pattern = '^\*'
	elseif filetype == 'markdown'
		let header_pattern = '^#'
	endif
	call search(header_pattern, 'bs')
	let line = getline('.')
	if line !~ header_pattern
		echomsg 'organ bird previous header : not found'
		return v:false
	endif
	normal! zv
	" -- slow
	"normal! zx
	return v:true
endfun

fun! organ#bird#next_header ()
	" Next header
	let linum = line('.')
	let colnum = col('$')
	call cursor(linum, colnum)
	let line = getline('.')
	let filetype = &filetype
	if filetype == 'org'
		let header_pattern = '^\*'
	elseif filetype == 'markdown'
		let header_pattern = '^#'
	endif
	call search(header_pattern, 's')
	let line = getline('.')
	if line !~ header_pattern
		echomsg 'organ bird next header : not found'
		return v:false
	endif
	normal! zv
	" -- slow
	"normal! zx
	return v:true
endfun

