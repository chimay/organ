" vim: set ft=vim fdm=indent iskeyword&:

" Complete
"
" Completion list functions

" Return entries as list
"
" vim does not filter the entries,
" if needed, it has to be done
" in the function body
"
" Note : kyusu#pour makes a deepcopy of the list before
" processing, no need to do it here

" ---- script constants

if exists('s:src_langs')
	unlockvar s:src_langs
endif
let s:src_langs = organ#crystal#fetch('templates/languages')
lockvar s:src_langs

if exists('s:url_prefixes')
	unlockvar s:url_prefixes
endif
let s:url_prefixes = organ#crystal#fetch('url/prefixes')
lockvar s:url_prefixes

if exists('s:pandoc_formats')
	unlockvar s:pandoc_formats
endif
let s:pandoc_formats = organ#crystal#fetch('export/formats/pandoc')
lockvar s:pandoc_formats

if exists('s:emacs_functions')
	unlockvar s:emacs_functions
endif
let s:emacs_functions = organ#crystal#fetch('export/functions/emacs', 'dict')
lockvar s:emacs_functions

if exists('s:emacs_formats')
	unlockvar s:emacs_formats
endif
let s:emacs_formats = keys(s:emacs_functions)
lockvar s:emacs_formats

if exists('s:asciidoc_formats')
	unlockvar s:asciidoc_formats
endif
let s:asciidoc_formats = organ#crystal#fetch('export/formats/asciidoc')
lockvar s:asciidoc_formats

if exists('s:asciidoctor_formats')
	unlockvar s:asciidoctor_formats
endif
let s:asciidoctor_formats = organ#crystal#fetch('export/formats/asciidoctor')
lockvar s:asciidoctor_formats

if exists('s:subcommands_actions')
	unlockvar s:subcommands_actions
endif
let s:subcommands_actions = organ#diadem#fetch('command/meta/actions')
lockvar s:subcommands_actions

" ---- headlines

fun! organ#complete#headline (arglead, cmdline, cursorpos)
	" Complete full headline path
	let choices = organ#perspective#headlines ()
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

fun! organ#complete#headline_same_level_or_parent (arglead, cmdline, cursorpos)
	" Complete full headline path of current or parent level
	" Used by tree moveto
	let properties = organ#bird#properties ()
	let level = properties.level
	let choices = organ#perspective#headlines (level - 1, level)
	let wordlist = split(a:cmdline)
	let headlines = organ#kyusu#pour(wordlist, choices)
	let current = organ#bird#path ()
	let Matches = function('organ#kyusu#not_current_path', [current])
	eval headlines->filter(Matches)
	return headlines
endfun

" -- tags

fun! organ#complete#tag (arglead, cmdline, cursorpos)
	" Complete tags defined on #+tags & :tag:tag:...:
	let choices = organ#perspective#tags ()
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

" ---- structure templates

fun! organ#complete#templates_lang (arglead, cmdline, cursorpos)
	" Complete language for src bloc
	let choices = s:src_langs
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

" ---- links

fun! organ#complete#url (arglead, cmdline, cursorpos)
	" Complete url for links
	let urls = organ#vine#urlist ()
	" ---- glob(expr, nosuf, list, alllinks)
	let registers = []
	for regname in ['+']
		let regcontent = getreg(regname)
		if ! empty(regcontent)
			eval registers->add(regcontent)
		endif
	endfor
	let tree = glob('**', v:true, v:true)
	eval tree->map({ _, v -> 'file:' .. v })
	let choices = registers + urls + tree + s:url_prefixes
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

" ---- expressions to evaluate

fun! organ#complete#vim_expression (arglead, cmdline, cursorpos)
	" Complete expression
	let choices = g:ORGAN_STOPS.expr.vim
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

fun! organ#complete#python_expression (arglead, cmdline, cursorpos)
	" Complete expression
	let choices = g:ORGAN_STOPS.expr.python
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

" ---- unicode characters

fun! organ#complete#unicode (arglead, cmdline, cursorpos)
	" Complete unicode characters
	let choices = organ#perspective#unicode ()
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

" ---- export

fun! organ#complete#pandoc_formats (arglead, cmdline, cursorpos)
	" Complete supported pandoc output formats
	let choices = s:pandoc_formats
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

fun! organ#complete#emacs_formats (arglead, cmdline, cursorpos)
	" Complete supported emacs/orgmode output formats
	let choices = s:emacs_formats
	echomsg s:emacs_formats
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

fun! organ#complete#asciidoc_formats (arglead, cmdline, cursorpos)
	" Complete supported asciidoc output formats
	let choices = s:asciidoc_formats
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

fun! organ#complete#asciidoctor_formats (arglead, cmdline, cursorpos)
	" Complete supported asciidoctor output formats
	let choices = s:asciidoctor_formats
	let wordlist = split(a:cmdline)
	return organ#kyusu#pour(wordlist, choices)
endfun

" ---- meta command

fun! organ#complete#meta_command (arglead, cmdline, cursorpos)
	" Completion for :Organ meta command
	let cmdline = a:cmdline
	let arglead = a:arglead
	let cursorpos = a:cursorpos
	" ---- words
	let wordlist = split(cmdline)
	let length =  len(wordlist)
	" ---- checks
	if length == 0
		return []
	endif
	if wordlist[0] !=# 'Organ'
		return []
	endif
	" ---- last word
	let last = wordlist[-1]
	let last_list = split(last, '[,;]')
	" ---- cursor after a partial word ?
	let blank = cmdline[cursorpos - 1] =~ '\m\s'
	" ---- subcommand
	let subcommands = organ#utils#items2keys(s:subcommands_actions)
	if length == 1 && blank
		return subcommands
	endif
	if length == 2 && ! blank
		return organ#kyusu#pour(last_list, subcommands)
	endif
	let subcommand = wordlist[1]
	return []
endfun
