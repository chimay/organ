" vim: set ft=vim fdm=indent iskeyword&:

" Pipe
"
" Export to other file formats
" Use Emacs in batch mode

fun! organ#pipe#extensions (output_format)
	" Input and output file extensions
	let output_format = a:output_format
	if &filetype == 'org'
		let input_extension = '\.org'
	elseif &filetype == 'markdown'
		let input_extension = '\.md'
	endif
	let output_extension = '\.' .. output_format
	if output_format == 'markdown'
		let output_extension = '\.md'
	endif
	return [input_extension, output_extension]
endfun

fun! organ#pipe#pandoc_export (output_format)
	" Export current file to output_format, using pandoc
	let output_format = a:output_format
	if ! executable('pandoc')
		echomsg 'organ pipe pandoc export : executable not found'
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

fun! organ#pipe#emacs_export (output_format)
	" Export current file to output_format, using emacs
	let output_format = a:output_format
	if ! executable('emacs')
		echomsg 'organ pipe emacs export : executable not found'
	endif
	if output_format == 'html'
		let emacs_fun = 'org-html-export-to-html'
	else
		echomsg 'organ pipe emacs export : output format not supported'
	endif
	let output_format = a:output_format
	let input = bufname('%')
	let [input_ext, output_ext] = organ#pipe#extensions (output_format)
	let output = substitute(input, input_ext, output_ext, '')
	let command = 'emacs ' .. input .. ' '
	let command ..= '--batch -f ' .. emacs_fun .. ' --kill'
	call system(command)
	return command
endfun

fun! organ#pipe#interface ()
	" Export interface
	let prompt = 'Switch to line : '
	let complete = 'customlist,organ#complete#pandoc_formats'
	let record = input(prompt, '', complete)
endfun
