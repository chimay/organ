" vim: set ft=vim fdm=indent iskeyword&:

" Monkey
"
" Navigation on orgmode or markdown lists hierarchy

" ---- script constants

if ! exists('s:list_pattern')
	let s:list_pattern = organ#crystal#fetch('list/pattern')
	lockvar s:list_pattern
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

fun! organ#monkey#level ()
	" Level of current list item
	let line = getline('.')
	if line !~ s:list_pattern
		echomsg 'organ monkey level : not on a list item list'
		return -1
	endif
	let spaces = repeat(' ', &tabstop)
	let line = substitute(line, '	', spaces, 'g')
	let indent = line->matchstr('^\s*')
	let indnum = len(indent)
	let level = indnum / s:indent_length + 1
	return level
endfun

fun! organ#monkey#properties ()
	" Properties of current list item
	let linum = line('.')
	let itemline = getline('.')
	let level = organ#monkey#level ()
	let pattern = s:list_pattern
	let content = substitute(itemline, pattern, '', '')
	let properties = #{
				\ linum : linum,
				\ itemline : itemline,
				\ level : level,
				\ content : content
				\}
	return properties
endfun

fun! organ#monkey#subtree ()
	" Range & properties of current list subtree
	let properties = organ#monkey#properties ()
	let subtree = #{
				\ head_linum : properties.linum,
				\ itemline : properties.itemline,
				\ level : properties.level,
				\ content : properties.content,
				\ tail_linum : tail_linum,
				\}
	return subtree
endfun
