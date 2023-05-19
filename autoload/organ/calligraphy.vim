" vim: set ft=vim fdm=indent iskeyword&:

" Calligraphy
"
" Use unicode characters

" ---- script constants

if exists('s:field_separ')
	unlockvar s:field_separ
endif
let s:field_separ = organ#crystal#fetch('separator/field')
lockvar s:field_separ

" ---- generic

fun! organ#calligraphy#insert ()
	" Insert unicode character
	let linum = line('.')
	let colnum = col('.')
	let line = getline(linum)
	let [before, after] = organ#utils#line_split_by_cursor (line, colnum)
	let prompt = 'Character name : '
	let complete = 'customlist,organ#complete#unicode'
	let entry = input(prompt, '', complete)
	let character = entry->split(s:field_separ)[0]
	let newline = before .. character .. after
	call setline(linum, newline)
	let colnum += 2
	call cursor(linum, colnum)
endfun
