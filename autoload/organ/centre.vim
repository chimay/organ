" vim: set ft=vim fdm=indent iskeyword&:

" Centre
"
" Mappings

" ---- script constants

if ! exists('s:speedkeys')
	let s:speedkeys = organ#geode#fetch('speedkeys', 'dict')
	lockvar s:speedkeys
endif

if ! exists('s:normal_plugs')
	let s:normal_plugs = organ#geode#fetch('plugs/normal')
	lockvar s:normal_plugs
endif

if ! exists('s:visual_plugs')
	let s:visual_plugs = organ#geode#fetch('plugs/visual')
	lockvar s:visual_plugs
endif

if ! exists('s:insert_plugs')
	let s:insert_plugs = organ#geode#fetch('plugs/insert')
	lockvar s:insert_plugs
endif

if ! exists('s:normal_maps')
	let s:normal_maps = organ#geode#fetch('maps/normal')
	lockvar s:level_2_normal_maps
endif

if ! exists('s:visual_maps')
	let s:visual_maps = organ#geode#fetch('maps/visual')
	lockvar s:level_2_visual_maps
endif

if ! exists('s:insert_maps')
	let s:insert_maps = organ#geode#fetch('maps/insert')
	lockvar s:level_2_insert_maps
endif

" ---- plugs

fun! organ#centre#plugs ()
	" Link <plug> mappings to organ functions
	" ---- normal maps
	let begin = 'nnoremap  <plug>('
	let middle = ') <cmd>call'
	let end = '<cr>'
	for item in s:normal_plugs
		let left = item[0]
		let right = item[1]
		if right !~ ')$'
			let right ..= '()'
		endif
		execute begin .. left .. middle right .. end
	endfor
	" ---- visual maps
	let begin = 'vnoremap  <plug>('
	" use colon instead of <cmd> to catch the range
	let middle = ') :call'
	for item in s:visual_plugs
		let left = item[0]
		let right = item[1]
		if right !~ ')$'
			let right ..= '()'
		endif
		execute begin .. left .. middle right .. end
	endfor
	" ---- insert maps
	let begin = 'inoremap  <plug>('
	let middle = ') <cmd>call'
	let end = '<cr>'
	for item in s:insert_plugs
		let left = item[0]
		let right = item[1]
		if right !~ ')$'
			let right ..= '()'
		endif
		execute begin .. left .. middle right .. end
	endfor
endfun

" ---- maps

fun! organ#centre#mappings (mode = 'normal')
	" Normal maps of level
	let mode = a:mode
	" ---- mode dependent variables
	let maplist = s:{mode}_maps
	if mode ==# 'normal'
		let mapcmd = 'nmap'
	elseif mode ==# 'visual'
		let mapcmd = 'vmap'
	elseif mode ==# 'insert'
		let mapcmd = 'imap'
	endif
	" -- buffer local maps only
	let mapcmd ..= ' <buffer>'
	" ---- variables
	let prefix = g:organ_config.prefix
	let begin = mapcmd .. ' <silent> ' .. prefix
	let middle = '<plug>('
	let end = ')'
	" ---- loop
	for item in maplist
		let left = item[0]
		let right = item[1]
		execute begin .. left middle .. right .. end
	endfor
endfun

fun! organ#centre#prefixless ()
	" Prefix-less maps
	" ---- normal
	let nmap = 'nmap <buffer> <silent>'
	execute nmap '<m-p>       <plug>(organ-nav-previous)'
	execute nmap '<m-n>       <plug>(organ-nav-next)'
	execute nmap '<m-b>       <plug>(organ-nav-backward)'
	execute nmap '<m-f>       <plug>(organ-nav-forward)'
	execute nmap '<m-u>       <plug>(organ-nav-parent)'
	execute nmap '<m-d>       <plug>(organ-nav-child)'
	execute nmap '<m-left>    <plug>(organ-op-promote)'
	execute nmap '<m-right>   <plug>(organ-op-demote)'
	execute nmap '<m-s-left>  <plug>(organ-op-promote-subtree)'
	execute nmap '<m-s-right> <plug>(organ-op-demote-subtree)'
	" ---- visual
	let vmap = 'vmap <buffer> <silent>'
	" ---- normal
	let imap = 'imap <buffer> <silent>'
	" -- tree
	execute imap '<m-p>       <plug>(organ-nav-previous)'
	execute imap '<m-n>       <plug>(organ-nav-next)'
	execute imap '<m-b>       <plug>(organ-nav-backward)'
	execute imap '<m-f>       <plug>(organ-nav-forward)'
	execute imap '<m-u>       <plug>(organ-nav-parent)'
	execute imap '<m-d>       <plug>(organ-nav-child)'
	execute imap '<m-left>    <plug>(organ-op-promote)'
	execute imap '<m-right>   <plug>(organ-op-demote)'
	execute imap '<m-s-left>  <plug>(organ-op-promote-subtree)'
	execute imap '<m-s-right> <plug>(organ-op-demote-subtree)'
endfun

fun! organ#centre#speedkeys ()
	" Speed keys on headlines first char
	let map = 'nnoremap <buffer>'
	let command = "<cmd>call organ#bird#speed('"
	let close = "')<cr>"
	for key in keys(s:speedkeys)
		execute map key command  .. key .. close
	endfor
endfun

" ---- link plugs & maps

fun! organ#centre#cables ()
	" Link keys to <plug> mappings
	call organ#centre#mappings ()
	call organ#centre#mappings ('visual')
	call organ#centre#mappings ('insert')
	if g:organ_config.prefixless > 0
		call organ#centre#prefixless ()
	endif
	if g:organ_config.speedkeys > 0
		call organ#centre#speedkeys ()
	endif
endfun
