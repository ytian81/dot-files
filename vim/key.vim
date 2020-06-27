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

" Show all kep mappings
function! ShowKeyMappings()
    redir @a
    silent verbose map
    redir END
    " Open a new window if the current one isn't empty
    if line("$") != 1 || getline(1) != ""
      vnew
    endif
    " edit temporary file
    edit Key\ Mapping
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
nnoremap <leader>kk :call ShowKeyMappings()<cr>
