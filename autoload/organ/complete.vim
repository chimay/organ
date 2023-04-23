" vim: set ft=vim fdm=indent iskeyword&:

" Complete
"
" Completion list functions

" Return entries as list
"
" vim does not filter the entries,
" if needed, it has to be done
" in the function body
"
" Note : kyusu#pour makes a deepcopy of the list before
" processing, no need to do it here

fun! organ#complete#headline (arglead, cmdline, cursorpos)
	" Complete buffer line
	let choices = organ#perspective#headlines ()
	let wordlist = split(a:cmdline)
	return wheel#kyusu#pour(wordlist, choices)
endfun

