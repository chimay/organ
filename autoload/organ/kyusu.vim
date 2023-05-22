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

if exists('s:vowels')
	unlockvar s:vowels
endif
let s:vowels = organ#crystal#fetch('pattern/vowels')
lockvar s:vowels

" ---- helpers

fun! organ#kyusu#vocalize(word)
	" Add vowels patterns between chars
	let word = a:word
	let charlist = word->split('\zs')
	let inter = s:vowels .. '*'
	let vocalize = []
	for index in range(len(charlist) - 1)
		let char = charlist[index]
		eval vocalize->add(char)
		eval vocalize->add(inter)
	endfor
	eval vocalize->add(charlist[-1])
	let vocalize = vocalize->join('')
	return vocalize
endfun

fun! organ#kyusu#steep (wordlist, unused, value)
	" Whether value matches all words of wordlist
	" Word beginning by a ! means logical not
	" Pipe | in word means logical or
	" unused argument is for compatibility with filter()
	let wordlist = copy(a:wordlist)
	let value = a:value
	eval wordlist->map({ _, val -> substitute(val, '\m|', '\\|', 'g') })
	let match = v:true
	if g:organ_config.completion.vocalize > 0
		eval wordlist->map({ _, val -> organ#kyusu#vocalize(val) })
	endif
	for word in wordlist
		if word !~ '\m^!'
			if value !~ word
				let match = v:false
				break
			endif
		else
			if value =~ word[1:]
				let match = v:false
				break
			endif
		endif
	endfor
	return match
endfun

" ---- prompt completion

fun! organ#kyusu#pour (wordlist, list)
	" Return elements of list matching words of wordlist
	let wordlist = a:wordlist
	let list = a:list
	if g:organ_config.completion.fuzzy > 0
		return list->matchfuzzy(join(wordlist))
	endif
	let list = deepcopy(list)
	let Matches = function('organ#kyusu#steep', [wordlist])
	let candidates = filter(list, Matches)
	return candidates
endfun

" ---- not current headline path, for tree moveto

fun! organ#kyusu#not_current_path (current, unused_key, value)
	" True if value is not the current heading path
	let current = a:current
	let value = a:value
	let value = split(value, s:field_separ)[1]
	let value = split(value, s:level_separ)
	let notme = current != value
	return notme
endfun
