" vim: set ft=vim fdm=indent iskeyword&:

" Seed
"
" Expand shortcuts, kind of a lightweight snippet
"
" Aka org structure templates

fun! organ#seed#expand ()
	" Expand template at current line
endfun

fun! organ#seed#expand_src ()
	" Expand src bloc at current line
	let prompt = 'Src bloc lang : '
	let complete = 'customlist,organ#complete#templates_lang'
	let record = input(prompt, '', complete)
	if empty(record)
		return -1
	endif
endfun
