" vim: set ft=vim fdm=indent iskeyword&:

" Seed
"
" Expand shortcuts, kind of a lightweight snippet
"
" Aka org structure templates

" ---- script constants

if exists('s:rep_one_char')
	unlockvar s:rep_one_char
endif
let s:rep_one_char = organ#crystal#fetch('filetypes/repeated_one_char_heading')
lockvar s:rep_one_char

if exists('s:templates')
	unlockvar s:templates
endif
let s:templates = organ#crystal#fetch('templates/expansions', 'dict')
lockvar s:templates

" ---- generic

fun! organ#seed#expand ()
	" Expand template at current line
	let line = getline('.')
	let trigger_pattern = '\m\s*\zs.*$'
	let trigger = line->matchstr(trigger_pattern)
	let spaces = '\m^\s*'
	if line =~ spaces .. '<'
		return organ#seed#angle (trigger)
	elseif line =~ spaces .. '+'
		return organ#seed#plus (trigger)
	elseif line =~ spaces .. ':'
		return organ#seed#colon (trigger)
	endif
endfun

" ---- trigger class

fun! organ#seed#angle (trigger)
	" Expand angle shortcut at current line
	" #+begin_something
	" <cursor>
	" #+end_something
	let trigger = a:trigger
	if trigger ==# '<s'
		return organ#seed#source ()
	endif
	let templates = copy(s:templates)->extend(g:organ_config.templates, 'force')
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
	" #+something: <cursor>
	let trigger = a:trigger
	let templates = copy(s:templates)->extend(g:organ_config.templates, 'force')
	if has_key(templates, trigger)
		let suffix = templates[trigger]
		let newline = '#+' .. suffix .. ': '
		let linum = line('.')
		call setline(linum, newline)
		startinsert!
		return newline
	endif
	return ''
endfun

fun! organ#seed#colon (trigger)
	" Expand colon shortcut at current line
	let trigger = a:trigger
	let templates = copy(s:templates)->extend(g:organ_config.templates, 'force')
	if has_key(templates, trigger)
		let keyword = templates[trigger]
		return organ#seed#colon_{keyword} ()
	endif
	return ''
endfun

" ---- details

fun! organ#seed#source (...)
	" Expand source bloc shortcut at current line
	" #+begin_src language
	" <cursor>
	" #+end_src
	if s:rep_one_char->index(&filetype) < 0
		echomsg 'organ seed source : filetype not supported'
		return ''
	endif
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
	if &filetype ==# 'org'
		let open = '#+begin_src ' .. lang
		let close = '#+end_src'
	elseif &filetype ==# 'markdown'
		let open = '```' .. lang
		let close = '```'
	elseif &filetype ==# 'vimwiki'
		let open = '{{{' .. lang
		let close = '}}}'
	endif
	let linum = line('.')
	call setline(linum, open)
	call append(linum, '')
	let linum += 1
	call append(linum, close)
	call cursor(linum, 1)
	startinsert
	return open
endfun

fun! organ#seed#colon_section ()
	" Properties bloc with section custom id
    " :properties:
    " :custom_id: section: <cursor>
    " :end:
	let open = ':properties:'
	let middle = ':custom_id: section:'
	let close = ':end:'
	let linum = line('.')
	call setline(linum, open)
	call append(linum, middle)
	let linum += 1
	call append(linum, close)
	call cursor(linum, 1)
	startinsert!
	return open
endfun
