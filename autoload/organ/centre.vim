" vim: set ft=vim fdm=indent iskeyword&:

" Centre
"
" Mappings

" ---- script constants

if exists('s:subcommands_actions')
	unlockvar s:subcommands_actions
endif
let s:subcommands_actions = organ#diadem#fetch('command/meta/actions')
lockvar s:subcommands_actions

if exists('s:speedkeys')
	unlockvar s:speedkeys
endif
let s:speedkeys = organ#geode#fetch('speedkeys', 'dict')
lockvar s:speedkeys

if exists('s:normal_plugs')
	unlockvar s:normal_plugs
endif
let s:normal_plugs = organ#geode#fetch('plugs/normal')
lockvar s:normal_plugs

if exists('s:visual_plugs')
	unlockvar s:visual_plugs
endif
let s:visual_plugs = organ#geode#fetch('plugs/visual')
lockvar s:visual_plugs

if exists('s:insert_plugs')
	unlockvar s:insert_plugs
endif
let s:insert_plugs = organ#geode#fetch('plugs/insert')
lockvar s:insert_plugs

if exists('s:normal_maps')
	unlockvar s:level_2_normal_maps
endif
let s:normal_maps = organ#geode#fetch('maps/normal')
lockvar s:level_2_normal_maps

if exists('s:visual_maps')
	unlockvar s:level_2_visual_maps
endif
let s:visual_maps = organ#geode#fetch('maps/visual')
lockvar s:level_2_visual_maps

if exists('s:insert_maps')
	unlockvar s:level_2_insert_maps
endif
let s:insert_maps = organ#geode#fetch('maps/insert')
lockvar s:level_2_insert_maps

" ---- script variables

if ! exists('s:mapstore')
	let s:mapstore = #{ normal : {}, visual : {}, insert : {} }
endif

" ---- commands

fun! organ#centre#meta (subcommand)
	" Function for meta command
	let subcommand = a:subcommand
	" ---- subcommands without argument
	let action_dict = organ#utils#items2dict(s:subcommands_actions)
	let action = action_dict[subcommand]
	if action ==# 'organ#void#nope'
		echomsg 'organ centre meta-command : this action need a third argument'
		return v:false
	endif
	return organ#utils#call(action)
endfun

fun! organ#centre#commands ()
	" Define commands
	" ---- meta command
	command! -nargs=* -complete=customlist,organ#complete#meta_command
				\ Organ call organ#centre#meta(<f-args>)
endfun

" ---- pre-existing maps

fun! organ#centre#storemaps ()
	" Store prexisting maps on speed keys
	" ---- run it only once
	if ! empty(s:mapstore.normal)
		return s:mapstore
	endif
	" ---- normal maps
	for key in keys(s:speedkeys)
		let maparg = maparg(key, 'n', v:false, v:true)
		if empty(maparg)
			continue
		endif
		if key =~ '\m^<[^>]\+>$'
			let key = tolower(key)
		endif
		let s:mapstore.normal[key] = maparg
	endfor
	" ---- visual maps
	for key in keys(s:speedkeys)
		let maparg = maparg(key, 'v', v:false, v:true)
		if empty(maparg)
			continue
		endif
		if key =~ '\m^<[^>]\+>$'
			let key = tolower(key)
		endif
		let s:mapstore.visual[key] = maparg
	endfor
	" ---- insert maps
	for key in keys(s:speedkeys)
		let maparg = maparg(key, 'i', v:false, v:true)
		if empty(maparg)
			continue
		endif
		if key =~ '\m^<[^>]\+>$'
			let key = tolower(key)
		endif
		let s:mapstore.insert[key] = maparg
	endfor
	" ---- make sure it is not modified
	lockvar s:mapstore
	" ---- coda
	return s:mapstore
endfun

fun! organ#centre#mapstore (...)
	" Front-end to s:mapstore
	if a:0 == 0
		return s:mapstore
	endif
	let key = a:1
	if a:0 > 1
		let mode = a:2
	else
		let mode = 'normal'
	endif
	if key =~ '\m^<[^>]\+>$'
		let key = tolower(key)
	endif
	if empty(key) || ! has_key(s:mapstore[mode], key)
		return {}
	endif
	return s:mapstore[mode][key]
endfun

" ---- speed keys

fun! organ#centre#speedkeys ()
	" Speed keys on headlines first char
	let everywhere = g:organ_config.everywhere
	if everywhere > 0
		let map = 'nnoremap'
	else
		let map = 'nnoremap <buffer>'
	endif
	let command = "<cmd>call organ#nest#speed('"
	let close = "')<cr>"
	for key in keys(s:speedkeys)
		" -- to avoid vim complain about <...> key in <cmd> map
		let rawkey = organ#utils#reverse_keytrans (key)
		execute map key command  .. rawkey .. close
	endfor
endfun

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

fun! organ#centre#always ()
	" Always defined maps
	let everywhere = g:organ_config.everywhere
	let previous = g:organ_config.previous
	if everywhere > 0
		execute 'nmap' previous '<plug>(organ-previous)'
	else
		execute 'nmap <buffer>' previous '<plug>(organ-previous)'
	endif
endfun

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
	let everywhere = g:organ_config.everywhere
	if everywhere <= 0
		let mapcmd ..= ' <buffer>'
	endif
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

fun! organ#centre#prefixless (mode = 'normal')
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
	let everywhere = g:organ_config.everywhere
	if everywhere <= 0
		let mapcmd ..= ' <buffer>'
	endif
	" ---- variables
	let prefix = g:organ_config.prefix
	let begin = mapcmd .. ' <silent> '
	let middle = '<plug>('
	let end = ')'
	" ---- loop
	let plugs = g:organ_config.prefixless_plugs[mode]
	let empty_plugs = empty(plugs)
	for item in maplist
		let left = item[0]
		let right = item[1]
		if ! empty_plugs && plugs->index(right) < 0
			continue
		endif
		execute begin .. left middle .. right .. end
	endfor
endfun

" ---- link plugs & maps

fun! organ#centre#cables ()
	" Link keys to <plug> mappings
	" ---- speed keys
	if g:organ_config.speedkeys > 0
		call organ#centre#storemaps ()
		call organ#centre#speedkeys ()
	endif
	" ---- always defined maps
	call organ#centre#always ()
	" ---- prefix maps
	call organ#centre#mappings ()
	call organ#centre#mappings ('visual')
	call organ#centre#mappings ('insert')
	" ---- prefixless maps
	if g:organ_config.prefixless > 0
		for mode in g:organ_config.prefixless_modes
			call organ#centre#prefixless (mode)
		endfor
	endif
endfun
