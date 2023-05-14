" vim: set ft=vim fdm=indent iskeyword&:

" Origami
"
" Folding

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
