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
Plug 'airblade/vim-gitgutter'
Plug 'AndrewRadev/switch.vim'
Plug 'antoinemadec/coc-fzf'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'bfredl/nvim-miniyank'
Plug 'bkad/CamelCaseMotion'
Plug 'chrisbra/Colorizer', {'on': 'ColorToggle'}
Plug 'christoomey/vim-tmux-navigator'
Plug 'derekwyatt/vim-fswitch'
Plug 'dstein64/vim-win'
" Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
Plug 'gelguy/wilder.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'honza/vim-snippets'
Plug 'jacquesbh/vim-showmarks'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --no-zsh' }
Plug 'junegunn/fzf.vim', { 'do': function('InstallRg') }
Plug 'junegunn/goyo.vim'
Plug 'junegunn/vim-easy-align'
Plug 'junegunn/vim-peekaboo'
Plug 'justinmk/vim-sneak'
Plug 'kamykn/spelunker.vim'
Plug 'kevinhwang91/rnvimr'
Plug 'skywind3000/asyncrun.vim'
Plug 'lakshayg/vim-bazel'
" Plug 'ludovicchabant/vim-gutentags', { 'do': function('InstallGTags')}
Plug 'machakann/vim-swap'
Plug 'majutsushi/tagbar'
Plug 'markonm/traces.vim'
Plug 'mhinz/vim-startify'
Plug 'gruvbox-community/gruvbox'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'PeterRincker/vim-searchlight'
" Plug 'skywind3000/gutentags_plus'
Plug 'rhysd/conflict-marker.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'sheerun/vim-polyglot'
Plug 'skywind3000/asyncrun.vim'
Plug 'terryma/vim-expand-region'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-rhubarb' ", { 'on': 'GBrowse' }
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'tweekmonster/startuptime.vim', { 'on': 'StartupTime' }
Plug 'vim-airline/vim-airline', {'do': function('InstallPowerlineFont')}
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-scripts/ReplaceWithRegister'
Plug 'vim-scripts/star-search'
Plug 'wellle/targets.vim'
Plug 'Xuyuanp/scrollbar.nvim'
Plug 'Yggdroot/indentLine'
" List ends here. Plugins become visible to Vim after this call.
call plug#end()

" Include local plugins.
call s:IncludeLocalPlugin('general.vim')
call s:IncludeLocalPlugin('key.vim')
call s:IncludeLocalPlugin('plugin.vim')
call s:IncludeLocalPlugin('color.vim')
call s:IncludeLocalPlugin('local.vim')
