" Color setting
" echo "Loading color setting"
nnoremap <leader>kc :so $VIMRUNTIME/syntax/hitest.vim<cr>

autocmd BufRead,WinEnter    * set cursorline
autocmd WinLeave            * set nocursorline

set textwidth=100
autocmd FileType * set formatoptions+=t
set colorcolumn=+1

set pumheight=10

nmap <leader>sp :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>

augroup highlight_yank
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}
augroup END

" Show all highlight
function! ShowHighLight()
    redir @a
    silent verbose highlight
    redir END
    " edit temporary file
    vsp Auto\ Command
    " set filetype for syntax highlight
    setlocal filetype=vim
    " insert mappings
    % delete
    put a
    " delete empty lines
    global /^ *$/ delete
    " we don't want to save this temporary file
    set nomodified
endfunction
nnoremap <silent> <leader>kh :silent call ShowHighLight()<cr>

" set t_8f=[38;2;%lu;%lu;%lum
" set t_8b=[48;2;%lu;%lu;%lum
if !has('nvim')
    set term=screen-256color
else
    set termguicolors
endif

set background=dark

" https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f
function! MyHighlights() abort
    highlight DiffAdd     gui=none guifg=none    guibg=#15420e
    highlight DiffDelete  gui=none guifg=#4b0000 guibg=#4b0000
    highlight DiffChange  gui=none guifg=none    guibg=#516c5b
    highlight DiffText    gui=none guifg=none    guibg=#a7722c
endfunction
augroup ColorSchemeOverWrite
    autocmd!
    autocmd ColorScheme * call MyHighlights()
augroup END

let g:airline_theme='gruvbox'
let g:gruvbox_invert_selection=0
let g:gruvbox_italic=1
let g:gruvbox_sign_column='bg0'
colorscheme gruvbox
