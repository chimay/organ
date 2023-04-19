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
	let begin = 'nnoremap <plug>('
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
	let begin = 'vnoremap <plug>('
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
	" ---- expr maps
	let begin = 'nnoremap <expr> <plug>('
	let middle = ')'
	for item in s:expr_plugs
		let left = item[0]
		let right = item[1]
		if right !~ ')$'
			let right ..= '()'
		endif
		execute begin .. left .. middle right
	endfor
endfun

" ---- maps

fun! organ#centre#mappings (mode = 'normal')
	" Normal maps of level
	let mode = a:mode
	" ---- mode dependent variables
	if mode ==# 'normal'
		let mapcmd = 'nmap'
	elseif mode ==# 'visual'
		let mapcmd = 'vmap'
	endif
	let level_maps = s:level_{level}_{mode}_maps
	" ---- variables
	let prefix = g:organ_config.prefix
	let begin = mapcmd .. ' <silent> ' .. prefix
	let middle = '<plug>('
	let end = ')'
	" ---- loop
	for item in level_maps
		let left = item[0]
		let right = item[1]
		execute begin .. left middle .. right .. end
	endfor
endfun

" ---- link plugs & maps

fun! organ#centre#cables ()
	" Link keys to <plug> mappings
	call organ#centre#mappings ()
endfun
