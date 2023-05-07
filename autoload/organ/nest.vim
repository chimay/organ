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

" -- speed keys

fun! organ#nest#speed_help ()
	" Speed key on headlines first char
	echomsg 'h : help            | <pageup> : previous  | <home> : backward (= level)'
	echomsg 'w : where ?         | <pagedown> : next    | <end> : forward (= level)'
	echomsg '( : parent          | ) : loose child      | } : strict child'
	echomsg '^ : goto heading    | * : cycle fold vis   | # : cycle all folds vis'
	echomsg '% : select subtree  | yy : yank subtree    | dd : cycle all folds vis'
	echomsg '<del> : promote     | <ins> : demote       | e : pandoc export'
	echomsg 'H : promote subtree | L : demote subtree   | E : emacs export'
	echomsg 'U : move sub back   | D : move sub for     | M : move subtree to heading'
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
