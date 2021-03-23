" Key mapping
" echo "Loading key mapping"

let mapleader="\<Space>"

" Visual select matching pair
nmap <silent> gm v%

" Filtered Up and Down
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

" Tab navigations
nnoremap ta :bufdo tab split<CR><CR>
nnoremap to :tabonly<CR>

" Source vimrc
nnoremap <expr> <leader>sv (expand('%:p') ==? expand($MYVIMRC) ? ":w \|" : ":")."source $MYVIMRC<CR>"

" Smooth scrall
map <C-U> <C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y><C-Y>
map <C-D> <C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E><C-E>

" Mark before searching
nnoremap / ms/

" Always jump to exact location
nnoremap ' `

" map z<cr> to zt
nnoremap z<cr> zt

" Show all kep mappings
function! ShowKeyMappings()
    redir @a
    silent verbose map
    redir END
    " edit temporary file
    vsp Key\ Mapping
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
nnoremap <silent> <leader>kk :silent call ShowKeyMappings()<cr>

" Show all autocmd
function! ShowAutoCmd()
    redir @a
    silent verbose autocmd
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
nnoremap <silent> <leader>ka :silent call ShowAutoCmd()<cr>

function! TurnOffGutter()
    setlocal  norelativenumber
    setlocal  nonumber
    setlocal  signcolumn=no
endfunction
nnoremap <silent> <leader>cg :call TurnOffGutter()<cr>
