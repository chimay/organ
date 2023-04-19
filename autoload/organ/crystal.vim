" vim: set ft=vim fdm=indent iskeyword&:

" Crystal
"
" Internal Constants made crystal clear

if ! exists('s:plain_list_line_pattern')
	let s:plain_list_line_pattern = '^\s*[-+]\|^\s\+\*\|^\s*[0-9]\+[.)]'
	lockvar! s:plain_list_line_pattern
endif

if ! exists('s:plain_list_unordered_prefixes')
	let s:plain_list_unordered_prefixes = ['-', '+', '*']
	lockvar! s:plain_list_unordered_prefixes
endif

if ! exists('s:plain_list_ordered_prefixes_patterns')
	let s:plain_list_ordered_prefixes_patterns = ['[0-9]\+.', '[0-9]\+)']
	lockvar! s:plain_list_ordered_prefixes_patterns
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
