" vim: set ft=vim fdm=indent iskeyword&:

" Void
"
" Initialization of variables

fun! organ#void#config ()
	" Initialize config
	if ! exists('g:organ_config')
		let g:organ_config = {}
	endif
	if ! has_key(g:organ_config, 'speedkeys')
		let g:organ_config.speedkeys = 0
	endif
	if ! has_key(g:organ_config, 'prefix')
		let g:organ_config.prefix = '<M-c>'
	endif
	if ! has_key(g:organ_config, 'prefixless')
		let g:organ_config.prefixless = 0
	endif
	if ! has_key(g:organ_config, 'prefixless_modes')
		let g:organ_config.prefixless_modes = ['normal', 'insert']
	endif
	if ! has_key(g:organ_config, 'prefixless_plugs')
		let g:organ_config.prefixless_plugs = []
	endif
	if ! has_key(g:organ_config, 'list_indent_length')
		let g:organ_config.list_indent_length = 2
	endif
endfun
