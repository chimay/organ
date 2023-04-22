" vim: set ft=vim fdm=indent iskeyword&:

" Geode
"
" Internal Constants for plugs & maps

" ---- plugs

if ! exists('s:plugs_normal')
	let s:plugs_normal = [
		\ [ 'organ-nav-previous'           , 'organ#bird#previous'             ] ,
		\ [ 'organ-nav-next'               , 'organ#bird#next'                 ] ,
		\ [ 'organ-nav-backward'           , 'organ#bird#backward'             ] ,
		\ [ 'organ-nav-forward'            , 'organ#bird#forward'              ] ,
		\ [ 'organ-nav-parent'             , 'organ#bird#parent'               ] ,
		\ [ 'organ-nav-loose-child'        , 'organ#bird#loose_child'          ] ,
		\ [ 'organ-nav-strict-child'       , 'organ#bird#strict_child'         ] ,
		\ [ 'organ-nav-whereami'           , 'organ#bird#whereami'             ] ,
		\ [ 'organ-nav-cycle-current-fold' , 'organ#bird#cycle_current_fold'   ] ,
		\ [ 'organ-nav-cycle-all-folds'    , 'organ#bird#cycle_all_folds'      ] ,
		\ [ 'organ-op-promote'             , 'organ#yggdrasil#promote'         ] ,
		\ [ 'organ-op-demote'              , 'organ#yggdrasil#demote'          ] ,
		\ [ 'organ-op-promote-subtree'     , 'organ#yggdrasil#promote_subtree' ] ,
		\ [ 'organ-op-demote-subtree'      , 'organ#yggdrasil#demote_subtree'  ] ,
		\ ]
	lockvar! s:plugs_normal
endif

if ! exists('s:plugs_visual')
	let s:plugs_visual = [
				\ ]
	lockvar! s:plugs_visual
endif

if ! exists('s:plugs_insert')
	let s:plugs_insert = [
		\ [ 'organ-nav-previous'       , 'organ#bird#previous'        ] ,
		\ [ 'organ-nav-next'           , 'organ#bird#next'            ] ,
		\ [ 'organ-nav-backward'       , 'organ#bird#backward'        ] ,
		\ [ 'organ-nav-forward'        , 'organ#bird#forward'         ] ,
		\ [ 'organ-nav-parent'         , 'organ#bird#parent'          ] ,
		\ [ 'organ-nav-loose-child'    , 'organ#bird#loose_child'     ] ,
		\ [ 'organ-nav-strict-child'   , 'organ#bird#strict_child'    ] ,
		\ [ 'organ-nav-whereami'       , 'organ#bird#whereami'        ] ,
		\ [ 'organ-op-promote'         , 'organ#tree#promote'         ] ,
		\ [ 'organ-op-demote'          , 'organ#tree#demote'          ] ,
		\ [ 'organ-op-promote-subtree' , 'organ#tree#promote_subtree' ] ,
		\ [ 'organ-op-demote-subtree'  , 'organ#tree#demote_subtree'  ] ,
		\ ]
	lockvar! s:plugs_insert
endif

" ---- maps

if ! exists('s:maps_normal')
	let s:maps_normal = [
		\ [ '<m-p>'       , 'organ-nav-previous'           ] ,
		\ [ '<m-n>'       , 'organ-nav-next'               ] ,
		\ [ '<m-b>'       , 'organ-nav-backward'           ] ,
		\ [ '<m-f>'       , 'organ-nav-forward'            ] ,
		\ [ '<m-u>'       , 'organ-nav-parent'             ] ,
		\ [ '<m-d>'       , 'organ-nav-loose-child'        ] ,
		\ [ '<m-s-d>'     , 'organ-nav-strict-child'       ] ,
		\ [ '<m-w>'       , 'organ-nav-whereami'           ] ,
		\ [ '<m-v>'       , 'organ-nav-cycle-current-fold' ] ,
		\ [ '<m-s-v>'     , 'organ-nav-cycle-fold-folds'   ] ,
		\ [ '<m-left>'    , 'organ-op-promote'             ] ,
		\ [ '<m-right>'   , 'organ-op-demote'              ] ,
		\ [ '<m-s-left>'  , 'organ-op-promote-subtree'     ] ,
		\ [ '<m-s-right>' , 'organ-op-demote-subtree'      ] ,
		\ ]
	lockvar! s:maps_normal
endif

if ! exists('s:maps_visual')
	let s:maps_visual = [
		\ ]
	lockvar! s:maps_visual
endif

if ! exists('s:maps_insert')
	let s:maps_insert = [
		\ [ '<m-p>'       , 'organ-nav-previous'           ] ,
		\ [ '<m-n>'       , 'organ-nav-next'               ] ,
		\ [ '<m-b>'       , 'organ-nav-backward'           ] ,
		\ [ '<m-f>'       , 'organ-nav-forward'            ] ,
		\ [ '<m-u>'       , 'organ-nav-parent'             ] ,
		\ [ '<m-d>'       , 'organ-nav-loose-child'        ] ,
		\ [ '<m-s-d>'     , 'organ-nav-strict-child'       ] ,
		\ [ '<m-w>'       , 'organ-nav-whereami'           ] ,
		\ [ '<m-v>'       , 'organ-nav-cycle-current-fold' ] ,
		\ [ '<m-s-v>'     , 'organ-nav-cycle-fold-folds'   ] ,
		\ [ '<m-left>'    , 'organ-op-promote'             ] ,
		\ [ '<m-right>'   , 'organ-op-demote'              ] ,
		\ [ '<m-s-left>'  , 'organ-op-promote-subtree'     ] ,
		\ [ '<m-s-right>' , 'organ-op-demote-subtree'      ] ,
		\ ]
	lockvar! s:maps_insert
endif

" ---- speed keys

if ! exists('s:speedkeys')
	let s:speedkeys = [
		\ [ 'p',        'organ#bird#previous'             ] ,
		\ [ 'n',        'organ#bird#next'                 ] ,
		\ [ 'b',        'organ#bird#backward'             ] ,
		\ [ 'f',        'organ#bird#forward'              ] ,
		\ [ '-',        'organ#bird#parent'               ] ,
		\ [ '+',        'organ#bird#loose_child'          ] ,
		\ [ 'w',        'organ#bird#whereami'             ] ,
		\ [ 'x',        'organ#bird#cycle_current_fold'   ] ,
		\ [ 'X',        'organ#bird#cycle_all_folds'      ] ,
		\ [ '<',        'organ#yggdrasil#promote'         ] ,
		\ [ '>',        'organ#yggdrasil#demote'          ] ,
		\ [ 'H',        'organ#yggdrasil#promote_subtree' ] ,
		\ [ 'L',        'organ#yggdrasil#demote_subtree'  ] ,
		\ ]
	lockvar! s:speedkeys
endif

if ! exists('s:speedkeys_with_angle')
	let s:speedkeys_with_angle = [
		\ ]
	lockvar! s:speedkeys_with_angle
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
