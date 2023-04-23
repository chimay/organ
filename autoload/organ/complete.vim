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

" ---- script constants

if ! exists('s:pandoc_formats')
	let s:pandoc_formats = organ#crystal#fetch('export/formats/pandoc')
	lockvar s:pandoc_formats
endif

if ! exists('s:emacs_formats')
	let s:emacs_formats = organ#crystal#fetch('export/formats/emacs')
	lockvar s:emacs_formats
endif

" ---- headlines

fun! organ#complete#headline (arglead, cmdline, cursorpos)
	" Complete buffer line
	let choices = organ#perspective#headlines ()
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

fun! organ#complete#path (arglead, cmdline, cursorpos)
	" Complete buffer line
	let choices = organ#perspective#paths ()
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

" ---- export

fun! organ#complete#pandoc_formats (arglead, cmdline, cursorpos)
	" Complete buffer line
	let choices = s:pandoc_formats
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

fun! organ#complete#emacs_formats (arglead, cmdline, cursorpos)
	" Complete buffer line
	let choices = s:emacs_formats
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun
