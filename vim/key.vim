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
nnoremap <expr> <leader>R (expand('%:p') ==? expand($MYVIMRC) ? ":w \|" : ":")."source $MYVIMRC<CR>"

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
    setlocal  conceallevel=0
    lua require('scrollbar').clear()
endfunction
nnoremap <silent> <leader>cg :call TurnOffGutter()<cr>

" disable Ex command-line window
map q: :q
map q/ /q
map q? ?q

" update both plugins and coc extensions
nnoremap <silent> <leader>U :PlugUpdate \| CocUpdate<cr>

" copy file name to clipboard
function! YankInput(input)
    let @+ = a:input
    echom 'Copied "' . a:input . '" to clipboard'
endfunction
nnoremap <silent> y; :call YankInput(expand('%:t'))<cr>
nnoremap <silent> y' :call YankInput(expand('%:.'))<cr>

function! GetVisualRange()
    " The marks '< and '> are set to the start and end of the last visual selection
    let l1 = line("'<")
    let l2 = line("'>")

    " If they are the same, just return one line number, otherwise return the range
    return l1 == l2 ? l1 : l1 . '-' . l2
endfunction

" Copy range of line numbers (e.g. 10-15)
xnoremap <silent> y; :<c-u>call YankInput(expand('%:t') . ':' . GetVisualRange())<cr>
" Copy relative path with line range (e.g. path/to/file.txt:10-15)
xnoremap <silent> y' :<c-u>call YankInput(expand('%:.') . ':' . GetVisualRange())<cr>
