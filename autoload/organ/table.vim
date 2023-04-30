" vim: set ft=vim fdm=indent iskeyword&:

" Table
"
" Table operations

" ---- delimiter

fun! organ#table#delimiter ()
	" Tables column char
	return '|'
endfun

" -- positions

fun! organ#table#positions (...)
	" Positions of the delimiter char
	if a:0 > 0
		let linum = a:1
	else
		let linum = line('.')
	endif
	let delimiter = organ#table#delimiter ()
	let line = getline(linum)
	let positions = []
	let index = 0
	while v:true
		call cursor('.', 1)
		let index = line->match(delimiter, index) + 1
		if index == 0
			break
		endif
		eval positions->add(index)
	endwhile
	return positions
endfun

fun! organ#table#grid (...)
	" Align char in all table lines
	if a:0 == 2
		let head_linum = a:1
		let tail_linum = a:2
	else
		let head_linum = organ#table#head ()
		let tail_linum = organ#table#tail ()
	endif
	let grid = []
	for linum in range(head_linum, tail_linum)
		let positions = organ#table#positions (linum)
		eval grid->add(positions)
	endfor
	return grid
endfun

" ---- patterns

fun! organ#table#generic_pattern ()
	" Generic table line pattern
	let delimiter = organ#table#delimiter ()
	let pattern = '\m^\s*' .. delimiter .. '.*'
	let pattern ..= '\&.*' .. delimiter .. '\s*$'
	return pattern
endfun

fun! organ#table#outside_pattern ()
	" Pattern for non table lines
	let delimiter = organ#table#delimiter ()
	let pattern = '\m^\s*[^' .. delimiter .. '].*'
	let pattern ..= '\|.*[^' .. delimiter .. ']\s*$'
	let pattern ..= '\|^$'
	return pattern
endfun

fun! organ#table#is_in_table ()
	" Whether current line is in a table
	let line = getline('.')
	return line =~ organ#table#generic_pattern ()
endfun

fun! organ#table#head (move = 'dont-move')
	" First line of table
	let move = a:move
	let outside_pattern = organ#table#outside_pattern ()
	let flags = organ#utils#search_flags ('backward', move, 'dont-wrap')
	let linum = search(outside_pattern, flags)
	if linum == 0
		echomsg 'organ table head : not found'
		return 1
	endif
	return linum + 1
endfun

fun! organ#table#tail (move = 'dont-move')
	" Last line of table
	let move = a:move
	let outside_pattern = organ#table#outside_pattern ()
	let flags = organ#utils#search_flags ('forward', move, 'dont-wrap')
	let linum = search(outside_pattern, flags)
	if linum == 0
		echomsg 'organ table tail : not found'
		return line('$')
	endif
	return linum - 1
endfun

" ---- properties

fun! organ#table#properties ()
	" Table properties
	let head_linum = organ#table#head ()
	let tail_linum = organ#table#tail ()
	let grid = organ#table#grid (head_linum, tail_linum)
	return #{
				\ head_linum : head_linum,
				\ tail_linum : tail_linum,
				\ grid : grid,
				\}
endfun

" ---- format

fun! organ#table#add_missing_columns ()
	" Add missing columns delimiters
	let delimiter = organ#table#delimiter ()
	let properties = organ#table#properties ()
	let head_linum = properties.head_linum
	let tail_linum = properties.tail_linum
	let grid = deepcopy(properties.grid)
	let widthlist = map(deepcopy(grid), { _, v -> len(v)})
	let maxim = max(widthlist)
	let index = 0
	for linum in range(head_linum, tail_linum)
		let width = widthlist[index]
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

fun! organ#table#align ()
	" Align char in all table lines
	let grid = organ#table#add_missing_columns ()
	let head_linum = organ#table#head ()
	let tail_linum = organ#table#tail ()
	let lencol = len(grid[0])
	let dual = organ#utils#dual(grid)
	let maxima = map(deepcopy(dual), { _, v -> max(v)})
	let index = 0
	for linum in range(head_linum, tail_linum)
		let line = getline(linum)
		let grid_index = grid[index]
		for colnum in range(lencol)
			let col = grid_index[colnum]
			let add = maxima[colnum] - col
			if add > 0
				let spaces = repeat(' ', add)
				if col == 1
					let before = ''
					let after = line
				elseif col ==
				else
					let before = line[:colnum - 2]
					let after = line[colnum - 1:]
				endif
				let newline = before .. spaces .. after
				call setline(linum, newline)
			endif
		endfor
		let index += 1
	endfor
endfun
