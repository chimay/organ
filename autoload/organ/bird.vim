" vim: set ft=vim fdm=indent iskeyword&:

" Bird
"
" Navigation on orgmode or markdown headings hierarchy

" ---- helpers

fun! organ#bird#is_on_first_line ()
	" Whether current position is on heading line
	let filetype = &filetype
	if filetype == 'org'
		let heading_pattern = '^\*'
	elseif filetype == 'markdown'
		let heading_pattern = '^#'
	endif
	let line = getline('.')
	return line =~ heading_pattern
endfun

fun! organ#bird#first_line (goto_head = 'goto-head')
	" Find first line (head line) of current heading
	let goto_head = a:goto_head
	let filetype = &filetype
	if filetype == 'org'
		let heading_pattern = '^\*'
	elseif filetype == 'markdown'
		let heading_pattern = '^#'
	endif
	if goto_head != 'goto-head'
		let linum = search(heading_pattern, 'bcnW')
	else
		let linum = search(heading_pattern, 'bcsW')
	endif
	if linum == 0
		echomsg 'organ bird heading line : not found'
		return v:false
	endif
	return linum
endfun

fun! organ#bird#last_line (goto_last = 'goto-last')
	" Find last line of current heading
	let goto_last = a:goto_last
	let filetype = &filetype
	if filetype == 'org'
		let heading_pattern = '^\*'
	elseif filetype == 'markdown'
		let heading_pattern = '^#'
	endif
	if goto_last != 'goto-last'
		let linum = search(heading_pattern, 'nW')
		let linum -= 1
	else
		let linum = search(heading_pattern, 'sW')
		let linum -= 1
		call cursor(linum, 1)
	endif
	if linum == 0
		echomsg 'organ bird heading line : not found'
		return v:false
	endif
	return linum
endfun

fun! organ#bird#level (goto_head = 'goto-head')
	" Level of current heading
	let goto_head = a:goto_head
	let linum = organ#bird#first_line (goto_head)
	if linum == 0
		return v:false
	endif
	let line = getline(linum)
	let filetype = &filetype
	if filetype == 'org'
		let leading = line->matchstr('^\*\+')
	elseif filetype == 'markdown'
		let leading = line->matchstr('^#\+')
	endif
	let level = len(leading)
	return level
endfun

" ---- previous, next, backward, forward, parent

fun! organ#bird#previous_heading (wrap = 'wrap')
	" Previous heading
	let wrap = a:wrap
	let linum = line('.')
	call cursor(linum, 1)
	let line = getline('.')
	let filetype = &filetype
	if filetype == 'org'
		let heading_pattern = '^\*'
	elseif filetype == 'markdown'
		let heading_pattern = '^#'
	endif
	if wrap == 'wrap'
		let linum = search(heading_pattern, 'bsw')
	else
		let linum = search(heading_pattern, 'bsW')
	endif
	let line = getline('.')
	if line !~ heading_pattern
		echomsg 'organ bird previous heading : not found'
		return v:false
	endif
	normal! zv
	return linum
endfun

fun! organ#bird#next_heading (wrap = 'wrap')
	" Next heading
	let wrap = a:wrap
	let linum = line('.')
	let colnum = col('$')
	call cursor(linum, colnum)
	let line = getline('.')
	let filetype = &filetype
	if filetype == 'org'
		let heading_pattern = '^\*'
	elseif filetype == 'markdown'
		let heading_pattern = '^#'
	endif
	if wrap == 'wrap'
		let linum = search(heading_pattern, 'sw')
	else
		let linum = search(heading_pattern, 'sW')
	endif
	let line = getline('.')
	if line !~ heading_pattern
		echomsg 'organ bird next heading : not found'
		return v:false
	endif
	normal! zv
	return linum
endfun

fun! organ#bird#backward_heading ()
	" Backward heading of same level
	if ! organ#bird#is_on_first_line ()
		return organ#bird#previous_heading ()
	endif
	let start_level = organ#bird#level ()
	let start_linum = line('.')
	let old_linum = start_linum
	let wrapped = v:false
	while v:true
		let current_linum = organ#bird#previous_heading ()
		let current_level = organ#bird#level ()
		if current_level == start_level
			return current_linum
		endif
		if current_linum >= old_linum
			if ! wrapped
				let wrapped = v:true
			else
				return current_linum
			endif
		endif
		if current_linum <= start_linum && wrapped
			return current_linum
		endif
		let old_linum = current_linum
	endwhile
endfun

fun! organ#bird#forward_heading ()
	" Forward heading of same level
	if ! organ#bird#is_on_first_line ()
		return organ#bird#next_heading ()
	endif
	let start_level = organ#bird#level ()
	let start_linum = line('.')
	let old_linum = start_linum
	let wrapped = v:false
	while v:true
		let current_linum = organ#bird#next_heading ()
		let current_level = organ#bird#level ()
		if current_level == start_level
			return current_linum
		endif
		if current_linum <= old_linum
			if ! wrapped
				let wrapped = v:true
			else
				return current_linum
			endif
		endif
		if current_linum >= start_linum && wrapped
			return current_linum
		endif
		let old_linum = current_linum
	endwhile
endfun

fun! organ#bird#parent_heading ()
	" Parent upper heading
	call organ#bird#heading_line ()
	let start_level = organ#bird#level ()
	let start_linum = line('.')
	let old_linum = start_linum
	if start_level == 1
		return start_linum
	endif
	let wrapped = v:false
	while v:true
		let current_linum = organ#bird#previous_heading ()
		let current_level = organ#bird#level ()
		if current_level == start_level - 1
			return current_linum
		endif
		if current_linum >= old_linum
			if ! wrapped
				let wrapped = v:true
			else
				return current_linum
			endif
		endif
		if current_linum <= start_linum && wrapped
			return current_linum
		endif
		let old_linum = current_linum
	endwhile
endfun

" ---- goto

fun! organ#bird#goto ()
	" Goto heading with completion
endfun

" -- speed commands

fun! organ#bird#speed (key)
	" Speed key on heading line
endfun

