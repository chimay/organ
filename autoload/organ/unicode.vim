" vim: set ft=vim fdm=indent iskeyword&:

" Unicode
"
" Internal Constants for unicode characters

" ---- punctuation

if exists('s:punctuation')
unlockvar! s:punctuation
endif
let s:punctuation = [
	\ [ 'nbsp'                     , ' ' ],
	\ [ 'sect'                     , '§' ],
	\ [ 'para pilcrow'             , '¶' ],
	\ [ 'micro'                    , 'µ' ],
	\ [ 'left double angle quote'  , '«' ],
	\ [ 'right double angle quote' , '»' ],
\ ]
lockvar! s:punctuation

" ---- greek

if exists('s:greek_lowercase')
unlockvar! s:greek_lowercase
endif
let s:greek_lowercase = [
	\ [ 'alpha'            , 'α' ],
	\ [ 'beta'             , 'β' ],
	\ [ 'gamma'            , 'γ' ],
	\ [ 'digamma'          , 'ϝ' ],
	\ [ 'delta'            , 'δ' ],
	\ [ 'epsilon'          , 'ε' ],
	\ [ 'epsilon-straight' , 'ϵ' ],
	\ [ 'zeta'             , 'ζ' ],
	\ [ 'eta'              , 'η' ],
	\ [ 'theta'            , 'θ' ],
	\ [ 'theta-sym'        , 'ϑ' ],
	\ [ 'iota'             , 'ι' ],
	\ [ 'kappa'            , 'κ' ],
	\ [ 'kappa-var'        , 'ϰ' ],
	\ [ 'lambda'           , 'λ' ],
	\ [ 'mu'               , 'μ' ],
	\ [ 'nu'               , 'ν' ],
	\ [ 'xi'               , 'ξ' ],
	\ [ 'omicron'          , 'ο' ],
	\ [ 'pi'               , 'π' ],
	\ [ 'pi-var'           , 'ϖ' ],
	\ [ 'rho'              , 'ρ' ],
	\ [ 'rho-var'          , 'ϱ' ],
	\ [ 'sigma'            , 'σ' ],
	\ [ 'sigma-final'      , 'ς' ],
	\ [ 'tau'              , 'τ' ],
	\ [ 'upsilon'          , 'υ' ],
	\ [ 'upsilon-hook'     , 'ϒ' ],
	\ [ 'phi'              , 'φ' ],
	\ [ 'phi-straight'     , 'ϕ' ],
	\ [ 'chi'              , 'χ' ],
	\ [ 'psi'              , 'ψ' ],
	\ [ 'omega'            , 'ω' ],
\ ]
lockvar! s:greek_lowercase

if exists('s:greek_uppercase')
unlockvar! s:greek_uppercase
endif
let s:greek_uppercase = [
	\ [ 'Alpha'        , 'Α' ],
	\ [ 'Beta'         , 'Β' ],
	\ [ 'Gamma'        , 'Γ' ],
	\ [ 'Digamma'      , 'Ϝ' ],
	\ [ 'Delta'        , 'Δ' ],
	\ [ 'Epsilon'      , 'Ε' ],
	\ [ 'Zeta'         , 'Ζ' ],
	\ [ 'Eta'          , 'Η' ],
	\ [ 'Theta'        , 'Θ' ],
	\ [ 'Iota'         , 'Ι' ],
	\ [ 'Kappa'        , 'Κ' ],
	\ [ 'Lambda'       , 'Λ' ],
	\ [ 'Mu'           , 'Μ' ],
	\ [ 'Nu'           , 'Ν' ],
	\ [ 'Xi'           , 'Ξ' ],
	\ [ 'Omicron'      , 'Ο' ],
	\ [ 'Pi'           , 'Π' ],
	\ [ 'Rho'          , 'Ρ' ],
	\ [ 'Sigma'        , 'Σ' ],
	\ [ 'Tau'          , 'Τ' ],
	\ [ 'Upsilon'      , 'Υ' ],
	\ [ 'Phi'          , 'Φ' ],
	\ [ 'Chi'          , 'Χ' ],
	\ [ 'Psi'          , 'Ψ' ],
	\ [ 'Omega'        , 'Ω' ],
\ ]
lockvar! s:greek_uppercase

" ---- mathematics

if exists('s:math_basic')
unlockvar! s:math_basic
endif
let s:math_basic = [
	\ [ 'equiv'            , '≡' ],
	\ [ 'less or equal'    , '≤' ],
	\ [ 'greater or equal' , '≥' ],
	\ [ 'for all'          , '∀' ],
	\ [ 'exists'           , '∃' ],
	\ [ 'does not exists'  , '∄' ],
\ ]
lockvar! s:math_basic

if exists('s:math_set')
unlockvar! s:math_set
endif
let s:math_set = [
	\ [ 'empty set'             , '∅ ' ],
	\ [ 'element of'            , '∈'  ],
	\ [ 'not element of'        , '∉'  ],
	\ [ 'subset of'             , '⊂'  ],
	\ [ 'subset of'             , '⊂'  ],
	\ [ 'subset of or equal to' , '⊆'  ],
	\ [ 'subset of or equal to' , '⊇'  ],
	\ [ 'not superset of'       , '⊄'  ],
	\ [ 'not superset of'       , '⊅'  ],
	\ [ 'union'                 , '∪'  ],
	\ [ 'intersection'          , '∩'  ],
\ ]
lockvar! s:math_set

if exists('s:math_operators')
unlockvar! s:math_operators
endif
let s:math_operators= [
	\ [ 'times'            , '×'  ],
	\ [ 'divide'           , '÷'  ],
	\ [ 'plus minus'       , '±'  ],
	\ [ 'circled plus'     , '⊕ ' ],
	\ [ 'circled times'    , '⊗ ' ],
	\ [ 'circled dot'      , '⊙  '],
	\ [ 'circled division' , '⊘ ' ],
	\ [ 'square root'      , '√'  ],
	\ [ 'partial diff'     , '∂'  ],
	\ [ 'delta increment'  , '∆'  ],
	\ [ 'nabla'            , '∇'  ],
	\ [ 'n sum'            , '∑'  ],
	\ [ 'n product'        , '∏'  ],
	\ [ 'integral'         , '∫'  ],
	\ [ 'contour integral' , '∮'  ],
\ ]
lockvar! s:math_operators

if exists('s:math_misc')
unlockvar! s:math_misc
endif
let s:math_misc= [
	\ [ 'infinity'        , '∞'  ],
	\ [ 'perp'            , '⊥'  ],
	\ [ 'dagger'          , '†'  ],
\ ]
lockvar! s:math_misc

" ---- music

if exists('s:music')
unlockvar! s:music
endif
let s:music = [
	\ [ 'sharp'   , '♯'  ],
	\ [ 'natural' , '♮'  ],
	\ [ 'flat'    , '♭'  ],
	\ [ 'tie'     , '‿'  ],
\ ]
lockvar! s:music

" ---- miscellaneous

if exists('s:miscellaneous')
unlockvar! s:miscellaneous
endif
let s:miscellaneous = [
	\ [ 'm dash'    , '—' ],
	\ [ 'breve bar' , '¦' ],
\ ]
lockvar! s:miscellaneous

" ---- all together

if exists('s:lists')
	unlockvar! s:lists
endif
let s:lists = [
			\ 'punctuation',
			\ 'greek uppercase',
			\ 'greek lowercase',
			\ 'math_set',
			\ 'math_operators',
			\ 'math_misc',
			\ 'music',
			\ 'miscellaneous',
			\ ]
lockvar! s:lists

if exists('s:all')
	unlockvar! s:all
endif
let s:all = []
for s:name in s:lists
	let s:formated = substitute(s:name, ' ', '_', 'g')
	eval s:all->extend(s:{s:formated})
endfor
lockvar! s:all

" ---- public interface

fun! organ#unicode#fetch (varname, conversion = 'no-conversion')
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
