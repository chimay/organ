" vim: set ft=vim fdm=indent iskeyword&:

" Diadem
"
" Internal Constants for commands

" ---- commands

if ! exists('s:command_meta_actions')
	let s:command_meta_actions = [
				\ [ 'previous'           , 'organ#bird#previous'                       ] ,
				\ [ 'next'               , 'organ#bird#next'                           ] ,
				\ [ 'backward'           , 'organ#bird#backward'                       ] ,
				\ [ 'forward'            , 'organ#bird#forward'                        ] ,
				\ [ 'parent'             , 'organ#bird#parent'                         ] ,
				\ [ 'child-loose'        , 'organ#bird#loose_child'                    ] ,
				\ [ 'child-strict'       , 'organ#bird#strict_child'                   ] ,
				\ [ 'whereami'           , 'organ#bird#whereami'                       ] ,
				\ [ 'goto-headline'      , 'organ#bird#goto_path'                      ] ,
				\ [ 'cycle-current'      , 'organ#bird#cycle_current_fold'             ] ,
				\ [ 'cycle-global'       , 'organ#bird#cycle_all_folds'                ] ,
				\ [ 'select-subtree'     , 'organ#tree#select_subtree'                 ] ,
				\ [ 'yank-subtree'       , 'organ#tree#yank_subtree'                   ] ,
				\ [ 'delete-subtree'     , 'organ#tree#delete_subtree'                 ] ,
				\ [ 'new'                , "organ#nest#oper('new')"                   ] ,
				\ [ 'promote'            , "organ#nest#oper('promote')"               ] ,
				\ [ 'demote'             , "organ#nest#oper('demote')"                ] ,
				\ [ 'promote-subtree'    , "organ#nest#oper('promote_subtree')"       ] ,
				\ [ 'demote-subtree'     , "organ#nest#oper('demote_subtree')"        ] ,
				\ [ 'move-subtree-up'    , "organ#nest#oper('move_subtree_backward')" ] ,
				\ [ 'move-subtree-down'  , "organ#nest#oper('move_subtree_forward')"  ] ,
				\ [ 'export-with-pandoc' , 'organ#pipe#pandoc_export'                  ] ,
				\ [ 'export-with-emacs'  , 'organ#pipe#emacs_export'                   ] ,
				\ ]
	lockvar! s:command_meta_actions
endif

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