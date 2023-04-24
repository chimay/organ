" vim: set ft=vim fdm=indent iskeyword&:

" Eagle
"
" Navigation and operations on orgmode or markdown
" headings or items hierarchy

fun! organ#nest#navig (function)
	" Choose to apply headline or list navigation function
	let function = a:function
	if organ#colibri#is_in_list ()
		call organ#colibri#{function} ()
	else
		call organ#bird#{function} ()
	endif
endfun

fun! organ#nest#oper (function)
	" Choose to apply headline or list operation function
	let function = a:function
	if organ#colibri#is_in_list ()
		call organ#bush#{function} ()
	else
		call organ#tree#{function} ()
	endif
endfun
