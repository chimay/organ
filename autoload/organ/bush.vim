" vim: set ft=vim fdm=indent iskeyword&:

" Bush
"
" Operations on orgmode or markdown lists hierarchy

" ---- script constants

" ---- helpers

fun! organ#bush#indent_item (level)
	" Indent current list item
	let level = a:level
	let properties = organ#colibri#properties ()
	let head = properties.linum
	let itemhead = properties.itemhead
	let tail = organ#colibri#itemtail ()
	let len_prefix = len(properties.prefix)
	let shift = organ#colibri#common_indent ()
	let step = g:organ_config.list.indent_length
	let spaces = '\m^\s*'
	" ---- item head line
	let numspaces = shift + step * (level - 1)
	let indent = repeat(' ', numspaces)
	let itemhead = substitute(itemhead, spaces, indent, '')
	call setline(head, itemhead)
	" ---- other lines
	if head >= tail
		return itemhead
	endif
	let numspaces += len_prefix
	let indent = repeat(' ', numspaces)
	echomsg head tail
	for linum in range(head + 1, tail)
		let line = getline(linum)
		let line = substitute(line, spaces, indent, '')
		call setline(linum, line)
	endfor
	return itemhead
endfun

fun! organ#bush#recount ()
	" Update counters in ordered list
	" TODO
	let position = getcurpos ()
	let first = organ#colibri#list_start ()
	let last =  organ#colibri#list_end ()
	let counters = {}
	let itemhead_pattern = organ#colibri#generic_pattern ()
	let flags = organ#utils#search_flags ('backward', 'move', 'dont-wrap')
	call cursor(first, 1)
	while v:true
		let linum = search(itemhead_pattern, flags)
		if linum > last
			break
		endif
	endwhile
	call setpos('.', position)
endfun

" ---- new list item

fun! organ#bush#new ()
	" New list item
	let properties = organ#colibri#properties ()
	" ---- indent
	let level = properties.level
	let shift = organ#colibri#common_indent ()
	let step = g:organ_config.list.indent_length
	let numspaces = shift + step * (level - 1)
	let indent = repeat(' ', numspaces)
	" ---- prefix
	let prefix = properties.prefix
	let line = indent .. prefix
	" ---- increment if needed
	let counter_pattern = '[0-9]\+'
	let counter = line->matchstr(counter_pattern)
	if ! empty(counter)
		let counter = str2nr(counter) + 1
		let line = substitute(line, counter_pattern, counter, '')
	endif
	" ---- append to buffer
	call append('.', line)
	" ---- update counters
	call organ#bush#recount ()
	" ---- move cursor
	let linum = line('.') + 1
	call cursor(linum, 1)
	let colnum = col('$')
	call cursor(linum, colnum)
	startinsert!
endfun

" ---- select, yank, delete

fun! organ#bush#select_subtree ()
	" Visually select subtree
	let subtree = organ#colibri#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	call cursor(head_linum, 1)
	normal! V
	call cursor(tail_linum, 1)
	return subtree
endfun

fun! organ#bush#yank_subtree ()
	" Visually yank subtree
	let subtree = organ#colibri#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	let range = head_linum .. ',' .. tail_linum
	execute range .. 'yank "'
	return subtree
endfun

fun! organ#bush#delete_subtree ()
	" Visually delete subtree
	let subtree = organ#colibri#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	let range = head_linum .. ',' .. tail_linum
	execute range .. 'delete "'
	return subtree
endfun

" ---- promote & demote

" -- current only

fun! organ#bush#promote ()
	" Promote list item
	if empty(&filetype) || keys(g:organ_config.list.unordered)->index(&filetype) < 0
		echomsg 'organ colibri generic pattern : filetype not supported'
		return ''
	endif
	let properties = organ#colibri#properties ()
	let linum = properties.linum
	let itemhead = properties.itemhead
	" --- indent
	let spaces = repeat(' ', &tabstop)
	let itemhead = substitute(itemhead, '	', spaces, 'g')
	let level = properties.level
	if level == 1
		echomsg 'organ bush promote : already at top level'
		return 0
	endif
	let itemhead = organ#bush#indent_item (level - 1)
	" ---- unordered item
	let unordered = g:organ_config.list.unordered[&filetype]
	let len_unordered = len(unordered)
	for index in range(len(unordered))
		let second = '[' .. unordered[index] .. ']'
		if itemhead =~ '\m^\s*' .. second
			let stripe = organ#utils#circular_minus(index, len_unordered)
			let first = unordered[stripe]
			let itemhead = substitute(itemhead, second, first, '')
			call setline(linum, itemhead)
			return linum
		endif
	endfor
	" ---- ordered item
	let ordered = g:organ_config.list.ordered[&filetype]
	let len_ordered = len(ordered)
	for index in range(len(ordered))
		let second = '[' .. ordered[index] .. ']'
		if itemhead =~ '\m^\s*[0-9]\+' .. second
			let stripe = organ#utils#circular_minus(index, len_ordered)
			let first = ordered[stripe]
			let itemhead = substitute(itemhead, second, first, '')
			call setline(linum, itemhead)
			return linum
		endif
	endfor
endfun

fun! organ#bush#demote ()
	" Demote list item
	if empty(&filetype) || keys(g:organ_config.list.unordered)->index(&filetype) < 0
		echomsg 'organ colibri generic pattern : filetype not supported'
		return ''
	endif
	let properties = organ#colibri#properties ()
	let linum = properties.linum
	let itemhead = properties.itemhead
	" --- indent
	let spaces = repeat(' ', &tabstop)
	let itemhead = substitute(itemhead, '	', spaces, 'g')
	let level = properties.level
	let itemhead = organ#bush#indent_item (level + 1)
	" ---- unordered item
	let unordered = g:organ_config.list.unordered[&filetype]
	let len_unordered = len(unordered)
	for index in range(len(unordered))
		let first = '[' .. unordered[index] .. ']'
		if itemhead =~ '\m^\s*' .. first
			let stripe = organ#utils#circular_plus(index, len_unordered)
			let second = unordered[stripe]
			let itemhead = substitute(itemhead, first, second, '')
			call setline(linum, itemhead)
			return linum
		endif
	endfor
	" ---- ordered item
	let ordered = g:organ_config.list.ordered[&filetype]
	let len_ordered = len(ordered)
	for index in range(len(ordered))
		let first = '[' .. ordered[index] .. ']'
		if itemhead =~ '\m^\s*[0-9]\+' .. first
			let stripe = organ#utils#circular_plus(index, len_ordered)
			let second = ordered[stripe]
			let itemhead = substitute(itemhead, first, second, '')
			call setline(linum, itemhead)
			return linum
		endif
	endfor
endfun

" -- subtree

fun! organ#bush#promote_subtree ()
	" Promote list item subtree
	let subtree = organ#colibri#subtree ()
	let head_linum = subtree.head_linum
	if head_linum == 0
		echomsg 'organ bush promote subtree : itemhead not found'
		return 0
	endif
	let level = subtree.level
	if level == 1
		echomsg 'organ bush promote subtree : already at top level'
		return 0
	endif
	let tail_linum = subtree.tail_linum
	while v:true
		let linum = organ#bush#promote ()
		let linum = organ#colibri#next ('move', 'dont-wrap')
		if linum > tail_linum || linum == 0
			call cursor(head_linum, 1)
			return linum
		endif
	endwhile
endfun

fun! organ#bush#demote_subtree ()
	" Demote list item subtree
	let subtree = organ#colibri#subtree ()
	let head_linum = subtree.head_linum
	if head_linum == 0
		echomsg 'organ tree demote subtree : itemhead not found'
		return 0
	endif
	let tail_linum = subtree.tail_linum
	while v:true
		let linum = organ#bush#demote ()
		let linum = organ#colibri#next ('move', 'dont-wrap')
		if linum > tail_linum || linum == 0
			call cursor(head_linum, 1)
			return linum
		endif
	endwhile
endfun

" ---- move

fun! organ#bush#move_subtree_backward ()
	" Move subtree backward
	let subtree = organ#colibri#subtree ('move')
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	let range = head_linum .. ',' .. tail_linum
	let level = subtree.level
	let itemhead_pattern = organ#colibri#level_pattern (1, level)
	let flags = organ#utils#search_flags ('backward', 'dont-move', 'dont-wrap')
	let target = search(itemhead_pattern, flags) - 1
	execute range .. 'move' target
	call cursor(target + 1, 1)
	return target
endfun

fun! organ#bush#move_subtree_forward ()
	" Move_subtree_forward
	let subtree = organ#colibri#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	let range = head_linum .. ',' .. tail_linum
	let level = subtree.level
	let same_pattern = organ#colibri#level_pattern (level, level)
	let level -= 1
	let upper_pattern = organ#colibri#level_pattern (level, level)
	let flags = organ#utils#search_flags ('forward', 'dont-move', 'dont-wrap')
	let same_linum = search(same_pattern, flags)
	let upper_linum = search(upper_pattern, flags)
	if same_linum < upper_linum || upper_linum == 0
		call cursor(same_linum, 1)
		let same_subtree = organ#colibri#subtree ()
		let target = same_subtree.tail_linum
	else
		call cursor(upper_linum, 1)
		let itemhead_pattern = organ#colibri#generic_pattern ()
		let target = search(itemhead_pattern, flags) - 1
	endif
	execute range .. 'move' target
	let spread = tail_linum - head_linum
	let new_place = target - spread
	call cursor(new_place, 1)
	return new_place
endfun
