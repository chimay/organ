" vim: set ft=vim fdm=indent iskeyword&:

" Origami
"
" Folding

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

" ---- orgmode

fun! organ#origami#orgmode (linum)
	" Orgmode folding expression
	let content = getline(a:linum)
	let begin = '\m^\*\{'
	let end = '} '
	for level in range(1, 9)
		let pattern = begin .. level .. end
		if content =~ pattern
			return '>' .. level
		endif
	endfor
	return '='
endfun

" ---- markdown

fun! organ#origami#markdown (linum)
	" Markdown folding expression
	let content = getline(a:linum)
	let begin = '\m^#\{'
	let end = '} '
	for level in range(1, 9)
		let pattern = begin .. level .. end
		if content =~ pattern
			return '>' .. level
		endif
	endfor
	return '='
endfun

" ---- asciidoc

fun! organ#origami#asciidoc (linum)
	" Asciidoc folding expression
	let content = getline(a:linum)
	let begin = '\m^=\{'
	let end = '} '
	for level in range(1, 9)
		let pattern = begin .. level .. end
		if content =~ pattern
			return '>' .. level
		endif
	endfor
	return '='
endfun

" ---- generic

fun! organ#origami#folding_text ()
	" Orgmode folding text
	let comstr = substitute(&commentstring, '%s', '', '')
	let text = getline(v:foldstart)
	let text = substitute(text, '\m{{{[0-9]\?', '', '')				" }}}
	let text = substitute(text, comstr, '', 'g')
	let text = substitute(text, '\t', '', 'g')
	let Nlines = v:foldend - v:foldstart
	let text = text .. ' :: ' .. Nlines .. ' lines' .. v:folddashes
	let text = substitute(text, '\m \{2,}', ' ', 'g')
	return text
endfun

fun! organ#origami#folding ()
	" Generic folding
	setlocal foldmethod=expr
	setlocal foldtext=organ#origami#folding_text()
	if &filetype ==# 'org'
		setlocal foldexpr=organ#origami#orgmode(v:lnum)
	elseif &filetype ==# 'markdown'
		setlocal foldexpr=organ#origami#markdown(v:lnum)
	elseif &filetype ==# 'asciidoc'
		setlocal foldexpr=organ#origami#asciidoc(v:lnum)
	endif
endfun

" ---- foldmarker headline

fun! organ#origami#is_marker_headline_file ()
	" Whether headlines are indent defined in current file
	return s:rep_one_char->index(&filetype) < 0 && &foldmethod ==# 'marker'
endfun

fun! organ#origami#is_endmarker_fold (...)
	" Whether current subtree has an end marker
	if a:0 > 0
		let level = a:1
	else
		let level = organ#bird#properties ().level
	endif
	if s:rep_one_char->index(&filetype) >= 0 || &foldmethod ==# 'indent'
		return v:false
	endif
	let tail_linum = organ#origami#subtree_tail (level)
	let markerlist = split(&foldmarker, ',')
	let tail_line = getline(tail_linum)
	if tail_line =~ markerlist[1]
		return v:true
	endif
	if tail_linum == 1
		return v:false
	endif
	let prev_linum = tail_linum - 1
	let prev_line = getline(prev_linum)
	if tail_line ==# s:hollow_pattern && prev_line =~ markerlist[1]
		return v:true
	endif
	return v:false
endfun

fun! organ#origami#level_pattern (minlevel = 1, maxlevel = 30)
	" Foldmarker headline pattern, level between minlevel and maxlevel
	let minlevel = a:minlevel
	let maxlevel = a:maxlevel
	let marker = split(&foldmarker, ',')[0]
	let pattern = '\m' .. marker .. '\%('
	for level in range(minlevel, maxlevel)
		let pattern ..= level
		if level < maxlevel
			let pattern ..= '\|'
		endif
	endfor
	let pattern ..= '\)'
	return pattern
endfun

fun! organ#origami#subtree_tail_level_pattern (minlevel = 1, maxlevel = 30)
	" Foldmarker subtree tail pattern, level between minlevel and maxlevel
	let minlevel = a:minlevel
	let maxlevel = a:maxlevel
	let markerlist = split(&foldmarker, ',')
	let pattern = '\m' .. markerlist[0] .. '\%('
	for level in range(minlevel, maxlevel)
		let pattern ..= level
		if level < maxlevel
			let pattern ..= '\|'
		endif
	endfor
	let pattern ..= '\)\|' .. markerlist[1] .. '\%('
	for level in range(minlevel, maxlevel)
		let pattern ..= level
		if level < maxlevel
			let pattern ..= '\|'
		endif
	endfor
	let pattern ..= '\)'
	return pattern
endfun

fun! organ#origami#subtree_tail (...)
	" Tail linum of foldmarker subtree
	if a:0 > 0
		let level = organ#bird#properties ().level
	else
		let level = a:1
	endif
	let last_linum = line('$')
	let markerlist = split(&foldmarker, ',')
	call cursor('.', col('$'))
	let tail_pattern = organ#origami#subtree_tail_level_pattern (1, level)
	let flags = organ#utils#search_flags ('forward', 'dont-move', 'dont-wrap')
	let forward_linum = search(tail_pattern, flags)
	if forward_linum == 0
		return last_linum
	endif
	if forward_linum == last_linum
		return forward_linum
	endif
	let line = getline(forward_linum)
	if line =~ markerlist[1]
		let next_line = getline(forward_linum + 1)
		if next_line ==# s:hollow_pattern
			return forward_linum + 1
		else
			return forward_linum
		endif
	endif
	return forward_linum - 1
endfun

" ---- suspend & resume during heavy functions that does not need it

fun! organ#origami#suspend ()
	" Suspend expr folding
	if ! exists('b:organ_stops')
		let b:organ_stops = {}
		let b:organ_stops.foldmethod = {}
		let b:organ_stops.foldmethod.locked = v:false
	endif
	if b:organ_stops.foldmethod.locked
		return v:false
	endif
	let b:organ_stops.foldmethod.value = &l:foldmethod
	let b:organ_stops.foldmethod.locked = v:true
	let &l:foldmethod = 'manual'
	return v:true
endfun

fun! organ#origami#resume ()
	" Resume expr folding
	if ! exists('b:organ_stops')
		echomsg 'organ origami resume : b:organ_stops does not exist'
		return v:false
	endif
	let &l:foldmethod = b:organ_stops.foldmethod.value
	let b:organ_stops.foldmethod.locked = v:false
	return v:true
endfun
