" vim: set ft=vim fdm=indent iskeyword&:

" Origami
"
" Folding

fun! organ#origami#folding_text ()
	" Orgmode folding text
	let commentaire = substitute(&commentstring, '%s', '', '')
	let text = getline(v:foldstart)
	let text = substitute(text, '\m{{{[0-9]\?', '', '')				" }}}
	let text = substitute(text, commentaire, '', 'g')
	let text = substitute(text, '\t', '', 'g')
	let text = substitute(text, '’', "'", 'g')
	let text = substitute(text, '\m\C[[=A=]]', 'A', 'g')
	let text = substitute(text, '\m\C[[=E=]]', 'E', 'g')
	let text = substitute(text, '\m\C[[=I=]]', 'I', 'g')
	let text = substitute(text, '\m\C[[=O=]]', 'O', 'g')
	let text = substitute(text, '\m\C[[=U=]]', 'U', 'g')
	let text = substitute(text, '\m\C[[=a=]]', 'a', 'g')
	let text = substitute(text, '\m\C[[=e=]]', 'e', 'g')
	let text = substitute(text, '\m\C[[=i=]]', 'i', 'g')
	let text = substitute(text, '\m\C[[=o=]]', 'o', 'g')
	let text = substitute(text, '\m\C[[=u=]]', 'u', 'g')
	let Nlignes = v:foldend - v:foldstart
	let text = text .. ' :: ' .. Nlignes .. ' lines' .. v:folddashes
	let text = substitute(text, '\m \{2,}', ' ', 'g')
	return text
endfun

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
