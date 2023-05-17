" vim: set ft=vim fdm=indent iskeyword&:

" Diadem
"
" Internal Constants for commands

" ---- commands

if exists('s:command_meta_actions')
	unlockvar! s:command_meta_actions
endif
let s:command_meta_actions = [
	\ [ 'previous'                , "organ#nest#navig('previous')"             ] ,
	\ [ 'next'                    , "organ#nest#navig('next')"                 ] ,
	\ [ 'backward'                , "organ#nest#navig('backward')"             ] ,
	\ [ 'forward'                 , "organ#nest#navig('forward')"              ] ,
	\ [ 'parent'                  , "organ#nest#navig('parent')"               ] ,
	\ [ 'child-loose'             , "organ#nest#navig('loose_child')"          ] ,
	\ [ 'child-strict'            , "organ#nest#navig('strict_child')"         ] ,
	\ [ 'info'                    , 'organ#bird#info'                          ] ,
	\ [ 'goto-headline'           , 'organ#bird#goto'                          ] ,
	\ [ 'cycle-fold'              , 'organ#bird#cycle_current_fold'            ] ,
	\ [ 'cycle-all-folds'         , 'organ#bird#cycle_all_folds'               ] ,
	\ [ 'new'                     , "organ#nest#oper('new')"                   ] ,
	\ [ 'select-subtree'          , "organ#nest#oper('select_subtree')"        ] ,
	\ [ 'yank-subtree'            , "organ#nest#oper('yank_subtree')"          ] ,
	\ [ 'delete-subtree'          , "organ#nest#oper('delete_subtree')"        ] ,
	\ [ 'promote'                 , "organ#nest#oper('promote')"               ] ,
	\ [ 'demote'                  , "organ#nest#oper('demote')"                ] ,
	\ [ 'promote-subtree'         , "organ#nest#oper('promote_subtree')"       ] ,
	\ [ 'demote-subtree'          , "organ#nest#oper('demote_subtree')"        ] ,
	\ [ 'move-subtree-up'         , "organ#nest#oper('move_subtree_backward')" ] ,
	\ [ 'move-subtree-down'       , "organ#nest#oper('move_subtree_forward')"  ] ,
	\ [ 'move-subtree-to'         , 'organ#tree#moveto'                        ] ,
	\ [ 'tag'                     , 'organ#tree#tag'                           ] ,
	\ [ 'toggle-checkbox'         , 'organ#bush#toggle_checkbox'               ] ,
	\ [ 'cycle-todo-right'        , "organ#nest#oper('cycle_todo_right')"      ] ,
	\ [ 'cycle-todo-left'         , "organ#nest#oper('cycle_todo_left')"       ] ,
	\ [ 'align'                   , 'organ#table#align'                        ] ,
	\ [ 'next-cell'               , 'organ#table#next_cell'                    ] ,
	\ [ 'previous-cell'           , 'organ#table#previous_cell'                ] ,
	\ [ 'move-row-up'             , 'organ#table#move_row_up'                  ] ,
	\ [ 'move-row-down'           , 'organ#table#move_row_down'                ] ,
	\ [ 'move-col-left'           , 'organ#table#move_col_left'                ] ,
	\ [ 'move-col-right'          , 'organ#table#move_col_right'               ] ,
	\ [ 'new-row'                 , 'organ#table#new_row'                      ] ,
	\ [ 'new-col'                 , 'organ#table#new_col'                      ] ,
	\ [ 'delete-row'              , 'organ#table#delete_row'                   ] ,
	\ [ 'delete-col'              , 'organ#table#delete_col'                   ] ,
	\ [ 'store-url'               , 'organ#vine#store'                         ] ,
	\ [ 'new-link'                , 'organ#vine#new'                           ] ,
	\ [ 'previous-link'           , 'organ#vine#previous'                      ] ,
	\ [ 'next-link'               , 'organ#vine#next'                          ] ,
	\ [ 'goto-link-target'        , 'organ#vine#goto'                          ] ,
	\ [ 'export'                  , 'organ#nest#export'                        ] ,
	\ [ 'alter-export'            , 'organ#nest#alter_export'                  ] ,
	\ [ 'expand-template'         , 'organ#seed#expand'                        ] ,
	\ [ 'timestamp'               , 'organ#utils#timestamp'                    ] ,
	\ [ 'unicode'                 , 'organ#calligraphy#insert'                 ] ,
	\ [ 'export-with-pandoc'      , 'organ#pipe#pandoc_export'                 ] ,
	\ [ 'export-with-emacs'       , 'organ#pipe#emacs_export'                  ] ,
	\ [ 'export-with-asciidoc'    , 'organ#pipe#asciidoc_export'               ] ,
	\ [ 'export-with-asciidoctor' , 'organ#pipe#asciidoctor_export'            ] ,
	\ [ 'org-to-markdown'         , 'organ#nest#org2markdown'                  ] ,
	\ [ 'markdown-to-org'         , 'organ#nest#markdown2org'                  ] ,
	\ ]
lockvar! s:command_meta_actions

" ---- public interface

fun! organ#diadem#fetch (varname, conversion = 'no-conversion')
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
		return organ#matrix#items2dict ({varname})
	else
		return {varname}
	endif
endfun
