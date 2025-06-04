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

set diffopt+=linematch:50
set diffopt+=iwhite

set splitkeep=screen

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

set expandtab
set softtabstop=4
set shiftwidth=4

set ignorecase
set smartcase

set hlsearch

let g:LineNumberExcludeFileType = ['startify', 'fzf', 'fugitiveblame', 'tagbar', 'Fm']
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
set fileencodings=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936,latin1

function! general#clang_format()
    let l:clang_format_binary = get(g:, 'clang_format_binary', 'clang-format')
    let l:cmd = '!' . l:clang_format_binary . ' -i % '
    if v:count
        let l:cmd .= '--lines=' . v:lnum . ':' . (v:lnum+v:count-1)
    endif
    silent! execute l:cmd
endfunction

augroup CppFormat
    autocmd!
    " " Prefer to set formatexpr over formatprg because the latter doesn't accept range
    autocmd FileType cpp setlocal formatexpr=general#clang_format()
    " " disable textwidth because clang-format has better C++ context for wrapping text
    autocmd FileType cpp setlocal textwidth=0
    autocmd FileType cpp setlocal formatoptions-=o
    " autocmd FileType cpp setlocal formatprg=clang-format
augroup end

nnoremap <silent> gQ :call general#clang_format()<CR>

" Define a function to create the temporary file with an optional extension
" Using '...' makes the function variadic, so it can be called with 0 or more arguments.
function! VtmpCreateFile(...)
    let l:timestamp = strftime("%Y%m%d%H%M%S")
    let l:filepath = "/tmp/temp_" . l:timestamp
    let l:extension_arg = ""

    " Check if any argument was passed (a:0 holds the number of arguments)
    if a:0 > 0
        " If arguments exist, the first one is a:1
        let l:extension_arg = a:1
    endif

    " If an extension argument was provided and is not empty, append it to the file path
    if !empty(l:extension_arg)
        let l:filepath = l:filepath . "." . l:extension_arg
    endif

    " Split the window and open the new temporary file
    execute "vsplit" l:filepath
endfunction

" Define the Vtmp command to accept 0 or 1 argument
" <f-args> correctly passes the raw arguments to the function,
" which the variadic function now handles gracefully.
command! -nargs=? Vtmp call VtmpCreateFile(<f-args>)

" Existing normal mode mapping to open a temp file without an extension
nnoremap <silent> <space>v :Vtmp<CR>
