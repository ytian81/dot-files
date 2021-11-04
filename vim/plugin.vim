" Plugin configuration
" echo "Loading plugin configuration"

" Plug 'airblade/vim-gitgutter'
let g:gitgutter_preview_win_floating = 0

" Plug antoinemadec/FixCursorHold.nvim
let g:cursorhold_updatetime = 200

" Plug 'AndrewRadev/switch.vim' with Plug 'tpope/vim-speeddating'
" speeddating key maps have to be disabled so that they don't override switch key maps
let g:speeddating_no_mappings=1
" speeddating fallback keys are still map to vim's vanilla <c-a> and <c-x>
nnoremap <Plug>SpeedDatingFallbackUp <C-A>
nnoremap <Plug>SpeedDatingFallbackDown <C-X>
nnoremap <c-a> :if !switch#Switch() <bar>
      \ call speeddating#increment(v:count1) <bar> endif<cr>
nnoremap <c-x> :if !switch#Switch({'reverse': 1}) <bar>
      \ call speeddating#increment(-v:count1) <bar> endif<cr>
let g:switch_custom_definitions = [
      \ ['&&', '||'],
      \ ['>>', '<<'],
      \ ['==', '!='],
      \ ['>', '<', '>=', '<='],
      \ ['++', '--'],
      \ ['DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'],
      \ ['EXPECT', 'ASSERT'],
      \ ['EQ', 'TRUE', 'FALSE', 'DOUBLE_EQ', 'FLOAT_EQ', 'THAT'],
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

" bfredl/nvim-miniyank
map p <Plug>(miniyank-autoput)
map P <Plug>(miniyank-autoPut)

" " bkadCamelCaseMotion
map <silent> W <Plug>CamelCaseMotion_w
map <silent> B <Plug>CamelCaseMotion_b
map <silent> E <Plug>CamelCaseMotion_e
map <silent> gE <Plug>CamelCaseMotion_ge
sunmap W
sunmap B
sunmap E
sunmap gE

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

" gelguy/wilder.nvim
call wilder#setup({'modes': [':']})
call wilder#set_option('pipeline', [
       \   wilder#branch(
       \     [
       \       wilder#check({_, x -> empty(x)}),
       \       wilder#history(15),
       \     ],
       \     wilder#cmdline_pipeline({
       \       'language': 'python',
       \       'fuzzy': 1,
       \     }),
       \     wilder#python_search_pipeline({
       \       'pattern': wilder#python_fuzzy_pattern(),
       \       'sorter': wilder#python_difflib_sorter(),
       \       'engine': 're',
       \     }),
       \   ),
       \ ])
call wilder#set_option('renderer', wilder#popupmenu_renderer({
      \ 'highlighter': wilder#basic_highlighter(),
      \ 'max_height': '15%',
      \ 'reverse': 1,
      \ 'highlights': {
      \   'accent': wilder#make_hl('WilderAccent', 'Pmenu', [{}, {}, {'foreground': '#fabd2f'}]),
      \ },
      \ }))

" editorconfig/editorconfig-vim
let g:EditorConfig_exclude_patterns=['fugitive://.*']

" jacquesbh/vim-showmarks
autocmd BufRead,WinEnter    * :DoShowMarks
" autocmd WinLeave            * :NoShowMarks

" junegunn/fzf.vim
function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

command! -bang -nargs=* BTags
  \ call fzf#vim#buffer_tags(<q-args>,
  \ fzf#vim#with_preview({'placeholder': '{2}:{3}', 'options': ['--with-nth', '1,4']}), <bang>0)

function! GetJumps()
  redir => cout
  silent jumps
  redir END
  return reverse(split(cout, "\n")[1:])
endfunction
function! GoToJump(jump)
    let jumpnumber = split(a:jump, '\s\+')[0]
    execute "normal " . jumpnumber . "\<c-o>"
endfunction
command! Jumps call fzf#run(fzf#wrap({
        \ 'source': GetJumps(),
        \ 'sink': function('GoToJump')}))

nnoremap <Leader>f :Files<CR>
nnoremap <Leader>g :Rg<Space>
nnoremap <Leader>* :execute 'Rg '.expand('<cword>')<CR>
nnoremap <Leader>j :BTags<CR>
nnoremap <Leader>a :Buffers<CR>
nnoremap <Leader>m :Marks<CR>
nnoremap <Leader>hh :History<CR>
nnoremap <Leader>hl :Commits<CR>
nnoremap <Leader>hb :BCommits<CR>
let g:fzf_preview_window = ['up:50%', 'ctrl-/']
let g:fzf_buffers_jump=1
augroup FzfLayoutResize
    autocmd!
    autocmd VimEnter,VimResized  * let g:fzf_layout = { 'window': {
                \ 'width': &columns > 240 ? 0.6 : 0.8,
                \ 'height': 0.6,
                \ 'highlight': 'Comment',
                \ 'rounded': v:false
                \ }}
augroup END
" let g:fzf_commits_log_options = '--color=always --format="%C(auto)%h %C(green)%C(italic)%an%C(auto) %s%d %C(magenta)%cr"'
" let g:fzf_colors =
"     \ { 'fg':      ['fg', 'Normal'],
"       \ 'bg':      ['bg', 'Normal'],
"       \ 'hl':      ['fg', 'Comment'],
"       \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
"       \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
"       \ 'hl+':     ['fg', 'Statement'],
"       \ 'info':    ['fg', 'PreProc'],
"       \ 'border':  ['fg', 'Ignore'],
"       \ 'prompt':  ['fg', 'Conditional'],
"       \ 'pointer': ['fg', 'Exception'],
"       \ 'marker':  ['fg', 'Keyword'],
"       \ 'spinner': ['fg', 'Label'],
"       \ 'header':  ['fg', 'Comment'] }

" junegunn/vim-easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" justinmk/vim-sneak
map f <Plug>Sneak_f
map F <Plug>Sneak_F
map t <Plug>Sneak_t
map T <Plug>Sneak_T

" Plug 'kamykn/spelunker.vim'
set nospell
let g:enable_spelunker_vim = 1
let g:spelunker_target_min_char_len = 4
let g:spelunker_max_suggest_words = 15
let g:spelunker_max_hi_words_each_buf = 100
let g:spelunker_check_type = 2
let g:spelunker_highlight_type = 2
let g:spelunker_disable_uri_checking = 1
let g:spelunker_disable_email_checking = 1
let g:spelunker_disable_account_name_checking = 1
let g:spelunker_disable_auto_group = 1
augroup spelunker
  autocmd!
  autocmd CursorHold *.h,*.cpp,*.py,*go,*md call spelunker#check_displayed_words()
augroup END
nmap [s <Plug>(spelunker-jump-prev)
nmap ]s <Plug>(spelunker-jump-next)
" let g:spelunker_spell_bad_group = 'SpelunkerSpellBad'
" let g:spelunker_complex_or_compound_word_group = 'SpelunkerComplexOrCompoundWord'
" highlight SpelunkerSpellBad cterm=underline ctermfg=247 gui=underline guifg=#9e9e9e
" highlight SpelunkerComplexOrCompoundWord cterm=underline ctermfg=NONE gui=underline guifg=NONE

" kevinhwang91/rnvimr
let g:rnvimr_enable_ex = 1
let g:rnvimr_enable_picker = 1
let g:rnvimr_draw_border = 1
let g:rnvimr_hide_gitignore = 1
let g:rnvimr_border_attr = {'fg': 245, 'bg': -1}
let g:rnvimr_enable_bw = 1
let g:rnvimr_ranger_cmd = 'ranger --cmd="set column_ratios 1,1"
            \ --cmd="set draw_borders both"'
nnoremap <silent> <leader>e :RnvimrToggle<CR>
let g:rnvimr_action = {
            \ '<C-t>': 'NvimEdit tabedit',
            \ '<C-x>': 'NvimEdit split',
            \ '<C-v>': 'NvimEdit vsplit',
            \ 'gw': 'JumpNvimCwd',
            \ 'yw': 'EmitRangerCwd'
            \ }
let g:rnvimr_presets = []

augroup RnvimrLayoutResize
    autocmd!
    autocmd VimEnter,VimResized  * let g:rnvimr_layout = { 'relative': 'editor',
            \ 'width': float2nr(round((&columns > 240 ? 0.6 : 0.8) * &columns)),
            \ 'height': float2nr(round(0.6 * &lines)),
            \ 'col': float2nr(round((&columns > 240 ? 0.2 : 0.1 ) * &columns)),
            \ 'row': float2nr(round(0.2 * &lines)),
            \ 'style': 'minimal' }
augroup END

" skywind3000/asyncrun.vim
" Opening quickfix window when AsyncRun starts
augroup asyncrun_quickfix
    autocmd User AsyncRunStart call asyncrun#quickfix_toggle(8, 1)
augroup END

" lakshayg/vim-bazel
let g:bazel_make_command = "AsyncRun -program=make"

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

" sheerun/vim-polyglot
let g:cpp_member_highlight = 1

" skywind3000/asyncrun.vim
noremap <leader>rm :AsyncRun make<cr>

" terryma/vim-multiple-cursors
highlight link multiple_cursors_visual Visual
augroup MultipleCursorsSelectionFix
    autocmd User MultipleCursorsPre  if &selection ==# 'exclusive' | let g:multi_cursor_save_selection = &selection | set selection=inclusive | endif
    autocmd User MultipleCursorsPost if exists('g:multi_cursor_save_selection') | let &selection = g:multi_cursor_save_selection | unlet g:multi_cursor_save_selection | endif
augroup END

" mhinz/vim-startify
let g:startify_change_to_dir = 0
let g:startify_change_to_vcs_root = 1

" neoclide/coc.nvim
let g:coc_global_extensions = ['coc-clangd', 'coc-git', 'coc-highlight', 'coc-marketplace', 'coc-yaml']
" disable coc default semantic highlighting
let g:coc_default_semantic_highlight_groups=0
set hidden
set shortmess+=c
" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif
" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gc <Plug>(coc-references)
" Use K to show documentation in preview window.
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction
nnoremap <silent> K :call <SID>show_documentation()<CR>
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)
" Formatting selected code.
xmap <leader>cf  <Plug>(coc-format-selected) <CR>
nmap <leader>cf  <Plug>(coc-format) <CR>
" Introduce function text object
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)
" Use <C-j> for both expand and jump (make expand higher priority.
imap <C-j> <Plug>(coc-snippets-expand-jump)
nnoremap <leader>he :CocCommand git.showCommit<CR>

" PeterRincker/vim-searchlight
highlight link Searchlight Incsearch

" majutsushi/tagbar
let g:tagbar_show_linenumbers=1
let g:tagbar_width=50
nnoremap <Leader>p :TagbarToggle<CR>
highlight link TagbarSignature Comment
let g:tagbar_type_yaml = {
    \ 'ctagstype' : 'yaml',
    \ 'kinds' : [
        \ 'a:anchors',
        \ 's:section',
        \ 'e:entry'
    \ ],
  \ 'sro' : '.',
    \ 'scope2kind': {
      \ 'section': 's',
      \ 'entry': 'e'
    \ },
    \ 'kind2scope': {
      \ 's': 'section',
      \ 'e': 'entry'
    \ },
    \ 'sort' : 0
    \ }

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
nnoremap <Leader>hg :Git<space>
nnoremap <Leader>hc :Git commit<CR>
nnoremap <Leader>ha :Git add %<CR>
nnoremap <Leader>b  :Git blame<CR>
nnoremap <Leader>o  :.GBrowse<CR>
nnoremap <Leader>d  :Gdiffsplit<CR>
augroup GitHistoricalBufferFold
    autocmd!
    autocmd FileType git setlocal foldmethod=syntax
augroup end

" tpope/vim-sensible
nnoremap <silent> <Leader>l <Esc>:nohlsearch<CR><Esc>

" rhysd/conflict-marker.vim
" disable the default highlight group
let g:conflict_marker_highlight_group = ''
" Include text after begin and end markers
let g:conflict_marker_begin = '^<<<<<<< .*$'
let g:conflict_marker_end   = '^>>>>>>> .*$'

" scrooloose/nerdcommenter
let g:NERDSpaceDelims=1
let g:NERDDefaultAlign='left'
let g:NERDCommentEmptyLines=1

" vim-airline/vim-airline
let g:airline_inactive_collapse=0
let g:airline_powerline_fonts=1
let g:airline_skip_empty_sections = 1
let g:airline_extensions = ['coc', 'fugitiveline', 'hunks', 'quickfix', 'wordcount']
let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#tagbar#enabled = 0
let g:airline#extensions#fzf#enabled = 0
" Disable search count because of native vim support. Check :help shortmess
let g:airline#extensions#searchcount#enabled = 0
let g:airline#extensions#hunks#enabled = 1
let g:airline#extensions#hunks#non_zero_only = 1
function! AirlineInit()
  let g:airline_section_b = airline#section#create(['hunks', 'file'])
  let g:airline_section_c = airline#section#create(['%<', 'readonly', 'coc_status'])
endfunction
autocmd User AirlineAfterInit call AirlineInit()
let g:airline_stl_path_style = 'short'
let g:airline#extensions#default#section_truncate_width = {
  \ 'b': 0,
  \ 'c': 0,
  \ 'x': 79,
  \ 'y': 120,
  \ 'z': 79,
  \ 'warning': 45,
  \ 'error': 45,
  \ }

" Xuyuanp/scrollbar.nvim
augroup ScrollbarInit
  autocmd!
  autocmd WinEnter,FocusGained,CursorMoved,VimResized * silent! lua require('scrollbar').show()
  autocmd BufLeave,WinLeave,FocusLost                 * silent! lua require('scrollbar').clear()
augroup end
let g:scrollbar_highlight = {
    \ 'head': 'LineNr',
    \ 'body': 'LineNr',
    \ 'tail': 'LineNr',
    \ }
let g:scrollbar_min_size = 5
let g:scrollbar_max_size = 5

" Yggdroot/indentLine
let g:indentLine_fileTypeExclude=['help', 'fzf', 'startify']
