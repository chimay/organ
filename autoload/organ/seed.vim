" vim: set ft=vim fdm=indent iskeyword&:

" Seed
"
" Expand shortcuts, kind of a lightweight snippet
"
" Aka org structure templates

fun! organ#seed#expand ()
	" Expand template at current line
	if &filetype != 'org'
		echomsg 'organ seed expand : filetype not supported'
	endif
	let line = getline('.')
	let trigger_pattern = '\m\s*\zs.*$'
	let trigger = line->matchstr(trigger_pattern)
	let angle_pat = '\m^\s*<'
	let plus_pat = '\m^\s*+'
	if line =~ angle_pat
		return organ#seed#angle (trigger)
	elseif line =~ plus_pat
		return organ#seed#plus (trigger)
	endif
endfun

fun! organ#seed#angle (trigger)
	" Expand angle shortcut at current line
	let trigger = a:trigger
	let source_pat = '\m^\s*<s'
	if trigger == '<s'
		return organ#seed#source ()
	endif
	let templates = g:organ_config.templates
	if has_key(templates, trigger)
		let suffix = templates[trigger]
		let open = '#+begin_' .. suffix
		let close = '#+end_' .. suffix
		let linum = line('.')
		call setline(linum, open)
		call append(linum, '')
		let linum += 1
		call append(linum, close)
		call cursor(linum, 1)
		startinsert
		return open
	endif
	return ''
endfun

fun! organ#seed#plus (trigger)
	" Expand plus shortcut at current line
	let trigger = a:trigger
	let templates = g:organ_config.templates
	if has_key(templates, trigger)
		let suffix = templates[trigger]
		let newline = '#' .. suffix .. ': '
		let linum = line('.')
		call setline(linum, newline)
		startinsert!
		return newline
	endif
	return ''
endfun

fun! organ#seed#source (...)
	" Expand source bloc shortcut at current line
	if a:0 > 0
		let line = a:1
	else
		let line = getline('.')
	endif
	let prompt = 'Language : '
	let complete = 'customlist,organ#complete#templates_lang'
	let lang = input(prompt, '', complete)
	if empty(lang)
		return ''
	endif
	let open = '#+begin_src ' .. lang
	let close = '#+end_src'
	let linum = line('.')
	call setline(linum, open)
	call append(linum, '')
	let linum += 1
	call append(linum, close)
	call cursor(linum, 1)
	startinsert
	return open
endfun
