"=============================================================================
"    Description: QFixMemo
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home  (Japanese)
"=============================================================================
let s:version = 100
scriptencoding utf-8

if exists('g:disable_qfixmemo') && g:disable_qfixmemo == 1
  finish
endif
if exists('g:qfixmemo_version') && g:qfixmemo_version < s:version
  let g:loaded_qfixmemo = 0
endif
if exists('g:loaded_qfixmemo') && g:loaded_qfixmemo && !exists('g:fudist')
  finish
endif
let g:qfixmemo_version = s:version
let g:loaded_qfixmemo = 1
if v:version < 700 || &cp
  finish
endif
let s:debug = exists('g:fudist') ? g:fudist : 0

""""""""""""""""""""""""""""""
" options
""""""""""""""""""""""""""""""
" キーマップリーダー
if !exists('g:qfixmemo_mapleader')
  let g:qfixmemo_mapleader     = 'g,'
endif
" デフォルトキーマップを有効
if !exists('g:qfixmemo_default_keymap')
  let g:qfixmemo_default_keymap = 1
endif

if !exists('g:qfixmemo_dir')
  let g:qfixmemo_dir           = '~/qfixmemo'
endif
if !exists('g:qfixmemo_fileencoding')
  let g:qfixmemo_fileencoding  = &enc
endif
if !exists('g:qfixmemo_fileformat')
  let g:qfixmemo_fileformat    = &ff
endif

" タイトルマーカー
if !exists('g:qfixmemo_title')
  let g:qfixmemo_title         = '='
endif
" ファイルタイプ
if !exists('g:qfixmemo_filetype')
  let g:qfixmemo_filetype      = 'qfix_memo'
endif
" ファイルエンコーディング強制
if !exists('g:qfixmemo_forceencoding')
  let g:qfixmemo_forceencoding = 1
endif
" BOMを自動変換
if !exists('g:qfixmemo_nobomb')
  let g:qfixmemo_nobomb        = 1
endif

" QFixMemoのシンタックスハイライト設定
" 0001 : タイトル行
" 0010 : キーワード
" 0100 : タイムスタンプ
" 1000 : デフォルトシンタックス
" 0000 : 設定しない
" 上記を組み合わせて指定する
if !exists('g:qfixmemo_syntax_flag')
  let g:qfixmemo_syntax_flag = '1111'
endif
" デフォルトシンタックスファイル
if !exists('g:qfixmemo_syntax_file')
  let g:qfixmemo_syntax_file = 'howm_schedule.vim'
endif

" 新規メモファイル名
if !exists('g:qfixmemo_filename')
  let g:qfixmemo_filename      = '%Y/%m/%Y-%m-%d-%H%M%S'
endif
" ファイル名指定で任意ファイルを作成する際のファイル名/ディレクトリ
if !exists('g:qfixmemo_misc_file')
  let g:qfixmemo_misc_file     = '%Y/%m/'
endif
" メモファイルの拡張子(qfixmemo_filenameから設定)
if !exists('g:qfixmemo_ext')
  let g:qfixmemo_ext = fnamemodify(g:qfixmemo_filename, ':e')
  let g:qfixmemo_ext = g:qfixmemo_ext != '' ? g:qfixmemo_ext : 'txt'
endif
" クイックメモファイル名
if !exists('g:qfixmemo_quickmemo')
  let g:qfixmemo_quickmemo     = 'Qmem-00-0000-00-00-000000'
endif
" 日記ファイル名
if !exists('g:qfixmemo_diary')
  let g:qfixmemo_diary         = 'diary/%Y/%m/%Y-%m-%d'
endif
" ペアファイルの作成先ディレクトリ
if !exists('g:qfixmemo_pairfile_dir')
  let g:qfixmemo_pairfile_dir  = 'pairfile'
endif

function! s:QFixMemoSetTimeFormatRegxp(fmt)
  let regxp = a:fmt
  let regxp = escape(regxp, '[]~*.#')
  let regxp = substitute(regxp, '\C%Y', '\\d\\{4}', 'g')
  let regxp = substitute(regxp, '\C%m', '[0-1]\\d', 'g')
  let regxp = substitute(regxp, '\C%d', '[0-3]\\d', 'g')
  let regxp = substitute(regxp, '\C%H', '[0-2]\\d', 'g')
  let regxp = substitute(regxp, '\C%M', '[0-5]\\d', 'g')
  let regxp = substitute(regxp, '\C%S', '[0-5]\\d', 'g')
  let regxp = substitute(regxp, '\C%a', '\\(Sun\\|Mon\\|Tue\\|Wed\\|Thu\\|Fri\\|Sat\\|日\\|月\\|火\\|水\\|木\\|金\\|土\\)', 'g')
  return regxp
endfunction

" タイムスタンプ(strftime)
if !exists('g:qfixmemo_timeformat')
  let g:qfixmemo_timeformat = '[%Y-%m-%d %H:%M]'
endif
" タイムスタンプ(strftime)
if !exists('g:qfixmemo_dateformat')
  let g:qfixmemo_dateformat = '[%Y-%m-%d]'
endif
" qfixmemo#UpdateTime()でタイムスタンプの置換に使用する正規表現(Vim)
if !exists('g:qfixmemo_timeformat_regxp')
  let g:qfixmemo_timeformat_regxp = '^'.s:QFixMemoSetTimeFormatRegxp(g:qfixmemo_timeformat)
endif
" qfixmemo#UpdateTime()でタイムスタンプ行とみなす正規表現(Vim)
" 通常はqfixmemo_timeformat_regxpと同じ正規表現を指定
" 行内にタイムスタンプが含まれているが、タイムスタンプ行でない行を排除するため
" にある
if !exists('g:qfixmemo_timestamp_regxp')
  let g:qfixmemo_timestamp_regxp = g:qfixmemo_timeformat_regxp
endif
" qfixmemo#AddTitle()で擬似タイトル行とみなす正規表現(Vim)
" ファイルの一行目が特定の文字列で始まっていたらタイトル行やタイムスタンプの付
" 加を行いたくない場合に使用する
if !exists('g:qfixmemo_alt_title_regxp')
  let g:qfixmemo_alt_title_regxp = ''
endif

" 新規エントリテンプレート
if !exists('g:qfixmemo_template')
  let g:qfixmemo_template = [
    \'%TITLE% ',
    \""
  \]
endif
if !exists('g:qfixmemo_template_keycmd')
  let g:qfixmemo_template_keycmd = "$a"
endif
if !exists('g:qfixmemo_template_tag')
  let g:qfixmemo_template_tag    = ''
endif

" 最近更新したエントリ一覧の日数
if !exists('g:qfixmemo_recentdays')
  let g:qfixmemo_recentdays = 10
endif

" 最近のタイムスタンプ一覧の日数
if !exists('g:qfixmemo_timestamp_recentdays')
  let g:qfixmemo_timestamp_recentdays = 5
endif

" メニューバーへ登録
if !exists('g:qfixmemo_menubar')
  let g:qfixmemo_menubar = 1
endif

" フォールディング有効
if !exists('g:qfixmemo_folding')
  let g:qfixmemo_folding = 1
endif
" フォールディングパターン
if !exists('g:qfixmemo_folding_pattern')
  let g:qfixmemo_folding_pattern = '^=[^=]'
endif

" 自動タイトル行の文字数
if !exists('g:qfixmemo_title_length')
  let g:qfixmemo_title_length = 64
endif

" grep時にカーソル位置の単語を拾う
if !exists('g:qfixmemo_grep_cword')
  let g:qfixmemo_grep_cword = 1
endif

" 連結表示のセパレータ
if !exists('g:qfixmemo_separator')
  let g:qfixmemo_separator = '>>> %s'
endif

" howm_schedule.vimを使用する
" 0 : 使用しない
" 1 : autoload読込
" 2 : 起動時読込
if !exists('g:qfixmemo_use_howm_schedule')
  let g:qfixmemo_use_howm_schedule = 1
endif

" オートタイトル
if !exists('g:qfixmemo_use_addtitle')
  let g:qfixmemo_use_addtitle = 1
endif
" オートタイムスタンプ
if !exists('g:qfixmemo_use_addtime')
  let g:qfixmemo_use_addtime = 1
endif
" タイムスタンプアップデート
if !exists('g:qfixmemo_use_updatetime')
  let g:qfixmemo_use_updatetime = 0
endif
" ファイル末の空行を削除
if !exists('g:qfixmemo_use_deletenulllines')
  let g:qfixmemo_use_deletenulllines = 1
endif

" スイッチアクションの最大数
if !exists('g:qfixmemo_switch_action_max')
  let g:qfixmemo_switch_action_max = 8
endif

" ランダム表示保存ファイル
if !exists('g:qfixmemo_random_file')
  let g:qfixmemo_random_file = '~/.qfixmemo-random'
endif
" ランダム表示ファイル更新時間(日数)
if !exists('g:qfixmemo_random_time')
  let g:qfixmemo_random_time = 10
endif
" ランダム表示数
if !exists('g:qfixmemo_random_columns')
  let g:qfixmemo_random_columns = 10
endif
" ランダムに表示しない正規表現
if !exists('g:qfixmemo_random_exclude')
  let g:qfixmemo_random_exclude = ''
endif

" リネームで使用するファイル名の長さ
if !exists('g:qfixmemo_rename_length')
  let g:qfixmemo_rename_length = len(strftime(g:qfixmemo_filename))
endif

" QFixMemoファイル作成時のコマンド
if !exists('g:qfixmemo_editcmd')
  let g:qfixmemo_editcmd = ''
endif
if !exists('g:qfixmemo_splitmode')
  let g:qfixmemo_splitmode = 0
endif

" エントリ一覧表示にキャッシュを使用する
if !exists('g:qfixmemo_qfixlist_cache')
  let g:qfixmemo_qfixlist_cache = 1
endif

" エントリ一覧表示のコマンド
if !exists('g:qfixmemo_qfixlist_cmd')
  let g:qfixmemo_qfixlist_cmd = 'open'
endif

" 自動生成ファイル名(,W ,X)
if !exists('g:qfixmemo_auto_generate_filename')
  let g:qfixmemo_auto_generate_filename = '%Y-%m-%d-%H%M%S'
endif

" リストスイッチアクション
if !exists('g:qfixmemo_swlist_action')
  let qfixmemo_swlist_action = ['{ }', '{-}', '{*}']
endif

let s:howm_ext = 'howm'
" 常にqfixmemoファイルとして扱うファイルの正規表現
if !exists('g:qfixmemo_isqfixmemo_regxp')
  let g:qfixmemo_isqfixmemo_regxp = '\c\.'.s:howm_ext.'$'
endif

" howmlinkを使用する
if !exists('g:qfixmemo_use_howmlink')
  let g:qfixmemo_use_howmlink = 1
endif

if g:qfixmemo_use_howmlink
  " howm goto link
  if !exists('g:howm_glink_pattern')
    let g:howm_glink_pattern = '>>>'
  endif
  " howm come-fromリンク
  if !exists('g:howm_clink_pattern')
    let g:howm_clink_pattern = '<<<'
  endif
endif

" QFixWinでの<CR>を独自処理する
if !exists('g:QFix_UseAltCR')
  let g:QFix_UseAltCR = 2
endif

""""""""""""""""""""""""""""""
" User function
""""""""""""""""""""""""""""""
" ローカルキーマップ
silent! function QFixMemoLocalKeymapPost()
endfunction

" BufNewFile,BufRead
silent! function QFixMemoBufRead()
endfunction

" BufReadPost
silent! function QFixMemoBufLeave()
endfunction

" BufWinEnter
silent! function QFixMemoBufWinEnter()
endfunction

" BufEnter
silent! function QFixMemoBufEnter()
endfunction

" BufWritePre
if !exists('*QFixMemoBufWritePre')
function QFixMemoBufWritePre()
  " タイトル行付加
  call qfixmemo#AddTitle()
  " タイムスタンプ付加
  call qfixmemo#AddTime()
  " タイムスタンプアップデート
  call qfixmemo#UpdateTime()
  " ファイル末の空行を削除
  call qfixmemo#DeleteNullLines()
  " キーワードリンク
  call qfixmemo#AddKeyword()
endfunction
endif

" BufWritePost
silent! function QFixMemoBufWritePost()
endfunction

" アウトラインコマンド
if !exists('*QFixMemoOutline')
function QFixMemoOutline()
  silent! exe "normal! zi"
endfunction
endif

""""""""""""""""""""""""""""""
function! qfixmemo#InsertDate(type)
  let fmt = g:qfixmemo_timeformat
  if a:type == 'Date'
    let fmt = g:qfixmemo_dateformat
  endif
  let str = strftime(fmt)
  silent! put=str
  startinsert!
endfunction

if g:qfixmemo_use_howm_schedule
  function! qfixmemo#ListReminderCache(type)
    call <SID>howmScheduleEnv('save')
    call QFixHowmListReminderCache(a:type)
    call <SID>howmScheduleEnv('restore')
  endfunction

  function! qfixmemo#ListReminder(type)
    call <SID>howmScheduleEnv('save')
    call QFixHowmListReminder(a:type)
    call <SID>howmScheduleEnv('restore')
  endfunction

  function! qfixmemo#GenerateRepeatDate()
    call <SID>howmScheduleEnv('save')
    call QFixHowmGenerateRepeatDate()
    call <SID>howmScheduleEnv('restore')
  endfunction

  function! qfixmemo#OpenMenu(...)
    call <SID>howmScheduleEnv('save')
    call howm_menu#Init()
    " let g:QFixHowm_KeywordList = deepcopy(s:KeywordDic)
    if a:0
      call QFixHowmOpenMenu(a:1)
    else
      call QFixHowmOpenMenu()
    endif
    call <SID>howmScheduleEnv('restore')
    let lt = HowmSchedueCachedTime('menu')
    if lt > 0
      let lt = localtime() - lt
      echo 'QFixMemo : Cached menu ('.lt/60.' minutes ago)'
    endif
  endfunction

  function! s:howmScheduleEnv(...)
    if qfixmemo#Init()
      return
    endif
    call howm_schedule#Init()
  endfunction
endif

""""""""""""""""""""""""""""""
augroup QFixMemo
  au!
  au BufNewFile,BufRead * call <SID>BufRead()
  au BufEnter           * call <SID>BufEnter()
  au BufLeave           * call <SID>BufLeave()
  au BufWritePre        * call <SID>BufWritePre()
  au BufWritePost       * call <SID>BufWritePost()
  au BufWinEnter        * call <SID>BufWinEnter()
  au BufWinEnter quickfix call <SID>qfBufWinEnter()
augroup END

function! s:BufRead()
  if !IsQFixMemo(expand('%:p'))
    return
  endif
  call qfixmemo#BufRead()
endfunction

function! qfixmemo#BufRead()
  call qfixmemo#Init()
  " qfixmemo_dir以下のファイルであればファイル属性を設定
  if &readonly == 0
    if g:qfixmemo_forceencoding && &fenc != g:qfixmemo_fileencoding
      let saved_ft = &filetype
      let saved_syn = &syntax
      exe 'edit! ++enc='.g:qfixmemo_fileencoding.' ++ff='.g:qfixmemo_fileformat
      if &readonly
        edit!
        let mes= expand('%')."\nInvalid qfixmemo_fileencoding (".&fenc.")\nSet to fenc (".g:qfixmemo_fileencoding.")?"
        let choice = g:qfixmemo_forceencoding == 2 ? 1 : confirm(mes, "&Yes\n&No", 2, "W")
        if choice == 1
          exe 'set fenc='.g:qfixmemo_fileencoding
          exe 'set ff='.g:qfixmemo_fileformat
          " write!
        endif
      endif
      let &filetype=saved_ft
      let &syntax=saved_syn
    endif
    if &bomb && g:qfixmemo_nobomb
      " echohl ErrorMsg
      redraw|echom 'QFixMemo : BOM detected. set nobomb'
      " echohl None
      set nobomb
    endif
  endif
  call s:filetype()
  if g:qfixmemo_folding
    call QFixMemoSetFolding()
  endif
  call s:localkeymap()
  call QFixMemoBufRead()
endfunction

" local keymap
function! s:localkeymap()
  if exists('g:maplocalleader')
    let s:mapleader = g:mapleader
  endif
  let g:maplocalleader = g:qfixmemo_mapleader
  if g:qfixmemo_default_keymap
    call s:QFixMemoLocalKeymap()
  endif
  call QFixMemoLocalKeymapPost()
  if exists('s:maplocalleader')
    let g:maplocalleader = s:maplocalleader
  else
    unlet g:maplocalleader
  endif
endfunction

" デフォルトローカルキーマップ
command! -count -nargs=1 QFixMRUMoveCursor call QFixMRUMoveCursor(<q-args>)
if !exists('*QFixMRUMoveCursor')
function! QFixMRUMoveCursor(pos, ...)
endfunction
endif
function! s:QFixMemoLocalKeymap()
  if exists('*QFixMemoLocalKeymap')
    call QFixMemoLocalKeymap()
    return
  endif
  nnoremap <silent> <buffer> <LocalLeader>P :QFixMRUMoveCursor top<CR>:<C-u>call qfixmemo#Template('top')<CR>
  nnoremap <silent> <buffer> <LocalLeader>p :QFixMRUMoveCursor prev<CR>:<C-u>call qfixmemo#Template('prev')<CR>
  nnoremap <silent> <buffer> <LocalLeader>n :QFixMRUMoveCursor next<CR>:<C-u>call qfixmemo#Template('next')<CR>
  nnoremap <silent> <buffer> <LocalLeader>N :QFixMRUMoveCursor bottom<CR>:<C-u>call qfixmemo#Template('bottom')<CR>

  nnoremap <silent> <buffer> <LocalLeader>x :<C-u>call qfixmemo#DeleteEntry()<CR>
  nnoremap <silent> <buffer> <LocalLeader>X :<C-u>call qfixmemo#DeleteEntry('Move')<CR>
  nnoremap <silent> <buffer> <LocalLeader>W :<C-u>call qfixmemo#DivideEntry()<CR>
  vnoremap <silent> <buffer> <LocalLeader>W :<C-u>call qfixmemo#DivideEntry()<CR>

  nnoremap <silent> <buffer> <LocalLeader>S  :<C-u>call qfixmemo#UpdateTime(1)<CR>
  nnoremap <silent> <buffer> <LocalLeader>rs :<C-u>call qfixmemo#SortEntry('Normal')<CR>
  nnoremap <silent> <buffer> <LocalLeader>rS :<C-u>call qfixmemo#SortEntry('Reverse')<CR>

  nnoremap <silent> <buffer> <LocalLeader>f :<C-u>call qfixmemo#FGrep()<CR>
  nnoremap <silent> <buffer> <LocalLeader>e :<C-u>call qfixmemo#Grep()<CR>

  nnoremap <silent> <buffer> <LocalLeader>w :<C-u>call qfixmemo#ForceWrite()<CR>

  nnoremap <silent> <buffer> <LocalLeader>rn :<C-u>call qfixmemo#Rename()<CR>

  nnoremap <silent> <buffer> <CR> :call QFixMemoUserModeCR()<CR>

  if g:qfixmemo_use_howm_schedule
    nnoremap <silent> <buffer> <LocalLeader>z :<C-u>call CnvWildcardChapter()<CR>
    vnoremap <silent> <buffer> <LocalLeader>z :<C-u>call CnvWildcardChapter()<CR>
  endif
endfunction

" フォールディングレベル計算
if !exists('*QFixMemoSetFolding')
function QFixMemoSetFolding()
  setlocal nofoldenable
  setlocal foldmethod=expr
  if exists('*QFixMemoFoldingLevel')
    setlocal foldexpr=QFixMemoFoldingLevel(v:lnum)
  else
    setlocal foldexpr=getline(v:lnum)=~g:qfixmemo_folding_pattern?'>1':'1'
  endif
endfunction
endif

function! s:filetype()
  let file = QFixNormalizePath(expand('%:p'), 'compare')
  let pdir = QFixNormalizePath(fnamemodify(g:qfixmemo_dir.'/'.g:qfixmemo_pairfile_dir, ':p'), 'compare')
  if &filetype != '' && stridx(file, pdir) == 0
    return
  endif
  if g:qfixmemo_filetype != ''
    exe 'setlocal filetype=' . g:qfixmemo_filetype
  endif
  call s:syntaxHighlight()
endfunction

function! s:syntaxHighlight()
  if g:qfixmemo_syntax_flag =~ '^...1'
    silent! syn clear qfixmemoTitle
    let l:qfixmemo_title = escape(g:qfixmemo_title, g:qfixmemo_escape)
    exe 'syn region qfixmemoTitle start="^'.l:qfixmemo_title.'[^'.g:qfixmemo_title.']'.'" end="$" contains=qfixmemoTitleDesc,qfixmemoCategory'
    exe 'syn match qfixmemoTitleDesc "^'.l:qfixmemo_title.'$"'
    exe 'syn match qfixmemoTitleDesc contained "^'.l:qfixmemo_title.'"'
    syn match qfixmemoCategory contained +\(\[.\{-}\]\)\++
    hi link qfixmemoTitle     Title
    hi link qfixmemoTitleDesc Special
    hi link qfixmemoCategory  Label
  endif
  if g:qfixmemo_syntax_flag =~ '^..1.'
    silent! syn clear qfixmemoKeyword
    if s:KeywordHighlight != ''
      exe 'syn match qfixmemoKeyword display "\V'.escape(s:KeywordHighlight, '"').'"'
    endif
    hi link qfixmemoKeyword Underlined
  endif
  if g:qfixmemo_syntax_flag =~ '^.1..'
    exe 'syn match qfixmemoDateTime "'.g:qfixmemo_timestamp_regxp . '" contains=qfixmemoDate,qfixmemoTime'
    syn match qfixmemoDate contained '\d\{4}-\d\{2}-\d\{2}'
    syn match qfixmemoDate contained '\d\{4}/\d\{2}/\d\{2}'
    syn match qfixmemoTime contained '\d\{2}\(:\d\{2}\)\+'

    hi link qfixmemoDate Underlined
    hi link qfixmemoTime Constant
  endif
  if g:qfixmemo_syntax_flag =~ '^1...'
    exe 'runtime! syntax/'.g:qfixmemo_syntax_file
  endif
endfunction

function! s:BufEnter()
  if !IsQFixMemo(expand('%:p'))
    return
  endif
  if g:qfixmemo_default_keymap
    nnoremap <silent> <buffer> <CR> :call QFixMemoUserModeCR()<CR>
  endif
  call QFixMemoBufEnter()
endfunction

function! s:BufWinEnter()
  if !IsQFixMemo(expand('%:p'))
    return
  endif
  call QFixMemoBufWinEnter()
endfunction

function! s:BufLeave()
  if !IsQFixMemo(expand('%:p'))
    return
  endif
  call QFixMemoBufLeave()
endfunction

" 強制書込
function! qfixmemo#ForceWrite(...)
  let saved_bt = &buftype
  let saved_ei = &eventignore
  if &buftype != ''
    setlocal buftype=
  endif
  let s:ForceWrite = 1
  if a:0
    let s:ForceWrite = 0
    set eventignore=ALL
  endif
  write!
  let &eventignore = saved_ei
  let &buftype = saved_bt
endfunction

" タイトル行付加
function! qfixmemo#AddTitle(...)
  if g:qfixmemo_use_addtitle == 0 && (!a:0 || !a:1)
    return
  endif
  let l:qfixmemo_title = escape(g:qfixmemo_title, g:qfixmemo_escape)
  let rpattern = '^'.l:qfixmemo_title .'\s*\(\[.\{-}]*\]\s*\)*\s*$'
  let tpattern = qfixmemo#TitleRegxp()

  let save_cursor = getpos('.')
  " 一行目は必ずタイトル
  let fline = 1
  call cursor(1, 1)
  let str = getline(fline)
  let altreg = g:qfixmemo_alt_title_regxp
  " 一行目が予定・TODOなら次エントリへ
  if (altreg != '' && str =~ altreg)
    let [entry, fline, lline] = QFixMRUGet('entry', '%', fline, tpattern)
    let fline = lline + 1
    if fline >= line('$')
      call setpos('.', save_cursor)
      return
    endif
  elseif str !~ tpattern && str !~ l:qfixmemo_title
    exe "0put='".g:qfixmemo_title . " '"
  endif
  while 1
    let [entry, fline, lline] = QFixMRUGet('entry', '%', fline, tpattern)
    if fline == -1
      break
    endif
    let title = entry[0]
    if title =~ rpattern
      call remove(entry, 0)
      for str in entry
        if str != '' && (altreg == '' || str !~ altreg) && str !~ g:qfixmemo_timestamp_regxp
          let len = strlen(str)
          let str = substitute(str, '\%>' . g:qfixmemo_title_length .'v.*','','')
          if strlen(str) != len
            let str = str . '...'
          endif
          let title = substitute(title, '\s*$', ' ', '') . str
          let title = substitute(title, '^'. l:qfixmemo_title . '\s*', g:qfixmemo_title . ' ' , '')
          call setline(fline, title)
          break
        endif
      endfor
    elseif title =~ '^' . l:qfixmemo_title . '\S'
      let title = substitute(title, '^' . l:qfixmemo_title, g:qfixmemo_title . ' ', '')
      call setline(fline, title)
    endif
    let fline = lline+1
  endwhile
  call setpos('.', save_cursor)
endfunction

" タイムスタンプ行付加
function! qfixmemo#AddTime(...)
  if g:qfixmemo_use_addtime == 0 && (!a:0 || !a:1)
    return
  endif
  let l:qfixmemo_title = escape(g:qfixmemo_title, g:qfixmemo_escape)
  let save_cursor = getpos('.')
  call cursor(1, 1)
  let tpattern = qfixmemo#TitleRegxp()
  while 1
    let fline = search(tpattern, 'cW')
    if fline == 0
      break
    endif
    let [entry, fline, lline] = QFixMRUGet('entry', '%', fline, tpattern)
    if len(filter(entry, "v:val =~ '" . g:qfixmemo_timestamp_regxp. "'")) == 0
      let str = strftime(g:qfixmemo_timeformat)
      exe fline . 'put=str'
      let lline += 1
    endif
    call cursor(lline, 1)
  endwhile
  call setpos('.', save_cursor)
endfunction

" タイムスタンプアップデート
let s:qfixmemoWriteUpdateTime = 1
function! qfixmemo#UpdateTime(...)
  if g:qfixmemo_use_updatetime == 0 && (!a:0 || !a:1)
    return
  endif
  let l:qfixmemo_title = escape(g:qfixmemo_title, g:qfixmemo_escape)
  let fline = line('.')
  let save_cursor = getpos('.')
  let tpattern = qfixmemo#TitleRegxp()
  let [title, fline, lline] = QFixMRUGet('title', '%', fline, tpattern)
  call cursor(fline, 1)
  let fline = search(g:qfixmemo_timestamp_regxp, 'cW')
  let str = strftime(g:qfixmemo_timeformat)
  if stridx(getline(fline), str) == 0
    call setpos('.', save_cursor)
    return
  endif
  if fline == 0 || fline > lline
    let fline = fline == 0 ? 1 : fline
    exe fline . 'put=str'
  elseif s:qfixmemoWriteUpdateTime
    let str = substitute(getline(fline), g:qfixmemo_timeformat_regxp, str, '')
    call setline(fline, str)
  endif
  call setpos('.', save_cursor)
endfunction

" 行末の空白行を削除
function! qfixmemo#DeleteNullLines(...)
  if g:qfixmemo_use_deletenulllines == 0 && (!a:0 || !a:1)
    return
  endif
  let save_cursor = getpos('.')
  "ファイル末尾を空白一行に
  call cursor(line('$'), 1)
  let endline = line('.')
  if getline('.') !~ '^$'
    exe "put=''"
  else
    let firstline = search('^.\+$', 'nbW')
    if firstline == 0
      return
    endif
    if firstline+2 <= endline
      exe firstline+2.','.endline.'delete _'
    endif
  endif
  call setpos('.', save_cursor)
endfunction

let s:ForceWrite = 0
function! s:BufWritePre()
  if exists('b:qfixmemo_bufwrite_pre') && b:qfixmemo_bufwrite_pre == 0
    call qfixmemo#AddKeyword()
    return
  endif
  if !IsQFixMemo(expand('%:p'))
    return
  endif
  if s:ForceWrite
    let s:ForceWrite = 0
    return
  endif
  if search('^.\+$', 'ncw') == 0
    return
  endif
  call QFixMemoBufWritePre()
endfunction

function! s:BufWritePost()
  if !IsQFixMemo(expand('%:p'))
    return
  endif
  if search('^.\+$', 'ncw') == 0
    call delete(expand('%:p'))
    return
  endif
  call QFixMemoBufWritePost()
endfunction

let s:init = 0
function! qfixmemo#Init(...)
  " for qfixwin
  if &buftype == 'quickfix'
    let b:qfixwin_height = winheight(0)
    let b:qfixwin_width  = winwidth(0)
    let g:QFix_Height = b:qfixwin_height
  endif
  call QFixMemoInit()
  call QFixMemoTitleRegxp()
  if a:0 && a:1 !~ 'silent'
    let dir = expand(g:qfixmemo_dir)
    if isdirectory(dir) == 0
      if a:1 !~ 'mkdir'
        let mes = printf("!!!Create qfixmemo_dir? (%s)", g:qfixmemo_dir)
        let choice = confirm(mes, "&Yes\n&No", 2, "W")
        if choice != 1
          return 1
        endif
      endif
      call mkdir(dir, 'p')
    endif
  endif
  if s:init
    return 0
  endif
  call qfixmemo#MRUInit()
  if g:qfixmemo_use_howm_schedule
    call howm_schedule#Init()
  endif
  call qfixmemo#LoadKeyword()
  if has('macunix')
    silent! call libcallnr("libc.dylib", "srand", localtime())
  elseif has('unix') && !has('win32unix')
    silent! call libcallnr("", "srand", localtime())
  else
    silent! call libcallnr("msvcrt.dll", "srand", localtime())
  endif
  let s:init = 1
  return 0
endfunction

" for autoload
function! qfixmemo#load(...)
endfunction

""""""""""""""""""""""""""""""
" 拡張子を付加してqfixmemo#EditFile()を呼び出し
function! qfixmemo#Edit(...)
  if qfixmemo#Init()
    return
  endif
  if a:0 == 0
    let file = input('filename : ', '')
    if file == ''
      return
    endif
    let file = strftime(file)
  else
    let file = strftime(a:1)
  endif
  if fnamemodify(file, ':e') !~ '\c'.g:qfixmemo_ext
    let file = file.'.'.g:qfixmemo_ext
  endif
  call qfixmemo#EditFile(file)
endfunction

" qfixmemoファイルを開く
function! qfixmemo#EditFile(file)
  if qfixmemo#Init('mkdir')
    return
  endif
  let file = strftime(a:file)
  let pathhead = '\([A-Za-z]:[/\\]\|\~[/\\]\|\.\.\?[/\\]\|[/\\]\)'
  if file !~ '^'.pathhead
    let file = expand(g:qfixmemo_dir).'/'.file
  endif
  let opt = ''
  if IsQFixMemo(file)
    let opt = '++enc=' . g:qfixmemo_fileencoding . ' ++ff=' . g:qfixmemo_fileformat . ' '
  endif
  let mode = g:qfixmemo_splitmode ? 'split' : ''
  call s:edit(file, mode, opt)
endfunction

" 新規メモ作成
" カウント指定で qfixmemo_filename, qfixmemo_filename1, ...を使用する
function! qfixmemo#EditNew()
  if qfixmemo#Init()
    return
  endif
  let file = g:qfixmemo_filename
  if count
    exe 'let file = g:qfixmemo_filename'.count
  endif
  call qfixmemo#Edit(file)
endfunction

" 新規メモをファイル名指定で作成
" 拡張子指定がないときのみ、qfixmemo_extを付加する。
function! qfixmemo#EditInput()
  if qfixmemo#Init('mkdir')
    return
  endif
  let fname = g:qfixmemo_misc_file
  if count
    exe 'let fname = g:qfixmemo_misc_file'.count
  endif
  let fname = substitute(fname, '[/\\]\+', '/', 'g')
  while 1
    let file = input('File: ', fname, 'file')
    if file == ''
      return
    endif
    if fnamemodify(file, ':t') == ''
      echohl ErrorMsg
      redraw|echom 'QFixMemo : Please input filename.'
      echohl None
      continue
    endif
    break
  endwhile
  let file = substitute(file, '[/\\]\+', '/', 'g')
  if fnamemodify(file, ':e') == ''
    let file = file.'.'.g:qfixmemo_ext
  endif
  call qfixmemo#EditFile(file)
endfunction

" クイックメモを開く
let s:qfixmemo_quickmemo = g:qfixmemo_quickmemo
function! qfixmemo#Quickmemo(...)
  if qfixmemo#Init('mkdir')
    return
  endif
  if a:0 && a:1 == 0
    let s:qfixmemo_quickmemo = g:qfixmemo_quickmemo
  endif
  let file = s:qfixmemo_quickmemo
  let num = a:0 ? a:1 : count
  if count
    exe 'let file = g:qfixmemo_quickmemo'.count
    let s:qfixmemo_quickmemo = file
  endif
  if fnamemodify(file, ':e') == ''
    let file = file.'.'.g:qfixmemo_ext
  endif
  call qfixmemo#EditFile(file)
endfunction

" 日記を開く
function! qfixmemo#EditDiary(file)
  if qfixmemo#Init()
    return
  endif
  let file = fnamemodify(a:file, ':r') .'.'.g:qfixmemo_ext
  call qfixmemo#EditFile(file)
endfunction

" ペアファイルを開く
function! qfixmemo#PairFile(file)
  if qfixmemo#Init()
    return
  endif
  let file = a:file
  if a:file == '%'
    let file = expand(a:file)
  endif
  let file = fnamemodify(file, ':t')
  let pfile = g:qfixmemo_pairfile_dir . '/' . file

  let glist = []
  if !filereadable(fnamemodify(g:qfixmemo_dir . '/' . pfile . '.'.g:qfixmemo_ext, ':p'))
    let str = g:qfixmemo_title . ' ' . substitute(fnamemodify(file, ':p'), '\\', '/', 'g')
    call add(glist, str)
    let type = g:qfixmemo_filetype . (g:qfixmemo_filetype != '' ? '.' : '') . &filetype
    call add(glist, '')
    call add(glist, printf('vim: set ft=%s :', type))
  endif
  call qfixmemo#Edit(pfile)
  if len(glist)
    let glist += getline(2, '$')
    call setline(1, glist)
    if line('.') == 1
      call cursor('2', col('$'))
    endif
    exe 'set filetype='.type
  endif
endfunction

function! s:edit(file, ...)
  let file = expand(a:file)
  let file = substitute(file, '\\', '/', 'g')

  let winnr = bufwinnr(file)
  if winnr > -1
    exe winnr.'wincmd w'
    return
  endif

  let mode = a:0 > 0 ? a:1 : ''
  let opt = a:0 > 1 ? a:2 : ''
  let winnum = bufwinnr(file)
  if winnum == winnr()
    return
  endif
  if winnum != -1
    exe winnum . 'wincmd w'
    return
  endif

  let winnr = s:getEditWinnr()
  if winnr < 1 || mode == 'split'
    split
  else
    exe winnr.'wincmd w'
  endif

  let dir = fnamemodify(file, ':h')
  if isdirectory(dir) == 0
    call mkdir(dir, 'p')
  endif
  let editcmd = g:qfixmemo_editcmd != '' ? g:qfixmemo_editcmd : 'edit '
  exe editcmd . ' ' . opt .' ' . escape(file, ' #%')
  if !filereadable(file) && IsQFixMemo(file)
    call qfixmemo#Template('New')
  endif
endfunction

function! s:getEditWinnr()
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
      let w = i
    endif
  endfor
  exe pwin.'wincmd w'
  return w
endfunction

function! qfixmemo#Template(cmd)
  if qfixmemo#Init()
    return
  endif
  let cmd    = a:cmd
  if exists('g:qfixmemo_template_'.g:qfixmemo_ext)
    exe 'let tmpl = deepcopy(g:qfixmemo_template_'.g:qfixmemo_ext . ')'
  else
    let tmpl = deepcopy(g:qfixmemo_template)
  endif
  if len(tmpl) == 0
    return
  endif
  let keycmd = g:qfixmemo_template_keycmd
  if exists('g:qfixmemo_template_keycmd_'.g:qfixmemo_ext)
    exe 'let keycmd = g:qfixmemo_template_keycmd_'.g:qfixmemo_ext
  endif

  let title  = g:qfixmemo_title
  let tag    = g:qfixmemo_template_tag

  call map(tmpl, 'substitute(v:val, "%TITLE%", title, "g")')
  call map(tmpl, 'substitute(v:val, "%DATE%", g:qfixmemo_timeformat, "g")')
  if tag != ''
    let tag = tag . ' '
  endif
  call map(tmpl, 'substitute(v:val, "%TAG%"  , tag,   "g")')
  call map(tmpl, 'strftime(v:val)')
  if cmd == 'New'
    silent! call setline(1, tmpl)
    call cursor(1, 1)
  endif
  let tmpl = s:patch73_272(tmpl)
  let nl = ""
  let len = len(tmpl)
  let l = line('.')
  if cmd =~ 'next'
    if getline(line('.')) != ''
      silent! put=nl
    endif
    silent! put=tmpl
    call cursor(l+1, 1)
  elseif cmd == 'prev'
    silent! -1put=tmpl
    call cursor(l, 1)
  elseif cmd == 'top'
    silent! -1put=tmpl
    call cursor(1, 1)
  elseif cmd == 'bottom'
    if getline(line('$')) != ''
      silent! put=nl
    endif
    silent! $put=tmpl
    call cursor(l+1, 1)
  endif
  let saved_ve = &virtualedit
  silent setlocal virtualedit+=onemore
  silent! exe 'normal! '. keycmd
  if keycmd =~ '\CA$'
    exe 'normal! l'
    startinsert!
  elseif keycmd =~ '\Ca$'
    exe 'normal! l'
    startinsert
  elseif keycmd =~ '\CI$'
    exe 'normal! ^'
    startinsert
  elseif keycmd =~ '\Ci$'
    startinsert
  endif
  silent! exe 'setlocal virtualedit='.saved_ve
endfunction

" Vim 7.3patch272の:put=listバグ修正による挙動の違いを吸収する
" 7.3.272  ":put =list" does not add empty line for trailing empty item
if !exists('qfixmemo_patch73_272')
  let qfixmemo_patch73_272 = v:version > 703 || (v:version == 703 && has('patch272'))
endif
function! s:patch73_272(list)
  if g:qfixmemo_patch73_272
    return a:list
  endif
  let list = deepcopy(a:list)
  call add(list, "")
  return list
endfunction

function! qfixmemo#DeleteEntry(...)
  if qfixmemo#Init()
    return
  endif
  let tpattern = qfixmemo#TitleRegxp()
  let [text, startline, endline] = QFixMRUGet('title', '%', line('.'), tpattern)
  silent! exe startline.','.endline.'d'
  call cursor(startline, 1)
  if &hidden == 0
    write!
  endif
  if a:0
    let filename = g:qfixmemo_auto_generate_filename
    call qfixmemo#Edit(filename)
    silent! %delete _
    silent! 0put
    silent! $delete _
    call cursor(1, 1)
    stopinsert
    let s:qfixmemoWriteUpdateTime = 0
    write!
    let s:qfixmemoWriteUpdateTime = 1
  endif
endfunction

function! qfixmemo#DivideEntry() range
  if qfixmemo#Init()
    return
  endif
  let g:QFixMRU_Disable = 1
  let fline = a:firstline
  let lline = a:lastline
  if fline == lline
    let fline = 1
    let lline = line('$')
  endif

  let filename = g:qfixmemo_auto_generate_filename
  let cnt = 0
  let bufnr = bufnr('%')
  let tpattern = qfixmemo#TitleRegxp()
  while 1
    let [entry, fline, lline] = QFixMRUGet('entry', '%', fline, tpattern)
    if fline == -1
      break
    endif
    let file = strftime(filename, localtime()+cnt)
    call qfixmemo#Edit(file)
    silent! %delete _
    call setline(1, entry)
    silent! $delete _
    call cursor(1, 1)
    silent! exe 'w! '
    exe 'b ' . bufnr
    " silent! exe 'bd'
    let fline = lline + 1
    if fline > a:lastline
      break
    endif
    let cnt += 1
  endwhile
  stopinsert
  silent! %delete _
  silent! exe 'w! '
  let g:QFixMRU_Disable = 0
endfunction

function! qfixmemo#Readfile(file, fileencoding)
  let mfile = fnamemodify(a:file, ':p')
  if bufloaded(mfile) "バッファが存在する場合
    let glist = getbufline(mfile, 1, '$')
  else
    let glist = readfile(mfile)
    let from = a:fileencoding
    let to   = &enc
    call map(glist, 'iconv(v:val, from, to)')
  endif
  return glist
endfunction

""""""""""""""""""""""""""""""
" MRUを開く
function! qfixmemo#ListMru()
  if qfixmemo#Init()
    return
  endif
  if count
    let g:QFixMRU_Entries = count
  endif
  redraw | echo 'QFixMemo : Read MRU...'
  call QFixMRU(g:qfixmemo_dir, '/:dir')
endfunction

" 最近編集されたファイル内のエントリ一覧
function! qfixmemo#ListRecent()
  if qfixmemo#Init()
    return
  endif
  if count
    let g:qfixmemo_recentdays = count
  endif
  let title = QFixMRUGetTitleGrepRegxp(g:qfixmemo_ext)
  let qflist = qfixlist#search(title, g:qfixmemo_dir, 'mtime', g:qfixmemo_recentdays, g:qfixmemo_fileencoding, '**/*')
  return qfixlist#copen(qflist, g:qfixmemo_dir)
endfunction

" タイムスタンプが最近のエントリ一覧
function! qfixmemo#ListRecentTimeStamp(...)
  if qfixmemo#Init()
    return
  endif
  call qfixlist#Init()
  if count
    let g:qfixmemo_recentdays = count
  endif
  let days = g:qfixmemo_recentdays

  " findstrは特別扱い
  let findstr = (g:mygrepprg == '') + (g:mygrepprg == 'findstr') + (a:0)
  let fmt = g:qfixmemo_timeformat
  if findstr
    let fmt = substitute(fmt, ' .*$', '', '')
    if exists('g:qfixmemo_timeformat_findstr')
      let fmt = g:qfixmemo_timeformat_findstr
    endif
  endif
  let fmt = '^' . escape(fmt, '()[]~*.#')
  let fmt = substitute(fmt, '\C%H', '[0-2][0-9]', 'g')
  let fmt = substitute(fmt, '\C%M', '[0-5][0-9]', 'g')
  let fmt = substitute(fmt, '\C%S', '[0-5][0-9]', 'g')
  let fmt = substitute(fmt, '\C%a', iconv('(Sun|Mon|Tue|Wed|Thu|Fri|Sat|日|月|火|水|木|金|土)', &enc, g:qfixmemo_fileencoding), 'g')

  let tregxp = ''
  let ltime = localtime()
  for n in range(days)
    let year  = strftime('%Y', ltime)
    let month = strftime('%m', ltime)
    let day   = strftime('%d', ltime)

    let regxp = fmt
    let regxp = substitute(regxp, '\C%Y', year, 'g')
    let regxp = substitute(regxp, '\C%m', month, 'g')
    let regxp = substitute(regxp, '\C%d', day, 'g')

    let tregxp = tregxp . printf('|%s', regxp)
    let ltime -= 24*60*60
  endfor
  let tregxp = substitute(tregxp, '^|', '', '')

  redraw | echo 'QFixMemo : Searching...'
  if findstr
    let saved_grepprg = &grepprg
    set grepprg=findstr
    let tregxp = substitute(tregxp, '\^', '', 'g')
    let tregxp = substitute(tregxp, '|', ' ', 'g')
    let prevPath = escape(getcwd(), ' ')
    let qf = getqflist()
    exe 'lchdir ' . escape(expand(g:qfixmemo_dir), ' ')
    let cmd = 'grep! /n /p /r /i /s /b "' . tregxp . '" *.*'
    silent! exe cmd
    exe 'lchdir ' . prevPath
    let qflist = getqflist()
    call setqflist(qf)
    let &grepprg = saved_grepprg
    let qflist = qfixlist#sort('rtext', qflist)
    " FIXME: findstrで内部エンコーディングが utf-8 だと日本語ファイル名が処理できない
    for idx in range(len(qflist))
      let file = bufname(qflist[idx]['bufnr'])
      let file = substitute(fnamemodify(file, ':p'), '\\', '/', 'g')
      let qflist[idx]['filename'] = file
    endfor
  else
    let qflist = qfixlist#search(tregxp, g:qfixmemo_dir, 'rtext', 0, g:qfixmemo_fileencoding, '**/*')
    let fmt = g:qfixmemo_timestamp_regxp
    call filter(qflist, "v:val['text'] =~ '" . fmt . "'")
  endif

  redraw | echo 'QFixMemo : Add summary...'
  let tpattern = qfixmemo#TitleRegxp()
  let idx = 0
  for d in qflist
    let file = d['filename']
    let lnum = d['lnum']
    let [entry, flnum, llnum] = QFixMRUGet('entry', file, lnum, tpattern)
    if len(entry) == 0
      call remove(qflist, idx)
      continue
    endif
    let qflist[idx]['text'] = entry[0]
    let idx += 1
  endfor
  redraw | echo ''
  return qfixlist#copen(qflist, g:qfixmemo_dir)
endfunction

" キーマップ用リストコマンド
" 追加オプションがある場合はキャッシュを強制的に無効化
function! qfixmemo#ListCmd(...)
  if qfixmemo#Init()
    return
  endif
  let cmd = g:qfixmemo_qfixlist_cmd
  let [qflist, path] = qfixlist#GetList(cmd)
  if g:qfixmemo_qfixlist_cache && !a:0 && qflist != []
    redraw|echo 'QFixMemo : Cached list.'
    if cmd =~ 'copen'
      return qfixlist#copen()
    else
      return qfixlist#open()
    endif
  endif
  let pattern = QFixMRUGetTitleGrepRegxp(g:qfixmemo_ext)
  let qflist = qfixlist#search(pattern, g:qfixmemo_dir, g:qfixmemo_list_sort, 0, g:qfixmemo_fileencoding, '**/*')
  if cmd =~ 'copen'
    return qfixlist#copen(qflist, g:qfixmemo_dir)
  else
    return qfixlist#open(qflist, g:qfixmemo_dir)
  endif
endfunction

" ファイルリスト
function! qfixmemo#ListFile(file)
  if qfixmemo#Init()
    return
  endif
  let title = '^'.escape(g:qfixmemo_title, g:qfixmemo_escape)
  let pattern = a:file
  if fnamemodify(pattern, ':e') !~ '\c'.g:qfixmemo_ext
    let pattern = pattern.'.'.g:qfixmemo_ext
  endif
  let pattern = '**/'.substitute(pattern, '[\\/]', '\[\\\\/\]', 'g')
  let pattern = s:strftimeRegxp(pattern)
  let qflist = qfixlist#search(title, g:qfixmemo_dir, g:qfixmemo_list_sort, 0, g:qfixmemo_fileencoding, pattern)
  return qfixlist#open(qflist, g:qfixmemo_dir)
endfunction

function! s:strftimeRegxp(regxp)
  let regxp = a:regxp
  let regxp = substitute(regxp, '%Y', '[0-9][0-9][0-9][0-9]', 'g')
  let regxp = substitute(regxp, '%m', '[0-9][0-9]', 'g')
  let regxp = substitute(regxp, '%d', '[0-9][0-9]', 'g')
  let regxp = substitute(regxp, '%H', '[0-9][0-9]', 'g')
  let regxp = substitute(regxp, '%M', '[0-9][0-9]', 'g')
  let regxp = substitute(regxp, '%S', '[0-9][0-9]', 'g')
  return regxp
endfunction

" Globファイルリスト
function! qfixmemo#Glob(path, file, mode)
  if qfixmemo#Init()
    return
  endif
  let prevPath = escape(getcwd(), ' ')
  let path = expand(a:path)
  if !isdirectory(path)
    let mes = printf('"%s" is not directory.', a:path)
    let choice = confirm(mes, "&OK", 1, "W")
    return
  endif
  if path !~ '[\\/]$'
    let path .= '/'
  endif
  let mode = a:mode
  exe 'lchdir ' . escape(path, ' ')
  redraw | echo 'QFixMemo : glob...'
  let files = split(glob(a:file), '\n')
  let qflist = []
  let lnum = 1
  let text = ''
  let from = g:qfixmemo_fileencoding
  let to   = &enc
  redraw | echo 'QFixMemo : Read firstline'
  let func = printf('%s(qflist, usefile)', g:qfixmemo_list_sort == 'reverse' ? 'insert' : 'add')
  for n in files
    let n = path . n
    let n = fnamemodify(n, ':p')
    if !isdirectory(n)
      let lnum = 1
      let tlist = readfile(n, '', 1)
      let text = len(tlist) ? iconv(tlist[0], from, to) : ''
      let usefile = {'filename':n, 'lnum':lnum, 'text':text}
      call eval(func)
    endif
  endfor
  exe 'lchdir ' . prevPath
  if g:qfixmemo_list_sort != '' && g:qfixmemo_list_sort != 'reverse'
    let qflist = qfixlist#sort(g:qfixmemo_list_sort, qflist)
  endif
  redraw | echo ''
  if mode =~ 'list'
    return qflist
  elseif mode =~ 'copen'
    return qfixlist#copen(qflist, path)
  else
    return qfixlist#open(qflist, path)
  endif
endfunction

let s:RenameQFList = []
function! qfixmemo#ListRenameFile(file)
  if qfixmemo#Init('query')
    return
  endif
  let qflist = qfixmemo#Glob(g:qfixmemo_dir, '**/*.'.g:qfixmemo_ext, 'list')
  for d in qflist
    let d['filename'] = substitute(d['filename'], '\\', '/', 'g')
  endfor
  let pattern = a:file
  if fnamemodify(pattern, ':e') !~ '\c'.g:qfixmemo_ext
    let pattern = pattern.'.'.g:qfixmemo_ext
  endif
  let pattern = s:strftimeRegxp(pattern)
  call filter(qflist, "v:val['filename'] =~ '" . pattern . "'")
  let pattern = g:qfixmemo_diary
  if fnamemodify(pattern, ':e') !~ '\c'.g:qfixmemo_ext
    let pattern = pattern.'.'.g:qfixmemo_ext
  endif
  let pattern = s:strftimeRegxp(pattern)
  call filter(qflist, "v:val['filename'] !~ '" . pattern . "'")
  call filter(qflist, "v:val['filename'] !~ '/" . g:qfixmemo_pairfile_dir . "/'")
  for d in qflist
    let file = s:formatFileName(d['text'], g:qfixmemo_rename_length)
    let d['text'] = file . '.' . g:qfixmemo_ext
  endfor

  call qfixlist#open(qflist, g:qfixmemo_dir)
  let s:RenameQFList = qflist
  nnoremap <silent> <buffer> !     :<C-u>call qfixmemo#RenameAll()<CR>
  nnoremap <silent> <buffer> <C-g> :<C-u>call qfixmemo#RenameAll()<CR>
  redraw| echo ' <C-g> or ! : Rename all files.'
  setlocal modifiable
endfunction

function! s:formatFileName(fname, len)
  let title = '^'.escape(g:qfixmemo_title, g:qfixmemo_escape)
  let fname = a:fname

  let fname = substitute(fname, title . '\s*\|\.\+$', '', 'g')
  let fname = substitute(fname, '^\(\[.\{-}\]\s*\)\+', '', 'g')
  let chars = a:len
  let fn =  chars != 0 ? '' : fname
  while chars
    let ch = matchstr(fname, '.')
    if ch == ''
      break
    endif
    let fn = fn.ch
    let len = len(ch)
    let fname = strpart(fname, len)
    let chars -= len > 1 ? 2 : 1
    if fname == '' || chars < 1
      break
    endif
  endwhile
  let fn = substitute(fn, '[/:*?"<>|\\]', '_', 'g')
  return fn
endfunction

function! qfixmemo#Rename()
  if qfixmemo#Init()
    return
  endif
  let from = substitute(fnamemodify(expand('%'), ':p'), '\\', '/', 'g')
  let tpattern = qfixmemo#TitleRegxp()
  let [title, flnum, llnum] = QFixMRUGet('title', '%', 1, tpattern)
  let title = s:formatFileName(title, g:qfixmemo_rename_length)
  while 1
    let to = input('Rename to : ', title)
    if to == ''
      return
    endif
    let to = substitute(to, '[/:*?"<>|\\]', '_', 'g')
    let to = substitute(to, '^\s*\|\s*$', '', 'g')
    if to !~ '\.' . fnamemodify(from, ':e')
      let to = to .  '.' . fnamemodify(from, ':e')
    endif
    if filereadable(fnamemodify(from, ':p:h') . '/' . to)
      let mes = '"'.to.'" already exists.'
      let choice = confirm(mes, "&Input name\n&Overwrite\n&Cancel", 1, "Q")
      if choice == 1
        let to = ''
        continue
      elseif choice != 2
        return
      else
        break
      endif
    else
      break
    endif
  endwhile
  let to = fnamemodify(from, ':p:h') . '/' . to
  update
  call rename(from, to)
  silent! exe 'silent! edit '.escape(to, ' %#')
  silent! exe 'silent! bwipeout '.from
endfunction

function! qfixmemo#RenameAll()
  if qfixmemo#Init('query')
    return
  endif
  let mes = '!!! Rename all memo files.'
  if confirm(mes, "&OK\n&Cancel", 2, "W") != 1
    return
  endif

  let s:RenameQFList = []
  for n in range(1, line('$'))
    let str = getline(n)
    let from = g:qfixmemo_dir.'/'.substitute(str, '|.*$', '', '')
    let form = substitute(from, '\\', '/', 'g')
    let to   = substitute(str, '^[^|]\+|[^|]|', '', '')
    let res = {'filename': from, 'lnum': 1, 'text': to}
    call add(s:RenameQFList, res)
  endfor
  let glist = []
  for d in s:RenameQFList
    let from = d['filename']
    let to = substitute(d['text'], '^\s*\|\s*$', '', 'g')
    let to = fnamemodify(from, ':p:h') . '/' . to
    let to = substitute(to, '\\', '/', 'g')
    if filereadable(to) || fnamemodify(to, ':t:r') == ''
      call add(glist, d)
      continue
    endif
    call rename(from, to)
  endfor
  close!
  call qfixlist#open(glist, g:qfixmemo_dir)
  if len(glist)
    redraw|echo 'Change these filename(s).'
  else
    redraw|echo 'Done.'
  endif
  let s:RenameQFList = glist
endfunction

""""""""""""""""""""""""""""""
" カレンダー表示
function! qfixmemo#Calendar(...)
  if qfixmemo#Init()
    return
  endif
  if a:0 && g:qfixmemo_calendar_wincmd =~ 'botright'
    let g:qfixmemo_calendar_wincmd = 'vertical topleft'
  elseif a:0
    let g:qfixmemo_calendar_wincmd = 'vertical botright'
  endif
  let winnr = bufwinnr('__Calendar__')
  if a:0 && winnr != -1
    exe winnr.'wincmd w'
    exe 'wincmd c'
  elseif fnamemodify(bufname(winbufnr(0)), ':t') == '__Calendar__'
    close
    return
  endif
  silent! call howm_calendar#init()
  call QFixMemoCalendar(g:qfixmemo_calendar_wincmd, '__Calendar__', g:qfixmemo_calendar_count)
endfunction

if !exists('*QFixMemoCalendar')
function QFixMemoCalendar(...)
endfunction
endif

""""""""""""""""""""""""""""""
let s:rwalk = []
let s:randomfile = ''
" ランダム表示
function! qfixmemo#RandomWalk(file, ...)
  if qfixmemo#Init()
    return
  endif
  let file = expand(a:file)
  let ftime = getftime(file)
  let ftime = ftime < 0 ? 0 : ftime
  let ltime = localtime() - ftime
  let dir   = g:qfixmemo_dir
  if exists('g:qfixmemo_root')
    let dir = g:qfixmemo_root
  endif
  if exists('g:qfixmemo_random_dir')
    let dir = g:qfixmemo_random_dir
  endif
  if ftime == 0 || ltime > (g:qfixmemo_random_time*24*60*60)
    let s:rwalk = s:randomWriteFile(file, dir)
  elseif file != s:randomfile
    let s:rwalk = s:randomReadFile(file, dir)
  endif
  let columns = g:qfixmemo_random_columns
  if count
    let g:qfixmemo_random_columns = count
  endif
  if &ft == 'qf'
    let columns = winheight(0)
  endif
  let dir = g:qfixmemo_dir
  let qflist = s:randomList(s:rwalk, columns, dir)
  if a:0
    return qflist
  endif
  if len(qflist) == 0
    echohl ErrorMsg
    redraw|echom 'QFixMemo : Nothing in random list!'
    echohl None
    return
  endif
  redraw | echo ''
  return qfixlist#copen(qflist, dir)
endfunction

" ランダムキャッシュ再作成
function! qfixmemo#RebuildRandomCache(file)
  if qfixmemo#Init()
    return
  endif
  let dir   = g:qfixmemo_dir
  if exists('g:qfixmemo_root')
    let dir = g:qfixmemo_root
  endif
  if exists('g:qfixmemo_random_dir')
    let dir = g:qfixmemo_random_dir
  endif
  let file = a:file
  redraw | echo 'QFixMemo : Rebuild random cache...'
  let s:rwalk = s:randomWriteFile(file, dir)
  call qfixmemo#RandomWalk(file)
endfunction

function! s:randomList(list, len, dir)
  let len  = a:len
  let list = deepcopy(a:list)

  let head = expand(a:dir)
  let head = QFixNormalizePath(head)
  call filter(list, "v:val['filename'] =~ '".head."'")

  let rexclude = g:qfixmemo_random_exclude
  if rexclude != ''
    call filter(list, "v:val['text']     !~ '".rexclude."'")
    call filter(list, "v:val['filename'] !~ '".rexclude."'")
  endif
  let result = []
  while 1
    let range = len(list)
    if range <= 0 || len <= 0
      break
    endif
    let r = exists('*QFixMemoRandom') ? QFixMemoRandom(range) : s:random(range)
    let file = list[r]['filename']
    let file = QFixNormalizePath(file)
    let readable = 1
    if stridx(file, head) == 0
      let readable = filereadable(file)
      if readable
        call add(result, list[r])
        let len -= 1
      endif
    endif
    call remove(list, r)
    if !readable
      call filter(list, "stridx(v:val['filename'], file)==-1")
    endif
  endwhile
  return result
endfunction

function! s:random(range)
  if has('macunix')
    let r = libcallnr("libc.dylib", "rand", -1) % a:range
  elseif has('unix') && !has('win32unix')
    let r = libcallnr("", "rand", -1) % a:range
  else
    let r = libcallnr("msvcrt.dll", "rand", -1) % a:range
  endif
  return r
endfunction

function! s:randomReadFile(file, dir)
  redraw | echo 'QFixMemo : Read random cache...'
  let prevPath = escape(getcwd(), ' ')
  let dir = a:dir
  let s:randomfile = a:file
  let rfile = expand(a:file)
  let list = s:readfile(rfile)
  let head = expand(dir)
  let head = QFixNormalizePath(head)
  let result = []
  for r in list
    let file = substitute(r, '|.*', '', '')
    let file = head . '/'.file
    let file = substitute(file, '\\', '/', 'g')
    let text = substitute(r, '^[^|]\+|', '', '')
    let lnum = matchstr(text, '^\d\+')
    let text = substitute(text, '^[^|]\+|', '', '')
    let res = {'filename' : file, 'lnum' : lnum, 'text' : text}
    call add(result, res)
  endfor
  exe 'lchdir ' . prevPath
  return result
endfunction

function! s:readfile(file)
  let mfile = fnamemodify(a:file, ':p')
  if bufloaded(mfile) "バッファが存在する場合
    let glist = getbufline(mfile, 1, '$')
  else
    let glist = readfile(mfile)
    let from = g:qfixmemo_fileencoding
    let to   = &enc
    call map(glist, 'iconv(v:val, from, to)')
  endif
  return glist
endfunction

function! s:randomWriteFile(file, dir)
  redraw | echo 'QFixMemo : Searching...'
  let prevPath = escape(getcwd(), ' ')
  let dir = a:dir
  let rfile = expand(a:file)
  let title = '^'.escape(g:qfixmemo_title, g:qfixmemo_escape)
  let sq = qfixlist#search(title, dir, 'nop', 0, g:qfixmemo_fileencoding, '**/*')
  redraw | echo 'QFixMemo : Rebuild random cache...'
  let rexclude = g:qfixmemo_random_exclude
  if rexclude != ''
    call filter(sq, "v:val['text']     !~ '".rexclude."'")
    call filter(sq, "v:val['filename'] !~ '".rexclude."'")
  endif
  exe 'lchdir ' . escape(expand(dir), ' ')
  let result = []
  call add(result, dir)
  let head = QFixNormalizePath(expand(dir)) . '/'
  for d in sq
    let file = d['filename']
    " let file = fnamemodify(file, ':.')
    let file = substitute(file, '^'. head, '', '')
    let text = iconv(d['text'], &enc, g:qfixmemo_fileencoding)
    let res = file.'|'.d['lnum'].'|'.text
    call add(result, res)
  endfor
  call writefile(result, rfile)
  exe 'lchdir ' . prevPath
  return sq
endfunction

""""""""""""""""""""""""""""""
" Grep
function! qfixmemo#Grep(...)
  if qfixmemo#Init()
    return
  endif
  let fixmode = 0
  if a:0 && a:1 == 'fix'
    let fixmode = 1
  endif
  let title = fixmode ? 'F' : ''
  let title = substitute(g:qfixmemo_grep_title, '%MODE%', title, 'g')
  let pattern = ''
  if g:qfixmemo_grep_cword == 1
    let pattern = expand("<cword>")
  endif
  if g:qfixmemo_grep_cword < 0
    let g:qfixmemo_grep_cword = 1
  endif
  let pattern = input(title, pattern)
  if pattern != ''
    let file = '*'
    let file = input('filepattern : ', file)
    if file == ''
      return
    endif
    let @/ = pattern
    if fixmode
      let g:MyGrep_Regexp = 0
      let @/ = '\V'.pattern
    endif
    call s:grep(pattern, file, fixmode)
    call histadd('/', '\V' . @/)
    call histadd('@', pattern)
  endif
endfunction

" FGrep
function! qfixmemo#FGrep()
  call qfixmemo#Grep('fix')
endfunction

if !exists('g:qfixmemo_grep_title')
  let g:qfixmemo_grep_title = 'QFixMemo %MODE%Grep : '
endif
if !exists('g:qfixmemo_search_sort')
  let g:qfixmemo_search_sort = 'mtime'
endif
if !exists('g:qfixmemo_list_sort')
  let g:qfixmemo_list_sort = 'reverse'
endif

function! s:grep(pattern, file, fixmode)
  let g:MyGrep_Regexp = !a:fixmode
  let qflist = qfixlist#search(a:pattern, g:qfixmemo_dir, g:qfixmemo_search_sort, 0, g:qfixmemo_fileencoding, '**/'.a:file)
  return qfixlist#copen(qflist, g:qfixmemo_dir)
endfunction

""""""""""""""""""""""""""""""
" インデント対応アウトライン
""""""""""""""""""""""""""""""
" アウトライン(foldenable)
if !exists('g:qfixmemo_outline_foldenable')
  let g:qfixmemo_outline_foldenable = 1
endif
" アウトライン(foldmethod)
if !exists('g:qfixmemo_outline_foldmethod')
  let g:qfixmemo_outline_foldmethod = 'indent'
endif
" アウトライン(foldexpr)
if !exists('g:qfixmemo_outline_foldexpr')
  let g:qfixmemo_outline_foldexpr = "getline(v:lnum)=~'^[=.*・]'?'>1':'1'"
endif
" アウトライン(syntax)
if !exists('g:qfixmemo_outline_syntax')
  let g:qfixmemo_outline_syntax = 'ezotl'
endif

function! qfixmemo#EzOutline(...)
  if qfixmemo#Init()
    return
  endif
  setlocal noexpandtab

  let id = a:0 ? a:1 : 0
  let fen = s:GetOptionWithID('g:qfixmemo_outline_foldenable', id)
  let fde = s:GetOptionWithID('g:qfixmemo_outline_foldexpr',   id)
  let fdm = s:GetOptionWithID('g:qfixmemo_outline_foldmethod', id)
  let syn = s:GetOptionWithID('g:qfixmemo_outline_syntax',     id)

  let &foldenable          = fen
  exe 'setlocal foldexpr='  .fde
  exe 'setlocal foldmethod='.fdm
  exe 'runtime! syntax/'    .syn.'.vim'
endfunction

function! s:GetOptionWithID(opt, id)
  exe 'let opt='.a:opt.(exists(a:opt.a:id) ? string(a:id) : '')
  return opt
endfunction

""""""""""""""""""""""""""""""
" メニュータイトル
if !exists('g:qfixmemo_menu_title')
  let g:qfixmemo_menu_title = '__menu__'
endif
" メニューキーを使用する
if !exists('g:qfixmemo_menu_hotkey')
  let g:qfixmemo_menu_hotkey = 1
endif

""""""""""""""""""""""""""""""
" カレンダー
if !exists('g:qfixmemo_calendar_wincmd')
  let g:qfixmemo_calendar_wincmd = 'vertical topleft'
  " let g:qfixmemo_calendar_wincmd = 'vertical botright'
  " let g:qfixmemo_calendar_wincmd = 'leftabove'
  " let g:qfixmemo_calendar_wincmd = 'rightbelow'
endif
if !exists('g:qfixmemo_calendar_count')
  let g:qfixmemo_calendar_count = 3
endif

""""""""""""""""""""""""""""""
" sub menu
" サブメニューのタイトル
if !exists('g:qfixmemo_submenu_title')
  let g:qfixmemo_submenu_title = '__submenu__'
endif
" サブメニューのサイズ
if !exists('g:qfixmemo_submenu_size')
  let g:qfixmemo_submenu_size = 30
endif
" サブメニューを常に一定のサイズにする
if !exists('g:qfixmemo_submenu_keepsize')
  let g:qfixmemo_submenu_keepsize = 0
endif
" サブメニューのwrap
if !exists('g:qfixmemo_submenu_wrap')
  let g:qfixmemo_submenu_wrap = 1
endif
" サブメニューを出す方向
if !exists('g:qfixmemo_submenu_direction')
  let g:qfixmemo_submenu_direction = 'topleft vertical'
endif
" サブメニューカレンダーのウィンドウ位置
" ''             非表示
" 'rightbelow'   右か下
" 'leftabove'    左か上
if !exists('g:qfixmemo_submenu_calendar_wincmd')
  let g:qfixmemo_submenu_calendar_wincmd = 'leftabove'
endif
if !exists('g:qfixmemo_submenu_winfixheight')
  let g:qfixmemo_submenu_winfixheight = 1
endif
if !exists('g:qfixmemo_submenu_winfixwidth')
  let g:qfixmemo_submenu_winfixwidth = 1
endif
" サブメニュー自動保存を使用する
if !exists('g:qfixmemo_submenu_autowrite')
  let g:qfixmemo_submenu_autowrite = 1
endif
" サブメニューのシングルウィンドウモード
if !exists('g:qfixmemo_submenu_single_mode')
  let g:qfixmemo_submenu_single_mode = 1
endif

let s:qfixmemo_submenu_title = g:qfixmemo_submenu_title
let s:sb_id = 0
function! qfixmemo#SubMenu(...)
  if qfixmemo#Init('mkdir')
    return
  endif
  let basedir = g:qfixmemo_dir
  if exists('g:qfixmemo_submenu_dir')
    let basedir = g:qfixmemo_submenu_dir
  endif
  let l:count = a:0 && a:1 ? a:1 : count
  let file = s:submenu_mkdir(basedir)
  let bufnum = bufnr(file)
  let winnum = bufwinnr(file)
  if g:qfixmemo_submenu_single_mode
    if winnum != -1 && bufnum == bufnr('%')
      wincmd c
      if l:count == 0 && a:0 == 0
        return
      endif
      let winnum = -1
    endif
    if winnum != -1
      exe winnum . 'wincmd w'
      if l:count == 0 && a:0 == 0
        return
      endif
      wincmd c
    endif
  else
    if bufnum == bufnr('%') && l:count == 0 && a:0 == 0
      wincmd c
      return
    elseif winnum != -1 && l:count == 0 && a:0 == 0
      exe winnum . 'wincmd w'
      return
    endif
  endif
  if a:0 && l:count == 0
    let s:qfixmemo_submenu_title = g:qfixmemo_submenu_title
    let s:sb_id = 0
  elseif l:count
    exe 'let s:qfixmemo_submenu_title = g:qfixmemo_submenu_title'.l:count
    let s:sb_id = l:count
  endif
  let file = s:submenu_mkdir(basedir)
  call s:OpenQFixSubWin(file, s:sb_id)
endfunction

function! s:submenu_mkdir(basedir)
  let pathhead = '\([A-Za-z]:[/\\]\|\~[/\\]\|\.\.\?[/\\]\|[/\\]\)'
  let prevPath = escape(getcwd(), ' ')
  exe 'lchdir ' . escape(expand(a:basedir), ' ')
  let file = expand(s:qfixmemo_submenu_title)
  if file !~ '^'.pathhead
    let file = expand(a:basedir).'/'.file
  endif
  exe 'lchdir ' . prevPath
  let dir = fnamemodify(file, ':h')
  if !isdirectory(dir)
    call mkdir(dir, 'p')
  endif
  return file
endfunction

function! s:OpenQFixSubWin(file, id)
  let file = a:file
  let swid = a:id
  let winnum = bufwinnr(file)
  if winnum != -1
    if winnr() != winnum
      exe winnum . 'wincmd w'
    endif
    return
  endif
  let windir  = s:GetOptionWithID('g:qfixmemo_submenu_direction', swid)
  let winsize = s:GetOptionWithID('g:qfixmemo_submenu_size', swid)
  let keepsize = s:GetOptionWithID('g:qfixmemo_submenu_keepsize', swid)

  let bufnum = bufnr(file)
  if bufnum == -1
    let wcmd = expand(file)
      augroup QFixMemoSubMenu
        if windir =~ 'vert'
          exe 'au BufEnter '.fnamemodify(file, ':t').' call <SID>QFixMemoSubMenuResize('.winsize.', "vertical")'
        else
          exe 'au BufEnter '.fnamemodify(file, ':t').' call <SID>QFixMemoSubMenuResize('.winsize.')'
        endif
        exe 'au BufLeave '.fnamemodify(file, ':t').' call <SID>QFixMemoSubMenuBufLeave()'
        if g:qfixmemo_submenu_autowrite
          exe 'au BufWinLeave,VimLeave '.fnamemodify(file, ':t').' call <SID>SubMenuBufAutoWrite()'
        endif
      augroup END
  else
    let wcmd = '+buffer' . bufnum
  endif
  let opt = ''
  " let opt = ' ++enc='.g:qfixmemo_fileencoding .' ++ff='.g:qfixmemo_fileformat
  exe 'silent! ' . windir . ' ' . (winsize == 0 ? '' : string(winsize)) ' split ' .opt. ' ' . wcmd
  exe 'set fenc='.g:qfixmemo_fileencoding
  exe 'set ff='.g:qfixmemo_fileformat

  if g:qfixmemo_submenu_autowrite
    setlocal buftype=nowrite
  endif
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal foldcolumn=0
  setlocal nobuflisted
  setlocal nolist
  let wfh = s:GetOptionWithID('g:qfixmemo_submenu_winfixheight', swid)
  let wfw = s:GetOptionWithID('g:qfixmemo_submenu_winfixwidth', swid)
  let &winfixheight = wfh
  let &winfixwidth = wfw
  exe 'let &wrap='.s:GetOptionWithID('g:qfixmemo_submenu_wrap', swid)
  nnoremap <silent> <buffer> q    :close<CR>
  nnoremap <silent> <buffer> <CR> :call QFixMemoUserModeCR()<CR>
  if exists('g:qfixmemo_submenu_writekey')
    let cmd = g:qfixmemo_submenu_writekey
    exe 'nnoremap <silent> <buffer> ' . cmd . ' :<C-u>call qfixmemo#ForceWrite("ignore")<CR>'
  endif
  let cmd = g:qfixmemo_mapleader . 'w'
  exe 'nnoremap <silent> <buffer> ' . cmd . ' :<C-u>call qfixmemo#ForceWrite("ignore")<CR>'
  let b:qfixmemo_bufwrite_pre = 0
  call s:syntaxHighlight()
  if bufnum == -1 && !filereadable(expand(file))
    call qfixmemo_msg#submenu()
  endif
  call QFixMemoSubMenuOutline(swid)
  if exists('b:submenu_width')
    exe 'vertical resize '.b:submenu_width
  elseif windir =~ 'vert'
    if !exists('b:submenu_width')
      let b:submenu_width = winsize
    endif
    exe 'vertical resize '.winsize
  endif
  if !exists('b:submenu_height')
    let b:submenu_height = winheight(0)
  endif
  if !exists('b:submenu_keepsize')
    let b:submenu_keepsize = keepsize
  endif
  let wincmd = s:GetOptionWithID('g:qfixmemo_submenu_calendar_wincmd', swid)
  if wincmd != ''
    let wincmd = wincmd . (windir =~ 'vert' ? '' : ' vertical')
    silent! call howm_calendar#init()
    call QFixMemoCalendar(wincmd, '__Cal__', 1, 'parent'. (keepsize ? '' : 'resize'))
  endif
  exe 'setlocal statusline=\ '.fnamemodify(file, ':t')
  if exists('*QFixMemoSubMenuBufWinEnter')
    call QFixMemoSubMenuBufWinEnter()
  endif
  exe 'normal! zz'
endfunction

function s:QFixMemoSubMenuBufLeave()
  if b:submenu_keepsize
    return
  endif
  let b:submenu_height = winheight(0)
  let b:submenu_width  = winwidth(0)
  exe "let g:calendar_width_".bufnr('%')."=winwidth(0)"
endfunction

function s:QFixMemoSubMenuResize(winsize, ...)
  let winsize = a:winsize
  if a:0
    let winsize = b:submenu_width < a:winsize ? a:winsize : b:submenu_width
    exe 'vertical resize '.winsize
  else
    let winsize = b:submenu_height < a:winsize ? a:winsize : b:submenu_height
    let w = &lines - winheight(0) - &cmdheight - (&laststatus > 0 ? 1 : 0)
    if w > 0
      if winheight(0) < winsize
        exe 'resize '.winsize
      endif
    endif
  endif
endfunction

function! qfixmemo#SubMenuBufAutoWrite(file)
  call s:SubMenuBufAutoWrite(a:file)
endfunction
let s:qfixmemo_fileencoding = g:qfixmemo_fileencoding
function! s:SubMenuBufAutoWrite(...)
  let file = fnamemodify(expand('<afile>'), ':p')
  if a:0
    let file = a:1
  endif
  let str = getbufline(file, 1, '$')
  if str == ['']
    call delete(file)
    return
  endif
  let from = &enc
  let to   = s:qfixmemo_fileencoding
  call map(str, 'iconv(v:val, from, to)')
  if filereadable(file) && str == readfile(file)
    return
  endif
  let dir = fnamemodify(file, ':h')
  if !isdirectory(dir)
    call mkdir(dir, 'p')
  endif
  call writefile(str, file)
  call qfixmemo#AddKeyword()
endfunction

" サブメニューでアウトラインを使用する
if !exists('g:qfixmemo_submenu_outline')
  let g:qfixmemo_submenu_outline = 1
endif

" デフォルトアウトラインモード
" 外部で定義されている場合はそちらが優先されます。
silent! function QFixMemoSubMenuOutline(id)
  if !g:qfixmemo_submenu_outline
    return
  endif
  let id = a:id
  setlocal ts=2 sw=2 sts=2
  call qfixmemo#EzOutline(id)
endfunction

""""""""""""""""""""""""""""""
" Quickfix
""""""""""""""""""""""""""""""
" for qfixwin/qfixmru
function! s:qfBufWinEnter()
  nnoremap <buffer> <silent> @    :call qfixmemo#Cmd_AT('normal')<CR><ESC>
  vnoremap <buffer> <silent> @    :call qfixmemo#Cmd_AT('visual')<CR><ESC>
  nnoremap <buffer> <silent> #    :call qfixmemo#Cmd_Replace('remove')<CR>

  nnoremap <buffer> <silent> R    :call qfixmemo#Cmd_RD('Remove')<CR>
  vnoremap <buffer> <silent> R    :call qfixmemo#Cmd_RD('Remove')<CR>
  nnoremap <buffer> <silent> D    :call qfixmemo#Cmd_RD('Delete')<CR>
  vnoremap <buffer> <silent> D    :call qfixmemo#Cmd_RD('Delete')<CR>
  nnoremap <buffer> <silent> <F5> :call qfixmemo#RandomWalk(g:qfixmemo_random_file)<CR>
  nnoremap <buffer> <silent> x  :call qfixmemo#Cmd_X()<CR>
  " vnoremap <buffer> <silent> x  :call QFixHowmCmd_X()<CR>
  nnoremap <buffer> <silent> X  :call qfixmemo#Cmd_X('move')<CR>
  " vnoremap <buffer> <silent> X  :call QFixHowmCmd_X('move')<CR>
  if exists('*QFixMemoQFBufWinEnterPost')
    call QFixMemoQFBufWinEnterPost()
  endif
endfunction

function! QFixPreviewReadOpt(file)
  let file = a:file
  let opt = ''
  if g:qfixmemo_forceencoding && IsQFixMemo(file)
    let opt = ' ++enc='.g:qfixmemo_fileencoding .' ++ff='.g:qfixmemo_fileformat
  endif
  return opt
endfunction

function! qfixmemo#MRUInit()
  if g:QFixMRU_state || g:QFixMRU_VimLeaveWrite
    return
  endif
  " call QFixMRURead()
  let g:QFixMRU_VimLeaveWrite = 1
endfunction

function! qfixmemo#TitleRegxp()
  let l:qfixmemo_title = escape(g:qfixmemo_title, g:qfixmemo_escape)
  let regxp = '^'.l:qfixmemo_title. '\([^'.g:qfixmemo_title[0].']\+\|\s*$\)'
  return regxp
endfunction

" for qfixwin
function! QFixFtype(file)
  if g:qfixmemo_filetype == '' || !IsQFixMemo(a:file)
    return 0
  endif
  if g:qfixmemo_filetype =~ '\.'
    call s:filetype()
  else
    let syn = g:qfixmemo_filetype
    exe 'runtime! syntax/'.syn.'.vim'
    call s:syntaxHighlight()
  endif
  return 1
  let g:qfixmemo_keyword_file = '~/.qfixmemo-keys'
endfunction

" for qfixwin
function! qfixmemo#Cmd_AT(mode) range
  if qfixmemo#Init()
    return
  endif
  let save_cursor = getpos('.')
  let g:QFixMRU_Disable = 1

  let flist = []
  let llist = []

  let cnt = line('$')
  let firstline = a:firstline
  if a:firstline != a:lastline || a:mode =~ 'visual'
    let cnt = a:lastline - a:firstline + 1
  else
    let firstline = 1
  endif

  let rez = []
  let elist = []
  let h = g:QFix_Height
  let tpattern = qfixmemo#TitleRegxp()
  for n in range(cnt)
    let file = QFixGet('file', firstline+n)
    let lnum = QFixGet('lnum', firstline+n)
    let [entry, flnum, llnum] = QFixMRUGet('entry', file, lnum, tpattern)
    let tdesc = entry[0] . flnum . llnum
    if count(elist, tdesc) != 0
      continue
    endif
    call add(elist, tdesc)
    if g:qfixmemo_separator != ''
      let str = printf(g:qfixmemo_separator, file)
      let entry = insert(entry, str, 1)
    endif
    let rez = extend(rez, entry)
  endfor

  let g:QFix_Height = h
  call qfixmemo#Edit(g:qfixmemo_filename)
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile

  silent! %delete _
  call setline(1, rez)
  call cursor(1, 1)

  call setpos('.', save_cursor)
  exe 'normal! z.'
  silent! wincmd p
  let g:QFixMRU_Disable = 0
endfunction

" for qfixwin
function! qfixmemo#Cmd_Replace(mode)
  if qfixmemo#Init()
    return
  endif
  let prevPath = escape(getcwd(), ' ')
  let sq = QFixGetqflist()
  let idx = 0
  let nsq = []
  let tpattern = qfixmemo#TitleRegxp()
  for d in sq
    let bufnr = d['bufnr']
    let file = bufname(bufnr)
    let lnum = d['lnum']
    let [text, lnum, llnum] = QFixMRUGet('title', file, lnum, tpattern)
    let sqdat = {'bufnr': bufnr, 'lnum': lnum, 'text': text}
    call filter(nsq, "(v:val['bufnr'] == ".bufnr . '&&'. "v:val['text'] == '".text ."') == 0")
    call add(nsq, sqdat)
  endfor
  call QFixSetqflist(nsq)
  exe 'lchdir ' . prevPath
  call QFixCopen()
  call cursor(1, 1)
  return
endfunction

" for qfixwin
function! qfixmemo#Cmd_RD(cmd) range
  if qfixmemo#Init()
    return
  endif
  let fline = a:firstline - 1
  let lline = a:lastline - 1
  if a:cmd == 'Delete'
    let mes = "!!!Delete file(s)"
  else
    let mes = printf("!!!Remove to (%s)", g:qfixmemo_dir)
  endif
  let choice = confirm(mes, "&Yes\n&No", 2, "W")
  if choice != 1
    return
  endif
  let save_cursor = getpos('.')
  let idx = fline
  let qf = QFixGetqflist()
  for n in range(fline, lline)
    let file = fnamemodify(bufname(qf[idx]['bufnr']), ':p')
    if a:cmd == 'Delete'
      call delete(file)
    elseif a:cmd == 'Remove'
      let dst = fnamemodify(g:qfixmemo_dir, ':p') . fnamemodify(file, ':t')
      call rename(file, dst)
    endif
    call remove(qf, idx)
  endfor
  call QFixSetqflist(qf)
  call QFixCopen()
  call setpos('.', save_cursor)
endfunction

" for qfixwin
function! qfixmemo#Cmd_X(...) range
  if qfixmemo#Init()
    return
  endif
  let lnum = QFixGet('lnum')
  let qf = QFixGetqflist()
  if len(qf) == 0
    return
  endif
  let g:QFixMRU_Disable = 1
  let l = line('.') - 1
  let lnum = qf[l]['lnum']
  let file = bufname(qf[l]['bufnr'])
  let mes = "!!!Delete Entry!"
  if a:0 > 0
    let mes = "!!!Move Entry!"
  endif
  let choice = confirm(mes, "&Yes\n&No", 2, "W")
  if choice == 1
    call qfixmemo#Edit(file)
    call cursor(lnum, 1)
    if a:0 > 0
      call qfixmemo#DeleteEntry('Move')
    else
      call qfixmemo#DeleteEntry()
    endif
    let s:qfixmemoWriteUpdateTime = 0
    write!
    let s:qfixmemoWriteUpdateTime = 1
    silent! wincmd p
    let qf = QFixGetqflist()
    call remove(qf, l)
    call QFixSetqflist(qf)
    call cursor(l+1, 1)
  endif
  let g:QFixMRU_Disable = 1
endfunction

""""""""""""""""""""""""""""""
" キーワードを使用する
if !exists('g:qfixmemo_use_keyword')
  let g:qfixmemo_use_keyword = 1
endif
" キーワードファイル
if !exists('g:qfixmemo_keyword_file')
  let g:qfixmemo_keyword_file = '~/.qfixmemo-keys'
endif
" オートリンク用キーワードの処理
" 0 : 検索
" 1 : qfixmemo_keyword_dir内の対応するファイルを開く
" 2 : vimwikiを使用
if !exists('g:qfixmemo_keyword_mode')
  let g:qfixmemo_keyword_mode = 1
endif
" keyword対応ファイル作成ディレクトリ
if !exists('g:qfixmemo_keyword_dir')
  let g:qfixmemo_keyword_dir = 'keyword'
endif
" キーワードに登録しない正規表現
if !exists('g:qfixmemo_keyword_exclude')
  let g:qfixmemo_keyword_exclude = ''
endif
" キーワード開始正規表現
if !exists('g:qfixmemo_keyword_pre')
  let g:qfixmemo_keyword_pre = '\[\['
endif
" キーワード終了正規表現
if !exists('g:qfixmemo_keyword_post')
  let g:qfixmemo_keyword_post = '\]\]'
endif

" オートリンク読込
function! qfixmemo#LoadKeyword(...)
  if g:qfixmemo_use_keyword == 0
    return
  endif
  if a:0 == 0
    let kfile = expand(g:qfixmemo_keyword_file)
    if !filereadable(kfile)
      return
    endif
    let s:KeywordDic = readfile(kfile)
  endif

  let s:KeywordHighlight = ''
  for keyword in s:KeywordDic
    if keyword =~ '^\s*$'
      continue
    endif
    if g:qfixmemo_keyword_exclude != '' && keyword =~ g:qfixmemo_keyword_exclude
      continue
    endif
    let keyword = substitute(keyword, '\s*$', '', '')
    let keyword = substitute(keyword, '^\s*', '', '')
    let keyword = escape(keyword, '\\')
    let s:KeywordHighlight = s:KeywordHighlight.''.keyword.'\|'
  endfor
  silent! syn clear qfixmemoKeyword
  let s:KeywordHighlight = substitute(s:KeywordHighlight, '\\|\s*$', '', '')
  if s:KeywordHighlight != '' && IsQFixMemo(expand('%:p'))
    exe 'syn match qfixmemoKeyword display "\V'.escape(s:KeywordHighlight, '"').'"'
  endif
endfunction

" オートリンク保存
let s:KeywordDic = []
let s:KeywordHighlight = ''
function! qfixmemo#AddKeyword(...)
  if g:qfixmemo_use_keyword == 0 && (!a:0 || !a:1)
    return
  endif
  let pre  = g:qfixmemo_keyword_pre
  let post = g:qfixmemo_keyword_post
  let kpattern = pre.'.\{-}'.post

  let addkey = 0
  if a:0
    let list = a:1
    call filter(list, "v:val =~ '".kpattern."'")
  else
    let list = s:GetKeywordStr(kpattern)
  endif
  for text in list
    while 1
      let stridx = match(text, pre)
      let pairpos = matchend(text, post)
      if stridx == -1 || pairpos == -1
        break
      endif
      let keyword = matchstr(text, pre.'\zs'.'.\{-}'.'\ze'.post)
      let keyword = substitute(keyword, '^\s*', '', '')
      let keyword = substitute(keyword, '\s*$', '', '')
      let text = strpart(text, pairpos)
      if g:qfixmemo_keyword_exclude != '' && keyword =~ g:qfixmemo_keyword_exclude
        continue
      endif
      if count(s:KeywordDic, keyword) == 0 && keyword !~ '^\s*$'
        let addkey += 1
        call add(s:KeywordDic, keyword)
      endif
    endwhile
  endfor

  if exists('g:howm_clink_pattern') && g:howm_clink_pattern != ''
    if a:0
      let list = a:1
      call filter(list, "v:val =~ '" . g:howm_clink_pattern .".\\+'")
    else
      let list = s:GetKeywordStr(g:howm_clink_pattern .'.\+')
    endif
    for keyword in list
      let keyword = substitute(keyword, '^.*'.g:howm_clink_pattern.'\s*', '', '')
      let keyword = substitute(keyword, '\s*$', '', '')
      if g:qfixmemo_keyword_exclude != '' && keyword =~ g:qfixmemo_keyword_exclude
        continue
      endif
      if count(s:KeywordDic, keyword) == 0 && keyword !~ '^\s*$'
        let addkey += 1
        call add(s:KeywordDic, keyword)
      endif
    endfor
  endif

  if addkey
    call sort(s:KeywordDic)
    call reverse(s:KeywordDic)
    let kfile = expand(g:qfixmemo_keyword_file)
    call writefile(s:KeywordDic, kfile)
    call qfixmemo#LoadKeyword('highlight')
  endif
endfunction

function! s:GetKeywordStr(regxp)
  let regxp = a:regxp
  let glist = []
  let save_cursor = getpos('.')
  call cursor(1, 1)
  let lnum = search(regxp, 'cW')
  while 1
    if lnum == 0
      break
    endif
    call add(glist, getline(lnum))
    let lnum = search(regxp, 'W')
  endwhile
  call setpos('.', save_cursor)
  return glist
endfunction

" オートリンク再作成
function! qfixmemo#RebuildKeyword()
  if qfixmemo#Init()
    return
  endif
  redraw | echo 'QFixMemo : Rebuild Keyword...'

  let pattern = g:qfixmemo_keyword_pre . '.*' .g:qfixmemo_keyword_post
  let kfile = '*.'.s:howm_ext.' *.'.g:qfixmemo_ext
  let qflist = qfixlist#search(pattern, g:qfixmemo_dir, 'nop', 0, g:qfixmemo_fileencoding, '**/'.kfile)
  if exists('g:howm_clink_pattern') && g:howm_clink_pattern != ''
    let pattern = g:howm_clink_pattern
    let extlist = qfixlist#search(pattern, g:qfixmemo_dir, 'nop', 0, g:qfixmemo_fileencoding, '**/'.kfile)
    call extend(qflist, extlist)
  endif

  let extlist = QFixMemoRebuildKeyword(g:qfixmemo_dir, g:qfixmemo_fileencoding)
  let pattern = g:qfixmemo_keyword_pre.'.*'.g:qfixmemo_keyword_post

  if exists('g:howm_clink_pattern') && g:howm_clink_pattern != ''
    let pattern = '\('.g:howm_clink_pattern.'\|'.pattern.'\)'
  endif

  let basedir = g:qfixmemo_dir
  if exists('g:qfixmemo_submenu_dir')
    let basedir = g:qfixmemo_submenu_dir
  endif
  let prevPath = escape(getcwd(), ' ')
  exe 'lchdir ' . escape(expand(basedir), ' ')
  let file = fnamemodify(g:qfixmemo_submenu_title, ':p')
  let saved_sq = getloclist(0)
  silent! exe 'lvimgrep /'.pattern.'/j '. escape(file, ' ')
  call extend(extlist, getloclist(0))
  call setloclist(0, saved_sq)
  exe 'lchdir ' . prevPath

  for n in range(len(extlist))
    if !exists('extlist[n]["filename"]')
      let extlist[n]['filename'] = fnamemodify(bufname(extlist[n]['bufnr']), ':p')
    endif
  endfor
  call extend(qflist, extlist)
  let from = g:qfixmemo_fileencoding
  let to   = &enc
  let str = []
  for d in qflist
    let lnum = d['lnum']
    let glist = readfile(d['filename'])
    call add(str, glist[lnum-1])
  endfor
  call map(str, 'iconv(v:val, from, to)')

  let s:KeywordDic = []
  call qfixmemo#AddKeyword(str)
  if len(qflist)
    call QFixSetqflist(qflist)
    call QFixCopen()
    call cursor(1, 1)
    redraw | echo 'QFixMemo : done.'
  else
    call delete(expand(g:qfixmemo_keyword_file))
    call qfixmemo#LoadKeyword('highlight')
    redraw | echo 'QFixMemo : no keywords.'
  endif
endfunction

" 外部で定義されたキーワードをgetqflist()と同じ形式で返す
if !exists('*QFixMemoRebuildKeyword')
function QFixMemoRebuildKeyword(dir, fenc)
  return []
endfunction
endif

if !exists('*QFixMemoCR_vimwiki')
function! QFixMemoCR_vimwiki()
  if g:qfixmemo_use_howm_schedule
    call howm_schedule#Init()
    if QFixHowmScheduleAction()
      return 1
    endif
  endif
  call qfixmemo#Init()
  if qfixmemo#OpenCursorline()
    return 1
  endif
  if qfixmemo#SwitchAction()
    return 1
  endif
  call vimwiki#follow_link('nosplit')
  return
endfunction
endif

if !exists('*QFixMemoUserModeCR')
function QFixMemoUserModeCR(...)
  if exists('*QFixMemoCR_'.&filetype)
    call eval('QFixMemoCR_'.&filetype.'()')
    return
  endif
  if qfixmemo#CR()
    return
  endif
  exe "normal! \<CR>"
endfunction
endif

function! qfixmemo#CR(...)
  if g:qfixmemo_use_howm_schedule
    call howm_schedule#Init()
    if QFixHowmScheduleAction()
      return 1
    endif
  endif
  call qfixmemo#Init()
  if qfixmemo#OpenCursorline()
    return 1
  endif
  if qfixmemo#SwitchAction()
    return 1
  endif
  if qfixmemo#OpenKeywordLink()
    return 1
  endif
  return 0
endfunction

" カーソル位置のリンクを開く
function! qfixmemo#OpenCursorline()
  return openuri#open()
endfunction

" オートリンクを開く
function! qfixmemo#OpenKeywordLink()
  let save_cursor = getpos('.')
  let col = col('.')
  let lstr = getline('.')

  let word = ''
  if exists('g:howm_clink_pattern') && g:howm_clink_pattern != ''
    let idx = match(lstr, g:howm_clink_pattern)
    if idx > -1 && idx <= col
      let word = matchstr(lstr, g:howm_clink_pattern . '.*')
      let word = substitute(word, g:howm_clink_pattern . '\s*\|\s*$', '', 'g')
    endif
  endif
  if exists('g:howm_glink_pattern') && g:howm_glink_pattern != ''
    let idx = match(lstr, g:howm_glink_pattern)
    if idx > -1 && idx <= col
      let word = matchstr(lstr, g:howm_glink_pattern . '.*')
      let word = substitute(word, g:howm_glink_pattern . '\s*\|\s*$', '', 'g')
    endif
  endif
  if word != ''
    let g:MyGrep_Regexp = 0
    let qflist = qfixlist#search(word, g:qfixmemo_dir, 'mtime', 0, g:qfixmemo_fileencoding, '**/*')
    if exists('g:howm_clink_pattern') && g:howm_clink_pattern != ''
      let qflist = sort(qflist, "<SID>qfixmemoSortHowmClink")
    endif
    if len(qflist)
      call qfixlist#copen(qflist, g:qfixmemo_dir)
    else
      redraw|echo 'QFixMemo : keyword not found. (use "'.escape(g:qfixmemo_mapleader, '\\').'rk" : Rebuild keyword)'
    endif
    return 1
  endif

  for word in s:KeywordDic
    let len = strlen(word)
    let pos = stridx(lstr, word)
    if pos == -1 || col < pos+1
      continue
    endif
    let str = strpart(lstr, col-len, 2*len)
    if stridx(str, word) > -1
      let file = word
      if g:qfixmemo_keyword_mode == 0
        let g:MyGrep_Regexp = 0
        let qflist = qfixlist#search(word, g:qfixmemo_dir, 'mtime', 0, g:qfixmemo_fileencoding, '**/*')
        if exists('g:howm_clink_pattern') && g:howm_clink_pattern != ''
          let qflist = sort(qflist, "<SID>qfixmemoSortHowmClink")
        endif
        if len(qflist)
          call qfixlist#copen(qflist, g:qfixmemo_dir)
        else
          redraw|echo 'QFixMemo : keyword not found. (use "'.escape(g:qfixmemo_mapleader, '\\').'rk" : Rebuild keyword)'
        endif
        return 1
      elseif g:qfixmemo_keyword_mode == 1
        let file = substitute(file, '[\\/:*?"|<>]', '_', 'g')
        if g:qfixmemo_keyword_dir != ''
          let file = g:qfixmemo_keyword_dir . '/' . file
        endif
        call qfixmemo#Edit(file)
      elseif g:qfixmemo_keyword_mode == 2
        let cmd = ':e '
        let subdir = vimwiki#current_subdir()
        call vimwiki#open_link(cmd, subdir.file)
      endif
      return 1
    endif
  endfor
  return 0
endfunction

" スイッチアクション
function! qfixmemo#SwitchAction()
  let save_cursor = getpos('.')
  if exists('g:qfixmemo_switch_action')
    if QFixMemoSwitchAction(g:qfixmemo_switch_action)
      return 1
    endif
  endif
  call setpos('.', save_cursor)
  for i in range(1, g:qfixmemo_switch_action_max)
    if !exists('g:qfixmemo_switch_action'.i)
      continue
    endif
    exe 'let action = g:qfixmemo_switch_action'.i
    if QFixMemoSwitchAction(action)
      return 1
    endif
  endfor
  call setpos('.', save_cursor)
  if QFixMemoSwitchAction(g:qfixmemo_swlist_action)
    return 1
  endif
  call setpos('.', save_cursor)
  return 0
endfunction

function! QFixMemoSwitchAction(list, ...)
  let prevline = line('.')
  let max = len(a:list)
  let didx = 0
  for pattern in a:list
    let didx = (didx == max-1 ? 0 : didx+1)
    let nr = strlen(pattern)
    let cpattern = a:list[didx]
    let [lnum, start] = searchpos('\V'.escape(pattern, '\'), 'ncb', line('.'))
    if lnum == 0 || col('.') >= start+nr
      continue
    endif
    if pattern == '{_}'
      " let cpattern = strftime('['.g:qfixmemo_timeformat.'].')
    endif
    let prevcol = (a:0 == 0 ? start : col('.'))
    let nr = strlen(substitute(pattern, '.', '.', 'g'))
    call cursor(prevline, start)
    exe 'normal! c'.nr.'l'.cpattern
    call cursor(prevline, prevcol)
    return 1
  endfor
  return 0
endfunction

""""""""""""""""""""""""""""""
" カレントバッファのエントリを更新時間順にソート
function! qfixmemo#SortEntry(mode)
  if qfixmemo#Init()
    return
  endif
  let elist = s:qfixmemoGetEntryList()
  if elist == []
    return
  endif
  " ソート
  if a:mode == 'Normal'
    let elist = sort(elist, "<SID>qfixmemoSortEntryMtime")
  else
    let elist = sort(elist, "<SID>qfixmemoSortEntryMtimeR")
  endif
  " 書き換え
  let glist = []
  for d in elist
    call extend(glist, d['text'])
  endfor
  silent! %delete _
  call setline(1, glist)

  call cursor(1, 1)
  let s:qfixmemoWriteUpdateTime = 0
  write
  let s:qfixmemoWriteUpdateTime = 1
  unlet! elist
endfunction

" カレントバッファのエントリリストを得る
function! s:qfixmemoGetEntryList()
  let save_cursor = getpos('.')

  let elist = []
  let titlepattern = qfixmemo#TitleRegxp()
  let timepattern = g:qfixmemo_timestamp_regxp

  let fline = 1
  while 1
    let [entry, fline, lline] = QFixMRUGet('entry', '%', fline, titlepattern)
    if fline == -1
      break
    endif
    let title = entry[0]
    let ttext = deepcopy(entry)
    let tline = strftime(g:qfixmemo_timeformat, 0)
    call filter(entry, "v:val =~ '" . timepattern ."'")
    if len(entry)
      let tline = entry[0]
    endif
    let mydict = {'fline': fline, 'eline': lline, 'mtime': tline, 'text': ttext, 'title': title}
    call add(elist, mydict)
    let fline = lline+1
  endwhile
  return elist
endfunction

function! s:qfixmemoSortEntryMtime(v1, v2)
  return (a:v1.mtime <= a:v2.mtime?1:-1)
endfunction

function! s:qfixmemoSortEntryMtimeR(v1, v2)
  return (a:v1.mtime >= a:v2.mtime?1:-1)
endfunction

function! s:qfixmemoSortHowmClink(v1, v2)
  if a:v2.text =~ g:howm_clink_pattern && a:v1.text !~ g:howm_clink_pattern
    return 1
  elseif a:v1.text =~ g:howm_clink_pattern && a:v2.text !~ g:howm_clink_pattern
    return -1
  endif
  if a:v1.mtime == a:v2.mtime
    if a:v1.filename != a:v2.filename
      return (a:v1['filename'] < a:v2['filename']?1:-1)
    endif
    return (a:v1['lnum']+0 > a:v2['lnum']+0?1:-1)
  endif
  return (a:v1['mtime'] < a:v2['mtime']?1:-1)
endfunction

""""""""""""""""""""""""""""""
function! qfixmemo#Syntax()
  if g:qfixmemo_filetype != ''
    exe 'setlocal filetype=' . g:qfixmemo_filetype
  endif
  call s:syntaxHighlight()
endfunction

