" vim: set ft=vim fdm=indent iskeyword&:

" Perspective
"
" Content generators for completion of prompting functions

" ---- script constants

if ! exists('s:level_separ')
	let s:level_separ = organ#crystal#fetch('separator/level')
	lockvar s:level_separ
endif

if ! exists('s:field_separ')
	let s:field_separ = organ#crystal#fetch('separator/field')
	lockvar s:field_separ
endif

" ---- helpers

fun! organ#perspective#headlines_numbers ()
	" List of headlines line numbers
	let headline_pattern = organ#bird#generic_pattern ()
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

fun! organ#perspective#headlines (minlevel = 1, maxlevel = 30)
	" List of paths
	let minlevel = a:minlevel
	let maxlevel = a:maxlevel
	let position = getcurpos()
	let headnumlist = organ#perspective#headlines_numbers ()
	let returnlist = []
	for linum in headnumlist
		call cursor(linum, 1)
		let path = organ#bird#path ()
		let level = len(path)
		if level < minlevel || level > maxlevel
			continue
		endif
		let pathstring = path->join(s:level_separ)
		let entry = [linum, pathstring]
		let record = join(entry, s:field_separ)
		eval returnlist->add(record)
	endfor
	call setpos('.', position)
	return returnlist
endfun

fun! organ#perspective#tags ()
	" List of tags defined on #+tags lines
	let position = getcurpos()
	let runme = 'global /\m\c^#+tags:/p'
	let linelist = execute(runme)
	let linelist = split(linelist, "\n")
	let returnlist = []
	for elem in linelist
		let list = elem->split(' ')
		let list = list[2:]
		eval list->map({ _, v -> substitute(v, '\m([a-zA-Z])$', '', '')})
		eval returnlist->extend(list)
	endfor
	call setpos('.', position)
	return returnlist
endfun
