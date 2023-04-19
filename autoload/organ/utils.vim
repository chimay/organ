" vim: set ft=vim fdm=indent iskeyword&:

" Utils
"
" Small tools

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
