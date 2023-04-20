" vim: set ft=vim fdm=indent iskeyword&:

" Bird
"
" Navigation on orgmode or markdown hierarchy

" ---- helpers

fun! organ#bird#is_on_heading_line ()
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

fun! organ#bird#heading_line (goto_heading = 'goto-heading')
	" Find current heading line
	let goto_heading = a:goto_heading
	let position = getcurpos ()
	let line = getline('.')
	let filetype = &filetype
	if filetype == 'org'
		let heading_pattern = '^\*'
	elseif filetype == 'markdown'
		let heading_pattern = '^#'
	endif
	let linum = search(heading_pattern, 'bcs')
	let line = getline('.')
	if line !~ heading_pattern
		echomsg 'organ bird heading line : not found'
		return v:false
	endif
	if goto_heading != 'goto-heading'
		call setpos('.', position)
	endif
	return linum
endfun

fun! organ#bird#end_line (goto_heading = 'goto-heading')
	" Find last line of current heading
	let goto_heading = a:goto_heading
	let position = getcurpos ()
	let line = getline('.')
	let filetype = &filetype
	if filetype == 'org'
		let heading_pattern = '^\*'
	elseif filetype == 'markdown'
		let heading_pattern = '^#'
	endif
	let linum = search(heading_pattern, 'bcs')
	let line = getline('.')
	if line !~ heading_pattern
		echomsg 'organ bird heading line : not found'
		return v:false
	endif
	if goto_heading != 'goto-heading'
		call setpos('.', position)
	endif
	return linum
endfun

fun! organ#bird#level (goto_heading = 'goto-heading')
	" Level of current heading
	let goto_heading = a:goto_heading
	let position = getcurpos ()
	if ! organ#bird#heading_line ()
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
	if goto_heading != 'goto-heading'
		call setpos('.', position)
	endif
	return level
endfun

" ---- headings

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
	if ! organ#bird#is_on_heading_line ()
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
	if ! organ#bird#is_on_heading_line ()
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

fun! organ#bird#goto_heading ()
	" Goto heading
endfun

" -- speed commands

fun! organ#bird#speed (key)
	" Speed key on heading line
endfun

