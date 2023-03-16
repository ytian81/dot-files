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
set linebreak
set breakindent
let &showbreak='↳ '

autocmd FileType * set formatoptions-=o

set expandtab
set softtabstop=4
set shiftwidth=4

set ignorecase
set smartcase

set hlsearch

let g:LineNumberExcludeFileType = ['startify', 'fzf', 'fugitiveblame', 'tagbar', 'rnvimr']
augroup RelativeLineNumber
    autocmd!
    autocmd WinEnter,FocusGained,BufRead,InsertLeave,CmdlineLeave * if index(g:LineNumberExcludeFileType, &filetype) < 0 | set number
    autocmd WinEnter,FocusGained,BufRead,InsertLeave,CmdlineLeave * if index(g:LineNumberExcludeFileType, &filetype) < 0 | set relativenumber
    autocmd WinLeave,FocusLost,BufLeave,InsertEnter,CmdLineEnter * if index(g:LineNumberExcludeFileType, &filetype) < 0 | set norelativenumber
augroup end

if function#linux()
    set clipboard+=unnamedplus
elseif function#mac()
    set clipboard+=unnamed
endif

set virtualedit+=block

set report=0

set undodir=~/.vim/undodir
set undofile

set confirm
set autowrite

set splitright
set splitbelow

set showtabline=0

if function#global_statusline()
    set laststatus=3
else
    set laststatus=2
endif

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
