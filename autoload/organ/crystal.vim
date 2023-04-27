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

" ---- structure templates

if ! exists('s:templates_languages')
	let s:templates_languages = [
				\ 'F90',
				\ 'c',
				\ 'cpp',
				\ 'clojure',
				\ 'css',
				\ 'd',
				\ 'emacs-lisp',
				\ 'eshell',
				\ 'java',
				\ 'latex',
				\ 'lisp',
				\ 'lua',
				\ 'ly',
				\ 'makefile',
				\ 'ocaml',
				\ 'org',
				\ 'perl',
				\ 'python',
				\ 'r',
				\ 'ruby',
				\ 'scheme',
				\ 'sql',
				\ 'sed',
				\ 'shell',
				\]
	lockvar! s:templates_languages
endif

" ---- links

if ! exists('s:url_prefixes')
	let s:url_prefixes = [
		\ 'bibtex:',
		\ 'docview:',
		\ 'elisp:',
		\ 'eww:',
		\ 'file:',
		\ 'file+emacs:',
		\ 'file+sys:',
		\ 'ftp:',
		\ 'help:',
		\ 'http:',
		\ 'https:',
		\ 'info:',
		\ 'irc:',
		\ 'mailto:',
		\ 'news:',
		\ 'rmail:',
		\ 'shell:',
		\]
	lockvar! s:url_prefixes
endif

" ---- export formats

if ! exists('s:export_formats_pandoc')
	let s:export_formats_pandoc = [
				\ 'asciidoc',
				\ 'beamer',
				\ 'bibtex',
				\ 'biblatex',
				\ 'chunkedhtml',
				\ 'commonmark',
				\ 'commonmark_x',
				\ 'context',
				\ 'csljson',
				\ 'docbook',
				\ 'docx',
				\ 'dokuwiki',
				\ 'epub',
				\ 'fb2',
				\ 'gfm',
				\ 'haddock',
				\ 'html',
				\ 'icml',
				\ 'ipynb',
				\ 'jats',
				\ 'jira',
				\ 'json',
				\ 'latex',
				\ 'man',
				\ 'markdown',
				\ 'markua',
				\ 'mediawiki',
				\ 'ms',
				\ 'muse',
				\ 'native',
				\ 'odt',
				\ 'opml',
				\ 'opendocument',
				\ 'org',
				\ 'pdf',
				\ 'plain',
				\ 'pptx',
				\ 'rst',
				\ 'rtf',
				\ 'texinfo',
				\ 'textile',
				\ 'slideous',
				\ 'slidy',
				\ 'dzslides',
				\ 'revealjs',
				\ 's5',
				\ 'tei',
				\ 'xwiki',
				\ 'zimwiki',
				\]
	lockvar! s:export_formats_pandoc
endif

if ! exists('s:export_functions_emacs')
	let s:export_functions_emacs = [
				\ ['ascii', 'org-ascii-export-to-ascii'],
				\ ['html', 'org-html-export-to-html'],
				\ ['latex', 'org-latex-export-to-latex'],
				\ ['markdown', 'org-md-export-to-markdown'],
				\ ['pdf', 'org-latex-export-to-pdf'],
				\]
	lockvar! s:export_functions_emacs
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
