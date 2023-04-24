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

" ---- helpers

fun! organ#pipe#extensions (output_format)
	" Input and output file extensions
	let output_format = a:output_format
	let input_extension = '\.' .. bufname('%')->fnamemodify(':e')
	let output_extension = '\.' .. output_format
	if output_format == 'markdown'
		let output_extension = '\.md'
	endif
	return [input_extension, output_extension]
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
	let input = bufname('%')
	let [input_ext, output_ext] = organ#pipe#extensions (output_format)
	let output = substitute(input, input_ext, output_ext, '')
	let command = 'pandoc -f '
	let command ..= &filetype .. ' '
	let command ..= '-t ' .. output_format .. ' '
	let command ..= input .. ' >' .. output
	call system(command)
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
	let input = bufname('%')
	let [input_ext, output_ext] = organ#pipe#extensions (output_format)
	let emacs_fun = s:emacs_functions[output_format]
	let command = 'emacs ' .. input .. ' '
	let command ..= '--batch -f ' .. emacs_fun .. ' --kill'
	call system(command)
	return command
endfun