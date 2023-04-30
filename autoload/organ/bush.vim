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
	for linum in range(head + 1, tail)
		let line = getline(linum)
		let line = substitute(line, spaces, indent, '')
		call setline(linum, line)
	endfor
	return itemhead
endfun

fun! organ#bush#update_counters ()
	" Update counters in ordered list
	let counter_start = g:organ_config.list.counter_start
	let position = getcurpos ()
	let first = organ#colibri#list_start ()
	let last =  organ#colibri#list_end ()
	let counters = {}
	let itemhead_pattern = organ#colibri#generic_pattern ()
	let counter_pattern = '\m^\s*\zs[0-9]\+'
	let flags = organ#utils#search_flags ('forward', 'move', 'dont-wrap')
	call cursor(first, 1)
	let linum = first
	while v:true
		if linum == 0
			break
		endif
		if linum > last
			break
		endif
		let properties = organ#colibri#properties ()
		let prefix = properties.prefix
		let count = prefix->matchstr(counter_pattern)
		if empty(count)
			let linum = search(itemhead_pattern, flags)
			continue
		endif
		let level = properties.level
		let line = properties.itemhead
		if ! has_key(counters, level)
			let counters[level] = counter_start
		else
			let counters[level] += 1
		endif
		let count = counters[level]
		let line = substitute(line, counter_pattern, count, '')
		call setline(linum, line)
		let linum = search(itemhead_pattern, flags)
	endwhile
	call setpos('.', position)
	return counters
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
	" ---- append to buffer
	call append('.', line)
	" ---- update counters
	call organ#bush#update_counters ()
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
	normal! o
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
	execute range .. 'yank "'
	call organ#utils#delete (head_linum, tail_linum)
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
	let itemhead = substitute(itemhead, '\t', spaces, 'g')
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
			call organ#bush#update_counters ()
			if mode() ==# 'i'
				startinsert!
			endif
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
			call organ#bush#update_counters ()
			if mode() ==# 'i'
				startinsert!
			endif
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
	let itemhead = substitute(itemhead, '\t', spaces, 'g')
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
			call organ#bush#update_counters ()
			if mode() ==# 'i'
				startinsert!
			endif
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
			call organ#bush#update_counters ()
			if mode() ==# 'i'
				startinsert!
			endif
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
	let goal = search(itemhead_pattern, flags)
	let target = goal - 1
	execute range .. 'move' target
	call cursor(goal, 1)
	call organ#bush#update_counters ()
	return goal
endfun

fun! organ#bush#move_subtree_forward ()
	" Move_subtree_forward
	let subtree = organ#colibri#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	let range = head_linum .. ',' .. tail_linum
	let level = subtree.level
	let same_pattern = organ#colibri#level_pattern (level, level)
	let flags = organ#utils#search_flags ('forward', 'dont-move', 'dont-wrap')
	let same_linum = search(same_pattern, flags)
	if level >= 2
		let level -= 1
		let upper_pattern = organ#colibri#level_pattern (level, level)
		let upper_linum = search(upper_pattern, flags)
	else
		let upper_linum = 0
	endif
	if same_linum > 0 && (same_linum < upper_linum || upper_linum == 0)
		call cursor(same_linum, 1)
		let same_subtree = organ#colibri#subtree ()
		let target = same_subtree.tail_linum
	else
		call cursor(upper_linum, 1)
		let target = organ#colibri#itemtail ()
		if target == -1
			let target = line('$')
		endif
	endif
	execute range .. 'move' target
	let spread = tail_linum - head_linum
	let goal = target - spread
	call cursor(goal, 1)
	call organ#bush#update_counters ()
	return goal
endfun
