" vim: set ft=vim fdm=indent iskeyword&:

" Crystal
"
" Internal Constants made crystal clear

if ! exists('s:plain_list_line_pattern')
	let s:plain_list_line_pattern = '^\s*[-+]\|^\s\+\*\|^\s*[0-9]\+[.)]'
	lockvar! s:plain_list_line_pattern
endif

if ! exists('s:speedkeys')
	let s:speedkeys = [
				\ 'p', 'n', 'b', 'f', 'u', 'D',
				\ 'h', 'l', 'H', 'L'
				\]
	lockvar! s:speedkeys
endif

" ---- public interface

fun! organ#crystal#fetch (varname, conversion = 'no-conversion')
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
