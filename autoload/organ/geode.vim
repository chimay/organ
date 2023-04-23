" vim: set ft=vim fdm=indent iskeyword&:

" Geode
"
" Internal Constants for plugs & maps

" ---- speed keys

if ! exists('s:speedkeys')
	let s:speedkeys = [
		\ [ 'p',        'organ#bird#previous'                   ] ,
		\ [ 'n',        'organ#bird#next'                       ] ,
		\ [ 'b',        'organ#bird#backward'                   ] ,
		\ [ 'f',        'organ#bird#forward'                    ] ,
		\ [ '-',        'organ#bird#parent'                     ] ,
		\ [ '~',        'organ#bird#loose_child'                ] ,
		\ [ '+',        'organ#bird#strict_child'               ] ,
		\ [ 'h',        'organ#bird#goto_path'                  ] ,
		\ [ 'w',        'organ#bird#whereami'                   ] ,
		\ [ '*',        'organ#bird#cycle_current_fold'         ] ,
		\ [ '#',        'organ#bird#cycle_all_folds'            ] ,
		\ [ '@',        'organ#tree#select_subtree'             ] ,
		\ [ 'yy',       'organ#tree#yank_subtree'               ] ,
		\ [ 'dd',       'organ#tree#delete_subtree'             ] ,
		\ [ '<',        'organ#yggdrasil#promote'               ] ,
		\ [ '>',        'organ#yggdrasil#demote'                ] ,
		\ [ 'H',        'organ#yggdrasil#promote_subtree'       ] ,
		\ [ 'L',        'organ#yggdrasil#demote_subtree'        ] ,
		\ [ 'U',        'organ#yggdrasil#move_subtree_backward' ] ,
		\ [ 'D',        'organ#yggdrasil#move_subtree_forward'  ] ,
		\ ]
	lockvar! s:speedkeys
endif

if ! exists('s:speedkeys_with_angle')
	let s:speedkeys_with_angle = [
		\ ]
	lockvar! s:speedkeys_with_angle
endif

" ---- plugs

if ! exists('s:plugs_normal')
	let s:plugs_normal = [
		\ [ 'organ-previous'           , 'organ#bird#previous'                   ] ,
		\ [ 'organ-next'               , 'organ#bird#next'                       ] ,
		\ [ 'organ-backward'           , 'organ#bird#backward'                   ] ,
		\ [ 'organ-forward'            , 'organ#bird#forward'                    ] ,
		\ [ 'organ-parent'             , 'organ#bird#parent'                     ] ,
		\ [ 'organ-loose-child'        , 'organ#bird#loose_child'                ] ,
		\ [ 'organ-strict-child'       , 'organ#bird#strict_child'               ] ,
		\ [ 'organ-goto'               , 'organ#bird#goto_path'                  ] ,
		\ [ 'organ-whereami'           , 'organ#bird#whereami'                   ] ,
		\ [ 'organ-cycle-current-fold' , 'organ#bird#cycle_current_fold'         ] ,
		\ [ 'organ-cycle-all-folds'    , 'organ#bird#cycle_all_folds'            ] ,
		\ [ 'organ-select-subtree'     , 'organ#tree#select_subtree'             ] ,
		\ [ 'organ-yank-subtree'       , 'organ#tree#yank_subtree'               ] ,
		\ [ 'organ-delete-subtree'     , 'organ#tree#delete_subtree'             ] ,
		\ [ 'organ-promote'            , 'organ#yggdrasil#promote'               ] ,
		\ [ 'organ-demote'             , 'organ#yggdrasil#demote'                ] ,
		\ [ 'organ-promote-subtree'    , 'organ#yggdrasil#promote_subtree'       ] ,
		\ [ 'organ-demote-subtree'     , 'organ#yggdrasil#demote_subtree'        ] ,
		\ [ 'organ-move-subtree-up'    , 'organ#yggdrasil#move_subtree_backward' ] ,
		\ [ 'organ-move-subtree-down'  , 'organ#yggdrasil#move_subtree_forward'  ] ,
		\ ]
	lockvar! s:plugs_normal
endif

if ! exists('s:plugs_visual')
	let s:plugs_visual = [
				\ ]
	lockvar! s:plugs_visual
endif

if ! exists('s:plugs_insert')
	let s:plugs_insert = s:plugs_normal
	lockvar! s:plugs_insert
endif

" ---- maps

if ! exists('s:maps_normal')
	let s:maps_normal = [
		\ [ '<m-p>'       , 'organ-previous'           ] ,
		\ [ '<m-n>'       , 'organ-next'               ] ,
		\ [ '<m-b>'       , 'organ-backward'           ] ,
		\ [ '<m-f>'       , 'organ-forward'            ] ,
		\ [ '<m-u>'       , 'organ-parent'             ] ,
		\ [ '<m-l>'       , 'organ-loose-child'        ] ,
		\ [ '<m-s-l>'     , 'organ-strict-child'       ] ,
		\ [ '<m-h>'       , 'organ-goto'               ] ,
		\ [ '<m-w>'       , 'organ-whereami'           ] ,
		\ [ '<m-v>'       , 'organ-cycle-current-fold' ] ,
		\ [ '<m-s-v>'     , 'organ-cycle-all-folds'    ] ,
		\ [ '<m-@>'       , 'organ-select-subtree'     ] ,
		\ [ '<m-y>'       , 'organ-yank-subtree'       ] ,
		\ [ '<m-d>'       , 'organ-delete-subtree'     ] ,
		\ [ '<m-left>'    , 'organ-promote'            ] ,
		\ [ '<m-right>'   , 'organ-demote'             ] ,
		\ [ '<m-s-left>'  , 'organ-promote-subtree'    ] ,
		\ [ '<m-s-right>' , 'organ-demote-subtree'     ] ,
		\ [ '<m-up>'      , 'organ-move-subtree-up'    ] ,
		\ [ '<m-down>'    , 'organ-move-subtree-down'  ] ,
		\ ]
	lockvar! s:maps_normal
endif

if ! exists('s:maps_visual')
	let s:maps_visual = [
		\ ]
	lockvar! s:maps_visual
endif

if ! exists('s:maps_insert')
	let s:maps_insert = s:maps_normal
	lockvar! s:maps_insert
endif

" ---- public interface

fun! organ#geode#fetch (varname, conversion = 'no-conversion')
	" Return script variable called varname
	" The leading s: can be omitted
	" Optional argument :
	"   - no-conversion : simply returns the asked variable, dont convert anything
	"   - dict : if varname points to an items list, convert it to a dictionary
	let varname = a:varname
	let conversion = a:conversion
	" ---- variable name
	let varname = substitute(varname, '/', '_', 'g')
	let varname = substitute(varname, '-', '_', 'g')
	let varname = substitute(varname, ' ', '_', 'g')
	if varname !~ '\m^s:'
		let varname = 's:' .. varname
	endif
	" ---- raw or conversion
	if conversion ==# 'dict'
		return organ#utils#items2dict ({varname})
	else
		return {varname}
	endif
endfun
