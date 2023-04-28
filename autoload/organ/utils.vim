" vim: set ft=vim fdm=indent iskeyword&:

" Utils
"
" Small tools

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

fun! organ#utils#search_flags (course = 'forward', move = 'move', wrap = 'wrap')
	" Search flags
	let course = a:course
	let move = a:move
	let wrap = a:wrap
	let flags = ''
	if course ==# 'backward'
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
	return flags
endfun

fun! organ#utils#delete (first, ...)
	" Delete lines to black hole register
	let first = a:first
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
