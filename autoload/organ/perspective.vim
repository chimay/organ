" vim: set ft=vim fdm=indent iskeyword&:

" Perspective
"
" Content generators for completion of prompting functions

" ---- script constants

if ! exists('s:field_separ')
	let s:field_separ = organ#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" ---- helpers

fun! organ#perspective#headlines_numbers ()
	" List of headlines line numbers
	let headline_pattern = organ#bird#headline_pattern ()
	let position = getcurpos()
	let runme = 'global /' .. headline_pattern .. '/number'
	let returnlist = execute(runme)
	let returnlist = split(returnlist, "\n")
	for index in range(len(returnlist))
		let elem = returnlist[index]
		let fields = split(elem, ' ')
		let linum = fields[0]
		let returnlist[index] = linum
	endfor
	call setpos('.', position)
	return returnlist
endfun

" ---- headlines

fun! organ#perspective#headlines ()
	" List of headlines
	let headline_pattern = organ#bird#headline_pattern ()
	let position = getcurpos()
	let runme = 'global /' .. headline_pattern .. '/number'
	let returnlist = execute(runme)
	let returnlist = split(returnlist, "\n")
	for index in range(len(returnlist))
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

fun! organ#perspective#paths ()
	" List of paths
	let position = getcurpos()
	let headnumlist = organ#perspective#headlines_numbers ()
	let returnlist = []
	for linum in headnumlist
		call cursor(linum, 1)
		let path = organ#bird#path ()
		let entry = [linum, path]
		let record = join(entry, s:field_separ)
		eval returnlist->add(record)
	endfor
	call setpos('.', position)
	return returnlist
endfun
