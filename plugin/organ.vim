" vim: set filetype=vim:
" Organ - Generalize org-mode principles to markdown and folded files

scriptencoding utf-8

if exists("g:organ_loaded")
	finish
endif

let g:organ_loaded = 1

call organ#void#init ()
