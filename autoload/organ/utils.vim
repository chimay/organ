" vim: set ft=vim fdm=indent iskeyword&:

" Utils
"
" Small tools

" ---- circular

fun! organ#utils#circular_plus (index, length)
	" Rotate/increase index with modulo
	return (a:index + 1) % a:length
endfun

fun! organ#utils#circular_minus (index, length)
	" Rotate/decrease index with modulo
	let index = (a:index - 1) % a:length
	if index < 0
		let index += a:length
	endif
	return index
endfun

" ---- lists

fun! organ#utils#is_inside (element, list)
	" Whether element is in list
	let index = a:list->index(a:element)
	if index >= 0
		return v:true
	else
		return v:false
	endif
endfun

" ---- dicts and lists

fun! organ#utils#is_nested_list (argument)
	" Whether argument is a nested list
	" Empty list is not considered nested
	let argument = a:argument
	if type(argument) != v:t_list
		return v:false
	endif
	if empty(argument)
		return v:false
	endif
	for elem in argument
		if type(elem) != v:t_list
			return v:false
		endif
	endfor
	return v:true
endfun

fun! organ#utils#items2dict (items)
	" Convert items list -> dictionary
	let items = a:items
	if ! organ#utils#is_nested_list (items)
		return {}
	endif
	let dict = {}
	for [key, val] in items
		let dict[key] = val
	endfor
	return dict
endfun

fun! organ#utils#items2keys (items)
	" Return list of keys from dict given by items list
	let items = a:items
	if ! organ#utils#is_nested_list (items)
		return []
	endif
	let keylist = []
	for [key, val] in items
		eval keylist->add(key)
	endfor
	return keylist
endfun

fun! organ#utils#items2values (items)
	" Return list of values from dict given by items list
	let items = a:items
	if ! organ#utils#is_nested_list (items)
		return []
	endif
	let valist = []
	for [key, val] in items
		eval valist->add(val)
	endfor
	return valist
endfun

" ---- characters

fun! organ#utils#reverse_keytrans (keystring)
	" Convert char representation like <c-a> -> 
	let keystring = a:keystring
	let angle_pattern = '\m<[^>]\+>'
	while v:true
		let match = keystring->matchstr(angle_pattern)
		if empty(match)
			break
		endif
		execute 'let subst =' '"\<' .. match[1:-2] .. '>"'
		let keystring = substitute(keystring, match, subst, '')
	endwhile
	return keystring
endfun

" ----- buffer

fun! organ#utils#search_flags (course = 'forward', move = 'move', wrap = 'wrap', where = 'not-here')
	" Search flags
	let course = a:course
	let move = a:move
	let wrap = a:wrap
	let where = a:where
	let flags = ''
	if course ==# 'backward' || course ==# 'back'
		let flags ..= 'b'
	endif
	if move ==# 'move'
		let flags ..= 's'
	else
		let flags ..= 'n'
	endif
	if wrap ==# 'wrap'
		let flags ..= 'w'
	else
		let flags ..= 'W'
	endif
	if where ==# 'accept-here' || where ==# 'ok-here'
		let flags ..= 'c'
	endif
	return flags
endfun

fun! organ#utils#line_split_by_cursor (...)
	" Returns line split by cursor, before and after
	if a:0 > 0
		let line = a:1
	else
		let line = getline('.')
	endif
	if a:0 > 1
		let colnum = a:2
	else
		let colnum = col('.')
	endif
	if colnum <= 1
		let before = ''
		let after = line
	elseif colnum == col('$')
		let before = line
		let after = ''
	else
		let before = line[:colnum - 2]
		let after = line[colnum - 1:]
	endif
	return [before, after]
endfun

fun! organ#utils#delete (first, ...)
	" Delete lines to black hole register
	let first = a:first
	if &modifiable == 0
		echomsg 'organ utils delete : modifiable is off'
		return 0
	endif
	if a:0 > 0
		let last = a:1
	else
		let last = first
	endif
	if exists('*deletebufline')
		return deletebufline('%', first, last)
	else
		" delete lines -> underscore _ = no storing register
		let range = first .. ',' .. last
		execute 'silent!' range .. 'delete _'
		return 0
	endif
endfun

" ---- functional

fun! organ#utils#call (function, ...)
	" Call function depicted as a Funcref or a string
	" Optional arguments are passed to Fun
	if empty(a:function)
		return v:false
	endif
	let arguments = a:000
	let Fun = a:function
	let kind = type(Fun)
	if kind == v:t_func
		if empty(arguments)
			" form : Fun = function('name') without argument
			return Fun()
		else
			" form : Fun = function('name') with arguments
			return call(Fun, arguments)
		endif
	elseif kind == v:t_string
		if Fun =~ '\m)$'
			" form : Fun = 'function(...)'
			" a:000 of organ#metafun#call is ignored
			return eval(Fun)
			" works, but less elegant
			"execute 'let value =' Fun
		elseif empty(arguments)
			" form : Fun = 'function' without argument
			return {Fun}()
		else
			" form : Fun = 'function' with arguments
			return call(Fun, arguments)
		endif
	else
		echomsg 'organ gear call : bad argument'
		" likely not a representation of a function
		" simply forward concatened arguments
		return [Fun] + arguments
	endif
endfun
