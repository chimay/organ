" vim: set ft=vim fdm=indent iskeyword&:

" Tree
"
" Operations on orgmode or markdown headings hierarchy

" ---- script constants

if exists('s:hollow_pattern')
	unlockvar s:hollow_pattern
endif
let s:hollow_pattern = organ#crystal#fetch('pattern/line/hollow')
lockvar s:hollow_pattern

if exists('s:rep_one_char')
	unlockvar s:rep_one_char
endif
let s:rep_one_char = organ#crystal#fetch('filetypes/repeated_one_char_heading')
lockvar s:rep_one_char

if exists('s:field_separ')
	unlockvar s:field_separ
endif
let s:field_separ = organ#crystal#fetch('separator/field')
lockvar s:field_separ

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
	let subtree = organ#bird#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	if head_linum == 0
		echomsg 'organ tree promote heading : headline not found'
		return 0
	endif
	if subtree.level == 1
		echomsg 'organ tree promote heading : already at top level'
		return 0
	endif
	let headline = subtree.headline
	if s:rep_one_char->index(&filetype) >= 0
		let headline = headline[1:]
	elseif &foldmethod ==# 'marker'
		let markerlist = split(&foldmarker, ',')
		let marker = markerlist[0]
		let endmarker = markerlist[1]
		let level = organ#bird#foldlevel ()
		let old = marker .. level
		let new = marker .. string(level - 1)
		let headline = substitute(headline, old, new, '')
		let endmarker_pattern = organ#origami#endmarker_level_pattern (level, level)
		let endnum = 0
		if getline(tail_linum) =~ endmarker_pattern
			let endnum = tail_linum
		elseif tail_linum > 1 && getline(tail_linum - 1) =~ endmarker_pattern
			let endnum = tail_linum - 1
		endif
		let endline = getline(endnum)
		let old = endmarker .. level
		let new = endmarker .. string(level - 1)
		let endline = substitute(endline, old, new, '')
		call setline(endnum, endline)
	endif
	call setline(head_linum, headline)
	if context ==# 'alone'
		call setpos('.', position)
		if s:rep_one_char->index(&filetype) >= 0 && head_linum == line('.') && col('.') > 1
			call cursor('.', col('.') - 1)
		endif
	endif
	return head_linum
endfun

fun! organ#tree#demote (context = 'alone')
	" Demote heading
	let context = a:context
	let position = getcurpos ()
	let subtree = organ#bird#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	if head_linum == 0
		echomsg 'organ tree demote heading : headline not found'
		return 0
	endif
	let headline = subtree.headline
	let filetype = &filetype
	if s:rep_one_char->index(&filetype) >= 0
		let char = organ#bird#char ()
		let headline = char .. headline
	elseif &foldmethod ==# 'marker'
		let markerlist = split(&foldmarker, ',')
		let marker = markerlist[0]
		let endmarker = markerlist[1]
		let level = organ#bird#foldlevel ()
		let old = marker .. level
		let new = marker .. string(level + 1)
		let headline = substitute(headline, old, new, '')
		let endmarker_pattern = organ#origami#endmarker_level_pattern (level, level)
		let endnum = 0
		if getline(tail_linum) =~ endmarker_pattern
			let endnum = tail_linum
		elseif tail_linum > 1 && getline(tail_linum - 1) =~ endmarker_pattern
			let endnum = tail_linum - 1
		endif
		let endline = getline(endnum)
		let old = endmarker .. level
		let new = endmarker .. string(level + 1)
		let endline = substitute(endline, old, new, '')
		call setline(endnum, endline)
	endif
	call setline(head_linum, headline)
	if context ==# 'alone'
		call setpos('.', position)
		if s:rep_one_char->index(&filetype) >= 0 && head_linum == line('.') && col('.') > 1
			call cursor('.', col('.') + 1)
		endif
		normal! zv
	endif
	return head_linum
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
	let depth = cursor_linum - head_linum
	let level = subtree.level
	let last_linum = line('$')
	" ---- find same level targets candidates
	let same_pattern = organ#bird#level_pattern (level, level)
	let flags = organ#utils#search_flags ('backward', 'dont-move', 'wrap')
	let same_linum = search(same_pattern, flags)
	" ---- find upper level targets candidates
	if level >= 2
		let upper_level = level - 1
		let upper_pattern = organ#bird#level_pattern (upper_level, upper_level)
		" -- two times
		" -- first to find the current parent
		" -- second to find the previous parent
		let middle_linum = search(upper_pattern, flags)
		call cursor(middle_linum, 1)
		let upper_linum = search(upper_pattern, flags)
		"call cursor(cursor_linum, 1)
	else
		let middle_linum = 0
		let upper_linum = 0
	endif
	" ---- nearest candidate
	let nearest = organ#bird#nearest (cursor_linum, same_linum, upper_linum, -1)
	if nearest == 0
		" both linum == 0
		echomsg 'organ tree move subtree backward : not found'
		return 0
	endif
	if nearest == cursor_linum
		echomsg 'organ tree move subtree backward : nothing to do'
		return 0
	endif
	" ---- plain backward or wrapped forward ?
	let backward = nearest < cursor_linum
	" ---- same or upper level ?
	if same_linum == nearest
		" -- same_linum == nearest
		if same_linum == organ#bird#nearest(cursor_linum, same_linum, middle_linum, -1)
			" no upper level between
			let target = same_linum - 1
		else
			" upper level between
			call cursor(same_linum, 1)
			let same_subtree = organ#bird#subtree ()
			let target = same_subtree.tail_linum
		endif
	else
		" -- upper_linum == nearest
		call cursor(upper_linum, 1)
		let upper_subtree = organ#bird#subtree ()
		let target = upper_subtree.tail_linum
	endif
	" ---- forward level 1
	if ! backward && level == 1
		let target = last_linum
	endif
	" ---- endmarker case
	if level > 1 && organ#origami#is_marker_headline_file ()
		let endmarker_pattern = organ#origami#endmarker_level_pattern (upper_level, upper_level)
		let target_line = getline(target)
		if target_line =~ endmarker_pattern
			let target -= 1
		elseif target > 1
			let prev_target_line = getline(target - 1)
			if prev_target_line =~ endmarker_pattern
				let target -= 2
			endif
		endif
	endif
	" ---- new head, cursor
	if backward
		let new_headnum = target + 1
	else
		let new_headnum = target - spread
	endif
	let cursor_target = new_headnum + depth
	" ---- move subtree
	let range = head_linum .. ',' .. tail_linum
	execute range .. 'move' target
	" ---- check blank lines
	let before_head = new_headnum - 1
	if before_head > 0 && getline(before_head) =~ '\m\S'
		call append(before_head, '')
		let cursor_target += 1
	endif
	let new_tail = new_headnum + spread
	if getline(new_tail) =~ '\m^\S'
		call append(new_tail, '')
	endif
	if getline('$') ==# ''
		call organ#utils#delete ('$')
	endif
	" --- move cursor to the new heading place
	call cursor(cursor_target, 1)
	normal! zv
	call organ#spiral#cursor ()
	return new_headnum
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
	let nearest = organ#bird#nearest (cursor_linum, same_linum, upper_linum, 1)
	if nearest == 0
		" both linum == 0
		echomsg 'organ tree move subtree forward : not found'
		return 0
	endif
	if nearest == cursor_linum
		echomsg 'organ tree move subtree forward : nothing to do'
		return 0
	endif
	" ---- same or upper level ?
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
	" ---- plain forward or wrapped backward ?
	let forward = nearest > cursor_linum
	if ! forward
		if level == 1
			call cursor(1, 1)
			let headline_pattern = organ#bird#generic_pattern ()
			let flags = organ#utils#search_flags ('forward', 'dont-move', 'dont-wrap')
			let anyhead_forward = search(headline_pattern, flags)
			if anyhead_forward > 0
				let target = anyhead_forward - 1
			else
				let target = line('$')
			endif
		endif
		let cursor_target = target + 1
	endif
	" ---- endmarker case
	if level > 1 && organ#origami#is_marker_headline_file ()
		let endmarker_pattern = organ#origami#endmarker_level_pattern (upper_level, upper_level)
		let target_line = getline(target)
		if target > 1
			let prev_target_line = getline(target - 1)
		endif
		if target_line =~ endmarker_pattern
			let delta = 1
			let target -= delta
			let cursor_target -= delta
		elseif target > 1 && prev_target_line =~ endmarker_pattern
			let delta = 2
			let target -= delta
			let cursor_target -= delta
		endif
	endif
	" ---- move subtree
	let range = head_linum .. ',' .. tail_linum
	execute range .. 'move' target
	echomsg range .. 'move' target
	" ---- check blank lines
	let before_head = cursor_target - 1
	if before_head > 0 && getline(before_head) =~ '\m\S'
		call append(before_head, '')
		let cursor_target += 1
	endif
	let new_tail = cursor_target + spread
	if getline(new_tail) =~ '\m^\S'
		call append(new_tail, '')
	endif
	if getline('$') ==# ''
		call organ#utils#delete ('$')
	endif
	" --- move cursor to the new heading place
	call cursor(cursor_target, 1)
	normal! zv
	call organ#spiral#cursor ()
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
	let level = subtree.level
	let upper_level = level - 1
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
	" ---- endmarker case
	if level > 1 && organ#origami#is_marker_headline_file ()
		let endmarker_pattern = organ#origami#endmarker_level_pattern (upper_level, upper_level)
		let target_line = getline(target)
		if target > 1
			let prev_target_line = getline(target - 1)
		endif
		if target_line =~ endmarker_pattern
			let target -= 1
		elseif target > 1 && prev_target_line =~ endmarker_pattern
			let target -= 2
		endif
	endif
	" ---- move
	execute range .. 'move' target
	if target < head_linum
		call cursor(target + 1, 1)
	else
		let spread = tail_linum - head_linum
		let new_place = target - spread
		call cursor(new_place, 1)
	endif
	normal! zv
	call organ#spiral#cursor ()
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
