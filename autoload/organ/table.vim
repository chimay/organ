" vim: set ft=vim fdm=indent iskeyword&:

" Table
"
" Table operations

" ---- script constants

if exists('s:indent_pattern')
	unlockvar s:indent_pattern
endif
let s:indent_pattern = organ#crystal#fetch('pattern/indent')
lockvar s:indent_pattern

" ---- helpers

" -- patterns

fun! organ#table#delimiter ()
	" Tables column char
	return '|'
endfun

fun! organ#table#separator_delimiter ()
	" Tables column delimiter in separator line
	if &filetype ==# 'org'
		return '+'
	elseif &filetype ==# 'markdown'
		return '|'
	endif
	return '+'
endfun

fun! organ#table#separator_delimiter_pattern ()
	" Tables column pattern in separator line
	if &filetype ==# 'org'
		return '[|+]'
	elseif &filetype ==# 'markdown'
		return '|'
	endif
	return '[|+]'
endfun

fun! organ#table#generic_pattern (...)
	" Generic table line pattern
	if a:0 > 0
		let delimiter = a:1
	else
		let delimiter = organ#table#delimiter ()
	endif
	let pattern = '\m^\s*' .. delimiter .. '.*'
	let pattern ..= '\&.*' .. delimiter .. '\s*$'
	return pattern
endfun

fun! organ#table#separator_pattern ()
	" Separator line pattern
	if &filetype ==# 'org'
		let pattern = '\m^\s*|-\+|\s*$\|'
		let pattern ..= '^\s*|\%(-*+\)\+-*|\s*$'
		return pattern
	elseif &filetype ==# 'markdown'
		let pattern = '\m^\s*|[-:]\+|\%([-:]*|\)*\s*$'
		return pattern
	else
		let pattern = '\m^\s*|[-+| ]*[-+]\+[-+| ]*|\s*$'
		return pattern
	endif
	" -- never matches
	"return '\m^$\&^.$'
endfun

fun! organ#table#outside_pattern (argdict = {})
	" Pattern for non table lines
	let argdict = a:argdict
	if has_key (argdict, 'delimiter')
		let delimiter =  argdict.delimiter
	else
		let delimiter = organ#table#delimiter ()
	endif
	let pattern = '\m^$\|'
	let pattern ..= '^\s*[^' .. delimiter .. ' ].*'
	let pattern ..= '\|.*[^' .. delimiter .. ' ]\s*$'
	return pattern
endfun

fun! organ#table#is_in_table (...)
	" Whether current line is in a table
	if a:0 > 0
		let linum = a:1
	else
		let linum = line('.')
	endif
	let line = getline(linum)
	let pattern = organ#table#generic_pattern ()
	return line =~ pattern
endfun

fun! organ#table#is_separator_line (...)
	" Whether current line is a separator line
	if a:0 > 0
		let linum = a:1
	else
		let linum = line('.')
	endif
	let line = getline(linum)
	let pattern = organ#table#separator_pattern ()
	return line =~ pattern
endfun

fun! organ#table#head (move = 'dont-move')
	" First line of table
	let move = a:move
	let flags = organ#utils#search_flags ('backward', move, 'dont-wrap')
	let linum = search('\m^\s*$', flags)
	if linum == 0
		echomsg 'organ table head : not found'
		return 1
	endif
	return linum + 1
endfun

fun! organ#table#tail (move = 'dont-move')
	" Last line of table
	let move = a:move
	let flags = organ#utils#search_flags ('forward', move, 'dont-wrap')
	let linum = search('\m^\s*$', flags)
	if linum == 0
		echomsg 'organ table tail : not found'
		return line('$')
	endif
	return linum - 1
endfun

" --- grid

fun! organ#table#lengthes (grid)
	" Lengthes of lists in grid
	let grid = deepcopy(a:grid)
	return map(grid, { _, v -> len(v)})
endfun

fun! organ#table#metalen (grid)
	" Lengthes of each element of grid
	let grid = deepcopy(a:grid)
	let Lengthes = { list -> copy(list)->map({ _, v -> len(v) }) }
	let Metalen = { _, list -> Lengthes(list) }
	return map(grid, Metalen)
endfun

fun! organ#table#maxima (grid)
	" Maxima of elements in grid
	let grid = deepcopy(a:grid)
	return map(grid, { _, v -> max(v)})
endfun

fun! organ#table#complete (grid, absent = -1)
	" Complete grid with elements equals to absent
	let complete = deepcopy(a:grid)
	let absent = a:absent
	let absentcell = [absent]
	let lengthes = organ#table#lengthes (complete)
	let maxim = max(lengthes)
	for index in range(len(complete))
		let add = maxim - lengthes[index]
		if add > 0
			let added = absentcell->repeat(add)
			eval complete[index]->extend(added)
		endif
	endfor
	return complete
endfun

fun! organ#table#dual (grid)
	" Dual of positions in all table lines
	let grid = a:grid
	" -- outer length
	let outer_length = len(grid)
	" -- inner max length
	let lengthes = organ#table#lengthes (grid)
	let inner_length = max(lengthes)
	" -- span
	let outer_span = range(outer_length)
	let inner_span = range(inner_length)
	" -- init dual
	" can't use repeat() with nested list :
	" it uses references to the same inner list
	let dual = copy(inner_span)->map('[]')
	" -- double loop
	for inner in inner_span
		let dualelem = dual[inner]
		for outer in outer_span
			if inner < lengthes[outer]
				eval dualelem->add(grid[outer][inner])
			endif
		endfor
	endfor
	" -- coda
	return dual
endfun

" -- align TODO

fun! organ#table#delimgrid (paragraph)
	" Grid of cells limiters
	let paragraph = a:paragraph
	let delimiter = paragraph.delimiter
	let sepdelim_pattern = paragraph.separator_delimiter_pattern
	let delimgrid = []
	" ---- loop
	let linum = paragraph.linumlist[0]
	for line in paragraph.linelist
		let delims = []
		"let Addmatch = { match -> string(delims->add(match[0])[-1]) }
		if organ#table#is_separator_line (linum)
			" -- not a real substitute, just to gather matches
			" -- it's that or a while loop with matchstr()
			"call substitute(line, separator_delimiter, Addmatch, 'g')
			" -- or
			call substitute(line, sepdelim_pattern, '\=delims->add(submatch(0))', 'g')
		else
			"call substitute(line, delimiter, Addmatch, 'g')
			" -- or
			call substitute(line, delimiter, '\=delims->add(submatch(0))', 'g')
		endif
		eval delimgrid->add(delims)
		let linum += 1
	endfor
	" ---- coda
	return delimgrid
endfun

fun! organ#table#cellgrid (paragraph)
	" Grid of cells contents
	" Use split(string, pattern, keepempty)
	let paragraph = a:paragraph
	let delimiter = paragraph.delimiter
	let sepdelim_pattern = paragraph.separator_delimiter_pattern
	let cellgrid = []
	let linum = paragraph.linumlist[0]
	for line in paragraph.linelist
		if organ#table#is_separator_line (linum)
			let cells = line->split(sepdelim_pattern, v:true)
		else
			let cells = line->split(delimiter, v:true)
		endif
		eval cellgrid->add(cells)
		let linum += 1
	endfor
	return cellgrid
endfun

" -- positions

fun! organ#table#positions (argdict = {})
	" Positions of the delimiter char
	" First char of the line = 1
	let argdict = a:argdict
	if has_key (argdict, 'delimiter')
		let delimiter =  argdict.delimiter
	else
		let delimiter = organ#table#delimiter ()
	endif
	if has_key (argdict, 'linum')
		let linum =  argdict.linum
	else
		let linum = line('.')
	endif
	let line = getline(linum)
	if organ#table#is_separator_line (linum)
		let pattern = organ#table#separator_delimiter_pattern ()
	else
		let pattern = delimiter
	endif
	let positions = []
	let byte_index = 0
	while v:true
		let byte_index = line->match(pattern, byte_index)
		if byte_index < 0
			break
		endif
		let char_index = line->charidx(byte_index) + 1
		eval positions->add(char_index)
		let byte_index += 1
	endwhile
	return positions
endfun

fun! organ#table#posgrid (argdict = {})
	" Positions in all table lines
	let argdict = a:argdict
	if has_key (argdict, 'head_linum')
		let head_linum =  argdict.head_linum
	else
		let head_linum = organ#table#head ()
	endif
	if has_key (argdict, 'tail_linum')
		let tail_linum =  argdict.tail_linum
	else
		let tail_linum = organ#table#tail ()
	endif
	let grid = []
	for linum in range(head_linum, tail_linum)
		let argdict.linum = linum
		let positions = organ#table#positions (argdict)
		eval grid->add(positions)
	endfor
	return grid
endfun

" ---- align, new TODO

fun! organ#table#minindent (paragraph)
	" Minimize table indent
	let paragraph = a:paragraph
	let spaces = repeat(' ', &tabstop)
	" ---- eval min indent
	let linelist = paragraph.linelist
	let indentlist = []
	let rownum = 0
	for line in linelist
		if line =~ "^\s*\t"
			let line = substitute(line, "\t", spaces, 'g')
			let linelist[rownum] = line
		endif
		let leading = line->matchstr(s:indent_pattern)
		let indent = len(leading)
		eval indentlist->add(indent)
		let rownum += 1
	endfor
	let minindent = min(indentlist)
	let minlead = repeat(' ', minindent)
	" ---- reduce
	let rownum = 0
	for line in linelist
		let indent = indentlist[rownum]
		if indent > minindent
			let line = line->substitute(s:indent_pattern, minlead, '')
			let linelist[rownum] = line
		endif
		let rownum += 1
	endfor
	" ---- coda
	return paragraph
endfun

fun! organ#table#add_missing_delims (paragraph)
	" Add missing columns delimiters
	let paragraph = a:paragraph
	let linumlist = paragraph.linumlist
	let linelist = paragraph.linelist
	let delimiter = paragraph.delimiter
	let sepdelim = paragraph.separator_delimiter
	let delimgrid = paragraph.delimgrid
	" ---- add loop
	let lengthes = organ#table#lengthes (delimgrid)
	let maxim = max(lengthes)
	let rownum = 0
	for linum in linumlist
		let width = lengthes[rownum]
		let add = maxim - width
		if add > 0
			let line = linelist[rownum]
			let delims = delimgrid[rownum]
			if organ#table#is_separator_line (linum)
				let addme = sepdelim->repeat(add)
				let listaddme = [sepdelim]->repeat(add)
				" -- needs the colon for compatibilty
				let newline = line[:-2] .. addme .. line[-1:]
				let newdelims = delims[:-2] + listaddme + delims[-1:]
			else
				let addme = delimiter->repeat(add)
				let listaddme = [delimiter]->repeat(add)
				let newline = line .. addme
				let newdelims = delims + listaddme
			endif
			let linelist[rownum] = newline
			let delimgrid[rownum] = newdelims
		endif
		let rownum += 1
	endfor
	" --- coda
	return paragraph
endfun

fun! organ#table#align_cells (paragraph)
	" Align cells
	let paragraph = a:paragraph
	return paragraph
endfun

fun! organ#table#meta_align (mode = 'normal') range
	" Align table or paragraph
	call organ#origami#suspend ()
	let mode = a:mode
	let position = getcurpos ()
	let paragraph = {}
	" ---- head & tail
	if mode ==# 'visual'
		let head_linum = a:firstline
		let tail_linum = a:lastline
	else
		let head_linum = organ#table#head ()
		let tail_linum = organ#table#tail ()
	endif
	" ---- lines
	let paragraph.linumlist = range(head_linum, tail_linum)
	let paragraph.linelist = getline(head_linum, tail_linum)
	let paragraph.pristine = copy(paragraph.linelist)
	" ---- indent
	let paragraph = organ#table#minindent(paragraph)
	" ---- delimiter pattern
	let paragraph.is_table = organ#table#is_in_table ()
	if paragraph.is_table
		let paragraph.delimiter = organ#table#delimiter ()
		let paragraph.separator_delimiter = organ#table#separator_delimiter ()
		let paragraph.separator_delimiter_pattern = organ#table#separator_delimiter_pattern ()
	else
		let prompt = 'Align following pattern : '
		let paragraph.delimiter = input(prompt, '')
		let paragraph.separator_delimiter = paragraph.delimiter
		let paragraph.separator_delimiter_pattern = paragraph.delimiter
	endif
	" ---- delimiters
	let paragraph.delimgrid = organ#table#delimgrid(paragraph)
	if paragraph.is_table
		let paragraph = organ#table#add_missing_delims(paragraph)
	endif
	" ---- cells
	let paragraph.cellgrid = organ#table#cellgrid(paragraph)
	let paragraph.lengrid = organ#table#metalen(paragraph.cellgrid)
	" ---- align cells
	let paragraph = organ#table#align_cells (paragraph)
	" ---- commit lines to buffer
	let linum = head_linum
	for line in paragraph.linelist
		call setline(linum, line)
		let linum += 1
	endfor
	" ---- coda
	call setpos('.', position)
	call organ#origami#resume ()
	return paragraph
endfun

" ---- align, legacy

fun! organ#table#shrink_separator_lines (argdict = {})
	" Reduce separator line to their minimum
	let argdict = a:argdict
	if has_key (argdict, 'head_linum')
		let head_linum =  argdict.head_linum
	else
		let head_linum = organ#table#head ()
		let argdict.head_linum = head_linum
	endif
	if has_key (argdict, 'tail_linum')
		let tail_linum =  argdict.tail_linum
	else
		let tail_linum = organ#table#tail ()
		let argdict.tail_linum = tail_linum
	endif
	for linum in range(head_linum, tail_linum)
		if organ#table#is_separator_line (linum)
			call setline(linum, '|-|')
		endif
	endfor
	return argdict
endfun

fun! organ#table#reduce_multi_spaces (argdict = {})
	" Reduce multi-spaces before a delimiter to one
	let argdict = a:argdict
	if has_key (argdict, 'delimiter')
		let delimiter =  argdict.delimiter
	else
		let delimiter = organ#table#delimiter ()
		let argdict.delimiter = delimiter
	endif
	if has_key (argdict, 'head_linum')
		let head_linum =  argdict.head_linum
	else
		let head_linum = organ#table#head ()
		let argdict.head_linum = head_linum
	endif
	if has_key (argdict, 'tail_linum')
		let tail_linum =  argdict.tail_linum
	else
		let tail_linum = organ#table#tail ()
		let argdict.tail_linum = tail_linum
	endif
	let range = head_linum .. ',' .. tail_linum
	" ---- also replace indent tabs
	let pattern = '\m\s\+\(' .. delimiter .. '\)'
	let substit = ' \1'
	let pattern = pattern->escape('/')
	let substit = substit->escape('/')
	let position = getcurpos ()
	execute 'silent!' range 'substitute /' .. pattern .. '/' .. substit .. '/g'
	call setpos('.', position)
	return argdict
endfun

fun! organ#table#add_missing_columns (argdict = {})
	" Add missing columns delimiters
	let argdict = a:argdict
	if has_key (argdict, 'delimiter')
		let delimiter = argdict.delimiter
	else
		let delimiter = organ#table#delimiter ()
		let argdict.delimiter = delimiter
	endif
	if has_key (argdict, 'head_linum')
		let head_linum = argdict.head_linum
	else
		let head_linum = organ#table#head ()
		let argdict.head_linum = head_linum
	endif
	if has_key (argdict, 'tail_linum')
		let tail_linum =  argdict.tail_linum
	else
		let tail_linum = organ#table#tail ()
		let argdict.tail_linum = tail_linum
	endif
	if has_key (argdict, 'grid')
		let grid =  argdict.grid
	else
		let grid =  organ#table#posgrid (argdict)
		let argdict.grid = grid
	endif
	let lengthes = organ#table#lengthes (grid)
	let maxim = max(lengthes)
	let index = 0
	for linum in range(head_linum, tail_linum)
		let width = lengthes[index]
		let add = maxim - width
		if add > 0
			let line = getline(linum)
			if organ#table#is_separator_line (linum)
				let addme = organ#table#separator_delimiter ()
				" -- needs the colon for compatibilty
				let newline = line[:-2] .. addme->repeat(add) .. line[-1:]
			else
				let addme = delimiter
				let newline = line .. addme->repeat(add)
			endif
			call setline(linum, newline)
			let grid_index = grid[index]
			let last_pos = grid_index[-1]
			let addedpos = range(last_pos + 1, last_pos + add)
			eval grid_index->extend(addedpos)
		endif
		let index += 1
	endfor
	return argdict
endfun

fun! organ#table#align_columns (argdict = {})
	" Align following a delimiter
	" For tables : align columns in all table rows
	let argdict = a:argdict
	if has_key (argdict, 'head_linum')
		let head_linum =  argdict.head_linum
	else
		let head_linum = organ#table#head ()
		let argdict.head_linum = head_linum
	endif
	if has_key (argdict, 'tail_linum')
		let tail_linum =  argdict.tail_linum
	else
		let tail_linum = organ#table#tail ()
		let argdict.tail_linum = tail_linum
	endif
	if has_key (argdict, 'grid')
		let grid =  argdict.grid
	else
		let grid =  organ#table#posgrid (argdict)
		let argdict.grid = grid
	endif
	" ---- grid derivates
	let lengthes = organ#table#lengthes (grid)
	let colmax = max(lengthes)
	let dual = organ#table#dual(grid)
	let maxima = organ#table#maxima(dual)
	" ---- lines list
	let linelist = getline(head_linum, tail_linum)
	let lenlinelist = len(linelist)
	" ---- double loop
	let index = 0
	let modified = []
	for colnum in range(colmax)
		for rownum in range(lenlinelist)
			if lengthes[rownum] <= colnum
				continue
			endif
			let row = grid[rownum]
			let char_position = row[colnum]
			let add = maxima[colnum] - char_position
			if add == 0
				continue
			endif
			let line = linelist[rownum]
			let byte_position = line->byteidx(char_position - 1) + 1
			" -- shift
			let is_sep_line = line =~ organ#table#separator_pattern ()
			if colnum > 0 && is_sep_line
				let shift = repeat('-', add)
			else
				let shift = repeat(' ', add)
			endif
			" -- adapt line
			if byte_position == 1
				let before = ''
				let after = line
			elseif byte_position == len(line) + 1
				let before = line
				let after = ''
			else
				let before = line[:byte_position - 2]
				let after = line[byte_position - 1:]
			endif
			let linelist[rownum] = before .. shift .. after
			" -- adapt grid & maxima
			for rightcol in range(colnum, lengthes[rownum] - 1)
				let row[rightcol] += add
				if row[rightcol] > maxima[rightcol]
					let maxima[rightcol] = row[rightcol]
				endif
			endfor
			" ---- register row as modified
			if modified->index(rownum) < 0
				eval modified->add(rownum)
			endif
		endfor
	endfor
	" ---- commit changes to buffer
	let linum = head_linum
	for rownum in range(lenlinelist)
		if modified->index(rownum) < 0
			let linum += 1
			continue
		endif
		call setline(linum, linelist[rownum])
		let linum += 1
	endfor
	return argdict
endfun

fun! organ#table#align (mode = 'normal') range
	" Align table or paragraph
	call organ#origami#suspend ()
	let mode = a:mode
	let position = getcurpos ()
	let argdict = {}
	if mode ==# 'visual'
		let argdict.head_linum = a:firstline
		let argdict.tail_linum = a:lastline
	else
		let argdict.head_linum = organ#table#head ()
		let argdict.tail_linum = organ#table#tail ()
	endif
	if organ#table#is_in_table ()
		let argdict.delimiter = organ#table#delimiter ()
		let argdict = organ#table#shrink_separator_lines (argdict)
		let argdict = organ#table#reduce_multi_spaces (argdict)
		let argdict = organ#table#add_missing_columns (argdict)
	else
		let prompt = 'Align following pattern : '
		let argdict.delimiter = input(prompt, '')
		let argdict = organ#table#reduce_multi_spaces (argdict)
	endif
	let argdict = organ#table#align_columns (argdict)
	call setpos('.', position)
	call organ#origami#resume ()
	return argdict
endfun

" ---- update

fun! organ#table#update ()
	" Update table : to be used in InsertLeave autocommand
	if ! organ#table#is_in_table ()
		return []
	endif
	let position = getcurpos ()
	let argdict = {}
	let argdict.delimiter = organ#table#delimiter ()
	let argdict = organ#table#shrink_separator_lines (argdict)
	let argdict = organ#table#reduce_multi_spaces (argdict)
	let argdict = organ#table#add_missing_columns (argdict)
	let argdict = organ#table#align_columns (argdict)
	call setpos('.', position)
	return argdict
endfun

" ---- navigation

fun! organ#table#next_cell ()
	" Go to next cell
	call organ#table#update ()
	let delimiter = organ#table#delimiter ()
	let pattern = '\m' .. delimiter .. '\s\{0,1}\zs.\ze'
	let flags = organ#utils#search_flags ('forward', 'move', 'dont-wrap')
	let linum = search(pattern, flags)
	return linum
endfun

fun! organ#table#previous_cell ()
	" Go to previous cell
	call organ#table#update ()
	let delimiter = organ#table#delimiter ()
	let pattern = '\m' .. delimiter .. '\s\{0,1}\zs.\ze'
	let flags = organ#utils#search_flags ('backward', 'move', 'dont-wrap')
	let linum = search(pattern, flags)
	return linum
endfun

fun! organ#table#cell_begin ()
	" Go to cell beginning
	let position = getcurpos ()
	let delimiter = organ#table#delimiter ()
	let flags = organ#utils#search_flags ('backward', 'move', 'dont-wrap', 'accept-here')
	" ---- delimiter
	let linum_delim = search(delimiter, flags)
	let colnum_delim = col('.')
	call setpos('.', position)
	" ---- cell begin
	let pattern = '\m' .. delimiter .. '\s*\zs[^ |]\ze'
	let linum = search(pattern, flags)
	let colnum = col('.')
	" ---- empty cell
	if linum < linum_delim || colnum < colnum_delim
		call setpos('.', position)
		return [linum, colnum]
	endif
	" ---- coda
	return [linum, colnum]
endfun

fun! organ#table#cell_end ()
	" Go to cell end
	let position = getcurpos ()
	let delimiter = organ#table#delimiter ()
	let flags = organ#utils#search_flags ('forward', 'move', 'dont-wrap', 'accept-here')
	" ---- delimiter
	let linum_delim = search(delimiter, flags)
	let colnum_delim = col('.')
	call setpos('.', position)
	" ---- cell end
	let pattern = '\m\zs[^ |]\ze\s*' .. delimiter
	let linum = search(pattern, flags)
	let colnum = col('.')
	" ---- empty cell
	if linum > linum_delim || colnum > colnum_delim
		call setpos('.', position)
		return [linum, colnum]
	endif
	" ---- coda
	return [linum, colnum]
endfun

fun! organ#table#select_cell ()
	" Select cell content
	normal! v
	let linum = organ#table#cell_begin ()
	normal! o
	let linum = organ#table#cell_end ()
	return linum
endfun

" ---- move rows & cols

fun! organ#table#move_row_up ()
	" Move table row up
	let linum = line('.')
	if linum == 1
		return 0
	endif
	let current = getline(linum)
	let previous = getline(linum - 1)
	call setline(linum - 1, current)
	call setline(linum, previous)
	call cursor(linum - 1, col('.'))
	return linum
endfun

fun! organ#table#move_row_down ()
	" Move table row down
	let linum = line('.')
	if linum == line('$')
		return 0
	endif
	let current = getline(linum)
	let next = getline(linum + 1)
	call setline(linum + 1, current)
	call setline(linum, next)
	call cursor(linum + 1, col('.'))
	return linum
endfun

fun! organ#table#move_col_left (argdict = {})
	" Move table column left
	" Assume the table is aligned
	let argdict = a:argdict
	if has_key (argdict, 'head_linum')
		let head_linum =  argdict.head_linum
	else
		let head_linum = organ#table#head ()
	endif
	if has_key (argdict, 'tail_linum')
		let tail_linum =  argdict.tail_linum
	else
		let tail_linum = organ#table#tail ()
	endif
	let positions = organ#table#positions (argdict)
	let colmax = len(positions)
	" ---- two delimiters or less = only one column
	if colmax <= 2
		return positions
	endif
	" ---- current column
	" ---- between delimiters colnum & colnum + 1
	let cursor = col('.')
	for colnum in range(colmax - 1)
		if cursor >= positions[colnum] && cursor <= positions[colnum + 1]
			break
		endif
	endfor
	" ---- can't move further left
	if colnum == 0
		return positions
	endif
	" ---- lines list
	let current_linum = line('.')
	let linelist = getline(head_linum, tail_linum)
	let lenlinelist = len(linelist)
	" ---- patterns
	let separator_pattern = organ#table#separator_pattern ()
	let tabdelim = organ#table#delimiter ()
	let sepdelim = organ#table#separator_delimiter ()
	" ---- two columns to exchange, three delimiters
	let char_first = positions[colnum - 1]
	let char_second = positions[colnum]
	let char_third = positions[colnum + 1]
	" ---- move column in all table lines
	let linum = head_linum
	for rownum in range(lenlinelist)
		let line = linelist[rownum]
		" -- chunks
		let byte_first = line->byteidx(char_first - 1) + 1
		let byte_second = line->byteidx(char_second - 1) + 1
		let byte_third = line->byteidx(char_third - 1) + 1
		if byte_first == 1
			let before = ''
			let after = line[byte_third - 1:]
		elseif byte_third == len(line) + 1
			let before = line
			let after = line[byte_third - 1:]
		else
			let before = line[:byte_first - 2]
			let after = line[byte_third - 1:]
		endif
		let previous = line[byte_first - 1:byte_second - 2]
		let current = line[byte_second - 1:byte_third - 2]
		" -- adjust separator line
		if colnum == 1 && tabdelim != sepdelim && line =~ separator_pattern
			let current = tabdelim .. current[1:]
			let previous = sepdelim .. previous[1:]
		endif
		" --- reorder
		let linelist[rownum] = before .. current .. previous .. after
		" -- store cursor column for the end
		if linum == current_linum
			let cursor_col = cursor - (byte_second - byte_first)
		endif
		let linum += 1
	endfor
	" ---- commit changes to buffer
	let linum = head_linum
	for index in range(len(linelist))
		call setline(linum, linelist[index])
		let linum += 1
	endfor
	" ---- coda
	call cursor('.', cursor_col)
	return positions
endfun

fun! organ#table#move_col_right (argdict = {})
	" Move table column right
	" Assume the table is aligned
	let argdict = a:argdict
	if has_key (argdict, 'head_linum')
		let head_linum =  argdict.head_linum
	else
		let head_linum = organ#table#head ()
	endif
	if has_key (argdict, 'tail_linum')
		let tail_linum =  argdict.tail_linum
	else
		let tail_linum = organ#table#tail ()
	endif
	let positions = organ#table#positions (argdict)
	let colmax = len(positions)
	" ---- two delimiters or less = only one column
	if colmax <= 2
		return positions
	endif
	" ---- current column
	" ---- between delimiters colnum & colnum + 1
	let cursor = col('.')
	for colnum in range(colmax - 1)
		if cursor >= positions[colnum] && cursor <= positions[colnum + 1]
			break
		endif
	endfor
	" ---- can't move further right
	if colnum >= colmax - 2
		return positions
	endif
	" ---- lines list
	let current_linum = line('.')
	let linelist = getline(head_linum, tail_linum)
	let lenlinelist = len(linelist)
	" ---- patterns
	let separator_pattern = organ#table#separator_pattern ()
	let tabdelim = organ#table#delimiter ()
	let sepdelim = organ#table#separator_delimiter ()
	" ---- two columns to exchange, three delimiters
	let char_first = positions[colnum]
	let char_second = positions[colnum + 1]
	let char_third = positions[colnum + 2]
	" ---- move column in all table lines
	let linum = head_linum
	for rownum in range(lenlinelist)
		let line = linelist[rownum]
		" -- chunks
		let byte_first = line->byteidx(char_first - 1) + 1
		let byte_second = line->byteidx(char_second - 1) + 1
		let byte_third = line->byteidx(char_third - 1) + 1
		if byte_first == 1
			let before = ''
			let after = line[byte_third - 1:]
		elseif byte_third == len(line) + 1
			let before = line
			let after = line[byte_third - 1:]
		else
			let before = line[:byte_first - 2]
			let after = line[byte_third - 1:]
		endif
		let current = line[byte_first - 1:byte_second - 2]
		let next = line[byte_second - 1:byte_third - 2]
		" -- adjust separator line
		if colnum == 0 && tabdelim != sepdelim && line =~ separator_pattern
			let next = tabdelim .. next[1:]
			let current = sepdelim .. current[1:]
		endif
		" --- reorder
		let linelist[rownum] = before .. next .. current .. after
		" -- store cursor column for the end
		if linum == current_linum
			let cursor_col = cursor + (byte_third - byte_second)
		endif
		let linum += 1
	endfor
	" ---- commit changes to buffer
	let linum = head_linum
	for index in range(len(linelist))
		call setline(linum, linelist[index])
		let linum += 1
	endfor
	" ---- coda
	call cursor('.', cursor_col)
	return positions
endfun

" ---- new rows & cols

fun! organ#table#new_row ()
	" Add new row below cursor line
	let linum = line('.')
	let newrow = '| |'
	call append('.', newrow)
	let argdict = #{
		\ head_linum : linum,
		\ tail_linum : linum + 1,
		\}
	call organ#table#add_missing_columns (argdict)
	call organ#table#align_columns (argdict)
	call cursor(linum + 1, col('.'))
endfun

fun! organ#table#new_separator_line ()
	" Add new row below cursor line
	let linum = line('.')
	let newrow = '|-|'
	call append('.', newrow)
	let argdict = #{
		\ head_linum : linum,
		\ tail_linum : linum + 1,
		\}
	call organ#table#add_missing_columns (argdict)
	call organ#table#align_columns (argdict)
	call cursor(linum + 1, col('.'))
endfun

fun! organ#table#new_col ()
	" Add new column at the right of the cursor
	" Assume the table is aligned
	call organ#origami#suspend ()
	let head_linum = organ#table#head ()
	let tail_linum = organ#table#tail ()
	let delimiter = organ#table#delimiter ()
	let sepdelim  = organ#table#separator_delimiter ()
	let positions = organ#table#positions ()
	let colmax = len(positions)
	" ---- not enough column delimiters
	if colmax <= 1
		return positions
	endif
	" ---- current column
	" ---- between delimiters colnum & colnum + 1
	let charcol = charcol('.')
	for colnum in range(colmax - 1)
		if charcol >= positions[colnum] && charcol <= positions[colnum + 1]
			break
		endif
	endfor
	" ---- lines list
	let current_linum = line('.')
	let linelist = getline(head_linum, tail_linum)
	let lenlinelist = len(linelist)
	" ---- one column, two delimiters
	let char_first = positions[colnum]
	let char_second = positions[colnum + 1]
	" ---- add new column in all table lines
	let linum = head_linum
	for rownum in range(lenlinelist)
		let line = linelist[rownum]
		let byte_first = line->byteidx(char_first - 1) + 1
		let byte_second = line->byteidx(char_second - 1) + 1
		if byte_second == len(line)
			let before = line
			let after = ''
		else
			let before = line[:byte_second - 1]
			let after = line[byte_second:]
		endif
		if line =~ organ#table#separator_pattern ()
			let linelist[rownum] = before .. '--' .. sepdelim .. after
		else
			let linelist[rownum] = before .. '  ' .. delimiter .. after
		endif
		" -- store cursor column for the end
		if linum == current_linum
			let cursor_col = byte_second + 1
		endif
		let linum += 1
	endfor
	" ---- commit changes to buffer
	let linum = head_linum
	for index in range(len(linelist))
		call setline(linum, linelist[index])
		let linum += 1
	endfor
	" ---- coda
	call cursor('.', cursor_col)
	call organ#origami#resume ()
endfun

" ---- delete rows & cols

fun! organ#table#delete_row ()
	" Delete row
	call organ#utils#delete(line('.'))
endfun

fun! organ#table#delete_col ()
	" Delete column
	" Assume the table is aligned
	call organ#origami#suspend ()
	let head_linum = organ#table#head ()
	let tail_linum = organ#table#tail ()
	let delimiter = organ#table#delimiter ()
	let sepdelim  = organ#table#separator_delimiter ()
	let positions = organ#table#positions ()
	let colmax = len(positions)
	" ---- not enough column delimiters
	if colmax <= 1
		return positions
	endif
	" ---- current column
	" ---- between delimiters colnum & colnum + 1
	let charcol = charcol('.')
	for colnum in range(colmax - 1)
		if charcol >= positions[colnum] && charcol <= positions[colnum + 1]
			break
		endif
	endfor
	" ---- lines list
	let current_linum = line('.')
	let linelist = getline(head_linum, tail_linum)
	let lenlinelist = len(linelist)
	" ---- one column, two delimiters
	let char_first = positions[colnum]
	let char_second = positions[colnum + 1]
	" ---- add new column in all table lines
	let linum = head_linum
	for rownum in range(lenlinelist)
		let line = linelist[rownum]
		let byte_first = line->byteidx(char_first - 1) + 1
		let byte_second = line->byteidx(char_second - 1) + 1
		if byte_first == 1
			let before = ''
			let after = line
		elseif byte_second == len(line) + 1
			let before = line
			let after = ''
		else
			let before = line[:byte_first - 2]
			let after = line[byte_second - 1:]
		endif
		let linelist[rownum] = before .. after
		" -- store cursor column for the end
		if linum == current_linum
			let cursor_col = byte_first
		endif
		let linum += 1
	endfor
	" ---- commit changes to buffer
	let linum = head_linum
	for index in range(len(linelist))
		call setline(linum, linelist[index])
		let linum += 1
	endfor
	" ---- coda
	call cursor('.', cursor_col)
	call organ#origami#resume ()
	return positions
endfun
