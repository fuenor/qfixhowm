"================================================================================
"    Description: QFixGrep (日本語Grepヘルパー)
"                 本プラグインはキーマップ等のフロントエンドのみ設定している
"                 grep     : qfixlist.vim
"                 QuickFix : myqfix.vim
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/grep
"================================================================================
let s:version = 300
scriptencoding utf-8

"  Install:
"    このファイルとqfixlist.vimをランタイムパスの通った場所へコピーしてくださ
"    い。
"    qfixlist.vimはautoload対応なのでautoloadディレクトリでもかまいません。
"    プレビュー表示や絞り込み検索等にはmyqfix.vimも必要です。
"
"    * Windowsのgrep
"      grep.exeがある場合は mygrepprgを設定してください。
"        let mygrepprg='c:/cygwin/bin/grep'
"        let mygrepprg='grep'
"
"        デフォルトではfindstrが使用されますが、utf-8等のファイルは検索できま
"        せんし正規表現は貧弱です。
"        詳しくは以下を参照してください。
"        http://sites.google.com/site/fudist/Home/grep
"  Note:
"    このプラグインはQFixGrepフロントエンドのみ設定しているので無効化しても
"    QFixMemoの動作に支障はありません。
"      let disable_MyGrep = 1
"
"    好みのgrepコマンドを作成したい場合はこのファイルをコピーして改変してくだ
"    さい。

if exists('g:disable_MyGrep') && g:disable_MyGrep == 1
  finish
endif
if exists('g:MyGrep_version') && g:MyGrep_version < s:version
  let g:loaded_MyGrep = 0
endif
if exists("g:loaded_MyGrep") && g:loaded_MyGrep && !exists('g:fudist')
  finish
endif
let g:MyGrep_version = s:version
let g:loaded_MyGrep = 1
if v:version < 700 || &cp
  finish
endif
let s:debug = exists('g:fudist') ? g:fudist : 0

" let mygrepprg=findstr, let mygrepprg=grepで切り替え可能に
if !exists('g:grep') && exists('g:mygrepprg')
  let g:grep = g:mygrepprg
endif
if !exists('g:findstr')
  let g:findstr = 'findstr'
endif

" メニューへの登録
if !exists('MyGrep_MenuBar')
  let MyGrep_MenuBar = 2 * has('gui_running')
endif

" キーマップを使用する
if !exists('g:MyGrep_Keymap')
  let g:MyGrep_Keymap = 1
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

" デフォルトのファイルパターン
if !exists('g:MyGrep_FilePattern')
  let g:MyGrep_FilePattern = '*'
endif
" 検索時にカーソル位置の単語を拾う
if !exists('g:MyGrep_DefaultSearchWord')
  let g:MyGrep_DefaultSearchWord = 1
endif
" 検索ディレクトリはカレントディレクトリを基点にする
if !exists('g:MyGrep_CurrentDirMode')
  let g:MyGrep_CurrentDirMode = 1
endif
" 検索は常に再帰検索
if !exists('g:MyGrep_RecursiveMode')
  let g:MyGrep_RecursiveMode = 0
endif
" デフォルトソートパターン('', 'mtime', 'text', 'reverse')
if !exists('g:MyGrep_Sort')
  let g:MyGrep_Sort = ''
endif
" help
if !exists('g:QFixGrep_Help')
  let g:QFixGrep_Help= 'qfixgrep_help'
endif

silent! function QFixGrepMenubar(menu, leader)
  let sepcmd  = 'amenu <silent> 41.333 '.a:menu.'.-sep%d-			<Nop>'
  let menucmd = 'amenu <silent> 41.333 '.a:menu.'.%s<Tab>'.a:leader.'%s %s'
  call s:addMenu(menucmd, 'Grep(&G)'                    , 'e',  ':<C-u>call <SID>QFGrep("Grep")<CR>')
  call s:addMenu(menucmd, 'FGrep(&F)'                   , 'f',  ':<C-u>call <SID>QFGrep("FGrep")<CR>')
  call s:addMenu(menucmd, 'RGrep(&R)'                   , 're', ':<C-u>call <SID>QFGrep("RGrep")<CR>')
  call s:addMenu(menucmd, 'RFGrep(&R)'                  , 'rf', ':<C-u>call <SID>QFGrep("RFGrep")<CR>')
  call s:addMenu(menucmd, 'Vimgrep(&V)'                 , 'v',  ':<C-u>call <SID>QFGrep("Vimgrep")<CR>')
  call s:addMenu(menucmd, 'GrepBuffer(&B)'              , 'b',  ':<C-u>BGrep<CR>')
  exe printf(sepcmd, 1)
  call s:addMenu(menucmd, 'Grepadd(&G)'                 , 'E',  ':<C-u>call <SID>QFGrep("Grepadd")<CR>')
  call s:addMenu(menucmd, 'FGrepadd(&F)'                , 'F',  ':<C-u>call <SID>QFGrep("FGrepadd")<CR>')
  call s:addMenu(menucmd, 'RGrepadd(&R)'                , 'rE', ':<C-u>call <SID>QFGrep("RGrepadd")<CR>')
  call s:addMenu(menucmd, 'RFGrepadd(&R)'               , 'rF', ':<C-u>call <SID>QFGrep("RFGrepadd")<CR>')
  call s:addMenu(menucmd, 'Vimgrepadd(&V)'              , 'V',  ':<C-u>call <SID>QFGrep("Vimgrepadd")<CR>')
  call s:addMenu(menucmd, 'GrepBufferadd(&B)'           , 'B',  ':<C-u>BGrepadd<CR>')
  exe printf(sepcmd, 2)
  call s:addMenu(menucmd, 'CurrentDirMode(&D)'          , 'rD', ':<C-u>ToggleGrepCurrentDirMode<CR>')
  call s:addMenu(menucmd, 'SetFileEncoding(&G)'         , 'rG', ':<C-u>call <SID>SetFileEncoding()<CR>')
  call s:addMenu(menucmd, 'RecursiveMode(&M)'           , 'rM', ':<C-u>ToggleGrepRecursiveMode<CR>')
  exe printf(sepcmd, 3)
  call s:addMenu(menucmd, 'Load\ Quickfix(&L)'          , 'k',  ':<C-u>MyGrepReadResult<CR>\|:call QFixCopen()<CR>')
  call s:addMenu(menucmd, 'Save\ Quickfix[Local]\ (&A)' , 'w',  ':<C-u>MyGrepWriteResult<CR>')
  exe printf(sepcmd, 4)
  call s:addMenu(menucmd, 'Help(&H)'                    , 'H',  ':<C-u>help '.g:QFixGrep_Help.'<CR>')
endfunction

function! s:addMenu(menu, acc, key, cmd)
  exe printf(a:menu, a:acc, a:key, a:cmd)
endfunction

if g:MyGrep_MenuBar
  let s:menu = '&Tools.QFixGrep(&G)'
  if MyGrep_MenuBar == 2
    let s:menu = 'Grep(&G)'
  elseif MyGrep_MenuBar == 3
    let s:menu = 'QFixApp(&Q).QFixGrep(&G)'
  endif
  let s:MyGrep_Key = g:MyGrep_Key . g:MyGrep_KeyB
  let s:MyGrep_Key = exists('g:qfixmemo_mapleader') ? g:qfixmemo_mapleader : s:MyGrep_Key
  let s:MyGrep_Key = escape(s:MyGrep_Key, '\\')
  call QFixGrepMenubar(s:menu, s:MyGrep_Key)
endif

if g:MyGrep_Keymap
  let s:MyGrep_Key = g:MyGrep_Key . g:MyGrep_KeyB
  let s:MyGrep_Key = exists('g:qfixmemo_mapleader') ? g:qfixmemo_mapleader : s:MyGrep_Key
  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'b  :<C-u>call <SID>BGrep("", 0, 0)<CR>'
  exe 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'b  :<C-u>call <SID>BGrep("", -1, 0)<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'e  :<C-u>call <SID>QFGrep("Grep")<CR>'
  exe 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'e  :<C-u>call <SID>QFGrep("GrepV")<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'f  :<C-u>call <SID>QFGrep("FGrep")<CR>'
  exe 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'f  :<C-u>call <SID>QFGrep("FGrepV")<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'re :<C-u>call <SID>QFGrep("RGrep")<CR>'
  exe 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'re :<C-u>call <SID>QFGrep("RGrepV")<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rf :<C-u>call <SID>QFGrep("RFGrep")<CR>'
  exe 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'rf :<C-u>call <SID>QFGrep("RFGrepV")<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'v  :<C-u>call <SID>QFGrep("Vimgrep")<CR>'
  exe 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'v  :<C-u>call <SID>QFGrep("VimgrepV")<CR>'

  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rD  :<C-u>ToggleGrepCurrentDirMode<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rG  :<C-u>call <SID>SetFileEncoding()<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rM  :<C-u>ToggleGrepRecursiveMode<CR>'

  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'B  :<C-u>call <SID>BGrep("", 0, 0)<CR>'
  exe 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'B  :<C-u>call <SID>BGrep("", -1, 0)<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'E  :<C-u>call <SID>QFGrep("Grepadd")<CR>'
  exe 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'E  :<C-u>call <SID>QFGrep("GrepaddV")<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'F  :<C-u>call <SID>QFGrep("FGrepadd")<CR>'
  exe 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'F  :<C-u>call <SID>QFGrep("FGrepaddV")<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rE :<C-u>call <SID>QFGrep("RGrepadd")<CR>'
  exe 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'rE :<C-u>call <SID>QFGrep("RGrepaddV")<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rF :<C-u>call <SID>QFGrep("RFGrepadd")<CR>'
  exe 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'rF :<C-u>call <SID>QFGrep("RFGrepaddV")<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'V  :<C-u>call <SID>QFGrep("Vimgrepadd")<CR>'
  exe 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'V  :<C-u>call <SID>QFGrep("VimgrepaddV")<CR>'

  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'k :MyGrepReadResult<CR>\|:call QFixCopen()<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'H  :<C-u>call <SID>help()<CR>'
  autocmd BufWinEnter quickfix exe 'silent! nnoremap <unique> <buffer> <silent> '.s:MyGrep_Key.'w :MyGrepWriteResult<CR>'
  let s:MyGrep_Key = g:MyGrep_Key . g:MyGrep_KeyB
endif

""""""""""""""""""""""""""""""
" トグルコマンド
""""""""""""""""""""""""""""""
command! -bang ToggleGrepCurrentDirMode call <SID>ToggleGrepCurrentDirMode()
command! -bang ToggleGrepRecursiveMode  call <SID>ToggleGrepRecursiveMode()
command! -bang ToggleDamemoji           call qfixlist#ToggleDamemoji()

function! s:ToggleGrepCurrentDirMode()
  let g:MyGrep_CurrentDirMode = !g:MyGrep_CurrentDirMode
  echo 'QFixList : CurrentDirMode = '.(g:MyGrep_CurrentDirMode ? 'ON' : 'OFF')
endfunction

function! s:ToggleGrepRecursiveMode()
  let g:MyGrep_RecursiveMode = !g:MyGrep_RecursiveMode
  echo 'QFixList : RecursiveMode = '.(g:MyGrep_RecursiveMode ? 'ON' : 'OFF')
endfunction

""""""""""""""""""""""""""""""
" キーマップ/メニュー用
""""""""""""""""""""""""""""""
let s:prevResult = []
function! QFixGrep(cmd, pattern, path, filepattern, fenc, ...)
  let pattern = a:pattern
  if a:cmd =~ '\CV$'
    exe 'normal! vgvy'
    let pattern = @0
  endif
  let cmd = substitute(a:cmd, '\CV$', '', '')
  if pattern == '' && g:MyGrep_DefaultSearchWord
    let pattern = expand("<cword>")
  endif
  let pattern = input(cmd." : ", pattern)
  if pattern == ''
    return
  endif

  let path = a:path
  if path == ''
    let path = g:MyGrep_CurrentDirMode ? getcwd() : expand('%:p:h')
  endif

  let filepattern = a:filepattern != '' ? a:filepattern : '*'
  if g:MyGrep_FilePattern != ''
    let filepattern = g:MyGrep_FilePattern
  endif
  let filepattern = input("filepattern (rcsv: **/*) : ", filepattern)
  if filepattern == ''
    return
  endif
  call histdel("input", '^\*$')

  let fenc = a:fenc
  if fenc == ''
    let fenc = &fenc != '' ? &fenc : &enc
    let fenc = s:MyGrep_Fenc != '' ? s:MyGrep_Fenc : fenc
  endif

  let addflag = s:setenv(cmd)
  if !addflag
    let s:prevResult = []
  endif
  let qflist = qfixlist#sortgrep(pattern, path, g:MyGrep_Sort, filepattern, fenc)
  let s:prevResult = extend(s:prevResult, qflist)
  if empty(qflist)
    redraw | echo 'QFixGrep : Not found!'
    echo pattern.' | '.fenc.' | '.filepattern.' | '. path
  else
    call qfixlist#copen(s:prevResult, path)
  endif
endfunction

function! s:QFGrep(cmd)
  return QFixGrep(a:cmd, '', '', '', '', '')
endfunction

let s:MyGrep_Fenc = ''
function! s:SetFileEncoding()
  let mes = 'QFixGrep : grep fileencoding = '
  let s:MyGrep_Fenc = input(mes, s:MyGrep_Fenc)
endfunction

""""""""""""""""""""""""""""""
" コマンドラインコマンド
""""""""""""""""""""""""""""""
command! -nargs=* -bang BGrep       call <SID>BGrep(<q-args>, <bang>0, 0)
command! -nargs=* -bang Vimgrep     call <SID>QFixCmdGrep('Vimgrep', <q-args>)
command! -nargs=* -bang VGrep       call <SID>QFixCmdGrep('Vimgrep', <q-args>)

command! -nargs=* -bang BGrepadd    call <SID>BGrep(<q-args>, <bang>0, 1)
command! -nargs=* -bang VGrepadd    call <SID>QFixCmdGrep('Vimgrepadd', <q-args>)
command! -nargs=* -bang Vimgrepadd  call <SID>QFixCmdGrep('Vimgrepadd', <q-args>)

command! -nargs=* -bang Grep        call <SID>QFixCmdGrep('Grep',   <q-args>)
command! -nargs=* -bang EGrep       call <SID>QFixCmdGrep('Grep',   <q-args>)
command! -nargs=* -bang FGrep       call <SID>QFixCmdGrep('FGrep',  <q-args>)
command! -nargs=* -bang RGrep       call <SID>QFixCmdGrep('RGrep',  <q-args>)
command! -nargs=* -bang REGrep      call <SID>QFixCmdGrep('RGrep',  <q-args>)
command! -nargs=* -bang RFGrep      call <SID>QFixCmdGrep('RFGrep', <q-args>)

command! -nargs=* -bang Grepadd     call <SID>QFixCmdGrep('Grepadd',   <q-args>)
command! -nargs=* -bang EGrepadd    call <SID>QFixCmdGrep('Grepadd',   <q-args>)
command! -nargs=* -bang FGrepadd    call <SID>QFixCmdGrep('FGrepadd',  <q-args>)
command! -nargs=* -bang RGrepadd    call <SID>QFixCmdGrep('RGrepadd',  <q-args>)
command! -nargs=* -bang REGrepadd   call <SID>QFixCmdGrep('RGrepadd',  <q-args>)
command! -nargs=* -bang RFGrepadd   call <SID>QFixCmdGrep('RFGrepadd', <q-args>)

""""""""""""""""""""""""""""""
" コマンドラインgrep本体
""""""""""""""""""""""""""""""
function! s:QFixCmdGrep(cmd, arg)
  let opt = matchstr(a:arg, '^\(\s*[-/][^ ]\+\)\+')
  let fenc = matchstr(opt, '--fenc=[^\s]\+')
  let fenc = substitute(fenc, '--fenc=', '', '')
  if fenc == ''
    let fenc = &fenc != '' ? &fenc : &enc
    let fenc = s:MyGrep_Fenc != '' ? s:MyGrep_Fenc : fenc
  endif
  let opt = substitute(opt,'--fenc=[^\s]\+', '', '')
  let g:MyGrep_cmdopt = opt

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
    let path = g:MyGrep_CurrentDirMode ? getcwd() : expand('%:p:h')
  endif
  let filepattern = fnamemodify(str, ':t')

  let addflag = s:setenv(a:cmd)
  if !addflag
    let s:prevResult = []
  endif
  let qflist = qfixlist#sortgrep(pattern, path, g:MyGrep_Sort, filepattern, fenc)
  let s:prevResult = extend(s:prevResult, qflist)
  if empty(qflist)
    redraw | echo 'QFixGrep : Not found!'
    echo pattern.' | '.fenc.' | '.filepattern.' | '. path
  else
    call qfixlist#copen(s:prevResult, path)
  endif
endfunction

function! s:setenv(cmd)
  let cmd = a:cmd
  let g:MyGrep_Regexp     = 1
  let g:MyGrep_Recursive  = g:MyGrep_RecursiveMode
  " let g:MyGrep_Ignorecase = 1
  let g:MyGrep_UseVimgrep = 0
  if cmd =~ '\c^r'
    let g:MyGrep_Recursive = 1
  endif
  if cmd =~ '\cfgrep'
    let g:MyGrep_Regexp = 0
  endif
  if cmd =~ '\cvimgrep'
    let g:MyGrep_UseVimgrep = 1
  endif
  return cmd =~ '\cadd'
endfunction

""""""""""""""""""""""""""""""
" バッファのみgrep
" 無名バッファは検索できない。
""""""""""""""""""""""""""""""
function! s:BGrep(word, mode, addflag)
  let pattern = a:word
  let mes = "Buffers grep : "
  if a:addflag
    let mes = "Buffers grepadd : "
  endif
  if pattern == '' || a:mode == -1
    let pattern = expand("<cword>")
    if g:MyGrep_DefaultSearchWord == 0
      let pattern = ''
    endif
    if a:mode < 0
      let pattern = @0
    endif
    let pattern = input(mes, pattern)
  endif
  if pattern == '' | return | endif
  if a:addflag && g:QFix_SearchPath != ''
    let disppath = g:QFix_SearchPath
  else
    let disppath = expand('%:p:h')
  endif
  let g:QFix_SearchPath = disppath
  let @/ = pattern
  call histadd('/', '\V' . @/)
  call histadd('@', pattern)
  let bufnr = bufnr('%')
  let save_cursor = getpos('.')
  if a:addflag == 0
    let ccmd = g:QFix_UseLocationList ? 'lexpr ""' : 'cexpr ""'
    silent! exe ccmd
  endif
  call QFixPclose()
  let vopt = g:QFix_UseLocationList ? 'l' : ''
  silent! exe ':bufdo | try | '.vopt.'vimgrepadd /' . pattern . '/j % | catch | endtry'
  silent! exe 'b'.bufnr
  if a:addflag
    let g:QFix_SearchPath = disppath
  endif
  let g:QFix_SearchResult = []
  let save_qflist = QFixGetqflist()
  if empty(save_qflist)
    redraw | echo 'QFixGrep : Not found!'
  else
    call QFixCopen()
    call cursor(1, 1)
    redraw | echo ''
  endif
endfunction

" ロケーションリスト使用
if !exists('g:QFix_UseLocationList')
  let g:QFix_UseLocationList = 0
endif

function! QFixCmdCopy2QF()
  call qfixlist#copy2qfwin()
endfunction

function s:help()
  let file = exists('g:qfixmemo_help') ? g:qfixmemo_help : g:QFixGrep_Help
  exe 'help '.file
endfunction

