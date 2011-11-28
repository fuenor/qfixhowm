"================================================================================
"    Description: 日本語Grepヘルパー
"                 本体はqfixlist.vimで本プラグインはキーマップ等のフロントエン
"                 ドのみ設定している
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/grep
"================================================================================
let s:Version = 2.84
scriptencoding utf-8

if exists('g:disable_MyGrep') && g:disable_MyGrep == 1
  finish
endif
if exists('g:MyGrep_version') && g:MyGrep_version < s:Version
  let g:loaded_MyGrep = 0
endif
if exists("g:loaded_MyGrep") && g:loaded_MyGrep && !exists('g:fudist')
  finish
endif
let g:MyGrep_version = s:Version
let g:loaded_MyGrep = 1
if v:version < 700 || &cp
  finish
endif
let s:debug = exists('g:fudist') ? g:fudist : 0

" メニューへの登録
if !exists('MyGrep_MenuBar')
  let MyGrep_MenuBar = 2
endif
" キーマップリーダー
if !exists('g:MyGrep_Key')
  let g:MyGrep_Key = 'g'
  if exists('g:QFixHowm_Key')
    let g:MyGrep_Key = g:QFixHowm_Key
  endif
endif
" キーマップリーダー(2ストローク)
if !exists('g:MyGrep_KeyB')
  let g:MyGrep_KeyB = ','
  if exists('g:QFixHowm_KeyB')
    let g:MyGrep_KeyB = g:QFixHowm_KeyB
  endif
endif
let s:MyGrep_Key = g:MyGrep_Key . g:MyGrep_KeyB

" コマンドラインコマンドを使用する
if !exists('g:MyGrep_UseCommand')
  let g:MyGrep_UseCommand = 1
endif

""""""""""""""""""""""""""""""
if !exists('g:QFix_Height')
  let g:QFix_Height = 10
endif
if !exists('g:QFix_HeightDefault')
  let g:QFix_HeightDefault = QFix_Height
endif
if !exists('g:QFix_HeightFixMode')
  let g:QFix_HeightFixMode = 0
endif
if !exists('g:MyGrep_Ignorecase')
  let g:MyGrep_Ignorecase = 1
endif
if !exists('g:MyGrep_Regexp')
  let g:MyGrep_Regexp = 1
endif
if !exists('g:MyGrep_Recursive')
  let g:MyGrep_Recursive = 0
endif
" 検索ディレクトリはカレントディレクトリを基点にする
if !exists('g:MyGrep_CurrentDirMode')
  let g:MyGrep_CurrentDirMode = 1
endif
" デフォルトのファイルパターン
if !exists('g:MyGrep_FilePattern')
  let g:MyGrep_FilePattern = '*'
endif
if !exists('g:QFix_UseLocationList')
  let g:QFix_UseLocationList = 0
endif
if !exists('g:MyGrep_UseLocationList')
  " let g:MyGrep_UseLocationList = 0
endif
if !exists('g:findstr')
  let g:findstr = 'findstr'
endif
if !exists('g:grep')
  let g:grep = 'grep'
endif

""""""""""""""""""""""""""""""
" ユーザ呼び出し用コマンド
""""""""""""""""""""""""""""""
if !exists('g:MyGrep_SearchPathMode')
  let g:MyGrep_SearchPathMode = 1
endif

if g:MyGrep_UseCommand == 1
  command! -nargs=? -bang BGrep        call BGrep(<q-args>, <bang>0, 0)
  command! -nargs=? -bang Vimgrep      call UGrep('vimgrep', <q-args>, g:MyGrep_SearchPathMode, 0)
  command! -nargs=? -bang VGrep        call UGrep('vimgrep', <q-args>, g:MyGrep_SearchPathMode, 0)

  command! -nargs=? -bang BGrepadd     call BGrep(<q-args>, <bang>0, 1)
  command! -nargs=? -bang VGrepadd     call UGrep('vimgrep', <q-args>, g:MyGrep_SearchPathMode, 1)
  command! -nargs=? -bang Vimgrepadd   call UGrep('vimgrep', <q-args>, g:MyGrep_SearchPathMode, 1)

  command! -nargs=* -bang Grep        call CGrep( 0, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang FGrep       call CGrep( 1, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang EGrep       call CGrep( 0, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang RGrep       call RCGrep(0, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang RFGrep      call RCGrep(1, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang REGrep      call RCGrep(0, g:MyGrep_SearchPathMode, 0, <q-args>)

  command! -nargs=* -bang Grepadd     call CGrep( 0, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang FGrepadd    call CGrep( 1, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang EGrepadd    call CGrep( 0, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang RGrepadd    call RCGrep(0, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang RFGrepadd   call RCGrep(1, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang REGrepadd   call RCGrep(0, g:MyGrep_SearchPathMode, 1, <q-args>)

  command! -nargs=* -bang QFGrep      call CGrep( 0, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang QFGrepadd   call CGrep( 0, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang QFFGrep     call CGrep( 1, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang QFFGrepadd  call CGrep( 1, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang QFRGrep     call RCGrep(0, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang QFRGrepadd  call RCGrep(0, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang QFRFGrep    call RCGrep(1, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang QFRFGrepadd call RCGrep(1, g:MyGrep_SearchPathMode, 1, <q-args>)
endif

command! -nargs=? -bang QFBGrep call BGrep(<q-args>, <bang>0, 0)
command! -nargs=? -bang QFVGrep call VGrep(<q-args>, g:MyGrep_SearchPathMode, 0)

command! -nargs=? -bang QFBGrepadd call BGrep(<q-args>, <bang>0, 1)
command! -nargs=? -bang QFVGrepadd call VGrep(<q-args>, g:MyGrep_SearchPathMode, 1)

if MyGrep_MenuBar
  let s:MyGrep_Key = escape(s:MyGrep_Key, '\\')
  let s:menu = '&Tools.QFixGrep(&G)'
  if MyGrep_MenuBar == 2
    let s:menu = 'Grep(&G)'
  elseif MyGrep_MenuBar == 3
    let s:menu = 'QFixApp(&Q).QFixGrep(&G)'
  endif
  exe 'amenu <silent> 41.331 '.s:menu.'.Grep(&G)<Tab>'.s:MyGrep_Key.'e  :QFGrep!<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.FGrep(&F)<Tab>'.s:MyGrep_Key.'f  :QFFGrep!<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.RGrep(&R)<Tab>'.s:MyGrep_Key.'re  :QFRGrep!<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.RFGrep(&R)<Tab>'.s:MyGrep_Key.'rf  :QFRFGrep!<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.GrepBuffer(&B)<TAB>'.s:MyGrep_Key.'b :BGrep<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.Vimgrep(&V)<Tab>'.s:MyGrep_Key.'v  :QFVGrep!<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.-sep1-			<Nop>'

  exe 'amenu <silent> 41.331 '.s:menu.'.Grepadd(&G)<Tab>'.s:MyGrep_Key.'E  :QFGrepadd!<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.FGrepadd(&F)<Tab>'.s:MyGrep_Key.'F  :QFFGrepadd!<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.RGrepadd(&R)<Tab>'.s:MyGrep_Key.'rE  :QFRGrepadd!<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.RFGrepadd(&R)<Tab>'.s:MyGrep_Key.'rF  :QFRFGrepadd!<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.GrepBufferadd(&B)<TAB>'.s:MyGrep_Key.'B  :BGrepadd<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.Vimgrepadd(&V)<Tab>'.s:MyGrep_Key.'V  :QFVGrepadd!<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.-sep2-			<Nop>'
  exe 'amenu <silent> 41.331 '.s:menu.'.CurrentDirMode(&D)<Tab>'.s:MyGrep_Key.'rD  :ToggleGrepCurrentDirMode<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.SetFileEncoding(&G)<Tab>'.s:MyGrep_Key.'rG  :call s:SetFileEncoding()<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.RecursiveMode(&M)<Tab>'.s:MyGrep_Key.'rM  :ToggleGrepRecursiveMode<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.-sep3-			<Nop>'
  exe 'amenu <silent> 41.331 '.s:menu.'.Load\ Quickfix(&L)<Tab>'.s:MyGrep_Key.'k  :MyGrepReadResult<CR>\|:QFixCopen<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.Load\ Quickfix[Local]\ (&O)<Tab>O :MyGrepReadResult<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.Save\ Quickfix[Local]\ (&A)<Tab>A :MyGrepWriteResult<CR>'
  exe 'amenu <silent> 41.331 '.s:menu.'.-sep4-			<Nop>'
  exe 'amenu <silent> 41.331 '.s:menu.'.Help(&H)<Tab>'.s:MyGrep_Key.'H  :<C-u>call QFixGrepHelp_()<CR>'

  if MyGrep_MenuBar == 1
    exe 'amenu <silent> 40.333 &Tools.-sepend-			<Nop>'
  endif
  let s:MyGrep_Key = g:MyGrep_Key . g:MyGrep_KeyB
endif

exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'b  :call BGrep("", 0, 0)<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'b  :call BGrep("", -1, 0)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'e  :QFGrep!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'e  :call Grep("", -1, "Grep", 0)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'f  :QFFGrep!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'f  :call FGrep("", -1, 0)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'re  :QFRGrep!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'re  :call RGrep("", -1, "RGrep", 0)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rf  :QFRFGrep!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'rf  :call RFGrep("", -1, 0)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'v  :QFVGrep!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'v  :call VGrep("", -1, 0)<CR>'

exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rD  :ToggleGrepCurrentDirMode<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rG  :call <SID>SetFileEncoding()<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rM  :ToggleGrepRecursiveMode<CR>'

exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'B  :BGrepadd<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'E  :QFGrepadd!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'E  :call Grep("", -1, "Grep", 1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'F  :QFFGrepadd!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'F  :call FGrep("", -1, 1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rE  :QFRGrepadd!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'rE  :call RGrep("", -1, "RGrep", 1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rF  :QFRFGrepadd!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'rF  :call RFGrep("", -1, 1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'RE  :QFRGrepadd!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'RE  :call RGrep("", -1, "RGrep", 1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'RF  :QFRFGrepadd!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'RF  :call RFGrep("", -1, 1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'V  :QFVGrepadd!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'V  :call VGrep("", -1, 1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'k :MyGrepReadResult<CR>\|:QFixCopen<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'H :call QFixGrepHelp()<CR>'

exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'. :<C-u>call QFixGrepLocationMode()<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'0 :<C-u>call QFixGrepLocationMode(0)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'1 :<C-u>call QFixGrepLocationMode(1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'2 :<C-u>call QFixGrepLocationMode(2)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'3 :<C-u>call QFixGrepLocationMode(3)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'4 :<C-u>call QFixGrepLocationMode(4)<CR>'

autocmd BufWinEnter quickfix exe 'silent! nnoremap <unique> <buffer> <silent> '.s:MyGrep_Key.'w :MyGrepWriteResult<CR>'

""""""""""""""""""""""""""""""
" コマンド本体
""""""""""""""""""""""""""""""
command! -bang ToggleDamemoji           call qfixlist#ToggleDamemoji()
command! -bang ToggleGrepCurrentDirMode call qfixlist#ToggleGrepCurrentDirMode ()
command! -bang ToggleGrepRecursiveMode  call qfixlist#ToggleGrepRecursiveMode ()

""""""""""""""""""""""""""""""
function! VGrep(word, mode, addflag)
  let addflag = a:addflag
  let title = 'Vimgrep'
  if addflag
    let title = 'Vimgrepadd'
  endif
  let g:MyGrep_UseVimgrep = 1
  call Grep(a:word, a:mode, title, addflag)
endfunction

""""""""""""""""""""""""""""""
function! RFGrep(word, mode, addflag)
  let g:MyGrep_Recursive = 1
  return FGrep(a:word, a:mode, a:addflag)
endfunction

""""""""""""""""""""""""""""""
function! FGrep(word, mode, addflag)
  let addflag = a:addflag
  let title = 'FGrep'
  if addflag
    let title = 'FGrepadd'
  endif
  if g:MyGrep_Recursive == 1
    let title = 'R'.title
  endif
  let pattern = a:word
  let g:MyGrep_Regexp = 0
  call Grep(pattern, a:mode, title, addflag)
endfunction

""""""""""""""""""""""""""""""
function! UGrep(cmd, args, mode, addflag)
  if a:args == ''
    if a:cmd == 'grep'
      let title = a:addflag? 'Grepadd' : 'Grep'
      if g:MyGrep_Recursive == 1
        let title = 'R'.title
      endif
      return Grep('', a:mode, title, a:addflag)
    elseif a:cmd == 'grep -F'
      return FGrep('', a:mode, a:addflag)
    elseif a:cmd =~ 'vimgrep'
      return VGrep('', a:mode, a:addflag)
    endif
    return Grep('', a:mode, title, a:addflag)
  endif
  call s:save()
  let addflag = a:addflag
  let g:QFix_SearchPath = getcwd()
  if a:mode
    let disppath = expand('%:p:h')
  else
    let disppath = g:QFix_SearchPath
  endif
  let g:QFix_SearchPath = disppath
  let bufnr = bufnr('%')
  let save_cursor = getpos('.')
  if addflag == 0
    let ccmd = g:QFix_UseLocationList ? 'lexpr ""' : 'cexpr ""'
    exe ccmd
  endif
  call QFixPclose()
  if g:QFix_SearchPath != ''
  " silent! exe 'lchdir ' . escape(g:QFix_SearchPath, ' ')
  endif
  if addflag
    let g:QFix_SearchPath = disppath
  endif

  let cmd = a:cmd
  if cmd =~ 'vimgrep' && g:QFix_UseLocationList
    let cmd = 'l'.cmd
  endif
  let cmd = cmd.' '. a:args
  exe cmd
  let g:QFix_SearchResult = []
  let save_qflist = QFixGetqflist()
  if empty(save_qflist)
    redraw | echo 'QFixGrep : Not found!'
  else
    if g:QFix_HeightFixMode == 1
      let g:QFix_Height = g:QFix_HeightDefault
    endif
    QFixCopen
    call cursor(1, 1)
    redraw | echo ''
  endif
  call s:restore()
endfunction

""""""""""""""""""""""""""""""
function! RGrep(word, mode, title, addflag)
  let g:MyGrep_Recursive = 1
  let title = a:title
  let title = a:addflag ? title.'add' : title
  return Grep(a:word, a:mode, title, a:addflag)
endfunction

""""""""""""""""""""""""""""""
let s:MyGrep_Fenc = ''
" 検索時にカーソル位置の単語を拾う
if !exists('g:MyGrep_DefaultSearchWord')
  let g:MyGrep_DefaultSearchWord = 1
endif
function! Grep(word, mode, title, addflag)
  let addflag = a:addflag
  let pattern = a:word
  let extpattern = ''
  let extpat = '\(\s\+\(\*\*\/\)\?\*\.[^.]\+\)\+$'
  if pattern =~ extpat
    let extpattern = matchstr(pattern, extpat)
    let pattern = substitute(pattern, extpat, '', '')
  endif
  if pattern == '' || a:mode == -1
    let pattern = expand("<cword>")
    if g:MyGrep_DefaultSearchWord == 0
      let pattern = ''
    endif
    if a:mode == -1
      exe 'normal! vgvy'
      let pattern = @0
    endif
    let pattern = input(a:title." : ", pattern)
  endif
  if pattern == ''
    let g:MyGrep_Regexp = 1
    let g:MyGrep_Ignorecase = 1
    let g:MyGrep_Recursive  = 0
    let g:MyGrep_UseVimgrep = 0
    return
  endif
  let filepattern = '*'
  if expand('%:e') != ''
    let filepattern = '*.' . expand('%:e')
  endif
  if g:MyGrep_FilePattern != ''
    let filepattern = g:MyGrep_FilePattern
  endif
  if extpattern == ''
    let filepattern = input("filepattern (rcsv: **/*) : ", filepattern)
  else
    let filepattern = extpattern
  endif
  if filepattern == '' | return | endif
  call s:save()
  let @/ = '\V'.pattern
  call histadd('/', @/)
  call histadd('@', pattern)
  if match(pattern, '\C[A-Z]') != -1
    let g:MyGrep_Ignorecase = 0
  endif
  if a:mode == 0
    let searchPath = getcwd()
  else
    let searchPath = expand('%:p:h')
  endif
  if g:MyGrep_CurrentDirMode == 1
    let searchPath = getcwd()
  endif
  let fenc = &fileencoding
  if fenc == ''
    let fenc = &enc
  endif
  if s:MyGrep_Fenc != ''
    let fenc = s:MyGrep_Fenc
  endif
  let prevPath = escape(getcwd(), ' ')
  if a:addflag && g:QFix_SearchPath != ''
    let disppath = g:QFix_SearchPath
  else
    let disppath = searchPath
  endif
  let g:QFix_SearchPath = disppath
  if exists('*QFixSaveHeight')
    call QFixSaveHeight(0)
  endif
  call qfixlist#MyGrep(pattern, searchPath, filepattern, fenc, addflag)
  if g:QFix_SearchPath != ''
  " silent! exe 'lchdir ' . escape(g:QFix_SearchPath, ' ')
  endif
  let save_qflist = QFixGetqflist()
  if empty(save_qflist)
    redraw | echo 'QFixGrep : Not found!'
    echo pattern.' | '.fenc.' | '.filepattern.' | '. searchPath
  else
    if g:QFix_HeightFixMode == 1
      let g:QFix_Height = g:QFix_HeightDefault
    endif
    if a:addflag
      let g:QFix_SearchPath = disppath
    endif
    QFixCopen
    call cursor(1, 1)
    redraw | echo ''
  endif
  if g:MyGrep_ErrorMes != ''
    echohl ErrorMsg
    redraw | echo g:MyGrep_ErrorMes
    echohl None
  endif
  " silent! exe 'lchdir ' . prevPath
  call s:restore()
endfunction

function! s:SetFileEncoding()
  let mes = 'QFixGrep : grep fileencoding = '
  let s:MyGrep_Fenc = input(mes, s:MyGrep_Fenc)
endfunction

function! s:restore()
  if !exists('g:MyGrep_UseLocationList') || s:QFix_UseLocationList == g:MyGrep_UseLocationList
    return
  endif
  let g:QFix_Win             = s:QFix_Win
  let g:QFix_SearchPath      = s:QFix_SearchPath
  let g:QFix_UseLocationList = s:QFix_UseLocationList
endfunction

function! s:save()
  let s:QFix_UseLocationList = g:QFix_UseLocationList
  if !exists('g:MyGrep_UseLocationList') || g:QFix_UseLocationList == g:MyGrep_UseLocationList
    return
  endif
  let s:QFix_Win             = g:QFix_Win
  let s:QFix_SearchPath      = g:QFix_SearchPath
  let g:QFix_UseLocationList = g:MyGrep_UseLocationList
endfunction

""""""""""""""""""""""""""""""
" バッファのみgrep
" 無名バッファは検索できない。
""""""""""""""""""""""""""""""
function! BGrep(word, mode, addflag)
  call qfixlist#BGrep(a:word, a:mode, a:addflag)
endfunction

""""""""""""""""""""""""""""""
" コマンドラインgrep
""""""""""""""""""""""""""""""
let s:rMyGrep_Recursive = 0
function! RCGrep(mode, bang, addflag,  arg)
  let s:rMyGrep_Recursive = 1
  call CGrep(a:mode, a:bang, a:addflag, a:arg)
endfunction

function! CGrep(mode, bang, addflag,  arg)
  let mode = a:mode
  let addflag = a:addflag
  let opt = ''
  let pattern = ''
  let filepattern = ''
  let path = ''
  let type = 0
  let g:MyGrep_cmdopt = ''

  let g:MyGrep_Regexp = 1
  let g:MyGrep_Ignorecase = 1
  let g:MyGrep_Recursive  = 0
  let g:MyGrep_UseVimgrep = 0

  if s:rMyGrep_Recursive
    let g:MyGrep_Recursive  = 1
  endif
  let s:rMyGrep_Recursive = 0
  let opt = matchstr(a:arg, '^\(\s*[-/][^ ]\+\)\+')
  let fenc = matchstr(opt, '--fenc=[^\s]\+')
  let fenc = substitute(fenc, '--fenc=', '', '')
  if fenc == ''
    let fenc = &fenc
  endif
  let opt = substitute(opt,'--fenc=[^\s]\+', '', '')

  let pattern = substitute(a:arg, '^\(\s*[-/][^ ]\+\)\+', '', '')
  let pattern = matchstr(pattern, '^.*[^\\]\s')
  let pattern = substitute(pattern, '\s*$\|^\s*', '', 'g')
  if pattern =~ '^".*"$'
    let pattern = substitute(pattern, '^"\|"$', '', 'g')
  endif
  " \で " をエスケープ？
  if pattern =~ '^\\".*\\"$'
    let pattern = substitute(pattern, '^\\"\|\\"$', '"', 'g')
  endif
  let str = substitute(a:arg, '^.*[^\\]\s', '', '')
  let str = substitute(str, '\\ ', ' ', 'g')
  let path = fnamemodify(str, ':p:h')
  if path == ''
    let path = expand('%:p:h')
  endif
  let filepattern = fnamemodify(str, ':t')
  if pattern =~ '^\s*$'
    if mode
      return UGrep('grep -F', pattern, a:bang, addflag)
    endif
    return UGrep('grep', pattern, a:bang, addflag)
  endif
  call s:save()
  if mode
    let g:MyGrep_Regexp = 0
  endif
  let g:MyGrep_cmdopt = opt
  call qfixlist#MyGrep(pattern, path, filepattern, fenc, addflag)
  let save_qflist = QFixGetqflist()
  if empty(save_qflist)
    redraw | echo 'QFixGrep : Not found!'
    echo pattern.' | '.fenc.' | '.filepattern.' | '. path
  else
    if g:QFix_HeightFixMode == 1
      let g:QFix_Height = g:QFix_HeightDefault
    endif
    QFixCopen
    call cursor(1, 1)
  endif
  call s:restore()
endfunction

let s:QFixGrep_Helpfile = 'QFixGrepHelp'
function! QFixGrepHelp()
  if exists('*QFixHowmHelp')
    return QFixHowmHelp()
  endif
  return QFixGrepHelp_()
endfunction

function! QFixGrepHelp_()
  call mygrep_msg#help()
  silent! exe 'split ' . s:QFixGrep_Helpfile
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  " setlocal nobuflisted
  call setline(1, g:QFixGrepHelpList)
  call cursor(1, 1)
endfunction

