" vim: set ft=vim fdm=indent iskeyword&:

" Bird
"
" Navigation on orgmode or markdown headings hierarchy

" ---- script constants

if exists('s:indent_pattern')
	unlockvar s:indent_pattern
endif
let s:indent_pattern = organ#crystal#fetch('pattern/indent')
lockvar s:indent_pattern

if exists('s:rep_one_char')
	unlockvar s:rep_one_char
endif
let s:rep_one_char = organ#crystal#fetch('filetypes/repeated_one_char_heading')
lockvar s:rep_one_char

if exists('s:level_separ')
	unlockvar s:level_separ
endif
let s:level_separ = organ#crystal#fetch('separator/level')
lockvar s:level_separ

if exists('s:field_separ')
	unlockvar s:field_separ
endif
let s:field_separ = organ#crystal#fetch('separator/field')
lockvar s:field_separ

if exists('s:tags_pattern')
	unlockvar s:tags_pattern
endif
let s:tags_pattern = organ#crystal#fetch('pattern/headline/tag')
lockvar s:tags_pattern

" ---- helpers

fun! organ#bird#char ()
	" Headline char
	if &filetype ==# 'org'
		return '*'
	elseif &filetype ==# 'markdown'
		return '#'
	elseif &filetype ==# 'asciidoc'
		return '='
	endif
endfun

fun! organ#bird#generic_pattern ()
	" Generic headline pattern
	if s:rep_one_char->index(&filetype) >= 0
		let char = organ#bird#char ()
		return '\m^[' .. char .. ']\+'
	elseif &foldmethod ==# 'marker'
		let marker = split(&foldmarker, ',')[0]
		return '\m' .. marker .. '[0-9]\+'
	elseif &foldmethod ==# 'indent'
		return '\m^\([ \t]*\)\ze\S.*\n\1[ \t]'
	endif
	" ---- default : never matches
	" ---- other solutions
	" ----   - \m^a\&^[^a]
	" ----   - \m^a\&^a\@!
	return '\m^$\&^.$'
endfun

fun! organ#bird#level_pattern (minlevel = 1, maxlevel = 30)
	" Headline pattern of level between minlevel and maxlevel
	let minlevel = a:minlevel
	let maxlevel = a:maxlevel
	if s:rep_one_char->index(&filetype) >= 0
		let char = organ#bird#char ()
		let pattern = '\m^[' .. char .. ']\{'
		let pattern ..= minlevel .. ',' .. maxlevel .. '}'
		let pattern ..= '[^' .. char .. ']'
		return pattern
	elseif &foldmethod ==# 'marker'
		return organ#origami#level_pattern (minlevel, maxlevel)
	elseif &foldmethod ==# 'indent'
		return organ#stair#level_pattern (minlevel, maxlevel)
	endif
	" -- never matches
	return '\m^$\&^.$'
endfun

fun! organ#bird#is_on_headline ()
	" Whether current line is an headline
	if organ#stair#is_indent_headline_file ()
		return organ#stair#is_on_headline ()
	endif
	let line = getline('.')
	return line =~ organ#bird#generic_pattern ()
endfun

fun! organ#bird#headline (move = 'dont-move')
	" Headline of current subtree
	let move = a:move
	let position = getcurpos ()
	call cursor('.', col('$'))
	let headline_pattern = organ#bird#generic_pattern ()
	let flags = organ#utils#search_flags ('backward', move, 'dont-wrap', 'accept-here')
	let linum = search(headline_pattern, flags)
	if move != 'move'
		call setpos('.', position)
	endif
	return linum
endfun

fun! organ#bird#foldlevel (move = 'dont-move')
	" Fold level
	let move = a:move
	let linum = organ#bird#headline (move)
	return foldlevel(linum)
endfun

fun! organ#bird#properties (move = 'dont-move')
	" Properties of current headline
	let move = a:move
	let linum = organ#bird#headline (move)
	if linum == 0
		echomsg 'organ bird properties : headline not found'
		return #{
			\ linum : 0,
			\ headline : '',
			\ commentstrings : [],
			\ levelstring : '',
			\ level : 1,
			\ todo : '',
			\ title : '',
			\ tagstring : '',
			\ tags : [],
			\}
	endif
	let headline = getline(linum)
	let title = headline
	" ---- commentstring
	let commentstrings = []
	if s:rep_one_char->index(&filetype) < 0 && ! empty(&commentstring)
		let comlist = split(&commentstring, '%s')
		let lencomlist = len(comlist)
		if lencomlist >= 1
			let comstr_pattern = '\m^' .. comlist[0]
			let comstr_pattern = comstr_pattern->escape('.*')
			let comstr = title->matchstr(comstr_pattern)
			eval commentstrings->add(comstr)
			let title = substitute(title, comstr_pattern, '', '')
		endif
		if lencomlist >= 2
			let comstr_pattern = '\m' .. comlist[1] .. '$'
			let comstr_pattern = comstr_pattern->escape('.*')
			let comstr = title->matchstr(comstr_pattern)
			eval commentstrings->add(comstr)
			let title = substitute(title, comstr_pattern, '', '')
		endif
	endif
	" ---- level & title
	if s:rep_one_char->index(&filetype) >= 0
		let char = organ#bird#char ()
		let levelstring_pattern = '\m^[' .. char .. ']\+'
		let levelstring = title->matchstr(levelstring_pattern)
		let level = len(levelstring)
		let title = title[level + 1:]
	elseif &foldmethod ==# 'marker'
		let marker = split(&foldmarker, ',')[0]
		let levelstring_pattern = '\m' .. marker .. '[0-9]\+'
		let levelstring = title->matchstr(levelstring_pattern)
		let level = organ#bird#foldlevel ()
		let title = substitute(title, levelstring_pattern, '', '')
	elseif &foldmethod ==# 'indent'
		let indentinfo = organ#stair#info (title)
		let levelstring = indentinfo.string
		let level = indentinfo.level + 1
		let title = substitute(title, s:indent_pattern, '', '')
	endif
	" ---- todo status
	let found = v:false
	for todo in g:organ_config.todo_cycle
		if title =~ todo
			let title = substitute(title, todo, '', '')
			let found = v:true
			break
		endif
	endfor
	if ! found
		let todo = ''
	endif
	" ---- tags
	let tagstring = title->matchstr(s:tags_pattern)
	let tags = tagstring[1:-2]->split(':')
	let title = substitute(title, s:tags_pattern, '', '')
	" ---- coda
	let title = trim(title)
	let properties = #{
			\ linum : linum,
			\ headline : headline,
			\ commentstrings : commentstrings,
			\ levelstring : levelstring,
			\ level : level,
			\ todo : todo,
			\ title : title,
			\ tagstring : tagstring,
			\ tags : tags,
			\}
	return properties
endfun

fun! organ#bird#subtree_tail (...)
	" Tail linum of current subtree
	if a:0 > 0
		let properties = organ#bird#properties ()
	else
		let properties = a:1
	endif
	let level = properties.level
	if s:rep_one_char->index(&filetype) >= 0
		call cursor('.', col('$'))
		let tail_pattern = organ#bird#level_pattern (1, level)
		let flags = organ#utils#search_flags ('forward', 'dont-move', 'dont-wrap')
		let forward_linum = search(tail_pattern, flags)
		if forward_linum == 0
			return line('$')
		endif
		return forward_linum - 1
	elseif &foldmethod ==# 'marker'
		return organ#origami#subtree_tail (level)
	elseif &foldmethod ==# 'indent'
		return organ#stair#subtree_tail (properties)
	endif
	return 0
endfun

fun! organ#bird#subtree (move = 'dont-move')
	" Range & properties of current subtree
	let move = a:move
	let position =  getcurpos ()
	let properties = organ#bird#properties (move)
	let head_linum = properties.linum
	if head_linum == 0
		echomsg 'organ bird subtree : headline not found'
		return #{
			\ linum : 0,
			\ head_linum : 0,
			\ tail_linum : 0,
			\ headline : '',
			\ commentstrings : [],
			\ level : 1,
			\ levelstring : '',
			\ title : '',
			\ todo : '',
			\}
	endif
	" ---- sync with properties
	let subtree = properties
	let subtree.head_linum = properties.linum
	" ---- find tail
	let subtree.tail_linum = organ#bird#subtree_tail (properties)
	if move ==# 'move'
		mark '
		call cursor(head_linum, 1)
	else
		call setpos('.', position)
	endif
	return subtree
endfun

fun! organ#bird#nearest (one, two, direction = 1, ...)
	" Nearest line number when folling direction, with wrap allowed
	" direction : 1 = forward, -1 = backward
	" if one or two == 0 : assuming not found, and return the other
	" if one and two == 0 : assuming both not found, and return 0
	let one = a:one
	let two = a:two
	let direction = a:direction
	if a:0 > 0
		let cursor = a:1
	else
		let cursor = line('.')
	endif
	if one == 0 && two == 0
		return 0
	endif
	if one == 0
		return two
	endif
	if two == 0
		return one
	endif
	let product = (one - cursor) * (two - cursor) * direction
	if product >= 0
		return min([one, two])
	else
		return max([one, two])
	endif
endfun

" ---- previous, next

fun! organ#bird#previous (move = 'move', wrap = 'wrap')
	" Previous heading
	let move = a:move
	let wrap = a:wrap
	let position = getcurpos ()
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
	if move ==# 'move'
		mark '
		call cursor('.', 1)
		normal! zv
		call organ#spiral#cursor ()
	else
		call setpos('.', position)
	endif
	return linum
endfun

fun! organ#bird#next (move = 'move', wrap = 'wrap')
	" Next heading
	let move = a:move
	let wrap = a:wrap
	let position = getcurpos ()
	call cursor('.', col('$'))
	let headline_pattern = organ#bird#generic_pattern ()
	let flags = organ#utils#search_flags ('forward', move, wrap)
	let linum = search(headline_pattern, flags)
	if linum == 0
		echomsg 'organ bird next : not found'
		return 0
	endif
	if move ==# 'move'
		mark '
		call cursor('.', 1)
		normal! zv
		call organ#spiral#cursor ()
	else
		call setpos('.', position)
	endif
	return linum
endfun

" ---- backward, forward

fun! organ#bird#backward (move = 'move', wrap = 'wrap')
	" Backward heading of same level
	let move = a:move
	let wrap = a:wrap
	let position = getcurpos ()
	let properties = organ#bird#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ bird backward : headline not found'
		return linum
	endif
	let level = properties.level
	call cursor('.', 1)
	let headline_pattern = organ#bird#level_pattern (level, level)
	let flags = organ#utils#search_flags ('backward', move, wrap)
	let linum = search(headline_pattern, flags)
	if move ==# 'move'
		mark '
		call cursor('.', 1)
		normal! zv
		call organ#spiral#cursor ()
	else
		call setpos('.', position)
	endif
	return linum
endfun

fun! organ#bird#forward (move = 'move', wrap = 'wrap')
	" Forward heading of same level
	let move = a:move
	let wrap = a:wrap
	let position = getcurpos ()
	let properties = organ#bird#properties ()
	let linum = properties.linum
	if linum == 0
		echomsg 'organ bird forward : headline not found'
		return linum
	endif
	let level = properties.level
	call cursor('.', col('$'))
	let headline_pattern = organ#bird#level_pattern (level, level)
	let flags = organ#utils#search_flags ('forward', move, wrap)
	let linum = search(headline_pattern, flags)
	if move ==# 'move'
		mark '
		call cursor('.', 1)
		normal! zv
		call organ#spiral#cursor ()
	else
		call setpos('.', position)
	endif
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
	let position = getcurpos ()
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
	if move ==# 'move'
		mark '
		call cursor('.', 1)
		normal! zv
		call organ#spiral#cursor ()
	else
		call setpos('.', position)
	endif
	return linum
endfun

fun! organ#bird#loose_child (move = 'move', wrap = 'wrap')
	" Child headline, or, more generally, first headline of level + 1, forward
	let move = a:move
	let wrap = a:wrap
	let position = getcurpos ()
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
	if move ==# 'move'
		mark '
		call cursor('.', 1)
		normal! zv
		call organ#spiral#cursor ()
	else
		call setpos('.', position)
	endif
	return linum
endfun

fun! organ#bird#strict_child (move = 'move', wrap = 'wrap')
	" First child subtree, strictly speaking
	let move = a:move
	let wrap = a:wrap
	let position = getcurpos ()
	let subtree = organ#bird#subtree ()
	let head_linum = subtree.head_linum
	let tail_linum = subtree.tail_linum
	if head_linum == 0 || tail_linum == 0
		echomsg 'organ bird strict child : headline not found'
		return -1
	endif
	let level = subtree.level + 1
	let headline_pattern = organ#bird#level_pattern (level, level)
	let flags = organ#utils#search_flags ('forward', move, wrap)
	let linum = search(headline_pattern, flags)
	if linum == 0 || linum > tail_linum
		"echomsg 'organ bird strict child : no child found'
		call setpos('.', position)
		call organ#spiral#cursor ()
		return 0
	endif
	if move ==# 'move'
		mark '
		call cursor('.', 1)
		normal! zv
		call organ#spiral#cursor ()
	else
		call setpos('.', position)
	endif
	return linum
endfun

" ---- full path of subtree : chapter, section, subsection, and so on

fun! organ#bird#path (move = 'dont-move')
	" Full headings path of current subtree : part, chapter, ...
	let move = a:move
	let position = getcurpos ()
	let properties = organ#bird#properties ('move')
	let path = [properties.title]
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
		let parent_linum = organ#bird#parent ('move', 'wrap', properties)
		if parent_linum == 0
			if move != 'move'
				call setpos('.', position)
			endif
			return path
		endif
		let properties = organ#bird#properties ('move')
		eval path->insert(properties.title)
	endwhile
endfun

fun! organ#bird#path_string (move = 'dont-move')
	" Full headings path of current subtree : part, chapter, ...
	let move = a:move
	let path = organ#bird#path (move)
	return path->join(s:level_separ)
endfun

fun! organ#bird#info (move = 'dont-move')
	" Echo full subtree path
	let dashboard = 'organ: ' .. organ#bird#path_string (a:move)
	echomsg dashboard
	call organ#spiral#cursor ()
endfun

" ---- goto

fun! organ#bird#goto ()
	" Goto heading path with completion
	let prompt = 'Go to headline : '
	let complete = 'customlist,organ#complete#headline'
	let record = input(prompt, '', complete)
	if empty(record)
		return -1
	endif
	let fields = split(record, s:field_separ)
	let linum = str2nr(fields[0])
	call cursor(linum, 1)
	call organ#spiral#cursor ()
	normal! zv
	call organ#spiral#cursor ()
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
