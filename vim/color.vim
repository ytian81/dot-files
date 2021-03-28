" Color setting
" echo "Loading color setting"
nnoremap <leader>kc :so $VIMRUNTIME/syntax/hitest.vim<cr>

autocmd BufRead,WinEnter    * set cursorline
autocmd WinLeave            * set nocursorline

set textwidth=100
autocmd FileType * set formatoptions+=t
set colorcolumn=+1

set pumheight=10

nmap <leader>sp :call <SID>SynStack()<CR>
function! <SID>SynStack()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunc
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=700}
augroup END

" set t_8f=[38;2;%lu;%lu;%lum
" set t_8b=[48;2;%lu;%lu;%lum
" set termguicolors
if !has('nvim')
    set term=screen-256color
endif

set background=dark
set termguicolors

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
let g:gruvbox_invert_selection=0
let g:gruvbox_italic=1
let g:gruvbox_sign_column='bg0'
colorscheme gruvbox
