" vim: set ft=vim fdm=indent iskeyword&:

" Bird
"
" Navigation on orgmode or markdown hierarchy

" ---- helpers

fun! organ#bird#header_line ()
	" Find current header top line
	let line = getline('.')
	let filetype = &filetype
	if filetype == 'org'
		let header_pattern = '^\*'
	elseif filetype == 'markdown'
		let header_pattern = '^#'
	endif
	let linum = search(header_pattern, 'bcs')
	let line = getline('.')
	if line !~ header_pattern
		echomsg 'organ bird header line : not found'
		return v:false
	endif
	return linum
endfun

fun! organ#bird#level (goto_header = v:true)
	" Level of current header
	let goto_header = a:goto_header
	let position = getcurpos ()
	if ! organ#bird#header_line ()
		return v:false
	endif
	let line = getline('.')
	let filetype = &filetype
	if filetype == 'org'
		let leading = line->matchstr('^\*\+')
	elseif filetype == 'markdown'
		let leading = line->matchstr('^#\+')
	endif
	let level = len(leading)
	if ! goto_header
		call setpos('.', position)
	endif
	return level
endfun

" ---- headers

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

fun! organ#bird#backward_header ()
	" Backward header of same level
	let linum = line('.')
endfun

fun! organ#bird#forward_header ()
	" Forward header of same level
endfun

fun! organ#bird#goto_header ()
	" Goto header
endfun

" -- speed commands

fun! organ#bird#speed (key)
	" Speed key on header line
endfun

