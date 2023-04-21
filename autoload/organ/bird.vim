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
	" First line of current heading
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

fun! organ#bird#properties (move = 'dont-move')
	" Properties of current headline
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

fun! organ#bird#range (move = 'dont-move')
	" Range of current heading
	let move = a:move
	let properties = organ#bird#properties ()
	let head_linum = properties.linum
	if head_linum == 0
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
	let forward_linum = search(headline_pattern, 'nW')
	if forward_linum == 0
		let tail_linum = line('$')
	else
		let tail_linum = forward_linum - 1
	endif
	if move == 'move'
		mark '
		call cursor(tail_linum, 1)
	endif
	return [head_linum, tail_linum]
endfun

fun! organ#bird#tail (move = 'dont-move')
	" Last line of current heading
	return organ#bird#range()[1]
endfun

fun! organ#bird#level (move = 'dont-move')
	" Level of current heading
	return organ#bird#properties(a:move).level
endfun

" ---- previous, next

fun! organ#bird#previous (wrap = 'wrap')
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

fun! organ#bird#next (wrap = 'wrap')
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

" ---- backward, forward

fun! organ#bird#backward (wrap = 'wrap')
	" Backward heading of same level
	let wrap = a:wrap
	let properties = organ#bird#properties ()
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
	if wrap == 'wrap'
		let linum = search(headline_pattern, 'bsw')
	else
		let linum = search(headline_pattern, 'bsW')
	endif
	normal! zv
	return linum
endfun

fun! organ#bird#forward (wrap = 'wrap')
	" Forward heading of same level
	let wrap = a:wrap
	let properties = organ#bird#properties ()
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

" ---- parent, child

fun! organ#bird#parent (wrap = 'wrap')
	" Parent heading, ie first headline of level - 1, backward
	let wrap = a:wrap
	let properties = organ#bird#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ bird parent heading : headline not found'
		return linum
	endif
	let level = properties.level
	if level == 1
		echomsg 'organ tree parent heading : already at top level'
		return linum
	endif
	let level -= 1
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

fun! organ#bird#child (wrap = 'wrap')
	" Child heading, or, more generally, first headline of level + 1, forward
	let wrap = a:wrap
	let properties = organ#bird#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ bird child heading : headline not found'
		return linum
	endif
	let level = properties.level + 1
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
	if linum == 0
		echomsg 'organ bird child heading : child heading not found'
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

