" vim: set ft=vim fdm=indent iskeyword&:

" Tree
"
" Operations on orgmode or markdown headings hierarchy

" ---- promote & demote

" -- current heading only

fun! organ#tree#promote ()
	" Promote heading
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
	let headline = headline[1:]
	call setline(linum, headline)
	return linum
endfun

fun! organ#tree#demote ()
	" Demote heading
	let properties = organ#bird#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ tree demote heading : headline not found'
		return 0
	endif
	let headline = properties.headline
	let filetype = &filetype
	if filetype == 'org'
		let headline = '*' .. headline
	elseif filetype == 'markdown'
		let headline = '#' .. headline
	endif
	call setline(linum, headline)
	normal! zv
	return linum
endfun

" -- subtree

fun! organ#tree#promote_subtree ()
	" Promote subtree
	let section = organ#bird#section ()
	let head_linum = section.head_linum
	if head_linum == 0
		echomsg 'organ tree promote subtree : headline not found'
		return 0
	endif
	let level = section.level
	if level == 1
		echomsg 'organ tree promote subtree : already at top level'
		return 0
	endif
	let tail_linum = section.tail_linum
	while v:true
		let linum = organ#tree#promote ()
		let linum = organ#bird#next ('move', 'dont-wrap')
		if linum >= tail_linum || linum == 0
			call cursor(head_linum, 1)
			return linum
		endif
	endwhile
endfun

fun! organ#tree#demote_subtree ()
	" Demote subtree
	let section = organ#bird#section ()
	let head_linum = section.head_linum
	if head_linum == 0
		echomsg 'organ tree demote subtree : headline not found'
		return 0
	endif
	let tail_linum = section.tail_linum
	while v:true
		let linum = organ#tree#demote ()
		let linum = organ#bird#next ('move', 'dont-wrap')
		if linum >= tail_linum || linum == 0
			call cursor(head_linum, 1)
			return linum
		endif
	endwhile
endfun

" ---- select, yank, delete

fun! organ#tree#select_subtree ()
	" Visually select subtree
	let section = organ#bird#section ()
	let head_linum = section.head_linum
	let tail_linum = section.tail_linum
	execute head_linum .. 'mark <'
	execute tail_linum .. 'mark >'
	normal! gv
	return section
endfun

fun! organ#tree#yank_subtree ()
	" Visually yank subtree
	let section = organ#bird#section ()
	let head_linum = section.head_linum
	let tail_linum = section.tail_linum
	let range = head_linum .. ',' .. tail_linum
	execute range .. 'yank "'
	return section
endfun

fun! organ#tree#delete_subtree ()
	" Visually delete subtree
	let section = organ#bird#section ()
	let head_linum = section.head_linum
	let tail_linum = section.tail_linum
	let range = head_linum .. ',' .. tail_linum
	execute range .. 'delete "'
	return section
endfun

" ---- move

fun! organ#tree#move_subtree_backward ()
	" Move subtree backward
	let section = organ#bird#section ('move')
	let head_linum = section.head_linum
	let tail_linum = section.tail_linum
	let range = head_linum .. ',' .. tail_linum
	let level = section.level
	let headline_pattern = organ#bird#headline_pattern (1, level)
	let flags = organ#bird#search_flags ('backward', 'dont-move', 'dont-wrap')
	let target = search(headline_pattern, flags) - 1
	execute range .. 'move' target
	call cursor(target + 1, 1)
	return target
endfun

fun! organ#tree#move_subtree_forward ()
	" Move subtree forward
	let section = organ#bird#section ()
	let head_linum = section.head_linum
	let tail_linum = section.tail_linum
	let range = head_linum .. ',' .. tail_linum
	let level = section.level
	if tail_linum == line('$')
		call cursor(tail_linum, 1)
	else
		call cursor(tail_linum + 1, 1)
	endif
	let forward_section = organ#bird#section ()
	let target = forward_section.tail_linum
	execute range .. 'move' target
	echomsg range .. 'move' target
	let spread = tail_linum - head_linum
	let new_place = target - spread
	call cursor(new_place, 1)
	return new_place
endfun
