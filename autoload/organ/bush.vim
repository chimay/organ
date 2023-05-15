" vim: set ft=vim fdm=indent iskeyword&:

" Bush
"
" Operations on orgmode or markdown lists hierarchy

" ---- script constants

if ! exists('s:rep_one_char')
	let s:rep_one_char = organ#crystal#fetch('filetypes/repeated_one_char_heading')
	lockvar s:rep_one_char
endif

" ---- helpers

fun! organ#bush#indent_item (level, ...)
	" Indent all list item line(s)
	let level = a:level
	if a:0 > 0
		let properties = a:1
	else
		let properties = organ#colibri#properties ()
	endif
	let head = properties.linum
	let itemhead = properties.itemhead
	let tail = organ#colibri#itemtail ()
	let len_prefix = len(properties.prefix)
	" ---- item head line
	let shift = organ#colibri#common_indent ()
	let step = g:organ_config.list.indent_length
	let spaces = '\m^\s*'
	let numspaces = shift + step * (level - 1)
	let indent = repeat(' ', numspaces)
	let itemhead = substitute(itemhead, spaces, indent, '')
	call setline(head, itemhead)
	let properties.itemhead = itemhead
	" ---- other lines
	if head >= tail
		return itemhead
	endif
	" -- length prefix + one space
	let numspaces += len_prefix + 1
	let indent = repeat(' ', numspaces)
	for linum in range(head + 1, tail)
		let line = getline(linum)
		let line = substitute(line, spaces, indent, '')
		call setline(linum, line)
	endfor
	return itemhead
endfun

fun! organ#bush#update_counters (maxlevel = 30)
	" Update counters in ordered list
	let maxlevel = a:maxlevel
	let length = maxlevel
	let global_counter_start = g:organ_config.list.counter_start
	let position = getcurpos ()
	" ---- find boundaries
	let first = organ#colibri#list_start ()
	let last = organ#colibri#list_end ()
	" ---- counters
	let counterlist = repeat([-1], maxlevel)
	let counter_pattern = '\m^\s*\zs[0-9]\+'
	let itemhead_pattern = organ#colibri#generic_pattern ()
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
		let counter_start = properties.counter_start
		let countindex = level - 1
		for index in range(countindex + 1, length - 1)
			let counterlist[index] = -1
		endfor
		if counter_start >= 0
			let counterlist[countindex] = counter_start
		else
			if counterlist[countindex] < 0
				let counterlist[countindex] = global_counter_start
			else
				let counterlist[countindex] += 1
			endif
		endif
		let count = counterlist[countindex]
		let line = properties.itemhead
		let line = substitute(line, counter_pattern, count, '')
		call setline(linum, line)
		let linum = search(itemhead_pattern, flags)
	endwhile
	call setpos('.', position)
	return counterlist
endfun

fun! organ#bush#rotate_prefix (direction = 1, ...)
	" Return next/previous item prefix
	" direction : 1 = right = next, -1 = left = previous
	let direction = a:direction
	if a:0 > 0
		let properties = a:1
	else
		let properties = organ#colibri#properties ()
	endif
	if a:0 > 1
		let type = a:2
	else
		let type = 'all'
	endif
	" ---- standardize prefix
	let prefix = properties.prefix
	let prefix = substitute(prefix, '\m^\s*\zs[0-9]\+', '1', '')
	" ---- prefix list
	if empty(&filetype) || keys(g:organ_config.list.unordered)->index(&filetype) < 0
		let filekey = 'default'
	else
		let filekey = &filetype
	endif
	let unordered = copy(g:organ_config.list.unordered[filekey])
	let ordered = copy(g:organ_config.list.ordered[filekey])
	let ordered = ordered->map({ _, v -> '1' .. v })
	if type ==# 'all'
		let prefixlist = unordered + ordered
	elseif unordered->index(prefix) >= 0
		let prefixlist = unordered
	elseif ordered->index(prefix) >= 0
		let prefixlist = ordered
	else
		throw 'organ bush rotate prefix : unknown prefix'
	endif
	" ---- no * if no indent
	let indent = properties.indent
	if indent ==# ''
		let starindex = prefixlist->index('*')
		if starindex > 0
			eval prefixlist->remove(starindex)
		endif
	endif
	" ---- cycle
	let index = prefixlist->index(prefix)
	let length = len(prefixlist)
	if direction == 1
		let newindex = organ#utils#circular_plus (index, length)
	elseif direction == -1
		let newindex = organ#utils#circular_minus (index, length)
	else
		throw 'organ bush cycle prefix : bad direction'
	endif
	return prefixlist[newindex]
endfun

fun! organ#bush#set_prefix (prefix, ...)
	" Cycle item prefix
	" direction : 1 = right, -1 = left
	let prefix = a:prefix
	if a:0 > 0
		let properties = a:1
	else
		let properties = organ#colibri#properties ()
	endif
	let linum = properties.linum
	let itemhead = properties.itemhead
	let level = properties.level
	" ---- update line
	let prefix_pattern = '\m^\s*\zs\S\+'
	let newitem = substitute(itemhead, prefix_pattern, prefix, '')
	let properties.itemhead = newitem
	call setline(linum, newitem)
	" ---- indent all item line(s)
	call organ#bush#indent_item (level)
	return newitem
endfun

fun! organ#bush#update_prefix (direction = 1, ...)
	" Set prefix to the one used by same level neighbours in same subtree
	" If alone in level, just rotate prefix following promote/demote direction
	" direction : 1 = right = next, -1 = left = previous
	let direction = a:direction
	if a:0 > 0
		let properties = a:1
	else
		let properties = organ#colibri#properties ()
	endif
	let position = getcurpos ()
	let linum = properties.linum
	let level = properties.level
	" ---- find boundaries
	if level > 1
		let parent_linum = organ#colibri#parent ()
		let subtree = organ#colibri#subtree ()
		let first = subtree.head_linum
		let last = subtree.tail_linum
		call setpos('.',  position)
	else
		let first = organ#colibri#list_start ()
		let last = organ#colibri#list_end ()
	endif
	if first == 0
		echomsg 'organ bush cycle prefix : itemhead not found'
		return 0
	endif
	" ---- potential neighbours
	call organ#colibri#itemhead ('move')
	let linum_back = organ#colibri#backward ('dont-move', 'dont-wrap')
	let linum_forth = organ#colibri#forward ('dont-move', 'dont-wrap')
	if linum_back > 0 && linum_back != linum && linum_back >= first
		call cursor(linum_back, 1)
		let neighbour = organ#colibri#properties ()
		let prefix = neighbour.prefix
	elseif linum_forth > 0 && linum_forth != linum && linum_forth <= last
		call cursor(linum_forth, 1)
		let neighbour = organ#colibri#properties ()
		let prefix = neighbour.prefix
	else
		" --- alone of level in subtree
		let prefix = organ#bush#rotate_prefix (direction, properties, 'same-kind')
	endif
	let level = properties.level
	call organ#bush#set_prefix (prefix, properties)
	" ---- coda
	call setpos('.',  position)
	return properties
endfun

" ---- new list item

fun! organ#bush#new ()
	" New list item
	call organ#origami#suspend ()
	let properties = organ#colibri#properties ()
	" ---- indent
	let level = properties.level
	let shift = organ#colibri#common_indent ()
	let step = g:organ_config.list.indent_length
	let numspaces = shift + step * (level - 1)
	let indent = repeat(' ', numspaces)
	" ---- prefix
	let prefix = properties.prefix
	let line = indent .. prefix .. ' '
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
	call organ#origami#resume ()
endfun

fun! organ#bush#new_with_check ()
	" New list item with check box
	let properties = organ#colibri#properties ()
	" ---- indent
	let level = properties.level
	let shift = organ#colibri#common_indent ()
	let step = g:organ_config.list.indent_length
	let numspaces = shift + step * (level - 1)
	let indent = repeat(' ', numspaces)
	" ---- prefix
	let prefix = properties.prefix
	let line = indent .. prefix .. ' [ ] '
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

" ---- cycle prefix

fun! organ#bush#cycle_prefix (direction = 1)
	" Cycle prefix of all same-level items in parent subtree or in list
	" direction : 1 = right = next, -1 = left = previous
	call organ#origami#suspend ()
	let direction = a:direction
	let position = getcurpos ()
	let properties = organ#colibri#properties ()
	let level = properties.level
	" ---- find boundaries
	if level > 1
		let linum = organ#colibri#parent ()
		let subtree = organ#colibri#subtree ()
		let first = subtree.head_linum
		let last = subtree.tail_linum
		call setpos('.',  position)
	else
		let first = organ#colibri#list_start ()
		let last = organ#colibri#list_end ()
	endif
	if first == 0
		echomsg 'organ bush cycle prefix : itemhead not found'
		return 0
	endif
	" ---- rotate prefix
	let newprefix = organ#bush#rotate_prefix (direction, properties)
	" ---- loop
	call cursor(first, 1)
	while v:true
		let properties = organ#colibri#properties ()
		if level == properties.level
			call organ#bush#set_prefix (newprefix, properties)
		endif
		let linum = organ#colibri#next ('move', 'dont-wrap')
		if linum > last || linum == 0
			break
		endif
	endwhile
	" ---- update counters
	if newprefix =~ '\m^[0-9]\+'
		call cursor(first, 1)
		call organ#bush#update_counters ()
	endif
	" ---- coda
	call setpos('.', position)
	call organ#origami#resume ()
	return newprefix
endfun

" ---- checkbox

fun! organ#bush#toggle_checkbox ()
	" Cycle todo keyword marker left
	let properties = organ#colibri#properties ()
	let linum = properties.linum
	let indent = properties.indent
	let level = properties.level
	let prefix = properties.prefix
	let counter_start = properties.counter_start
	let checkbox = properties.checkbox
	let todo = properties.todo
	let text = properties.text
	" ---- toggle checkbox
	if empty(checkbox)
		let toggled_checkbox = '[ ]'
	elseif checkbox ==# '[ ]'
		let toggled_checkbox = '[X]'
	elseif checkbox =~ '\m\[[Xx]\]'
		let toggled_checkbox = '[ ]'
	else
		throw 'organ bush toggle checkbox : bad checkbox format'
	endif
	" ---- add spaces
	let prefix = prefix .. ' '
	if counter_start >= 0
		let counter_start = '[@' .. counter_start .. '] '
	else
		let counter_start = ''
	endif
	let toggled_checkbox = toggled_checkbox .. ' '
	if ! empty(todo)
		let todo = todo .. ' '
	endif
	" ---- update line
	let newline = indent .. prefix .. counter_start .. toggled_checkbox .. todo .. text
	call setline(linum, newline)
	return newline
endfun

" ---- todo

fun! organ#bush#cycle_todo_left ()
	" Cycle todo keyword marker left
	let properties = organ#colibri#properties ()
	let linum = properties.linum
	let indent = properties.indent
	let level = properties.level
	let prefix = properties.prefix
	let counter_start = properties.counter_start
	let checkbox = properties.checkbox
	let todo = properties.todo
	let text = properties.text
	" ---- previous in cycle
	let todo = properties.todo
	let todo_cycle = g:organ_config.todo_cycle
	let lencycle = len(todo_cycle)
	let cycle_index = todo_cycle->index(todo)
	if cycle_index < 0
		let previous_todo = todo_cycle[-1]
	elseif cycle_index == 0
		let previous_todo = ''
	else
		let previous_todo = todo_cycle[cycle_index - 1]
	endif
	" ---- add spaces
	let prefix = prefix .. ' '
	if counter_start >= 0
		let counter_start = '[@' .. counter_start .. '] '
	else
		let counter_start = ''
	endif
	if ! empty(checkbox)
		let checkbox = checkbox .. ' '
	endif
	if ! empty(previous_todo)
		let previous_todo = previous_todo .. ' '
	endif
	" ---- update line
	let newline = indent .. prefix .. counter_start .. checkbox .. previous_todo .. text
	call setline(linum, newline)
	" ---- coda
	return newline
endfun

fun! organ#bush#cycle_todo_right ()
	" Cycle todo keyword marker right
	let properties = organ#colibri#properties ()
	let linum = properties.linum
	let indent = properties.indent
	let level = properties.level
	let prefix = properties.prefix
	let counter_start = properties.counter_start
	let checkbox = properties.checkbox
	let todo = properties.todo
	let text = properties.text
	" ---- next in cycle
	let todo = properties.todo
	let todo_cycle = g:organ_config.todo_cycle
	let lencycle = len(todo_cycle)
	let cycle_index = todo_cycle->index(todo)
	if cycle_index < 0
		let next_todo = todo_cycle[0]
	elseif cycle_index == lencycle - 1
		let next_todo = ''
	else
		let next_todo = todo_cycle[cycle_index + 1]
	endif
	" ---- add spaces
	let prefix = prefix .. ' '
	if counter_start >= 0
		let counter_start = '[@' .. counter_start .. '] '
	else
		let counter_start = ''
	endif
	if ! empty(checkbox)
		let checkbox = checkbox .. ' '
	endif
	if ! empty(next_todo)
		let next_todo = next_todo .. ' '
	endif
	" ---- update line
	let newline = indent .. prefix .. counter_start .. checkbox .. next_todo .. text
	call setline(linum, newline)
	" ---- coda
	return newline
endfun

" ---- promote & demote

" -- current only

fun! organ#bush#promote (mode = 'alone')
	" Promote list item
	let mode = a:mode
	if mode ==# 'alone'
		call organ#origami#suspend ()
	endif
	let properties = organ#colibri#properties ()
	let linum = properties.linum
	let level = properties.level
	" --- do nothing if top level
	if level == 1
		echomsg 'organ bush promote : already at top level'
		return 0
	endif
	" --- adjust indent
	let properties.itemhead = organ#bush#indent_item (level - 1, properties)
	let properties.level -= 1
	" ---- update prefix
	call organ#bush#update_prefix (-1, properties)
	" ---- update counters
	if mode ==# 'alone'
		call organ#bush#update_counters ()
		call organ#origami#resume ()
	endif
	" ---- coda
	return linum
endfun

fun! organ#bush#demote (mode = 'alone')
	" Demote list item
	let mode = a:mode
	if mode ==# 'alone'
		call organ#origami#suspend ()
	endif
	let properties = organ#colibri#properties ()
	let linum = properties.linum
	let level = properties.level
	" --- adjust indent
	let properties.itemhead = organ#bush#indent_item (level + 1, properties)
	let properties.level += 1
	" ---- update prefix
	call organ#bush#update_prefix (1, properties)
	" ---- update counters
	if mode ==# 'alone'
		call organ#bush#update_counters ()
		call organ#origami#resume ()
	endif
	" ---- coda
	return linum
endfun

" -- subtree

fun! organ#bush#promote_subtree ()
	" Promote list item subtree
	call organ#origami#suspend ()
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
		let linum = organ#bush#promote ('batch')
		let linum = organ#colibri#next ('move', 'dont-wrap')
		if linum > tail_linum || linum == 0
			break
		endif
	endwhile
	call organ#bush#update_counters ()
	call cursor(head_linum, 1)
	call organ#origami#resume ()
	return linum
endfun

fun! organ#bush#demote_subtree ()
	" Demote list item subtree
	call organ#origami#suspend ()
	let subtree = organ#colibri#subtree ()
	let head_linum = subtree.head_linum
	if head_linum == 0
		echomsg 'organ bush demote subtree : itemhead not found'
		return 0
	endif
	let tail_linum = subtree.tail_linum
	while v:true
		let linum = organ#bush#demote ('batch')
		let linum = organ#colibri#next ('move', 'dont-wrap')
		if linum > tail_linum || linum == 0
			break
		endif
	endwhile
	call organ#bush#update_counters ()
	call cursor(head_linum, 1)
	call organ#origami#resume ()
	return linum
endfun

" ---- move

fun! organ#bush#move_subtree_backward ()
	" Move subtree backward
	call cursor('.', 1)
	let cursor_linum = line('.')
	let subtree = organ#colibri#subtree ('move')
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	let spread = tail_linum - head_linum
	let level = subtree.level
	" ---- find same level and upper level targets candidates
	let same_pattern = organ#colibri#level_pattern (level, level)
	let flags = organ#utils#search_flags ('backward', 'dont-move', 'wrap')
	let same_linum = search(same_pattern, flags)
	if level >= 2
		let upper_level = level - 1
		let upper_pattern = organ#colibri#level_pattern (upper_level, upper_level)
		let upper_linum = search(upper_pattern, flags)
	else
		let upper_linum = 0
	endif
	" ---- nearest candidate
	let nearest = organ#bird#nearest (same_linum, upper_linum, -1)
	if nearest == 0
		" both linum == 0
		echomsg 'organ bush move subtree backward : not found'
		return 0
	endif
	if nearest == cursor_linum
		echomsg 'organ bush move subtree backward : nothing to do'
		return 0
	endif
	" ---- plain backward or wrapped backward ?
	" ---- if plain backward, same or upper level ?
	let backward = nearest < cursor_linum
	if backward
		let cursor_target = nearest
		let target = cursor_target - 1
	else
		call cursor(nearest, 1)
		let same_subtree = organ#colibri#subtree ()
		let target = same_subtree.tail_linum
		let cursor_target = target - spread
	endif
	" ---- move subtree
	let range = head_linum .. ',' .. tail_linum
	execute range .. 'move' target
	" --- move cursor to the new heading place
	call cursor(cursor_target, 1)
	call organ#bush#update_counters ()
	return cursor_target
endfun

fun! organ#bush#move_subtree_forward ()
	" Move subtree forward
	call cursor('.', col('$'))
	let cursor_linum = line('.')
	let subtree = organ#colibri#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	let spread = tail_linum - head_linum
	let level = subtree.level
	" ---- find same level and upper level targets candidates
	let same_pattern = organ#colibri#level_pattern (level, level)
	let flags = organ#utils#search_flags ('forward', 'dont-move', 'wrap')
	let same_linum = search(same_pattern, flags)
	if level >= 2
		let upper_level = level - 1
		let upper_pattern = organ#colibri#level_pattern (upper_level, upper_level)
		let upper_linum = search(upper_pattern, flags)
	else
		let upper_linum = 0
	endif
	" ---- nearest candidate
	let nearest = organ#bird#nearest (same_linum, upper_linum, 1)
	if nearest == 0
		" both linum == 0
		echomsg 'organ bush move subtree forward : not found'
		return 0
	endif
	if nearest == cursor_linum
		echomsg 'organ bush move subtree forward : nothing to do'
		return 0
	endif
	" ---- plain forward or wrapped forward ?
	" ---- if plain forward, same or upper level ?
	let forward = nearest > cursor_linum
	if forward
		if same_linum == nearest
			call cursor(same_linum, 1)
			let same_subtree = organ#colibri#subtree ()
			let target = same_subtree.tail_linum
			let cursor_target = target - spread
		else
			" upper_linum == nearest
			call cursor(upper_linum, 1)
			let itemhead_pattern = organ#colibri#generic_pattern ()
			let anyhead_forward = search(itemhead_pattern, flags)
			if anyhead_forward > 0
				let target = anyhead_forward - 1
			else
				let target = line('$')
			endif
			let cursor_target = target - spread
		endif
	else
		let cursor_target = nearest
		let target = cursor_target - 1
	endif
	" ---- move subtree
	let range = head_linum .. ',' .. tail_linum
	execute range .. 'move' target
	" --- move cursor to the new heading place
	call cursor(cursor_target, 1)
	call organ#bush#update_counters ()
	return cursor_target
endfun
