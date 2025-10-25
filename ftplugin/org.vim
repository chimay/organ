" vim: set ft=vim fdm=indent iskeyword&:

" Only do this when not done yet for this buffer
if exists("b:did_organ_ftplugin")
	finish
endif

let b:did_organ_ftplugin = 1

silent! call organ#void#enable ()
