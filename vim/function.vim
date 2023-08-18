" Function setting
" echo "Loading Function setting"

let s:function=fnamemodify(expand('<sfile>:p'), ':h')

" Platform
silent function! function#mac()
    return has('macunix')
endfunction
silent function! function#linux()
    return has('unix') && !has('macunix') && !has('win32unix')
endfunction
silent function! function#windows()
    return  (has('win32') || has('win64'))
endfunction

" global status line
silent function! function#global_statusline()
    return has('nvim-0.7')
endfunction

silent function! function#is_in_ssh()
    return $SSH_CONNECTION !=""
endfunction

" Install GTags and Universal Ctags
function! InstallGTags(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status == 'installed' || a:info.force
      if function#mac()
          !brew install global &&
           \ pip install pygments &&
           \ brew install --HEAD universal-ctags/universal-ctags/universal-ctags
      elseif function#linux()
          exec "!bash ".s:function."/install/installGtags.sh"
      endif
  endif
endfunction

" Install Rg
function! InstallRg(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status == 'installed' || a:info.force
      if function#mac()
          !brew install ripgrep
      elseif function#linux()
          exec "!bash ".s:function."/install/installRg.sh"
      endif
  endif
endfunction

" Install Powerline Font
function! InstallPowerlineFont(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status == 'installed' || a:info.force
      exec "!bash ".s:function."/install/installPowerlineFont.sh"
  endif
endfunction

" Parse GTest filter
" Heavily inspired by https://github.com/alepez/vim-gtest
function function#get_gtest_filter()
    let l:lnum = line('.')
    if 0 != match(getline(l:lnum), "^TEST")
        let l:lnum = search('^TEST', 'bnW')
        if 0 == l:lnum
            return ''
        endif
    endif
    " always get the next line in case test name is too long
    " if next line is not a test name, it will be ignored
    let l:line = join(getline(l:lnum, l:lnum+1))
    let l:ms = matchlist(l:line, '^\(TEST\S*\)\s*(\s*\(\S\{-1,}\),\s*\(\S\{-1,}\)\s*).*$')
    let l:ret = l:ms[2] . '.' . l:ms[3]
    if 0 == match(l:line, '^TEST_P')
        let l:ret = '*' . l:ret . '*'
    endif
    let l:ret = ' --test_arg=--gtest_filter="' . l:ret . '"'
    return l:ret
endfunction
