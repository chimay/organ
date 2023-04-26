" vim: set ft=vim fdm=indent iskeyword&:

" Centre
"
" Mappings

" ---- script constants

if ! exists('s:subcommands_actions')
	let s:subcommands_actions = organ#diadem#fetch('command/meta/actions')
	lockvar s:subcommands_actions
endif

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

" ---- speed keys

fun! organ#centre#speedkeys ()
	" Speed keys on headlines first char
	let map = 'nnoremap <buffer>'
	let command = "<cmd>call organ#nest#speed('"
	let close = "')<cr>"
	let close_angle = "', '>')<cr>"
	for key in keys(s:speedkeys)
		if key[0] == '<' && key[-1:] == '>'
			let arg_key = key[1:-2]
			execute map key command  .. arg_key .. close_angle
			echomsg map key command  .. arg_key .. close_angle
		else
			execute map key command  .. key .. close
		endif
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
	let mapcmd ..= ' <buffer>'
	" ---- variables
	let prefix = g:organ_config.prefix
	let begin = mapcmd .. ' <silent> '
	let middle = '<plug>('
	let end = ')'
	" ---- loop
	let plugs = g:organ_config.prefixless_plugs
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
	call organ#centre#mappings ()
	call organ#centre#mappings ('visual')
	call organ#centre#mappings ('insert')
	if g:organ_config.prefixless > 0
		for mode in g:organ_config.prefixless_modes
			call organ#centre#prefixless (mode)
		endfor
	endif
	if g:organ_config.speedkeys > 0
		call organ#centre#speedkeys ()
	endif
endfun
