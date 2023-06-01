" vim: set ft=vim fdm=indent iskeyword&:

" Void
"
" Initialization of variables

" ---- generic

fun! organ#void#stops ()
	" Initialize persistent data global var
	if ! exists('g:ORGAN_STOPS')
		let g:ORGAN_STOPS = {}
	endif
	if ! has_key(g:ORGAN_STOPS, 'urls')
		let g:ORGAN_STOPS.urls = []
	endif
	if ! has_key(g:ORGAN_STOPS, 'expr')
		let g:ORGAN_STOPS.expr = #{ vim : [], python : [] }
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
		let g:organ_config.previous = '<M-p>'
	endif
	if ! has_key(g:organ_config, 'prefix')
		let g:organ_config.prefix = '<M-o>'
	endif
	if ! has_key(g:organ_config, 'prefixless')
		let g:organ_config.prefixless = 0
	endif
	if ! has_key(g:organ_config, 'prefixless_modes')
		let g:organ_config.prefixless_modes = ['normal', 'visual', 'insert']
	endif
	if ! has_key(g:organ_config, 'prefixless_plugs')
		let g:organ_config.prefixless_plugs = #{ normal : [], visual : [], insert : [] }
	endif
	if ! has_key(g:organ_config, 'todo_cycle')
		let g:organ_config.todo_cycle = ['TODO', 'DONE']
	endif
	if ! has_key(g:organ_config, 'timestamp_format')
		let g:organ_config.timestamp_format = '<%Y-%m-%d %a %H:%M>'
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
	if ! has_key(g:organ_config.list.unordered, 'asciidoc')
		let g:organ_config.list.unordered.asciidoc = [
			\ '-',
			\ '+',
			\ '*',
			\ '--',
			\ '++',
			\ '**',
			\ '---',
			\ '+++',
			\ '***',
			\ ]
	endif
	if ! has_key(g:organ_config.list.unordered, 'vimwiki')
		let g:organ_config.list.unordered.vimwiki = ['-', '+', '*']
	endif
	" -- ordered chars
	if ! has_key(g:organ_config.list, 'counter_start')
		" must be >= 0
		let g:organ_config.list.counter_start = 1
	endif
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
	if ! has_key(g:organ_config.list.ordered, 'asciidoc')
		let g:organ_config.list.ordered.asciidoc = [
			\ '.',
			\ '..',
			\ '...',
			\ '....',
			\ '.....',
			\ '......',
			\ '.......',
			\ '........',
			\ '.........',
			\ ]
	endif
	if ! has_key(g:organ_config.list.ordered, 'vimwiki')
		let g:organ_config.list.ordered.vimwiki = ['.', ')']
	endif
	" ---- links
	if ! has_key(g:organ_config, 'links')
		let g:organ_config.links = {}
	endif
	if ! has_key(g:organ_config.links, 'keep')
		let g:organ_config.links.keep = 5
	endif
	" ---- structure templates
	if ! has_key(g:organ_config, 'templates')
		let g:organ_config.templates = {}
	endif
	" ---- expressions
	if ! has_key(g:organ_config, 'expr')
		let g:organ_config.expr = {}
	endif
	if ! has_key(g:organ_config.expr, 'keep')
		let g:organ_config.expr.keep = 30
	endif
	" ---- completion
	if ! has_key(g:organ_config, 'completion')
		let g:organ_config.completion = {}
	endif
	if ! has_key(g:organ_config.completion, 'vocalize')
		let g:organ_config.completion.vocalize = 0
	endif
	if ! has_key(g:organ_config.completion, 'wordize')
		let g:organ_config.completion.wordize = 0
	endif
	if ! has_key(g:organ_config.completion, 'fuzzy')
		let g:organ_config.completion.fuzzy = 0
	endif
endfun

fun! organ#void#foundation ()
	" Initialize organ
	call organ#void#stops ()
	call organ#void#config ()
endfun

fun! organ#void#standardize ()
	" Standardize config variables
	" ---- prefixless plugs to be mapped
	let plugs = g:organ_config.prefixless_plugs
	if type(plugs) == v:t_list || empty(plugs)
		let plugs = {}
		let plugs.normal = copy(g:organ_config.prefixless_plugs)
		let plugs.visual = copy(g:organ_config.prefixless_plugs)
		let plugs.insert = copy(g:organ_config.prefixless_plugs)
		let g:organ_config.prefixless_plugs = plugs
	endif
endfun

fun! organ#void#enable ()
	" Enable maps
	" To be used on filetype triggers
	call organ#void#standardize ()
	call organ#centre#cables ()
endfun

fun! organ#void#init ()
	" Main init function
	call organ#void#foundation ()
	call organ#centre#commands ()
	call organ#centre#plugs ()
	let everywhere = g:organ_config.everywhere
	if everywhere > 0
		call organ#void#enable ()
	endif
endfun
