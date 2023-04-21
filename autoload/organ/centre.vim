" vim: set ft=vim fdm=indent iskeyword&:

" Centre
"
" Mappings

" ---- script constants

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
		exe begin .. left .. middle right .. end
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
		exe begin .. left .. middle right .. end
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
		exe begin .. left .. middle right .. end
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
	exe nmap '<m-p>       <plug>(organ-nav-previous)'
	exe nmap '<m-n>       <plug>(organ-nav-next)'
	exe nmap '<m-b>       <plug>(organ-nav-backward)'
	exe nmap '<m-f>       <plug>(organ-nav-forward)'
	exe nmap '<m-u>       <plug>(organ-nav-parent)'
	exe nmap '<m-d>       <plug>(organ-nav-child)'
	exe nmap '<m-left>    <plug>(organ-op-promote)'
	exe nmap '<m-right>   <plug>(organ-op-demote)'
	exe nmap '<m-s-left>  <plug>(organ-op-promote-subtree)'
	exe nmap '<m-s-right> <plug>(organ-op-demote-subtree)'
	" ---- visual
	let vmap = 'vmap <buffer> <silent>'
	" ---- normal
	let imap = 'imap <buffer> <silent>'
	" -- tree
	exe imap '<m-p>       <plug>(organ-nav-previous)'
	exe imap '<m-n>       <plug>(organ-nav-next)'
	exe imap '<m-b>       <plug>(organ-nav-backward)'
	exe imap '<m-f>       <plug>(organ-nav-forward)'
	exe imap '<m-u>       <plug>(organ-nav-parent)'
	exe imap '<m-d>       <plug>(organ-nav-child)'
	exe imap '<m-left>    <plug>(organ-op-promote)'
	exe imap '<m-right>   <plug>(organ-op-demote)'
	exe imap '<m-s-left>  <plug>(organ-op-promote-subtree)'
	exe imap '<m-s-right> <plug>(organ-op-demote-subtree)'
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
endfun
