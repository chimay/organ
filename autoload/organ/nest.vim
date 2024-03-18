" vim: set ft=vim fdm=indent iskeyword&:

" Eagle
"
" Navigation and operations on headings or items hierarchy

" ---- script constants

if exists('s:rep_one_char')
	unlockvar s:rep_one_char
endif
let s:rep_one_char = organ#crystal#fetch('filetypes/repeated_one_char_heading')
lockvar s:rep_one_char

if exists('s:speedkeys')
	unlockvar s:speedkeys
endif
let s:speedkeys = organ#geode#fetch('speedkeys', 'dict')
lockvar s:speedkeys

if exists('s:waterproof_indent')
	unlockvar s:waterproof_indent
endif
let s:waterproof_indent = organ#crystal#fetch('waterproof/indent')
lockvar s:waterproof_indent

" ---- helpers

fun! organ#nest#is_on_headline_first_char ()
	" Whether cursor is on headline first char
	let first_char = col('.') == 1
	let headline = organ#bird#is_on_headline ()
	return first_char && headline
endfun

fun! organ#nest#is_on_itemhead_first_char ()
	" Whether cursor is on first char & first line of list item
	let first_char = col('.') == 1
	let itemhead = organ#colibri#is_on_itemhead ()
	return first_char && itemhead
endfun

fun! organ#nest#waterproof_indent (function)
	" Whether function is ok with indent headlines
	let function = a:function
	let waterproof = ! organ#stair#is_indent_headline_file ()
	let waterproof = waterproof || s:waterproof_indent->index(function) >= 0
	return waterproof
endfun

" ---- generic

fun! organ#nest#navig (function, ...)
	" Choose to apply headline or list navigation function
	let function = a:function
	if organ#colibri#is_in_list ()
		if a:0 > 0
			return call('organ#colibri#' .. function, a:000)
		else
			return organ#colibri#{function} ()
		endif
	else
		if a:0 > 0
			return call('organ#bird#' .. function, a:000)
		else
			return organ#bird#{function} ()
		endif
	endif
endfun

fun! organ#nest#oper (function, ...)
	" Choose to apply headline or list operation function
	let function = a:function
	if ! organ#nest#waterproof_indent(function)
		echomsg 'organ nest oper : not supported for indent folds'
		return v:false
	endif
	if organ#colibri#is_in_list ()
		if a:0 > 0
			return call('organ#bush#' .. function, a:000)
		else
			return organ#bush#{function} ()
		endif
	else
		if a:0 > 0
			return call('organ#tree#' .. function, a:000)
		else
			return organ#tree#{function} ()
		endif
	endif
endfun

" ---- speed keys

fun! organ#nest#speed_help ()
	" Speed key on headlines first char
	echomsg '<f1> : help             | <pageup> : previous    | <home> : backward (= level)'
	echomsg 'i : info                | <pagedown> : next      | <end> : forward (= level)'
	echomsg '+ : parent              | - : loose child        | _ : strict child'
	echomsg '<space> : go to heading | <tab> : cycle fold vis | <s-tab> : cycle all folds vis'
	echomsg 's : select subtree      | Y : yank subtree       | X : delete subtree'
	echomsg '<del> : promote         | <ins> : demote         | % : export'
	echomsg 'H : promote subtree     | L : demote subtree     | g% : alter export'
	echomsg 'U : move sub back       | D : move sub forward   | M : move subtree to heading'
endfun

fun! organ#nest#speed (key, mode = 'normal')
	" Speed key on headlines first char
	let key = a:key
	let mode = a:mode
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
	let maparg = organ#centre#mapstore(keytrans, mode)
	if ! empty(maparg)
		let rhs = maparg.rhs
		let rhs = organ#utils#reverse_keytrans(rhs)
		if v:count > 0
			let rhs = rhs->repeat(v:count)
		endif
		" -- expr map
		if maparg.expr > 0
			let rhs = eval(rhs)
		endif
		" -- feed
		call feedkeys(rhs)
		return 'normal-mapped-' .. keytrans
	endif
	" ---- non mapped key
	if v:count > 0
		let key = key->repeat(v:count)
	endif
	call feedkeys(key, 'n')
	return 'normal-' .. keytrans
endfun

" ---- return

fun! organ#nest#meta_return (...)
	" For <m-cr> map
	if organ#table#is_in_table ()
		return organ#table#new_row ()
	elseif organ#colibri#is_in_list ()
		if a:0 > 0
			return call('organ#bush#new', a:000)
		else
			return organ#bush#new ()
		endif
	else
		return organ#tree#new ()
	endif
endfun

fun! organ#nest#shift_return ()
	" For <s-cr> map
	if organ#table#is_in_table ()
	elseif organ#colibri#is_in_list ()
		return organ#bush#new_with_check ()
	else
		return organ#tree#new ()
	endif
endfun

" ---- tab

fun! organ#nest#tab (mode = 'normal')
	" For <tab> map
	let mode = a:mode
	if organ#nest#is_on_headline_first_char ()
		return organ#origami#cycle_current_fold ()
	elseif organ#nest#is_on_itemhead_first_char ()
		return organ#bush#toggle_checkbox ()
	elseif organ#table#is_in_table ()
		return organ#table#next_cell ()
	else
		return organ#nest#speed ("\<tab>", mode)
	endif
endfun

fun! organ#nest#shift_tab (mode = 'normal')
	" For <s-tab> map
	let mode = a:mode
	if organ#nest#is_on_headline_first_char ()
		return organ#origami#cycle_all_folds ()
	elseif organ#table#is_in_table ()
		return organ#table#previous_cell ()
	else
		return organ#nest#speed ("\<s-tab>", mode)
	endif
endfun

" ---- <m-arrow>

fun! organ#nest#meta_left ()
	" For <m-left> map
	if organ#table#is_in_table ()
		return organ#table#move_col_left ()
	elseif organ#colibri#is_in_list ()
		return organ#bush#promote ()
	else
		return organ#tree#promote ()
	endif
endfun

fun! organ#nest#meta_right ()
	" For <m-right> map
	if organ#table#is_in_table ()
		return organ#table#move_col_right ()
	elseif organ#colibri#is_in_list ()
		return organ#bush#demote ()
	else
		return organ#tree#demote ()
	endif
endfun

fun! organ#nest#meta_up ()
	" For <m-up> map
	if organ#table#is_in_table ()
		return organ#table#move_row_up ()
	elseif organ#colibri#is_in_list ()
		return organ#bush#move_subtree_backward ()
	else
		if ! organ#nest#waterproof_indent('subtree_backward')
			echomsg 'organ nest oper : not supported for indent folds'
			return v:false
		endif
		return organ#tree#move_subtree_backward ()
	endif
endfun

fun! organ#nest#meta_down ()
	" For <m-down> map
	if organ#table#is_in_table ()
		return organ#table#move_row_down ()
	elseif organ#colibri#is_in_list ()
		return organ#bush#move_subtree_forward ()
	else
		if ! organ#nest#waterproof_indent('subtree_forward')
			echomsg 'organ nest oper : not supported for indent folds'
			return v:false
		endif
		return organ#tree#move_subtree_forward ()
	endif
endfun

" ---- <s-arrow>

fun! organ#nest#shift_left ()
	" For <s-left> map
	if organ#table#is_in_table ()
		return organ#table#cell_begin ()
	elseif organ#colibri#is_in_list ()
		return organ#bush#cycle_prefix (-1)
	else
	endif
endfun

fun! organ#nest#shift_right ()
	" For <s-right> map
	if organ#table#is_in_table ()
		return organ#table#cell_end ()
	elseif organ#colibri#is_in_list ()
		return organ#bush#cycle_prefix (1)
	else
	endif
endfun

fun! organ#nest#shift_up ()
	" For <s-up> map
	if organ#table#is_in_table ()
		return organ#table#duplicate ()
	elseif organ#colibri#is_in_list ()
		return organ#bush#cycle_todo (-1)
	else
		return organ#tree#cycle_todo (-1)
	endif
endfun

fun! organ#nest#shift_down ()
	" For <s-right> map
	if organ#table#is_in_table ()
		return organ#table#select_cell ()
	elseif organ#colibri#is_in_list ()
		return organ#bush#cycle_todo (1)
	else
		return organ#tree#cycle_todo (1)
	endif
endfun

" ---- <m-s-arrow>

fun! organ#nest#meta_shift_left ()
	" For <m-s-left> map
	if organ#table#is_in_table ()
		return organ#table#delete_col ()
	elseif organ#colibri#is_in_list ()
		return organ#bush#promote_subtree ()
	else
		return organ#tree#promote_subtree ()
	endif
endfun

fun! organ#nest#meta_shift_right ()
	" For <m-s-right> map
	if organ#table#is_in_table ()
		return organ#table#new_col ()
	elseif organ#colibri#is_in_list ()
		return organ#bush#demote_subtree ()
	else
		return organ#tree#demote_subtree ()
	endif
endfun

fun! organ#nest#meta_shift_up ()
	" For <m-s-up> map
	if organ#table#is_in_table ()
		return organ#table#delete_row ()
	elseif organ#colibri#is_in_list ()
	else
	endif
endfun

fun! organ#nest#meta_shift_down ()
	" For <m-s-down> map
	if organ#table#is_in_table ()
		return organ#table#new_row ()
	elseif organ#colibri#is_in_list ()
	else
	endif
endfun

" ---- export

fun! organ#nest#export ()
	" Export
	if &filetype ==# 'org'
		call organ#pipe#emacs_export ()
	elseif &filetype ==# 'asciidoc'
		call organ#pipe#asciidoc_export ()
	else
		call organ#pipe#pandoc_export ()
	endif
endfun

fun! organ#nest#alter_export ()
	" Export alternative
	if &filetype ==# 'org'
		call organ#pipe#pandoc_export ()
	elseif &filetype ==# 'asciidoc'
		call organ#pipe#asciidoctor_export ()
	else
		call organ#pipe#pandoc_export ()
	endif
endfun

" ---- conversion org <-> markdown

fun! organ#nest#org2markdown ()
	" Convert headlines, links & table org -> markdown
	call organ#tree#org2markdown ()
	call organ#vine#org2markdown ()
	call organ#table#org2markdown ()
endfun

fun! organ#nest#markdown2org ()
	" Convert headlines, links & table markdown -> org
	call organ#tree#markdown2org ()
	call organ#vine#markdown2org ()
	call organ#table#markdown2org ()
endfun
