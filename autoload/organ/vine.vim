" vim: set ft=vim fdm=indent iskeyword&:

" Vine
"
" Link management

" ---- script constants

if exists('s:rep_one_char')
	unlockvar s:rep_one_char
endif
let s:rep_one_char = organ#crystal#fetch('filetypes/repeated_one_char_heading')
lockvar s:rep_one_char

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

fun! organ#vine#relative (target)
	" Relative path to file target
	let target = a:target
	" ---- current file
	let current = expand('%:p')
	" ---- find common dir base
	let target_list = split(target, '/')
	let current_list = split(current, '/')
	let length = len(target_list)
	let index = -1
	while v:true
		if index >= length - 2
			break
		endif
		if target_list[:index + 1] != current_list[:index + 1]
			break
		endif
		let index += 1
	endwhile
	if index < 0
		let common = []
	elseif index == length
		let common = target_list
	else
		let common = target_list[:index]
	endif
	let target_list = target_list[index + 1:]
	let target = join(target_list, '/')
	let current_list = current_list[index + 1:]
	let numparents = len(current_list) - 1
	let parents = repeat('../', numparents)
	let target = parents .. target
	return target
endfun

fun! organ#vine#generic_pattern ()
	" Generic link pattern
	if &filetype ==# 'org'
		let pattern = '\m\[\[[^\]]\+\]\]\|'
		let pattern ..= '\[\[[^\]]\+\]\[[^\]]\+\]\]'
	elseif &filetype ==# 'markdown'
		let pattern = '\m<[^>]\+>\|'
		let pattern ..= '\[[^\]]\+\]([^)]\+)'
	else
		let pattern = '\m\[\[[^\]]\+\]\]\|'
		let pattern ..= '\[\[[^\]]\+\]\[[^\]]\+\]\]'
	endif
	return pattern
endfun

fun! organ#vine#find ()
	" Find link under or near cursor
	let colindex = col('.') - 1
	let line = getline('.')
	let link_pattern = organ#vine#generic_pattern ()
	" ---- link under cursor ?
	let counter = 1
	while v:true
		let [link, begin, end] = line->matchstrpos(link_pattern, 0, counter)
		if begin == -1
			break
		endif
		if begin <= colindex && colindex <= end
			return link
		endif
		let counter += 1
	endwhile
	" ---- if no link under cursor, just find the closest match on line
	let counter = 1
	let mindist = col('$')
	let closest = ''
	while v:true
		let [link, begin, end] = line->matchstrpos(link_pattern, 0, counter)
		if begin == -1
			break
		endif
		let deltas = [abs(colindex - begin), abs(colindex - end)]
		let dist = min(deltas)
		if dist < mindist
			let closest = link
			let mindist = dist
		endif
		let counter += 1
	endwhile
	return closest
endfun

fun! organ#vine#url (link)
	" Url part of a link
	let link = a:link
	let url = ''
	if &filetype ==# 'org'
		let pattern = '\m\[\[\zs[^\]]\+\ze\]\]'
		let url = link->matchstr(pattern)
		if empty(url)
			let pattern = '\m\[\[\zs[^\]]\+\ze\]\[[^\]]\+\]\]'
			let url = link->matchstr(pattern)
		endif
	elseif &filetype ==# 'markdown'
		let pattern = '\m<\zs[^>]\+\ze>'
		let url = link->matchstr(pattern)
		if empty(url)
			let pattern = '\m\[[^\]]\+\](\zs[^)]\+\ze)'
			let url = link->matchstr(pattern)
		endif
	endif
	return url
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
	let bufname = expand('%')
	let file = fnamemodify(bufname, ':p')
	if empty(iden)
		let section = '*' .. properties.title
	else
		let section = '#' .. iden
	endif
	let url = 'file:' .. file .. '::' .. section
	let urldict = #{
				\ file : file,
				\ section : section,
				\ url : url,
				\}
	let store = g:ORGAN_STOPS.urls
	let listurl = map(deepcopy(store), { _, v -> v.url })
	if listurl->index(url) >= 0
		echomsg 'organ: url already stored'
		return urldict
	endif
	eval store->insert(urldict)
	let keep = g:organ_config.links.keep
	if keep > 0
		let store = store[:keep - 1]
	endif
	echomsg 'organ: stored' url
	let g:ORGAN_STOPS.urls = store
	return url
endfun

" ---- url list, for completion

fun! organ#vine#urlist ()
	" List of urls with absolute & relative path, for completion
	let urls = g:ORGAN_STOPS.urls
	let urlist = []
	for elem in urls
		eval urlist->add(elem.url)
		let file = organ#vine#relative (elem.file)
		let relative_url = 'file:' .. file .. '::' .. elem.section
		eval urlist->add(relative_url)
	endfor
	return urlist
endfun

" ---- new

fun! organ#vine#new ()
	" Create new link
	if s:rep_one_char->index(&filetype) < 0
		echomsg 'organ vine template : filetype not supported'
		return ''
	endif
	let linum = line('.')
	let colnum = col('.')
	let line = getline(linum)
	let [before, after] = organ#utils#line_split_by_cursor (line, colnum)
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

" ---- find next or previous link

fun! organ#vine#previous ()
	" Go to previous link
	let link_pattern = organ#vine#generic_pattern ()
	let flags = organ#utils#search_flags ('backward', 'move', 'wrap')
	let linum = search(link_pattern, flags)
	return linum
endfun

fun! organ#vine#next ()
	" Go to next link
	let link_pattern = organ#vine#generic_pattern ()
	let flags = organ#utils#search_flags ('forward', 'move', 'wrap')
	let linum = search(link_pattern, flags)
	return linum
endfun

" ---- go to link target

fun! organ#vine#goto ()
	" Go to link target
	let link = organ#vine#find ()
	if empty(link)
		echomsg 'organ vine goto : no link under or near cursor'
		return {}
	endif
	let url = organ#vine#url (link)
	" ---- file & dir
	let file = substitute(url, '\m^file:', '', '')
	let file = substitute(file, '\m::[^:]\+$', '', '')
	let file = substitute(file, '\m::#.\+$', '', '')
	let folder = expand('%:p:h')
	" ---- section & iden
	let section = url->matchstr('\m::\zs[^:]\+$')[1:]
	let iden = ''
	if empty(section)
		let file = substitute(file, '\m::#.\+$', '', '')
		let iden = url->matchstr('\m::#\zs.\+$')
	endif
	" ---- go there
	execute 'lcd' folder
	execute 'edit' file
	if ! empty(section)
		call cursor(1, 1)
		let flags = organ#utils#search_flags ('forward', 'move', 'dont-wrap')
		let linum = search(section, flags)
	else
		call cursor(1, 1)
		let flags = organ#utils#search_flags ('forward', 'move', 'dont-wrap')
		let searchme = ':custom_id: ' .. iden
		let linum = search(searchme, flags)
	endif
	normal! zv
	" ---- coda
	let dict = #{
			\ url : url,
			\ file : file,
			\ section : section,
			\ iden : iden,
			\}
	return dict
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
