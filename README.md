<!-- vim: set filetype=markdown: -->

<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
    * [What is it ?](#what-is-it-)
    * [Features](#features)
    * [Prerequisites](#prerequisites)
* [Configuration](#configuration)
* [Bindings](#bindings)
    * [Prefixless](#prefixless)
    * [With prefix](#with-prefix)

<!-- vim-markdown-toc -->

WORK IN PROGRESS

# Introduction
## What is it ?

Organ is an Orgmode and Markdown environment plugin for Vim and Neovim.

It is primarily focused on editing org or markdown files.

## Features

- navigate in the headers hierarchy
  + next, previous : any level
  + forward, backward : same level as current one
  + parent header, upper level
- modify headers hierarchy
  + promote, demote header or list item

## Prerequisites

This plugin should mostly work out of the box.

If you want to export your file with org-export functions, you just need
to have Emacs installed, and the plugin takes care of the rest.

# Configuration

```vim
if ! exists("g:organ_loaded")
	let g:organ_config = {}
	let g:organ_config.prefix = '<m-c>'
	let g:organ_config.prefixless = 0
endif
```

# Bindings
## Prefixless

If you set the `g:organ_config.prefixless` variable to a greater-than-zero
value in your init file, these bindings become available :

- `<M-p>`     : previous heading
- `<M-n>`     : next heading
- `<M-b>`     : previous heading of same level
- `<M-f>`     : next heading of same level
- `<M-u>`     : parent heading
- `<M-left>`  : promote heading
- `<M-right>` : demote heading

## With prefix

These bindings are always available, regardless of the
`g:organ_config.prefixless` value :

- `<prefix><M-p>`     : previous heading
- `<prefix><M-n>`     : next heading
- `<prefix><M-b>`     : previous heading of same level
- `<prefix><M-f>`     : next heading of same level
- `<prefix><M-u>`     : parent heading
- `<prefix><M-left>`  : promote heading
- `<prefix><M-right>` : demote heading
