" vim: set ft=vim fdm=indent iskeyword&:

" Origami
"
" Folding

fun! organ#origami#folding_text ()
	" Orgmode folding text
	let commentaire = substitute(&commentstring, '%s', '', '')
	let text = getline(v:foldstart)
	let text = substitute(text, '{{{[0-9]\?', '', '')				" }}}
	let text = substitute(text, commentaire, '', 'g')
	let text = substitute(text, '\t', '', 'g')
	let text = substitute(text, '’', "'", 'g')
	let text = substitute(text, '\C[[=A=]]', 'A', 'g')
	let text = substitute(text, '\C[[=E=]]', 'E', 'g')
	let text = substitute(text, '\C[[=I=]]', 'I', 'g')
	let text = substitute(text, '\C[[=O=]]', 'O', 'g')
	let text = substitute(text, '\C[[=U=]]', 'U', 'g')
	let text = substitute(text, '\C[[=a=]]', 'a', 'g')
	let text = substitute(text, '\C[[=e=]]', 'e', 'g')
	let text = substitute(text, '\C[[=i=]]', 'i', 'g')
	let text = substitute(text, '\C[[=o=]]', 'o', 'g')
	let text = substitute(text, '\C[[=u=]]', 'u', 'g')
	let Nlignes = v:foldend - v:foldstart
	let text = text .. ' :: ' .. Nlignes .. ' lines' .. v:folddashes
	let text = substitute(text, ' \{2,}', ' ', 'g')
	return text
endfun

" ---- orgmode

fun! organ#origami#orgmode_folding_expr (linum)
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

fun! organ#origami#orgmode_folding ()
	" Orgmode folding
	setlocal foldmethod=expr
	setlocal foldexpr=organ#origami#orgmode_folding_expr(v:lnum)
	setlocal foldtext=organ#origami#folding_text()
endfun

" ---- markdown

fun! organ#origami#markdown_folding_expr (linum)
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

fun! organ#origami#markdown_folding ()
	" Orgmode folding
	setlocal foldmethod=expr
	setlocal foldexpr=organ#origami#markdown_folding_expr(v:lnum)
	setlocal foldtext=organ#origami#folding_text()
endfun

" ---- markdown

fun! organ#origami#asciidoc_folding_expr (linum)
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

fun! organ#origami#asciidoc_folding ()
	" Orgmode folding
	setlocal foldmethod=expr
	setlocal foldexpr=organ#origami#asciidoc_folding_expr(v:lnum)
	setlocal foldtext=organ#origami#folding_text()
endfun
" ---- generic

fun! organ#origami#folding ()
	" Generic folding
	if &filetype ==# 'org'
		call organ#origami#orgmode_folding ()
	elseif &filetype ==# 'markdown'
		call organ#origami#markdown_folding ()
	elseif &filetype ==# 'asciidoc'
		call organ#origami#asciidoc_folding ()
	endif
endfun
