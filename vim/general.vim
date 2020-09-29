" General setting
" Note a few common accepted setting is loaded by 'tpope/vim-sensible'
" echo "Loading general setting"


set whichwrap+=<,>,[,]

set selection=exclusive

set mouse=a
if !has('nvim')
    set ttymouse=sgr
endif

set completeopt=menuone

set showmatch
set matchtime=1

set updatetime=200

set nofoldenable
set foldmethod=indent
set foldlevelstart=99
set foldopen&
set foldclose&

set signcolumn=yes

set nowrap

autocmd FileType * set formatoptions-=o

set expandtab
set softtabstop=4
set shiftwidth=4

set ignorecase
set smartcase

set hlsearch

set number
autocmd BufRead,WinEnter    * set relativenumber
autocmd WinLeave            * set norelativenumber

if function#linux()
    set clipboard+=unnamedplus
elseif function#mac()
    set clipboard+=unnamed
endif

set report=0

set confirm
set autowrite

set splitright
set splitbelow

" Activate matchit.vim
packadd! matchit

" Restore cursor position when openning file
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   execute "normal! g`\"" |
    \ endif

set encoding=utf-8
set termencoding=utf-8
set fileencodings=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936,latin1
