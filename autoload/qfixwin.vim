"=============================================================================
"    Description: QFixPreview
"                 Preview, sortings and advanced search for Quickfix.
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home  (Japanese)
"=============================================================================
scriptencoding utf-8
let s:version = 292

" What Is This:
"   This plugin adds preview, sortings and advanced search to your quickfix window.
"
" Install:
"   Put this file into your runtime directory.
"     > vimfiles/plugin or .vim/plugin
"
" Usage:
"   Execute a quickfix command(vimgrep, grep, make, etc.) and open the quickfix window.
"
" Commands:
"   | <C-w>, | Open/Close (quickfix window)
"   | <C-w>. | Move to the quickfix window
"   | <C-w>/ | Toggle QuickFix/Location list
"
"   On the quickfix window:
"   | q | Close
"   | i | Open/Close (preview window)
"   | S | Sort commands
"   | s | Filter by string
"   | r | Filter by string (exclude)
"
"   | d dd | delete
"   | p P  | put
"
"   | u | Undo
"   | U | Undo all
"
"   | & | Copy to Location list
"   | A | Save
"   | O | Restore
"=============================================================================
function! qfixwin#init()
endfunction

if exists('g:disable_QFixWin') && g:disable_QFixWin == 1
  finish
endif
if exists("g:loaded_QFixWin") && g:loaded_QFixWin && !exists('g:fudist')
  finish
endif
let g:loaded_QFixWin = 1

if v:version < 700 || !has('quickfix')
  finish
endif
let s:debug = exists('g:fudist') ? g:fudist : 0

" Quickfixの拡張コマンドとプレビュー表示
" 0 : 全て無効
" 1 : QuickFix/ロケーションリストの両方で有効
" 2 : ロケーションリストのみ有効
" 3 : QFixMemo/QFixGrepコマンドのみ有効
if !exists('g:QFixWin_EnableMode')
  let g:QFixWin_EnableMode = 2
endif

" qfixlistの表示にロケーションリストを使用する
" 0 : QuickFixウィンドウ
" 1 : ロケーションリスト
if !exists('g:QFix_UseLocationList')
  let g:QFix_UseLocationList = 1
endif

" プレビューの有効/無効
if !exists('g:QFix_PreviewEnable')
  let g:QFix_PreviewEnable = 1
endif
" quickfixウィンドウの高さ
if !exists('g:QFix_Height')
  let g:QFix_Height = 10
endif
" quickfixウィンドウの幅
if !exists('g:QFix_Width')
  let g:QFix_Width = 0
endif
" Quickfixウィンドウのコマンド指定
if !exists('g:QFix_CopenCmd')
  let g:QFix_CopenCmd = ''
endif
" カーソル強調表示を有効にする
if !exists('g:QFix_CursorLine')
  let g:QFix_CursorLine = 1
endif
" プレビューウィンドウのコマンド指定
if !exists('g:QFix_PreviewOpenCmd')
  let g:QFix_PreviewOpenCmd = ''
endif
" プレビューウィンドウのサイズ指定
if !exists('g:QFix_PreviewWidth')
  let g:QFix_PreviewWidth = 0
endif
if !exists('g:QFix_PreviewHeight')
  " let g:QFix_PreviewHeight = &previewheight'
endif
" プレビューウィンドウの折り返し
if !exists('g:QFix_PreviewWrap')
  let g:QFix_PreviewWrap = 1
endif
" プレビューのカーソル強調表示
if !exists('g:QFix_PreviewCursorLine')
  let g:QFix_PreviewCursorLine = 1
endif
" プレビューハイライト
if !exists('g:QFix_PreviewFtypeHighlight')
  let g:QFix_PreviewFtypeHighlight = 1
endif
" 'tab'に設定すると<S-CR>はファイルをタブで開く
if !exists('g:QFix_Edit')
  let g:QFix_Edit = ''
endif
" QFixWin独自の<CR>コマンドを使用する
if !exists('g:QFix_UseAltCR')
  " let g:QFix_UseAltCR = 1
endif
" ファイルを開くとQuickfixウィンドウを閉じる
if !exists('g:QFix_CloseOnJump')
  let g:QFix_CloseOnJump = 0
endif
" ファイルを開く時に編集中のウィンドウも使用する
if !exists('g:QFix_UseModifiedWindow')
  let g:QFix_UseModifiedWindow = 1
endif
" プレビューしない拡張子
if !exists('g:QFix_PreviewExclude')
  let g:QFix_PreviewExclude = '\.pdf$\|\.xls$\|\.mp3$\|\.mpg$\|\.avi$\|\.wmv$\|\.jpg$\|\.bmp$\|\.png$\|\.gif$\|\.zip$\|\.rar$\|\.exe$\|\.dll$\|\.o$\|\.obj$\|\.lnk$'
endif
" 正規表現で一行目を判定してプレビュー非表示
" ファイルエンコーディングを判定しないのでマルチバイト文字は使用不可
if !exists('g:QFix_PreviewExcludeLineRegxp')
  let g:QFix_PreviewExcludeLineRegxp = ''
  let g:QFix_PreviewExcludeLineRegxp = '^VimCrypt\~\d\{2}!'
endif
" ファイルサイズが大きいならプレビュー非表示
if !exists('g:QFix_PreviewFileSize')
  let g:QFix_PreviewFileSize = 1024*1024
endif

" プレビューする間隔
" (この値でプレビューが有効か判定しているのでユニーク値を推奨)
if !exists('g:QFix_PreviewUpdatetime')
  let g:QFix_PreviewUpdatetime = 17
endif
let g:QFix_DefaultUpdatetime = &updatetime
" ファイル名取得の高速化
if !exists('g:QFix_HighSpeedPreview')
  let g:QFix_HighSpeedPreview = 0
endif

" プレビューウィンドウタイトル
if !exists('g:QFix_PreviewName')
  let g:QFix_PreviewName = 'QuickfixPreview'
endif
" ファイルを分割して開いたときの最小ウィンドウ高さ
if !exists('g:QFix_WindowHeightMin')
  let g:QFix_WindowHeightMin = 0
endif
" Quickfixウィンドウのデフォルト高さ
if !exists('g:QFix_HeightDefault')
  let g:QFix_HeightDefault = g:QFix_Height
endif

if !exists('g:QFix_Copen_Resize')
  let g:QFix_Copen_Resize   = 0
endif
if !exists('g:QFix_Copen_winfixheight')
  let g:QFix_Copen_winfixheight   = 1
endif
if !exists('g:QFix_Copen_winfixwidth')
  let g:QFix_Copen_winfixwidth    = 0
endif
if !exists('g:QFix_Preview_winfixheight')
  let g:QFix_Preview_winfixheight = 1
endif
if !exists('g:QFix_Preview_winfixwidth')
  let g:QFix_Preview_winfixwidth  = 0
endif
if !exists('g:QFix_TabEditMode')
  let g:QFix_TabEditMode = 1
endif
if !exists('g:QFix_SearchPathMode')
  let g:QFix_SearchPathMode = 1
endif

""""""""""""""""""""""""""""""
" キーマップ
""""""""""""""""""""""""""""""
silent! nnoremap <unique> <silent> <C-w>, :<C-u>call QFixToggleWin()<CR>
silent! nnoremap <unique> <silent> <C-w>. :<C-u>call QFixMoveToWin()<CR>
silent! nnoremap <unique> <silent> <C-w>0 :<C-u>call <SID>ToggleLocationListMode()<CR>
silent! nnoremap <unique> <silent> <C-w>/ :<C-u>call <SID>ToggleLocationListMode()<CR>

""""""""""""""""""""""""""""""
" コマンド
""""""""""""""""""""""""""""""
command! -nargs=* -bang QFixCopen call QFixCopen(<q-args>, <bang>0)
command! QFixCclose call QFixCclose()

function! s:ToggleLocationListMode()
  let g:QFix_UseLocationList = !g:QFix_UseLocationList
  echo 'QFixWin : Current window = '.(g:QFix_UseLocationList ? 'Location list' : 'QuickFix')
endfunction

""""""""""""""""""""""""""""""
" 内部変数
""""""""""""""""""""""""""""""
if !s:debug
  "デフォルトで使用させない
  let g:QFix_HighSpeedPreview = 0
endif

" ロケーションリスト
" b:qfixwin_buftype = 0  |  Quickfix List
" b:qfixwin_buftype = 1  |  Location List
" FIXME:QuickFix/場所リスト判定用 (未確認)
if !exists('g:QFixWin_QuickFixTitleReg')
  let g:QFixWin_QuickFixTitleReg = '\cQuickfix\|Liosta Ceartúchán Tapa\|Lista de cambios rápidos\|Listo de rapidriparoj\|Pikakorjausluettelo\|Ñïèñîê áûñòðûõ èñïðàâëåíèé\|Ñïèñîê âèïðàâëåíü\|Список быстрых исправлений\|Список виправлень'
endif
if !exists('g:QFixWin_LocationListTitleReg')
  let g:QFixWin_LocationListTitleReg = '\cLocation\|Liosta Suíomh\|Lista Locazioni\|Lista de locais\|Lista de ubicaciones\|Lista lokacji\|Liste des emplacements\|Listo de lokoj\|Llista de posicions\|Locatielijst\|Location\|Plassliste\|Positionsliste\|Sijaintiluettelo\|Ñïèñîê ì³ñöü\|Ñïèñîê ðàñïîëîæåíèé\|Список місць\|Список расположений\|場所リスト\|是帖 鯉系\|위치 목록'
endif

let g:QFix_Win = -1

let s:QFix_PreviewWin = -1
let s:QFixPreviewfile = ''

let g:QFix_SearchPath = ''
let g:QFix_SelectedLine  = 1
let g:QFix_SelectedLine0 = 1
let g:QFix_SelectedLine1 = 0
let g:QFix_SearchResult = []
let g:QFix_HSPSearchPath = ''

let g:QFix_Disable = 0
let g:QFix_Resize = 1
let g:QFix_PreviewEnableLock = 0

if !exists('g:qfixtempname')
  let g:qfixtempname = tempname()
endif
let s:tempdir = fnamemodify(g:qfixtempname, ':p:h')

augroup QFix
  au!
  au BufWinLeave             * call <SID>QFixBufWinLeave()
  au BufEnter,BufWinEnter    * call <SID>QFixBufEnter()
  au BufLeave                * call <SID>QFixBufLeave()
  au BufEnter,BufLeave       * call <SID>SetUpdatetime()
  au BufWinEnter      quickfix call <SID>QFBufWinEnter()
  au CursorHold              * call <SID>QFPreview()
  au QuickFixCmdPre         c* call <SID>QFixCmdPre(0)
  au QuickFixCmdPre         g* call <SID>QFixCmdPre(0)
  au QuickFixCmdPre         m* call <SID>QFixCmdPre(0)
  au QuickFixCmdPre         v* call <SID>QFixCmdPre(0)
  au QuickFixCmdPre         l* call <SID>QFixCmdPre(1)
  au QuickFixCmdPost  vimgrep* call <SID>QFixSetVimgrepEnv(0)
  au QuickFixCmdPost lvimgrep* call <SID>QFixSetVimgrepEnv(1)
augroup END

""""""""""""""""""""""""""""""
" b:qfixwin_updatetimeが存在すればupdatetimeを設定
function! s:SetUpdatetime()
  if exists('b:qfixwin_updatetime') && b:qfixwin_updatetime
    exe 'setlocal updatetime='.g:QFix_PreviewUpdatetime
  else
    if &updatetime != g:QFix_PreviewUpdatetime
      let g:QFix_DefaultUpdatetime = &updatetime
    endif
    exe 'setlocal updatetime='.g:QFix_DefaultUpdatetime
  endif
endfunction

" CmdPre
function! s:QFixCmdPre(mode)
  exe 'let s:UndoDic'.a:mode.' = []'
  exe 'let g:QFix_SelectedLine'.a:mode.'=1'
  if a:mode != g:QFix_UseLocationList
    return
  endif
  let g:QFix_SearchPath = ''
  let g:QFix_Height = g:QFix_HeightDefault
endfunction

" vimgrep初期化
function! s:QFixSetVimgrepEnv(mode)
  exe 'let s:UndoDic'.a:mode.' = []'
  exe 'let g:QFix_SelectedLine'.a:mode.'=1'
  if a:mode != g:QFix_UseLocationList
    return
  endif
endfunction

" 処理有効化チェック
function! s:QFixEnable(...)
  if (a:0)
    let g:QFixWin_EnableMode = a:1
    return g:QFixWin_EnableMode
  endif
  if &buftype == 'quickfix'
    if !exists('b:qfixwin_buftype')
      call s:QFixSetBuftype()
    endif
    if (b:qfixwin_buftype == 1) && (g:QFixWin_EnableMode == 2)
      return 1
    endif
  endif
  if (g:QFixWin_EnableMode <= 1)
    return g:QFixWin_EnableMode
  endif
  if !exists('b:qfix_enable') || b:qfix_enable == 0
    return 0
  endif
  return 1
endfunction

""""""""""""""""""""""""""""""
" QuickFixウィンドウ
" BufWinEnter
function! s:QFBufWinEnter(...)
  if (s:QFixEnable() == 0)
    return
  endif
  call s:QFixSetBuftype()
  if b:qfixwin_buftype == g:QFix_UseLocationList
    let g:QFix_Win = expand('<abuf>')
  endif

  let g:QFix_HSPSearchPath = getcwd()
  if !exists('g:MyGrep_Key') && !exists('g:QFixHowm_Key')
    let g:QFix_HighSpeedPreview = 0
  endif
  let s:QFixPreviewfile = ''
  if g:QFix_PreviewEnable < 0
    let g:QFix_PreviewEnable = 1
  endif
  if g:QFix_CursorLine
    setlocal cursorline
  else
    setlocal nocursorline
  endif
  setlocal nobuflisted
  setlocal nowrap

  nnoremap <buffer> <silent> q :close<CR>
  call QFixAltWincmdMap()

  if !exists('g:QFix_UseAltCR')
    let g:QFix_UseAltCR = 1
  endif
  if g:QFix_UseAltCR == 1
    nnoremap <buffer> <silent> <CR>   :call <SID>BeforeJump()<CR><CR>:call <SID>AfterJump()<CR>
  elseif g:QFix_UseAltCR == 2
    nnoremap <buffer> <silent> <CR>   :call <SID>BeforeJump()<CR><CR>:call <SID>AfterJump()<CR>
    vnoremap <buffer> <silent> <CR>   :call <SID>VisCR()<CR>
  endif
  nnoremap <buffer> <silent> <S-CR> :call <SID>BeforeJump()<CR>:call <SID>QFixSplit()<CR>:call <SID>AfterJump()<CR>
  if g:QFix_Edit == 'tab'
    nnoremap <buffer> <silent> <S-CR> :call <SID>BeforeJump()<CR>:call <SID>QFixEdit()<CR>:call <SID>AfterJump()<CR>
  endif

  nnoremap <buffer> <silent> i      :<C-u>call <SID>QFixTogglePreview()<CR>
  nnoremap <buffer> <silent> I      :<C-u>call <SID>QFixToggleHighlight()<CR>
  nnoremap <buffer> <silent> &      :<C-u>call <SID>QFixCmd_LocListCopy('normal')<CR>
  vnoremap <buffer> <silent> &      :<C-u>call <SID>QFixCmd_LocListCopy('visual')<CR>
  nnoremap <buffer> <silent> J      :<C-u>call <SID>QFixCmd_J()<CR>
  nnoremap <buffer> <silent> K      :<C-u>call QFixCmd_MRURemove()<CR>
  " nnoremap <buffer> <silent> A      :MyGrepWriteResult<CR>
  " nnoremap <buffer> <silent> O      :MyGrepReadResult<CR>
  nnoremap <buffer> <silent> <C-l>  :<C-u>call <SID>QFixSetqfShortPath()<CR>:exe 'normal! <C-l>'<CR>
  " silent! nnoremap <buffer> <unique> <silent> o :MyGrepWriteResult<CR>

  if b:qfixwin_buftype == g:QFix_UseLocationList
    " ハイスピードモードは使えない
    nnoremap <buffer> <silent> <C-h> :<C-u>call <SID>QFixTogglePreviewMode()<CR>
  endif
  nnoremap <buffer> <silent> r :<C-u>call <SID>QFixSearchStringsR()<CR>
  nnoremap <buffer> <silent> s :<C-u>call <SID>QFixSearchStrings()<CR>
  nnoremap <buffer> <silent> u :<C-u>call <SID>QFixRestoreUndo()<CR>
  nnoremap <buffer> <silent> U :<C-u>call <SID>QFixRestoreUndo('init')<CR>
  " S はQFixMemo/Howm定義を上書きしない
  silent! nnoremap <buffer> <unique> <silent> S :<C-u>call <SID>QFixSortExec()<CR>
  nnoremap <buffer> <silent> dd :call <SID>QFixDelete()<CR>
  nnoremap <buffer> <silent> p  :call <SID>QFixPut(0)<CR>
  nnoremap <buffer> <silent> P  :call <SID>QFixPut(1)<CR>
  vnoremap <buffer> <silent> d  :call <SID>QFixDelete()<CR>

  call s:QFixResize()
  if &buftype == 'quickfix'
    let b:qfixwin_height = winheight(0)
    let b:qfixwin_width  = winwidth(0)
    let g:QFix_Height = b:qfixwin_height
  endif
  if exists("*QFixSetupPost")
    call QFixSetupPost()
  endif
endfunction

function! s:QFixSetBuftype(...)
  if &buftype == 'quickfix' && !exists('b:qfixwin_buftype')
    if v:version > 704 || (v:version == 704 && has('patch2215'))
      let winnum = bufwinnr("%")
      let winfo = getwininfo(win_getid(winnum))[0]
      let b:qfixwin_buftype = (winfo.loclist == 1)
    else
      silent! let info = s:QFixGetBufInfo(bufnr('%'))
      " let b:qfixwin_buftype = info !~ g:QFixWin_QuickFixTitleReg
      let b:qfixwin_buftype = info =~ g:QFixWin_LocationListTitleReg
    endif
  endif
endfunction

function! s:QFixGetBufInfo(...)
  redir => buflist
  buffers!
  redir END
  if a:0
    let buflist = matchstr(buflist, '\(\n\|^\)\s*\zs'.a:1.'[^\n]\+\ze')
  endif
  return buflist
endfunction

function! QFixAltWincmdMap()
  nnoremap <buffer> <silent> <C-w>h     :call <SID>QFixAltWincmd('h')<CR>
  nnoremap <buffer> <silent> <C-w>j     :call <SID>QFixAltWincmd('j')<CR>
  nnoremap <buffer> <silent> <C-w>k     :call <SID>QFixAltWincmd('k')<CR>
  nnoremap <buffer> <silent> <C-w>l     :call <SID>QFixAltWincmd('l')<CR>
  nnoremap <buffer> <silent> <C-w><C-h> :call <SID>QFixAltWincmd('h')<CR>
  nnoremap <buffer> <silent> <C-w><C-j> :call <SID>QFixAltWincmd('j')<CR>
  nnoremap <buffer> <silent> <C-w><C-k> :call <SID>QFixAltWincmd('k')<CR>
  nnoremap <buffer> <silent> <C-w><C-l> :call <SID>QFixAltWincmd('l')<CR>
  let b:qfixwin_updatetime = 1
  exe 'setlocal updatetime='.g:QFix_PreviewUpdatetime
endfunction

function! s:QFixAltWincmd(cmd)
  call QFixPclose(1)
  let cnt = v:count == 0 ? 1 : v:count
  exe cnt.'wincmd '.a:cmd
  return
endfunction

" Quickfix ウィンドウPreview ON/OFF。
function! s:QFixTogglePreview()
  let g:QFix_PreviewEnable = !g:QFix_PreviewEnable
  call QFixPclose(1)
endfunction

" BufEnter
function! s:QFixBufEnter(...)
  if (s:QFixEnable() == 0)
    return
  endif
  if &previewwindow
    if s:QFix_PreviewWin == bufnr('%')
      if winnr('$') == 1
        call QFixPclose()
      else
        let winnum = bufwinnr(g:QFix_Win)
        exe winnum . 'wincmd w'
      endif
    endif
    return
  elseif &buftype == 'quickfix'
    call s:QFixSetBuftype()
    if expand('<abuf>') == g:QFix_Win
      let w = &lines - winheight(0) - &cmdheight - (&laststatus > 0 ? 1 : 0)
      if w > 0
        if exists('b:qfixwin_height') && b:qfixwin_height && g:QFix_Copen_Resize
          exe 'resize '. b:qfixwin_height
        endif
      endif
      if exists('b:qfixwin_width') && b:qfixwin_width && g:QFix_Copen_Resize
        " exe 'vertical resize '. b:qfixwin_width
      endif
      if g:QFix_PreviewEnable > 0
        call QFixPclose()
      endif
      if g:QFix_HighSpeedPreview
        let cmd = g:QFix_UseLocationList ? 'lopen' : 'copen'
        exe cmd
      endif
    endif
  endif
endfunction

" BufLeave
function! s:QFixBufLeave(...)
  if (s:QFixEnable() == 0)
    return
  endif
  if &buftype == 'quickfix'
    exe 'let g:QFix_SelectedLine'.b:qfixwin_buftype.'='.line('.')
    let b:qfixwin_height = winheight(0)
    let b:qfixwin_width  = winwidth(0)
    let g:QFix_Height = b:qfixwin_height
    call QFixPclose()
  endif
endfunction

" BufWinLeave
function! s:QFixBufWinLeave(...)
  if expand('<abuf>') == g:QFix_Win
    let g:QFix_Win = -1
  endif
endfunction

" CursorHold
function! s:QFPreview()
  if (s:QFixEnable() == 0)
    return
  endif
  if g:QFix_PreviewEnable > 0 && &buftype == 'quickfix'
    call QFixPreview()
  endif
endfunction

""""""""""""""""""""""""""""""
" undo/redo
""""""""""""""""""""""""""""""
let s:UndoDic0 = []
let s:UndoDic1 = []
" Quickfixウィンドウ用アンドゥ保存
function! s:QFixSaveUndo(id, qf, lnum)
  let id = a:id
  let lnum = a:lnum
  let path = g:QFix_SearchPath
  let qf = deepcopy(a:qf)
  exe 'call add(s:UndoDic'.id.', [qf, path, lnum])'
endfunction

" Quickfixウィンドウ用アンドゥ
function! s:QFixRestoreUndo(...)
  let type = b:qfixwin_buftype
  exe 'let dic = s:UndoDic'.type
  if len(dic) == 0
    return
  endif
  let idx = a:0 > 0 ? 0 : -1
  let [qf, path, lnum] = dic[idx]
  call s:SetBufqflistOpen(qf)
  if idx == 0
    let dic = []
  else
    call remove(dic, idx)
  endif
  exe 'let s:UndoDic'.type. '= dic'
  call cursor(lnum, 1)
endfunction

""""""""""""""""""""""""""""""
" edit
""""""""""""""""""""""""""""""
function! s:QFixEdit()
  let qfbuf = bufnr('%')
  let qf = QFixGetqflist()
  let bufnum = qf[line('.')-1]['bufnr']
  let lnum = qf[line('.')-1]['lnum']
  let col = qf[line('.')-1]['col']
  let file = fnamemodify(bufname(bufnum), ':p')
  let file = escape(file, ' ')
  if g:QFix_TabEditMode == 1
    call QFixCclose()
  endif
  call QFixEditFile(file)
  if g:QFix_TabEditMode == 1
    call QFixCopen()
    silent! wincmd p
  endif
  return
endfunction

""""""""""""""""""""""""""""""
" split
""""""""""""""""""""""""""""""
function! s:QFixSplit()
  let qfbuf = bufnr('%')
  let h = g:QFix_Height
  let qf = QFixGetqflist()
  let bufnum = qf[line('.')-1]['bufnr']
  let lnum = qf[line('.')-1]['lnum']
  let col = qf[line('.')-1]['col']
  let file = fnamemodify(bufname(bufnum), ':p')
  let winnum = bufwinnr(bufnum)
  if g:QFix_CopenCmd !~ 'vertical'
    exe 'split ' . s:escape(file, ' ')
  else
    if winnum == -1
      let winnr = QFixWinnr()
      if winnr < 1
      else
        exe winnr.'wincmd w'
      endif
      exe 'split ' . s:escape(file, ' ')
    else
      exe winnum.'wincmd w'
      split
    endif
  endif
  call cursor(lnum, col)
endfunction

""""""""""""""""""""""""""""""
" Before <CR>
""""""""""""""""""""""""""""""
function! s:BeforeJump()
  call QFixPclose()
  call QFixCR('before')
  if v:count == 0
    return
  endif
  call cursor(v:count, 1)
endfunction

if !exists('*QFixCR')
function QFixCR(mode)
endfunction
endif

""""""""""""""""""""""""""""""
" After <CR>
""""""""""""""""""""""""""""""
function! s:AfterJump(...)
  exe "normal! zz"
  call QFixCR('after')
  if g:QFix_CloseOnJump
    call QFixCclose()
  endif
endfunction

""""""""""""""""""""""""""""""
" Visual mode <CR>
""""""""""""""""""""""""""""""
function! s:VisCR() range
  let fline = a:firstline
  let lline = a:lastline
  call s:BeforeJump()
  let qf = QFixGetqflist()
  for l in range(fline, lline)
    let bufnr = qf[l-1]['bufnr']
    let lnum  = qf[l-1]['lnum']
    let col   = qf[l-1]['col']
    let file = fnamemodify(bufname(bufnr), ':p')
    call QFixEditFile(file)
    call cursor(lnum, col)
  endfor
  call QFixCR('after')
  if g:QFix_CloseOnJump
    call QFixCclose()
  endif
endfunction

""""""""""""""""""""""""""""""
" 選択中のqflistを取得
""""""""""""""""""""""""""""""
function! s:QFixCmd_LocListCopy(mode) range
  let lastline = line('$')
  let firstline = a:firstline
  if a:firstline != a:lastline || a:mode =~ 'visual'
    let lastline = a:lastline
  else
    let firstline = 1
  endif
  if exists('b:qfixwin_buftype')
    let sq = b:qfixwin_buftype ? getloclist(0) : getqflist()
  else
    let sq = QFixGetqflist()
  endif
  if lastline != line('$')
    call remove(sq, lastline-1, -1)
  endif
  if firstline > 1
    call remove(sq, 0, firstline - 2)
  endif
  call setloclist(0, sq)
  lopen
endfunction

""""""""""""""""""""""""""""""
" ジャンプ後のウィンドウ動作切替
""""""""""""""""""""""""""""""
function! s:QFixCmd_J()
  let g:QFix_CloseOnJump = !g:QFix_CloseOnJump
  echo 'Close on jump : ' . (g:QFix_CloseOnJump? 'ON' : 'OFF')
endfunction

""""""""""""""""""""""""""""""
" K コマンド
""""""""""""""""""""""""""""""
if !exists('*QFixCmd_MRURemove')
function! QFixCmd_MRURemove(...)
endfunction
endif

""""""""""""""""""""""""""""""
" リサイズ
""""""""""""""""""""""""""""""
function! s:QFixResize(...)
  let size = g:QFix_Height
  if exists('b:qfixwin_height') && size < b:qfixwin_height
    let size = b:qfixwin_height
  endif
  if size < g:QFix_HeightDefault
    let size = g:QFix_HeightDefault
  endif
  if a:0
    let size = a:1
  endif
  let w = &lines - winheight(0) - &cmdheight - (&laststatus > 0 ? 1 : 0)
  if w  > 0 && g:QFix_Copen_Resize
    exe 'resize ' . size
  endif
  let g:QFix_Height = size
endfunction

""""""""""""""""""""""""""""""
" ハイスピードプレビューの切替
""""""""""""""""""""""""""""""
function! s:QFixTogglePreviewMode()
  let g:QFix_HighSpeedPreview = !g:QFix_HighSpeedPreview
  echo 'Preview mode : ' . (g:QFix_HighSpeedPreview? 'HighSpeed' : 'Normal')
endfunction

""""""""""""""""""""""""""""""
" Delete
""""""""""""""""""""""""""""""
function! s:QFixDelete() range
  let lnum = line('.')
  let qf = s:GetBufqflist()
  let type = b:qfixwin_buftype
  call s:QFixSaveUndo(type, qf, lnum)
  let l = line('.') - 1
  let g:QFixDelete = []
  for loop in range(a:firstline, a:lastline)
    call add(g:QFixDelete, remove(qf, l))
  endfor
  call s:SetBufqflistOpen(qf)
  silent! exe 'normal! '.lnum.'G'
  return
endfunction

""""""""""""""""""""""""""""""
" put
""""""""""""""""""""""""""""""
let g:QFixDelete = []
function! s:QFixPut(ofs)
  let lnum = line('.')
  let l = line('.') - a:ofs
  let qf = s:GetBufqflist()
  let type = b:qfixwin_buftype
  call s:QFixSaveUndo(type, qf, lnum)
  call extend(qf, g:QFixDelete, l)
  call s:SetBufqflistOpen(qf)
  silent! exe 'normal! '.lnum.'G'
endfunction

""""""""""""""""""""""""""""""
" quickfixソートをトグル
""""""""""""""""""""""""""""""
function! s:QFixSortExec(...)
  let mes = 'Sort type? (r:reverse)+(m:mtime, n:name, t:text) : '
  if a:0
    let pattern = a:1
  else
    let pattern = input(mes, '')
  endif
  if pattern =~ 'r\?m'
    let g:QFix_Sort = substitute(pattern, 'm', 'mtime', '')
  elseif pattern =~ 'r\?n'
    let g:QFix_Sort = substitute(pattern, 'n', 'name', '')
  elseif pattern =~ 'r\?t'
    let g:QFix_Sort = substitute(pattern, 't', 'text', '')
  elseif pattern == 'r'
    let g:QFix_Sort = 'reverse'
  else
    return
  endif
  let type = b:qfixwin_buftype
  if g:QFix_Sort =~ 'mtime'
    let sq = s:QFixSort(g:QFix_Sort)
  elseif g:QFix_Sort =~ 'name'
    let sq = s:QFixSort(g:QFix_Sort)
  elseif g:QFix_Sort =~ 'text'
    let sq = s:QFixSort(g:QFix_Sort)
  elseif g:QFix_Sort =~ 'reverse'
    let sq = QFixGetqflist()
    let qf = s:GetBufqflist()
    let sq = reverse(sq)
  endif
  call s:SetBufqflistOpen(sq)
  call QFixMoveToWin()
  call cursor(1,1)
  redraw|echo 'Sorted by '.g:QFix_Sort.'.'
endfunction

""""""""""""""""""""""""""""""
" quickfixをソート
""""""""""""""""""""""""""""""
let g:QFix_Sort = ''
function! s:QFixSort(cmd)
  let type = b:qfixwin_buftype
  let save_qflist = s:GetBufqflist()
  if a:cmd =~ 'mtime'
    let bname = ''
    let bmtime = 0
    for d in save_qflist
      if exists('d["mtime"]')
        continue
      endif
      if bname == bufname(d.bufnr)
        let d['mtime'] = bmtime
      else
        let d['mtime'] = getftime(bufname(d.bufnr))
      endif
      let bname  = bufname(d.bufnr)
      let bmtime = d.mtime
    endfor
    let save_qflist = sort(save_qflist, "QFixCompareTime")
  elseif a:cmd =~ 'name'
    let save_qflist = sort(save_qflist, "QFixCompareName")
  elseif a:cmd =~ 'text'
    let save_qflist = sort(save_qflist, "QFixCompareText")
  endif
  if a:cmd =~ 'r.*'
    let save_qflist = reverse(save_qflist)
  endif
  let g:QFix_SearchResult = []
  return save_qflist
endfunction

""""""""""""""""""""""""""""""
" quickfix比較
""""""""""""""""""""""""""""""
function! QFixCompareBufnr(v1, v2)
  if a:v1.bufnr == a:v2.bufnr
    return (a:v1.lnum+0 > a:v2.lnum+0?1:-1)
  endif
  return a:v1.bufnr>a:v2.bufnr?1:-1
endfunction
function! QFixCompareName(v1, v2)
  if a:v1.bufnr == a:v2.bufnr
    return (a:v1.lnum+0 > a:v2.lnum+0?1:-1)
  endif
  return (bufname(a:v1.bufnr)> bufname(a:v2.bufnr)?1:-1)
endfunction
function! QFixCompareTime(v1, v2)
  if a:v1.mtime == a:v2.mtime
    if a:v1.bufnr != a:v2.bufnr
      return (bufname(a:v1.bufnr) < bufname(a:v2.bufnr)?1:-1)
    endif
    return (a:v1.lnum+0 > a:v2.lnum+0?1:-1)
  endif
  return (a:v1.mtime < a:v2.mtime?1:-1)
endfunction
function! QFixCompareText(v1, v2)
  if a:v1.text == a:v2.text
    return (bufname(a:v1.bufnr) < bufname(a:v2.bufnr)?1:-1)
  endif
  return (a:v1.text > a:v2.text?1:-1)
endfunction

""""""""""""""""""""""""""""""
" Quickfixウィンドウを文字列で絞り込み。
""""""""""""""""""""""""""""""
function! s:QFixSearchStrings(...)
  if a:0
    let _key = a:1
  else
    let _key = input('Search for pattern : ')
    if _key == ''
      return
    endif
  endif
  let qf = s:GetBufqflist()
  let type = b:qfixwin_buftype
  let lnum = line('.')
  call s:QFixSaveUndo(type, qf, lnum)
  let idx = 0
  for d in qf
    if d['text'] !~ _key && bufname(d['bufnr']) !~ _key
      call remove(qf, idx)
      continue
    endif
    let idx += 1
  endfor
  call s:SetBufqflistOpen(qf)
  let @/=_key
  call s:HighlightSearchWord(1)
  call QFixPclose()
endfunction

""""""""""""""""""""""""""""""
" Quickfixウィンドウを文字列で絞り込み。
""""""""""""""""""""""""""""""
function! s:QFixSearchStringsR(...)
  if a:0
    let _key = a:1
  else
    let _key = input('Search for pattern (exclude) : ')
    if _key == ''
      return
    endif
  endif
  let qf = s:GetBufqflist()
  let type = b:qfixwin_buftype
  let lnum = line('.')
  call s:QFixSaveUndo(type, qf, lnum)

  let idx = 0
  for d in qf
    if d['text'] =~ _key || bufname(d['bufnr']) =~ _key
      call remove(qf, idx)
      continue
    endif
    let idx += 1
  endfor

  call s:SetBufqflistOpen(qf)
  let @/=_key
  call s:HighlightSearchWord(1)
  call QFixPclose()
endfunction

function! s:GetBufqflist()
  if b:qfixwin_buftype
    return getloclist(0)
  else
    return getqflist()
  endif
endfunction

function! s:SetBufqflistOpen(qf, ...)
  let type = b:qfixwin_buftype
  let dir = ''
  if type == g:QFix_UseLocationList
    let dir = g:QFix_SearchPath
  elseif len(a:qf) > 0
    let file = bufname(a:qf[0]['bufnr'])
    let dir = fnamemodify(file, ':p:h')
  endif
  if type
    let qf = setloclist(0, a:qf)
    silent! exe 'chdir ' . s:escape(dir, ' ')
    lopen
  else
    let qf = setqflist(a:qf)
    silent! exe 'chdir ' . s:escape(dir, ' ')
    copen
  endif
  return qf
endfunction

""""""""""""""""""""""""""""""
" searchWord にしたがって、ハイライトを設定する
" searchWordType を見て searchWord の解釈を変える
"  0: 固定文字列
"  1: 正規表現 ( grep )
"  2: 正規表現 ( Vim )
""""""""""""""""""""""""""""""
function! s:HighlightSearchWord(searchWordType)
  let searchWord = @/
  let searchWordType = a:searchWordType
  if searchWord == ''
    return
  endif
  if searchWordType == 0
    let pat = '\c\V' . escape(searchWord, '\')
  elseif searchWordType == 1
    let pat = '\c\v' . escape(searchWord, '=~@%()[]+|')
  elseif searchWordType == 2
    let pat = searchWord
  else
    return
  endif
  silent! syntax clear QFixSearchWord
  hi QFixSearchWord ctermfg=Red ctermbg=Grey guifg=Red guibg=bg
  silent! exe 'syntax match QFixSearchWord display "' . escape(pat, '"') . '"'
endfunction

""""""""""""""""""""""""""""""
" ハイライト切替
""""""""""""""""""""""""""""""
function! s:QFixToggleHighlight()
  let g:QFix_PreviewFtypeHighlight = !g:QFix_PreviewFtypeHighlight
  let s:QFixPreviewfile = ''
  echo 'FileType syntax : ' . (g:QFix_PreviewFtypeHighlight? 'ON' : 'OFF')
endfunction

""""""""""""""""""""""""""""""
" Quickfixウィンドウへ移動
""""""""""""""""""""""""""""""
function! QFixMoveToWin(...)
  if a:0
    let g:QFix_UseLocationList = !g:QFix_UseLocationList
  endif
  let winnum = bufwinnr(g:QFix_Win)
  if (winnum == -1 || a:0)
    if a:0 && g:QFix_PreviewEnable == 1
      call QFixPclose()
    endif
    call QFixCopen()
  else
    if winnum != winnr()
      exe winnum . 'wincmd w'
    else
      call s:ResizeOnQFix()
      if a:0
        let g:QFix_UseLocationList = !g:QFix_UseLocationList
      endif
      return
    endif
  endif
  call s:QFixResize()
  if a:0
    let g:QFix_UseLocationList = !g:QFix_UseLocationList
  endif
endfunction

""""""""""""""""""""""""""""""
" Quickfixウィンドウのトグル
""""""""""""""""""""""""""""""
function! QFixToggleWin(...)
  if bufnr('%') == g:QFix_Win
    close
    return
  endif
  let winnr = bufwinnr(g:QFix_Win)
  if winnr != -1
    let bufnr = bufnr('%')
    call QFixPclose()
    let winnr = bufwinnr(g:QFix_Win)
    exe winnr . 'wincmd w'
    close
    let winnr = bufwinnr(bufnr)
    exe winnr . 'wincmd w'
    return
  elseif &buftype == 'quickfix'
    call QFixPclose()
    let winnr = QFixWinnr()
    if winnr < 1
      close
      return
    else
      exe winnr.'wincmd w'
    endif
  endif
  call QFixCopen()
endfunction

""""""""""""""""""""""""""""""
" サイズを変更する
""""""""""""""""""""""""""""""
function! s:ResizeOnQFix(...)
  if &buftype != 'quickfix'
    return
  endif
  let size = g:QFix_HeightDefault
  if v:count > 1
    let size = v:count
  endif
  call s:QFixResize(size)
endfunction

""""""""""""""""""""""""""""""
" copen代替
" CAUTION: cclose/copenでバッファ番号が変わるので b: は実質的に保存されない
""""""""""""""""""""""""""""""
function! QFixCopen(...)
  if g:QFix_Disable
    return
  endif
  if &buftype == 'quickfix'
    let b:qfixwin_height = winheight(0)
    let b:qfixwin_width  = winwidth(0)
    let g:QFix_Height = b:qfixwin_height
  endif
  let qf = QFixGetqflist()
  let idx = len(qf)
  if idx == 0
    echohl ErrorMsg
    if g:QFix_UseLocationList
      redraw|echom 'QFixWin : no location list'
    else
      redraw|echom 'QFixWin : no list'
    endif
    echohl None
    return
  endif
  let prevPath = s:escape(getcwd(), ' ')
  if a:0 && a:1 != ''
    let cmd = a:1
  else
    let cmd = g:QFix_CopenCmd
    if exists('g:QFix_CopenCmd'.g:QFix_UseLocationList)
      exe 'let cmd = g:QFix_CopenCmd'.g:QFix_UseLocationList
    endif
  endif
  let cmd = cmd . (g:QFix_UseLocationList ? ' l' : ' c')
  let saved_pe = g:QFix_PreviewEnable
  let g:QFix_PreviewEnable = 0
  call QFixPclose()
  silent! exe cmd . 'open ' . g:QFix_Height
  let b:qfixwin_buftype = g:QFix_UseLocationList
  let b:qfix_enable = 1
  call s:QFixSetBuftype()
  if !exists('b:QFix_SearchPath')
    if exists('g:QFix_SearchPath'.b:qfixwin_buftype)
      exe 'let b:QFix_SearchPath=g:QFix_SearchPath'.b:qfixwin_buftype
    else
      exe 'let b:QFix_SearchPath=g:QFix_SearchPath'
    endif
    let b:QFix_SearchPath = QFixNormalizePath(fnamemodify(b:QFix_SearchPath, ':p:h'))
    " let b:QFix_SearchPath = ''
  endif

  let spath = ''
  if g:QFix_SearchPathMode == 1
    if !s:SetSearchPath(qf, g:QFix_SearchPath, cmd.'open '.g:QFix_Height)
      let spath = QFixNormalizePath(fnamemodify(g:QFix_SearchPath, ':p:h'))
    endif
  elseif g:QFix_SearchPathMode == 2
    let spath = QFixGetqfRootPath(qf)
    if spath != ''
      silent! exe 'chdir ' . s:escape(spath, ' ')
      silent! exe cmd . 'open ' . g:QFix_Height
    endif
  endif
  if b:QFix_SearchPath != spath
    exe 'let g:QFix_SelectedLine'.b:qfixwin_buftype. '=1'
  endif
  exe 'let lnum=g:QFix_SelectedLine'.b:qfixwin_buftype
  call cursor(lnum, 1)
  silent! exe 'normal! zz'
  let b:QFix_SearchPath = spath
  exe 'let g:QFix_SearchPath'.b:qfixwin_buftype.'=b:QFix_SearchPath'
  let g:QFix_Win = bufnr('%')
  if g:QFix_Width > 0 && g:QFix_Copen_Resize
    exe "vertical resize ".g:QFix_Width
  endif
  let g:QFix_PreviewEnable = saved_pe
  let &winfixheight = g:QFix_Copen_winfixheight
  let &winfixwidth  = g:QFix_Copen_winfixwidth
  silent! exe 'chdir ' . prevPath
endfunction

" Windowsパス正規化
let s:MSWindows = has('win95') + has('win16') + has('win32') + has('win64')
function! QFixNormalizePath(path, ...)
  let path = a:path
  if s:MSWindows
    if a:0 " 比較しかしないならキャピタライズ
      let path = toupper(path)
    else
      " expand('~') で展開されるとドライブレターは大文字、
      " expand('c:/')ではそのままなので統一
      let path = substitute(path, '^\([a-z]\):', '\u\1:', '')
    endif
    let path = substitute(path, '\\', '/', 'g')
  endif
  " let path = expand(a:path)
  return path
endfunction

" パス表示を短くする
function! s:QFixSetqfShortPath()
  if &buftype != 'quickfix'
    return
  endif
  redraw|echo 'QFixWin : Search root path...'
  let qf = b:qfixwin_buftype ? getloclist(0) : getqflist()
  let wh = winheight(0)
  let spath = QFixGetqfRootPath(qf)
  let cmd = b:qfixwin_buftype ? 'l' : 'c'
  if spath != ''
    silent! exe 'chdir ' . s:escape(spath, ' ')
    silent! exe cmd . 'open '
    let w = &lines - winheight(0) - &cmdheight - (&laststatus > 0 ? 1 : 0)
    if w > 0 && &buftype == 'quickfix' && g:QFix_Copen_Resize
      exe 'resize '. wh
      " exe 'vertical resize '. ww
    endif
  endif
endfunction

" パス表示を最も短くするディレクトリを探す
function! QFixGetqfRootPath(qf)
  if len(a:qf) == 0
    return ''
  endif
  if exists('+shellslash')
    let saved_ssl = &shellslash
    set shellslash
  endif
  let qf = deepcopy(a:qf)
  let pbuf = -1
  for n in qf
    if bufexists(n['bufnr'])
      let pbuf = n['bufnr']
      break
    endif
  endfor
  if pbuf == -1
    return ''
  endif
  let qf = sort(qf, "QFixCompareBufnr")
  let spath = fnamemodify(bufname(qf[0]['bufnr']), ':p:h')
  for n in qf
    if n['bufnr'] == pbuf
      continue
    endif
    let pbuf = n['bufnr']
    let path = fnamemodify(bufname(pbuf), ':p:h')
    let head = spath
    let slen = strlen(head)
    while 1
      if path =~ '^\V'.head
        let spath = head
        break
      endif
      let head = fnamemodify(head, ':h')
      let hlen = strlen(head)
      if hlen == slen
        break
      endif
      let slen = hlen
    endwhile
  endfor
  if exists('+shellslash')
    let &shellslash = saved_ssl
  endif
  return spath
endfunction

function! s:SetSearchPath(qf, path, ...)
  let prevPath = s:escape(getcwd(), ' ')
  silent! exe 'chdir ' . s:escape(a:path, ' ')
  if a:0
    let cmd = a:1
  else
    let cmd = 'copen'
  endif
  silent! exe cmd
  " 登録されている半分のファイルが path以下になかったらクリア
  let none = len(a:qf) / 2 +1
  for n in a:qf
    let file = bufname(n['bufnr'])
    if file =~ '^\([\\/~:]\|[A-Za-z]:\)'
      let none -= 1
    endif
    if none < 1
      break
    endif
  endfor
  if none <= 0
    silent! exe 'chdir ' . prevPath
    silent! exe cmd
  endif
  return none <= 0
endfunction

""""""""""""""""""""""""""""""
" cclose代替
""""""""""""""""""""""""""""""
function! QFixCclose()
  if g:QFix_Disable
    return
  endif
  if g:QFix_UseLocationList
    silent! lclose
  else
    silent! cclose
  endif
endfunction

""""""""""""""""""""""""""""""
" setqflist代替
"""""""""""""""""""""""""""""
function! QFixSetqflist(sq, ...)
  let wh = winheight(0)
  let ww = winwidth(0)
  let cmd = 'a:sq'. (a:0 == 0 ? '' : ",'".a:1."'")
  if g:QFix_UseLocationList
    exe 'call setloclist(0, '.cmd.')'
  else
    exe 'call setqflist('.cmd.')'
  endif
  let w = &lines - winheight(0) - &cmdheight - (&laststatus > 0 ? 1 : 0)
  if w > 0 && &buftype == 'quickfix' && g:QFix_Copen_Resize
    exe 'resize '. wh
    exe 'vertical resize '. ww
  endif
endfunction

""""""""""""""""""""""""""""""
" getqflist代替
""""""""""""""""""""""""""""""
function! QFixGetqflist()
  if g:QFix_UseLocationList
    return getloclist(0)
  else
    return getqflist()
  endif
endfunction

""""""""""""""""""""""""""""""
" pclose代替
""""""""""""""""""""""""""""""
function! QFixPclose(...)
  if g:QFix_Disable && !a:0
    return
  endif
  if g:QFix_PreviewEnable < 1 && !a:0
    return
  endif
  if g:QFix_PreviewEnableLock == 1 && !a:0
    return
  endif
  let s:UseQFixPreviewOpen = 0
  if winnr('$') == 2 && tabpagenr('$') > 1 && g:QFix_PreviewEnable
  elseif winnr('$') == 1 && tabpagenr('$') > 1 && &previewwindow
    tabclose
  else
    let saved_winfixheight = &winfixheight
    let saved_winfixwidth  = &winfixwidth
    let wh = winheight(0)
    let ww = winwidth(0)
    setlocal winfixheight
    setlocal winfixwidth
    silent! pclose!
    let &winfixheight = saved_winfixheight
    let &winfixwidth  = saved_winfixwidth
    let w = &lines - winheight(0) - &cmdheight - (&laststatus > 0 ? 1 : 0)
    if w > 0 && g:QFix_Copen_Resize
      exe 'resize '.wh
      " exe 'vertical resize '.ww
    endif
  endif
  let s:UseQFixPreviewOpen = 1
endfunction

""""""""""""""""""""""""""""""
" Quickfixプレビュー。
""""""""""""""""""""""""""""""
let s:UseQFixPreviewOpen = 1

function! QFixPreview()
  if g:QFix_PreviewEnable < 1
    return
  endif
  let file = ''
  if g:QFix_HighSpeedPreview
    let gfile = s:QFixGetHSP('file')
    let lnum = s:QFixGetHSP('lnum')
    let file = fnamemodify(gfile, ':p')
    if !filereadable(file)
      let file = ''
    endif
  endif
  if file == ''
    let saved_ul = g:QFix_UseLocationList
    let g:QFix_UseLocationList = b:qfixwin_buftype
    let qf = QFixGetqflist()
    let g:QFix_UseLocationList = saved_ul
    let cline = line('.')
    if cline > len(qf)
      return
    endif
    let cline -= 1
    let buf = qf[cline]['bufnr']
    let lnum = qf[cline]['lnum']
    if buf == 0
      let file = ''
    elseif bufexists(buf + 0) != 0
      let file = bufname(buf)
    else
      let file = qf[cline]['filename']
    endif
    let file = fnamemodify(file, ':p')
  endif
  if s:UseQFixPreviewOpen
    call QFixPreviewOpen(file, lnum)
  endif
  return
endfunction

" Quickfixプレビュー本体。
function! QFixPreviewOpen(file, line, ...)
  if g:QFix_Disable
    return
  endif
  let file = a:file
  let file = substitute(file, '\s$', '', '')
  if s:QFixPreviewfile == file
    silent! wincmd P
    if &previewwindow
      if a:line == line('.')
        silent! wincmd p
        return
      endif
      silent! exe 'normal! '. a:line .'Gzz'
      if g:QFix_PreviewCursorLine
        setlocal cursorline
      else
        setlocal nocursorline
      endif
      silent! wincmd p
      return
    endif
  endif
  let s:QFixPreviewfile = file
  if &previewwindow
  else
    let saved_winfixheight = &winfixheight
    let saved_winfixwidth  = &winfixwidth
    " setlocal winfixheight
    " setlocal winfixwidth
    silent! exe 'silent! '.g:QFix_PreviewOpenCmd.' pedit! '.s:tempdir.'/'.g:QFix_PreviewName
    let &winfixheight = saved_winfixheight
    let &winfixwidth  = saved_winfixwidth
  endif
  silent! wincmd P
  let s:QFix_PreviewWin = bufnr('%')
  " set options
  let &wrap = g:QFix_PreviewWrap
  setlocal nofoldenable
  setlocal nobuflisted
  setlocal noswapfile
  setlocal buftype=nofile
  setlocal bufhidden=delete
  let &winfixheight = g:QFix_Preview_winfixheight
  let &winfixwidth  = g:QFix_Preview_winfixwidth
  if g:QFix_PreviewWidth > 0
    exe "vertical resize ".g:QFix_PreviewWidth
  endif
  if exists('g:QFix_PreviewHeight')
    exe 'resize '.g:QFix_PreviewHeight
  endif
  setlocal modifiable
  silent! %delete _
  if g:QFix_PreviewExclude != '' && file =~ g:QFix_PreviewExclude
    setlocal nomodifiable
    silent! wincmd p
    return
  endif

  let prevPath = s:escape(getcwd(), ' ')
  if g:QFix_SearchPath != ''
    silent! exe 'chdir ' . s:escape(g:QFix_SearchPath, ' ')
  endif

  syntax clear
  if g:QFix_PreviewFtypeHighlight != 0
    let qffile = file !~ '|' ? file : bufname(substitute(file, '|', '', 'g')+0)
    call s:QFixFtype_(qffile)
    " BufReadの副作用への安全策
    silent! %delete _
    setlocal nofoldenable
  else
    silent! call s:HighlightSearchWord(1)
  endif
  if bufloaded(file) "バッファが存在する場合
    if filereadable(file) && getfsize(file) > g:QFix_PreviewFileSize
      let glist = readfile(file, '', 1)
      call add(glist, '--- large file ---')
    else
      let glist = getbufline(file, 1,'$')
    endif
    call setline(1, glist)
  elseif file =~ '|$'
    let glist = getbufline(substitute(file, '|', '', 'g')+0, 1, '$')
    if len(glist) > g:QFix_PreviewFileSize
      call add(glist, '--- large file ---')
    else
      call setline(1, glist)
    endif
  else
    let cmd = '-r '
    let file = substitute(file, '\\', '/', 'g')
    let cmd = cmd . QFixPreviewReadOpt(file)
    if filereadable(file)
      if getfsize(file) > g:QFix_PreviewFileSize
        let glist = readfile(file, '', 1)
        call add(glist, '--- large file ---')
        call setline(1, glist)
        setlocal nomodifiable
        silent! wincmd p
        return
      endif
      if g:QFix_PreviewExcludeLineRegxp != ''
        let glist = readfile(file, '', 1)
        if len(glist) == 0 || glist[0] =~ g:QFix_PreviewExcludeLineRegxp
          call setline(1, glist)
          call setline(2, ['--- This file is encrypted ---'])
          setlocal nomodifiable
          silent! wincmd p
          return
        endif
      endif
      silent! exe cmd.' '.s:escape(file, '| ')
      silent! $delete _
    endif
  endif
  silent! exe 'normal! '. a:line .'Gzz'
  if g:QFix_PreviewCursorLine
    setlocal cursorline
  else
    setlocal nocursorline
  endif
  setlocal nomodifiable
  silent! exe 'chdir ' . prevPath
  silent! wincmd p
endfunction

" プレビューのエンコーディング強制オプション
if !exists('*QFixPreviewReadOpt')
function QFixPreviewReadOpt(file)
  return ''
endfunction
endif

""""""""""""""""""""""""""""""
" filetypeを返す
" プレビュー用ファイルタイプ指定
""""""""""""""""""""""""""""""
function! s:QFixFtype_(file)
  if exists('g:QFix_PreviewFtype')
    let suffix = fnamemodify(a:file, ':e')
    silent! let pft = g:QFix_PreviewFtype[suffix]
    if exists('pft')
      silent! exe 'setlocal filetype='.pft
      return pft
    endif
  endif
  let file = fnamemodify(a:file, ':t')
  "for QFixHowm
  if !QFixFtype(a:file)
    exe 'silent! doau BufNewFile '.file
  endif
  return ''
endfunction

if !exists('*QFixFtype')
function QFixFtype(file)
  return 0
endfunction
endif

""""""""""""""""""""""""""""""
" quickfixからファイル名を取り出し。
""""""""""""""""""""""""""""""
function! QFixGet(cmd, ...)
  let desc = a:cmd
  if a:cmd == 'file'
    let desc = 'filename'
  endif
  let qf = QFixGetqflist()
  let cline = line('.')
  if a:0 > 0
    let cline = a:1
  endif
  if cline > len(qf)
    return
  endif
  let cline -= 1
  if a:cmd == 'file'
    let buf = qf[cline]['bufnr']
    let file = fnamemodify(bufname(buf), ':p')
    let file = substitute(file, '\\', '/', 'g')
    return file
  endif
  if a:cmd == 'lnum'
    return qf[cline]['lnum']
  endif
  let cnum  = str2nr(substitute(matchstr(line, ' [0-9]\+|'), '|', '', ''))
  if a:cmd == 'cnum'
    return qf[cline]['col']
  endif
  return qf[cline]['text']
endfunction

""""""""""""""""""""""""""""""
" quickfixからファイル名を取り出し(ハイスピードプレビュー用)
""""""""""""""""""""""""""""""
function! s:QFixGetHSP(cmd, ...)
  let line  = getline('.')
  if a:0
    let line  = a:1
  endif
  let fname = substitute(matchstr(line, '^[^|]*'), '\\', '/', 'g')
  let line  = matchstr(line, '^[^|]*|.*|')
  let lnum  = str2nr(substitute(matchstr(line, '|[0-9]\+'), '|', '', ''))
  if a:cmd == 'file'
    let fname = substitute(fname, '\\', '/', 'g')
    return fname
  endif
  if a:cmd == 'lnum'
    return lnum
  endif
  let cnum  = str2nr(substitute(matchstr(line, ' [0-9]\+|'), '|', '', ''))
  if a:cmd == 'cnum'
    return cnum
  endif
  return substitute(line, '^\(.*\d\+\s*|\)\{-1}', '', '') == e.title
endfunction

""""""""""""""""""""""""""""""
" ファイルが存在するので開く
" 追加パラメータが'split'ならスプリットで開く
""""""""""""""""""""""""""""""
function! QFixEditFile(file, ...)
  let file = expand(a:file)
  let file = substitute(file, '\\', '/', 'g')
  let mode = a:0 > 0 ? a:1 : ''
  let opt  = a:0 > 1 ? a:2 : ''
  let winnum = bufwinnr(file)
  if winnum == winnr()
    return
  endif
  if winnum != -1
    exe winnum . 'wincmd w'
    return
  endif

  let winnr = QFixWinnr()
  if winnr < 1 || mode == 'split'
    split
  else
    exe winnr.'wincmd w'
  endif

  let dir = fnamemodify(file, ':h')
  if isdirectory(dir) == 0
    call mkdir(dir, 'p')
  endif
  exe g:QFix_Edit.'edit ' . opt . s:escape(file, ' ')
endfunction

""""""""""""""""""""""""""""""
" 通常バッファを返す
" 通常バッファがない場合は-1を返す
""""""""""""""""""""""""""""""
function! QFixWinnr()
  let g:QFix_PreviewEnableLock = 1
  let pwin = winnr()
  let max = winnr('$')
  let hidden = &hidden
  let w = -1
  for i in range(1, max)
    exe i . 'wincmd w'
    if &buftype == '' && &previewwindow == 0
      if &modified == 0
        let w = i
        break
      endif
      if g:QFix_UseModifiedWindow && hidden
        let w = i
      endif
    endif
  endfor
  exe pwin.'wincmd w'
  let g:QFix_PreviewEnableLock = 0
  return w
endfunction

""""""""""""""""""""""""""""""
" grepした結果を保存する
""""""""""""""""""""""""""""""
let s:result = []
let s:resulttime = 0
let s:resultpath = ''
" 現在登録されているGrep結果を保存するファイル
if !exists('g:MyGrep_Resultfile')
  let g:MyGrep_Resultfile = '~/.qfgrep.txt'
endif

function! s:MyGrepWriteResult(mode, file) range
  let file = expand(g:MyGrep_Resultfile)
  if v:count
    let file = substitute(file, '\(\.[^.]\+$\)', v:count.'\1', '')
  endif
  if a:file != ''
    let file = a:file
  endif
  " let file = fnamemodify(file, ':p')
  let firstline = 1
  let cnt = line('$')-1
  let s:result = []
  "let dir = g:QFix_SearchPath
  let dir = getcwd()
  call add(s:result, dir . '|'.line('.').'|')
  for d in range(firstline, firstline+cnt)
    let text = getline(d)
    if text == ''
      continue
    endif
    let fname = substitute(text, '|.*$', '', '')
    let fname = fnamemodify(fname, ':p')
    let text = fname . matchstr(text, '|.*')
    let s:result = add(s:result, text)
  endfor
  call writefile(s:result, file)
  call remove(s:result, 0)
  let s:resultpath = g:QFix_SearchPath
  let s:resulttime = getftime(file)
  redraw|echo 'QFixGrep : WriteResult "'.file.'"'
endfunction

""""""""""""""""""""""""""""""
" grepした結果を読み込む
""""""""""""""""""""""""""""""
function! s:MyGrepReadResult(readflag, ...)
  let file = expand(g:MyGrep_Resultfile)
  if a:0 > 1
    let file = a:2
  endif
  if v:count
    let file = substitute(file, '\(\.[^.]\+$\)', v:count.'\1', '')
  endif
  if a:readflag
    let s:resulttime = 0
  endif
  let s:resulttime = 0
  if !filereadable(file)
    return
  endif
  let lnum = 1
  if s:resulttime != getftime(file)
    let s:result = readfile(file)
    let s:resultpath = substitute(s:result[0], '|.*$', '','')
    let g:QFix_SearchPath = s:resultpath
    let lnum = matchstr(s:result[0], '|\d\+')
    let lnum = substitute(lnum, '|', '','g')
    call remove(s:result, 0)
    let s:resulttime = getftime(file)
  endif
  redraw|echo 'QFixGrep : Loading...'
  let qf = []
  for str in s:result
    let file = substitute(str, '|.*$', '','')
    let lnum = str2nr(matchstr(str, '|\zs\d\+'))
    let text = substitute(str, '^.\{-}|.\{-}|', '', '')
    call add(qf, {'filename' : file, 'lnum' : lnum, 'text' : text})
  endfor
  call QFixSetqflist(qf)
  redraw|echo 'QFixGrep : ReadResult "'.file.'"'
  call QFixCopen()
  call QFixMoveToWin()
  call cursor(lnum, 1)
endfunction

function! s:escape(str, chars)
  return escape(a:str, a:chars.((has('win32')|| has('win64')) ? '#%&' : '#%$'))
endfunction

