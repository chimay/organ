" vim: set filetype=vim:

scriptencoding utf-8

if exists("g:organ_loaded")
	finish
endif

let g:organ_loaded = 1

call organ#void#config ()
call organ#centre#commands ()
call organ#centre#plugs ()
