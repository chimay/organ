" vim: set ft=vim fdm=indent iskeyword&:

" Geode
"
" Internal Constants for plugs & maps

" ---- speed keys

if exists('s:speedkeys')
	unlockvar! s:speedkeys
endif
let s:speedkeys = [
    \ [ '<f1>'       , 'organ#nest#speed_help()'                  ] ,
    \ [ '<pageup>'   , "organ#nest#navig('previous')"             ] ,
    \ [ '<pagedown>' , "organ#nest#navig('next')"                 ] ,
    \ [ '<home>'     , "organ#nest#navig('backward')"             ] ,
    \ [ '<end>'      , "organ#nest#navig('forward')"              ] ,
    \ [ '+'          , "organ#nest#navig('parent')"               ] ,
    \ [ '-'          , "organ#nest#navig('loose_child')"          ] ,
    \ [ '_'          , "organ#nest#navig('strict_child')"         ] ,
    \ [ '<kplus>'    , "organ#nest#navig('parent')"               ] ,
    \ [ '<kminus>'   , "organ#nest#navig('loose_child')"          ] ,
    \ [ 'i'          , 'organ#bird#info'                          ] ,
    \ [ '<space>'    , 'organ#bird#goto'                          ] ,
    \ [ '<tab>'      , 'organ#nest#tab'                           ] ,
    \ [ '<s-tab>'    , 'organ#nest#shift_tab'                     ] ,
    \ [ 's'          , "organ#nest#oper('select_subtree')"        ] ,
    \ [ 'Y'          , "organ#nest#oper('yank_subtree')"          ] ,
    \ [ 'X'          , "organ#nest#oper('delete_subtree')"        ] ,
    \ [ '<del>'      , "organ#nest#oper('promote')"               ] ,
    \ [ '<insert>'   , "organ#nest#oper('demote')"                ] ,
    \ [ 'H'          , "organ#nest#oper('promote_subtree')"       ] ,
    \ [ 'L'          , "organ#nest#oper('demote_subtree')"        ] ,
    \ [ 'U'          , "organ#nest#oper('move_subtree_backward')" ] ,
    \ [ 'D'          , "organ#nest#oper('move_subtree_forward')"  ] ,
    \ [ 'M'          , 'organ#tree#moveto'                        ] ,
    \ [ '#'          , 'organ#tree#tag'                           ] ,
	\ [ 't'          , "organ#nest#oper('cycle_todo', 1)"         ] ,
	\ [ 'T'          , "organ#nest#oper('cycle_todo', -1)"        ] ,
	\ [ 'C'          , 'organ#bush#toggle_checkbox'               ] ,
	\ [ '%'          , 'organ#nest#export'                        ] ,
	\ [ 'g%'         , 'organ#nest#alter_export'                  ] ,
	\ ]
lockvar! s:speedkeys

" ---- plugs

if exists('s:plugs_normal')
	unlockvar! s:plugs_normal
endif
let s:plugs_normal = [
	\ [ 'organ-enable'             , 'organ#void#enable()'               ] ,
	\ [ 'organ-previous'           , "organ#nest#navig('previous')"      ] ,
	\ [ 'organ-next'               , "organ#nest#navig('next')"          ] ,
	\ [ 'organ-backward'           , "organ#nest#navig('backward')"      ] ,
	\ [ 'organ-forward'            , "organ#nest#navig('forward')"       ] ,
	\ [ 'organ-parent'             , "organ#nest#navig('parent')"        ] ,
	\ [ 'organ-loose-child'        , "organ#nest#navig('loose_child')"   ] ,
	\ [ 'organ-strict-child'       , "organ#nest#navig('strict_child')"  ] ,
	\ [ 'organ-info'               , 'organ#bird#info'                   ] ,
	\ [ 'organ-goto-headline'      , 'organ#bird#goto'                   ] ,
	\ [ 'organ-cycle-fold'         , 'organ#origami#cycle_current_fold'  ] ,
	\ [ 'organ-cycle-all-folds'    , 'organ#origami#cycle_all_folds'     ] ,
	\ [ 'organ-select-subtree'     , "organ#nest#oper('select_subtree')" ] ,
	\ [ 'organ-yank-subtree'       , "organ#nest#oper('yank_subtree')"   ] ,
	\ [ 'organ-delete-subtree'     , "organ#nest#oper('delete_subtree')" ] ,
	\ [ 'organ-meta-return'        , 'organ#nest#meta_return()'          ] ,
	\ [ 'organ-shift-return'       , 'organ#nest#shift_return()'         ] ,
	\ [ 'organ-tab'                , 'organ#nest#tab()'                  ] ,
	\ [ 'organ-shift-tab'          , 'organ#nest#shift_tab()'            ] ,
	\ [ 'organ-meta-left'          , 'organ#nest#meta_left()'            ] ,
	\ [ 'organ-meta-right'         , 'organ#nest#meta_right()'           ] ,
	\ [ 'organ-meta-up'            , 'organ#nest#meta_up()'              ] ,
	\ [ 'organ-meta-down'          , 'organ#nest#meta_down()'            ] ,
	\ [ 'organ-shift-left'         , 'organ#nest#shift_left()'           ] ,
	\ [ 'organ-shift-right'        , 'organ#nest#shift_right()'          ] ,
	\ [ 'organ-shift-up'           , 'organ#nest#shift_up()'             ] ,
	\ [ 'organ-shift-down'         , 'organ#nest#shift_down()'           ] ,
	\ [ 'organ-meta-shift-left'    , 'organ#nest#meta_shift_left()'      ] ,
	\ [ 'organ-meta-shift-right'   , 'organ#nest#meta_shift_right()'     ] ,
	\ [ 'organ-meta-shift-up'      , 'organ#nest#meta_shift_up()'        ] ,
	\ [ 'organ-meta-shift-down'    , 'organ#nest#meta_shift_down()'      ] ,
	\ [ 'organ-move-subtree-to'    , 'organ#tree#moveto'                 ] ,
	\ [ 'organ-toggle-tag'         , 'organ#tree#tag'                    ] ,
	\ [ 'organ-toggle-checkbox'    , 'organ#bush#toggle_checkbox'        ] ,
	\ [ 'organ-align'              , 'organ#table#align'                 ] ,
	\ [ 'organ-new-separator-line' , 'organ#table#new_separator_line'    ] ,
	\ [ 'organ-store-url'          , 'organ#vine#store'                  ] ,
	\ [ 'organ-new-link'           , 'organ#vine#new'                    ] ,
	\ [ 'organ-previous-link'      , 'organ#vine#previous'               ] ,
	\ [ 'organ-next-link'          , 'organ#vine#next'                   ] ,
	\ [ 'organ-goto-link-target'   , 'organ#vine#goto'                   ] ,
	\ [ 'organ-expand-template'    , 'organ#seed#expand'                 ] ,
	\ [ 'organ-timestamp'          , 'organ#abacus#timestamp'            ] ,
	\ [ 'organ-eval-vim'           , 'organ#abacus#eval_vim'             ] ,
	\ [ 'organ-eval-python'        , 'organ#abacus#eval_python'          ] ,
	\ [ 'organ-unicode'            , 'organ#calligraphy#insert'          ] ,
	\ [ 'organ-export'             , 'organ#nest#export'                 ] ,
	\ [ 'organ-alter-export'       , 'organ#nest#alter_export'           ] ,
	\ ]
lockvar! s:plugs_normal

if exists('s:plugs_visual')
	unlockvar! s:plugs_visual
endif
let s:plugs_visual = [
	\ [ 'organ-align'       , "organ#table#align('visual')" ]  ,
	\ [ 'organ-shift-left'  , 'organ#nest#shift_left()'     ]  ,
	\ [ 'organ-shift-right' , 'organ#nest#shift_right()'    ]  ,
	\ ]
lockvar! s:plugs_visual

if exists('s:plugs_insert')
	unlockvar! s:plugs_insert
endif
let s:plugs_insert = [
	\ [ 'organ-previous'           , "organ#nest#navig('previous')"      ] ,
	\ [ 'organ-next'               , "organ#nest#navig('next')"          ] ,
	\ [ 'organ-backward'           , "organ#nest#navig('backward')"      ] ,
	\ [ 'organ-forward'            , "organ#nest#navig('forward')"       ] ,
	\ [ 'organ-parent'             , "organ#nest#navig('parent')"        ] ,
	\ [ 'organ-loose-child'        , "organ#nest#navig('loose_child')"   ] ,
	\ [ 'organ-strict-child'       , "organ#nest#navig('strict_child')"  ] ,
	\ [ 'organ-info'               , 'organ#bird#info'                   ] ,
	\ [ 'organ-goto-headline'      , 'organ#bird#goto'                   ] ,
	\ [ 'organ-cycle-fold'         , 'organ#origami#cycle_current_fold'  ] ,
	\ [ 'organ-cycle-all-folds'    , 'organ#origami#cycle_all_folds'     ] ,
	\ [ 'organ-select-subtree'     , "organ#nest#oper('select_subtree')" ] ,
	\ [ 'organ-yank-subtree'       , "organ#nest#oper('yank_subtree')"   ] ,
	\ [ 'organ-delete-subtree'     , "organ#nest#oper('delete_subtree')" ] ,
	\ [ 'organ-meta-return'        , "organ#nest#meta_return('insert')"  ] ,
	\ [ 'organ-shift-return'       , 'organ#nest#shift_return()'         ] ,
	\ [ 'organ-tab'                , "organ#nest#tab('insert')"          ] ,
	\ [ 'organ-shift-tab'          , "organ#nest#shift_tab('insert')"    ] ,
	\ [ 'organ-meta-left'          , 'organ#nest#meta_left()'            ] ,
	\ [ 'organ-meta-right'         , 'organ#nest#meta_right()'           ] ,
	\ [ 'organ-meta-up'            , 'organ#nest#meta_up()'              ] ,
	\ [ 'organ-meta-down'          , 'organ#nest#meta_down()'            ] ,
	\ [ 'organ-shift-left'         , 'organ#nest#shift_left()'           ] ,
	\ [ 'organ-shift-right'        , 'organ#nest#shift_right()'          ] ,
	\ [ 'organ-shift-up'           , 'organ#nest#shift_up()'             ] ,
	\ [ 'organ-shift-down'         , 'organ#nest#shift_down()'           ] ,
	\ [ 'organ-meta-shift-left'    , 'organ#nest#meta_shift_left()'      ] ,
	\ [ 'organ-meta-shift-right'   , 'organ#nest#meta_shift_right()'     ] ,
	\ [ 'organ-meta-shift-up'      , 'organ#nest#meta_shift_up()'        ] ,
	\ [ 'organ-meta-shift-down'    , 'organ#nest#meta_shift_down()'      ] ,
	\ [ 'organ-move-subtree-to'    , 'organ#tree#moveto'                 ] ,
	\ [ 'organ-toggle-tag'         , 'organ#tree#tag'                    ] ,
	\ [ 'organ-toggle-checkbox'    , 'organ#bush#toggle_checkbox'        ] ,
	\ [ 'organ-align'              , 'organ#table#align'                 ] ,
	\ [ 'organ-new-separator-line' , 'organ#table#new_separator_line'    ] ,
	\ [ 'organ-store-url'          , 'organ#vine#store'                  ] ,
	\ [ 'organ-new-link'           , 'organ#vine#new'                    ] ,
	\ [ 'organ-previous-link'      , 'organ#vine#previous'               ] ,
	\ [ 'organ-next-link'          , 'organ#vine#next'                   ] ,
	\ [ 'organ-goto-link-target'   , 'organ#vine#goto'                   ] ,
	\ [ 'organ-expand-template'    , 'organ#seed#expand'                 ] ,
	\ [ 'organ-timestamp'          , 'organ#abacus#timestamp'            ] ,
	\ [ 'organ-eval-vim'           , 'organ#abacus#eval_vim'             ] ,
	\ [ 'organ-eval-python'        , 'organ#abacus#eval_python'          ] ,
	\ [ 'organ-unicode'            , 'organ#calligraphy#insert'          ] ,
	\ [ 'organ-export'             , 'organ#nest#export'                 ] ,
	\ [ 'organ-alter-export'       , 'organ#nest#alter_export'           ] ,
	\ ]
lockvar! s:plugs_insert

" ---- maps

if exists('s:maps_normal')
	unlockvar! s:maps_normal
endif
let s:maps_normal = [
	\ [ '<m-!>'       , 'organ-enable'             ] ,
	\ [ '<m-p>'       , 'organ-previous'           ] ,
	\ [ '<m-n>'       , 'organ-next'               ] ,
	\ [ '<m-b>'       , 'organ-backward'           ] ,
	\ [ '<m-f>'       , 'organ-forward'            ] ,
	\ [ '<m-u>'       , 'organ-parent'             ] ,
	\ [ '<m-l>'       , 'organ-loose-child'        ] ,
	\ [ '<m-s-l>'     , 'organ-strict-child'       ] ,
	\ [ '<m-i>'       , 'organ-info'               ] ,
	\ [ '<m-h>'       , 'organ-goto-headline'      ] ,
	\ [ '<m-z>'       , 'organ-cycle-fold'         ] ,
	\ [ '<m-s-z>'     , 'organ-cycle-all-folds'    ] ,
	\ [ '<m-v>'       , 'organ-select-subtree'     ] ,
	\ [ '<m-y>'       , 'organ-yank-subtree'       ] ,
	\ [ '<m-s-x>'     , 'organ-delete-subtree'     ] ,
	\ [ '<m-cr>'      , 'organ-meta-return'        ] ,
	\ [ '<s-cr>'      , 'organ-shift-return'       ] ,
	\ [ '<m-left>'    , 'organ-meta-left'          ] ,
	\ [ '<m-right>'   , 'organ-meta-right'         ] ,
	\ [ '<m-up>'      , 'organ-meta-up'            ] ,
	\ [ '<m-down>'    , 'organ-meta-down'          ] ,
	\ [ '<s-left>'    , 'organ-shift-left'         ] ,
	\ [ '<s-right>'   , 'organ-shift-right'        ] ,
	\ [ '<s-up>'      , 'organ-shift-up'           ] ,
	\ [ '<s-down>'    , 'organ-shift-down'         ] ,
	\ [ '<m-s-left>'  , 'organ-meta-shift-left'    ] ,
	\ [ '<m-s-right>' , 'organ-meta-shift-right'   ] ,
	\ [ '<m-s-up>'    , 'organ-meta-shift-up'      ] ,
	\ [ '<m-s-down>'  , 'organ-meta-shift-down'    ] ,
	\ [ '<tab>'       , 'organ-tab'                ] ,
	\ [ '<s-tab>'     , 'organ-shift-tab'          ] ,
	\ [ '<m-m>'       , 'organ-move-subtree-to'    ] ,
	\ [ '<m-t>'       , 'organ-toggle-tag'         ] ,
	\ [ '<m-c>'       , 'organ-toggle-checkbox'    ] ,
	\ [ '<m-a>'       , 'organ-align'              ] ,
	\ [ '<m-_>'       , 'organ-new-separator-line' ] ,
	\ [ '<m-s>'       , 'organ-store-url'          ] ,
	\ [ '<m-->'       , 'organ-new-link'           ] ,
	\ [ '<m-@>'       , 'organ-previous-link'      ] ,
	\ [ '<m-&>'       , 'organ-next-link'          ] ,
	\ [ '<m-o>'       , 'organ-goto-link-target'   ] ,
	\ [ '<m-x>'       , 'organ-expand-template'    ] ,
	\ [ '<m-d>'       , 'organ-timestamp'          ] ,
	\ [ '<m-=>'       , 'organ-eval-vim'           ] ,
	\ [ "<m-'>"       , 'organ-eval-python'        ] ,
	\ [ '<m-$>'       , 'organ-unicode'            ] ,
	\ [ '<m-e>'       , 'organ-export'             ] ,
	\ [ '<m-s-e>'     , 'organ-alter-export'       ] ,
	\ ]
lockvar! s:maps_normal

if exists('s:maps_visual')
	unlockvar! s:maps_visual
endif
let s:maps_visual = [
	\ [ '<m-a>'     , 'organ-align'       ]  ,
	\ [ '<s-left>'  , 'organ-shift-left'  ]  ,
	\ [ '<s-right>' , 'organ-shift-right' ]  ,
	\]
lockvar! s:maps_visual

if exists('s:maps_insert')
	unlockvar! s:maps_insert
endif
let s:maps_insert = [
	\ [ '<m-p>'       , 'organ-previous'           ] ,
	\ [ '<m-n>'       , 'organ-next'               ] ,
	\ [ '<m-b>'       , 'organ-backward'           ] ,
	\ [ '<m-f>'       , 'organ-forward'            ] ,
	\ [ '<m-u>'       , 'organ-parent'             ] ,
	\ [ '<m-l>'       , 'organ-loose-child'        ] ,
	\ [ '<m-s-l>'     , 'organ-strict-child'       ] ,
	\ [ '<m-i>'       , 'organ-info'               ] ,
	\ [ '<m-h>'       , 'organ-goto-headline'      ] ,
	\ [ '<m-z>'       , 'organ-cycle-fold'         ] ,
	\ [ '<m-s-z>'     , 'organ-cycle-all-folds'    ] ,
	\ [ '<m-v>'       , 'organ-select-subtree'     ] ,
	\ [ '<m-y>'       , 'organ-yank-subtree'       ] ,
	\ [ '<m-s-x>'     , 'organ-delete-subtree'     ] ,
	\ [ '<m-cr>'      , 'organ-meta-return'        ] ,
	\ [ '<s-cr>'      , 'organ-shift-return'       ] ,
	\ [ '<m-left>'    , 'organ-meta-left'          ] ,
	\ [ '<m-right>'   , 'organ-meta-right'         ] ,
	\ [ '<m-up>'      , 'organ-meta-up'            ] ,
	\ [ '<m-down>'    , 'organ-meta-down'          ] ,
	\ [ '<s-left>'    , 'organ-shift-left'         ] ,
	\ [ '<s-right>'   , 'organ-shift-right'        ] ,
	\ [ '<s-up>'      , 'organ-shift-up'           ] ,
	\ [ '<s-down>'    , 'organ-shift-down'         ] ,
	\ [ '<m-s-left>'  , 'organ-meta-shift-left'    ] ,
	\ [ '<m-s-right>' , 'organ-meta-shift-right'   ] ,
	\ [ '<m-s-up>'    , 'organ-meta-shift-up'      ] ,
	\ [ '<m-s-down>'  , 'organ-meta-shift-down'    ] ,
	\ [ '<tab>'       , 'organ-tab'                ] ,
	\ [ '<s-tab>'     , 'organ-shift-tab'          ] ,
	\ [ '<m-m>'       , 'organ-move-subtree-to'    ] ,
	\ [ '<m-t>'       , 'organ-toggle-tag'         ] ,
	\ [ '<m-c>'       , 'organ-toggle-checkbox'    ] ,
	\ [ '<m-a>'       , 'organ-align'              ] ,
	\ [ '<m-_>'       , 'organ-new-separator-line' ] ,
	\ [ '<m-s>'       , 'organ-store-url'          ] ,
	\ [ '<m-->'       , 'organ-new-link'           ] ,
	\ [ '<m-@>'       , 'organ-previous-link'      ] ,
	\ [ '<m-&>'       , 'organ-next-link'          ] ,
	\ [ '<m-o>'       , 'organ-goto-link-target'   ] ,
	\ [ '<m-x>'       , 'organ-expand-template'    ] ,
	\ [ '<m-d>'       , 'organ-timestamp'          ] ,
	\ [ '<m-=>'       , 'organ-eval-vim'           ] ,
	\ [ "<m-'>"       , 'organ-eval-python'        ] ,
	\ [ '<m-$>'       , 'organ-unicode'            ] ,
	\ [ '<m-e>'       , 'organ-export'             ] ,
	\ [ '<m-s-e>'     , 'organ-alter-export'       ] ,
	\ ]
lockvar! s:maps_insert

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
