set nocp
call pathogen#infect()
call pathogen#helptags()
filetype plugin indent on
filetype plugin on

syntax enable
set nocompatible
set encoding=utf-8
set hidden
set magic
set autoread " reload file if it was changed outside of vim
set ttyfast
" set showbreak=↪
set title
set lazyredraw

set history=1000
set swapfile
set backup
set backupdir=~/.vim/_backup    " where to put backup files.
set directory=~/.vim/_temp      " where to put swap files.

set wildignore+=*.rbc,*.scssc,*.sassc
set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg
set wildignore+=.ds_store,.gitkeep

" text
set backspace=indent,eol,start "backspace through everything in indent mode
set nowrap
set expandtab
set shiftwidth=2
set tabstop=2
set ai " autoindent
set si " smartindent

" searching
set incsearch
set ignorecase
set hlsearch
set smartcase

" UI
set rnu
set ruler
set cursorline
set showmatch
set showcmd
set cmdheight=1
set showtabline=2
set colorcolumn=80
set scrolloff=5
set sidescrolloff=15

set list
set listchars=""
set listchars+=tab:▸\
set listchars+=extends:>
set listchars+=precedes:<

" don't show trailing spaces in in sert mode
augroup trailing
  au InsertEnter * :set listchars-=trail:·
  au InsertLeave * :set listchars+=trail:·
augroup END

set wildmenu                      " Enhanced command line completion.
set wildmode=list:longest         " Complete files like a shell.

if has("statusline") && !&cp
  set laststatus=2  " always show the status bar
  set statusline=%t\ (%{&ft})\ %{fugitive#statusline()}\ %m\ %=%-15(%3l,%02c%03V%)\ %4(%p%%%)
endif

let g:solarized_contrast='high'
let g:solarized_visibility='high'

if has("gui_running")
  "set guifont=Consolas\ for\ BBEdit:h12
  set guioptions=egmrt " turn off toolbar
  set vb " disable visual bell
  set antialias
  set guioptions-=r "don't show right scrollbar
  set showtabline=1
  set guifont=Monaco:h18
endif

set background=dark
colorscheme solarized

"Invisible character colors
" highlight NonText guifg=0 ctermfg=0 ctermbg=8 guibg=8
" highlight SpecialKey guifg=8 ctermfg=8 ctermbg=0 guibg=0

" FILETYPE SPECIFIC OPTIONS ----------------------------------------------

if has("autocmd")
  " In Makefiles, use real tabs, not tabs expanded to spaces
  au FileType make set noexpandtab

  au BufRead,BufNewFile *.{md,markdown,mdown,mkd,mkdn} setf markdown | call s:setup_wrapping()
  au BufRead,BufNewFile *.{txt} setf txt | call s:setup_wrapping()

  " Treat JSON files like JavaScript
  au BufNewFile,BufRead *.json set ft=javascript
endif

" PLUGIN OPTIONS ----------------------------------------------

" auto clean fugitive buffers
au BufReadPost fugitive://* set bufhidden=delete

" load matchit plugin
so $VIMRUNTIME/macros/matchit.vim

" indent-guides config
let g:indent_guides_enable_on_vim_startup=1
let g:indent_guides_start_level=2
let g:indent_guides_guide_size=2
let g:indent_guides_auto_colors=0
" solarized dark
hi IndentGuidesEven ctermbg=0
" solarized light
" hi IndentGuidesEven ctermbg=7

" use auto colors for indent guides in the gui
if has("gui_running")
  let g:indent_guides_auto_colors=1
  let g:indent_guides_guide_size=1
endif

" ctrlp options
let g:ctrlp_extensions = ["tag"]
let g:ctrlp_working_path_mode = 0
let g:ctrlp_match_window_reversed = 0
let g:ctrlp_max_height = 10
let g:ctrlp_use_caching = 0
let g:ctrlp_cache_dir = $HOME.'/.vim/_cache/ctrlp'
let g:ctrlp_mruf_relative = 1
let g:ctrlp_custom_ignore = 'tmp$\|\.git$\|\.hg$\|\.svn$'

" autoclose options
let g:AutoCloseExpandEnterOn = "" " make autoclose and endwise work together again
let g:AutoClosePairs_add = "|"

" FUNCTIONS ----------------------------------------------

function s:setup_wrapping()
  set wrap
  set wrapmargin=2
  set textwidth=72
endfunction

function! SwapNumberRelative()
  if &number == 0
    set number
  else
    set rnu
  endif
endfunction

" Remap the tab key to do autocompletion or indentation depending on the
" context (from http://overstimulate.com/articles/vim-ruby)
function! InsertTabWrapper()
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction

" taken and modified from
" https://github.com/garybernhardt/dotfiles/blob/master/.vimrc
function! ShowRoutes()
  :topleft 100 :split __Routes__
  " Make sure Vim doesn't write __Routes__ as a file
  :set buftype=nofile
  " Delete everything
  :normal 1GdG
  " Put routes output in buffer
  :0r! rake -s routes
  " Size window to number of lines (1 plus rake output length)
  :exec ":resize " . line("$")
  " Move cursor to bottom
  :normal 1GG
  " Delete empty trailing line
  :normal dd
endfunction

" MAPPINGS ----------------------------------------------
" esc esc to elimintate lag in terminal vim
inoremap jk <Esc><Esc>

set pastetoggle=<F2>

" remap j and k to move up and down DISPLAYED lines
" without having to press 2 keys
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

" Press Space to turn off highlighting and clear any message already displayed.
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" Switch between last two buffers
nnoremap <leader><leader> <c-^>

" rake routes
map <leader>rr :call ShowRoutes()<cr><F5>

" ctrlp mappings... f5 purges cache and gets new files
map <leader>f :CtrlP<cr><F5>
map <leader>F :CtrlPCurFile<cr><F5>

map <leader>et :CtrlPTag<cr><F5>

map <leader>ev :CtrlP app/views<cr><F5>
map <leader>ec :CtrlP app/controllers<cr><F5>
map <leader>em :CtrlP app/models<cr><F5>
map <leader>eh :CtrlP app/helpers<cr><F5>
map <leader>es :CtrlP spec<cr><F5>
map <leader>el :CtrlP lib<cr><F5>

" fugitive mappings
map <leader>gs :Gstatus<cr>
map <leader>gd :Git diff %<cr>
map <leader>gl :Git l<cr>

" tab completion
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

" swap between relative line numbers and regular line numbers
map <c-n> :call SwapNumberRelative()<cr> <space>

" don't use Ex mode, use Q for formatting
map Q gq

" Window splitting shortcuts
nnoremap <silent> vv <C-w>v
nnoremap <silent> ss <C-w>s

" Window movement shortcuts
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

" disable cursor keys in normal mode
map <Left>  :echo "BAD"<cr>
map <Right> :echo "BAD"<cr>
map <Up>    :echo "BAD"<cr>
map <Down>  :echo "BAD"<cr>

" run jshint on current file
nnoremap <leader>js :JSHint<cr>

" ack word under cursor
nnoremap <silent>K :Ack <cword><CR>

" COMMANDS ----------------------------------------------

command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>
command! InsertTime :normal a<c-r>=strftime('%F %H:%M:%S.0 %z')<cr>
command! Marked :normal :!open -a Marked.app '%:p'<cr> :redraw!<cr>
