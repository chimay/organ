" vim: set ft=vim fdm=indent iskeyword&:

" Table
"
" Table operations

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
	return '|'
endfun

fun! organ#table#separator_delimiter_pattern ()
	" Tables column pattern in separator line
	if &filetype ==# 'org'
		return '[|+]'
	elseif &filetype ==# 'markdown'
		return '|'
	endif
	return '|'
endfun

fun! organ#table#generic_pattern (argdict = {})
	" Generic table line pattern
	let argdict = a:argdict
	if has_key (argdict, 'delimiter')
		let delimiter =  argdict.delimiter
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
	endif
	" ---- most unlikely
	return '\m most unlikely : ezheifj iefjiz fbreyrbeyr byaz'
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

" -- positions

fun! organ#table#positions (argdict = {})
	" Positions of the delimiter char
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
	let positions = []
	let index = 0
	while v:true
		if organ#table#is_separator_line (linum)
			let pattern = organ#table#separator_delimiter_pattern ()
		else
			let pattern = delimiter
		endif
		let index = line->match(pattern, index) + 1
		if index == 0
			break
		endif
		eval positions->add(index)
	endwhile
	return positions
endfun

fun! organ#table#grid (argdict = {})
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

fun! organ#table#lengthes (grid)
	" Lengthes of elements in grid
	let grid = deepcopy(a:grid)
	return map(grid, { _, v -> len(v)})
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

fun! organ#table#maxima (dual)
	" Maxima of elements in dual
	let dual = deepcopy(a:dual)
	return map(dual, { _, v -> max(v)})
endfun

" ---- navigation

fun! organ#table#next_cell ()
	" Go to next cell
	let delimiter = organ#table#delimiter ()
	let pattern = '\m' .. delimiter .. '\zs \ze\s*\S'
	let flags = organ#utils#search_flags ('forward', 'move', 'dont-wrap')
	let linum = search(pattern, flags)
endfun

fun! organ#table#previous_cell ()
	" Go to previous cell
	let delimiter = organ#table#delimiter ()
	let pattern = '\m' .. delimiter .. '\zs \ze\s*\S'
	let flags = organ#utils#search_flags ('backward', 'move', 'dont-wrap')
	let linum = search(pattern, flags)
endfun

" ---- align

fun! organ#table#reduce_multi_spaces (argdict = {})
	" Reduce multi-spaces before a delimiter to one
	let argdict = a:argdict
	if has_key (argdict, 'delimiter')
		let delimiter =  argdict.delimiter
	else
		let delimiter = organ#table#delimiter ()
	endif
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
	let range = head_linum .. ',' .. tail_linum
	let pattern = '\m\s\+\(' .. delimiter .. '\)'
	let substit = ' \1'
	let pattern = pattern->escape('/')
	let substit = substit->escape('/')
	let position = getcurpos ()
	execute 'silent!' range 'substitute /' .. pattern .. '/' .. substit .. '/g'
	call setpos('.',  position)
endfun

fun! organ#table#add_missing_columns (argdict = {})
	" Add missing columns delimiters
	let argdict = a:argdict
	if has_key (argdict, 'delimiter')
		let delimiter = argdict.delimiter
	else
		let delimiter = organ#table#delimiter ()
	endif
	if has_key (argdict, 'head_linum')
		let head_linum = argdict.head_linum
	else
		let head_linum = organ#table#head ()
	endif
	if has_key (argdict, 'tail_linum')
		let tail_linum =  argdict.tail_linum
	else
		let tail_linum = organ#table#tail ()
	endif
	if has_key (argdict, 'grid')
		let grid =  argdict.grid
	else
		let grid =  organ#table#grid (argdict)
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
				let line = line[:-2] .. addme->repeat(add) .. line[-1:]
			else
				let addme = delimiter
				let line ..= addme->repeat(add)
			endif
			call setline(linum, line)
			let grid_index = grid[index]
			let last_pos = grid_index[-1]
			let addedpos = range(last_pos + 1, last_pos + add)
			eval grid_index->extend(addedpos)
		endif
		let index += 1
	endfor
	return grid
endfun

fun! organ#table#align_columns (argdict = {})
	" Align following a delimiter
	" For tables : align columns in all table rows
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
	if has_key (argdict, 'grid')
		let grid =  argdict.grid
	else
		let grid =  organ#table#grid (argdict)
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
	for colnum in range(colmax)
		for rownum in range(lenlinelist)
			if lengthes[rownum] <= colnum
				continue
			endif
			let row = grid[rownum]
			let position = row[colnum]
			let add = maxima[colnum] - position
			if add == 0
				continue
			endif
			let line = linelist[rownum]
			" -- shift
			let is_sep_line = line =~ organ#table#separator_pattern ()
			if colnum > 0 && is_sep_line
				let shift = repeat('-', add)
			else
				let shift = repeat(' ', add)
			endif
			" -- adapt line
			if position == 1
				let before = ''
				let after = line
			elseif position == len(line) + 1
				let before = line
				let after = ''
			else
				let before = line[:position - 2]
				let after = line[position - 1:]
			endif
			let linelist[rownum] = before .. shift .. after
			" -- adapt grid & maxima
			for rightcol in range(colnum, lengthes[rownum] - 1)
				let row[rightcol] += add
				if row[rightcol] > maxima[rightcol]
					let maxima[rightcol] = row[rightcol]
				endif
			endfor
		endfor
	endfor
	" ---- commit changes to buffer
	let linum = head_linum
	for index in range(len(linelist))
		call setline(linum, linelist[index])
		let linum += 1
	endfor
	return grid
endfun

fun! organ#table#is_aligned (argdict = {})
	" Whether table is aligned
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
	if has_key (argdict, 'grid')
		let grid =  argdict.grid
	else
		let grid =  organ#table#grid (argdict)
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
	for colnum in range(colmax)
		for rownum in range(lenlinelist)
			if lengthes[rownum] <= colnum
				continue
			endif
			let row = grid[rownum]
			let position = row[colnum]
			let add = maxima[colnum] - position
			if add > 0
				return v:false
			endif
		endfor
	endfor
	return v:true
endfun

fun! organ#table#align (mode = 'normal') range
	" Align table or paragraph
	let mode = a:mode
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
		call organ#table#reduce_multi_spaces (argdict)
		let argdict.grid = organ#table#add_missing_columns (argdict)
	else
		let prompt = 'Align following pattern : '
		let argdict.delimiter = input(prompt, '')
		call organ#table#reduce_multi_spaces (argdict)
	endif
	let grid = organ#table#align_columns (argdict)
	return grid
endfun

" ---- move rows & cols

fun! organ#table#move_up ()
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

fun! organ#table#move_down ()
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

fun! organ#table#move_left (argdict = {})
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
	let linelist = getline(head_linum, tail_linum)
	let lenlinelist = len(linelist)
	" ---- two columns to exchange, three delimiters
	let first = positions[colnum - 1]
	let second = positions[colnum]
	let third = positions[colnum + 1]
	" ---- move column in all table lines
	for rownum in range(lenlinelist)
		let line = linelist[rownum]
		if first == 1
			let before = ''
			let after = line
		elseif third == len(line) + 1
			let before = line
			let after = ''
		else
			let before = line[:first - 2]
			let after = line[third - 1:]
		endif
		let previous = line[first - 1:second - 2]
		let current = line[second - 1:third - 2]
		let linelist[rownum] = before .. current .. previous .. after
	endfor
	" ---- commit changes to buffer
	let linum = head_linum
	for index in range(len(linelist))
		call setline(linum, linelist[index])
		let linum += 1
	endfor
	" ---- coda
	call cursor('.', cursor - (second - first))
	return positions
endfun

fun! organ#table#move_right (argdict = {})
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
	let linelist = getline(head_linum, tail_linum)
	let lenlinelist = len(linelist)
	" ---- two columns to exchange, three delimiters
	let first = positions[colnum]
	let second = positions[colnum + 1]
	let third = positions[colnum + 2]
	" ---- move column in all table lines
	for rownum in range(lenlinelist)
		let line = linelist[rownum]
		if first == 1
			let before = ''
			let after = line
		elseif third == len(line) + 1
			let before = line
			let after = ''
		else
			let before = line[:first - 2]
			let after = line[third - 1:]
		endif
		let current = line[first - 1:second - 2]
		let next = line[second - 1:third - 2]
		let linelist[rownum] = before .. next .. current .. after
	endfor
	" ---- commit changes to buffer
	let linum = head_linum
	for index in range(len(linelist))
		call setline(linum, linelist[index])
		let linum += 1
	endfor
	" ---- coda
	call cursor('.', cursor + (third - second))
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
	let cursor = col('.')
	for colnum in range(colmax - 1)
		if cursor >= positions[colnum] && cursor <= positions[colnum + 1]
			break
		endif
	endfor
	" ---- lines list
	let linelist = getline(head_linum, tail_linum)
	let lenlinelist = len(linelist)
	" ---- one column, two delimiters
	let first = positions[colnum]
	let second = positions[colnum + 1]
	" ---- add new column in all table lines
	for rownum in range(lenlinelist)
		let line = linelist[rownum]
		if second == len(line)
			let before = line
			let after = ''
		else
			let before = line[:second - 1]
			let after = line[second:]
		endif
		if line =~ organ#table#separator_pattern ()
			let linelist[rownum] = before .. '--' .. sepdelim .. after
		else
			let linelist[rownum] = before .. '  ' .. delimiter .. after
		endif
	endfor
	" ---- commit changes to buffer
	let linum = head_linum
	for index in range(len(linelist))
		call setline(linum, linelist[index])
		let linum += 1
	endfor
	" ---- coda
	call cursor('.', second + 1)
endfun

" ---- delete rows & cols

fun! organ#table#delete_row ()
	" Delete row
	call organ#utils#delete(line('.'))
endfun

fun! organ#table#delete_col ()
	" Delete column
	" Assume the table is aligned
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
	let cursor = col('.')
	for colnum in range(colmax - 1)
		if cursor >= positions[colnum] && cursor <= positions[colnum + 1]
			break
		endif
	endfor
	" ---- lines list
	let linelist = getline(head_linum, tail_linum)
	let lenlinelist = len(linelist)
	" ---- one column, two delimiters
	let first = positions[colnum]
	let second = positions[colnum + 1]
	" ---- add new column in all table lines
	for rownum in range(lenlinelist)
		let line = linelist[rownum]
		if first == 1
			let before = ''
			let after = line
		elseif second == len(line) + 1
			let before = line
			let after = ''
		else
			let before = line[:first - 2]
			let after = line[second - 1:]
		endif
		let linelist[rownum] = before .. after
	endfor
	" ---- commit changes to buffer
	let linum = head_linum
	for index in range(len(linelist))
		call setline(linum, linelist[index])
		let linum += 1
	endfor
	" ---- coda
	call cursor('.', first)
	return positions
endfun
