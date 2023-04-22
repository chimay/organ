<!-- vim: set filetype=markdown: -->

<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
    * [What is it ?](#what-is-it-)
    * [Why another orgmode clone for vim ?](#why-another-orgmode-clone-for-vim-)
    * [Features](#features)
    * [Prerequisites](#prerequisites)
* [Configuration](#configuration)
* [Bindings](#bindings)
    * [Speed keys](#speed-keys)
    * [Prefixless](#prefixless)
    * [With prefix](#with-prefix)

<!-- vim-markdown-toc -->

# Introduction
## What is it ?

Organ is an Orgmode and Markdown environment plugin for Vim and Neovim.

It is primarily focused on editing orgmode and markdown files.

## Why another orgmode clone for vim ?

First of all, it is not intended as a clone, more of a loose adaptation.

The current orgmode plugins for (neo)vim are either :

- abandoned and not adapted for my usage
- writtent in lua, which means they only work for neovim

Since I use both editors, I wanted to write a lightweight plugin in
plain simple vimscript, with minimal dependancies (most of it doesn't
need anything).

## Features

- folding based on headings
- navigate in the headings hierarchy
  + next, previous : any level
  + forward, backward : same level as current one
  + parent heading, upper level
- modify headings hierarchy
  + promote, demote heading or list item

## Prerequisites

This plugin should mostly work out of the box.

TODO If you want to export your file with org-export functions, you just
need to have Emacs installed, and the plugin takes care of the rest.

# Configuration

```vim
if ! exists("g:organ_loaded")
  let g:organ_config = {}
  " enable speed keys on headlines first char
  let g:organ_config.speedkeys = 1
  " choose your mappings prefix
  let g:organ_config.prefix = '<m-c>'
  " enable prefixless maps
  let g:organ_config.prefixless = 1
  " enable only the prefixless maps you want
  " see the output of :map <plug>(organ- to see available plugs
  let g:organ_config.prefixless_plugs = ['organ-previous', 'organ-next']
endif
```

# Bindings
## Speed keys

If you set the `g:organ_config.speedkeys` variable to a greater-than-zero
value in your init file, the speed keys become available. They are
active only when the cursor is on the first char of a headline :

- `p`      : previous heading
- `n`      : next heading
- `b`      : backward heading of same level
- `f`      : forward heading of same level
- `-`      : parent heading
- `+`      : child heading, loosely speaking : first headline of level + 1, forward
- `w`      : where am I ? full headings path (chapter, section, subsection, ...)
- `*`      : cycle current fold visibility
- `#`      : cycle all folds visibility
- `@`      : select subtree
- `<`      : promote heading or list item
- `>`      : demote heading or list item
- `H`      : promote subtree
- `L`      : demote subtree

## Prefixless

If you set the `g:organ_config.prefixless` variable to a greater-than-zero
value in your init file, these bindings become available :

- `<M-p>`       : previous heading
- `<M-n>`       : next heading
- `<M-b>`       : previous heading of same level
- `<M-f>`       : next heading of same level
- `<M-u>`       : parent heading
- `<M-d>`       : child heading, loosely speaking : first headline of level + 1, forward
- `<M-S-d>`     : child heading, strictly speaking
- `<M-w>`       : where am I ? full headings path (chapter, section, subsection, ...)
- `<M-@>`       : select subtree
- `<M-left>`    : promote heading or list item
- `<M-right>`   : demote heading or list item
- `<M-S-left>`  : promote subtree
- `<M-S-right>` : demote subtree

If some of them conflicts with your settings, you can restrict them to
a sublist. Example :


```vim
let g:organ_config.prefixless_plugs = ['organ-previous', 'organ-next']
```

You can list all available plugs with the command `:map <plug>(organ-`.

Note that once you are on the first char of a headline, the speedkeys
become available. The plug `organ-previous` brings you precisely there.


## With prefix

The prefix bindings are always available, regardless of the
`g:organ_config.prefixless` value. They are mostly inspired by orgmode,
with `<C-...>` replaced by `<M-...>`. The default prefix is `<M-c>` :

- `<M-c><M-p>`       : previous heading
- `<M-c><M-n>`       : next heading
- `<M-c><M-b>`       : previous heading of same level
- `<M-c><M-f>`       : next heading of same level
- `<M-c><M-u>`       : parent heading
- `<M-c><M-d>`       : child heading, loosely speaking : first headline of level + 1, forward
- `<M-c><M-S-d>`     : child heading, strictly speaking
- `<M-c><M-w>`       : where am I ? full headings path (chapter, section, subsection, ...)
- `<M-c><M-@>`       : select subtree
- `<M-c><M-left>`    : promote heading or list item
- `<M-c><M-right>`   : demote heading or list item
- `<M-c><M-S-left>`  : promote subtree
- `<M-c><M-S-right>` : demote subtree

## Custom

You can trigger filetype autocommands to define your own maps :

```vim
autocmd FileType org nmap <buffer><silent> <c-p> <plug>(organ-previous)
autocmd FileType markdown nmap <buffer><silent> <c-p> <plug>(organ-previous)
```

This should have the same effect as writing :

```vim
nmap <buffer><silent> <c-p> <plug>(organ-previous)
nmap <buffer><silent> <c-p> <plug>(organ-previous)
```

in `ftplugin/org/main.vim` and `ftplugin/markdown/main.vim` somewhere
in your runtimepath.
