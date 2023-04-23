" vim: set ft=vim fdm=indent iskeyword&:

" Perspective
"
" Content generators for completion of prompting functions

" ---- script constants

if ! exists('s:field_separ')
	let s:field_separ = wheel#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" ---- headlines

fun! organ#perspective#headlines ()
	" List of headlines
	let headline_pattern = organ#bird#headline_pattern ()
	let position = getcurpos()
	let runme = 'global /' .. headline_pattern .. '/number'
	let returnlist = execute(runme)
	let returnlist = split(returnlist, "\n")
	for index in wheel#chain#rangelen(returnlist)
		let elem = returnlist[index]
		let fields = split(elem, ' ')
		let linum = fields[0]
		let content = join(fields[1:])
		let linum = printf('%5d', linum)
		let entry = [linum, content]
		let elem = join(entry, s:field_separ)
		let returnlist[index] = elem
	endfor
	call setpos('.', position)
	return returnlist
endfun

