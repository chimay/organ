" vim: set ft=vim fdm=indent iskeyword&:

" Eagle
"
" Navigation and operations on orgmode or markdown
" headings or items hierarchy

" ---- script constants

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
endfun

fun! organ#nest#oper (function)
	" Choose to apply headline or list operation function
	let function = a:function
	if organ#colibri#is_in_list ()
		call organ#bush#{function} ()
	else
		call organ#tree#{function} ()
	endif
endfun

" -- speed keys

fun! organ#nest#speed_help ()
	" Speed key on headlines first char
	echomsg 'h : help            | <pageup> : previous  | <home> : backward (= level)'
	echomsg 'w : where ?         | <pagedown> : next    | <end> : forward (= level)'
	echomsg '^ : parent          | $ : loose child      | - : strict child'
	echomsg '~ : goto heading    | * : cycle fold vis   | # : cycle all folds vis'
	echomsg '& : select subtree  | yy : yank subtree    | dd : cycle all folds vis'
	echomsg '<del> : promote     | <ins> : demote       | e : pandoc export'
	echomsg 'H : promote subtree | L : demote subtree   | E : emacs export'
	echomsg 'U : move sub back   | D : move sub for     | M : move subtree to heading'
endfun

fun! organ#nest#speed (key, angle = 'no-angle')
	" Speed key on headlines first char
	let key = a:key
	let angle = a:angle
	" ---- headline or itemhead
	let first_char = col('.') == 1
	let tree = organ#bird#is_on_headline ()
	let tree = tree || organ#colibri#is_on_itemhead ()
	if first_char && tree
		if angle ==# 'angle' || angle ==# '>'
			let key = '<' .. key .. '>'
		endif
		let action = s:speedkeys[key]
		call organ#utils#call(action)
		return 'tree-' .. angle
	endif
	" ---- normal
	" -- special key with angle, like <bs>
	if angle ==# 'angle' || angle ==# '>'
		execute 'let key =' '"\<' .. key .. '>"'
		execute 'normal!' key
		return 'normal-angle'
	endif
	" -- without angle
	execute 'normal!' key
	return 'normal'
endfun
