" vim: set ft=vim fdm=indent iskeyword&:

" Vine
"
" Link management

" ---- helpers

fun! organ#vine#template (url, desc = '')
	" Link template
	let url = a:url
	let desc = a:desc
	if &filetype == 'org'
		if empty(desc)
			let link = '[[' .. url .. ']]'
		else
			let link = '[[' .. url .. '][' .. desc .. ']]'
		endif
	elseif &filetype == 'markdown'
		if empty(desc)
			let link = '<' .. url .. '>'
		else
			let link = '[' .. desc .. '](' .. url .. ')'
		endif
	endif
	let link ..= ' '
	return link
endfun

" ---- store url

fun! organ#vine#store ()
	" Store org url at current position
	let properties = organ#bird#properties ()
	let linum = properties.linum
	let iden = ''
	let last_linum = line('$')
	if linum + 2 <= last_linum
		let next_line = getline(linum + 1)
		if next_line =~ '\m\c^:properties:'
			let iden_line = getline(linum + 2)
			let prefix = '\m\c:custom_id: '
			let iden = substitute(iden_line, prefix, '', '')
		endif
	endif
	let bufname = bufname(bufnr('%'))
	let file = fnamemodify(bufname, ':t')
	let url = 'file:'
	let url ..= file
	let url ..= '::'
	if empty(iden)
		let url ..= '*' .. properties.title
	else
		let url ..= '#' .. iden
	endif
	let store = g:organ_store.url
	if store->index(url) < 0
		eval store->add(url)
		let store = store[:12]
	endif
	return url
endfun

" ---- new

fun! organ#vine#new ()
	" Create new link
	let position = getcurpos ()
	let linum = position[1]
	let colnum = position[2]
	let line = getline(linum)
	if colnum <= 1
		let before = ''
	else
		let before = line[:colnum - 2]
	endif
	let after = line[colnum - 1:]
	let prompt = 'Link url : '
	let complete = 'customlist,organ#complete#url'
	let url = input(prompt, '', complete)
	let prompt = 'Link description : '
	let desc = input(prompt)
	let link = organ#vine#template (url, desc)
	let lenlink = len(link)
	let newline = before .. link .. after
	call setline(linum, newline)
	let colnum += lenlink
	call cursor(linum, colnum)
endfun
