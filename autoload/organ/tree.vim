" vim: set ft=vim fdm=indent iskeyword&:

" Tree
"
" Operations on orgmode or markdown headings hierarchy

" ---- script constants

if ! exists('s:rep_one_char')
	let s:rep_one_char = organ#crystal#fetch('filetypes/repeated_one_char_heading')
	lockvar s:rep_one_char
endif

if ! exists('s:field_separ')
	let s:field_separ = organ#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" ---- helpers

fun! organ#tree#rotate_todo (direction = 1, ...)
	" Return next/previous todo keywoard
	" direction : 1 = right = next, -1 = left = previous
	let direction = a:direction
	if a:0 > 0
		let properties = a:1
	else
		let properties = organ#bird#properties ()
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

fun! organ#tree#rebuild (properties = {}, mode = 'apply')
	" Rebuild headline from properties
	let properties = a:properties
	let mode = a:mode
	if empty(properties)
		let properties = organ#bird#properties ()
	endif
	" ---- properties
	let linum = properties.linum
	let levelstring = copy(properties.levelstring)
	let title = copy(properties.title)
	let todo = copy(properties.todo)
	let tagstring = copy(properties.tagstring)
	let commentstrings = copy(properties.commentstrings)
	let lencomlist = len(commentstrings)
	" ---- add spaces
	if s:rep_one_char->index(&filetype) >= 0
		let levelstring ..= ' '
	else
		let title ..= ' '
	endif
	if ! empty(todo)
		let todo ..= ' '
	endif
	if lencomlist >= 1
		let commentstrings[0] ..= ' '
	endif
	if lencomlist >= 2
		let commentstrings[1] = ' ' .. commentstrings[1]
	endif
	" ---- padding for tags
	let padding = ''
	if ! empty(tagstring)
		let length = len(levelstring) + len(todo) + len(title) + len(tagstring)
		" -- 72 = roughly standard long line size
		let padlen = max([72 - length, 1])
		let padding = repeat(' ', padlen)
	endif
	" ---- core
	if s:rep_one_char->index(&filetype) >= 0
		let line = levelstring .. todo .. title .. padding .. tagstring
	else
		let line = todo .. title .. levelstring .. padding .. tagstring
	endif
	" ---- commentstrings
	if s:rep_one_char->index(&filetype) < 0 && ! empty(commentstrings)
		if lencomlist >= 1
			let line = commentstrings[0] .. line
		endif
		if lencomlist >= 2
			let line = line .. commentstrings[1]
		endif
	endif
	" ---- apply
	if mode ==# 'apply'
		call setline(linum, line)
	endif
	return line
endfun

" ---- new heading

fun! organ#tree#new ()
	" New heading
	let properties = organ#bird#properties ()
	let levelstring = copy(properties.levelstring)
	let level = properties.level
	let commentstrings = copy(properties.commentstrings)
	let lencomlist = len(commentstrings)
	" ---- add spaces
	if lencomlist >= 1
		let commentstrings[0] ..= ' '
	endif
	if lencomlist >= 2
		let commentstrings[1] = ' ' .. commentstrings[1]
	endif
	" ---- new heading line
	if s:rep_one_char->index(&filetype) >= 0
		let line = levelstring .. ' '
	else
		let line = ' ' .. levelstring
	endif
	" -- commentstring
	if s:rep_one_char->index(&filetype) < 0 && ! empty(commentstrings)
		if lencomlist >= 1
			let line = commentstrings[0] .. line
		endif
		if lencomlist >= 2
			let line = line .. commentstrings[1]
		endif
	endif
	" ---- append
	let linelist = [line, '']
	call append('.', linelist)
	let linum = line('.') + 1
	call cursor(linum, 1)
	if s:rep_one_char->index(&filetype) >= 0
		"call cursor('.', col('$'))
		startinsert!
	else
		if lencomlist == 0
			call cursor('.', 1)
		else
			let lencomstr = len(commentstrings[0])
			call cursor('.', 1 + lencomstr)
		endif
		startinsert
	endif
endfun

" ---- select, yank, delete

fun! organ#tree#select_subtree ()
	" Visually select subtree
	let subtree = organ#bird#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	call cursor(head_linum, 1)
	normal! V
	call cursor(tail_linum, 1)
	normal! o
	return subtree
endfun

fun! organ#tree#yank_subtree ()
	" Visually yank subtree
	let subtree = organ#bird#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	let range = head_linum .. ',' .. tail_linum
	execute range .. 'yank "'
	return subtree
endfun

fun! organ#tree#delete_subtree ()
	" Visually delete subtree
	let subtree = organ#bird#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	let range = head_linum .. ',' .. tail_linum
	execute range .. 'yank "'
	call organ#utils#delete (head_linum, tail_linum)
	return subtree
endfun

" ---- promote & demote

" -- current heading only

fun! organ#tree#promote (context = 'alone')
	" Promote heading
	let context = a:context
	let position = getcurpos ()
	let properties = organ#bird#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ tree promote heading : headline not found'
		return 0
	endif
	if properties.level == 1
		echomsg 'organ tree promote heading : already at top level'
		return 0
	endif
	let headline = properties.headline
	if s:rep_one_char->index(&filetype) >= 0
		let headline = headline[1:]
	elseif &foldmethod ==# 'marker'
		let marker = split(&foldmarker, ',')[0]
		let level = organ#bird#foldlevel ()
		let old = marker .. level
		let new = marker .. string(level - 1)
		let headline = substitute(headline, old, new, '')
	endif
	call setline(linum, headline)
	if context ==# 'alone'
		call setpos('.', position)
		if s:rep_one_char->index(&filetype) >= 0 && linum == line('.') && col('.') > 1
			call cursor('.', col('.') - 1)
		endif
	endif
	return linum
endfun

fun! organ#tree#demote (context = 'alone')
	" Demote heading
	let context = a:context
	let position = getcurpos ()
	let properties = organ#bird#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ tree demote heading : headline not found'
		return 0
	endif
	let headline = properties.headline
	let filetype = &filetype
	if s:rep_one_char->index(&filetype) >= 0
		let char = organ#bird#char ()
		let headline = char .. headline
	elseif &foldmethod ==# 'marker'
		let marker = split(&foldmarker, ',')[0]
		let level = organ#bird#foldlevel ()
		let old = marker .. level
		let new = marker .. string(level + 1)
		let headline = substitute(headline, old, new, '')
	endif
	call setline(linum, headline)
	if context ==# 'alone'
		call setpos('.', position)
		if s:rep_one_char->index(&filetype) >= 0 && linum == line('.') && col('.') > 1
			call cursor('.', col('.') + 1)
		endif
		normal! zv
	endif
	return linum
endfun

" -- subtree

fun! organ#tree#promote_subtree ()
	" Promote subtree
	if organ#stair#is_indent_headline_file ()
		call organ#tree#select_subtree ()
		normal! <
		return line('.')
	endif
	let position = getcurpos ()
	let subtree = organ#bird#subtree ()
	let head_linum = subtree.head_linum
	if head_linum == 0
		echomsg 'organ tree promote subtree : headline not found'
		return 0
	endif
	let level = subtree.level
	if level == 1
		echomsg 'organ tree promote subtree : already at top level'
		return 0
	endif
	let tail_linum = subtree.tail_linum
	while v:true
		let linum = organ#tree#promote ('batch')
		let linum = organ#bird#next ('move', 'dont-wrap')
		if linum >= tail_linum || linum == 0
			break
		endif
	endwhile
	call setpos('.', position)
	if s:rep_one_char->index(&filetype) >= 0 && head_linum == line('.') && col('.') > 1
		call cursor('.', col('.') - 1)
	endif
	return linum
endfun

fun! organ#tree#demote_subtree ()
	" Demote subtree
	if organ#stair#is_indent_headline_file ()
		call organ#tree#select_subtree ()
		normal! >
		return line('.')
	endif
	let position = getcurpos ()
	let subtree = organ#bird#subtree ()
	let head_linum = subtree.head_linum
	if head_linum == 0
		echomsg 'organ tree demote subtree : headline not found'
		return 0
	endif
	let tail_linum = subtree.tail_linum
	while v:true
		let linum = organ#tree#demote ('batch')
		let linum = organ#bird#next ('move', 'dont-wrap')
		if linum >= tail_linum || linum == 0
			break
		endif
	endwhile
	call setpos('.', position)
	if s:rep_one_char->index(&filetype) >= 0 && head_linum == line('.') && col('.') > 1
		call cursor('.', col('.') + 1)
	endif
	return linum
endfun

" ---- move

fun! organ#tree#move_subtree_backward ()
	" Move subtree backward
	call cursor('.', 1)
	let cursor_linum = line('.')
	let subtree = organ#bird#subtree ('move')
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	let spread = tail_linum - head_linum
	let level = subtree.level
	let last_linum = line('$')
	" ---- find same level and upper level targets candidates
	let same_pattern = organ#bird#level_pattern (level, level)
	let flags = organ#utils#search_flags ('backward', 'dont-move', 'wrap')
	let same_linum = search(same_pattern, flags)
	if level >= 2
		let upper_level = level - 1
		let upper_pattern = organ#bird#level_pattern (upper_level, upper_level)
		let upper_linum = search(upper_pattern, flags)
	else
		let upper_linum = 0
	endif
	" ---- nearest candidate
	let nearest = organ#bird#nearest (same_linum, upper_linum, -1)
	if nearest == 0
		" both linum == 0
		echomsg 'organ tree move subtree backward : not found'
		return 0
	endif
	if nearest == cursor_linum
		echomsg 'organ tree move subtree backward : nothing to do'
		return 0
	endif
	" ---- plain backward or wrapped backward ?
	" ---- if plain backward, same or upper level ?
	let backward = nearest < cursor_linum
	if backward
		if same_linum == nearest
			let cursor_target = same_linum
			let target = cursor_target - 1
		else
			" upper_linum == nearest
			let cursor_target = upper_linum
			let target = cursor_target - 1
		endif
	else
		if getline(last_linum) != ''
			call append(last_linum, '')
			let last_linum += 1
		endif
		let target = last_linum
		let cursor_target = target - spread
	endif
	" ---- move subtree
	let range = head_linum .. ',' .. tail_linum
	execute range .. 'move' target
	" ---- check blank lines
	let before_head = cursor_target - 1
	if before_head > 0 && getline(before_head) =~ '\m\S'
		call append(before_head, '')
		let cursor_target += 1
	endif
	let new_tail = cursor_target + spread
	let after_tail = new_tail + 1
	if after_tail <= last_linum && getline(new_tail) =~ '\m^\S' && getline(after_tail) =~ '\m^\S'
		call append(new_tail, '')
	endif
	if getline('$') ==# ''
		call organ#utils#delete ('$')
	endif
	" --- move cursor to the new heading place
	call cursor(cursor_target, 1)
	return cursor_target
endfun

fun! organ#tree#move_subtree_forward ()
	" Move subtree forward
	call cursor('.', col('$'))
	let cursor_linum = line('.')
	let subtree = organ#bird#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	let spread = tail_linum - head_linum
	let level = subtree.level
	let last_linum = line('$')
	" ---- find same level targets candidates
	let same_pattern = organ#bird#level_pattern (level, level)
	let flags = organ#utils#search_flags ('forward', 'dont-move', 'wrap')
	let same_linum = search(same_pattern, flags)
	" ---- find upper level targets candidates
	if level >= 2
		let upper_level = level - 1
		let upper_pattern = organ#bird#level_pattern (upper_level, upper_level)
		let upper_linum = search(upper_pattern, flags)
	else
		let upper_linum = 0
	endif
	" ---- nearest candidate
	let nearest = organ#bird#nearest (same_linum, upper_linum, 1)
	if nearest == 0
		" both linum == 0
		echomsg 'organ tree move subtree forward : not found'
		return 0
	endif
	if nearest == cursor_linum
		echomsg 'organ tree move subtree forward : nothing to do'
		return 0
	endif
	" ---- plain forward or wrapped forward ?
	" ---- if plain forward, same or upper level ?
	let forward = nearest > cursor_linum
	if forward
		if same_linum == nearest
			" -- same_linum == nearest
			call cursor(same_linum, 1)
			let same_subtree = organ#bird#subtree ()
			let target = same_subtree.tail_linum
			let cursor_target = target - spread
		else
			" -- upper_linum == nearest
			call cursor(upper_linum, 1)
			call cursor('.', col('$'))
			let headline_pattern = organ#bird#generic_pattern ()
			let flags = organ#utils#search_flags ('forward', 'dont-move', 'dont-wrap')
			let anyhead_forward = search(headline_pattern, flags)
			if anyhead_forward > 0
				let target = anyhead_forward - 1
			else
				let target = line('$')
			endif
			let cursor_target = target - spread
		endif
	else
		if getline(last_linum) != ''
			call append(last_linum, '')
			let tail_linum += 1
		endif
		call cursor(1, 1)
		let headline_pattern = organ#bird#generic_pattern ()
		let cursor_target = search(headline_pattern, flags)
		let target = cursor_target - 1
	endif
	" ---- move subtree
	let range = head_linum .. ',' .. tail_linum
	execute range .. 'move' target
	" ---- check blank lines
	let before_head = cursor_target - 1
	if before_head > 0 && getline(before_head) =~ '\m\S'
		call append(before_head, '')
		let cursor_target += 1
	endif
	let new_tail = cursor_target + spread
	let after_tail = new_tail + 1
	if after_tail <= last_linum && getline(new_tail) =~ '\m^\S' && getline(after_tail) =~ '\m^\S'
		call append(new_tail, '')
	endif
	if getline('$') ==# ''
		call organ#utils#delete ('$')
	endif
	" --- move cursor to the new heading place
	call cursor(cursor_target, 1)
	return cursor_target
endfun

" ---- move to another subtree path, aka org-refile

fun! organ#tree#moveto ()
	" Move current subtree to another one
	" ---- range of current subtree
	let subtree = organ#bird#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	let range = head_linum .. ',' .. tail_linum
	" ---- find target subtree
	let prompt = 'Move current subtree to : '
	let complete = 'customlist,organ#complete#headline_same_level_or_parent'
	let record = input(prompt, '', complete)
	if empty(record)
		return -1
	endif
	let fields = split(record, s:field_separ)
	let linum = str2nr(fields[0])
	call cursor(linum, 1)
	let subtree = organ#bird#subtree ()
	let target = subtree.tail_linum
	" ---- move
	execute range .. 'move' target
	if target < head_linum
		call cursor(target + 1, 1)
	else
		let spread = tail_linum - head_linum
		let new_place = target - spread
		call cursor(new_place, 1)
	endif
	return target
endfun

" ---- tags

fun! organ#tree#tag ()
	" Toggle tag
	let properties = organ#bird#properties ()
	let taglist = properties.tags
	" ---- ask user the tag to toggle
	let prompt = 'Toggle headline tag : '
	let complete = 'customlist,organ#complete#tag'
	let tag = input(prompt, '', complete)
	" ---- remove surrounding colons if needed
	if tag[0] ==# ':'
		let tag = tag[1:]
	endif
	" -- needs the colon for compatibilty
	if tag[-1:] ==# ':'
		let tag = tag[:-2]
	endif
	if empty(tag)
		return properties.headline
	endif
	" ---- tag list
	let index = taglist->index(tag)
	if index < 0
		eval taglist->add(tag)
	else
		eval taglist->remove(index)
	endif
	if empty(taglist)
		let tagstring = ''
	else
		let tagstring = ':' .. taglist->join(':') .. ':'
	endif
	let properties.tags = taglist
	let properties.tagstring = tagstring
	return organ#tree#rebuild(properties)
endfun

" ---- todo

fun! organ#tree#cycle_todo (direction = 1)
	" Cycle todo keyword marker following direction
	" direction : 1 = right = next, -1 = left = previous
	let direction = a:direction
	let properties = organ#bird#properties ()
	let newtodo = organ#tree#rotate_todo (direction, properties)
	let properties.todo = newtodo
	return organ#tree#rebuild(properties)
endfun

" ---- convert org <-> markdown

fun! organ#tree#org2markdown ()
	" Convert org headlines to markdown
	let pre = '^\*\{'
	let post = '}\zs\*'
	for level in reverse(range(1, 30))
		let pattern = pre .. level .. post
		let runme = 'silent! %substitute/' .. pattern .. '/#/g'
		let output = execute(runme)
	endfor
	silent! %substitute/^\*/#/g
endfun

fun! organ#tree#markdown2org ()
	" Convert markdown headlines to org
	let pre = '^#\{'
	let post = '}\zs#'
	for level in reverse(range(1, 30))
		let pattern = pre .. level .. post
		let runme = 'silent! %substitute/' .. pattern .. '/*/g'
		let output = execute(runme)
	endfor
	silent! %substitute/^#/*/g
endfun
