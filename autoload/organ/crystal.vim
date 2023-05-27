" vim: set ft=vim fdm=indent iskeyword&:

" Crystal
"
" Internal Constants made crystal clear

" ---- golden ratio

if exists('s:golden_ratio')
	unlockvar! s:golden_ratio
endif
let s:golden_ratio = 1.618034
"let s:golden_ratio = (1 + sqrt(5)) / 2
lockvar! s:golden_ratio

" ---- patterns

if exists('s:pattern_indent')
	unlockvar! s:pattern_indent
endif
let s:pattern_indent = '\m^\s*'
lockvar! s:pattern_indent

if exists('s:pattern_line_hollow')
	unlockvar! s:pattern_line_hollow
endif
let s:pattern_line_hollow = '\m^\s*$'
lockvar! s:pattern_line_hollow

if exists('s:pattern_angle')
	unlockvar! s:pattern_angle
endif
let s:pattern_angle = '\m<[^>]\+>'
lockvar! s:pattern_angle

if exists('s:pattern_headline_tag')
	unlockvar! s:pattern_headline_tag
endif
let s:pattern_headline_tag = '\m:\%([^:]\+:\)\+'
lockvar! s:pattern_headline_tag

if exists('s:pattern_vowels')
	unlockvar! s:pattern_vowels
endif
let s:pattern_vowels = '[[=a=][=e=][=i=][=o=][=u=][=y=]]'
lockvar! s:pattern_vowels

" ---- maximum heading or list item level

if exists('s:maximum_level')
	unlockvar! s:maximum_level
endif
let s:maximum_level = 30
lockvar! s:maximum_level

" ---- filetypes with repeated one char heading

if exists('s:filetypes_heading_char')
	unlockvar! s:filetypes_heading_char
endif
let s:filetypes_heading_char = [
	\ ['org', '*'],
	\ ['markdown', '#'],
	\ ['asciidoc', '='],
	\ ['vimwiki', '='],
	\]
lockvar! s:filetypes_heading_char

if exists('s:filetypes_repeated_one_char_heading')
	unlockvar! s:filetypes_repeated_one_char_heading
endif
let s:filetypes_repeated_one_char_heading = deepcopy(s:filetypes_heading_char)->map({ _, v -> v[0] })
lockvar! s:filetypes_repeated_one_char_heading

" ---- separators

if exists('s:separator_level')
	unlockvar! s:separator_level
endif
let s:separator_level = ' ⧽ '
lockvar! s:separator_level

if exists('s:separator_field')
	unlockvar! s:separator_field
endif
let s:separator_field = ' │ '
lockvar! s:separator_field

if exists('s:separator_field_bar')
	unlockvar! s:separator_field_bar
endif
" digraph : in insert mode : ctrl-k vv -> │ != usual | == <bar>
let s:separator_field_bar = '│'
lockvar! s:separator_field_bar

" ---- structure templates

if exists('s:templates_languages')
	unlockvar! s:templates_languages
endif
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

" ---- links

if exists('s:url_prefixes')
	unlockvar! s:url_prefixes
endif
let s:url_prefixes = [
	\ 'bibtex:',
	\ 'docview:',
	\ 'elisp:',
	\ 'eww:',
	\ 'file:',
	\ 'file+emacs:',
	\ 'file+sys:',
	\ 'ftp://',
	\ 'help:',
	\ 'http://',
	\ 'https://',
	\ 'info:',
	\ 'irc:',
	\ 'mailto:',
	\ 'news:',
	\ 'rmail:',
	\ 'shell:',
	\]
lockvar! s:url_prefixes

" ---- export formats

if exists('s:export_formats_pandoc')
	unlockvar! s:export_formats_pandoc
endif
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

if exists('s:export_functions_emacs')
unlockvar! s:export_functions_emacs
endif
let s:export_functions_emacs = [
	\ ['ascii', 'org-ascii-export-to-ascii'],
	\ ['html', 'org-html-export-to-html'],
	\ ['latex', 'org-latex-export-to-latex'],
	\ ['markdown', 'org-md-export-to-markdown'],
	\ ['pdf', 'org-latex-export-to-pdf'],
	\]
lockvar! s:export_functions_emacs

if exists('s:export_formats_asciidoc')
	unlockvar! s:export_formats_asciidoc
endif
let s:export_formats_asciidoc = [
	\ 'docbook45',
	\ 'docbook5',
	\ 'xhtml11',
	\ 'html4',
	\ 'html5',
	\ 'slidy',
	\ 'wordpress',
	\ 'latex',
	\]
lockvar! s:export_formats_asciidoc

if exists('s:export_formats_asciidoctor')
	unlockvar! s:export_formats_asciidoctor
endif
let s:export_formats_asciidoctor = [
	\ 'docbook45',
	\ 'docbook',
	\ 'docbook5',
	\ 'xhtml11',
	\ 'html',
	\ 'html4',
	\ 'html5',
	\ 'manpage',
	\ 'slidy',
	\ 'wordpress',
	\ 'latex',
	\]
lockvar! s:export_formats_asciidoctor

" ---- waterproof functions in indent headline files

if exists('s:waterproof_indent')
	unlockvar! s:waterproof_indent
endif
let s:waterproof_indent = [
	\ 'select_subtree',
	\ 'yank_subtree',
	\ 'delete_subtree',
	\ 'promote_subtree',
	\ 'demote_subtree',
	\]
lockvar! s:waterproof_indent

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
