" vim: set ft=vim fdm=indent iskeyword&:

" Bird
"
" Navigation on orgmode or markdown headings hierarchy

" ---- helpers

fun! organ#bird#is_on_headline ()
	" Whether current position is on headline
	let filetype = &filetype
	if filetype == 'org'
		let headline_pattern = '^\*'
	elseif filetype == 'markdown'
		let headline_pattern = '^#'
	endif
	let line = getline('.')
	return line =~ headline_pattern
endfun

fun! organ#bird#headline (move = 'dont-move')
	" Find first line of current heading
	let move = a:move
	let filetype = &filetype
	if filetype == 'org'
		let headline_pattern = '^\*'
	elseif filetype == 'markdown'
		let headline_pattern = '^#'
	endif
	if move == 'move'
		return search(headline_pattern, 'bcsW')
	else
		return search(headline_pattern, 'bcnW')
	endif
endfun

fun! organ#bird#tail (move = 'dont-move')
	" Find last line of current heading
	let goto_last = a:goto_last
	let filetype = &filetype
	if filetype == 'org'
		let headline_pattern = '^\*'
	elseif filetype == 'markdown'
		let headline_pattern = '^#'
	endif
	let linum = search(headline_pattern, 'nW')
	let linum -= 1
	if move == 'move'
		call cursor(linum, 1)
	endif
	return linum
endfun

fun! organ#bird#headline_properties (move = 'dont-move')
	" Properties of current heading headline
	let move = a:move
	let linum = organ#bird#headline (move)
	let line = getline(linum)
	let filetype = &filetype
	if filetype == 'org'
		let leading = line->matchstr('^\*\+')
	elseif filetype == 'markdown'
		let leading = line->matchstr('^#\+')
	endif
	let level = len(leading)
	let properties = #{ level : level, linum : linum, line : line }
	return properties
endfun

fun! organ#bird#level (move = 'dont-move')
	" Level of current heading
	return organ#bird#headline_properties(a:move).level
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
		let headline_pattern = '^\*'
	elseif filetype == 'markdown'
		let headline_pattern = '^#'
	endif
	if wrap == 'wrap'
		let linum = search(headline_pattern, 'bsw')
	else
		let linum = search(headline_pattern, 'bsW')
	endif
	let line = getline('.')
	if line !~ headline_pattern
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
		let headline_pattern = '^\*'
	elseif filetype == 'markdown'
		let headline_pattern = '^#'
	endif
	if wrap == 'wrap'
		let linum = search(headline_pattern, 'sw')
	else
		let linum = search(headline_pattern, 'sW')
	endif
	let line = getline('.')
	if line !~ headline_pattern
		echomsg 'organ bird next heading : not found'
		return v:false
	endif
	normal! zv
	return linum
endfun

fun! organ#bird#backward_heading (wrap = 'wrap')
	" Backward heading of same level
	let wrap = a:wrap
	let properties = organ#bird#headline_properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ bird backward heading : headline not found'
		return linum
	endif
	let level = properties.level
	let filetype = &filetype
	if filetype == 'org'
		let headline_pattern = '^' .. repeat('\*', level) .. '[^*]'
	elseif filetype == 'markdown'
		let headline_pattern = '^' .. repeat('#', level) .. '[^#]'
	endif
	echo headline_pattern
	if wrap == 'wrap'
		let linum = search(headline_pattern, 'bsw')
	else
		let linum = search(headline_pattern, 'bsW')
	endif
	normal! zv
	return linum
endfun

fun! organ#bird#forward_heading (wrap = 'wrap')
	" Forward heading of same level
	let wrap = a:wrap
	let properties = organ#bird#headline_properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ bird forward heading : headline not found'
		return linum
	endif
	let level = properties.level
	let filetype = &filetype
	if filetype == 'org'
		let headline_pattern = '^' .. repeat('\*', level) .. '[^*]'
	elseif filetype == 'markdown'
		let headline_pattern = '^' .. repeat('#', level) .. '[^#]'
	endif
	if wrap == 'wrap'
		let linum = search(headline_pattern, 'sw')
	else
		let linum = search(headline_pattern, 'sW')
	endif
	normal! zv
	return linum
endfun

fun! organ#bird#parent_heading (wrap = 'wrap')
	" Parent upper heading
	let wrap = a:wrap
	let properties = organ#bird#headline_properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ bird parent heading : headline not found'
		return linum
	endif
	let level = properties.level - 1
	let filetype = &filetype
	if filetype == 'org'
		let headline_pattern = '^' .. repeat('\*', level) .. '[^*]'
	elseif filetype == 'markdown'
		let headline_pattern = '^' .. repeat('#', level) .. '[^#]'
	endif
	if wrap == 'wrap'
		let linum = search(headline_pattern, 'bsw')
	else
		let linum = search(headline_pattern, 'bsW')
	endif
	normal! zv
	return linum
endfun

" ---- goto

fun! organ#bird#goto ()
	" Goto heading with completion
endfun

" -- speed commands

fun! organ#bird#speed (key)
	" Speed key on heading line
endfun

