" vim: set ft=vim fdm=indent iskeyword&:

" Geode
"
" Internal Constants for plugs & maps

" ---- speed keys

if ! exists('s:speedkeys')
	let s:speedkeys = [
		\ [ 'h',          'organ#nest#speed_help()'                  ] ,
		\ [ '<pageup>',   "organ#nest#navig('previous')"             ] ,
		\ [ '<pagedown>', "organ#nest#navig('next')"                 ] ,
		\ [ '<home>',     "organ#nest#navig('backward')"             ] ,
		\ [ '<end>',      "organ#nest#navig('forward')"              ] ,
		\ [ '(',          "organ#nest#navig('parent')"               ] ,
		\ [ ')',          "organ#nest#navig('loose_child')"          ] ,
		\ [ '}',          "organ#nest#navig('strict_child')"         ] ,
		\ [ 'w',          'organ#bird#whereami'                      ] ,
		\ [ '^',          'organ#bird#goto_path'                     ] ,
		\ [ '*',          'organ#bird#cycle_current_fold'            ] ,
		\ [ '#',          'organ#bird#cycle_all_folds'               ] ,
		\ [ '%',          "organ#nest#oper('select_subtree')"        ] ,
		\ [ 'yy',         "organ#nest#oper('yank_subtree')"          ] ,
		\ [ 'dd',         "organ#nest#oper('delete_subtree')"        ] ,
		\ [ '<del>',      "organ#nest#oper('promote')"               ] ,
		\ [ '<ins>',      "organ#nest#oper('demote')"                ] ,
		\ [ 'H',          "organ#nest#oper('promote_subtree')"       ] ,
		\ [ 'L',          "organ#nest#oper('demote_subtree')"        ] ,
		\ [ 'U',          "organ#nest#oper('move_subtree_backward')" ] ,
		\ [ 'D',          "organ#nest#oper('move_subtree_forward')"  ] ,
		\ [ 'M',          "organ#tree#moveto"                        ] ,
		\ [ 'e',          'organ#pipe#pandoc_export'                 ] ,
		\ [ 'E',          'organ#pipe#emacs_export'                  ] ,
		\ ]
	lockvar! s:speedkeys
endif

" ---- plugs

if ! exists('s:plugs_normal')
	let s:plugs_normal = [
		\ [ 'organ-previous'                      , "organ#nest#navig('previous')"             ] ,
		\ [ 'organ-next'                          , "organ#nest#navig('next')"                 ] ,
		\ [ 'organ-backward'                      , "organ#nest#navig('backward')"             ] ,
		\ [ 'organ-forward'                       , "organ#nest#navig('forward')"              ] ,
		\ [ 'organ-parent'                        , "organ#nest#navig('parent')"               ] ,
		\ [ 'organ-loose-child'                   , "organ#nest#navig('loose_child')"          ] ,
		\ [ 'organ-strict-child'                  , "organ#nest#navig('strict_child')"         ] ,
		\ [ 'organ-whereami'                      , 'organ#bird#whereami'                      ] ,
		\ [ 'organ-goto-headline'                 , 'organ#bird#goto_path'                     ] ,
		\ [ 'organ-cycle-current-fold-visibility' , 'organ#bird#cycle_current_fold'            ] ,
		\ [ 'organ-cycle-all-folds-visibility'    , 'organ#bird#cycle_all_folds'               ] ,
		\ [ 'organ-new'                           , "organ#nest#oper('new')"                   ] ,
		\ [ 'organ-select-subtree'                , "organ#nest#oper('select_subtree')"        ] ,
		\ [ 'organ-yank-subtree'                  , "organ#nest#oper('yank_subtree')"          ] ,
		\ [ 'organ-delete-subtree'                , "organ#nest#oper('delete_subtree')"        ] ,
		\ [ 'organ-promote'                       , "organ#nest#oper('promote')"               ] ,
		\ [ 'organ-demote'                        , "organ#nest#oper('demote')"                ] ,
		\ [ 'organ-promote-subtree'               , "organ#nest#oper('promote_subtree')"       ] ,
		\ [ 'organ-demote-subtree'                , "organ#nest#oper('demote_subtree')"        ] ,
		\ [ 'organ-move-subtree-up'               , "organ#nest#oper('move_subtree_backward')" ] ,
		\ [ 'organ-move-subtree-down'             , "organ#nest#oper('move_subtree_forward')"  ] ,
		\ [ 'organ-move-subtree-to'               , 'organ#tree#moveto'                        ] ,
		\ [ 'organ-expand-template'               , 'organ#seed#expand'                        ] ,
		\ [ 'organ-store-url'                     , 'organ#vine#store'                         ] ,
		\ [ 'organ-new-link'                      , 'organ#vine#new'                           ] ,
		\ [ 'organ-format-table'                  , 'organ#table#format'                       ] ,
		\ [ 'organ-export-pandoc'                 , 'organ#pipe#pandoc_export'                 ] ,
		\ [ 'organ-export-emacs'                  , 'organ#pipe#emacs_export'                  ] ,
		\ [ 'organ-export-asciidoc'               , 'organ#pipe#asciidoc_export'               ] ,
		\ [ 'organ-export-asciidoctor'            , 'organ#pipe#asciidoctor_export'            ] ,
		\ ]
	lockvar! s:plugs_normal
endif

if ! exists('s:plugs_visual')
	let s:plugs_visual = s:plugs_normal
	lockvar! s:plugs_visual
endif

if ! exists('s:plugs_insert')
	let s:plugs_insert = s:plugs_normal
	lockvar! s:plugs_insert
endif

" ---- maps

if ! exists('s:maps_normal')
	let s:maps_normal = [
		\ [ '<m-p>'       , 'organ-previous'                      ] ,
		\ [ '<m-n>'       , 'organ-next'                          ] ,
		\ [ '<m-b>'       , 'organ-backward'                      ] ,
		\ [ '<m-f>'       , 'organ-forward'                       ] ,
		\ [ '<m-u>'       , 'organ-parent'                        ] ,
		\ [ '<m-l>'       , 'organ-loose-child'                   ] ,
		\ [ '<m-s-l>'     , 'organ-strict-child'                  ] ,
		\ [ '<m-w>'       , 'organ-whereami'                      ] ,
		\ [ '<m-h>'       , 'organ-goto-headline'                 ] ,
		\ [ '<m-z>'       , 'organ-cycle-current-fold-visibility' ] ,
		\ [ '<m-s-z>'     , 'organ-cycle-all-folds-visibility'    ] ,
		\ [ '<m-cr>'      , 'organ-new'                           ] ,
		\ [ '<m-v>'       , 'organ-select-subtree'                ] ,
		\ [ '<m-y>'       , 'organ-yank-subtree'                  ] ,
		\ [ '<m-d>'       , 'organ-delete-subtree'                ] ,
		\ [ '<m-left>'    , 'organ-promote'                       ] ,
		\ [ '<m-right>'   , 'organ-demote'                        ] ,
		\ [ '<m-s-left>'  , 'organ-promote-subtree'               ] ,
		\ [ '<m-s-right>' , 'organ-demote-subtree'                ] ,
		\ [ '<m-up>'      , 'organ-move-subtree-up'               ] ,
		\ [ '<m-down>'    , 'organ-move-subtree-down'             ] ,
		\ [ '<m-m>'       , 'organ-move-subtree-to'               ] ,
		\ [ '<m-x>'       , 'organ-expand-template'               ] ,
		\ [ '<m-s>'       , 'organ-store-url'                     ] ,
		\ [ '<m-@>'       , 'organ-new-link'                      ] ,
		\ [ '<m-a>'       , 'organ-format-table'                  ] ,
		\ [ '<m-e>'       , 'organ-export-pandoc'                 ] ,
		\ [ '<m-s-e>'     , 'organ-export-emacs'                  ] ,
		\                                                         ]
	lockvar! s:maps_normal
endif

if ! exists('s:maps_visual')
	let s:maps_visual = s:maps_normal
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
