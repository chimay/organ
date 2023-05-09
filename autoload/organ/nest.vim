" vim: set ft=vim fdm=indent iskeyword&:

" Eagle
"
" Navigation and operations on orgmode or markdown
" headings or items hierarchy

" ---- script constants

if ! exists('s:rep_one_char')
	let s:rep_one_char = organ#crystal#fetch('filetypes/repeated_one_char_heading')
	lockvar s:rep_one_char
endif

if ! exists('s:speedkeys')
	let s:speedkeys = organ#geode#fetch('speedkeys', 'dict')
	lockvar s:speedkeys
endif

" --- context sensitive

fun! organ#nest#navig (function)
	" Choose to apply headline or list navigation function
	let function = a:function
	if organ#colibri#is_in_list ()
		call organ#colibri#{function} ()
	else
		call organ#bird#{function} ()
	endif
	return v:true
endfun

fun! organ#nest#oper (function)
	" Choose to apply headline or list operation function
	if s:rep_one_char->index(&filetype) < 0 && &foldmethod ==# 'indent'
		echomsg 'organ nest oper : not supported for indent folds'
		return v:false
	endif
	let function = a:function
	if organ#colibri#is_in_list ()
		call organ#bush#{function} ()
	else
		call organ#tree#{function} ()
	endif
	return v:true
endfun

" ---- <m-arrow>

fun! organ#nest#meta_left ()
	" For <m-left> map
	if organ#table#is_in_table ()
		call organ#table#move_left ()
	elseif organ#colibri#is_in_list ()
		call organ#bush#promote ()
	else
		call organ#tree#promote ()
	endif
endfun

fun! organ#nest#meta_right ()
	" For <m-right> map
	if organ#table#is_in_table ()
		call organ#table#move_right ()
	elseif organ#colibri#is_in_list ()
		call organ#bush#demote ()
	else
		call organ#tree#demote ()
	endif
endfun

fun! organ#nest#meta_up ()
	" For <m-up> map
	if organ#table#is_in_table ()
		call organ#table#move_up ()
	elseif organ#colibri#is_in_list ()
		call organ#bush#move_subtree_backward ()
	else
		call organ#tree#move_subtree_backward ()
	endif
endfun

fun! organ#nest#meta_down ()
	" For <m-down> map
	if organ#table#is_in_table ()
		call organ#table#move_down ()
	elseif organ#colibri#is_in_list ()
		call organ#bush#move_subtree_forward ()
	else
		call organ#tree#move_subtree_forward ()
	endif
endfun

" ---- <m-s-arrow>

fun! organ#nest#shift_meta_left ()
	" For <m-s-left> map
	if organ#table#is_in_table ()
		call organ#table#move_left ()
	elseif organ#colibri#is_in_list ()
		call organ#bush#promote_subtree ()
	else
		call organ#tree#promote_subtree ()
	endif
endfun

fun! organ#nest#shift_meta_right ()
	" For <m-s-right> map
	if organ#table#is_in_table ()
		call organ#table#new_col ()
	elseif organ#colibri#is_in_list ()
		call organ#bush#demote_subtree ()
	else
		call organ#tree#demote_subtree ()
	endif
endfun

fun! organ#nest#shift_meta_up ()
	" For <m-s-up> map
	if organ#table#is_in_table ()
		call organ#table#move_up ()
	elseif organ#colibri#is_in_list ()
	else
	endif
endfun

fun! organ#nest#shift_meta_down ()
	" For <m-s-down> map
	if organ#table#is_in_table ()
		call organ#table#new_row ()
	elseif organ#colibri#is_in_list ()
	else
	endif
endfun

" -- speed keys

fun! organ#nest#speed_help ()
	" Speed key on headlines first char
	echomsg 'h : help            | <pageup> : previous    | <home> : backward (= level)'
	echomsg 'w : where ?         | <pagedown> : next      | <end> : forward (= level)'
	echomsg '+ : parent          | - : loose child        | _ : strict child'
	echomsg 'h : goto heading    | <tab> : cycle fold vis | <s-tab> : cycle all folds vis'
	echomsg 's : select subtree  | Y : yank subtree       | D : delete subtree'
	echomsg '<del> : promote     | <ins> : demote         | e : pandoc export'
	echomsg 'H : promote subtree | L : demote subtree     | E : emacs export'
	echomsg 'U : move sub back   | D : move sub forward   | M : move subtree to heading'
endfun

fun! organ#nest#speed (key)
	" Speed key on headlines first char
	let key = a:key
	let keytrans = key->keytrans()
	if keytrans =~ '\m^<[^>]\+>$'
		let keytrans = tolower(keytrans)
	endif
	" ------ headline or itemhead
	let first_char = col('.') == 1
	let tree = organ#bird#is_on_headline ()
	let tree = tree || organ#colibri#is_on_itemhead ()
	if first_char && tree
		let action = s:speedkeys[keytrans]
		call organ#utils#call (action)
		return 'speed-' .. keytrans
	endif
	" ------ elsewhere
	" ---- mapped key
	let maparg = organ#centre#mapstore(keytrans)
	if ! empty(maparg)
		let rhs = maparg.rhs
		let rhs = organ#utils#reverse_keytrans(rhs)
		if v:count > 0
			let rhs = rhs->repeat(v:count)
		endif
		call feedkeys(rhs)
		return 'normal-mapped-' .. keytrans
	endif
	" ---- non mapped key
	if v:count > 0
		let rhs = rhs->repeat(v:count)
	endif
	call feedkeys(key, 'n')
	return 'normal-' .. keytrans
endfun
