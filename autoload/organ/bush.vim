" vim: set ft=vim fdm=indent iskeyword&:

" Bush
"
" Operations on orgmode or markdown lists hierarchy

" ---- script constants

" ---- new list item

fun! organ#bush#new ()
	" New list item
	" TODO
	let properties = organ#colibri#properties ()
	let level = properties.level
	"let line = organ#colibri#char()->repeat(level)
	let line ..= ' '
	let linelist = [line, '']
	call append('.', linelist)
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
	let linum = organ#colibri#itemhead ()
	let line = getline(linum)
	" --- indent
	let spaces = repeat(' ', &tabstop)
	let line = substitute(line, '	', spaces, 'g')
	let indent_length = g:organ_config.list.indent_length
	let list_indent = repeat(' ', indent_length)
	if line[:indent_length - 1] == list_indent
		let line = line[indent_length:]
	endif
	" ---- unordered item
	let unordered = g:organ_config.list.unordered[&filetype]
	let len_unordered = len(unordered)
	for index in range(len(unordered))
		let second = unordered[index]
		if line =~ '^\s*' .. second
			let first = organ#utils#circular_minus(index, len_unordered)
			let line = substitute(line, second, first, '')
			call setline(linum, line)
			return linum
		endif
	endfor
	" ---- ordered item
	let ordered = g:organ_config.list.ordered[&filetype]
	let len_ordered = len(ordered)
	for index in range(len(ordered))
		let second = ordered[index]
		if line =~ '^\s*' .. second
			let first = organ#utils#circular_minus(index, len_ordered)
			let line = substitute(line, second, first, '')
			call setline(linum, line)
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
	let linum = organ#colibri#itemhead ()
	let line = getline(linum)
	" --- indent
	let spaces = repeat(' ', &tabstop)
	let line = substitute(line, '	', spaces, 'g')
	let indent_length = g:organ_config.list.indent_length
	let list_indent = repeat(' ', indent_length)
	let line = list_indent .. line
	call setline(linum, line)
	" ---- unordered item
	let unordered = g:organ_config.list.unordered[&filetype]
	let len_unordered = len(unordered)
	for index in range(len(unordered))
		let first = unordered[index]
		if line =~ '^\s*' .. first
			let second = organ#utils#circular_plus(index, len_unordered)
			let line = substitute(line, first, second, '')
			call setline(linum, line)
			return linum
		endif
	endfor
	" ---- ordered item
	let ordered = g:organ_config.list.ordered[&filetype]
	let len_ordered = len(ordered)
	for index in range(len(ordered))
		let first = ordered[index]
		if line =~ '^\s*' .. first
			let second = organ#utils#circular_plus(index, len_ordered)
			let line = substitute(line, first, second, '')
			call setline(linum, line)
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
		if linum >= tail_linum || linum == 0
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
		if linum >= tail_linum || linum == 0
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
