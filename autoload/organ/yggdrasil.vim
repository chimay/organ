" vim: set ft=vim fdm=indent iskeyword&:

" Tree
"
" Operations on orgmode or markdown headings or items hierarchy

" ---- script constants

if ! exists('s:plain_list_line_pattern')
	let s:plain_list_line_pattern = organ#crystal#fetch('plain_list/line_pattern')
	lockvar s:plain_list_line_pattern
endif

" ---- promote & demote

fun! organ#yggdrasil#promote ()
	" Promote heading or list item
	let line = getline('.')
	if line =~ s:plain_list_line_pattern
		call organ#bush#promote ()
	else
		call organ#tree#promote ()
	endif
endfun

fun! organ#yggdrasil#demote ()
	" Demote heading or list item
	let line = getline('.')
	if line =~ s:plain_list_line_pattern
		call organ#bush#demote ()
	else
		call organ#tree#demote ()
	endif
endfun
