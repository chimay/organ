" vim: set ft=vim fdm=indent iskeyword&:

" Perspective
"
" Content generators for completion of prompting functions

" ---- script constants

if exists('s:tags_pattern')
	unlockvar s:tags_pattern
endif
let s:tags_pattern = organ#crystal#fetch('pattern/headline/tag')
lockvar s:tags_pattern

if exists('s:level_separ')
	unlockvar s:level_separ
endif
let s:level_separ = organ#crystal#fetch('separator/level')
lockvar s:level_separ

if exists('s:field_separ')
	unlockvar s:field_separ
endif
let s:field_separ = organ#crystal#fetch('separator/field')
lockvar s:field_separ

" ---- helpers

fun! organ#perspective#headlines_numbers ()
	" List of headlines line numbers
	let headline_pattern = organ#bird#generic_pattern ()
	let position = getcurpos ()
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
	let position = getcurpos ()
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
	" List of tags defined on #+tags & headlines :tag:tag:...:
	let position = getcurpos ()
	let returnlist = []
	" ---- #+tags lines
	if &filetype ==# 'org'
		let runme = 'global /\m\c^#+tags:/print'
		let output = execute(runme)
		let linelist = split(output, "\n")
		for elem in linelist
			let list = elem->split(' ')
			let list = list[2:]
			eval list->map({ _, v -> substitute(v, '\m([a-zA-Z])$', '', '')})
			eval returnlist->extend(list)
		endfor
	endif
	" ---- tags on headlines
	let comlist = split(&commentstring, '\s*%s\s*')
	if len(comlist) >= 2
		let endcom = comlist[1]->escape('.*')
		let tags_pattern = s:tags_pattern .. '\s*\%(' .. endcom .. '\)\?$'
	else
		let tags_pattern = s:tags_pattern .. '$'
	endif
	let runme = 'global /' .. tags_pattern .. '/print'
	let output = execute(runme)
	let linelist = split(output, "\n")
	for elem in linelist
		let fields = split(elem, ' ')
		eval fields->filter({ _, v -> v =~ '^:[[:alnum:]:]\+:$' })
		for tagstring in fields
			let list = tagstring[1:-2]->split(':')
			eval returnlist->extend(list)
		endfor
	endfor
	eval returnlist->sort()->uniq()
	" ---- coda
	call setpos('.', position)
	return returnlist
endfun

" ---- unicode

fun! organ#perspective#unicode ()
	let charlist = deepcopy(organ#unicode#fetch('all'))
	let returnlist = []
	for entry in charlist
		let entry[0] = entry[0]->substitute('/', s:level_separ, 'g')
		eval entry->reverse()
		let record = join(entry, s:field_separ)
		eval returnlist->add(record)
	endfor
	return returnlist
endfun
