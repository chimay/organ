" vim: set ft=vim fdm=indent iskeyword&:

" Colibri
"
" Navigation on orgmode or markdown lists hierarchy

" ---- script constants

" ---- helpers

fun! organ#colibri#generic_pattern ()
	" Generic pattern of item head line
	if empty(&filetype)
		echomsg 'organ colibri generic pattern : empty filetype'
		return ''
	endif
	if keys(g:organ_config.list.unordered)->index(&filetype) >= 0
		let unordered = g:organ_config.list.unordered[&filetype]
		let ordered = g:organ_config.list.ordered[&filetype]
	else
		let unordered = g:organ_config.list.unordered.default
		let ordered = g:organ_config.list.ordered.default
	endif
	let unordered = unordered->join('')
	let ordered = ordered->join('')
	let pattern = '\m\%(^\s*[' .. unordered .. ']\s\+\|'
	let pattern ..= '^\s*[0-9]\+[' .. ordered .. ']\s\+\)'
	if &filetype ==# 'org'
		let pattern ..= '\&^[^*]'
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
	let hollow_pattern = '\m^\s*$'
	if current_line =~ itemhead_pattern
		return v:true
	endif
	if current_line =~ hollow_pattern
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
		if line =~ hollow_pattern
			return v:false
		endif
	endfor
	return v:true
endfun

fun! organ#colibri#list_start (move = 'dont-move')
	" Line number of the first line in current list
	let move = a:move
	if ! organ#colibri#is_in_list ()
		echomsg 'organ colibri start : not in a list'
		return 0
	endif
	let position = getcurpos ()
	let hollow_pattern = '\m^\s*$'
	let itemhead_pattern = organ#colibri#generic_pattern ()
	let flags = organ#utils#search_flags ('backward', 'move', 'dont-wrap')
	while v:true
		let linum = search(hollow_pattern, flags)
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

fun! organ#colibri#list_end (move = 'dont-move')
	" Line number of the last line in current list
	let move = a:move
	if ! organ#colibri#is_in_list ()
		echomsg 'organ colibri final : not in a list'
		return 0
	endif
	let position = getcurpos ()
	let hollow_pattern = '\m^\s*$'
	let itemhead_pattern = organ#colibri#generic_pattern ()
	let flags = organ#utils#search_flags ('forward', 'move', 'dont-wrap')
	while v:true
		let linum = search(hollow_pattern, flags)
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

fun! organ#colibri#itemtail (move = 'dont-move')
	" Last line of current list item
	let move = a:move
	let itemhead_pattern = organ#colibri#generic_pattern ()
	let flags = organ#utils#search_flags ('forward', 'dont-move', 'dont-wrap')
	let linum = search(itemhead_pattern, flags)
	let final = organ#colibri#list_end ()
	if linum == 0
		let linum = final
		if move ==# 'move'
			call cursor(linum, 1)
		endif
		return linum
	endif
	let linum -= 1
	let linum = min([linum, final])
	if move ==# 'move'
		call cursor(linum, 1)
	endif
	return linum
endfun

fun! organ#colibri#common_indent ()
	" Common indent of current list, in number of spaces
	let first = organ#colibri#list_start ()
	let last =  organ#colibri#list_end ()
	let indent_pattern = '\m^\s*'
	let hollow_pattern = '\m^\s*$'
	let linelist = getline(first, last)
	let indentlist = []
	for line in linelist
		if line =~ hollow_pattern
			continue
		endif
		let leading = line->matchstr(indent_pattern)
		let indent = len(leading)
		eval indentlist->add(indent)
	endfor
	return min(indentlist)
endfun

fun! organ#colibri#level_pattern (minlevel = 1, maxlevel = 100)
	" Item head pattern of level between minlevel and maxlevel
	if empty(&filetype) || keys(g:organ_config.list.unordered)->index(&filetype) < 0
		echomsg 'organ colibri generic pattern : filetype not supported'
		return ''
	endif
	let indent_length = g:organ_config.list.indent_length
	let min = (a:minlevel - 1) * indent_length
	let max = (a:maxlevel - 1) * indent_length
	let shift = organ#colibri#common_indent ()
	let min += shift
	let max += shift
	let unordered = g:organ_config.list.unordered[&filetype]
	let unordered = unordered->join('')
	let ordered = g:organ_config.list.ordered[&filetype]
	let ordered = ordered->join('')
	let pattern = '\m^ \{' .. min .. ',' .. max .. '}'
	let pattern ..= '\%([' .. unordered .. ']\s\+\|'
	let pattern ..= '[0-9]\+[' .. ordered .. ']\s\+\)'
	if &filetype ==# 'org'
		let pattern ..= '\&^[^*]'
		return pattern
	endif
	return pattern
endfun

fun! organ#colibri#properties (move = 'dont-move')
	" Properties of current list item
	let move = a:move
	if ! organ#colibri#is_in_list ()
		echomsg 'organ colibri properties : not in a list'
		return #{ linum : 0, itemhead : '', level : 0, text : '' }
	endif
	let linum = organ#colibri#itemhead (move)
	if linum == 0
		echomsg 'organ colibri properties : itemhead not found'
		return #{ linum : 0, itemhead : '', level : 0, text : '' }
	endif
	let itemhead = getline(linum)
	" ---- tab -> spaces
	let spaces = repeat(' ', &tabstop)
	let itemhead = substitute(itemhead, '	', spaces, 'g')
	" ---- computing level
	let indent = itemhead->matchstr('\m^\s*')
	let numspaces = len(indent)
	let common_indent = organ#colibri#common_indent ()
	let numspaces -= common_indent
	let indent_length = g:organ_config.list.indent_length
	let level = numspaces / indent_length + 1
	" ---- prefix
	let prefix_pattern = '\S\+\s\+'
	let prefix = itemhead->matchstr(prefix_pattern)
	let prefix = substitute(prefix, '\m^\s*', '', '')
	" ---- text without prefix
	let itemhead_pattern = organ#colibri#generic_pattern ()
	let text = substitute(itemhead, itemhead_pattern, '', '')
	let properties = #{
				\ linum : linum,
				\ itemhead : itemhead,
				\ level : level,
				\ prefix : prefix,
				\ text : text,
				\}
	return properties
endfun

fun! organ#colibri#subtree (move = 'dont-move')
	" Range & properties of current list subtree
	let move = a:move
	let properties = organ#colibri#properties (move)
	let head_linum = properties.linum
	if head_linum == 0
		echomsg 'organ colibri subtree : itemhead not found'
		return #{ head_linum : 0, itemhead : '', level : 0, text : '', tail_linum : 0 }
	endif
	let level = properties.level
	let itemhead_pattern = organ#colibri#level_pattern (1, level)
	let flags = organ#utils#search_flags ('forward', 'dont-move', 'dont-wrap')
	let forward_linum = search(itemhead_pattern, flags)
	let final = organ#colibri#list_end ()
	if forward_linum == 0 || forward_linum > final
		let tail_linum = final
	else
		let tail_linum = forward_linum - 1
	endif
	let subtree = #{
				\ head_linum : properties.linum,
				\ itemhead : properties.itemhead,
				\ level : properties.level,
				\ prefix : properties.prefix,
				\ text : properties.text,
				\ tail_linum : tail_linum,
				\}
	return subtree
endfun

" ---- previous, next

fun! organ#colibri#previous (move = 'move', wrap = 'wrap')
	" Previous list item
	let move = a:move
	let wrap = a:wrap
	let linum = line('.')
	call cursor(linum, 1)
	let line = getline('.')
	let itemhead_pattern = organ#colibri#generic_pattern ()
	let flags = organ#utils#search_flags ('backward', move, wrap)
	let linum = search(itemhead_pattern, flags)
	if linum == 0
		echomsg 'organ colibri previous : not found'
		return 0
	endif
	normal! zv
	return linum
endfun

fun! organ#colibri#next (move = 'move', wrap = 'wrap')
	" Next list item
	let move = a:move
	let wrap = a:wrap
	let linum = line('.')
	let colnum = col('$')
	call cursor(linum, colnum)
	let line = getline('.')
	let itemhead_pattern = organ#colibri#generic_pattern ()
	let flags = organ#utils#search_flags ('forward', move, wrap)
	let linum = search(itemhead_pattern, flags)
	if linum == 0
		echomsg 'organ colibri next : not found'
		return 0
	endif
	normal! zv
	return linum
endfun

" ---- backward, forward

fun! organ#colibri#backward (move = 'move', wrap = 'wrap')
	" Backward item of same level
	let move = a:move
	let wrap = a:wrap
	let properties = organ#colibri#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ colibri backward : item not found'
		return linum
	endif
	let level = properties.level
	let itemhead_pattern = organ#colibri#level_pattern (level, level)
	let flags = organ#utils#search_flags ('backward', move, wrap)
	let linum = search(itemhead_pattern, flags)
	normal! zv
	return linum
endfun

fun! organ#colibri#forward (move = 'move', wrap = 'wrap')
	" Forward item of same level
	let move = a:move
	let wrap = a:wrap
	let properties = organ#colibri#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ colibri forward : item not found'
		return linum
	endif
	let level = properties.level
	let itemhead_pattern = organ#colibri#level_pattern (level, level)
	let flags = organ#utils#search_flags ('forward', move, wrap)
	let linum = search(itemhead_pattern, flags)
	normal! zv
	return linum
endfun

" ---- parent, child

fun! organ#colibri#parent (move = 'move', wrap = 'wrap', ...)
	" Parent headline, ie first headline of level - 1, backward
	let move = a:move
	let wrap = a:wrap
	if a:0 > 0
		let properties = a:1
	else
		let properties = organ#colibri#properties ()
	endif
	let linum = properties.linum
	if linum == 0
		echomsg 'organ bird parent : current headline not found'
		return linum
	endif
	let level = properties.level
	if level == 1
		echomsg 'organ bird parent : already at top level'
		return linum
	endif
	let level -= 1
	let headline_pattern = organ#colibri#level_pattern (level, level)
	let flags = organ#utils#search_flags ('backward', move, wrap)
	let linum = search(headline_pattern, flags)
	if linum == 0
		echomsg 'organ bird parent : no parent found'
		return linum
	endif
	normal! zv
	return linum
endfun

fun! organ#colibri#loose_child (move = 'move', wrap = 'wrap')
	" Child headline, or, more generally, first headline of level + 1, forward
	let move = a:move
	let wrap = a:wrap
	let properties = organ#colibri#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ bird loose child : current headline not found'
		return linum
	endif
	let level = properties.level + 1
	let headline_pattern = organ#colibri#level_pattern (level, level)
	let flags = organ#utils#search_flags ('forward', move, wrap)
	let linum = search(headline_pattern, flags)
	if linum == 0
		echomsg 'organ bird loose child : no child found'
		return linum
	endif
	normal! zv
	return linum
endfun

fun! organ#colibri#strict_child (move = 'move', wrap = 'wrap')
	" First child subtree, strictly speaking
	let move = a:move
	let wrap = a:wrap
	let position = getcurpos ()
	" TODO
	let subtree = organ#colibri#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	if head_linum == 0 || tail_linum == 0
		echomsg 'organ bird strict child : headline not found'
		return linum
	endif
	let level = subtree.level + 1
	let headline_pattern = organ#colibri#level_pattern (level, level)
	let flags = organ#utils#search_flags ('forward', move, wrap)
	let linum = search(headline_pattern, flags)
	if linum == 0 || linum > tail_linum
		"echomsg 'organ bird strict child : no child found'
		call setpos('.', position)
		return 0
	endif
	normal! zv
	return linum
endfun
