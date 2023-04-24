" vim: set ft=vim fdm=indent iskeyword&:

" Colibri
"
" Navigation on orgmode or markdown lists hierarchy

" ---- script constants

if ! exists('s:itemhead_pattern_org')
	let s:itemhead_pattern_org = organ#crystal#fetch('list/itemhead/pattern/org')
	lockvar s:itemhead_pattern_org
endif

if ! exists('s:itemhead_pattern_markdown')
	let s:itemhead_pattern_markdown = organ#crystal#fetch('list/itemhead/pattern/markdown')
	lockvar s:itemhead_pattern_markdown
endif

if ! exists('s:indent')
	let s:indent = organ#crystal#fetch('list/indent')
	lockvar s:indent
endif

if ! exists('s:indent_length')
	let s:indent_length = organ#crystal#fetch('list/indent/length')
	lockvar s:indent_length
endif

" ---- helpers

fun! organ#colibri#generic_pattern ()
	" Generic pattern of item head line
	if &filetype == 'org'
		return s:itemhead_pattern_org
	elseif &filetype == 'markdown'
		return s:itemhead_pattern_markdown
	else
		echomsg 'organ colibri generic pattern : filetype not supported'
	endif
endfun

fun! organ#colibri#itemhead_pattern (minlevel = 1, maxlevel = 100, indent = 0)
	" Item head pattern of level between minlevel and maxlevel
	" All list is indented with indent * s:indent_length
	let minlevel = a:minlevel + a:indent
	let maxlevel = a:maxlevel + a:indent
	let min = minlevel - 1
	let max = maxlevel - 1
	if min == 0 && &filetype == 'org'
		let pattern = '^\%(\%(' .. s:indent .. '\)\{' .. min .. ',' .. max .. '\}'
		let pattern ..= '\%([-+*]\|[0-9]\+[.)]\)\)\|'
		let pattern ..= '\%(^[-+]\|^[0-9]\+[.)]\)'
		return pattern
	endif
	let pattern = '^\%(' .. s:indent .. '\)\{' .. min .. ',' .. max .. '\}'
	if &filetype == 'org'
		let pattern ..= '\%([-+*]\|[0-9]\+[.)]\)'
	elseif &filetype == 'markdown'
		let pattern ..= '\%([-+*]\|[0-9]\+[.]\)'
	endif
	return pattern
endfun

fun! organ#colibri#is_on_itemhead ()
	" Whether current line is a item head
	let line = getline('.')
	return line =~ organ#colibri#generic_pattern ()
endfun

fun! organ#colibri#is_in_list ()
	" Whether current line is in a list
	let linum = line('.')
	let line = getline(linum)
	let itemhead_pattern = organ#colibri#generic_pattern ()
	if line =~ itemhead_pattern
		return v:true
	endif
	if line =~ '^\s*$'
		if linum == line('$')
			return v:false
		endif
		let next = getline(linum + 1)
		if next !~ s:itemhead_pattern
			return v:false
		endif
	endif
endfun

fun! organ#colibri#itemhead (move = 'dont-move')
	" Head of current list item
	let move = a:move
	let itemhead_pattern = organ#colibri#generic_pattern ()
	let flags = organ#utils#search_flags ('backward', move, 'dont-wrap')
	let flags ..= 'c'
	return search(itemhead_pattern, flags)
endfun

fun! organ#colibri#level ()
	" Level of current list item
	let itemhead = getline('.')
	let itemhead_pattern = organ#colibri#generic_pattern ()
	if itemhead !~ itemhead_pattern
		echomsg 'organ colibri level : not on a list line'
		return -1
	endif
	let spaces = repeat(' ', &tabstop)
	let itemhead = substitute(itemhead, '	', spaces, 'g')
	let indent = itemhead->matchstr('^\s*')
	let indnum = len(indent)
	let level = indnum / s:indent_length + 1
	return level
endfun

fun! organ#colibri#properties ()
	" Properties of current list item
	let itemhead = getline('.')
	let itemhead_pattern = organ#colibri#generic_pattern ()
	if itemhead !~ itemhead_pattern
		echomsg 'organ colibri level : not on a list line'
		return -1
	endif
	let linum = line('.')
	let level = organ#colibri#level ()
	let content = substitute(itemhead, itemhead_pattern, '', '')
	let properties = #{
				\ linum : linum,
				\ itemhead : itemhead,
				\ level : level,
				\ content : content
				\}
	return properties
endfun

fun! organ#colibri#subtree ()
	" Range & properties of current list subtree
	let properties = organ#colibri#properties ()
	let level = properties.level
	let pattern = '^' .. s:indent->repeat(level - 1)
	let pattern ..= '[-+*0-9]'
	let flags = organ#utils#search_flags ('forward', 'dont-move', 'dont-wrap')
	let forward_linum = search(pattern, flags)
	echomsg pattern forward_linum
	if forward_linum == 0
		let tail_linum = line('$')
	else
		let tail_linum = forward_linum - 1
	endif
	let subtree = #{
				\ head_linum : properties.linum,
				\ itemhead : properties.itemhead,
				\ level : properties.level,
				\ content : properties.content,
				\ tail_linum : tail_linum,
				\}
	return subtree
endfun
