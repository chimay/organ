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

if exists('s:hollow_pattern')
	unlockvar s:hollow_pattern
endif
let s:hollow_pattern = organ#crystal#fetch('pattern/line/hollow')
lockvar s:hollow_pattern

" ---- helpers

" -- patterns

fun! organ#table#delimiter ()
	" Tables column char
	return '|'
endfun

fun! organ#table#sepline_delimiter ()
	" Tables column delimiter in separator line
	if &filetype ==# 'org'
		return '+'
	elseif &filetype ==# 'markdown'
		return '|'
	endif
	return '+'
endfun

fun! organ#table#sepline_delimiter_pattern ()
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

fun! organ#table#sepline_pattern ()
	" Separator line pattern
	if &filetype ==# 'org'
		let pattern = '\m^\s*|-\+|\s*$\|'
		let pattern ..= '^\s*|\%(-*+\)\+-*|\s*$'
		return pattern
	elseif &filetype ==# 'markdown'
		let pattern = '\m^\s*|[-:]\+|\%([-:]*|\)*\s*$'
		return pattern
	endif
	let pattern = '\m^\s*|[-+|]*[-+]\+[-+|]*|\s*$'
	return pattern
endfun

fun! organ#table#outside_pattern ()
	" Pattern for non table lines
	let delimiter = organ#table#delimiter ()
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
	let pattern = organ#table#sepline_pattern ()
	return line =~ pattern
endfun

" -- head & tail

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

" -- grid

fun! organ#table#lengthes (grid)
	" Lengthes of lists in grid
	let grid = deepcopy(a:grid)
	return map(grid, { _, v -> len(v)})
endfun

fun! organ#table#metalen (grid)
	" Lengthes of each element of grid
	let grid = deepcopy(a:grid)
	" ---- count tabs as 'tabstop' chars, and multibyte char as one
	let Lengthes = { list -> copy(list)->map({ _, v -> strdisplaywidth(v) }) }
	let Metalen = { _, list -> Lengthes(list) }
	return map(grid, Metalen)
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

" -- grid, align

fun! organ#table#delimgrid (paragraph)
	" Grid of cells limiters
	let paragraph = a:paragraph
	let delimiter = paragraph.delimpat
	let sepdelim_pattern = organ#table#sepline_delimiter_pattern ()
	let delimgrid = []
	" ---- loop
	let linum = paragraph.linumlist[0]
	for line in paragraph.linelist
		let delimrow = []
		"let Addmatch = { match -> string(delimrow->add(match[0])[-1]) }
		if organ#table#is_separator_line (linum)
			" -- not a real substitute, just to gather matches
			" -- it's that or a while loop with matchstr()
			"call substitute(line, separator_delimiter, Addmatch, 'g')
			" -- or
			call substitute(line, sepdelim_pattern, '\=delimrow->add(submatch(0))', 'g')
		else
			"call substitute(line, delimiter, Addmatch, 'g')
			" -- or
			call substitute(line, delimiter, '\=delimrow->add(submatch(0))', 'g')
		endif
		eval delimgrid->add(delimrow)
		let linum += 1
	endfor
	" ---- coda
	return delimgrid
endfun

fun! organ#table#cellgrid (paragraph)
	" Grid of cells contents
	" Use split(string, pattern, keepempty)
	let paragraph = a:paragraph
	let is_table = paragraph.is_table
	let delimiter = paragraph.delimpat
	let sepdelim_pattern = organ#table#sepline_delimiter_pattern ()
	let cellgrid = []
	" ---- loop
	let linum = paragraph.linumlist[0]
	for line in paragraph.linelist
		if organ#table#is_separator_line (linum)
			let cellrow = line->split(sepdelim_pattern, v:true)
		else
			let cellrow = line->split(delimiter, v:true)
		endif
		let first = cellrow[0]
		eval cellrow->map({ _, v -> trim(v) })
		if is_table
			" -- first cell is indent
			let cellrow[0] = first
		else
			let cellrow[0] = first->substitute('\s*$', '', '')
		endif
		if is_table
			" -- last cell is spaces or empty
			if ! empty(cellrow[-1])
				throw 'organ table cellgrid : last table field is not empty'
				"return []
			endif
			let cellrow = cellrow[:-2]
		endif
		" -- add to grid
		eval cellgrid->add(cellrow)
		let linum += 1
	endfor
	" ---- coda
	return cellgrid
endfun

fun! organ#table#size (paragraph)
	" Size of table in paragraph
endfun

" -- positions

fun! organ#table#positions (...)
	" Positions in bytes of the delimiter char
	" First char of the line = 1
	if a:0 > 0
		let linum = a:1
	else
		let linum = line('.')
	endif
	if a:0 > 1
		let pattern = a:2
	else
		let pattern = organ#table#sepline_delimiter_pattern ()
	endif
	let line = getline(linum)
	let positions = []
	let index = 0
	while v:true
		let index = line->match(pattern, index)
		if index < 0
			break
		endif
		eval positions->add(index)
		let index += 1
	endwhile
	return positions
endfun

fun! organ#table#charpos (...)
	" Positions in char indexes of the delimiter char
	" First char of the line = 1
	if a:0 > 0
		let linum = a:1
	else
		let linum = line('.')
	endif
	if a:0 > 1
		let pattern = a:2
	else
		let pattern = organ#table#sepline_delimiter_pattern ()
	endif
	let line = getline(linum)
	let positions = []
	let byte_index = 0
	while v:true
		let byte_index = line->match(pattern, byte_index)
		if byte_index < 0
			break
		endif
		let char_index = line->charidx(byte_index)
		eval positions->add(char_index)
		let byte_index += 1
	endwhile
	return positions
endfun

" -- cursor

fun! organ#table#cursor (paragraph)
	" Cursor info in table
	" - position in buffer
	" - (row & col) in table
	" - local position in table cell
	let paragraph = a:paragraph
	let is_table = paragraph.is_table
	let linumlist = paragraph.linumlist
	" ---- cursor
	let cursor = {}
	let cursor.table = {}
	let cursor.buffer = {}
	let curpos = getcurpos ()
	let cursor.buffer.position = curpos
	let cursor.buffer.linum = curpos[1]
	let cursor.buffer.colnum = curpos[2]
	let curlinum = cursor.buffer.linum
	let cursorcolindex = cursor.buffer.colnum - 1
	" ---- patterns
	if organ#table#is_separator_line (curlinum)
		let delimpat = organ#table#sepline_delimiter_pattern ()
	else
		let delimpat = paragraph.delimpat
	endif
	" ---- delimiter positions
	let positions = organ#table#positions (curlinum, delimpat)
	let colmax = len(positions)
	" ---- current row
	let cursor.table.row = linumlist->index(curlinum)
	" ---- current column
	" -- note : in tables :
	" --   + indent = cellrow[0]
	" --   + first col = cellrow[1]
	if cursorcolindex < positions[0]
		let cursor.table.col = 0
		let indent = organ#stair#info ()
		let netshift = cursorcolindex - indent.total
		let cursor.table.localshift = max([netshift, 0])
	elseif cursorcolindex > positions[-1]
		let cursor.table.col = colmax
		let cursor.table.localshift = cursorcolindex - positions[- 1]
	else
		for colnum in range(1, colmax - 1)
			if cursorcolindex >= positions[colnum - 1] && cursorcolindex <= positions[colnum]
				let cursor.table.col = colnum
				let cursor.table.localshift = cursorcolindex - positions[colnum - 1]
				break
			endif
		endfor
	endif
	return cursor
endfun

fun! organ#table#adapt_cursor (paragraph)
	" Adapt cursor position to row & col registered in paragraph
	let paragraph = a:paragraph
	let linumlist = paragraph.linumlist
	let cursor = paragraph.cursor
	let currownum = cursor.table.row
	let curcolnum = cursor.table.col
	let localshift = cursor.table.localshift
	" ---- cursor buffer line
	let curlinum = linumlist[currownum]
	" ---- patterns
	if organ#table#is_separator_line (curlinum)
		let delimpat = organ#table#sepline_delimiter_pattern ()
	else
		let delimpat = paragraph.delimpat
	endif
	" ---- delimiters positions
	let positions = organ#table#positions (curlinum, delimpat)
	" ---- cursor buffer column
	if curcolnum == 0
		let indent = organ#stair#info ()
		let totalshift = localshift + indent.total
		let cursorcol = 1 + totalshift
	else
		let cursorcol = positions[curcolnum - 1] + 1 + localshift
	endif
	" ---- move cursor
	call cursor(curlinum, cursorcol)
	" ---- update paragraph fields
	let cursor.buffer.linum = curlinum
	let cursor.buffer.colnum = cursorcol
	let cursor.buffer.position = getcurpos ()
	" ---- coda
	return paragraph
endfun

fun! organ#table#adapt_localshift (oldshift, oldcont, newcont)
	" Adapt local cell shift from old to new content
	let oldshift = a:oldshift
	let oldcont = a:oldcont
	let newcont = a:newcont
	let charnum = oldcont->charidx(oldshift)
	if charnum < 0
		return len(newcont)
	endif
	let newshift = newcont->byteidx(charnum)
	if newshift < 0
		return len(newcont)
	endif
	echomsg oldshift charnum newshift
	return newshift
endfun

" ---- align

fun! organ#table#shrink_separator_lines (paragraph)
	" Reduce separator line to their minimum
	let paragraph = a:paragraph
	let linelist = paragraph.linelist
	let lenlinelist = len(linelist)
	let cellgrid = paragraph.cellgrid
	let sepline_pattern = organ#table#sepline_pattern ()
	for rownum in range(lenlinelist)
		let line = linelist[rownum]
		let is_sep_line = line =~ sepline_pattern
		if ! is_sep_line
			continue
		endif
		" -- cells
		let cellrow = cellgrid[rownum]
		for colnum in range(1, len(cellrow) - 1)
			let cellrow[colnum] = '-'
		endfor
	endfor
	return paragraph
endfun

fun! organ#table#minindent (paragraph)
	" Minimize table indent
	let paragraph = a:paragraph
	" ---- eval min indent
	let linelist = paragraph.linelist
	let lenlinelist = len(linelist)
	let indentlist = copy(linelist)->map({ _, v -> organ#stair#info(v) })
	let totalist = copy(indentlist)->map({ _, v -> v.total })
	let minindent = min(totalist)
	let spaces = repeat(' ', minindent)
	let tabspaces = organ#stair#tabspaces(minindent)
	let mixed = tabspaces.string
	" ---- reduce
	for rownum in range(lenlinelist)
		let indentnum = totalist[rownum]
		if indentnum == minindent
			continue
		endif
		let line = linelist[rownum]
		if indentlist[rownum].tabs == 0
			let line = line->substitute(s:indent_pattern, spaces, '')
		else
			let line = line->substitute(s:indent_pattern, mixed, '')
		endif
		let linelist[rownum] = line
	endfor
	" ---- coda
	return paragraph
endfun

fun! organ#table#add_missing_delims (paragraph)
	" Add missing columns delimiters
	let paragraph = a:paragraph
	let linumlist = paragraph.linumlist
	let linelist = paragraph.linelist
	let delimiter = paragraph.delimpat
	let sepdelim = organ#table#sepline_delimiter ()
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
			let delimrow = delimgrid[rownum]
			if organ#table#is_separator_line (linum)
				let addme = sepdelim->repeat(add)
				let listaddme = [sepdelim]->repeat(add)
				" -- needs the colon for compatibilty
				let newline = line[:-2] .. addme .. line[-1:]
				let newdelims = delimrow[:-2] + listaddme + delimrow[-1:]
			else
				let addme = delimiter->repeat(add)
				let listaddme = [delimiter]->repeat(add)
				let newline = line .. addme
				let newdelims = delimrow + listaddme
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
	let linumlist = paragraph.linumlist
	let linelist = paragraph.linelist
	let lenlinelist = len(linelist)
	let cellgrid = paragraph.cellgrid
	let delimgrid = paragraph.delimgrid
	let lengrid = paragraph.lengrid
	let dual = organ#table#dual(lengrid)
	let maxima = organ#table#maxima(dual)
	let sepline_pattern = organ#table#sepline_pattern ()
	" ---- double loop
	for rownum in range(lenlinelist)
		let line = linelist[rownum]
		let is_sep_line = line =~ sepline_pattern
		" -- cells
		let cellrow = cellgrid[rownum]
		for colnum in range(len(cellrow))
			let content = cellrow[colnum]
			let add = maxima[colnum] - strdisplaywidth(content)
			if add == 0
				continue
			endif
			if colnum > 0 && is_sep_line
				let shift = repeat('-', add)
			else
				let shift = repeat(' ', add)
			endif
			if content =~ '^[0-9.]\+$'
				" number : align right
				let content = shift .. content
			else
				" other : align left
				let content = content .. shift
			endif
			let cellrow[colnum] = content
		endfor
	endfor
	" ---- coda
	return paragraph
endfun

fun! organ#table#rebuild (paragraph)
	" Rebuild lines from paragraph
	let paragraph = a:paragraph
	let is_table = paragraph.is_table
	let linelist = paragraph.linelist
	let lenlinelist = len(linelist)
	let cellgrid = paragraph.cellgrid
	let delimgrid = paragraph.delimgrid
	let sepline_pattern = organ#table#sepline_pattern ()
	for rownum in range(lenlinelist)
		let line = linelist[rownum]
		let is_sep_line = line =~ sepline_pattern
		let cellrow = cellgrid[rownum]
		let delimrow = delimgrid[rownum]
		let lencells = len(cellrow)
		let lendelims = len(delimrow)
		let newline = ''
		for colnum in range(lencells)
			if is_sep_line && colnum > 0
				let postcell = '-'
			elseif is_table && colnum == 0
				let postcell = ''
			else
				let postcell = ' '
			endif
			if is_sep_line && colnum < lencells - 1
				let postdelim = '-'
			elseif colnum == lencells - 1
				let postdelim = ''
			else
				let postdelim = ' '
			endif
			let newline ..= cellrow[colnum] .. postcell
			if colnum < lendelims
				let newline ..= delimrow[colnum] .. postdelim
			endif
		endfor
		let linelist[rownum] = newline->substitute('\m\s*$', '', 'g')
	endfor
	return paragraph
endfun

fun! organ#table#commit (paragraph)
	" Commit lines to buffer
	let paragraph = a:paragraph
	let linum = paragraph.linumlist[0]
	let pristine = paragraph.pristine
	let rownum = 0
	let modified = 0
	for line in paragraph.linelist
		if line !=# pristine[rownum]
			let modified += 1
			call setline(linum, line)
		endif
		let rownum += 1
		let linum += 1
	endfor
	let paragraph.modified = modified
	return paragraph
endfun

fun! organ#table#align (mode = 'normal') range
	" Align table or paragraph
	call organ#origami#suspend ()
	let mode = a:mode
	" ---- init
	let paragraph = {}
	let paragraph.is_table = organ#table#is_in_table ()
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
	" ---- delimiter pattern
	if paragraph.is_table
		let paragraph.delimpat = organ#table#delimiter ()
	else
		let prompt = 'Align following pattern : '
		let paragraph.delimpat = input(prompt, '')
	endif
	" ---- cursor info, including row & col in table
	let paragraph.cursor = organ#table#cursor (paragraph)
	" ---- indent
	let paragraph = organ#table#minindent(paragraph)
	" ---- delimiters
	let paragraph.delimgrid = organ#table#delimgrid(paragraph)
	if paragraph.is_table
		let paragraph = organ#table#add_missing_delims(paragraph)
	endif
	" ---- cells
	let paragraph.cellgrid = organ#table#cellgrid(paragraph)
	if paragraph.is_table
		let paragraph = organ#table#shrink_separator_lines(paragraph)
	endif
	let paragraph.lengrid = organ#table#metalen(paragraph.cellgrid)
	" ---- align cells
	let paragraph = organ#table#align_cells (paragraph)
	" ---- rebuild lines
	let paragraph = organ#table#rebuild (paragraph)
	" ---- commit lines to buffer
	call organ#table#commit (paragraph)
	" ---- adapt cursor position
	call organ#table#adapt_cursor (paragraph)
	" ---- coda
	call organ#origami#resume ()
	return paragraph
endfun

" ---- build paragraph

fun! organ#table#fill (...)
	" FIll paragraph dict
	if a:0 > 1
		let head_linum = a:1
		let tail_linum = a:2
	else
		let head_linum = organ#table#head ()
		let tail_linum = organ#table#tail ()
	endif
	" ---- init
	let paragraph = {}
	let paragraph.is_table = organ#table#is_in_table ()
	" ---- lines
	let paragraph.linumlist = range(head_linum, tail_linum)
	let paragraph.linelist = getline(head_linum, tail_linum)
	let paragraph.pristine = copy(paragraph.linelist)
	" ---- delimiter pattern
	let paragraph.delimpat = organ#table#delimiter ()
	" ---- cursor info, including row & col in table
	let paragraph.cursor = organ#table#cursor (paragraph)
	" ---- indent
	let paragraph = organ#table#minindent(paragraph)
	" ---- delimiters
	let paragraph.delimgrid = organ#table#delimgrid(paragraph)
	let paragraph = organ#table#add_missing_delims(paragraph)
	" ---- cells
	let paragraph.cellgrid = organ#table#cellgrid(paragraph)
	let paragraph = organ#table#shrink_separator_lines(paragraph)
	let paragraph.lengrid = organ#table#metalen(paragraph.cellgrid)
	let paragraph = organ#table#align_cells (paragraph)
	" ---- rebuild lines
	let paragraph = organ#table#rebuild (paragraph)
	" ---- coda
	return paragraph
endfun

" ---- update

fun! organ#table#update (...)
	" Update table : to be used in InsertLeave autocommand
	if ! organ#table#is_in_table ()
		return {}
	endif
	" ---- build
	let paragraph = call('organ#table#fill', a:000)
	" ---- commit
	call organ#table#commit (paragraph)
	" ---- adapt cursor position
	call organ#table#adapt_cursor (paragraph)
	" ---- coda
	return paragraph
endfun

" ---- navigation

fun! organ#table#previous_cell ()
	" Go to previous cell
	let paragraph = organ#table#update ()
	let cellgrid = paragraph.cellgrid
	let linelist = paragraph.linelist
	" ---- cursor
	let cursor = paragraph.cursor
	let currownum = cursor.table.row
	let curcolnum = cursor.table.col
	" ---- patterns
	let sepline_pattern = organ#table#sepline_pattern ()
	" ---- departure cell content
	let curcellrow = cellgrid[currownum]
	let colmax = len(curcellrow)
	if curcolnum == colmax
		let oldcont = ''
	else
		let oldcont = curcellrow[curcolnum]
	endif
	" ---- row & col
	if curcolnum <= 1
		if currownum == 0
			return paragraph
		endif
		let above_rownum = currownum - 1
		while v:true
			if linelist[above_rownum] !~ sepline_pattern
				break
			endif
			if above_rownum == 0
				return paragraph
			endif
			let above_rownum -= 1
		endwhile
		let currownum = above_rownum
		let curcellrow = cellgrid[currownum]
		let colmax = len(curcellrow)
		let curcolnum = colmax
	endif
	let curcolnum -= 1
	" ---- arrival cell content
	let newcont = cellgrid[currownum][curcolnum]
	" ---- adapt localshift in case of unicode long chars
	let oldshift = cursor.table.localshift
	let newshift = organ#table#adapt_localshift (oldshift, oldcont, newcont)
	let cursor.table.localshift = newshift
	" -- adapt cursor
	let cursor.table.row = currownum
	let cursor.table.col = curcolnum
	call organ#table#adapt_cursor (paragraph)
	" ---- coda
	return paragraph
endfun

fun! organ#table#next_cell ()
	" Go to next cell
	let paragraph = organ#table#update ()
	let linelist = paragraph.linelist
	let lenlinelist = len(linelist)
	let cellgrid = paragraph.cellgrid
	" ---- cursor
	let cursor = paragraph.cursor
	let currownum = cursor.table.row
	let curcolnum = cursor.table.col
	" ---- patterns
	let sepline_pattern = organ#table#sepline_pattern ()
	" ---- departure cell content
	let curcellrow = cellgrid[currownum]
	let colmax = len(curcellrow)
	if curcolnum == colmax
		let oldcont = ''
	else
		let oldcont = curcellrow[curcolnum]
	endif
	" ---- row & col
	let curcellrow = cellgrid[currownum]
	let colmax = len(curcellrow)
	if curcolnum >= colmax - 1
		if currownum == len(linelist) - 1
			return paragraph
		endif
		let below_rownum = currownum + 1
		while v:true
			if linelist[below_rownum] !~ sepline_pattern
				break
			endif
			if below_rownum == lenlinelist - 1
				return paragraph
			endif
			let below_rownum += 1
		endwhile
		let currownum = below_rownum
		let curcolnum = 0
	endif
	let curcolnum += 1
	" ---- arrival cell content
	let newcont = cellgrid[currownum][curcolnum]
	" ---- adapt localshift in case of multibyte chars
	let oldshift = cursor.table.localshift
	let newshift = organ#table#adapt_localshift (oldshift, oldcont, newcont)
	let cursor.table.localshift = newshift
	" -- adapt cursor
	let cursor.table.row = currownum
	let cursor.table.col = curcolnum
	call organ#table#adapt_cursor (paragraph)
	" ---- coda
	return paragraph
endfun

fun! organ#table#cell_begin ()
	" Go to cell beginning
	let paragraph = organ#table#update ()
	let cellgrid = paragraph.cellgrid
	" ---- cursor
	let cursor = paragraph.cursor
	let currownum = cursor.table.row
	let curcolnum = cursor.table.col
	let curcellrow = cellgrid[currownum]
	" ---- we need at least one column
	" -- curcellrow contains :
	" --   + 1 indent cell
	" --   + row cells
	let colmax = len(curcellrow)
	if colmax <= 1
		return paragraph
	endif
	" ---- border case
	if curcolnum == 0
		let cursor.table.col = 1
	endif
	if curcolnum == colmax
		let cursor.table.col -= 1
	endif
	" ---- local shift
	let cursor.table.localshift = 2
	" ---- apply
	call organ#table#adapt_cursor (paragraph)
	" ---- coda
	return paragraph
endfun

fun! organ#table#cell_end ()
	" Go to cell end
	let paragraph = organ#table#update ()
	let cellgrid = paragraph.cellgrid
	" ---- cursor
	let cursor = paragraph.cursor
	let currownum = cursor.table.row
	let curcolnum = cursor.table.col
	let curcellrow = cellgrid[currownum]
	" ---- we need at least one column
	" -- curcellrow contains :
	" --   + 1 indent cell
	" --   + row cells
	let colmax = len(curcellrow)
	if colmax <= 1
		return paragraph
	endif
	" ---- border case
	if curcolnum == 0
		let curcolnum = 1
		let cursor.table.col = 1
	endif
	if curcolnum == colmax
		let curcolnum -= 1
		let cursor.table.col -= 1
	endif
	" ---- local shift
	let content = curcellrow[curcolnum]
	let cursor.table.localshift = len(content) + 1
	" ---- apply
	call organ#table#adapt_cursor (paragraph)
	" ---- coda
	return paragraph
endfun

" ---- select

fun! organ#table#select_cell ()
	" Select cell content
	normal! v
	let linum = organ#table#cell_begin ()
	let flags = organ#utils#search_flags ('forth', 'move', 'dont-wrap', 'ok-here')
	let linum = search('\S', flags)
	normal! o
	let linum = organ#table#cell_end ()
	let flags = organ#utils#search_flags ('back', 'move', 'dont-wrap', 'ok-here')
	let linum = search('\S', flags)
	return linum
endfun

" ---- duplicate above cell content to current one

fun! organ#table#duplicate ()
	" Duplicate above cell content to current one
	call organ#origami#suspend ()
	let paragraph = organ#table#update ()
	let linumlist = paragraph.linumlist
	let linelist = paragraph.linelist
	let cellgrid = paragraph.cellgrid
	" ---- cursor
	let cursor = paragraph.cursor
	let curlinum = cursor.buffer.linum
	let cursorcol = cursor.buffer.colnum
	let currownum = cursor.table.row
	let curcolnum = cursor.table.col
	" ---- we need at least a table row above
	if currownum <= 0
		return paragraph
	endif
	" ---- patterns
	let sepline_pattern = organ#table#sepline_pattern ()
	" ---- above row
	let above_rownum = currownum - 1
	while v:true
		if linelist[above_rownum] !~ sepline_pattern
			break
		endif
		if above_rownum == 0
			return paragraph
		endif
		let above_rownum -= 1
	endwhile
	let aboverow = cellgrid[above_rownum]
	" ---- (above row, same col) content -> (current row, current col)
	let oldcont = cellgrid[currownum][curcolnum]
	let newcont = aboverow[curcolnum]
	if newcont =~ s:hollow_pattern
		return paragraph
	endif
	let cellgrid[currownum][curcolnum] = newcont
	" ---- adapt localshift in case of unicode long chars
	let oldshift = cursor.table.localshift
	let newshift = organ#table#adapt_localshift (oldshift, oldcont, newcont)
	let cursor.table.localshift = newshift
	" ---- sync paragraph -> table
	let paragraph = organ#table#rebuild (paragraph)
	call organ#table#commit (paragraph)
	call organ#table#adapt_cursor (paragraph)
	" ---- coda
	call organ#origami#resume ()
	return paragraph
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

fun! organ#table#move_col_left (...)
	" Move table column left
	call organ#origami#suspend ()
	let paragraph = organ#table#update ()
	let linumlist = paragraph.linumlist
	let linelist = paragraph.linelist
	let lenlinelist = len(linelist)
	let cellgrid = paragraph.cellgrid
	" ---- cursor
	let cursor = paragraph.cursor
	let curlinum = cursor.buffer.linum
	let cursorcol = cursor.buffer.colnum
	let currownum = cursor.table.row
	let curcolnum = cursor.table.col
	let curcellrow = cellgrid[currownum]
	" ---- we need at least two columns
	" -- curcellrow contains :
	" --   + 1 indent cell
	" --   + row cells
	let colmax = len(curcellrow)
	if colmax <= 3
		return paragraph
	endif
	" ---- can't move further left
	if curcolnum <= 1
		return paragraph
	endif
	" ---- exchange columns
	for rownum in range(lenlinelist)
		let cellrow = cellgrid[rownum]
		let previous = cellrow[curcolnum - 1]
		let current = cellrow[curcolnum]
		let newcellrow = copy(cellrow)
		let newcellrow[curcolnum - 1] = current
		let newcellrow[curcolnum] = previous
		let cellgrid[rownum] = newcellrow
	endfor
	" ---- sync paragraph -> table
	let paragraph = organ#table#rebuild (paragraph)
	call organ#table#commit (paragraph)
	" -- adapt cursor
	let cursor.table.col -= 1
	call organ#table#adapt_cursor (paragraph)
	" ---- coda
	call organ#origami#resume ()
	return paragraph
endfun

fun! organ#table#move_col_right ()
	" Move table column right
	call organ#origami#suspend ()
	let paragraph = organ#table#update ()
	let linumlist = paragraph.linumlist
	let linelist = paragraph.linelist
	let lenlinelist = len(linelist)
	let cellgrid = paragraph.cellgrid
	" ---- cursor
	let cursor = paragraph.cursor
	let curlinum = cursor.buffer.linum
	let cursorcol = cursor.buffer.colnum
	let currownum = cursor.table.row
	let curcolnum = cursor.table.col
	let curcellrow = cellgrid[currownum]
	" ---- we need at least two columns
	" -- curcellrow contains :
	" --   + 1 indent cell
	" --   + row cells
	let colmax = len(curcellrow)
	if colmax < 3
		return paragraph
	endif
	" ---- can't move further right
	if curcolnum >= colmax - 1
		return paragraph
	endif
	" ---- exchange columns
	for rownum in range(lenlinelist)
		let cellrow = cellgrid[rownum]
		" -- indent = cellrow[0]
		" -- first col = cellrow[1]
		let current = cellrow[curcolnum]
		let next = cellrow[curcolnum + 1]
		let newcellrow = copy(cellrow)
		let newcellrow[curcolnum] = next
		let newcellrow[curcolnum + 1] = current
		let cellgrid[rownum] = newcellrow
	endfor
	" ---- sync paragraph -> table
	let paragraph = organ#table#rebuild (paragraph)
	call organ#table#commit (paragraph)
	" -- adapt cursor
	let cursor.table.col += 1
	call organ#table#adapt_cursor (paragraph)
	" ---- coda
	call organ#origami#resume ()
	return paragraph
endfun

" ---- new rows & cols

fun! organ#table#new_row ()
	" Add new row below cursor line
	let linum = line('.')
	let newrow = '| |'
	call append('.', newrow)
	let paragraph = organ#table#update()
	call cursor(linum + 1, col('.'))
	return paragraph
endfun

fun! organ#table#new_separator_line ()
	" Add new row below cursor line
	let linum = line('.')
	let newrow = '|-|'
	call append('.', newrow)
	let paragraph = organ#table#update()
	call cursor(linum + 1, col('.'))
	return paragraph
endfun

fun! organ#table#new_col ()
	" Add new column at the right of the cursor
	" Assume the table is aligned
	call organ#origami#suspend ()
	let paragraph = organ#table#update ()
	let linumlist = paragraph.linumlist
	let linelist = paragraph.linelist
	let lenlinelist = len(linelist)
	let cellgrid = paragraph.cellgrid
	let delimgrid = paragraph.delimgrid
	" ---- cursor
	let cursor = paragraph.cursor
	let currownum = cursor.table.row
	let curcolnum = cursor.table.col
	let curcellrow = cellgrid[currownum]
	" ---- patterns
	let delim = organ#table#delimiter ()
	let seplinedelim = organ#table#sepline_delimiter ()
	let sepline_pattern = organ#table#sepline_pattern ()
	" ---- we need at least one column
	" -- curcellrow contains :
	" --   + 1 indent cell
	" --   + row cells
	let colmax = len(curcellrow)
	if colmax < 2
		return paragraph
	endif
	" ---- new column
	if curcolnum == colmax
		let curcolnum -= 1
	endif
	let nextcolnum = curcolnum + 1
	for rownum in range(lenlinelist)
		let line = linelist[rownum]
		let cellrow = cellgrid[rownum]
		let delimrow = delimgrid[rownum]
		if line =~ sepline_pattern
			eval cellrow->insert('-', nextcolnum)
			eval delimrow->insert(seplinedelim, 1)
		else
			eval cellrow->insert(' ', nextcolnum)
			eval delimrow->insert(delim, 1)
		endif
	endfor
	" ---- sync paragraph -> table
	let paragraph = organ#table#rebuild (paragraph)
	call organ#table#commit (paragraph)
	" -- adapt cursor
	let cursor.table.col += 1
	let cursor.table.localshift = 2
	call organ#table#adapt_cursor (paragraph)
	" ---- coda
	call organ#origami#resume ()
	return paragraph
endfun

" ---- delete rows & cols

fun! organ#table#delete_row ()
	" Delete row
	call organ#utils#delete(line('.'))
endfun

fun! organ#table#delete_col ()
	" Delete column
	call organ#origami#suspend ()
	let paragraph = organ#table#update ()
	let linumlist = paragraph.linumlist
	let linelist = paragraph.linelist
	let lenlinelist = len(linelist)
	let cellgrid = paragraph.cellgrid
	let delimgrid = paragraph.delimgrid
	" ---- cursor
	let cursor = paragraph.cursor
	let currownum = cursor.table.row
	let curcolnum = cursor.table.col
	let curcellrow = cellgrid[currownum]
	" ---- patterns
	let delim = organ#table#delimiter ()
	let seplinedelim = organ#table#sepline_delimiter ()
	" ---- we need at least one column
	" -- curcellrow contains :
	" --   + 1 indent cell
	" --   + row cells
	let colmax = len(curcellrow)
	if colmax <= 1
		return paragraph
	endif
	" ---- delete column
	if curcolnum == colmax
		let curcolnum -= 1
	endif
	for rownum in range(lenlinelist)
		let line = linelist[rownum]
		let cellrow = cellgrid[rownum]
		let delimrow = delimgrid[rownum]
		eval cellrow->remove(curcolnum)
		eval delimrow->remove(1)
	endfor
	" ---- sync paragraph -> table
	let paragraph = organ#table#rebuild (paragraph)
	call organ#table#commit (paragraph)
	" -- adapt cursor
	let cursor.table.col = max([curcolnum - 1, 0])
	let cursor.table.localshift = 2
	call organ#table#adapt_cursor (paragraph)
	" ---- coda
	call organ#origami#resume ()
	return paragraph
endfun
