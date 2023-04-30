" vim: set ft=vim fdm=indent iskeyword&:

" Void
"
" Initialization of variables

fun! organ#void#store ()
	" Initialize store
	if ! exists('g:organ_store')
		let g:organ_store = {}
	endif
	if ! has_key(g:organ_store, 'url')
		let g:organ_store.url = []
	endif
endfun

fun! organ#void#config ()
	" Initialize config
	if ! exists('g:organ_config')
		let g:organ_config = {}
	endif
	" ---- generic
	if ! has_key(g:organ_config, 'everywhere')
		let g:organ_config.everywhere = 0
	endif
	if ! has_key(g:organ_config, 'speedkeys')
		let g:organ_config.speedkeys = 0
	endif
	if ! has_key(g:organ_config, 'previous')
		let g:organ_config.prefix = '<M-p>'
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
	" ---- list
	if ! has_key(g:organ_config, 'list')
		let g:organ_config.list = {}
	endif
	if ! has_key(g:organ_config.list, 'indent_length')
		let g:organ_config.list.indent_length = 2
	endif
	" -- unordered chars
	if ! has_key(g:organ_config.list, 'unordered')
		let g:organ_config.list.unordered = {}
	endif
	if ! has_key(g:organ_config.list.unordered, 'default')
		let g:organ_config.list.unordered.default = ['-', '+', '*']
	endif
	if ! has_key(g:organ_config.list.unordered, 'org')
		let g:organ_config.list.unordered.org = ['-', '+', '*']
	endif
	if ! has_key(g:organ_config.list.unordered, 'markdown')
		let g:organ_config.list.unordered.markdown = ['-', '+']
	endif
	" -- ordered chars
	if ! has_key(g:organ_config.list, 'ordered')
		let g:organ_config.list.ordered = {}
	endif
	if ! has_key(g:organ_config.list.ordered, 'default')
		let g:organ_config.list.ordered.default = ['.', ')']
	endif
	if ! has_key(g:organ_config.list.ordered, 'org')
		let g:organ_config.list.ordered.org = ['.', ')']
	endif
	if ! has_key(g:organ_config.list.ordered, 'markdown')
		let g:organ_config.list.ordered.markdown = ['.']
	endif
	if ! has_key(g:organ_config.list, 'counter_start')
		let g:organ_config.list.counter_start = 1
	endif
	" ---- structure templates
	if ! has_key(g:organ_config, 'templates')
		let g:organ_config.templates = {
					\ '<C' : 'comment',
					\ '<E' : 'export',
					\ '<c' : 'center',
					\ '<e' : 'example',
					\ '<q' : 'quote',
					\ '<s' : 'src',
					\ '<v' : 'verse',
					\ '+A' : 'author',
					\ '+E' : 'email',
					\ '+I' : 'index',
					\ '+T' : 'toc',
					\ '+i' : 'include',
					\ '+h' : 'html',
					\ '+l' : 'latex',
					\ '+o' : 'options',
					\ '+s' : 'startup',
					\ '+t' : 'tags',
					\ ':s' : 'section',
					\}
	endif
endfun

fun! organ#void#foundation ()
	" Initialize organ
	call organ#void#store ()
	call organ#void#config ()
endfun

fun! organ#void#enable ()
	" Enable maps
	" To be used on filetype triggers
	call organ#centre#cables ()
endfun

fun! organ#void#init ()
	" Main init function
	call organ#void#foundation ()
	call organ#centre#commands ()
	call organ#centre#plugs ()
	let everywhere = g:organ_config.everywhere
	if everywhere > 0
		" ---- enable maps
		call organ#centre#cables ()
	endif
endfun
