" vim: set ft=vim fdm=indent iskeyword&:

" Vine
"
" Link management

" ---- helpers

fun! organ#vine#template (url, desc = '')
	" Link template
	let url = a:url
	if &filetype == 'org'
		if empty(desc)
			let link = '[[' .. url .. ']]'
		else
			let link = '[[' ... url ... '][' ... desc ... ']]'
		endif
	elseif &filetype == 'markdown'
		if empty(desc)
			let link = '<' .. url .. '>'
		else
			let link = '[[' ... url ... '][' ... desc ... ']]'
		endif
	endif
endfun

" ---- new

fun! organ#vine#create ()
	" Create new link
	let position = getcurpos ()
	let linum = position[1]
	let colnum = position[2]
	let line = getline(linum)
	let before = line[:colnum - 1]
	let after = line[colnum:]
	let prompt = 'Link url : '
	let url = input(prompt)
	let prompt = 'Link description : '
	let desc = input(prompt)
	let link = organ#vine#template (url, desc)
endfun
