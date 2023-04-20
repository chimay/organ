" vim: set ft=vim fdm=indent iskeyword&:

" Bird
"
" Navigation on orgmode or markdown hierarchy

" ---- helpers

fun! organ#bird#is_on_header_line ()
	" Whether current position is on header line
	let filetype = &filetype
	if filetype == 'org'
		let header_pattern = '^\*'
	elseif filetype == 'markdown'
		let header_pattern = '^#'
	endif
	let line = getline('.')
	return line =~ header_pattern
endfun

fun! organ#bird#header_line (goto_header = v:true)
	" Find current header top line
	let goto_header = a:goto_header
	let position = getcurpos ()
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
	if ! goto_header
		call setpos('.', position)
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
	let linum = search(header_pattern, 'bs')
	let line = getline('.')
	if line !~ header_pattern
		echomsg 'organ bird previous header : not found'
		return v:false
	endif
	normal! zv
	return linum
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
	let linum = search(header_pattern, 's')
	let line = getline('.')
	if line !~ header_pattern
		echomsg 'organ bird next header : not found'
		return v:false
	endif
	normal! zv
	return linum
endfun

fun! organ#bird#backward_header ()
	" Backward header of same level
	if ! organ#bird#is_on_header_line ()
		return organ#bird#previous_header ()
	endif
	let old_level = organ#bird#level ()
	let old_linum = line('.')
	while v:true
		let new_linum = organ#bird#previous_header ()
		let new_level = organ#bird#level ()
		if new_level == old_level
			return new_linum
		endif
		if new_linum >= old_linum
			return new_linum
		endif
	endwhile
endfun

fun! organ#bird#forward_header ()
	" Forward header of same level
	if ! organ#bird#is_on_header_line ()
		return organ#bird#next_header ()
	endif
	let old_level = organ#bird#level ()
	let old_linum = line('.')
	while v:true
		let new_linum = organ#bird#next_header ()
		let new_level = organ#bird#level ()
		if new_level == old_level
			return new_linum
		endif
		if new_linum <= old_linum
			return new_linum
		endif
	endwhile
endfun

fun! organ#bird#parent_header ()
	" Parent upper header
	if ! organ#bird#is_on_header_line ()
		return organ#bird#previous_header ()
	endif
	let old_level = organ#bird#level ()
	let old_linum = line('.')
	while v:true
		let new_linum = organ#bird#previous_header ()
		let new_level = organ#bird#level ()
		if new_level == old_level - 1
			return new_linum
		endif
		if new_linum >= old_linum
			return new_linum
		endif
	endwhile
endfun

fun! organ#bird#goto_header ()
	" Goto header
endfun

" -- speed commands

fun! organ#bird#speed (key)
	" Speed key on header line
endfun

