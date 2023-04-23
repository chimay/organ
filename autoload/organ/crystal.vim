" vim: set ft=vim fdm=indent iskeyword&:

" Crystal
"
" Internal Constants made crystal clear

" ---- separators

if ! exists('s:separator_level')
	let s:separator_level = ' ⧽ '
	lockvar! s:separator_level
endif

if ! exists('s:separator_field')
	let s:separator_field = ' │ '
	" digraph : in insert mode : ctrl-k vv -> │ != usual | == <bar>
	lockvar! s:separator_field
endif

if ! exists('s:separator_field_bar')
	let s:separator_field_bar = '│'
	" digraph : ctrl-k vv ->
	lockvar! s:separator_field_bar
endif

" ---- patterns

if ! exists('s:plain_list_line_pattern')
	let s:plain_list_line_pattern = '^\s*[-+]\|^\s\+\*\|^\s*[0-9]\+[.)]'
	lockvar! s:plain_list_line_pattern
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
	if conversion ==# 'dict'
		return organ#utils#items2dict ({varname})
	else
		return {varname}
	endif
endfun
