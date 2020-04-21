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

" Install YouCompleteMe
function! BuildYCM(info)
  " info is a dictionary with 3 fields
  " - name:   name of the plugin
  " - status: 'installed', 'updated', or 'unchanged'
  " - force:  set on PlugInstall! or PlugUpdate!
  if a:info.status == 'installed' || a:info.force
    !./install.py
  endif
endfunction
