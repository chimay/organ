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
	" -
	let position = getcurpos ()
	let linum = position[1]
	let colnum = position[2]
	let line = getline(linum)
	if colnum <= 1
		let before = ''
		let after = line
	elseif colnum == col('$')
		let before = line
		let after = ''
	else
		let before = line[:colnum - 2]
		let after = line[colnum - 1:]
	endif
	let prompt = 'Character name : '
	let complete = 'customlist,organ#complete#unicode'
	let entry = input(prompt, '', complete)
	let character = entry->split(s:field_separ)[0]
	let newline = before .. character .. after
	call setline(linum, newline)
	let colnum += 1
	call cursor(linum, colnum)
endfun
