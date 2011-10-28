"=============================================================================
"    Description: QFixMemo
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home  (Japanese)
"  Last Modified: 0000-00-00 00:00
"=============================================================================
let s:Version = 0.01
scriptencoding utf-8

"=============================================================================
if exists('g:disable_qfixmemo') && g:disable_qfixmemo == 1
  finish
endif
if exists('g:qfixmemo_version') && g:qfixmemo_version < s:Version
  unlet loaded_qfixmemo
endif
if exists('g:loaded_qfixmemo') && !exists('fudist')
  finish
endif
if v:version < 700 || &cp
  finish
endif
let g:loaded_qfixmemo = 1
let g:qfixmemo_version = s:Version

let s:debug = 0
if exists('g:fudist') && g:fudist
  let s:debug = 1
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
if !exists('g:qfixmemo_ext')
  let g:qfixmemo_ext           = 'txt'
endif

" キーマップリーダー
if !exists('g:qfixmemo_mapleader')
  let g:qfixmemo_mapleader     = 'g,'
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

" QFixMemoのシンタックスハイライト設定
" 0 : 何も設定しない
" 1 : タイトル行、キーワード
" 2 : タイトル行、キーワード、タイムスタンプ
" 3 : タイトル行、キーワード、タイムスタンプ、予定・TODO
if !exists('g:qfixmemo_syntax')
  let g:qfixmemo_syntax = 3
endif

" 新規メモファイル名
if !exists('g:qfixmemo_filename')
  let g:qfixmemo_filename      = '%Y/%m/%Y-%m-%d-%H%M%S'
endif
" 日記ファイル名
if !exists('g:qfixmemo_diary')
  let g:qfixmemo_diary         = 'diary/%Y-%m-%d'
endif
" クイックメモファイル名
if !exists('g:qfixmemo_quickmemo')
  let g:qfixmemo_quickmemo     = 'Qmem-00-0000-00-00-000000'
endif
" ペアファイルの作成先ディレクトリ
if !exists('g:qfixmemo_pairfile_dir')
  let g:qfixmemo_pairfile_dir  = 'pairfile'
endif

" タイムスタンプフォーマット
if !exists('g:qfixmemo_timeformat')
  let g:qfixmemo_timeformat = '[%Y-%m-%d %H:%M]'
  if exists('g:QFixHowm_DatePattern')
    let g:qfixmemo_timeformat = '['. g:QFixHowm_DatePattern . ' %H:%M]'
  endif
endif

" 予定・TODO識別子
if !exists('g:qfixmemo_scheduleext')
  let g:qfixmemo_scheduleext = '-@!+~.'
endif
function! qfixmemo#SetTimeFormatRegxp(fmt)
  let regxp = a:fmt
  let regxp = '^'.escape(regxp, '[]~*.#')
  let regxp = substitute(regxp, '\C%Y', '[0-9][0-9][0-9][0-9]', 'g')
  let regxp = substitute(regxp, '\C%m', '[0-1][0-9]', 'g')
  let regxp = substitute(regxp, '\C%d', '[0-3][0-9]', 'g')
  let regxp = substitute(regxp, '\C%H', '[0-2][0-9]', 'g')
  let regxp = substitute(regxp, '\C%M', '[0-5][0-9]', 'g')
  let regxp = substitute(regxp, '\C%S', '[0-5][0-9]', 'g')
  return regxp
endfunction
let s:qfixmemo_timeformat = qfixmemo#SetTimeFormatRegxp(g:qfixmemo_timeformat)

if exists('g:qfixmemo_scheduleformat')
  let s:qfixmemo_scheduleformat = g:qfixmemo_scheduleformat
else
  let s:qfixmemo_scheduleformat = '^\s*\[\d\{4}[-/]\d\{2}[-/]\d\{2}\( \d\{2}\(:\d\{2}\)\{1,2}\)\?\]['.g:qfixmemo_scheduleext.']'
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
  let g:qfixmemo_menubar       = 1
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

" キーワードを使用する
if !exists('g:qfixmemo_use_keyword')
  let g:qfixmemo_use_keyword = 1
endif

" スイッチアクションの最大数
if !exists('g:qfixmemo_switch_action_max')
  let g:qfixmemo_switch_action_max = 8
endif

" ランダム表示保存ファイル
if !exists('g:qfixmemo_random_file')
  let g:qfixmemo_random_file = '~/.qfixmemo-random'
endif
" ランダム表示ファイル更新時間(秒)
if !exists('g:qfixmemo_random_time')
  let g:qfixmemo_random_time = 10*24*60*60
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

" 新規ファイル作成時のオプション
if !exists('g:qfixmemo_editcmd')
  let g:qfixmemo_editcmd = ''
endif
if !exists('g:qfixmemo_splitmode')
  let g:qfixmemo_splitmode = 0
endif

" エントリ一覧表示にキャッシュを使用する
if !exists('g:qfixmemo_use_list_cache')
  let g:qfixmemo_use_list_cache = 1
endif

" 自動生成ファイル名(,W ,X)
if !exists('g:qfixmemo_auto_generate_filename')
  let g:qfixmemo_auto_generate_filename = '%Y-%m-%d-%H%M%S'
endif

let s:howm_ext = 'howm'
" 常にqfixmemoファイルとして扱うファイルの正規表現
if !exists('g:qfixmemo_isqfixmemo_regxp')
  let g:qfixmemo_isqfixmemo_regxp = '\c\.'.s:howm_ext.'$'
endif

""""""""""""""""""""""""""""""
" User function
""""""""""""""""""""""""""""""
" キーマップ
silent! function QFixMemoKeymapPost()
  " nnoremap <silent> <Leader>C :<C-u>call qfixmemo#Edit(g:qfixmemo_filename)<CR>
endfunction

" ローカルキーマップ
silent! function QFixMemoLocalKeymapPost()
  " nnoremap <silent> <buffer> <LocalLeader>f :<C-u>call qfixmemo#FGrep()<CR>
endfunction

" BufNewFile,BufRead
silent! function QFixMemoBufRead()
endfunction

" BufReadPost
silent! function QFixMemoBufReadPost()
endfunction

" BufWinEnter
silent! function QFixMemoBufWinEnter()
endfunction

" BufEnter
silent! function QFixMemoBufEnter()
endfunction

" BufWritePre
silent! function QFixMemoBufWritePre()
  " タイトル行付加
  call qfixmemo#AddTitle()
  " タイムスタンプ付加
  call qfixmemo#AddTime()
  " タイムスタンプアップデート
  " call qfixmemo#UpdateTime()
  " キーワードリンク
  call qfixmemo#AddKeyword()
  " ファイル末の空行を削除
  call qfixmemo#DeleteNullLines()
endfunction

" BufWritePost
silent! function QFixMemoBufWritePost()
endfunction

" アウトラインコマンド
silent! function QFixMemoOutline()
  silent! exe "normal! zi"
endfunction

" タイトル検索用正規表現設定
silent! function QFixMemoTitleRegxp()
  let g:qfixmemo_ext = tolower(g:qfixmemo_ext)
  let l:qfixmemo_title = escape(g:qfixmemo_title, g:qfixmemo_escape)
  if !exists('g:QFixMRU_Title["'.g:qfixmemo_ext.'"]')
    let g:QFixMRU_Title[g:qfixmemo_ext] = '^'.l:qfixmemo_title. '\([^'.g:qfixmemo_title[0].']\|$\)'
  endif
  " 使用するgrepに合わせて設定します
  if !exists('g:QFixMRU_Title["'.g:qfixmemo_ext.'_regxp"]')
    let g:QFixMRU_Title[g:qfixmemo_ext.'_regxp'] = '^'.l:qfixmemo_title. '[^'.g:qfixmemo_title[0].']'
  endif
  if exists('g:QFixMRU_RegisterFile') && '.'.g:qfixmemo_ext !~ g:QFixMRU_RegisterFile
    let g:QFixMRU_RegisterFile = '\.'.g:qfixmemo_ext.'$'
  endif
  " .howm
  if !exists("g:QFixMRU_Title['".s:howm_ext."']")
    let g:QFixMRU_Title[s:howm_ext]          = g:QFixMRU_Title[g:qfixmemo_ext]
  endif
  if !exists('g:QFixMRU_Title["howm_regxp"]')
    let g:QFixMRU_Title[s:howm_ext.'_regxp'] = g:QFixMRU_Title[g:qfixmemo_ext.'_regxp']
  endif
endfunction

" デフォルトキーマップ
silent! function QFixMemoKeymap()
  silent! nnoremap <silent> <unique> <Leader>C       :<C-u>call qfixmemo#Edit()<CR>
  silent! nnoremap <silent> <unique> <Leader>c       :<C-u>call qfixmemo#EditNew()<CR>
  silent! nnoremap <silent> <unique> <Leader>u       :<C-u>call qfixmemo#Quickmemo()<CR>
  silent! nnoremap <silent> <unique> <Leader>U       :<C-u>call qfixmemo#Quickmemo(0)<CR>
  silent! nnoremap <silent> <unique> <Leader><Space> :<C-u>call qfixmemo#Edit(g:qfixmemo_diary)<CR>
  silent! nnoremap <silent> <unique> <Leader>j       :<C-u>call qfixmemo#PairFile('%')<CR>
  silent! nnoremap <silent> <unique> <Leader>i       :<C-u>call qfixmemo#SubMenu()<CR>
  silent! nnoremap <silent> <unique> <Leader>I       :<C-u>call qfixmemo#SubMenu(0)<CR>

  silent! nnoremap <silent> <unique> <Leader>m       :<C-u>call qfixmemo#ListMru()<CR>
  silent! nnoremap <silent> <unique> <Leader>l       :<C-u>call qfixmemo#ListRecent()<CR>
  silent! nnoremap <silent> <unique> <Leader>L       :<C-u>call qfixmemo#ListRecentTimeStamp()<CR>
  if g:qfixmemo_use_list_cache
    silent! nnoremap <silent> <unique> <Leader>a     :<C-u>call qfixmemo#ListCache('open')<CR>
  else
    silent! nnoremap <silent> <unique> <Leader>a     :<C-u>call qfixmemo#List('open')<CR>
  endif
  silent! nnoremap <silent> <unique> <Leader>ra      :<C-u>call qfixmemo#List('open')<CR>
  silent! nnoremap <silent> <unique> <Leader>A       :<C-u>call qfixmemo#ListFile(g:qfixmemo_diary)<CR>
  silent! nnoremap <silent> <unique> <Leader>rA      :<C-u>call qfixmemo#Glob(g:qfixmemo_dir, '**/*', 'open')<CR>
  silent! nnoremap <silent> <unique> <Leader>rN      :<C-u>call qfixmemo#ListRenameFile(g:qfixmemo_filename)<CR>

  silent! nnoremap <silent> <unique> <Leader>rr      :<C-u>call qfixmemo#RandomWalk(g:qfixmemo_random_file)<CR>
  silent! nnoremap <silent> <unique> <Leader>rR      :<C-u>call qfixmemo#RebuildRandomCache(g:qfixmemo_random_file)<CR>
  silent! nnoremap <silent> <unique> <Leader>rk      :<C-u>call qfixmemo#RebuildKeyword()<CR>

  silent! nnoremap <silent> <unique> <Leader>s       :<C-u>call qfixmemo#FGrep()<CR>
  silent! nnoremap <silent> <unique> <Leader>g       :<C-u>call qfixmemo#Grep()<CR>

  silent! nnoremap <silent> <unique> <Leader>o       :<C-u>call QFixMemoOutline()<CR>

  if g:qfixmemo_use_howm_schedule
    silent! nnoremap <silent> <unique> <Leader>t     :<C-u>call qfixmemo#ListReminderCache("todo")<CR>
    silent! nnoremap <silent> <unique> <Leader>rt    :<C-u>call qfixmemo#ListReminder("todo")<CR>
    silent! nnoremap <silent> <unique> <Leader>y     :<C-u>call qfixmemo#ListReminderCache("schedule")<CR>
    silent! nnoremap <silent> <unique> <Leader><Tab> :<C-u>call qfixmemo#ListReminderCache("schedule")<CR>
    silent! nnoremap <silent> <unique> <Leader>ry    :<C-u>call qfixmemo#ListReminder("schedule")<CR>
    silent! nnoremap <silent> <unique> <Leader>rd    :<C-u>call qfixmemo#GenerateRepeatDate()<CR>
    silent! nnoremap <silent> <unique> <Leader>d     :<C-u>call qfixmemo#InsertDate('Date')<CR>
    silent! nnoremap <silent> <unique> <Leader>T     :<C-u>call qfixmemo#InsertDate('Time')<CR>
    silent! nnoremap <silent> <unique> <Leader>,     :<C-u>call qfixmemo#OpenMenu("cache")<CR>
    silent! nnoremap <silent> <unique> <Leader>r,    :<C-u>call qfixmemo#OpenMenu()<CR>
  endif
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

  function! qfixmemo#InsertDate(type)
    call <SID>howmScheduleEnv('save')
    call QFixHowmInsertDate(a:type)
    call <SID>howmScheduleEnv('restore')
  endfunction

  function! qfixmemo#OpenMenu(...)
    call howm_menu#Init()
    call <SID>howmScheduleEnv('save')
    let g:QFixHowm_KeywordList = deepcopy(s:KeywordDic)
    if a:0
      call QFixHowmOpenMenu(a:1)
    else
      call QFixHowmOpenMenu()
    endif
    call <SID>howmScheduleEnv('restore')
    let lt = localtime() - HowmSchedueCachedTime('menu')
    echo 'QFixMemo : Cached menu ('.lt/60.' minutes ago)'
  endfunction

  function! s:howmScheduleEnv(mode)
    call howm_schedule#Init()
    if a:mode == 'save'
      let s:howm_dir           = g:howm_dir
      let s:howm_fileencoding  = g:howm_fileencoding
      let g:howm_dir           = g:qfixmemo_dir
      let g:howm_fileencoding  = g:qfixmemo_fileencoding
    elseif a:mode == 'restore'
      let g:howm_dir           = s:howm_dir
      let g:howm_fileencoding  = s:howm_fileencoding
    endif
  endfunction
endif

" デフォルトローカルキーマップ
silent! function QFixMemoLocalKeymap()
  nnoremap <silent> <buffer> <LocalLeader>P :QFixMRUMoveCursor top<CR>:<C-u>call qfixmemo#Template('top')<CR>
  nnoremap <silent> <buffer> <LocalLeader>p :QFixMRUMoveCursor prev<CR>:<C-u>call qfixmemo#Template('prev')<CR>
  nnoremap <silent> <buffer> <LocalLeader>n :QFixMRUMoveCursor next<CR>:<C-u>call qfixmemo#Template('next')<CR>
  nnoremap <silent> <buffer> <LocalLeader>N :QFixMRUMoveCursor bottom<CR>:<C-u>call qfixmemo#Template('bottom')<CR>

  nnoremap <silent> <buffer> <LocalLeader>x :<C-u>call qfixmemo#DeleteEntry()<CR>
  nnoremap <silent> <buffer> <LocalLeader>X :<C-u>call qfixmemo#DeleteEntry('Move')<CR>
  nnoremap <silent> <buffer> <LocalLeader>W :<C-u>call qfixmemo#DivideEntry()<CR>
  vnoremap <silent> <buffer> <LocalLeader>W :<C-u>call qfixmemo#DivideEntry()<CR>

  nnoremap <silent> <buffer> <LocalLeader>S  :<C-u>call qfixmemo#UpdateTime()<CR>
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

silent! function QFixMemoMenubar(menu, leader)
  let menucmd = 'amenu <silent> 41.333 '.a:menu.'.%s<Tab>'.a:leader.'%s :call feedkeys("'.a:leader.'%s","t")<CR>'
  let sepcmd  = 'amenu <silent> 41.333 '.a:menu.'.-sep%d-			<Nop>'
  call s:addMenu(menucmd, 'CreateNew(&C)'      , 'c')
  call s:addMenu(menucmd, 'CreateNew(Name)(&N)', 'C')
  call s:addMenu(menucmd, 'QuickMemo(&U)'      , 'u')
  call s:addMenu(menucmd, 'Diary(&D)'          , '<Space>')
  call s:addMenu(menucmd, 'PairFile(&J)'       , 'j')
  call s:addMenu(menucmd, 'SubMenu(&I)'        , 'i')
  exe printf(sepcmd, 1)
  call s:addMenu(menucmd, 'MRU(&M)'              , 'm')
  let menucmd = 'amenu <silent> 41.334 '.a:menu.'.%s<Tab>'.a:leader.'%s :call feedkeys("'.a:leader.'%s","t")<CR>'
  let sepcmd  = 'amenu <silent> 41.334 '.a:menu.'.-sep%d-			<Nop>'
  call s:addMenu(menucmd, 'ListRecent(&L)'       , 'l')
  call s:addMenu(menucmd, 'ListRecent(Stamp)(&2)', 'L')

  if g:qfixmemo_use_list_cache
    call s:addMenu(menucmd, 'List(cache)(&E)', 'a')
    call s:addMenu(menucmd, 'ListAll(&A)'    , 'ra')
  else
    call s:addMenu(menucmd, 'ListAll(&A)', 'a')
  endif
  call s:addMenu(menucmd, 'DiaryList(&O)'        , 'A')
  call s:addMenu(menucmd, 'FileList(&F)'         , 'rA')
  exe printf(sepcmd, 2)
  call s:addMenu(menucmd, 'FGrep(&S)', 's')
  call s:addMenu(menucmd, 'Grep(&G)' , 'g')
  if g:qfixmemo_use_howm_schedule
    exe printf(sepcmd, 3)
    call s:addMenu(menucmd, 'Schedule(&Y)'        , 'y')
    call s:addMenu(menucmd, 'Todo(&T)'            , 't')
    call s:addMenu(menucmd, 'Menu(&,)'            , ',')
    call s:addMenu(menucmd, 'Rebuild-Schedule(&V)', 'ry')
    call s:addMenu(menucmd, 'Rebuild-Todo(&W)'    , 'rt')
    call s:addMenu(menucmd, 'Rebuild-Menu(&\.)'   , 'r,')
  endif
  exe printf(sepcmd, 4)
  call s:addMenu(menucmd, 'RandomWalk(&R)'        , 'rr')
  call s:addMenu(menucmd, 'Rebuild-RandomWalk(&X)', 'rR')
  exe printf(sepcmd, 5)
  call s:addMenu(menucmd, 'Rebuild-Keyword(&K)', 'rk')
  exe printf(sepcmd, 6)
  " call s:addMenu(menucmd, 'Rename(&Z)'      , 'rn')
  call s:addMenu(menucmd, 'Rename-files(&Z)', 'rN')
  if g:qfixmemo_use_howm_schedule
    exe printf(sepcmd, 7)
    call s:addMenu(menucmd, 'Help(&H)', 'H')
  endif
  exe printf(sepcmd, 8)
  let submenu = '.Buffer[Local]\ (&B)'
  let sepcmd  = 'amenu <silent> 41.335 '.a:menu.submenu.'.-sep%d-			<Nop>'
  let menucmd = 'amenu <silent> 41.335 '.a:menu.submenu.'.%s<Tab>'.a:leader.'%s :call feedkeys("'.a:leader.'%s","t")<CR>'
  exe printf(sepcmd, 1)
  call s:addMenu(menucmd, 'Outline(&O)', 'o')
  exe printf(sepcmd, 2)
  call s:addMenu(menucmd, 'NewEntry(&1)', 'P')
  call s:addMenu(menucmd, 'NewEntry(&P)', 'p')
  call s:addMenu(menucmd, 'NewEntry(&N)', 'n')
  call s:addMenu(menucmd, 'NewEntry(&B)', 'N')
  exe printf(sepcmd, 3)
  call s:addMenu(menucmd, 'UpdateTime(&S)'    , 'S')
  call s:addMenu(menucmd, 'SortEntry(&S)'     , 'rs')
  call s:addMenu(menucmd, 'SortEntry(rev)(&S)', 'rS')
  exe printf(sepcmd, 4)
  call s:addMenu(menucmd, 'DeleteEntry(&X)', 'x')
  call s:addMenu(menucmd, 'MoveEntry(&M)'  , 'X')
  call s:addMenu(menucmd, 'DivideEntry(&W)', 'W')
  exe printf(sepcmd, 5)
  call s:addMenu(menucmd, 'Rename(&Z)', 'rn')

  call QFixMemoMenubarPost(a:menu, a:leader)
endfunction

silent! function QFixMemoMenubarPost(menu, leader)
endfunction

function! s:addMenu(menu, acc, cmd)
  exe printf(a:menu, a:acc, a:cmd, a:cmd)
endfunction

" VimEnter
silent! function QFixMemoVimEnter()
endfunction

" 初期化
silent! function QFixMemoInit(init)
endfunction

""""""""""""""""""""""""""""""
" global keymap
""""""""""""""""""""""""""""""
if exists('g:mapleader')
  let s:mapleader = g:mapleader
endif
let g:mapleader = g:qfixmemo_mapleader

call QFixMemoKeymap()
call QFixMemoKeymapPost()

if g:qfixmemo_menubar
  call QFixMemoMenubar('Memo(&M)', g:mapleader)
endif

if exists('s:mapleader')
  let g:mapleader = s:mapleader
else
  unlet g:mapleader
endif

""""""""""""""""""""""""""""""
" local keymap
""""""""""""""""""""""""""""""
silent! command -count -nargs=1 QFixMRUMoveCursor
function! s:localkeymap()
  if exists('g:maplocalleader')
    let s:mapleader = g:mapleader
  endif
  let g:maplocalleader = g:qfixmemo_mapleader
  call QFixMemoLocalKeymap()
  call QFixMemoLocalKeymapPost()
  if exists('s:maplocalleader')
    let g:maplocalleader = s:maplocalleader
  else
    unlet g:maplocalleader
  endif
endfunction

""""""""""""""""""""""""""""""
augroup QFixMemo
  au!
  au BufNewFile,BufRead * call <SID>BufRead()
  au BufReadPost        * call <SID>BufReadPost()
  au BufEnter           * call <SID>BufEnter()
  au BufWritePre        * call <SID>BufWritePre()
  au BufWritePost       * call <SID>BufWritePost()
  au BufWinEnter        * call <SID>BufWinEnter()
  au VimEnter           * call <SID>VimEnter()
  au BufWinEnter quickfix call <SID>qfBufWinEnter()
augroup END

function! s:VimEnter()
  call QFixMemoTitleRegxp()
  call QFixMemoVimEnter()
  call qfixmemo#VimEnterCmd()
  if g:qfixmemo_use_howm_schedule == 2
    call howm_schedule#Init()
  endif
endfunction

function! s:BufWinEnter()
  if !s:isQFixMemo(expand('%'))
    return
  endif
  call s:localkeymap()
  call QFixMemoBufWinEnter()
endfunction

function! s:BufReadPost()
  if !s:isQFixMemo(expand('%'))
    return
  endif
  call QFixMemoBufReadPost()
endfunction

function! s:BufRead()
  if !s:isQFixMemo(expand('%'))
    return
  endif
  if g:qfixmemo_folding
    call QFixMemoSetFolding()
  endif
  call QFixMemoBufRead()
endfunction

" フォールディングレベル計算
silent! function QFixMemoSetFolding()
  setlocal nofoldenable
  setlocal foldmethod=expr
  if exists('*QFixMemoFoldingLevel')
    setlocal foldexpr=QFixMemoFoldingLevel(v:lnum)
  else
    setlocal foldexpr=getline(v:lnum)=~g:qfixmemo_folding_pattern?'>1':'1'
  endif
endfunction

function! s:BufEnter()
  " set filetype, fileencoding, fileformat
  " qfixmemo_dir以下のファイルであればファイル属性を設定
  if !s:isQFixMemo(expand('%'))
    return
  endif
  call QFixMemoBufEnterPre()

  if g:qfixmemo_forceencoding && &fenc != g:qfixmemo_fileencoding
    exe 'edit! ++enc='.g:qfixmemo_fileencoding.' ++ff='.g:qfixmemo_fileformat
  endif
  call s:filetype()
  " フォールディングを設定
  call QFixMemoBufEnter()
endfunction

silent! function QFixMemoBufEnterPre()
endfunction

" 強制書込
function! qfixmemo#ForceWrite()
  let saved_bt = &buftype
  if &buftype != ''
    setlocal buftype=
  endif
  let s:ForceWrite = 1
  write!
  let &buftype = saved_bt
endfunction

" タイトル行付加
function! qfixmemo#AddTitle()
  let l:qfixmemo_title = escape(g:qfixmemo_title, g:qfixmemo_escape)
  let rpattern = '^'.l:qfixmemo_title .'\s*\(\[.\{-}]*\]\s*\)*\s*$'

  let save_cursor = getpos('.')

  let tpattern = qfixmemo#TitleRegxp()
  " 一行目は必ずタイトル
  let fline = 1
  call cursor(1, 1)
  let str = getline(fline)
  " 一行目が予定・TODOなら次エントリへ
  if str =~ s:qfixmemo_scheduleformat
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
        if str != '' && str !~ s:qfixmemo_scheduleformat && str !~ s:qfixmemo_timeformat && str !~ '^\[.\{-}]$'
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
function! qfixmemo#AddTime()
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
    if len(filter(entry, "v:val =~ '" . s:qfixmemo_timeformat . '\(\s\|$\)'. "'")) == 0
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
function! qfixmemo#UpdateTime()
  call qfixmemo#Init()
  let l:qfixmemo_title = escape(g:qfixmemo_title, g:qfixmemo_escape)
  let fline = line('.')
  let save_cursor = getpos('.')
  let tpattern = qfixmemo#TitleRegxp()
  let [title, fline, lline] = QFixMRUGet('title', '%', fline, tpattern)
  call cursor(fline, 1)
  let fline = search(s:qfixmemo_timeformat, 'cW')
  let str = strftime(g:qfixmemo_timeformat)
  if fline == 0 || fline > lline
    let fline = fline == 0 ? 1 : fline
    exe fline . 'put=str'
  elseif s:qfixmemoWriteUpdateTime
    let str = substitute(getline(fline), s:qfixmemo_timeformat, str, '')
    call setline(fline, str)
  endif
  call setpos('.', save_cursor)
endfunction

" 行末の空白行を削除
function! qfixmemo#DeleteNullLines()
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
  if !s:isQFixMemo(expand('%'))
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

function! s:filetype()
  let file = QFixNormalizePath(expand('%:p'), 'compare')
  let pdir = QFixNormalizePath(fnamemodify(g:qfixmemo_dir.'/'.g:qfixmemo_pairfile_dir, ':p'), 'compare')
  if &filetype != '' && stridx(file, pdir) == 0
    return
  endif
  if exists('b:qfixmemo_filetype') && b:qfixmemo_filetype == &filetype
    return
  endif
  if g:qfixmemo_filetype != ''
    exe 'setlocal filetype=' . g:qfixmemo_filetype
  endif
  call s:syntaxHighlight()
  " for myqfix.vim
  if &previewwindow == 0
    let b:qfixmemo_filetype = &filetype
  endif
endfunction

function! s:syntaxHighlight()
  if g:qfixmemo_syntax == 0
    return
  endif
  silent! syn clear qfixmemoKeyword
  if s:KeywordHighlight != ''
    exe 'syn match qfixmemoKeyword display "\V'.escape(s:KeywordHighlight, '"').'"'
  endif
  hi link qfixmemoKeyword Underlined

  let l:qfixmemo_title = escape(g:qfixmemo_title, g:qfixmemo_escape)
  exe 'syn region qfixmemoTitle start="^'.l:qfixmemo_title.'[^'.g:qfixmemo_title.']'.'" end="$" contains=qfixmemoTitleDesc,qfixmemoCategory'
  exe 'syn match qfixmemoTitleDesc "^'.l:qfixmemo_title.'$"'
  exe 'syn match qfixmemoTitleDesc contained "^'.l:qfixmemo_title.'"'
  syn match qfixmemoCategory contained +\(\[.\{-}\]\)\++
  hi link qfixmemoTitle     Title
  hi link qfixmemoTitleDesc Special
  hi link qfixmemoCategory  Label

  if g:qfixmemo_syntax == 1
    return
  endif
  exe 'syn match qfixmemoDateTime "'.s:qfixmemo_timeformat . '" contains=qfixmemoDate,qfixmemoTime'
  syn match qfixmemoDate contained '\d\{4}-\d\{2}-\d\{2}'
  syn match qfixmemoDate contained '\d\{4}/\d\{2}/\d\{2}'
  syn match qfixmemoTime contained '\d\{2}\(:\d\{2}\)\+'

  hi link qfixmemoDate Underlined
  hi link qfixmemoTime Constant

  if g:qfixmemo_syntax == 2
    return
  endif
  runtime! syntax/howm_schedule.vim
endfunction

function! s:BufWritePost()
  if !s:isQFixMemo(expand('%'))
    return
  endif
  if search('^.\+$', 'ncw') == 0
    call delete(expand('%:p'))
    return
  endif
  call QFixMemoBufWritePost()
endfunction

let s:init = 0
function! qfixmemo#Init()
  call QFixMemoTitleRegxp()
  call QFixMemoInit(s:init)
  let dir = expand(g:qfixmemo_dir)
  if isdirectory(dir) == 0
    call mkdir(dir, 'p')
  endif
  if s:init
    return
  endif
  if g:qfixmemo_use_howm_schedule
    call howm_schedule#Init()
  endif
  call qfixmemo#MRUInit()
  call qfixmemo#LoadKeyword()
  if has('unix') && !has('win32unix')
    silent! call libcallnr("", "srand", localtime())
  else
    silent! call libcallnr("msvcrt.dll", "srand", localtime())
  endif
  let s:init = 1
endfunction

""""""""""""""""""""""""""""""
" 拡張子を付加してqfixmemo#EditFile()を呼び出し
function! qfixmemo#Edit(...)
  call qfixmemo#Init()
  if a:0 == 0
    let file = input('filename : ', '')
    if file == ''
      return
    endif
    let file = strftime(file)
  else
    let file = strftime(a:1)
  endif
  if tolower(fnamemodify(file, ':e')) != g:qfixmemo_ext
    let file = file . '.' . g:qfixmemo_ext
  endif
  call qfixmemo#EditFile(file)
endfunction

" qfixmemoファイルを開く
function! qfixmemo#EditFile(file)
  call qfixmemo#Init()

  let prevPath = escape(getcwd(), ' ')
  exe 'lchdir ' . expand(g:qfixmemo_dir)
  let file = fnamemodify(strftime(a:file), ':p')
  silent! exe 'lchdir ' . prevPath
  if s:isQFixMemo(file)
    let file = substitute(fnamemodify(file, ':p'), '\\', '/', 'g')
    let opt = '++enc=' . g:qfixmemo_fileencoding . ' ++ff=' . g:qfixmemo_fileformat . ' '
    let mode = g:qfixmemo_splitmode ? 'split' : ''
    call s:edit(file, mode, opt)
  else
    let mode = g:qfixmemo_splitmode ? 'split' : ''
    call QFixEditFile(file, mode)
  endif
endfunction

" 新規メモ作成
" カウント指定で qfixmemo_filename, qfixmemo_filename1, ...を使用する
function! qfixmemo#EditNew()
  let file = g:qfixmemo_filename
  if count
    exe 'let file = g:qfixmemo_filename'.count
  endif
  call qfixmemo#Edit(file)
endfunction

" クイックメモを開く
let s:qfixmemo_quickmemo = g:qfixmemo_quickmemo
function! qfixmemo#Quickmemo(...)
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
    let file = file . '.' . g:qfixmemo_ext
  endif
  call qfixmemo#EditFile(file)
endfunction

" 日記を開く
function! qfixmemo#EditDiary()
  call qfixmemo#Init()
  call qfixmemo#Edit(g:qfixmemo_diary)
endfunction

" ペアファイルを開く
function! qfixmemo#PairFile(file)
  call qfixmemo#Init()
  let file = a:file
  if a:file == '%'
    let file = expand(a:file)
  endif
  let file = fnamemodify(file, ':t')
  let pfile = g:qfixmemo_pairfile_dir . '/' . file

  let glist = []
  if !filereadable(fnamemodify(g:qfixmemo_dir . '/' . pfile . '.' . g:qfixmemo_ext, ':p'))
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
  let file = fnamemodify(a:file, ':p')
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
  exe g:qfixmemo_editcmd.' edit ' . opt . escape(file, ' #%')
  if !filereadable(file)
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

function! s:isQFixMemo(file)
  let file = fnamemodify(a:file, ':p')
  if g:qfixmemo_isqfixmemo_regxp != '' && file =~ g:qfixmemo_isqfixmemo_regxp
    return 1
  endif
  if tolower(fnamemodify(file, ':e')) != tolower(g:qfixmemo_ext)
    return 0
  endif
  let file = QFixNormalizePath(file, 'compare')
  let head = expand(g:qfixmemo_dir)
  let head = QFixNormalizePath(head, 'compare')
  if stridx(file, head) == 0
    return 1
  endif
  return 0
endfunction

function! qfixmemo#Template(cmd)
  call qfixmemo#Init()
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
  call qfixmemo#Init()
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
    call cursor(1,1)
    stopinsert
    let s:qfixmemoWriteUpdateTime = 0
    write!
  endif
endfunction

function! qfixmemo#DivideEntry() range
  call qfixmemo#Init()
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
    call cursor(1,1)
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
" List
" copen  : quickfix
" ccache : cache (quickfix)
" open   : qfixlist
" cache  : cache (qfixlist)

"タイトル検索のエスケープパターン
if !exists('g:qfixmemo_escape')
  let g:qfixmemo_escape = '[]~*.\#'
endif

" MRUを開く
function! qfixmemo#ListMru()
  call qfixmemo#Init()
  if count
    let g:QFixMRU_Entries = count
  endif
  redraw | echo 'QFixMemo : Read MRU...'
  call QFixMRU(g:qfixmemo_dir)
endfunction

" 最近編集されたファイル内のエントリ一覧
function! qfixmemo#ListRecent()
  call qfixmemo#Init()
  if count
    let g:qfixmemo_recentdays = count
  endif
  let title = QFixMRUGetTitleGrepRegxp(g:qfixmemo_ext)
  let qflist = qfixlist#search(title, g:qfixmemo_dir, 'mtime', g:qfixmemo_recentdays, g:qfixmemo_fileencoding, '**/*')
  call qfixlist#copen(qflist, g:qfixmemo_dir)
endfunction

" タイムスタンプが最近のエントリ一覧
function! qfixmemo#ListRecentTimeStamp(...)
  call qfixmemo#Init()
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
  let fmt = '^' . escape(fmt, '[]~*.#')
  let fmt = substitute(fmt, '\C%H', '[0-2][0-9]', 'g')
  let fmt = substitute(fmt, '\C%M', '[0-5][0-9]', 'g')
  let fmt = substitute(fmt, '\C%S', '[0-5][0-9]', 'g')

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
  let fmt = substitute(fmt, '\C%Y', '[0-2][0-9][0-9][0-9]', 'g')
  let fmt = substitute(fmt, '\C%m', '[0-1][0-9]', 'g')
  let fmt = substitute(fmt, '\C%d', '[0-3][0-9]', 'g')
  let fmt = fmt . '\([^'.g:qfixmemo_scheduleext.']\|$\)'

  if findstr
    let saved_grepprg = &grepprg
    let tregxp = '"'.substitute(tregxp, '|', ' ', 'g').'"'
    redraw | echo 'QFixMemo : (findstr) Searching...'
    let prevPath = escape(getcwd(), ' ')
    exe 'lchdir ' . expand(g:qfixmemo_dir)
    let cmd = 'grep! /n /p /r /s ' . tregxp . ' *.*'
    silent! exe cmd
    silent! exe 'lchdir ' . prevPath
    let &grepprg = saved_grepprg
    let qflist = QFixGetqflist()
    let qflist = qfixlist#Sort('rtext', qflist)
    " redraw | echo 'QFixMemo : Sorting...'
    call QFixSetqflist([])
    let qflist = reverse(qflist)
    " FIXME: findstrで内部エンコーディングが utf-8 だと日本語ファイル名が処理できない
    for idx in range(len(qflist))
      let file = bufname(qflist[idx]['bufnr'])
      let file = substitute(fnamemodify(file, ':p'), '\\', '/', 'g')
      let qflist[idx]['filename'] = file
    endfor
  else
    let qflist = qfixlist#search(tregxp, g:qfixmemo_dir, 'rtext', 0, g:qfixmemo_fileencoding, '**/*')
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
  call qfixlist#copen(qflist, g:qfixmemo_dir)
endfunction

" 全エントリ一覧
" 'open'   : QFixList再検索表示
" 'copen'  : QuickFix再検索表示
" 'cache'  : QFixListキャッシュ表示
" 'ccache' : QuickFixキャッシュ表示
function! qfixmemo#List(mode, ...)
  call qfixmemo#Init()
  let mode = a:mode
  if mode =~ 'cache'
    call qfixlist#open()
    redraw|echo 'QFixMemo : Cached list.'
    return
  elseif mode =~ 'ccache'
    call qfixlist#copen()
    redraw|echo 'QFixMemo : Cached list.'
    return
  endif

  let pattern = a:0 ? a:1 : QFixMRUGetTitleGrepRegxp(g:qfixmemo_ext)
  let qflist = qfixlist#search(pattern, g:qfixmemo_dir, 'reverse', 0, g:qfixmemo_fileencoding, '**/*')
  if mode =~ 'copen'
    call qfixlist#copen(qflist, g:qfixmemo_dir)
  else
    call qfixlist#open(qflist, g:qfixmemo_dir)
  endif
endfunction

" キャッシュ表示
let s:lcinit = 0
function! qfixmemo#ListCache(mode, ...)
  call qfixmemo#Init()
  let mode = a:mode
  if qfixlist#GetList() != [] && s:lcinit
    let mode = substitute(mode, 'open', 'cache', '')
  endif
  call qfixmemo#List(mode)
  let s:lcinit = 1
endfunction

" ファイルリスト
function! qfixmemo#ListFile(file)
  call qfixmemo#Init()
  let title = '^'.escape(g:qfixmemo_title, g:qfixmemo_escape)
  let qflist = qfixlist#search(title, g:qfixmemo_dir, 'reverse', 0, g:qfixmemo_fileencoding, '**/*')
  let pattern = a:file.'.'.g:qfixmemo_ext
  let pattern = s:strftimeRegxp(pattern)
  call filter(qflist, "v:val['filename'] =~ '" . pattern . "'")
  call qfixlist#open(qflist, g:qfixmemo_dir)
endfunction

function! s:strftimeRegxp(regxp)
  let regxp = a:regxp
  let regxp = substitute(regxp, '%Y', '\\d\\{4}', 'g')
  let regxp = substitute(regxp, '%m', '\\d\\{2}', 'g')
  let regxp = substitute(regxp, '%d', '\\d\\{2}', 'g')
  let regxp = substitute(regxp, '%H', '\\d\\{2}', 'g')
  let regxp = substitute(regxp, '%M', '\\d\\{2}', 'g')
  let regxp = substitute(regxp, '%S', '\\d\\{2}', 'g')
  return regxp
endfunction

" Globファイルリスト
function! qfixmemo#Glob(path, file, mode)
  call qfixmemo#Init()
  let prevPath = escape(getcwd(), ' ')
  let path = expand(a:path)
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
  for n in files
    let n = path . n
    let n = fnamemodify(n, ':p')
    if !isdirectory(n)
      let lnum = 1
      let tlist = readfile(n, '', 1)
      let text = len(tlist) ? iconv(tlist[0], from, to) : ''
      let usefile = {'filename':n, 'lnum':lnum, 'text':text}
      call insert(qflist, usefile)
    endif
  endfor
  silent! exe 'lchdir ' . prevPath
  redraw | echo ''
  if mode =~ 'list'
    return qflist
  elseif mode =~ 'copen'
    call qfixlist#copen(qflist, path)
  else
    call qfixlist#open(qflist, path)
  endif
endfunction

let s:RenameQFList = []
function! qfixmemo#ListRenameFile(file)
  call qfixmemo#Init()
  let qflist = qfixmemo#Glob(g:qfixmemo_dir, '**/*.'.g:qfixmemo_ext, 'list')
  let pattern = a:file.'.'.g:qfixmemo_ext
  let pattern = s:strftimeRegxp(pattern)
  call filter(qflist, "v:val['filename'] =~ '" . pattern . "'")
  let pattern = g:qfixmemo_diary.'.'.g:qfixmemo_ext
  let pattern = s:strftimeRegxp(pattern)
  call filter(qflist, "v:val['filename'] !~ '" . pattern . "'")
  call filter(qflist, "v:val['filename'] !~ '/" . g:qfixmemo_pairfile_dir . "/'")
  for d in qflist
    let file = s:formatFileName(d['text'], g:qfixmemo_rename_length)
    let d['text'] = file . '.' .  g:qfixmemo_ext
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
  let fname = substitute(fname, '^\(\[[^\]]\+\]\s*\)\+', '', 'g')
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
    redraw|echo 'Please, change these filename(s).'
  else
    redraw|echo 'Done.'
  endif
  let s:RenameQFList = glist
endfunction

""""""""""""""""""""""""""""""
let s:rwalk = []
let s:randomfile = ''
" ランダム表示
function! qfixmemo#RandomWalk(file, ...)
  call qfixmemo#Init()
  let file = expand(a:file)
  let ftime = getftime(file)
  let ftime = ftime < 0 ? 0 : ftime
  let ltime = localtime() - ftime
  let dir   = g:qfixmemo_dir
  if exists('g:qfixmemo_root_dir')
    let dir = g:qfixmemo_root_dir
  endif
  if exists('g:qfixmemo_random_dir')
    let dir = g:qfixmemo_random_dir
  endif
  if ftime == 0 || ltime > g:qfixmemo_random_time
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
  call qfixlist#copen(qflist, dir)
  redraw | echo ''
endfunction

" ランダムキャッシュ再作成
function! qfixmemo#RebuildRandomCache(file)
  call qfixmemo#Init()
  let dir   = g:qfixmemo_dir
  if exists('g:qfixmemo_root_dir')
    let dir = g:qfixmemo_root_dir
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
    let r = s:random(range)
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
  if has('unix') && !has('win32unix')
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
  silent! exe 'lchdir ' . prevPath
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
  silent! exe 'lchdir ' . escape(expand(dir), ' ')
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
  silent! exe 'lchdir ' . prevPath
  return sq
endfunction

""""""""""""""""""""""""""""""
" Grep
function! qfixmemo#Grep(...)
  call qfixmemo#Init()
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
    let @/ = pattern
    if fixmode
      let g:MyGrep_Regexp = 0
      let @/ = '\V'.pattern
    endif
    call s:grep(pattern)
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

function! s:grep(pattern)
  let qflist = qfixlist#search(a:pattern, g:qfixmemo_dir, '', 0, g:qfixmemo_fileencoding, '**/*')
  call qfixlist#copen(qflist, g:qfixmemo_dir)
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

function s:GetOptionWithID(opt, id)
  exe 'let opt='.a:opt.(exists(a:opt.a:id) ? string(a:id) : '')
  return opt
endfunction

""""""""""""""""""""""""""""""
" sub menu
"
" サブウィンドウのタイトル
if !exists('g:qfixmemo_submenu_title')
  let g:qfixmemo_submenu_title  = '__submenu__'
endif
" サブウィンドウのサイズ
if !exists('g:qfixmemo_submenu_width')
  let g:qfixmemo_submenu_width = 30
endif
" サブウィンドウを出す方向
if !exists('g:qfixmemo_submenu_direction')
  let g:qfixmemo_submenu_direction   = 'topleft vertical'
endif
" サブウィンドウのwrap
if !exists('g:qfixmemo_submenu_wrap')
  let g:qfixmemo_submenu_wrap = 1
endif

let s:qfixmemo_submenu_title = g:qfixmemo_submenu_title
let s:submenu_basedir = g:qfixmemo_dir
if exists('g:qfixmemo_root_dir')
  let s:submenu_basedir = g:qfixmemo_root_dir
endif
function! qfixmemo#SubMenu(...)
  call qfixmemo#Init()
  let basedir = s:submenu_basedir
  let l:count = a:0 && a:1 ? a:1 : count
  let prevPath = escape(getcwd(), ' ')
  silent! exec 'lchdir ' . escape(expand(basedir), ' ')
  let file = fnamemodify(s:qfixmemo_submenu_title, ':p')
  let bufnum = bufnr(file)
  let winnum = bufwinnr(file)

  if winnum != -1 && bufnum == bufnr('%')
    wincmd c
    if l:count == 0 && a:0 == 0
      silent! exec 'lchdir ' . prevPath
      return
    endif
    let winnum = -1
  endif
  if winnum != -1
    exe winnum . 'wincmd w'
    if l:count == 0 && a:0 == 0
      silent! exec 'lchdir ' . prevPath
      return
    endif
    wincmd c
  endif

  silent! exec 'lchdir ' . escape(expand(basedir), ' ')
  if a:0 && l:count == 0
    let s:qfixmemo_submenu_title = g:qfixmemo_submenu_title
  elseif l:count
    exe 'let s:qfixmemo_submenu_title = g:qfixmemo_submenu_title'.l:count
  endif
  let file = fnamemodify(s:qfixmemo_submenu_title, ':p')
  silent! exec 'lchdir ' . prevPath
  call s:OpenQFixSubWin(file, l:count)
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
  let winsize = s:GetOptionWithID('g:qfixmemo_submenu_width', swid)

  let bufnum = bufnr(file)
  if bufnum == -1
    let wcmd = expand(file)
    exe 'au BufEnter '.fnamemodify(file, ':t').' normal! '.winsize ."\<C-W>|"
    exe 'au BufWinLeave '.fnamemodify(file, ':t').' call <SID>SubMenuBufAutoWrite()'
  else
    let wcmd = '+buffer' . bufnum
  endif
  exe 'silent! ' . windir . ' ' . winsize . 'split ' . wcmd
  setlocal buftype=nowrite
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal foldcolumn=0
  setlocal nolist
  setlocal winfixwidth
  exe 'let &wrap='.s:GetOptionWithID('g:qfixmemo_submenu_wrap', swid)
  nnoremap <silent> <buffer> q    :close<CR>
  nnoremap <silent> <buffer> <CR> :call QFixMemoUserModeCR()<CR>
  if exists('g:qfixmemo_submenu_writekey')
    let cmd = g:qfixmemo_submenu_writekey
    exe 'nnoremap <silent> <buffer> ' . cmd . ' :<C-u>call qfixmemo#ForceWrite()<CR>'
  endif
  let cmd = g:qfixmemo_mapleader . 'w'
  exe 'nnoremap <silent> <buffer> ' . cmd . ' :<C-u>call qfixmemo#ForceWrite()<CR>'
  let b:qfixmemo_bufwrite_pre = 0
  call s:syntaxHighlight()
  if bufnum == -1 && !filereadable(expand(file))
    call qfixmemo_msg#submenu()
  endif
  call QFixMemoSubMenuOutline(swid)
  if exists('*QFixMemoSubMenuBufWinEnter')
    call QFixMemoSubMenuBufWinEnter()
  endif
endfunction

let s:qfixmemo_fileencoding = g:qfixmemo_fileencoding
function! s:SubMenuBufAutoWrite(...)
  return
  let prevPath = escape(getcwd(), ' ')
  exe 'lchdir ' . expand(s:submenu_basedir)
  if a:0
    let file = fnamemodify(expand('<afile>'), ':p')
  else
    let file = fnamemodify(expand("%"), ":p")
  endif
  silent! exe 'lchdir ' . prevPath
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
  if isdirectory(dir) == 0
    call mkdir(dir, 'p')
  endif
  call writefile(str, file)
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
  call QFixMemoQFBufWinEnterPost()
endfunction

silent! function QFixMemoQFBufWinEnterPost()
endfunction

function! QFixPreviewReadOpt(file)
  let file = a:file
  let opt = ''
  if g:qfixmemo_forceencoding && s:isQFixMemo(file)
    let opt = ' ++enc='.g:qfixmemo_fileencoding .' ++ff='.g:qfixmemo_fileformat
  endif
  return opt
endfunction

" for qfixmru
let s:mru_init = 0
function! qfixmemo#MRUInit()
  if s:mru_init
    return
  endif
  if g:QFixMRU_state == 0
    call QFixMRURead(g:QFixMRU_Filename)
    call QFixMRUWrite(0)
  endif
  let s:mru_init = 1
endfunction

function! qfixmemo#TitleRegxp()
  let l:qfixmemo_title = escape(g:qfixmemo_title, g:qfixmemo_escape)
  let regxp = '^'.l:qfixmemo_title. '\([^'.g:qfixmemo_title[0].']\+\|\s*$\)'
  return regxp
endfunction

" for qfixwin
function! QFixFtype(file)
  if !s:isQFixMemo(a:file)
    return
  endif
  if g:qfixmemo_filetype != ''
    call s:filetype()
  endif
endfunction

" for qfixwin
function! qfixmemo#Cmd_AT(mode) range
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
  wincmd p
  let g:QFixMRU_Disable = 0
endfunction

" for qfixwin
function! qfixmemo#Cmd_Replace(mode)
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
  silent! exe 'lchdir ' . prevPath
  QFixCopen
  call cursor(1, 1)
  return
endfunction

" for qfixwin
function! qfixmemo#Cmd_RD(cmd) range
  let fline = a:firstline - 1
  let lline = a:lastline - 1
  if a:cmd == 'Delete'
    let mes = "!!!Delete file(s)"
  else
    let mes = "!!!Remove to (~qfixmemo_dir)"
  endif
  let choice = confirm(mes, "&Yes\n&Cancel", 2, "W")
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
  QFixCopen
  call setpos('.', save_cursor)
endfunction

" for qfixwin
function! qfixmemo#Cmd_X(...) range
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
  let choice = confirm(mes, "&Yes\n&Cancel", 2, "W")
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
    wincmd p
    let qf = QFixGetqflist()
    call remove(qf, l)
    call QFixSetqflist(qf)
    call cursor(l+1, 1)
  endif
  let g:QFixMRU_Disable = 1
endfunction

""""""""""""""""""""""""""""""
" キーワードファイル
if !exists('g:qfixmemo_keyword_file')
  let g:qfixmemo_keyword_file = '~/.qfixmemo-keys'
endif
" オートリンク用tagsを作成するディレクトリ
if !exists('g:qfixmemo_keyword_dir')
  let g:qfixmemo_keyword_dir = 'wiki'
endif
" オートリンク用キーワードの処理
" 0 : 検索
" 1 : qfixmemo_keyword_dirを使用
" 2 : vimwikiを使用
if !exists('g:qfixmemo_keyword_mode')
  let g:qfixmemo_keyword_mode = 1
endif
" キーワードに登録しない正規表現
if !exists('g:qfixmemo_keyword_exclude')
  let g:qfixmemo_keyword_exclude = ''
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
  if s:KeywordHighlight != ''
    exe 'syn match qfixmemoKeyword display "\V'.escape(s:KeywordHighlight, '"').'"'
  endif
endfunction

" オートリンク保存
let s:KeywordDic = []
let s:KeywordHighlight = ''
function! qfixmemo#AddKeyword(...)
  if g:qfixmemo_use_keyword == 0
    return
  endif

  let addkey = 0
  if a:0
    let list = a:1
    call filter(list, "v:val =~ '\[\[.*\]\]'")
  else
    let list = s:GetKeywordStr('\[\[.*\]\]')
  endif
  for text in list
    while 1
      let stridx = match(text, '\[\[')
      let pairpos = matchend(text, '\]\]')
      if stridx == -1 || pairpos == -1
        break
      endif
      let keyword = strpart(text, stridx+2, pairpos-stridx-strlen('[[]]'))
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

  if exists('g:howm_clink_pattern')
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
  redraw | echo 'QFixMemo : Rebuild Keyword...'

  let pattern = '\[\[.*\]\]'
  let kfile = '*.'.s:howm_ext.' *.'.g:qfixmemo_ext
  let qflist = qfixlist#search(pattern, g:qfixmemo_dir, '', 0, g:qfixmemo_fileencoding, '**/'.kfile)
  if exists('g:howm_clink_pattern')
    let pattern = g:howm_clink_pattern
    let extlist = qfixlist#search(pattern, g:qfixmemo_dir, '', 0, g:qfixmemo_fileencoding, '**/'.kfile)
    call extend(qflist, extlist)
  endif

  let extlist = QFixMemoRebuildKeyword(g:qfixmemo_dir, g:qfixmemo_fileencoding)
  let pattern = '\[\[[^\]]\+\]\]'
  if exists('g:howm_clink_pattern')
    let pattern = '\('.g:howm_clink_pattern.'\|'.pattern.'\)'
  endif
  let file = expand(g:qfixmemo_submenu_title)
  silent! exe 'vimgrep /'.pattern.'/j '. escape(file, ' ')
  call extend(extlist, getqflist())
  silent! cexpr ''

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
    QFixCopen
    call cursor(1, 1)
    redraw | echo 'QFixMemo : done.'
  else
    call delete(expand(g:qfixmemo_keyword_file))
    call qfixmemo#LoadKeyword('highlight')
    redraw | echo 'QFixMemo : no keywords.'
  endif
endfunction

" 外部で定義されたキーワードをgetqflist()と同じ形式で返す
silent! function QFixMemoRebuildKeyword(dir, fenc)
  return []
endfunction

silent! function QFixMemoUserModeCR(...)
  if g:qfixmemo_use_howm_schedule
    call howm_schedule#Init()
    return QFixHowmUserModeCR()
  endif
  if qfixmemo#OpenCursorline()
    return
  endif
  if qfixmemo#SwitchAction()
    return
  endif
  if qfixmemo#OpenKeywordLink()
    return
  endif
  let cmd = a:0 ? a:1 : "normal! \<CR>"
  exe cmd
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

  if exists('g:howm_glink_pattern')
    let idx = match(lstr, g:howm_glink_pattern)
    if idx > -1 && idx <= col
      let word = matchstr(lstr, g:howm_glink_pattern . '.*')
      let word = substitute(word, g:howm_glink_pattern . '\s*', '', '')
      let g:MyGrep_Regexp = 0
      let qflist = qfixlist#search(word, g:qfixmemo_dir, '', 0, g:qfixmemo_fileencoding, '**/*')
      if exists('g:howm_clink_pattern')
        let qflist = sort(qflist, "<SID>qfixmemoSortHowmClink")
      endif
      if len(qflist)
        call QFixSetqflist(qflist)
        QFixCopen
      endif
      return 1
    endif
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
        let qflist = qfixlist#search(word, g:qfixmemo_dir, '', 0, g:qfixmemo_fileencoding, '**/*')
        if exists('g:howm_clink_pattern')
          let qflist = sort(qflist, "<SID>qfixmemoSortHowmClink")
        endif
        if len(qflist)
          call QFixSetqflist(qflist)
          QFixCopen
        endif
        return 1
      elseif g:qfixmemo_keyword_mode == 1
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
  for i in range(1, g:qfixmemo_switch_action_max)
    if !exists('g:qfixmemo_switch_action'.i)
      continue
    endif
    exe 'let action = '.'g:qfixmemo_switch_action'.i
    if QFixMemoSwitchAction(action)
      return 1
    endif
  endfor
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
      " let cpattern = strftime('['.s:qfixmemo_timeformat.'].')
    endif
    let prevcol = (a:0 == 0 ? start : col('.'))
    call cursor(prevline, start)
    exe 'normal! c'.nr.'l'.cpattern
    call cursor(prevline, prevcol)
    return 1
  endfor
  return 0
endfunction

" howm_schedule.vim用
function! QFixHowmOpenKeywordLink()
  if qfixmemo#OpenKeywordLink()
    return "\<ESC>"
  endif
  return "\<CR>"
endfunction

""""""""""""""""""""""""""""""
" カレントバッファのエントリを更新時間順にソート
function! qfixmemo#SortEntry(mode)
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
  unlet! elist
endfunction

" カレントバッファのエントリリストを得る
function! s:qfixmemoGetEntryList()
  let save_cursor = getpos('.')

  let elist = []
  let titlepattern = qfixmemo#TitleRegxp()
  let timepattern = s:qfixmemo_timeformat . '\([^'.g:qfixmemo_scheduleext.']\+\|$\)'
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
  if a:v1.text =~ g:howm_clink_pattern
    return -1
  endif
  return 1
endfunction

""""""""""""""""""""""""""""""
" help
function! qfixmemo#Syntax()
  if g:qfixmemo_filetype != ''
    exe 'setlocal filetype=' . g:qfixmemo_filetype
  endif
  call s:syntaxHighlight()
endfunction

""""""""""""""""""""""""""""""
" 起動時コマンドの基準時間
if !exists('g:qfixmemo_vimenter_time')
  let g:qfixmemo_vimenter_time = '07:00'
endif
" 起動時間チェック用ファイル
if !exists('g:qfixmemo_vimenter_file')
  let g:qfixmemo_vimenter_file = '~/.vimenter.qm'
endif

function! qfixmemo#VimEnterCmd()
  if exists('g:QFixMRU_RegisterFile') && g:QFixMRU_RegisterFile !~ g:qfixmemo_ext
    " let g:QFixMRU_RegisterFile = '\.'.g:qfixmemo_ext.'$'
  endif
  if exists('g:QFixMRU_Title') && g:QFixMRU_Title == {}
    " let g:QFixMRU_Title = {'mkd' : '^#',  'wiki' : '^='}
  endif
  if !exists('g:qfixmemo_vimenter_cmd')
    return
  endif
  let cmd   = g:qfixmemo_mapleader . g:qfixmemo_vimenter_cmd
  let file  = fnamemodify(g:qfixmemo_vimenter_file, ':p')
  let tstr  = substitute(g:qfixmemo_vimenter_time, '[^0-9]', '', 'g') . '00'

  let ltime = localtime()
  let lstr  = strftime('%Y%m%d%H%M%S', ltime)
  let estr  = strftime('%Y%m%d', ltime) . tstr
  if lstr < estr
    let ltime -= 24*60*60
    let estr = strftime('%Y%m%d', ltime) . tstr
  endif

  let ftime = getftime(file)
  let fstr = strftime('%Y%m%d%H%M%S', ftime)
  if ftime > 0 && fstr > estr
    return
  endif

  call writefile([], file)
  if exists('g:qfixmemo_vimenter_msg')
    let mes = g:qfixmemo_vimenter_msg
    let choice = confirm(mes, "&OK\n&Cancel", 1, "Q")
    if choice != 1
      redraw
      return
    endif
  endif
  call feedkeys(cmd, 't')
endfunction

