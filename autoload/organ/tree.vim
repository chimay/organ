" vim: set ft=vim fdm=indent iskeyword&:

" Tree
"
" Operations on org hierarchy


" ---- headers

fun! organ#tree#promote_header ()
	" Promote header
endfun

fun! organ#tree#demote_header ()
	" Demote header
endfun

" ---- list items

fun! organ#tree#promote_list_item ()
	" Promote list item
endfun

fun! organ#tree#demote_list_item ()
	" Demote list item
endfun

" ---- generic

fun! organ#tree#promote ()
	" Promote header or list item
	let line = getline('.')
	if line ==~ '^\s*[-+*]'
		call organ#tree#promote#list_item ()
	else
		call organ#tree#promote#header ()
	endif
endfun

fun! organ#tree#demote ()
	" Demote header or list item
	let line = getline('.')
	if line ==~ '^\s*[-+*]'
		call organ#tree#demote#list_item ()
	else
		call organ#tree#demote#header ()
	endif
endfun
