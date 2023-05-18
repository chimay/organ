" vim: set ft=vim fdm=indent iskeyword&:

" Abacus
"
" Evaluate expressions :
" - vim
" - python

" ---- vimscript

fun! organ#abacus#eval_vim ()
	" Eval vimscript expression
	"call setreg('"', result, 'c')
endfun

" ---- python

fun! organ#abacus#eval_python ()
	" Eval python expression
	"call setreg('"', result, 'c')
endfun

" ---- time & date

fun! organ#abacus#timestamp ()
	" Insert date & time stamp at cursor
	let linum = line('.')
	let colnum = col('.')
	let line = getline(linum)
	let [before, after] = organ#utils#line_split_by_cursor (line, colnum)
	let format = g:organ_config.timestamp_format
	let stamp = strftime(format)
	let lenstamp = len(stamp)
	let newline = before .. stamp .. after
	call setline(linum, newline)
	let colnum += lenstamp
	call cursor(linum, colnum)
endfun
