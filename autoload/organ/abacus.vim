" vim: set ft=vim fdm=indent iskeyword&:

" Abacus
"
" Evaluate expressions :
" - vim
" - python

" ---- vimscript

fun! organ#abacus#eval_vim ()
	" Eval vimscript expression
	" ---- prompt
	let prompt = 'Vim expression : '
	let complete = 'customlist,organ#complete#vim_expression'
	let expression = input(prompt, '', complete)
	" ---- add expression to history
	let stoplist = g:ORGAN_STOPS.expr.vim
	if stoplist->index(expression) < 0
		eval stoplist->add(expression)
	endif
	" ---- result
	let result = eval(expression)
	" ---- add result to default register
	call setreg('"', result, 'c')
	" ---- insert result into line
	let linum = line('.')
	let colnum = col('.')
	let line = getline(linum)
	let [before, after] = organ#utils#line_split_by_cursor (line, colnum)
	let newline = before .. result .. after
	call setline(linum, newline)
	let colnum += len(result)
	call cursor(linum, colnum)
	" ---- coda
	return result
endfun

" ---- python

fun! organ#abacus#eval_python ()
	" Eval python expression
	" ---- prompt
	let prompt = 'Python expression : '
	let complete = 'customlist,organ#complete#python_expression'
	let expression = input(prompt, '', complete)
	" ---- add expression to history
	let stoplist = g:ORGAN_STOPS.expr.python
	if stoplist->index(expression) < 0
		eval stoplist->add(expression)
	endif
	" ---- result
	let runme = "python print(" .. expression .. ")"
	let result = execute(runme)
	let result = result->substitute('\n', '', 'g')
	" ---- add result to default register
	call setreg('"', result, 'c')
	" ---- insert result into line
	let linum = line('.')
	let colnum = col('.')
	let line = getline(linum)
	let [before, after] = organ#utils#line_split_by_cursor (line, colnum)
	let newline = before .. result .. after
	call setline(linum, newline)
	let colnum += len(result)
	call cursor(linum, colnum)
	" ---- coda
	return result
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
