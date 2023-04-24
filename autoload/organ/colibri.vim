" vim: set ft=vim fdm=indent iskeyword&:

" Colibri
"
" Navigation on orgmode or markdown lists hierarchy

" ---- script constants

if ! exists('s:itemhead_pattern')
	let s:itemhead_pattern = organ#crystal#fetch('list/itemhead/pattern')
	lockvar s:itemhead_pattern
endif

if ! exists('s:list_indent')
	let s:list_indent = organ#crystal#fetch('list/indent')
	lockvar s:list_indent
endif

if ! exists('s:indent_length')
	let s:indent_length = organ#crystal#fetch('list/indent/length')
	lockvar s:indent_length
endif

" ---- helpers

fun! organ#colibri#itemhead_pattern (indent = 0, minlevel = 1, maxlevel = 100)
	" Item head pattern of level between minlevel and maxlevel
	" All list is indented with indent * s:indent_length
	let minlevel = a:minlevel
	let maxlevel = a:maxlevel
	if &filetype == 'org'
		return '^\*\{' .. minlevel .. ',' .. maxlevel .. '\}' .. '[^*]'
	elseif &filetype == 'markdown'
		return '^#\{' .. minlevel .. ',' .. maxlevel .. '\}' .. '[^#]'
	endif
endfun

fun! organ#colibri#is_on_itemhead ()
	" Whether current line is a item head
	let headline_pattern = organ#bird#headline_pattern ()
	let line = getline('.')
	return line =~ headline_pattern
endfun

fun! organ#colibri#is_in_list ()
	" Whether current line is in a list
	let linum = line('.')
	let line = getline(linum)
	if line =~ s:itemhead_pattern
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

fun! organ#colibri#level ()
	" Level of current list item
	let itemhead = getline('.')
	if itemhead !~ s:itemhead_pattern
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
	if itemhead !~ s:itemhead_pattern
		echomsg 'organ colibri level : not on a list line'
		return -1
	endif
	let linum = line('.')
	let level = organ#colibri#level ()
	let pattern = s:itemhead_pattern
	let content = substitute(itemhead, pattern, '', '')
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
	let pattern = '^' .. s:list_indent->repeat(level - 1)
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
