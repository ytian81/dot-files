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
