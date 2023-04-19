" vim: set ft=vim fdm=indent iskeyword&:

" Geode
"
" Internal Constants for plugs & maps

" ---- plugs

if ! exists('s:plugs_normal')
	let s:plugs_normal = [
		\ ]
	lockvar! s:plugs_normal
endif

if ! exists('s:plugs_visual')
	let s:plugs_visual = [
				\ ]
	lockvar! s:plugs_visual
endif

if ! exists('s:plugs_insert')
	let s:plugs_insert = [
		\ [ 'organ-tree-promote'   , 'organ#tree#promote'  ] ,
		\ ]
	lockvar! s:plugs_insert
endif

" ---- maps

if ! exists('s:maps_normal')
	let s:maps_normal = [
		\ ]
	lockvar! s:maps_normal
endif

if ! exists('s:maps_visual')
	let s:maps_visual = [
		\ ]
	lockvar! s:maps_visual
endif

if ! exists('s:maps_insert')
	let s:maps_insert = [
		\ [ '<m-left>'        , 'organ-tree-promote'  ] ,
		\ ]
	lockvar! s:maps_insert
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
	if conversion ==# 'dict' && organ#utils#is_nested_list ({varname})
		return organ#utils#items2dict ({varname})
	else
		return {varname}
	endif
endfun
