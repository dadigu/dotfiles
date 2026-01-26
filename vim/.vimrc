" General defaults
syntax enable
colorscheme habamax
nnoremap q: <nop>
set nocompatible
set relativenumber
set nohlsearch
set smartcase
set ignorecase
set incsearch
set autoindent
set nowrap
set nobackup
set noswapfile
set autoread
set wildmenu
set encoding=utf8
set backspace=2
set scrolloff=4

let &t_SI = "\e[6 q"
let &t_EI = "\e[2 q"

" Status line enhancements
set laststatus=2
set statusline=%f%m%=%y\ %{strlen(&fenc)?&fenc:'none'}\ %l:%c\ %L\ %P
hi StatusLine cterm=NONE ctermbg=black ctermfg=brown
hi StatusLineNC cterm=NONE ctermbg=black ctermfg=darkgray

" Commenting blocks of code.
augroup commenting_blocks_of_code
  autocmd!
  autocmd FileType c,cpp,go,scala,ts,js   let b:comment_leader = '// '
  autocmd FileType sh,ruby,python   	  let b:comment_leader = '# '
  autocmd FileType conf,fstab       	  let b:comment_leader = '# '
  autocmd FileType lua              	  let b:comment_leader = '-- '
  autocmd FileType vim              	  let b:comment_leader = '" '
augroup END
noremap <silent> gc :<C-B>silent <C-E>s/^/<C-R>=escape(b:comment_leader,'\/')<CR>/<CR>:nohlsearch<CR>
noremap <silent> ,cu :<C-B>silent <C-E>s/^\V<C-R>=escape(b:comment_leader,'\/')<CR>//e<CR>:nohlsearch<CR>

" Language specific indentation.
filetype plugin indent on
autocmd Filetype make,go,c,cpp setlocal noexpandtab tabstop=4 shiftwidth=4
autocmd Filetype html,js,css setlocal expandtab tabstop=2 shiftwidth=2
