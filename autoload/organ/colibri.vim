" vim: set ft=vim fdm=indent iskeyword&:

" Colibri
"
" Navigation on orgmode or markdown lists hierarchy

" ---- script constants

if ! exists('s:itemhead_pattern_org')
	let s:itemhead_pattern_org = organ#crystal#fetch('list/itemhead/pattern/org')
	lockvar s:itemhead_pattern_org
endif

if ! exists('s:itemhead_pattern_markdown')
	let s:itemhead_pattern_markdown = organ#crystal#fetch('list/itemhead/pattern/markdown')
	lockvar s:itemhead_pattern_markdown
endif

if ! exists('s:indent')
	let s:indent = organ#crystal#fetch('list/indent')
	lockvar s:indent
endif

if ! exists('s:indent_length')
	let s:indent_length = organ#crystal#fetch('list/indent/length')
	lockvar s:indent_length
endif

" ---- helpers

fun! organ#colibri#generic_pattern ()
	" Generic pattern of item head line
	if &filetype == 'org'
		return s:itemhead_pattern_org
	elseif &filetype == 'markdown'
		return s:itemhead_pattern_markdown
	else
		echomsg 'organ colibri generic pattern : filetype not supported'
	endif
endfun

fun! organ#colibri#level_pattern (minlevel = 1, maxlevel = 100, indent = 0)
	" Item head pattern of level between minlevel and maxlevel
	" All list is indented with indent * s:indent_length
	let min = a:minlevel + a:indent - 1
	let max = a:maxlevel + a:indent - 1
	if min == 0 && &filetype == 'org'
		let pattern = '^\%(\%(' .. s:indent .. '\)\{' .. min .. ',' .. max .. '\}'
		let pattern ..= '\%([-+*]\|[0-9]\+[.)]\)\)\|'
		let pattern ..= '\%(^[-+]\|^[0-9]\+[.)]\)'
		return pattern
	endif
	let pattern = '^\%(' .. s:indent .. '\)\{' .. min .. ',' .. max .. '\}'
	if &filetype == 'org'
		let pattern ..= '\%([-+*]\|[0-9]\+[.)]\)'
	elseif &filetype == 'markdown'
		let pattern ..= '\%([-+*]\|[0-9]\+[.]\)'
	endif
	return pattern
endfun

fun! organ#colibri#is_on_itemhead ()
	" Whether current line is a item head
	let line = getline('.')
	return line =~ organ#colibri#generic_pattern ()
endfun

fun! organ#colibri#itemhead (move = 'dont-move')
	" Head of current list item
	let move = a:move
	let itemhead_pattern = organ#colibri#generic_pattern ()
	let flags = organ#utils#search_flags ('backward', move, 'dont-wrap')
	let flags ..= 'c'
	return search(itemhead_pattern, flags)
endfun

fun! organ#colibri#is_in_list (move = 'dont-move')
	" Whether current line is in a list
	let move = a:move
	let linum = line('.')
	let current_line = getline(linum)
	let itemhead_pattern = organ#colibri#generic_pattern ()
	if current_line =~ itemhead_pattern
		return v:true
	endif
	if current_line =~ '^\s*$'
		if linum == line('$')
			return v:false
		endif
		let next = getline(linum + 1)
		if next !~ itemhead_pattern
			return v:false
		endif
	endif
	let head_linum = organ#colibri#itemhead (move)
	if head_linum == 0
		return v:false
	endif
	let linelist = getline(head_linum, linum - 1)
	for line in linelist
		if line =~ '^\s*$'
			return v:false
		endif
	endfor
	return v:true
endfun

fun! organ#colibri#start (move = 'dont-move')
	" Line number of the first line in current list
	let move = a:move
	if ! organ#colibri#is_in_list ()
		echomsg 'organ colibri start : not in a list'
		return 0
	endif
	let position = getcurpos ()
	let space_pattern = '^\s*$'
	let itemhead_pattern = organ#colibri#generic_pattern ()
	let flags = organ#utils#search_flags ('backward', 'move', 'dont-wrap')
	while v:true
		let linum = search(space_pattern, flags)
		if linum == 0
			let linum = 1
			if move != 'move'
				call setpos('.', position)
			else
				call cursor(linum, 1)
			endif
			return linum
		endif
		let previous = getline(linum - 1)
		call cursor(previous, 1)
		if ! organ#colibri#is_in_list ()
			let linum += 1
			if move != 'move'
				call setpos('.', position)
			else
				call cursor(linum, 1)
			endif
			return linum
		endif
	endwhile
	if move != 'move'
		call setpos('.', position)
	endif
	return 0
endfun

fun! organ#colibri#final (move = 'dont-move')
	" Line number of the last line in current list
	let move = a:move
	if ! organ#colibri#is_in_list ()
		echomsg 'organ colibri final : not in a list'
		return 0
	endif
	let position = getcurpos ()
	let space_pattern = '^\s*$'
	let itemhead_pattern = organ#colibri#generic_pattern ()
	let flags = organ#utils#search_flags ('forward', 'move', 'dont-wrap')
	while v:true
		let linum = search(space_pattern, flags)
		if linum == 0
			let linum = line('$')
			if move != 'move'
				call setpos('.', position)
			else
				call cursor(linum, 1)
			endif
			return linum
		endif
		let next = getline(linum + 1)
		if next !~ itemhead_pattern
			let linum -= 1
			if move != 'move'
				call setpos('.', position)
			else
				call cursor(linum, 1)
			endif
			return linum
		endif
	endwhile
	if move != 'move'
		call setpos('.', position)
	endif
	return 0
endfun

fun! organ#colibri#properties (move = 'dont-move')
	" Properties of current list item
	let move = a:move
	if ! organ#colibri#is_in_list ()
		echomsg 'organ colibri properties : not in a list'
		return #{ linum : 0, itemhead : '', level : 0, content : '' }
	endif
	let linum = organ#colibri#itemhead (move)
	if linum == 0
		echomsg 'organ bird properties : itemhead not found'
		return #{ linum : 0, itemhead : '', level : 0, content : '' }
	endif
	let itemhead = getline(linum)
	" ---- tab -> spaces
	let spaces = repeat(' ', &tabstop)
	let itemhead = substitute(itemhead, '	', spaces, 'g')
	" ---- computing level
	let indent = itemhead->matchstr('^\s*')
	let indnum = len(indent)
	let level = indnum / s:indent_length + 1
	" ---- content without prefix
	let itemhead_pattern = organ#colibri#generic_pattern ()
	let content = substitute(itemhead, itemhead_pattern, '', '')
	let properties = #{
				\ linum : linum,
				\ itemhead : itemhead,
				\ level : level,
				\ content : content,
				\}
	return properties
endfun

fun! organ#colibri#level (move = 'dont-move')
	" Level of current list subtree
	return organ#colibri#level(a:move).level
endfun

fun! organ#colibri#subtree (move = 'dont-move')
	" Range & properties of current list subtree
	let move = a:move
	let properties = organ#colibri#properties (move)
	let head_linum = properties.linum
	if head_linum == 0
		echomsg 'organ colibri subtree : itemhead not found'
		return #{ head_linum : 0, itemhead : '', level : 0, content : '', tail_linum : 0 }
	endif
	let level = properties.level
	let itemhead_pattern = organ#colibri#level_pattern (1, level)
	let flags = organ#utils#search_flags ('forward', 'dont-move', 'dont-wrap')
	let forward_linum = search(itemhead_pattern, flags)
	let final = organ#colibri#final ()
	if forward_linum == 0 || forward_linum > final
		let tail_linum = final
	else
		let tail_linum = forward_linum - 1
	endif
	let subtree = #{
				\ head_linum : properties.linum,
				\ itemhead : properties.itemhead,
				\ level : properties.level,
				\ content : properties.content,
				\ tail_linum : tail_linum,
				\}
	return subtree
endfun

fun! organ#colibri#tail (move = 'dont-move')
	" Last line of current list subtree
	return organ#colibri#subtree(a:move).tail_linum
endfun
