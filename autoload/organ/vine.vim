" vim: set ft=vim fdm=indent iskeyword&:

" Vine
"
" Link management

" ---- script constants

if ! exists('s:rep_one_char')
	let s:rep_one_char = organ#crystal#fetch('filetypes/repeated_one_char_heading')
	lockvar s:rep_one_char
endif

" ---- helpers

fun! organ#vine#template (url, desc = '')
	" Link template
	let url = a:url
	let desc = a:desc
	if &filetype ==# 'org'
		if empty(desc)
			let link = '[[' .. url .. ']]'
		else
			let link = '[[' .. url .. '][' .. desc .. ']]'
		endif
	elseif &filetype ==# 'markdown'
		if empty(desc)
			let link = '<' .. url .. '>'
		else
			let link = '[' .. desc .. '](' .. url .. ')'
		endif
	endif
	let link ..= ' '
	return link
endfun

" ---- store url dict

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
	let store = g:ORGAN_STOPS.urls
	if store->index(url) < 0
		eval store->insert(url)
		let keep = g:organ_config.links.keep
		if keep > 0
			let store = store[:keep - 1]
		endif
		echomsg 'organ: stored' url
	else
		echomsg 'organ: url already stored'
	endif
	let g:ORGAN_STOPS.urls = store
	return url
endfun

" ---- new

fun! organ#vine#new ()
	" Create new link
	if s:rep_one_char->index(&filetype) < 0
		echomsg 'organ vine template : filetype not supported'
		return ''
	endif
	let position = getcurpos ()
	let linum = position[1]
	let colnum = position[2]
	let line = getline(linum)
	if colnum <= 1
		let before = ''
		let after = line
	elseif colnum == col('$')
		let before = line
		let after = ''
	else
		let before = line[:colnum - 2]
		let after = line[colnum - 1:]
	endif
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

" ---- convert org <-> markdown

fun! organ#vine#org2markdown ()
	" Convert org links to markdown
	" ---- links without description
	silent! %substitute/\[\[\([^]]\+\)\]\]/<\1>/g
	" ---- links with description
	silent! %substitute/\[\[\([^]]\+\)\]\[\([^]]\+\)\]\]/[\2](\1)/g
endfun

fun! organ#vine#markdown2org ()
	" Convert markdown links to org
	" ---- links without description
	silent! %substitute/<\([^>]*[^/]\)>/[[\1]]/g
	" ---- links with description
	silent! %substitute/\[\([^]]\+\)\](\([^)]\+\))/[[\2][\1]]/g
endfun
