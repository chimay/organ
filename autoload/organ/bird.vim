" vim: set ft=vim fdm=indent iskeyword&:

" Bird
"
" Navigation on orgmode or markdown headings hierarchy

" ---- script constants

if ! exists('s:speedkeys')
	let s:speedkeys = organ#geode#fetch('speedkeys', 'dict')
	lockvar s:speedkeys
endif

if ! exists('s:speedkeys_with_angle')
	let s:speedkeys_with_angle = organ#geode#fetch('speedkeys/with_angle', 'dict')
	lockvar s:speedkeys_with_angle
endif

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
	" First line of current section
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
	if linum == 0
		echomsg 'organ bird properties : headline not found'
		return #{ linum : 0, headline : '', level : 0 }
	endif
	let headline = getline(linum)
	let filetype = &filetype
	if filetype == 'org'
		let leading = headline->matchstr('^\*\+')
	elseif filetype == 'markdown'
		let leading = headline->matchstr('^#\+')
	endif
	let level = len(leading)
	" -- assume a space before the title
	let title = headline[level + 1:]
	let properties = #{
				\ linum : linum,
				\ headline : headline,
				\ level : level,
				\ title : title
				\}
	return properties
endfun

fun! organ#bird#level (move = 'dont-move')
	" Level of current heading
	return organ#bird#properties(a:move).level
endfun

fun! organ#bird#title (move = 'dont-move')
	" Level of current heading
	return organ#bird#properties(a:move).title
endfun

fun! organ#bird#section (move = 'dont-move')
	" Range & properties of current section
	let move = a:move
	let properties = organ#bird#properties (move)
	let head_linum = properties.linum
	if head_linum == 0
		echomsg 'organ bird section : headline not found'
		return #{ head_linum : 0, headline : '', level : 0, tail_linum : 0 }
	endif
	let level = properties.level
	let filetype = &filetype
	if filetype == 'org'
		let headline_pattern = '^\*\{1,' .. level .. '\}' .. '[^*]'
	elseif filetype == 'markdown'
		let headline_pattern = '^#\{1,' .. level .. '\}' .. '[^#]'
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
	let headline = properties.headline
	let title = properties.title
	let dict = #{
				\ head_linum : head_linum,
				\ headline : headline,
				\ level : level,
				\ title : title,
				\ tail_linum : tail_linum,
				\}
	return dict
endfun

fun! organ#bird#tail (move = 'dont-move')
	" Last line of current
	return organ#bird#section(a:move).tail_linum
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
	if linum == 0
		echomsg 'organ bird previous heading : not found'
		return 0
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
	if linum == 0
		echomsg 'organ bird next heading : not found'
		return 0
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

fun! organ#bird#parent (wrap = 'wrap', ...)
	" Parent heading, ie first headline of level - 1, backward
	let wrap = a:wrap
	if a:0 > 0
		let properties = a:1
	else
		let properties = organ#bird#properties ()
	endif
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

" ---- full path of chapters, sections, subsections, and so on

fun! organ#bird#path ()
	" Full headings path
	let position = getcurpos ()
	let properties = organ#bird#properties ('move')
	let path = properties.title
	while v:true
		if properties.linum == 0
			call setpos('.', position)
			return path
		endif
		if properties.level == 1
			call setpos('.', position)
			return path
		endif
		call organ#bird#parent ('wrap', properties)
		let properties = organ#bird#properties ('move')
		let path = properties.title .. '/' .. path
	endwhile
endfun

fun! organ#bird#info ()
	" Echo full headings path
	echomsg organ#bird#path ()
endfun

" ---- goto

fun! organ#bird#goto ()
	" Goto heading with completion
endfun

" -- speed commands

fun! organ#bird#speed (key, angle = 'no-angle')
	" Speed key on headlines first char
	let key = a:key
	let angle = a:angle
	if angle ==# 'with-angle' || angle ==# '>'
		let function = s:speedkeys_with_angle[key]
		let key = '<' .. key .. '>'
	else
		let function = s:speedkeys[key]
	endif
	if ! organ#bird#is_on_headline () || col('.') != 1
		execute 'normal!' key
		return 0
	endif
	call {function}()
endfun

