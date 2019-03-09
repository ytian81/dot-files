" General setting
" Note a few common accepted setting is loaded by 'tpope/vim-sensible'
" echo "Loading general setting"


set whichwrap+=<,>,[,]

set selection=exclusive

set mouse=a

set completeopt=menuone

set showmatch
set matchtime=1

set nofoldenable

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
autocmd WinEnter    * set relativenumber
autocmd WinLeave    * set norelativenumber

if function#linux()
    set clipboard=unnamedplus
elseif function#mac()
    set clipboard=unnamed
endif

set report=0

set confirm
set autowrite

" Activate matchit.vim
packadd! matchit

set encoding=utf-8
set termencoding=utf-8
set fileencodings=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936,latin1
