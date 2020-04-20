" Color setting
" echo "Loading color setting"

autocmd BufRead,WinEnter    * set cursorline
autocmd WinLeave            * set nocursorline
highlight CursorLine cterm=None ctermbg=238 ctermfg=None guibg=black guifg=green

set textwidth=100
autocmd FileType * set formatoptions+=t
set colorcolumn=+1
highlight ColorColumn ctermbg=238 guibg=#2c2d27

highlight ExtraWhitespace ctermbg=darkred guibg=darkred
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

highlight Pmenu ctermfg=blue ctermbg=238 guifg=#005f87 guibg=#EEE8D5
highlight PmenuSel ctermfg=green ctermbg=238 guifg=#AFD700 guibg=#106900
set pumheight=10

" set t_8f=[38;2;%lu;%lu;%lum
" set t_8b=[48;2;%lu;%lu;%lum
" set termguicolors
if !has('nvim')
    set term=screen-256color
endif
let g:gruvbox_invert_selection=0
colorscheme gruvbox

set background=dark
