<!-- vim: set filetype=markdown: -->

<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
    * [What is it ?](#what-is-it-)
    * [Screenshots](#screenshots)
    * [Compatibilty](#compatibilty)
    * [Features](#features)
    * [Differences with standard orgmode](#differences-with-standard-orgmode)
    * [Dependencies](#dependencies)
        * [Export](#export)
        * [Across files](#across-files)
* [Installation](#installation)
    * [Using vim-packager](#using-vim-packager)
    * [Cloning the repo in a pack-start directory](#cloning-the-repo-in-a-pack-start-directory)
* [Configuration](#configuration)
    * [Persistent data](#persistent-data)
* [Bindings](#bindings)
    * [Speed keys](#speed-keys)
    * [Always defined](#always-defined)
    * [Prefixless](#prefixless)
    * [With prefix](#with-prefix)
    * [Custom](#custom)
    * [Available plugs](#available-plugs)
* [Folding](#folding)
    * [Markers](#markers)
    * [Indent](#indent)
* [Meta-command](#meta-command)
* [Prompt completion](#prompt-completion)
* [Autocommands](#autocommands)
* [Related](#related)
* [Misc](#misc)
    * [Why this name](#why-this-name)
    * [Why another orgmode clone for vim ?](#why-another-orgmode-clone-for-vim-)
* [Warning](#warning)

<!-- vim-markdown-toc -->

# Introduction
## What is it ?

Organ generalizes the great concepts of Orgmode to Markdown and any
folded file. It is primarily focused on editing these documents with
ease and agility.

## Screenshots

Headline completion, todo, links, list, table :

![all](https://github.com/chimay/organ-multimedia/blob/main/all.jpg)

See also the [organ-multimedia repository](https://github.com/chimay/organ-multimedia).

## Compatibilty

Organ supports :

- org files
- markdown
- asciidoc : headings only
- folded files with markers
- indent folded files : basic navigation only

It is written in vimscript and is compatible with both Vim and Neovim.

## Features

- folding based on headings in org and markdown files
- headings base on folding in folded files
  + you can handle your folds like orgmode headings
- navigate in headings or list items hierarchy
  + next, previous : any level
  + forward, backward : same level as current one
  + parent heading, upper level
  + child heading, lower level :
    - loosely speaking : first headline of level + 1, forward
    - strictly speaking : must be in the current subtree
  + go to another headline with prompt completion of full path
- modify headings or list items
  + new headline or list item
  + select, yank, delete subtree
  + promote, demote heading or list item
  + move subtree up or down
  + move current subtree in another one (aka org-refile)
- cycle todo status
- cycle list item prefix
- insert timestamp
- expand shortcut to template (aka org-structure-template)
  + markdown support limited to code blocks
- links
  + store url at cursor
  + create link with url completion
  + goto link under or close to cursor
  + goto next/previous link
- tables
  + inside of table : align columns
  + outside of table : align following a pattern
  + add new row, colum
  + delete row, colum
  + move row up or down
  + move column left or right
- export in another format using
  + pandoc
  + emacs
  + asciidoc or asciidoctor
  + view exported document
- convert headings and links org <-> markdown

## Differences with standard orgmode

- speed keys are also available in first char of list item line
- movements can
  + wrap around the end of the file
  + cross over a parent headline

## Dependencies

The core part runs on its own.

Some extra-features need external tools, see below.

### Export

If you want to export your file to another format, you just need to have
pandoc installed, and the plugin takes care of the rest.  For org files,
it can also be done with emacs installed, at least for the formats
supported by orgmode.

For asciidoc files, you need to install asciidoc or asciidoctor.

### Across files

If you want to add interactions between org or markdown files, you can
install [wheel](https://github.com/chimay/wheel). With it, you can :

- quickly jump to another org/markdown/whatever file
- look for headlines in all orgmode or markdown files of a group (aka outline)
- grep all your group files for special keywords, like TODO

# Installation
## Using vim-packager

Simply add this line after `packager#init()` to your initialisation file :

~~~vim
call packager#add('chimay/organ', { 'type' : 'start' })
~~~

and run `:PackagerInstall` (see the
[vim-packager readme](https://github.com/kristijanhusak/vim-packager)).

The syntax should be similar with other git oriented plugin managers.

## Cloning the repo in a pack-start directory

You can clone the repository somewhere in your `runtime-search-path`. You
can get a minimal version by asking a shallow clone (depth 1) and
filtering out the screenshots blobs :

```vim
mkdir -p ~/.local/share/nvim/site/pack/foo/start
cd ~/.local/share/nvim/site/pack/foo/start
git clone --depth 1 --filter=blob:none https://github.com/chimay/organ
```

If you install or update with git, don't forget to run :

```vim
:helptags doc
```

to be able to use the inline help.

# Configuration

Here is a complete example, cherrypick what you need :

```vim
if ! exists("g:organ_loaded")
  " ---- initialize dicts
  let g:organ_config = {}
  let g:organ_config.list = {}
  let g:organ_config.links = {}
  let g:organ_config.templates = {}
  " ---- enable for every file if > 0
  let g:organ_config.everywhere = 0
  " ---- enable speed keys on first char of headlines and list items
  let g:organ_config.speedkeys = 1
  " ---- key to trigger <plug>(organ-previous)
  " ---- and go where speedkeys are available
  " ---- examples : <m-p> (default), [z
  let g:organ_config.previous = '<m-p>'
  " ---- choose your mappings prefix
  let g:organ_config.prefix = '<m-o>'
  " ---- enable prefixless maps
  let g:organ_config.prefixless = 1
  " ---- prefixless maps in these modes (default)
  " ---- possible values : normal, visual, insert
  " ---- visual maps are defined only when significant
  let g:organ_config.prefixless_modes = ['normal', 'visual', 'insert']
  " ---- enable only the prefixless maps you want
  " ---- see the output of :map <plug>(organ- to see available plugs
  " let g:organ_config.prefixless_plugs = ['organ-next', 'organ-backward', 'organ-forward']
  " ---- number of spaces to indent lists (default)
  let g:organ_config.list.indent_length = 2
  " ---- items chars in unordered list (default)
  let g:organ_config.list.unordered = #{ org : ['-', '+', '*'], markdown : ['-', '+']}
  " ---- items chars in ordered list (default)
  let g:organ_config.list.ordered = #{ org : ['.', ')'], markdown : ['.']}
  " ---- first item counter in an ordered list
  " ---- must be >= 0
  " ---- default 1
  let g:organ_config.list.counter_start = 1
  " ---- number of stored links to keep (default)
  let g:organ_config.links.keep = 5
  " ---- shortcuts to expand templates
  " ---- examples from default settings
  " ---- run :echo g:organ_config.templates to see all
  " -- #+begin_center bloc
  let g:organ_config.templates['<c'] = 'center'
  " -- #+include: line
  let g:organ_config.templates['+i'] = 'include'
  " ---- todo keywoard cycle
  " ---- default : todo : TODO - DONE - none
  " ---- no need to add none to the list
  let g:organ_config.todo_cycle = ['TODO', 'IN PROGRESS', 'ALMOST DONE', 'DONE']
  " ---- timestamp format
  let g:organ_config.timestamp_format = '<%Y-%m-%d %a %H:%M>'
  " ---- custom maps
  nmap <c-cr> <plug>(organ-meta-return)
  imap <c-cr> <plug>(organ-meta-return)
  nnoremap <backspace> :Organ<space>
endif
```

## Persistent data

The following data :

- stored urls

are kept in the `g:ORGAN_STOPS` global variable. It is persistent across
(neo)vim sessions if you have `!` in your 'shada' (neovim) or 'viminfo'
(vim) option.

# Bindings
## Speed keys

If you set the `g:organ_config.speedkeys` variable to a greater-than-zero
value in your init file, the speed keys become available. They are active
only in normal mode, when the cursor is on the first char of a headline
or a list item line. Here is a complete list :

- `<f1>`       : help
- `<pageup>`   : previous heading
- `<pagedown>` : next heading
- `<home>`     : backward heading of same level
- `<end>`      : forward heading of same level
- `+`          : upper, parent heading
- `-`          : lower, child heading, loosely speaking
- `_`          : lower, child heading, strictly speaking
- `i`          : info : full headings path (part, chapter, section, subsection, ...)
- `h`          : go to headline, with prompt completion of full headings path
- `s`          : select subtree
- `Y`          : yank subtree
- `X`          : delete subtree
- `<del>`      : promote heading (and delete a level of indent)
- `<ins>`      : demote heading (and insert a level of indent)
- `H`          : promote subtree
- `L`          : demote subtree
- `U`          : move subtree up
- `D`          : move subtree down
- `M`          : move subtree in another one, with prompt completion

Some of them are context sensitive :

| Map       | First char in heading line    | Table               |
|-----------|-------------------------------|---------------------|
| `<tab>`   | cycle current fold visibility | go to next cell     |
| `<s-tab>` | cycle all folds visibility    | go to previous cell |

Some of them are filetype dependent :

| Map | Org                | Asciidoc                | Other              |
|-----|--------------------|-------------------------|--------------------|
| `e` | export with emacs  | export with asciidoc    | export with pandoc |
| `E` | export with pandoc | export with asciidoctor | export with pandoc |

## Always defined

Once you are on the first char of a headline, the speedkeys become
available. The plug `<plug>(organ-previous)` brings you precisely there,
and is therefore one of the most important maps. For this reason,
it's always defined, regardless of the prefixless setting. You can use
`g:organ_config.previous` to choose the key that triggers it.

## Prefixless

If you set the `g:organ_config.prefixless` variable to a greater-than-zero
value in your init file, these bindings become available :

- `<M-i>`      : info  : full headings path (chapter, section, subsection, ...)
- `<M-h>`      : go to headline, with prompt completion of full headings path
- `<M-z>`      : cycle current fold visibility (like an improved `za`)
- `<M-S-z>`    : cycle all folds visibility
- `<M-m>`      : move subtree in another one, with prompt completion
- `<M-x>`      : expand template
- `<M-s>`      : store url at cursor
- `<M-->`      : (press alt and dash) create new link
- `<M-@>`      : go to previous link
- `<M-&>`      : go to next link
- `<M-o>`      : go to link under or close to cursor
- `<M-d>`      : add date & time stamp
- `<M-_>`      : table : add a separator line
- `<M-e>`      : export with pandoc
- `<M-S-e>`    : export with emacs (works only in org files)

Some of them are context sensitive :

| Map           | Heading                 | List               | Table               |
|---------------|-------------------------|--------------------|---------------------|
| `<M-p>`       | previous heading        | previous item      |                     |
| `<M-n>`       | next heading            | next item          |                     |
| `<M-b>`       | prev head, same level   | prev item, = level |                     |
| `<M-f>`       | next head, same level   | next item, = level |                     |
| `<M-u>`       | parent heading          | parent item        |                     |
| `<M-l>`       | child heading, loose    | child item, loose  |                     |
| `<M-S-l>`     | child heading, strict   | child item, strict |                     |
| `<M-v>`       | select subtree          | select subtree     |                     |
| `<M-y>`       | yank subtree            | yank subtree       |                     |
| `<M-S-x>`     | delete subtree          | delete subtree     |                     |
| `<M-a>`       |                         |                    | align table         |
| `<M-CR>`      | new subtree             | new subtree        | new row             |
| `<M-left>`    | promote                 | promote            | move column left    |
| `<M-right>`   | demote                  | demote             | move column right   |
| `<M-up>`      | move subtree up         | move subtree up    | move row up         |
| `<M-down>`    | move subtree down       | move subtree down  | move row down       |
| `<S-left>`    |                         | cycle prefix left  |                     |
| `<S-right>`   |                         | cycle prefix right |                     |
| `<S-up>`      | cycle todo left         | cycle todo left    |                     |
| `<S-down>`    | cycle todo right        | cycle todo right   |                     |
| `<M-S-left>`  | promote subtree         | promote subtree    | new column          |
| `<M-S-right>` | demote subtree          | demote subtree     | delete column       |
| `<M-S-up>`    |                         |                    | delete row          |
| `<M-S-down>`  |                         |                    | new row             |

The align function can also be used to align a paragraph, or the visual
selection; following a pattern.

Note that most table operations expect an aligned table. So, if it's
not, you have to align it before juggling with rows & cols.

If there are some conflicts with your settings, you can restrict them
to a sublist. Example :

```vim
let g:organ_config.prefixless_plugs = ['organ-next', 'organ-backward', 'organ-forward']
```

You can also customize `g:organ_config.prefixless_modes` to create
prefixless maps only in the modes you specify.

## With prefix

These are the same as the prefixless maps, but preceded by a prefix to
avoid conflicts with other plugins. Examples with the default prefix
`<M-o>` :

- `<M-o><M-p>`       : previous heading
- `<M-o><M-n>`       : next heading
- `<M-o><M-b>`       : previous heading of same level
- `<M-o><M-f>`       : next heading of same level

Some of them are inspired by orgmode, with `<C-...>` replaced by `<M-...>`.

You can customize the prefix by setting `g:organ_config.prefix` to the
key you want.

The prefix bindings are always available, regardless of the
`g:organ_config.prefixless` value.

## Custom

Plugs can be mapped as usual :

```vim
nmap <c-n> <plug>(organ-next)
imap <c-n> <plug>(organ-next)
```

If you wish to enable it only for certain filetypes, you can use autocommands :

```vim
autocmd FileType org,markdown nmap <buffer> <c-n> <plug>(organ-next)
autocmd FileType org,markdown imap <buffer> <c-n> <plug>(organ-next)
```

This should have the same effect as writing :

```vim
nmap <buffer> <c-n> <plug>(organ-next)
imap <buffer> <c-n> <plug>(organ-next)
```

in `ftplugin/org/main.vim` and `ftplugin/markdown/main.vim`, somewhere
in your runtimepath.

You can find below a list of all available plugs.

## Available plugs

| Plugs                              | Heading or list item      | Table              |
|------------------------------------|---------------------------|--------------------|
| `<plug>`(organ-previous)           | previous heading or item  |                    |
| `<plug>`(organ-next)               | next heading or  item     |                    |
| `<plug>`(organ-backward)           | previous, same level      |                    |
| `<plug>`(organ-forward)            | next, same level          |                    |
| `<plug>`(organ-parent)             | parent heading or item    |                    |
| `<plug>`(organ-loose-child)        | loose child               |                    |
| `<plug>`(organ-strict-child)       | strict child              |                    |
| `<plug>`(organ-info)               | full heading path         |                    |
| `<plug>`(organ-goto-headline)      | go to headline, with comp |                    |
| `<plug>`(organ-cycle-fold)         | cycle current fold        |                    |
| `<plug>`(organ-cycle-all-folds)    | cycle all folds           |                    |
| `<plug>`(organ-select-subtree)     | select subtree            |                    |
| `<plug>`(organ-yank-subtree)       | yank subtree              |                    |
| `<plug>`(organ-delete-subtree)     | delete subtree            |                    |
| `<plug>`(organ-meta-return)        | new heading or item       | new row            |
| `<plug>`(organ-meta-left)          | promote                   | move column left   |
| `<plug>`(organ-meta-right)         | demote                    | move column right  |
| `<plug>`(organ-meta-up)            | move heading or item up   | move row up        |
| `<plug>`(organ-meta-down)          | move heading or item down | move row down      |
| `<plug>`(organ-shift-left)         | cycle item prefix left    |                    |
| `<plug>`(organ-shift-right)        | cycle item prefix right   |                    |
| `<plug>`(organ-shift-up)           | cycle todo keyword left   |                    |
| `<plug>`(organ-shift-down)         | cycle todo keyword right  |                    |
| `<plug>`(organ-meta-shift-left)    | promote subtree           | delete column      |
| `<plug>`(organ-meta-shift-right)   | demote subtree            | add new column     |
| `<plug>`(organ-meta-shift-up)      | cycle todo right          | delete row         |
| `<plug>`(organ-meta-shift-down)    | cycle todo left           | add new row        |
| `<plug>`(organ-tab)                |                           | go to next cell    |
| `<plug>`(organ-shift-tab)          |                           | go to prev cell    |
| `<plug>`(organ-move-subtree-to)    | move subtree, prompt comp |                    |
| `<plug>`(organ-align)              |                           | align table        |
| `<plug>`(organ-new-separator-line) |                           | add separator line |

| Plugs                            | Operation                         |
|----------------------------------|-----------------------------------|
| `<plug>`(organ-expand-template)  | expand template before cursor     |
| `<plug>`(organ-store-url)        | store url under or near cursor    |
| `<plug>`(organ-new-link)         | create new link                   |
| `<plug>`(organ-previous-link)    | go to previous link               |
| `<plug>`(organ-next-link)        | go to next link                   |
| `<plug>`(organ-goto-link-target) | go to link target                 |
| `<plug>`(organ-timestamp)        | add timestamp at cursor           |
| `<plug>`(organ-export)           | export document                   |
| `<plug>`(organ-alter-export)     | export document, alternative tool |

You can also list them with the command `:map <plug>(organ-`.

# Folding

Let's say you want to enable this plugin in text, python and vim files.
Just add :

```vim
autocmd filetype text,vim,python call organ#void#enable ()
```

to your init file.

If you want to enable it for all filetypes, just set the everywhere
setting :

```vim
let g:organ_config.everywhere = 1
```

## Markers

When editing a folded file, this plugin expect folds delimited by markers
with level included, like `{{{1`, `{{{2`, and so on. The closing markers
`}}}` are useless, and could in fact have undesired side effects.

## Indent

On files where `foldmethod=indent`, a limited support for basic navigation
is available.

# Meta-command

The `:Organ` meta-command gives you access to almost all the plugin
features :

```vim
:Organ subcommand
```

Examples :

```vim
:Organ store-url
:Organ export-with-pandoc
```

Completion is available for subcommands.

I suggest you map it to a convenient key. Example :

```vim
nnoremap <backspace> :Organ<space>
```

# Prompt completion

Completion is available for :

- meta-command subcommands
- full path of headlines (goto, move to)
- stored links and links protocols (adding new link)
- language of source code block (template expansion)

It is intended to work roughly as with the combo org-goto and helm in
Emacs. A space is interpreted as a logical and, a `|` as a logical or. In
fact, it works exactly as in [wheel](https://github.com/chimay/wheel). For
further details, please refer to the
[completion page](https://github.com/chimay/wheel/wiki/completion) on the wheel wiki.

# Autocommands

## Update table

Automatically update the current table alignment after each insertion :

```vim
augroup organ
  autocmd!
  autocmd InsertLeave *.org,*.md call organ#table#update ()
augroup END
```

## Conversion

If you copy some headings and links back and forth from org to markdown,
you can automatically convert the links at buffer write with the following
autocommands :

```vim
" ---- convert headings org <-> markdown
autocmd bufwritepre *.md call organ#tree#org2markdown ()
autocmd bufwritepre *.org call organ#tree#markdown2org ()
" ---- convert links org <-> markdown
autocmd bufwritepre *.md call organ#vine#org2markdown ()
autocmd bufwritepre *.org call organ#vine#markdown2org ()
```

# Related

- [vim-orgmode](https://github.com/jceb/vim-orgmode) (python)
- [vimOrganizer](https://github.com/hsitz/VimOrganizer) (abandoned)
- [nvim-orgmode](https://github.com/nvim-orgmode/orgmode) (lua, neovim only)

All of these plugins are for org files only.

# Misc

## Why this name

Besides being a short name for organizer, it's a pun for pipe-organ,
especially the big ones. With all these keyboards, pedalboards and stop
actions, an organist has to be organized, for sure.

## Why another orgmode clone for vim ?

First of all, it is not intended as a clone, more of a loose adaptation.

The current orgmode plugins for (neo)vim that I could find are for
org files only, and are either :

- abandoned and not adapted for my usage
- written in python (which is fine but still a dependency)
- written in lua, which means they only work with neovim

So, I started to write a lightweight org-mode plugin in plain vimscript,
and then I realized it wouldn't be too difficult to adapt it for markdown
and folded files. And here it is !

# Warning

Despite abundant testing, some bugs might remain, so be careful.
