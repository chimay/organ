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

if ! exists('s:emacs_functions')
	let s:emacs_functions = organ#crystal#fetch('export/functions/emacs', 'dict')
	lockvar s:emacs_functions
endif

if ! exists('s:emacs_formats')
	let s:emacs_formats = keys(s:emacs_functions)
	lockvar s:emacs_formats
endif

if ! exists('s:subcommands_actions')
	let s:subcommands_actions = organ#diadem#fetch('command/meta/actions')
	lockvar s:subcommands_actions
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
	echomsg s:emacs_formats
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

" ---- meta command

fun! organ#complete#meta_command (arglead, cmdline, cursorpos)
	" Completion for :Organ meta command
	let cmdline = a:cmdline
	let arglead = a:arglead
	let cursorpos = a:cursorpos
	" ---- words
	let wordlist = split(cmdline)
	let length =  len(wordlist)
	" ---- checks
	if length == 0
		return []
	endif
	if wordlist[0] !=# 'Organ'
		return []
	endif
	" ---- last word
	let last = wordlist[-1]
	let last_list = split(last, '[,;]')
	" ---- cursor after a partial word ?
	let blank = cmdline[cursorpos - 1] =~ '\m\s'
	" ---- subcommand
	let subcommands = organ#utils#items2keys(s:subcommands_actions)
	if length == 1 && blank
		return subcommands
	endif
	if length == 2 && ! blank
		return organ#kyusu#pour(last_list, subcommands)
	endif
	let subcommand = wordlist[1]
	return []
endfun
