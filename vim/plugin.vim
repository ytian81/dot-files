" Plugin configuration
" echo "Loading plugin configuration"

" Plug 'airblade/vim-gitgutter'
let g:gitgutter_override_sign_column_highlight=1

" Plug 'AndrewRadev/switch.vim'
let g:switch_mapping = "<c-x>"
let g:switch_reverse_mapping = "<c-a>"
let g:switch_custom_definitions = [
      \ ['&&', '||'],
      \ ['&', '|', '^'],
      \ ['&=', '|=', '^='],
      \ ['>>', '<<'],
      \ ['>>=', '<<='],
      \ ['==', '!='],
      \ ['>', '<', '>=', '<='],
      \ ['++', '--'],
      \ ['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'],
      \ ['EXPECT', 'ASSERT'],
      \ ['EQ', 'TRUE', 'FALSE', 'DOUBLE_EQ', 'FLOAT_EQ'],
      \ ]
let g:variable_style_switch_definitions = [
      \   {
      \     '\<[a-z0-9]\+_\k\+\>': {
      \       '_\(.\)': '\U\1'
      \     },
      \     '\<[a-z0-9]\+[A-Z]\k\+\>': {
      \       '\([A-Z]\)': '_\l\1'
      \     },
      \   }
      \ ]
nnoremap <silent> <Leader><c-x> :call switch#Switch({'definitions': g:variable_style_switch_definitions})<cr>
nnoremap <silent> <Leader><c-a> :call switch#Switch({'reverse': 1,'definitions': g:variable_style_switch_definitions})<cr>

" " bkadCamelCaseMotion
map <silent> W <Plug>CamelCaseMotion_w
map <silent> B <Plug>CamelCaseMotion_b
map <silent> E <Plug>CamelCaseMotion_e
map <silent> gE <Plug>CamelCaseMotion_ge
sunmap W
sunmap B
sunmap E
sunmap gE

"" ddrscott/vim-window
" Unimpaired mapping
nnoremap ]r :<C-U>call window#rotate(-1 * v:count1)<cr>
nnoremap [r :<C-U>call window#rotate(1 * v:count1)<cr>

" Improved window rotate to work with all layouts
nmap <C-w>r ]r
nmap <C-w><C-r> ]r

" Improve window exchange to work with all layouts
nnoremap <C-w>x :<C-U>call window#exchange(v:count)<cr>
nnoremap <C-w><c-x> :<C-U>call window#exchange(v:count)<cr>

" [g]lue windows together.
"    l = glue to right side
"    h = glue to left side
"    j = glue to bottom
"    k = glue to top
"
" `normal! 100zh` scrolls window contents into view since it gets messy when
" narrower window tries refocuses its cursor.
nnoremap <C-w>gl :<C-U>call window#join('rightbelow vsplit', v:count) <BAR>normal! 100zh<CR>
nnoremap <C-w>gh :<C-U>call window#join('leftabove vsplit', v:count)  <BAR>normal! 100zh<CR>
nnoremap <C-w>gj :<C-U>call window#join('belowright split', v:count)  <BAR>normal! 100zh<CR>
nnoremap <C-w>gk :<C-U>call window#join('aboveleft split', v:count)   <BAR>normal! 100zh<CR>

" Force a primary window layout.
" The capital HJKL forces the primary window to a specific direction.
command! -nargs=* LayoutH call window#layout('ball', 'H', <args>)
command! -nargs=* LayoutJ call window#layout('vertical ball', 'J', <args>)
command! -nargs=* LayoutK call window#layout('vertical ball', 'K', <args>)
command! -nargs=* LayoutL call window#layout('ball', 'L', <args>)

" Map the layout commands to something if that's your style.
nnoremap <C-w>gH :<C-U>LayoutH v:count<CR>
nnoremap <C-w>gJ :<C-U>LayoutJ v:count<CR>
nnoremap <C-w>gK :<C-U>LayoutK v:count<CR>
nnoremap <C-w>gL :<C-U>LayoutL v:count<CR>

" Improve window only, to split to new tab instead
nnoremap <C-w>o :call window#only()<cr>
nnoremap <C-w><c-o> :call window#only()<cr>

" derekwyatt/vim-fswitch
nmap <silent> <Leader>ss :FSHere<CR>
nmap <silent> <Leader>sh :FSSplitLeft<CR>
nmap <silent> <Leader>sl :FSSplitRight<CR>
nmap <silent> <Leader>sj :FSSplitBelow<CR>
nmap <silent> <Leader>sk :FSSplitAbove<CR>
let g:fsnonewfiles=1
autocmd! BufEnter *.cpp let b:fswitchdst = 'h,hpp'
            \ | let b:fswitchlocs = 'reg:|\(.*\)src|\1include/**/|,
            \                        reg:/src/include/,
            \                        reg:|src|include/**|,
            \                        ../include'
autocmd! BufEnter *.h let b:fswitchdst  = 'cpp,c'
            \ | let b:fswitchlocs =  'reg:|\(.*\)include\(.*\)|\1src/**|,
            \                         reg:/include/src/,
            \                         reg:/include.*/src/,
            \                         ../src'

" " easymotion/vim-easymotion
" nmap f <Plug>(easymotion-bd-f)
" nmap t <Plug>(easymotion-bd-t)
" nmap <Leader>w <Plug>(easymotion-bd-w)
" let g:EasyMotion_space_jump_first = 1

" editorconfig/editorconfig-vim
let g:EditorConfig_exclude_patterns=['fugitive://.*']

" junegunn/fzf.vim
" Similarly, we can apply it to fzf#vim#grep. To use ripgrep instead of ag:
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" Likewise, Files command with preview window
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

nnoremap <Leader>f :Files<CR>
nnoremap <Leader>g :Rg<Space>
nnoremap <Leader>j :BTags<CR>
nnoremap <Leader>a :Buffers<CR>

" junegunn/vim-easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" justinmk/vim-sneak
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

" Plug 'kamykn/spelunker.vim'
let g:enable_spelunker_vim = 1
let g:spelunker_target_min_char_len = 4
let g:spelunker_max_suggest_words = 15
let g:spelunker_max_hi_words_each_buf = 100
let g:spelunker_spell_bad_group = 'SpelunkerSpellBad'
let g:spelunker_complex_or_compound_word_group = 'SpelunkerComplexOrCompoundWord'
" highlight SpelunkerSpellBad cterm=underline ctermfg=247 gui=underline guifg=#9e9e9e
" highlight SpelunkerComplexOrCompoundWord cterm=underline ctermfg=NONE gui=underline guifg=NONE
let g:spelunker_disable_auto_group = 1
augroup spelunker
  autocmd!
  autocmd BufWinEnter,BufWritePost *.h,*.cpp call spelunker#check()
augroup END

" " ludovicchabant/vim-gutentags
" let $GTAGSLABEL = 'native-pygments'
" let $GTAGSCONF = fnamemodify(expand('<sfile>:p'), ':h').'/.gtags.conf'
" let g:gutentags_project_root = ['.root', '.svn', '.git', '.hg', '.project']
" let g:gutentags_ctags_tagfile = '.tags'
" let g:gutentags_modules = []
" if executable('ctags')
" 	let g:gutentags_modules += ['ctags']
" endif
" if executable('gtags-cscope') && executable('gtags')
"     let g:gutentags_modules += ['gtags_cscope']
" endif
" let s:vim_tags = expand('~/.cache/tags')
" if !isdirectory(s:vim_tags)
"    silent! call mkdir(s:vim_tags, 'p')
" endif
" let g:gutentags_cache_dir = s:vim_tags
" let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
" let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
" let g:gutentags_ctags_extra_args += ['--c-kinds=+px']
" let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']
" let g:gutentags_auto_add_gtags_cscope = 0
" let g:gutentags_define_advanced_commands = 1

" nathanaelkane/vim-indent-guides
let g:indent_guides_enable_on_vim_startup=1
let g:indent_guides_exclude_filetypes=['help', 'nerdtree']
let g:indent_guides_guide_size=1
let g:indent_guides_start_level=2

" octol/cpp-enhanced-highlight
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1
let g:cpp_experimental_template_highlight = 1
let g:cpp_concepts_highlight = 1

" majutsushi/tagbar
let g:tagbar_show_linenumbers=1
let g:tagbar_width=50
nnoremap <Leader>p :TagbarToggle<CR>

" " skywind3000/gutentags_plus
" let g:gutentags_plus_nomap = 1
" noremap <silent> <leader>as :GscopeFind s <C-R><C-W><cr>
" noremap <silent> <leader>ag :GscopeFind g <C-R><C-W><cr>
" noremap <silent> <leader>ac :GscopeFind c <C-R><C-W><cr>
" noremap <silent> <leader>at :GscopeFind t <C-R><C-W><cr>
" noremap <silent> <leader>ae :GscopeFind e <C-R><C-W><cr>
" noremap <silent> <leader>af :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
" noremap <silent> <leader>ai :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
" noremap <silent> <leader>ad :GscopeFind d <C-R><C-W><cr>
" noremap <silent> <leader>aa :GscopeFind a <C-R><C-W><cr>

" tpope/vim-fugitive
nnoremap <Leader>b :Gblame<CR>
nnoremap <Leader>o :Gbrowse<CR>
nnoremap <Leader>d :Gdiff<CR>

" tpope/vim-sensible
nnoremap <silent> <Leader>l :nohlsearch<C-R>=
            \ has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>

" rhysd/vim-clang-format
nnoremap <Leader>cf :ClangFormat<CR>
vnoremap <Leader>cf :ClangFormat<CR>

" scrooloose/nerdcommenter
let g:NERDSpaceDelims=1
let g:NERDDefaultAlign='left'
let g:NERDCommentEmptyLines=1

" scrooloose/nerdtree
let NERDTreeShowLineNumbers=1
map <Leader>e :edit %:h<CR>
map <Leader>q :NERDTreeToggle<CR>
autocmd BufEnter * if (winnr("$") == 1 &&
            \ exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Valloric/YouCompleteMe
let g:ycm_complete_in_comments=1
let g:ycm_confirm_extra_conf=0
let g:ycm_collect_identifiers_from_tags_files=0
let g:ycm_global_ycm_extra_conf=
            \ fnamemodify(expand('<sfile>:p'), ':h').
            \ '/.ycm_extra_conf.py'
let g:ycm_log_level='warning'
let g:ycm_seed_identifiers_with_syntax=1
let g:ycm_show_diagnostics_ui=0
let g:ycm_semantic_triggers =  {
            \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{3}'],
            \ 'cs,lua,javascript': ['re!\w{2}'],
            \ }
nnoremap <leader>z :YcmCompleter GoTo<CR>

" vim-airline/vim-airline
let g:airline_powerline_fonts=1
let g:airline#extensions#hunks#non_zero_only = 1
function! AirlineInit()
    " let g:airline_section_b = '%f'
    let g:airline_section_b = "%{fnamemodify(expand('%'),':.')}"
    let g:airline_section_c = airline#section#create(['hunks'])
    let g:airline_section_x = airline#section#create(['tagbar'])
endfunction
autocmd User AirlineAfterInit call AirlineInit()
" let g:airline#extensions#default#layout = [
"   \ [ 'a', 'b', 'c'],
"   \ [ 'x', 'y', 'z', 'error', 'warning' ]
"   \ ]
let g:airline_inactive_collapse=0
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 1
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#buffer_nr_show = 0
let g:airline#extensions#tabline#fnametruncate = 16
let g:airline#extensions#tabline#fnamecollapse = 2
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
let g:airline#extensions#tabline#buffer_min_count = 2
let g:airline_mode_map = {
      \ '__' : '-',
      \ 'n'  : 'N',
      \ 'i'  : 'I',
      \ 'R'  : 'R',
      \ 'c'  : 'C',
      \ 'v'  : 'V',
      \ 'V'  : 'V',
      \ '' : 'V',
      \ 's'  : 'S',
      \ 'S'  : 'S',
      \ '' : 'S',
      \ 't'  : 'T',
      \ }
let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap [1 <Plug>AirlineSelectTab1
nmap [2 <Plug>AirlineSelectTab2
nmap [3 <Plug>AirlineSelectTab3
nmap [4 <Plug>AirlineSelectTab4
nmap [5 <Plug>AirlineSelectTab5
nmap [6 <Plug>AirlineSelectTab6
nmap [7 <Plug>AirlineSelectTab7
nmap [8 <Plug>AirlineSelectTab8
nmap [9 <Plug>AirlineSelectTab9
nmap ]1 <Plug>AirlineSelectTab1
nmap ]2 <Plug>AirlineSelectTab2
nmap ]3 <Plug>AirlineSelectTab3
nmap ]4 <Plug>AirlineSelectTab4
nmap ]5 <Plug>AirlineSelectTab5
nmap ]6 <Plug>AirlineSelectTab6
nmap ]7 <Plug>AirlineSelectTab7
nmap ]8 <Plug>AirlineSelectTab8
nmap ]9 <Plug>AirlineSelectTab9
nmap <tab>j <Plug>AirlineSelectNextTab
nmap <tab>k <Plug>AirlineSelectPrevTab
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#ycm#enabled = 1
let g:airline#extensions#ycm#error_symbol = 'E:'
let g:airline#extensions#ycm#warning_symbol = 'W:'
let g:airline#extensions#branch#format = 1
let g:airline#extensions#default#section_truncate_width = {
  \ 'b': 80,
  \ 'c': 60,
  \ 'x': 45,
  \ 'y': 88,
  \ 'z': 45,
  \ 'warning': 99,
  \ 'error': 99,
  \ }

" Plug 'w0rp/ale'
let g:ale_c_parse_compile_commands=1
