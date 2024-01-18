set nocompatible            " disable compatibility to old-time vi
set showmatch               " show matching
set ignorecase              " case insensitive
set mouse=v                 " middle-click paste with
set hlsearch                " highlight search
set incsearch               " incremental search
set tabstop=4               " number of columns occupied by a tab
set softtabstop=4           " see multiple spaces as tabstops so <BS> does the right thing
set expandtab               " converts tabs to white space
set shiftwidth=4            " width for autoindents
set autoindent              " indent a new line the same amount as the line just typed
set number                  " add line numbers
set wildmode=longest,list   " get bash-like tab completions
set cc=100                  " set an 80 column border for good coding style
filetype plugin indent on   "allow auto-indenting depending on file type
syntax on                   " syntax highlighting
set mouse=a                 " enable mouse click
set clipboard=unnamedplus   " using system clipboard
filetype plugin on
set cursorline              " highlight current cursorline
set ttyfast                 " Speed up scrolling in Vim
" set spell                   " enable spell check (may need to download language package)
set backupdir=~/.cache/vim " Directory to store backup files.
set encoding=UTF-8
filetype plugin indent on
" On pressing tab, insert 2 spaces
set expandtab
" Show existing tabl with 2 space width
set tabstop=2
set softtabstop=2
" When indent with '>' use 2 spaces width
set shiftwidth=2


" Keybindings"
:inoremap jj <Esc>
let mapleader = ","
nmap <A-1> :NERDTreeToggle<CR>
nnoremap <leader>u :UndotreeToggle<CR>

" copies filepath to clipboard by pressing yf
:nnoremap <silent> yf :let @+=expand('%:p')<CR>
" copies pwd to clipboard: command yd
:nnoremap <silent> yd :let @+=expand('%:p:h')<CR>

function! ToggleVerbose()
    if !&verbose
        set verbosefile=~/.config/nvim/verbose.log
        set verbose=15
    else
        set verbose=0
        set verbosefile=
    endif
endfunction

call ToggleVerbose()

