<!-- vim: set filetype=markdown: -->

<!-- vim-markdown-toc GFM -->

* [Introduction](#introduction)
    * [What is it ?](#what-is-it-)
    * [Why another orgmode clone for vim ?](#why-another-orgmode-clone-for-vim-)
    * [Features](#features)
    * [Dependancies](#dependancies)
* [Configuration](#configuration)
* [Bindings](#bindings)
    * [Speed keys](#speed-keys)
    * [Prefixless](#prefixless)
    * [With prefix](#with-prefix)
    * [Custom](#custom)
* [Meta-command](#meta-command)

<!-- vim-markdown-toc -->

# Introduction
## What is it ?

Organ is an Orgmode and Markdown environment plugin for Vim and Neovim.

It is primarily focused on editing orgmode and markdown files with ease
and agility.

## Why another orgmode clone for vim ?

First of all, it is not intended as a clone, more of a loose adaptation.

The current orgmode plugins for (neo)vim are either :

- abandoned and not adapted for my usage
- writtent in lua, which means they only work for neovim

Since I use both editors, I wanted to write a lightweight plugin in
plain simple vimscript, with minimal dependancies (most of it doesn't
need anything to work).

## Features

- folding based on headings
- navigate in the headings hierarchy
  + next, previous : any level
  + forward, backward : same level as current one
  + parent heading, upper level
  + child heading, lower level : loosely or strictly speaking
  + go to another headline with prompt completion of full path
- modify headings hierarchy
  + promote, demote heading or list item
  + select, yank, delete subtree
  + move subtree up or down

## Dependancies

This plugin should work out of the box, apart from a few advanced
features.

If you want to export your file to another format, you just need to have
pandoc installed, and the plugin takes care of the rest.  For org files,
it can also be done with emacs installed.

If you want to navigate to an headline in another org or markdown file,
you can install [wheel](https://github.com/chimay/wheel) : it has a
prompt completion function (launched with `<plug>(wheel-prompt-outline)`)
that looks for headlines in all orgmode or markdown files of a group.

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
  " prefixless maps in these modes
  let g:organ_config.prefixless_modes = ['normal', 'insert']
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
- `-`      : upper, parent heading
- `~`      : lower, child heading, loosely speaking : first headline of level + 1, forward
- `+`      : lower, child heading, strictly speaking
- `w`      : where am I ? full headings path (part, chapter, section, subsection, ...)
- `h`      : go to headline, with prompt completion of full headings path
- `*`      : cycle current fold visibility
- `#`      : cycle all folds visibility
- `@`      : select subtree
- `yy`     : yank subtree
- `dd`     : delete subtree
- `<`      : promote heading
- `>`      : demote heading
- `H`      : promote subtree
- `L`      : demote subtree
- `U`      : move subtree up
- `D`      : move subtree down
- `e`      : export with pandoc
- `E`      : export with emacs

The prompt completion of headlines is intended to wark roughly as with
the combo org-goto and helm in Emacs. A space is interpreted as
a logical and, a `|` as a logical or. In fact, it works exactly as in
[wheel](https://github.com/chimay/wheel). For further details, please
refer to the
[completion page](https://github.com/chimay/wheel/wiki/completion)
on the wheel wiki.

## Prefixless

If you set the `g:organ_config.prefixless` variable to a greater-than-zero
value in your init file, these bindings become available :

- `<M-p>`       : previous heading
- `<M-n>`       : next heading
- `<M-b>`       : previous heading of same level
- `<M-f>`       : next heading of same level
- `<M-u>`       : upper, parent heading
- `<M-l>`       : lower, child heading, loosely speaking : first headline of level + 1, forward
- `<M-S-l>`     : lower, child heading, strictly speaking
- `<M-h>`       : go to headline, with prompt completion of full headings path
- `<M-w>`       : where am I ? full headings path (chapter, section, subsection, ...)
- `<M-@>`       : select subtree
- `<M-y>`       : yank subtree
- `<M-d>`       : delete subtree
- `<M-left>`    : promote heading or list item
- `<M-right>`   : demote heading or list item
- `<M-S-left>`  : promote subtree
- `<M-S-right>` : demote subtree
- `<M-up>`      : move subtree up
- `<M-down>`    : move subtree down
- `<M-e>`       : export with pandoc
- `<M-E>`       : export with emacs

You can customize `g:organ_config.prefixless_modes` to create these maps
only in the modes you specify.

If there are some conflicts with your settings, you can restrict them
to a sublist. Example :


```vim
let g:organ_config.prefixless_plugs = ['organ-previous', 'organ-next']
```

You can list all available plugs with the command `:map <plug>(organ-`.

Note that once you are on the first char of a headline, the speedkeys
become available. The plug `organ-previous` brings you precisely there,
and is therefore one of the most important maps.

## With prefix

These are the same as the prefixless maps, but preceded by a prefix to
avoid conflicts with other plugins. Examples with the default prefix
`<M-c>` :

- `<M-c><M-p>`       : previous heading
- `<M-c><M-n>`       : next heading
- `<M-c><M-b>`       : previous heading of same level
- `<M-c><M-f>`       : next heading of same level

They are mostly inspired by orgmode, with `<C-...>` replaced by `<M-...>`.

You can customize the prefix by setting `g:organ_config.prefix` to the
key you want.

The prefix bindings are always available, regardless of the
`g:organ_config.prefixless` value.

## Custom

You can trigger filetype autocommands to define your own maps :

```vim
autocmd FileType org,markdown nmap <buffer> <c-p> <plug>(organ-previous)
```

This should have the same effect as writing :

```vim
nmap <buffer> <c-p> <plug>(organ-previous)
```

in `ftplugin/org/main.vim` and `ftplugin/markdown/main.vim`, somewhere
in your runtimepath.

# Meta-command

The `:Organ` meta-command gives you access to almost all the plugin
features :

```vim
:Organ subcommand
```

Completion is available for subcommands.

I suggest you map it to a convenient key. Example :

```vim
autocmd FileType org,markdown nnoremap <buffer> <m-o> :Organ<space>
```
