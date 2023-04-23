" vim: set ft=vim fdm=indent iskeyword&:

" Pipe
"
" Export to other file formats
" Use Emacs in batch mode

fun! organ#pipe#pandoc_export (output_format)
	" Export current file to output_format
	let output_format = a:output_format
	let input = bufname('%')
	if &filetype == 'org'
		let inpext = '\.org'
	elseif &filetype == 'markdown'
		let inpext = '\.md'
	endif
	let outext = '\.' .. output_format
	if output_format == 'markdown'
		let outext = '\.md'
	endif
	let output = substitute(input, inpext, outext, '')
	let command = 'pandoc -f '
	let command ..= &filetype .. ' '
	let command ..= '-t ' .. output_format .. ' '
	let command ..= input .. ' >' .. output
	call system(command)
	return command
endfun
