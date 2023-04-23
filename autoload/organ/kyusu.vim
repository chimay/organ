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

if ! exists('s:unused')
	let s:unused = 0
	lockvar s:unused
endif

" ---- helpers

fun! wheel#kyusu#steep (wordlist, unused, value)
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

" ---- prompt completion

fun! wheel#kyusu#pour (wordlist, list)
	" Return elements of list matching words of wordlist
	let list = deepcopy(a:list)
	let Matches = function('wheel#kyusu#steep', [a:wordlist])
	let candidates = filter(list, Matches)
	return candidates
endfun
