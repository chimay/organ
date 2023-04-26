" vim: set ft=vim fdm=indent iskeyword&:

" Bird
"
" Navigation on orgmode or markdown headings hierarchy

" ---- script constants

if ! exists('s:level_separ')
	let s:level_separ = organ#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

if ! exists('s:field_separ')
	let s:field_separ = organ#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" ---- helpers

fun! organ#bird#char ()
	" Headline char
	if &filetype ==# 'org'
		return '*'
	elseif &filetype ==# 'markdown'
		return '#'
	endif
endfun

fun! organ#bird#generic_pattern ()
	if &filetype == 'org'
		return '\m^\*'
	elseif &filetype ==# 'markdown'
		return '\m^#'
	else
		echomsg 'organ bird generic pattern : filetype not supported'
	endif
endfun

fun! organ#bird#level_pattern (minlevel = 1, maxlevel = 100)
	" Headline pattern of level between minlevel and maxlevel
	let minlevel = a:minlevel
	let maxlevel = a:maxlevel
	if &filetype == 'org'
		return '\m^\*\{' .. minlevel .. ',' .. maxlevel .. '\}' .. '[^*]'
	elseif &filetype ==# 'markdown'
		return '\m^#\{' .. minlevel .. ',' .. maxlevel .. '\}' .. '[^#]'
	else
		echomsg 'organ bird headline pattern : filetype not supported'
	endif
endfun

fun! organ#bird#is_on_headline ()
	" Whether current line is an headline
	let line = getline('.')
	let headline_pattern = organ#bird#generic_pattern ()
	return line =~ headline_pattern
endfun

fun! organ#bird#headline (move = 'dont-move')
	" Headline of current subtree
	let move = a:move
	let headline_pattern = organ#bird#generic_pattern ()
	let flags = organ#utils#search_flags ('backward', move, 'dont-wrap')
	let flags ..= 'c'
	return search(headline_pattern, flags)
endfun

fun! organ#bird#properties (move = 'dont-move')
	" Properties of current headline
	let move = a:move
	let linum = organ#bird#headline (move)
	if linum == 0
		echomsg 'organ bird properties : headline not found'
		return #{ linum : 0, headline : '', level : 0, title : '' }
	endif
	let headline = getline(linum)
	if &filetype ==# 'org'
		let leading = headline->matchstr('\m^\*\+')
	elseif &filetype ==# 'markdown'
		let leading = headline->matchstr('\m^#\+')
	endif
	let level = len(leading)
	" -- assume a space before the title
	let title = headline[level + 1:]
	let properties = #{
				\ linum : linum,
				\ headline : headline,
				\ level : level,
				\ title : title,
				\}
	return properties
endfun

fun! organ#bird#subtree (move = 'dont-move')
	" Range & properties of current subtree
	let move = a:move
	let properties = organ#bird#properties (move)
	let head_linum = properties.linum
	if head_linum == 0
		echomsg 'organ bird subtree : headline not found'
		return #{ head_linum : 0, headline : '', level : 0, title : '', tail_linum : 0 }
	endif
	let level = properties.level
	let headline_pattern = organ#bird#level_pattern (1, level)
	let flags = organ#utils#search_flags ('forward', 'dont-move', 'dont-wrap')
	let forward_linum = search(headline_pattern, flags)
	if forward_linum == 0
		let tail_linum = line('$')
	else
		let tail_linum = forward_linum - 1
	endif
	if move == 'move'
		mark '
		call cursor(head_linum, 1)
	endif
	let headline = properties.headline
	let title = properties.title
	let subtree = #{
				\ head_linum : head_linum,
				\ headline : headline,
				\ level : level,
				\ title : title,
				\ tail_linum : tail_linum,
				\}
	return subtree
endfun

" ---- previous, next

fun! organ#bird#previous (move = 'move', wrap = 'wrap')
	" Previous heading
	let move = a:move
	let wrap = a:wrap
	let linum = line('.')
	call cursor(linum, 1)
	let line = getline('.')
	let headline_pattern = organ#bird#generic_pattern ()
	let flags = organ#utils#search_flags ('backward', move, wrap)
	let linum = search(headline_pattern, flags)
	if linum == 0
		echomsg 'organ bird previous : not found'
		return 0
	endif
	normal! zv
	return linum
endfun

fun! organ#bird#next (move = 'move', wrap = 'wrap')
	" Next heading
	let move = a:move
	let wrap = a:wrap
	let linum = line('.')
	let colnum = col('$')
	call cursor(linum, colnum)
	let line = getline('.')
	let headline_pattern = organ#bird#generic_pattern ()
	let flags = organ#utils#search_flags ('forward', move, wrap)
	let linum = search(headline_pattern, flags)
	if linum == 0
		echomsg 'organ bird next : not found'
		return 0
	endif
	normal! zv
	return linum
endfun

" ---- backward, forward

fun! organ#bird#backward (move = 'move', wrap = 'wrap')
	" Backward heading of same level
	let move = a:move
	let wrap = a:wrap
	let properties = organ#bird#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ bird backward : headline not found'
		return linum
	endif
	let level = properties.level
	let headline_pattern = organ#bird#level_pattern (level, level)
	let flags = organ#utils#search_flags ('backward', move, wrap)
	let linum = search(headline_pattern, flags)
	normal! zv
	return linum
endfun

fun! organ#bird#forward (move = 'move', wrap = 'wrap')
	" Forward heading of same level
	let move = a:move
	let wrap = a:wrap
	let properties = organ#bird#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ bird forward : headline not found'
		return linum
	endif
	let level = properties.level
	let headline_pattern = organ#bird#level_pattern (level, level)
	let flags = organ#utils#search_flags ('forward', move, wrap)
	let linum = search(headline_pattern, flags)
	normal! zv
	return linum
endfun

" ---- parent, child

fun! organ#bird#parent (move = 'move', wrap = 'wrap', ...)
	" Parent headline, ie first headline of level - 1, backward
	let move = a:move
	let wrap = a:wrap
	if a:0 > 0
		let properties = a:1
	else
		let properties = organ#bird#properties ()
	endif
	let linum = properties.linum
	if linum == 0
		echomsg 'organ bird parent : current headline not found'
		return linum
	endif
	let level = properties.level
	if level == 1
		echomsg 'organ bird parent : already at top level'
		return linum
	endif
	let level -= 1
	let headline_pattern = organ#bird#level_pattern (level, level)
	let flags = organ#utils#search_flags ('backward', move, wrap)
	let linum = search(headline_pattern, flags)
	if linum == 0
		echomsg 'organ bird parent : no parent found'
		return linum
	endif
	normal! zv
	return linum
endfun

fun! organ#bird#loose_child (move = 'move', wrap = 'wrap')
	" Child headline, or, more generally, first headline of level + 1, forward
	let move = a:move
	let wrap = a:wrap
	let properties = organ#bird#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ bird loose child : current headline not found'
		return linum
	endif
	let level = properties.level + 1
	let headline_pattern = organ#bird#level_pattern (level, level)
	let flags = organ#utils#search_flags ('forward', move, wrap)
	let linum = search(headline_pattern, flags)
	if linum == 0
		echomsg 'organ bird loose child : no child found'
		return linum
	endif
	normal! zv
	return linum
endfun

fun! organ#bird#strict_child (move = 'move', wrap = 'wrap')
	" First child subtree, strictly speaking
	let move = a:move
	let wrap = a:wrap
	let position = getcurpos ()
	" TODO
	let subtree = organ#bird#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	if head_linum == 0 || tail_linum == 0
		echomsg 'organ bird strict child : headline not found'
		return linum
	endif
	let level = subtree.level + 1
	let headline_pattern = organ#bird#level_pattern (level, level)
	let flags = organ#utils#search_flags ('forward', move, wrap)
	let linum = search(headline_pattern, flags)
	if linum == 0 || linum > tail_linum
		"echomsg 'organ bird strict child : no child found'
		call setpos('.', position)
		return 0
	endif
	normal! zv
	return linum
endfun

" ---- full path of subtree : chapter, section, subsection, and so on

fun! organ#bird#path (move = 'dont-move')
	" Full headings path of current subtree : part, chapter, ...
	let move = a:move
	let position = getcurpos ()
	let properties = organ#bird#properties ('move')
	let path = properties.title
	while v:true
		if properties.linum == 0
			if move != 'move'
				call setpos('.', position)
			endif
			return path
		endif
		if properties.level == 1
			if move != 'move'
				call setpos('.', position)
			endif
			return path
		endif
		call organ#bird#parent ('move', 'wrap', properties)
		let properties = organ#bird#properties ('move')
		let path = properties.title .. s:level_separ .. path
	endwhile
endfun

fun! organ#bird#whereami (move = 'dont-move')
	" Echo full subtree path
	let dashboard = 'organ: ' .. organ#bird#path (a:move)
	echomsg dashboard
endfun

" ---- goto

fun! organ#bird#goto_headline ()
	" Goto heading with completion
	let prompt = 'Goto headline : '
	let complete = 'customlist,organ#complete#headline'
	let record = input(prompt, '', complete)
	if empty(record)
		return -1
	endif
	let fields = split(record, s:field_separ)
	let linum = str2nr(fields[0])
	call cursor(linum, 1)
	normal! zv
	return linum
endfun

fun! organ#bird#goto_path ()
	" Goto heading with completion
	let prompt = 'Goto headline : '
	let complete = 'customlist,organ#complete#path'
	let record = input(prompt, '', complete)
	if empty(record)
		return -1
	endif
	let fields = split(record, s:field_separ)
	let linum = str2nr(fields[0])
	call cursor(linum, 1)
	normal! zv
	return linum
endfun

" ---- visibility

fun! organ#bird#cycle_current_fold ()
	" Cycle current fold visibility
	let position = getcurpos ()
	" ---- current subtree
	let subtree = organ#bird#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	let range = head_linum .. ',' .. tail_linum
	let level = subtree.level
	" ---- folds closed ?
	let current_closed = foldclosed('.')
	let linum_child = organ#bird#strict_child ('dont-move')
	if linum_child == 0
		let child_closed = -1
	else
		let child_closed = foldclosed(linum_child)
	endif
	" ---- cycle
	if current_closed > 0 && child_closed > 0
		normal! zo
		"execute range .. 'foldopen'
	elseif current_closed < 0 && child_closed > 0
		execute range .. 'foldopen!'
	elseif current_closed > 0 && child_closed < 0
		execute range .. 'foldopen!'
	else
		execute range .. 'foldclose!'
		for iter in range(1, level - 1)
			normal! zo
		endfor
	endif
endfun

fun! organ#bird#cycle_all_folds ()
	" Cycle folds visibility in all file
	" ---- max fold level of all file
	"let line_range = range(1, line('$'))
	"let max_foldlevel = max(map(line_range, { n -> foldlevel(n) }))
	" ---- cycle
	if &foldlevel == 0
		setlocal foldlevel=1
	elseif &foldlevel == 1
		setlocal foldlevel=10
	else
		setlocal foldlevel=0
	endif
endfun
