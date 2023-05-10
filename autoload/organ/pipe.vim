" vim: set ft=vim fdm=indent iskeyword&:

" Pipe
"
" Export to other file formats
" Use Emacs in batch mode

" ---- constants

if ! exists('s:pandoc_formats')
	let s:pandoc_formats = organ#crystal#fetch('export/formats/pandoc')
	lockvar s:pandoc_formats
endif

if ! exists('s:emacs_functions')
	let s:emacs_functions = organ#crystal#fetch('export/functions/emacs', 'dict')
	lockvar s:emacs_functions
endif

if ! exists('s:emacs_formats')
	let s:emacs_formats = keys(s:emacs_functions)
	lockvar s:emacs_formats
endif

if ! exists('s:asciidoc_formats')
	let s:asciidoc_formats = organ#crystal#fetch('export/formats/asciidoc')
	lockvar s:asciidoc_formats
endif

if ! exists('s:asciidoctor_formats')
	let s:asciidoctor_formats = organ#crystal#fetch('export/formats/asciidoctor')
	lockvar s:asciidoctor_formats
endif

" ---- helpers

fun! organ#pipe#extensions (output_format)
	" Input and output file extensions
	let output_format = a:output_format
	let input_extension = '\.' .. expand('%:e')
	let output_extension = '\.' .. output_format
	if output_format ==# 'markdown'
		let output_extension = '\.md'
	endif
	return [input_extension, output_extension]
endfun

" ---- open exported document

fun! organ#pipe#open (document)
	" Open exported document
	let document = a:document
	" ---- needs unix
	if ! has('unix')
		return -1
	endif
	" ---- already opened ?
	let psgrep = 'ps auxww | grep -v grep | grep ' .. document
	let grep = system(psgrep)
	if v:shell_error == 0
		return v:shell_error
	endif
	" ---- ask
	let prompt = 'Open exported document ?'
	let confirm = confirm(prompt, "&Yes\n&No", 2)
	if confirm != 1
		return -1
	endif
	" ---- open
	let open = 'xdg-open ' .. document .. '&'
	let output = system(open)
	return v:shell_error
endfun

" ---- export

fun! organ#pipe#pandoc_export (...)
	" Export current file to output_format, using pandoc
	if ! executable('pandoc')
		echomsg 'organ pipe pandoc export : executable not found'
	endif
	if a:0 > 0
		let output_format = a:1
	else
		let prompt = 'Export format (pandoc) : '
		let complete = 'customlist,organ#complete#pandoc_formats'
		let output_format = input(prompt, '', complete)
	endif
	if s:pandoc_formats->index(output_format) < 0
		echomsg 'organ pipe pandoc export : format not supported'
		return v:false
	endif
	let input = expand('%')
	let [input_ext, output_ext] = organ#pipe#extensions (output_format)
	let output = substitute(input, input_ext, output_ext, '')
	let command = 'pandoc -f '
	let command ..= &filetype .. ' '
	let command ..= '-t ' .. output_format .. ' '
	let command ..= input .. ' >' .. output
	call system(command)
	let code = organ#pipe#open (output)
	return command
endfun

fun! organ#pipe#emacs_export (...)
	" Export current file to output_format, using emacs
	if ! executable('emacs')
		echomsg 'organ pipe emacs export : executable not found'
	endif
	if a:0 > 0
		let output_format = a:1
	else
		let prompt = 'Export format (emacs) : '
		let complete = 'customlist,organ#complete#emacs_formats'
		let output_format = input(prompt, '', complete)
	endif
	if s:emacs_formats->index(output_format) < 0
		echomsg 'organ pipe emacs export : format not supported'
		return v:false
	endif
	let input = expand('%')
	let [input_ext, output_ext] = organ#pipe#extensions (output_format)
	let emacs_fun = s:emacs_functions[output_format]
	let command = 'emacs ' .. input .. ' '
	let command ..= '--batch -f ' .. emacs_fun .. ' --kill'
	call system(command)
	call organ#pipe#open (output)
	return command
endfun

fun! organ#pipe#asciidoc_export (...)
	" Export current file to output_format, using asciidoc
	if ! executable('asciidoc')
		echomsg 'organ pipe asciidoc export : executable not found'
	endif
	if a:0 > 0
		let output_format = a:1
	else
		let prompt = 'Export format (asciidoc) : '
		let complete = 'customlist,organ#complete#asciidoc_formats'
		let output_format = input(prompt, '', complete)
	endif
	if s:asciidoc_formats->index(output_format) < 0
		echomsg 'organ pipe asciidoc export : format not supported'
		return v:false
	endif
	let input = expand('%')
	let command = 'asciidoc -b ' .. output_format .. ' ' .. input
	call system(command)
	call organ#pipe#open (output)
	return command
endfun

fun! organ#pipe#asciidoctor_export (...)
	" Export current file to output_format, using asciidoctor
	if ! executable('asciidoctor')
		echomsg 'organ pipe asciidoctor export : executable not found'
	endif
	if a:0 > 0
		let output_format = a:1
	else
		let prompt = 'Export format (asciidoctor) : '
		let complete = 'customlist,organ#complete#asciidoctor_formats'
		let output_format = input(prompt, '', complete)
	endif
	if s:asciidoctor_formats->index(output_format) < 0
		echomsg 'organ pipe asciidoctor export : format not supported'
		return v:false
	endif
	let input = expand('%')
	let command = 'asciidoctor -b ' .. output_format .. ' ' .. input
	call system(command)
	call organ#pipe#open (output)
	return command
endfun
