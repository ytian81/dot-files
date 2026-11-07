" This vimrc uses vim-plug to manages all plugins.
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC | PlugInstall
endif

" Load local plugins in `vim` directory. Pass 1 after plugin name to debug
let s:vimrc_dir=fnamemodify(resolve(expand('<sfile>:p')), ':h')
function! s:IncludeLocalPlugin(...)
    let l:name=a:1

    if a:0>1
        let l:debug=a:2
    else
        let l:debug=0
    endif

    let l:plugin=s:vimrc_dir.'/vim/'.l:name

    if l:debug
        echo "Try to find ".l:plugin
    endif

    if filereadable(l:plugin)
        exec "source ".l:plugin
    else
        if l:debug
            echo "Cannot find ".l:plugin
        endif
    endif
endfunction

" Plugins will be downloaded under the specified directory.
call s:IncludeLocalPlugin('function.vim')
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
Plug 'ytian81/flexfloat.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'folke/noice.nvim'
Plug 'rcarriga/nvim-notify'
Plug 'airblade/vim-gitgutter'
Plug 'AndrewRadev/switch.vim'
Plug 'antoinemadec/coc-fzf'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'bfredl/nvim-miniyank'
Plug 'bkad/CamelCaseMotion'
Plug 'christoomey/vim-tmux-navigator'
Plug 'derekwyatt/vim-fswitch', { 'on': ['FSHere', 'FSSplitLeft', 'FSSplitRight', 'FSSplitBelow', 'FSSplitAbove'] }
Plug 'dstein64/vim-win'
if !has('nvim')
    Plug 'editorconfig/editorconfig-vim'
endif
Plug 'honza/vim-snippets'
Plug 'jacquesbh/vim-showmarks'
Plug 'LunarWatcher/auto-pairs'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --no-zsh' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align', { 'on': ['<Plug>(EasyAlign)', 'EasyAlign'] }
Plug 'junegunn/vim-peekaboo'
Plug 'justinmk/vim-sneak'
Plug 'kevinhwang91/nvim-bqf'
Plug 'ytian81/vim-bazel', { 'on': 'Bazel' }
Plug 'lambdalisue/glyph-palette.vim'
Plug 'lambdalisue/nerdfont.vim'
Plug 'majutsushi/tagbar', { 'on': 'TagbarToggle' }
Plug 'markonm/traces.vim'
Plug 'mhinz/vim-signify'
Plug 'gruvbox-community/gruvbox'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'PeterRincker/vim-searchlight'
Plug 'psliwka/vim-smoothie'
Plug 'rhysd/conflict-marker.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'nvim-treesitter/nvim-treesitter', { 'branch': 'main', 'do': ':TSUpdate' }
Plug 'nvim-treesitter/nvim-treesitter-textobjects', { 'branch': 'main' }
Plug 'nvim-treesitter/nvim-treesitter-context'
Plug 'skywind3000/asyncrun.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rhubarb'
if !has('nvim')
    Plug 'tpope/vim-sensible'
endif
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tweekmonster/startuptime.vim', { 'on': 'StartupTime' }
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/ReplaceWithRegister'
Plug 'vim-scripts/star-search'
Plug 'Xuyuanp/scrollbar.nvim'
Plug 'Yggdroot/indentLine'
"Plug 'github/copilot.vim'
Plug 'noisesfromspace/touchup.nvim'
" List ends here. Plugins become visible to Vim after this call.
call plug#end()

" Include local plugins.
call s:IncludeLocalPlugin('general.vim')
call s:IncludeLocalPlugin('key.vim')
call s:IncludeLocalPlugin('plugin.vim')
call s:IncludeLocalPlugin('color.vim')
call s:IncludeLocalPlugin('local.vim')
