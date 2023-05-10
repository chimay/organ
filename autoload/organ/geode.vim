" vim: set ft=vim fdm=indent iskeyword&:

" Geode
"
" Internal Constants for plugs & maps

" ---- speed keys

if ! exists('s:speedkeys')
	let s:speedkeys = [
		\ [ '<f1>',       'organ#nest#speed_help()'                  ] ,
		\ [ '<pageup>',   "organ#nest#navig('previous')"             ] ,
		\ [ '<pagedown>', "organ#nest#navig('next')"                 ] ,
		\ [ '<home>',     "organ#nest#navig('backward')"             ] ,
		\ [ '<end>',      "organ#nest#navig('forward')"              ] ,
		\ [ '+',          "organ#nest#navig('parent')"               ] ,
		\ [ '-',          "organ#nest#navig('loose_child')"          ] ,
		\ [ '_',          "organ#nest#navig('strict_child')"         ] ,
		\ [ '<kplus>',    "organ#nest#navig('parent')"               ] ,
		\ [ '<kminus>',   "organ#nest#navig('loose_child')"          ] ,
		\ [ 'i',          'organ#bird#info'                          ] ,
		\ [ 'h',          'organ#bird#goto'                          ] ,
		\ [ '<tab>',      'organ#bird#cycle_current_fold'            ] ,
		\ [ '<s-tab>',    'organ#bird#cycle_all_folds'               ] ,
		\ [ 's',          "organ#nest#oper('select_subtree')"        ] ,
		\ [ 'Y',          "organ#nest#oper('yank_subtree')"          ] ,
		\ [ 'X',          "organ#nest#oper('delete_subtree')"        ] ,
		\ [ '<del>',      "organ#nest#oper('promote')"               ] ,
		\ [ '<ins>',      "organ#nest#oper('demote')"                ] ,
		\ [ 'H',          "organ#nest#oper('promote_subtree')"       ] ,
		\ [ 'L',          "organ#nest#oper('demote_subtree')"        ] ,
		\ [ 'U',          "organ#nest#oper('move_subtree_backward')" ] ,
		\ [ 'D',          "organ#nest#oper('move_subtree_forward')"  ] ,
		\ [ 'M',          'organ#tree#moveto'                        ] ,
		\ [ 't',          "organ#nest#oper('todo')"                  ] ,
		\ [ 'e',          'organ#pipe#pandoc_export'                 ] ,
		\ [ 'E',          'organ#pipe#emacs_export'                  ] ,
		\ [ 'a',          'organ#pipe#asciidoc_export'               ] ,
		\ [ 'A',          'organ#pipe#asciidoctor_export'            ] ,
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
		\ [ 'organ-info'                          , 'organ#bird#info'                          ] ,
		\ [ 'organ-goto-headline'                 , 'organ#bird#goto'                          ] ,
		\ [ 'organ-cycle-current-fold-visibility' , 'organ#bird#cycle_current_fold'            ] ,
		\ [ 'organ-cycle-all-folds-visibility'    , 'organ#bird#cycle_all_folds'               ] ,
		\ [ 'organ-new'                           , "organ#nest#oper('new')"                   ] ,
		\ [ 'organ-select-subtree'                , "organ#nest#oper('select_subtree')"        ] ,
		\ [ 'organ-yank-subtree'                  , "organ#nest#oper('yank_subtree')"          ] ,
		\ [ 'organ-delete-subtree'                , "organ#nest#oper('delete_subtree')"        ] ,
		\ [ 'organ-meta-left'                     , 'organ#nest#meta_left()'                   ] ,
		\ [ 'organ-meta-right'                    , 'organ#nest#meta_right()'                  ] ,
		\ [ 'organ-meta-up'                       , 'organ#nest#meta_up()'                     ] ,
		\ [ 'organ-meta-down'                     , 'organ#nest#meta_down()'                   ] ,
		\ [ 'organ-meta-shift-left'               , 'organ#nest#meta_shift_left()'             ] ,
		\ [ 'organ-meta-shift-right'              , 'organ#nest#meta_shift_right()'            ] ,
		\ [ 'organ-meta-shift-up'                 , 'organ#nest#meta_shift_up()'               ] ,
		\ [ 'organ-meta-shift-down'               , 'organ#nest#meta_shift_down()'             ] ,
		\ [ 'organ-tab'                           , 'organ#nest#tab()'                         ] ,
		\ [ 'organ-shift-tab'                     , 'organ#nest#shift_tab()'                   ] ,
		\ [ 'organ-move-subtree-to'               , 'organ#tree#moveto'                        ] ,
		\ [ 'organ-expand-template'               , 'organ#seed#expand'                        ] ,
		\ [ 'organ-store-url'                     , 'organ#vine#store'                         ] ,
		\ [ 'organ-new-link'                      , 'organ#vine#new'                           ] ,
		\ [ 'organ-previous-link'                 , 'organ#vine#previous'                      ] ,
		\ [ 'organ-next-link'                     , 'organ#vine#next'                          ] ,
		\ [ 'organ-goto-link-target'              , 'organ#vine#goto'                          ] ,
		\ [ 'organ-cycle-todo'                    , "organ#nest#oper('todo')"                  ] ,
		\ [ 'organ-timestamp'                     , 'organ#utils#timestamp'                    ] ,
		\ [ 'organ-align'                         , 'organ#table#align'                        ] ,
		\ [ 'organ-new-separator-line'            , 'organ#table#new_separator_line'           ] ,
		\ [ 'organ-export-pandoc'                 , 'organ#pipe#pandoc_export'                 ] ,
		\ [ 'organ-export-emacs'                  , 'organ#pipe#emacs_export'                  ] ,
		\ [ 'organ-export-asciidoc'               , 'organ#pipe#asciidoc_export'               ] ,
		\ [ 'organ-export-asciidoctor'            , 'organ#pipe#asciidoctor_export'            ] ,
		\ ]
	lockvar! s:plugs_normal
endif

if ! exists('s:plugs_visual')
	let s:plugs_visual = [
		\ [ 'organ-align' , "organ#table#align('visual')" ] ,
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
		\ [ '<m-p>'       , 'organ-previous'                      ] ,
		\ [ '<m-n>'       , 'organ-next'                          ] ,
		\ [ '<m-b>'       , 'organ-backward'                      ] ,
		\ [ '<m-f>'       , 'organ-forward'                       ] ,
		\ [ '<m-u>'       , 'organ-parent'                        ] ,
		\ [ '<m-l>'       , 'organ-loose-child'                   ] ,
		\ [ '<m-s-l>'     , 'organ-strict-child'                  ] ,
		\ [ '<m-i>'       , 'organ-info'                          ] ,
		\ [ '<m-h>'       , 'organ-goto-headline'                 ] ,
		\ [ '<m-z>'       , 'organ-cycle-current-fold-visibility' ] ,
		\ [ '<m-s-z>'     , 'organ-cycle-all-folds-visibility'    ] ,
		\ [ '<m-cr>'      , 'organ-new'                           ] ,
		\ [ '<m-v>'       , 'organ-select-subtree'                ] ,
		\ [ '<m-y>'       , 'organ-yank-subtree'                  ] ,
		\ [ '<m-s-x>'     , 'organ-delete-subtree'                ] ,
		\ [ '<m-left>'    , 'organ-meta-left'                     ] ,
		\ [ '<m-right>'   , 'organ-meta-right'                    ] ,
		\ [ '<m-up>'      , 'organ-meta-up'                       ] ,
		\ [ '<m-down>'    , 'organ-meta-down'                     ] ,
		\ [ '<m-s-left>'  , 'organ-meta-shift-left'               ] ,
		\ [ '<m-s-right>' , 'organ-meta-shift-right'              ] ,
		\ [ '<m-s-up>'    , 'organ-meta-shift-up'                 ] ,
		\ [ '<m-s-down>'  , 'organ-meta-shift-down'               ] ,
		\ [ '<tab>'       , 'organ-tab'                           ] ,
		\ [ '<s-tab>'     , 'organ-shift-tab'                     ] ,
		\ [ '<m-m>'       , 'organ-move-subtree-to'               ] ,
		\ [ '<m-x>'       , 'organ-expand-template'               ] ,
		\ [ '<m-s>'       , 'organ-store-url'                     ] ,
		\ [ '<m-->'       , 'organ-new-link'                      ] ,
		\ [ '<m-@>'       , 'organ-previous-link'                 ] ,
		\ [ '<m-&>'       , 'organ-next-link'                     ] ,
		\ [ '<m-o>'       , 'organ-goto-link-target'              ] ,
		\ [ '<m-t>'       , 'organ-cycle-todo'                    ] ,
		\ [ '<m-d>'       , 'organ-timestamp'                     ] ,
		\ [ '<m-a>'       , 'organ-align'                         ] ,
		\ [ '<m-_>'       , 'organ-new-separator-line'            ] ,
		\ [ '<m-e>'       , 'organ-export-pandoc'                 ] ,
		\ [ '<m-s-e>'     , 'organ-export-emacs'                  ] ,
		\ ]
	lockvar! s:maps_normal
endif

if ! exists('s:maps_visual')
	let s:maps_visual = [
		\ [ '<m-a>' , 'organ-align' ] ,
		\]
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
