" vim: set ft=vim fdm=indent iskeyword&:

" Geode
"
" Internal Constants for plugs & maps

" ---- plugs

if ! exists('s:plugs_normal')
	let s:plugs_normal = [
		\ [ 'organ-tree-promote'   , 'organ#tree#promote'  ] ,
		\ ]
	lockvar! s:plugs_normal
endif

" ---- maps

if ! exists('s:maps_level_0_normal')
	let s:maps_level_0_normal = [
		\ [ '<m-left>'        , 'organ-tree-promote'  ] ,
		\ ]
	lockvar! s:maps_level_0_normal
endif

" ---- public interface

fun! organ#geode#fetch (varname, conversion = 'no-conversion')
	" Return script variable called varname
	" The leading s: can be omitted
	" Optional argument :
	"   - no-conversion : simply returns the asked variable, dont convert anything
	"   - dict : if varname points to an items list, convert it to a dictionary
	let varname = a:varname
	let conversion = a:conversion
	" ---- variable name
	let varname = substitute(varname, '/', '_', 'g')
	let varname = substitute(varname, '-', '_', 'g')
	let varname = substitute(varname, ' ', '_', 'g')
	if varname !~ '\m^s:'
		let varname = 's:' .. varname
	endif
	" ---- raw or conversion
	if conversion ==# 'dict' && wheel#matrix#is_nested_list ({varname})
		return wheel#matrix#items2dict ({varname})
	else
		return {varname}
	endif
endfun
