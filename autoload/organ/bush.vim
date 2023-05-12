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

fun! organ#bush#indent_item (level)
	" Indent all list item line(s)
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

fun! organ#bush#update_counters (maxlevel = 100)
	" Update counters in ordered list
	let maxlevel = a:maxlevel
	let length = maxlevel
	let global_counter_start = g:organ_config.list.counter_start
	let position = getcurpos ()
	let first = organ#colibri#list_start ()
	let last =  organ#colibri#list_end ()
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
		let counter_start = properties.counter
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

fun! organ#bush#cycle_prefix_right (...)
	" Cycle item prefix
	if a:0 > 0
		let properties = a:1
	else
		let properties = organ#colibri#properties ()
	endif
	let properties = organ#colibri#properties ()
	let linum = properties.linum
	let indent = properties.indent
	let level = properties.level
	let prefix = properties.prefix
	let counter = properties.counter
	let checkbox = properties.checkbox
	let todo = properties.todo
	let text = properties.text
	" ---- standardize prefix
	let prefix = substitute(prefix, '\m[0-9]\+', '1', '')
	" ---- prefix list
	if empty(&filetype) || keys(g:organ_config.list.unordered)->index(&filetype) < 0
		let filekey = 'default'
	else
		let filekey = &filetype
	endif
	let unordered = copy(g:organ_config.list.unordered[filekey])
	let ordered = copy(g:organ_config.list.ordered[filekey])
	let ordered = ordered->map({ _, v -> '1' .. v })
	let prefixlist = unordered + ordered
	" ---- no * if no indent
	if indent ==# ''
		let starindex = prefixlist->index('*')
		if starindex > 0
			eval prefixlist->remove(starindex)
		endif
	endif
	" ---- cycle
	let index = prefixlist->index(prefix)
	let length = len(prefixlist)
	let next = organ#utils#circular_plus (index, length)
	let next_prefix = prefixlist[next]
	" ---- add spaces
	let next_prefix = next_prefix .. ' '
	if counter >= 0
		let counter = '[@' .. counter .. '] '
	else
		let counter = ''
	endif
	if ! empty(checkbox)
		let checkbox = checkbox .. ' '
	endif
	if ! empty(todo)
		let todo = todo .. ' '
	endif
	" ---- update line
	let newline = indent .. next_prefix .. counter .. checkbox .. todo .. text
	call setline(linum, newline)
	" ---- update counters
	if next_prefix =~ '\m^1'
		call organ#bush#update_counters ()
	endif
	" ---- indent all item line(s)
	call organ#bush#indent_item (level)
	" ---- coda
	return properties
endfun

fun! organ#bush#cycle_prefix_left (...)
	" Cycle item prefix
	if a:0 > 0
		let properties = a:1
	else
		let properties = organ#colibri#properties ()
	endif
	let properties = organ#colibri#properties ()
	let linum = properties.linum
	let indent = properties.indent
	let level = properties.level
	let prefix = properties.prefix
	let counter = properties.counter
	let checkbox = properties.checkbox
	let todo = properties.todo
	let text = properties.text
	" ---- standardize prefix
	let prefix = substitute(prefix, '\m[0-9]\+', '1', '')
	" ---- prefix list
	if empty(&filetype) || keys(g:organ_config.list.unordered)->index(&filetype) < 0
		let filekey = 'default'
	else
		let filekey = &filetype
	endif
	let unordered = copy(g:organ_config.list.unordered[filekey])
	let ordered = copy(g:organ_config.list.ordered[filekey])
	let ordered = ordered->map({ _, v -> '1' .. v })
	let prefixlist = unordered + ordered
	" ---- no * if no indent
	if indent ==# ''
		let starindex = prefixlist->index('*')
		if starindex > 0
			eval prefixlist->remove(starindex)
		endif
	endif
	" ---- cycle
	let index = prefixlist->index(prefix)
	let length = len(prefixlist)
	let next = organ#utils#circular_minus (index, length)
	let next_prefix = prefixlist[next]
	" ---- add spaces
	let next_prefix = next_prefix .. ' '
	if counter >= 0
		let counter = '[@' .. counter .. '] '
	else
		let counter = ''
	endif
	if ! empty(checkbox)
		let checkbox = checkbox .. ' '
	endif
	if ! empty(todo)
		let todo = todo .. ' '
	endif
	" ---- update line
	let newline = indent .. next_prefix .. counter .. checkbox .. todo .. text
	call setline(linum, newline)
	" --- update counters
	if next_prefix =~ '\m^1'
		call organ#bush#update_counters ()
	endif
	" ---- indent all item line(s)
	call organ#bush#indent_item (level)
	" ---- coda
	return properties
endfun

fun! organ#bush#cycle_all_prefixes_right ()
	" Cycle prefix of all items in parent subtree
	let position = getcurpos ()
	let properties = organ#colibri#properties ()
	let level = properties.level
	if level > 1
		let linum = organ#colibri#parent ()
		let subtree = organ#colibri#subtree ()
		let head_linum = subtree.head_linum
		let tail_linum = subtree.tail_linum
	else
		let head_linum = organ#colibri#list_start ()
		let tail_linum = organ#colibri#list_end ()
	endif
	if head_linum == 0
		echomsg 'organ bush cycle parent subtree prefix : itemhead not found'
		return 0
	endif
	call cursor(head_linum, 1)
	while v:true
		let properties = organ#colibri#properties ()
		if level == properties.level
			call organ#bush#cycle_prefix_right (properties)
		endif
		let linum = organ#colibri#next ('move', 'dont-wrap')
		if linum > tail_linum || linum == 0
			call setpos('.', position)
			return linum
		endif
	endwhile
endfun

fun! organ#bush#cycle_all_prefixes_left ()
	" Cycle prefix of all items in parent subtree
	let position = getcurpos ()
	let properties = organ#colibri#properties ()
	let level = properties.level
	if level > 1
		let linum = organ#colibri#parent ()
		let subtree = organ#colibri#subtree ()
		let head_linum = subtree.head_linum
		let tail_linum = subtree.tail_linum
	else
		let head_linum = organ#colibri#list_start ()
		let tail_linum = organ#colibri#list_end ()
	endif
	if head_linum == 0
		echomsg 'organ bush cycle parent subtree prefix : itemhead not found'
		return 0
	endif
	call cursor(head_linum, 1)
	while v:true
		let properties = organ#colibri#properties ()
		if level == properties.level
			call organ#bush#cycle_prefix_left (properties)
		endif
		let linum = organ#colibri#next ('move', 'dont-wrap')
		if linum > tail_linum || linum == 0
			call setpos('.', position)
			return linum
		endif
	endwhile
endfun

" ---- promote & demote

" -- current only

fun! organ#bush#promote ()
	" Promote list item
	if empty(&filetype) || keys(g:organ_config.list.unordered)->index(&filetype) < 0
		let filekey = 'default'
	else
		let filekey = &filetype
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
	let unordered = g:organ_config.list.unordered[filekey]
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
	let ordered = g:organ_config.list.ordered[filekey]
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
		let filekey = 'default'
	else
		let filekey = &filetype
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
	let unordered = g:organ_config.list.unordered[filekey]
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
	let ordered = g:organ_config.list.ordered[filekey]
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
		echomsg 'organ bush demote subtree : itemhead not found'
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

" ---- checkbox

fun! organ#bush#toggle_checkbox ()
	" Cycle todo keyword marker left
	let properties = organ#colibri#properties ()
	let linum = properties.linum
	let indent = properties.indent
	let level = properties.level
	let prefix = properties.prefix
	let counter = properties.counter
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
	if counter >= 0
		let counter = '[@' .. counter .. '] '
	else
		let counter = ''
	endif
	let toggled_checkbox = toggled_checkbox .. ' '
	if ! empty(todo)
		let todo = todo .. ' '
	endif
	" ---- update line
	let newline = indent .. prefix .. counter .. toggled_checkbox .. todo .. text
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
	let counter = properties.counter
	let checkbox = properties.checkbox
	let todo = properties.todo
	let text = properties.text
	" ---- next in cycle
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
	if counter >= 0
		let counter = '[@' .. counter .. '] '
	else
		let counter = ''
	endif
	if ! empty(checkbox)
		let checkbox = checkbox .. ' '
	endif
	if ! empty(previous_todo)
		let previous_todo = previous_todo .. ' '
	endif
	" ---- update line
	let newline = indent .. prefix .. counter .. checkbox .. previous_todo .. text
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
	let counter = properties.counter
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
	if counter >= 0
		let counter = '[@' .. counter .. '] '
	else
		let counter = ''
	endif
	if ! empty(checkbox)
		let checkbox = checkbox .. ' '
	endif
	if ! empty(next_todo)
		let next_todo = next_todo .. ' '
	endif
	" ---- update line
	let newline = indent .. prefix .. counter .. checkbox .. next_todo .. text
	call setline(linum, newline)
	" ---- coda
	return newline
endfun
