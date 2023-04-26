" vim: set ft=vim fdm=indent iskeyword&:

" Kyusu
"
" Filter for prompt completion
"
" A kyusu is a japanese traditional teapot, often provided with a filter inside
"
" A kabusecha is a shaded japanese tea
"
" A gaiwan is a chinese tea cup

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

fun! organ#kyusu#steep (wordlist, unused, value)
	" Whether value matches all words of wordlist
	" Word beginning by a ! means logical not
	" Pipe | in word means logical or
	" unused argument is for compatibility with filter()
	let wordlist = copy(a:wordlist)
	eval wordlist->map({ _, val -> substitute(val, '|', '\\|', 'g') })
	let match = v:true
	for word in wordlist
		if word !~ '\m^!'
			if a:value !~ word
				let match = v:false
				break
			endif
		else
			if a:value =~ word[1:]
				let match = v:false
				break
			endif
		endif
	endfor
	return match
endfun

" ---- children subtree, for tree moveto

fun! organ#kyusu#not_child (path, unused_key, value)
	" True if value is not a children of path
	let path = a:path
	let value = a:value
	let value = split(value, s:field_separ)[1]
	let path = split(path, s:level_separ)
	let value = split(value, s:level_separ)
	let index = min([len(path), len(value)]) - 1
	let not_child = path[:index] != value[:index]
	echomsg path value path[:index] value[:index] index not_child
	return not_child
endfun

" ---- prompt completion

fun! organ#kyusu#pour (wordlist, list)
	" Return elements of list matching words of wordlist
	let list = deepcopy(a:list)
	let Matches = function('organ#kyusu#steep', [a:wordlist])
	let candidates = filter(list, Matches)
	return candidates
endfun
