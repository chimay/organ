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
	let dict = {}
	for [key, val] in a:items
		let dict[key] = val
	endfor
	return dict
endfun
