" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Enable syntax highlighting
syntax on

" Highlight cursor line underneath the cursor horizontally.
"set cursorline

" Highlight cursor line underneath the cursor vertically.
"set cursorcolumn

" Show line numbers
set number  

" Status bar
set laststatus=2

" Enable text wrap
set wrap

set wildmenu

" Set shift width to 4 spaces
set shiftwidth=4

" Set tab widht to 4 columns
set tabstop=4

" Use space characters instead of tabs
set expandtab

" Use highligting when doing a search
set hlsearch
