" vim: set ft=vim fdm=indent iskeyword&:

" Bush
"
" Operations on orgmode or markdown lists hierarchy

" ---- script constants

if exists('s:rep_one_char')
	unlockvar s:rep_one_char
endif
let s:rep_one_char = organ#crystal#fetch('filetypes/repeated_one_char_heading')
lockvar s:rep_one_char

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
	let properties.itemhead = itemhead
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
		let newline = substitute(line, spaces, indent, '')
		call setline(linum, newline)
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
		let counter = properties.counter
		if counter < 0
			let linum = search(itemhead_pattern, flags)
			continue
		endif
		let level = properties.level
		let counterstart = properties.counterstart
		let countindex = level - 1
		for index in range(countindex + 1, length - 1)
			let counterlist[index] = -1
		endfor
		if counterstart >= 0
			let counterlist[countindex] = counterstart
		else
			if counterlist[countindex] < 0
				let counterlist[countindex] = global_counter_start
			else
				let counterlist[countindex] += 1
			endif
		endif
		let count = counterlist[countindex]
		let line = properties.itemhead
		let newline = substitute(line, counter_pattern, count, '')
		call setline(linum, newline)
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
	" direction : 1 = right = next, -1 = left = previous
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
		let parent_linum = organ#colibri#parent ('move', 'dont-wrap')
		let subtree = organ#colibri#subtree ()
		let first = subtree.head_linum
		let last = subtree.tail_linum
		call setpos('.', position)
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
	call cursor('.', 1)
	let linum_back = organ#colibri#backward ('dont-move', 'dont-wrap')
	call cursor('.', col('$'))
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
	call setpos('.', position)
	return properties
endfun

fun! organ#bush#rotate_todo (direction = 1, ...)
	" Return next/previous todo keywoard
	" direction : 1 = right = next, -1 = left = previous
	let direction = a:direction
	if a:0 > 0
		let properties = a:1
	else
		let properties = organ#colibri#properties ()
	endif
	let todo = properties.todo
	let todo_cycle = g:organ_config.todo_cycle
	let lencycle = len(todo_cycle)
	let cycle_index = todo_cycle->index(todo)
	if direction == 1
		if cycle_index < 0
			let newtodo = todo_cycle[0]
		elseif cycle_index == lencycle - 1
			let newtodo = ''
		else
			let newtodo = todo_cycle[cycle_index + 1]
		endif
	elseif direction == -1
		if cycle_index < 0
			let newtodo = todo_cycle[-1]
		elseif cycle_index == 0
			let newtodo = ''
		else
			let newtodo = todo_cycle[cycle_index - 1]
		endif
	endif
	return newtodo
endfun

fun! organ#bush#update_ratios (maxlevel = 30)
	" Update ratios of [X] checked boxes in parent
	let maxlevel = a:maxlevel
	let position = getcurpos ()
	let length = maxlevel
	let linumlist = []
	let lastlinumlist = repeat([-1], maxlevel)
	let ratiodict = {}
	" ---- find boundaries
	let first = organ#colibri#list_start ()
	let last = organ#colibri#list_end ()
	" ---- scan checkboxes
	let itemhead_pattern = organ#colibri#generic_pattern ()
	let flags = organ#utils#search_flags ('forward', 'move', 'dont-wrap')
	let ratio_pattern = '\m\[[0-9]\+/[0-9]\+\]$'
	call cursor(first, 1)
	let linum = first
	while v:true
		if linum == 0
			break
		endif
		if linum > last
			break
		endif
		eval linumlist->add(linum)
		let properties = organ#colibri#properties ()
		" -- lastlinumlist
		let level = properties.level
		let levelindex = level - 1
		let lastlinumlist[levelindex] = linum
		" -- parent = last linum of level - 1
		if level == 1
			let linum = search(itemhead_pattern, flags)
			continue
		endif
		let checkbox = properties.checkbox
		if checkbox < 0
			let linum = search(itemhead_pattern, flags)
			continue
		endif
		let parentindex = level - 2
		let parent_linum = lastlinumlist[parentindex]
		if ! has_key(ratiodict, parent_linum)
			let ratiodict[parent_linum] = [checkbox, 1]
		else
			let ratio = ratiodict[parent_linum]
			let ratio = [ratio[0] + checkbox, ratio[1] + 1]
			let ratiodict[parent_linum] = ratio
		endif
		" -- next
		let linum = search(itemhead_pattern, flags)
	endwhile
	" ---- update ratios strings
	for linum in linumlist
		let line = getline(linum)
		if has_key(ratiodict, linum)
			let ratio = ratiodict[linum]
			let ratiostring = '[' .. ratio[0] .. '/' .. ratio[1] .. ']'
			if line =~ ratio_pattern
				let newline = substitute(line, ratio_pattern, ratiostring, '')
			else
				let newline = line .. ' ' .. ratiostring
			endif
			call setline(linum, newline)
		else
			if line =~ ratio_pattern
				let newline = substitute(line, ratio_pattern, '', '')
				let newline = substitute(newline, '\m\s*$', '', '')
				call setline(linum, newline)
			endif
		endif
	endfor
	" ---- coda
	call setpos('.', position)
	return [linumlist, lastlinumlist, ratiodict]
endfun

fun! organ#bush#rebuild (properties = {}, mode = 'apply')
	" Rebuild item head from properties
	let properties = a:properties
	let mode = a:mode
	if empty(properties)
		let properties = organ#colibri#properties ()
	endif
	" ---- properties
	let linum = properties.linum
	let indent = properties.indent
	let prefix = copy(properties.prefix)
	let counterstartstring = copy(properties.counterstartstring)
	let checkboxstring = copy(properties.checkboxstring)
	let todo = copy(properties.todo)
	let text = copy(properties.text)
	let ratiostring = copy(properties.ratiostring)
	" ---- add spaces
	let prefix ..= ' '
	if ! empty(counterstartstring)
		let counterstartstring ..= ' '
	endif
	if ! empty(checkboxstring)
		let checkboxstring ..= ' '
	endif
	if ! empty(todo)
		let todo ..= ' '
	endif
	if ! empty(text)
		let text ..= ' '
	endif
	" ---- line
	let line = indent .. prefix .. counterstartstring .. checkboxstring .. todo .. text .. ratiostring
	" ---- apply
	if mode ==# 'apply'
		call setline(linum, line)
	endif
	return line
endfun

" ---- new list item

fun! organ#bush#new (mode = 'normal')
	" New list item
	call organ#origami#suspend ()
	let mode = a:mode
	" ---- properties
	let properties = organ#colibri#properties ()
	let indent = properties.indent
	let prefix = copy(properties.prefix)
	" ---- add spaces
	let prefix ..= ' '
	" ---- prefix
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
	call organ#origami#resume ()
endfun

fun! organ#bush#new_with_check ()
	" New list item with check box
	call organ#origami#suspend ()
	" ---- properties
	let properties = organ#colibri#properties ()
	let indent = properties.indent
	let prefix = copy(properties.prefix)
	" ---- add spaces
	let prefix ..= ' '
	" ---- prefix
	let line = indent .. prefix .. '[ ] '
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
		let linum = organ#colibri#parent ('move', 'dont-wrap')
		let subtree = organ#colibri#subtree ()
		let first = subtree.head_linum
		let last = subtree.tail_linum
		call setpos('.', position)
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
	echomsg first last newprefix
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
	let checkbox = copy(properties.checkbox)
	" ---- toggle checkbox
	if checkbox == -1
		let checkbox = 0
		let checkboxstring = '[ ]'
	elseif checkbox == 0
		let checkbox = 1
		let checkboxstring = '[X]'
	elseif checkbox == 1
		let checkbox = 0
		let checkboxstring = '[ ]'
	endif
	let properties.checkbox = checkbox
	let properties.checkboxstring = checkboxstring
	let line = organ#bush#rebuild(properties)
	call organ#bush#update_ratios ()
	return line
endfun

" ---- todo

fun! organ#bush#cycle_todo (direction = 1)
	" Cycle todo keyword marker following direction
	" direction : 1 = right = next, -1 = left = previous
	let direction = a:direction
	let properties = organ#colibri#properties ()
	let todo = copy(properties.todo)
	let newtodo = organ#bush#rotate_todo (direction, properties)
	let properties.todo = newtodo
	return organ#bush#rebuild(properties)
endfun

" ---- promote & demote

" -- current only

fun! organ#bush#promote (context = 'alone')
	" Promote list item
	let context = a:context
	if context ==# 'alone'
		call organ#origami#suspend ()
	endif
	let properties = organ#colibri#properties ()
	let linum = properties.linum
	let level = properties.level
	" ---  do nothing if top level
	if level == 1
		echomsg 'organ bush promote : already at top level'
		return 0
	endif
	" ---- is cursor at end of line ?
	let is_cursor_at_eol = col('.') == col('$')
	" ---  adjust indent
	let properties.itemhead = organ#bush#indent_item (level - 1, properties)
	let properties.level -= 1
	" ---- update prefix
	call organ#bush#update_prefix (-1, properties)
	" ---- update counters
	if context ==# 'alone'
		call organ#bush#update_counters ()
		call organ#bush#update_ratios ()
		if col('.') > 1
			let step = g:organ_config.list.indent_length
			if ! is_cursor_at_eol
				call cursor('.', col('.') - step)
			endif
		endif
		call organ#origami#resume ()
	endif
	" ---- coda
	return linum
endfun

fun! organ#bush#demote (context = 'alone')
	" Demote list item
	let context = a:context
	if context ==# 'alone'
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
	if context ==# 'alone'
		call organ#bush#update_counters ()
		call organ#bush#update_ratios ()
		if col('.') > 1
			let step = g:organ_config.list.indent_length
			call cursor('.', col('.') + step)
		endif
		call organ#origami#resume ()
	endif
	" ---- coda
	return linum
endfun

" -- subtree

fun! organ#bush#promote_subtree ()
	" Promote list item subtree
	call organ#origami#suspend ()
	let position = getcurpos ()
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
	call organ#bush#update_ratios ()
	call setpos('.', position)
	if col('.') > 1
		let step = g:organ_config.list.indent_length
		call cursor('.', col('.') - step)
	endif
	call organ#origami#resume ()
	return linum
endfun

fun! organ#bush#demote_subtree ()
	" Demote list item subtree
	call organ#origami#suspend ()
	let position = getcurpos ()
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
	call organ#bush#update_ratios ()
	call setpos('.', position)
	if col('.') > 1
		let step = g:organ_config.list.indent_length
		call cursor('.', col('.') + step)
	endif
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
