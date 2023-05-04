" vim: set ft=vim fdm=indent iskeyword&:

" Diadem
"
" Internal Constants for commands

" ---- commands

if ! exists('s:command_meta_actions')
	let s:command_meta_actions = [
		\ [ 'previous'                      , "organ#nest#navig('previous')"             ] ,
		\ [ 'next'                          , "organ#nest#navig('next')"                 ] ,
		\ [ 'backward'                      , "organ#nest#navig('backward')"             ] ,
		\ [ 'forward'                       , "organ#nest#navig('forward')"              ] ,
		\ [ 'parent'                        , "organ#nest#navig('parent')"               ] ,
		\ [ 'child-loose'                   , "organ#nest#navig('loose_child')"          ] ,
		\ [ 'child-strict'                  , "organ#nest#navig('strict_child')"         ] ,
		\ [ 'whereami'                      , 'organ#bird#whereami'                      ] ,
		\ [ 'goto-headline'                 , 'organ#bird#goto_path'                     ] ,
		\ [ 'cycle-current-fold-visibility' , 'organ#bird#cycle_current_fold'            ] ,
		\ [ 'cycle-all-folds-visibililty'   , 'organ#bird#cycle_all_folds'               ] ,
		\ [ 'new'                           , "organ#nest#oper('new')"                   ] ,
		\ [ 'select-subtree'                , "organ#nest#oper('select_subtree')"        ] ,
		\ [ 'yank-subtree'                  , "organ#nest#oper('yank_subtree')"          ] ,
		\ [ 'delete-subtree'                , "organ#nest#oper('delete_subtree')"        ] ,
		\ [ 'promote'                       , "organ#nest#oper('promote')"               ] ,
		\ [ 'demote'                        , "organ#nest#oper('demote')"                ] ,
		\ [ 'promote-subtree'               , "organ#nest#oper('promote_subtree')"       ] ,
		\ [ 'demote-subtree'                , "organ#nest#oper('demote_subtree')"        ] ,
		\ [ 'move-subtree-up'               , "organ#nest#oper('move_subtree_backward')" ] ,
		\ [ 'move-subtree-down'             , "organ#nest#oper('move_subtree_forward')"  ] ,
		\ [ 'move-subtree-to'               , 'organ#tree#moveto'                        ] ,
		\ [ 'expand-template'               , 'organ#seed#expand'                        ] ,
		\ [ 'store-url'                     , 'organ#vine#store'                         ] ,
		\ [ 'new-link'                      , 'organ#vine#new'                           ] ,
		\ [ 'format-table'                  , 'organ#table#format'                       ] ,
		\ [ 'export-with-pandoc'            , 'organ#pipe#pandoc_export'                 ] ,
		\ [ 'export-with-emacs'             , 'organ#pipe#emacs_export'                  ] ,
		\ [ 'export-with-asciidoc'          , 'organ#pipe#asciidoc_export'               ] ,
		\ [ 'export-with-asciidoctor'       , 'organ#pipe#asciidoctor_export'            ] ,
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
