" vim: set ft=vim fdm=indent iskeyword&:

" Table
"
" Table operations

" ---- patterns

fun! organ#table#delimiter ()
	" Tables column char
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

fun! organ#table#outside_pattern (argdict = {})
	" Pattern for non table lines
	let argdict = a:argdict
	if has_key (argdict, 'delimiter')
		let delimiter =  argdict.delimiter
	else
		let delimiter = organ#table#delimiter ()
	endif
	let pattern = '\m^\s*[^' .. delimiter .. ' \t].*'
	let pattern ..= '\|.*[^' .. delimiter .. ' \t]\s*$'
	let pattern ..= '\|^$'
	return pattern
endfun

fun! organ#table#is_in_table (argdict = {})
	" Whether current line is in a table
	let line = getline('.')
	let pattern = organ#table#generic_pattern (a:argdict)
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
		let index = line->match(delimiter, index) + 1
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

" ---- properties

fun! organ#table#properties ()
	" Table properties
	let head_linum = organ#table#head ()
	let tail_linum = organ#table#tail ()
	let argdict = #{ head_linum : head_linum, tail_linum : tail_linum }
	let grid = organ#table#grid (argdict)
	return #{
				\ head_linum : head_linum,
				\ tail_linum : tail_linum,
				\ grid : grid,
				\}
endfun

" ---- format

fun! organ#table#add_missing_columns (argdict = {})
	" Add missing columns delimiters
	let argdict = a:argdict
	if has_key (argdict, 'delimiter')
		let delimiter =  argdict.delimiter
	else
		let delimiter = organ#table#delimiter ()
	endif
	if has_key (argdict, 'grid')
		let grid =  argdict.grid
	else
		let grid =  organ#table#grid (argdict)
	endif
	let properties = organ#table#properties ()
	let head_linum = properties.head_linum
	let tail_linum = properties.tail_linum
	let lengthes = organ#table#lengthes (grid)
	let maxim = max(lengthes)
	let index = 0
	for linum in range(head_linum, tail_linum)
		let width = lengthes[index]
		let add = maxim - width
		if add > 0
			let line = getline(linum)
			let line ..= delimiter->repeat(add)
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

fun! organ#table#align (argdict = {})
	" Align char in all table lines
	let argdict = a:argdict
	if has_key (argdict, 'grid')
		let grid =  argdict.grid
	else
		let grid =  organ#table#grid (argdict)
	endif
	let head_linum = organ#table#head ()
	let tail_linum = organ#table#tail ()
	" ---- grid derivates
	let lengthes = organ#table#lengthes (grid)
	let lencol = max(lengthes)
	let dual = organ#table#dual(grid)
	let maxima = organ#table#maxima(dual)
	" ---- lines list
	let linelist = getline(head_linum, tail_linum)
	let lenlinelist = len(linelist)
	" ---- double loop
	let index = 0
	for colnum in range(lencol)
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
			let shift = repeat(' ', add)
			" -- adapt line
			let line = linelist[rownum]
			if position == 1
				let before = ''
				let after = line
			elseif position == col('$')
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

fun! organ#table#format ()
	" Format table
	if organ#table#is_in_table ()
		let argdict = #{
			\ delimiter : organ#table#delimiter (),
			\}
		let argdict.grid = organ#table#add_missing_columns (argdict)
	else
		let prompt = 'Align following pattern : '
		let argdict = #{ delimiter : input(prompt, '') }
	endif
	let grid = organ#table#align (argdict)
	return grid
endfun
