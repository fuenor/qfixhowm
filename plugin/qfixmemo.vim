"=============================================================================
"    Description: QFixMemo
"                 本プラグインはキーマップ等の起動時処理のみ設定している
"                 本体は autoload/qfixmemo.vim
"                 デフォルトでは qfixmemo_autoload = 1 が設定されているので、
"                 起動時に autoload/qfixmemo.vimは読み込まれない。
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home  (Japanese)
"=============================================================================
let s:version = 100
scriptencoding utf-8

if exists('g:disable_qfixmemo') && g:disable_qfixmemo == 1
  finish
endif
if exists('g:qfixmemo_init_version') && g:qfixmemo_init_version < s:version
  let g:loaded_qfixmemo_init = 0
endif
if exists('g:loaded_qfixmemo_init') && g:loaded_qfixmemo_init && !exists('g:fudist')
  finish
endif
let g:qfixmemo_init_version = s:version
let g:loaded_qfixmemo_init = 1
if v:version < 700
  finish
endif
let s:debug = exists('g:fudist') ? g:fudist : 0
let s:saved_cpo = &cpo
set cpo&vim

" g:qfixmemo_prescriptで指定されたスクリプトを読み込み
if exists('g:qfixmemo_prescript') && filereadable(g:qfixmemo_prescript)
  exe 'source '.g:qfixmemo_prescript
endif

" QFixMemoをautoloadで読み込み
if !exists('g:qfixmemo_autoload')
  let g:qfixmemo_autoload = 1
endif

" キーマップリーダー
if !exists('g:qfixmemo_mapleader')
  let g:qfixmemo_mapleader = 'g,'
endif
" デフォルトキーマップを有効
if !exists('g:qfixmemo_default_keymap')
  let g:qfixmemo_default_keymap = 1
endif
" メニューバーへ登録
if !exists('g:qfixmemo_menubar')
  let g:qfixmemo_menubar = has('gui_running')
endif
" howm_schedule.vimを使用する
" 0 : 使用しない
" 1 : autoload読込
" 2 : 起動時読込
if !exists('g:qfixmemo_use_howm_schedule')
  let g:qfixmemo_use_howm_schedule = 1
endif

if !exists('g:qfixmemo_use_howm2html')
  let g:qfixmemo_use_howm2html = 1
endif
" エントリ一覧表示にキャッシュを使用する
if !exists('g:qfixmemo_qfixlist_cache')
  let g:qfixmemo_qfixlist_cache = 1
endif
" help
if !exists('g:qfixmemo_help')
  let g:qfixmemo_help = 'qfixmemo_help'
endif

" コマンドラインコマンド
" コマンドは:QFixMemo [cmd]でも実行可能です。
" cmdにはキーマップを指定します。
" :QFixMemo c  " 新規作成
" command! -nargs=1 -count QFixMemo exe <SID>qfixmemo_command(<q-args>)
" command! -nargs=1 -count QFixHowm exe <SID>qfixmemo_command(<q-args>)

" howm2htmlユーザーコマンド
command! -bang -nargs=* -range=% Howm2html call howm2html#Howm2html(<bang>0, <f-args>)
command! -bang -nargs=* Howm2htmlJump      call howm2html#Jump2html(<bang>0, <f-args>)
command! -nargs=* Howm2HtmlConvFiles       call howm2html#HowmHtmlConvFiles('%', <q-args>)
command! -nargs=* -bang Howm2HtmlUpdate    call howm2html#HowmHtmlConvFiles('%', <q-args>, '<bang>')

if !exists('g:qfixmemo_keymap')
  let g:qfixmemo_keymap = {
    \ 'C'       : ':<C-u>call qfixmemo#EditInput()',
    \ 'c'       : ':<C-u>call qfixmemo#EditNew()',
    \ 'u'       : ':<C-u>call qfixmemo#Quickmemo()',
    \ 'U'       : ':<C-u>call qfixmemo#Quickmemo(0)',
    \ '<Space>' : ':<C-u>call qfixmemo#EditDiary(g:qfixmemo_diary)',
    \ 'j'       : ':<C-u>call qfixmemo#PairFile("%")',
    \ 'i'       : ':<C-u>call qfixmemo#SubMenu()',
    \ 'I'       : ':<C-u>call qfixmemo#SubMenu(0)',
    \ 'm'       : ':<C-u>call qfixmemo#ListMru()',
    \ 'M'       : ':<C-u>call qfixmemo#MoveToAltQFixWin()',
    \ 'l'       : ':<C-u>call qfixmemo#ListRecent()',
    \ 'L'       : ':<C-u>call qfixmemo#ListRecentTimeStamp()',
    \ 'a'       : ':<C-u>call qfixmemo#ListCmd()',
    \ 'ra'      : ':<C-u>call qfixmemo#ListCmd("nocache")',
    \ 'A'       : ':<C-u>call qfixmemo#ListFile(g:qfixmemo_diary)',
    \ 'rA'      : ':<C-u>call qfixmemo#Glob(g:qfixmemo_dir, "**/*", "open")',
    \ 'rN'      : ':<C-u>call qfixmemo#ListRenameFile(g:qfixmemo_filename)',
    \ 'rr'      : ':<C-u>call qfixmemo#RandomWalk(g:qfixmemo_random_file)',
    \ 'rR'      : ':<C-u>call qfixmemo#RebuildRandomCache(g:qfixmemo_random_file)',
    \ 'rk'      : ':<C-u>call qfixmemo#RebuildKeyword()',
    \ 's'       : ':<C-u>call qfixmemo#FGrep()',
    \ 'g'       : ':<C-u>call qfixmemo#Grep()',
    \ 'q'       : ':<C-u>call qfixmemo#Calendar()',
    \ 'Q'       : ':<C-u>call qfixmemo#Calendar("LR")',
    \ 'd'       : ':<C-u>call qfixmemo#InsertDate("Date")',
    \ 'T'       : ':<C-u>call qfixmemo#InsertDate("Time")',
    \ 'z'       : ':call qfixmemo#WildcardChapter()'
    \ }
endif

if !exists('g:qfixmemo_keymap_v')
  let g:qfixmemo_keymap_v = {
    \ 'z'  : ':call qfixmemo#WildcardChapter("visual")'
  \ }
endif

if !exists('g:qfixmemo_keymap_schedule')
  let g:qfixmemo_keymap_schedule = {
  \ 't'     : ':<C-u>call qfixmemo#ListReminderCache("todo")',
  \ 'rt'    : ':<C-u>call qfixmemo#ListReminder("todo")',
  \ 'y'     : ':<C-u>call qfixmemo#ListReminderCache("schedule")',
  \ '<Tab>' : ':<C-u>call qfixmemo#ListReminderCache("schedule")',
  \ 'ry'    : ':<C-u>call qfixmemo#ListReminder("schedule")',
  \ 'rd'    : ':<C-u>call qfixmemo#GenerateRepeatDate()',
  \ ','     : ':<C-u>call qfixmemo#OpenMenu("cache")',
  \ 'r,'    : ':<C-u>call qfixmemo#OpenMenu()',
  \ }
endif

if !exists('g:qfixmemo_keymap_html')
  let g:qfixmemo_keymap_html = {
  \ 'hi'    : ':Howm2html!',
  \ 'hr'    : ':Howm2html',
  \ 'hI'    : ':Howm2html! %',
  \ 'hR'    : ':Howm2html %',
  \ 'hj'    : ':Howm2htmlJump!',
  \ 'hJ'    : ':Howm2htmlJump!',
  \ }
endif

if !exists('g:qfixmemo_keymap_local')
  let g:qfixmemo_keymap_local = {
    \ 'P'  : ':call qfixmemo#QFixMRUMoveCursor("top")<CR>:<C-u>call qfixmemo#Template("top")',
    \ 'p'  : ':call qfixmemo#QFixMRUMoveCursor("prev")<CR>:<C-u>call qfixmemo#Template("prev")',
    \ 'n'  : ':call qfixmemo#QFixMRUMoveCursor("next")<CR>:<C-u>call qfixmemo#Template("next")',
    \ 'N'  : ':call qfixmemo#QFixMRUMoveCursor("bottom")<CR>:<C-u>call qfixmemo#Template("bottom")',
    \ 'x'  : ':<C-u>call qfixmemo#DeleteEntry()',
    \ 'X'  : ':<C-u>call qfixmemo#DeleteEntry("Move")',
    \ 'W'  : ':<C-u>call qfixmemo#DivideEntry()',
    \ 'S'  : ':<C-u>call qfixmemo#UpdateTime(1)',
    \ 'rs' : ':<C-u>call qfixmemo#SortEntry("Normal")',
    \ 'rS' : ':<C-u>call qfixmemo#SortEntry("Reverse")',
    \ 'f'  : ':<C-u>call qfixmemo#FGrep()',
    \ 'e'  : ':<C-u>call qfixmemo#Grep()',
    \ 'w'  : ':<C-u>call qfixmemo#ForceWrite()',
    \ 'rn' : ':<C-u>call qfixmemo#Rename()',
    \ 'o'  : ':call QFixMemoOutline()',
  \ }
endif

if !exists('g:qfixmemo_keymap_local_v')
  let g:qfixmemo_keymap_local_v = {
    \ 'W'  : ':call qfixmemo#DivideEntry()',
  \ }
endif

if !exists('g:qfixmemo_keymap_menu_local')
  let g:qfixmemo_keymap_menu_local = {
    \ 'P'  : ':call qfixmemo#QFixMRUMoveCursor("top")<CR>:<C-u>call qfixmemo#Template("top")',
    \ 'p'  : ':call qfixmemo#QFixMRUMoveCursor("prev")<CR>:<C-u>call qfixmemo#Template("prev")',
    \ 'n'  : ':call qfixmemo#QFixMRUMoveCursor("next")<CR>:<C-u>call qfixmemo#Template("next")',
    \ 'N'  : ':call qfixmemo#QFixMRUMoveCursor("bottom")<CR>:<C-u>call qfixmemo#Template("bottom")',
    \ 'S'  : ':<C-u>call qfixmemo#UpdateTime(1)',
    \ 'rs' : ':<C-u>call qfixmemo#SortEntry("Normal")',
    \ 'rS' : ':<C-u>call qfixmemo#SortEntry("Reverse")',
    \ 'x'  : ':<C-u>call qfixmemo#DeleteEntry()',
    \ 'X'  : ':<C-u>call qfixmemo#DeleteEntry("Move")',
    \ 'W'  : ':<C-u>call qfixmemo#DivideEntry()',
    \ 'o'  : ':call QFixMemoOutline()',
    \ }
endif

function! s:qfixmemo_command(cmd)
  let qfcmd = ''
  let cmd = a:cmd
  if cmd == 'H'
    return ':help '.g:qfixmemo_help
  endif

  let cmd = cmd =~ '\cspace' ? '<Space>' : cmd
  let cmd = cmd =~ '\ctab' ? '<Tab>' : cmd

  if exists('g:qfixmemo_keymap[cmd]')
    let qfcmd = g:qfixmemo_keymap[cmd]
  elseif g:qfixmemo_use_howm_schedule && exists('g:qfixmemo_keymap_schedule[cmd]')
    let qfcmd = g:qfixmemo_keymap_schedule[cmd]
  elseif g:qfixmemo_use_howm2html && exists('g:qfixmemo_keymap_html[cmd]')
    let qfcmd = g:qfixmemo_keymap_html[cmd]
  elseif exists('g:qfixmemo_keymap_menu_local[cmd]')
    let qfcmd = g:qfixmemo_keymap_menu_local[cmd]
  endif
  return qfcmd
endfunction

" デフォルトキーマップ
function! s:QFixMemoKeymap()
  if exists('*QFixMemoKeymap')
    call QFixMemoKeymap()
    return
  endif
  let leader = g:qfixmemo_mapleader
  exe 'silent! nnoremap <silent> <unique> '.leader.' <Nop>'

  for key in keys(g:qfixmemo_keymap)
    call s:qfkeycmd(leader, key, g:qfixmemo_keymap[key].'<CR>')
  endfor

  for key in keys(g:qfixmemo_keymap_v)
    call s:qfkeycmd(leader, key, g:qfixmemo_keymap_v[key].'<CR>', 'v')
  endfor

  if g:qfixmemo_use_howm_schedule
    let g:qfixmemo_howm_schedule_key = 1
    for key in keys(g:qfixmemo_keymap_schedule)
      call s:qfkeycmd(leader, key, g:qfixmemo_keymap_schedule[key].'<CR>')
    endfor
  endif

  if g:qfixmemo_use_howm2html
    for key in keys(g:qfixmemo_keymap_html)
      call s:qfkeycmd(leader, key, g:qfixmemo_keymap_html[key].'<CR>')
    endfor
  endif
endfunction

function! s:qfkeycmd(leader, key, cmd, ...)
  let mode = a:0 ? a:1 : 'n'
  exe 'silent! '.mode.'noremap <silent> '.a:leader.a:key.' '.a:cmd
endfunction

if !exists('*QFixMemoMenubar')
function QFixMemoMenubar(menu, leader)
  let leader  = escape(a:leader, '\\')
  let sepcmd  = 'amenu <silent> 41.333 '.a:menu.'.-sep%d-			<Nop>'
  let menucmd = 'amenu <silent> 41.333 '.a:menu.'.%s<Tab>'.leader.'%s %s'
  call s:addMenu(menucmd, 'CreateNew(&C)'      , 'c')
  call s:addMenu(menucmd, 'CreateNew(Name)(&N)', 'C')
  call s:addMenu(menucmd, 'QuickMemo(&U)'      , 'u')
  call s:addMenu(menucmd, 'Diary(&D)'    , '<Space>')
  call s:addMenu(menucmd, 'PairFile(&J)'       , 'j')
  exe printf(sepcmd, 1)
  let sepcmd  = 'amenu <silent> 41.334 '.a:menu.'.-sep%d-			<Nop>'
  let menucmd = 'amenu <silent> 41.334 '.a:menu.'.%s<Tab>'.leader.'%s %s'
  call s:addMenu(menucmd, 'MRU(&M)'              , 'm')
  call s:addMenu(menucmd, 'ListRecent(&L)'       , 'l')
  call s:addMenu(menucmd, 'ListRecent(Stamp)(&2)', 'L')

  if g:qfixmemo_qfixlist_cache
    call s:addMenu(menucmd, 'List(cache)(&E)', 'a')
    call s:addMenu(menucmd, 'ListAll(&A)'    , 'ra')
  else
    call s:addMenu(menucmd, 'ListAll(&A)',     'a')
  endif
  call s:addMenu(menucmd, 'DiaryList(&O)',     'A')
  call s:addMenu(menucmd, 'FileList(&F)',      'rA')
  exe printf(sepcmd, 2)
  call s:addMenu(menucmd, 'Calendar(&Q)', 'q')
  call s:addMenu(menucmd, 'SubMenu(&I)' , 'i')
  exe printf(sepcmd, 3)
  call s:addMenu(menucmd, 'FGrep(&S)', 's')
  call s:addMenu(menucmd, 'Grep(&G)' , 'g')
  if g:qfixmemo_use_howm_schedule
    exe printf(sepcmd, 4)
    call s:addMenu(menucmd, 'Menu(&,)'            , ',')
    call s:addMenu(menucmd, 'Schedule(&Y)'        , 'y')
    call s:addMenu(menucmd, 'Todo(&T)'            , 't')
    let submenu = '.Rebuild\ (&\.)'
    let menucmd = 'amenu <silent> 41.334 '.a:menu.submenu.'.%s<Tab>'.leader.'%s %s'
    call s:addMenu(menucmd, 'Rebuild-Menu(&\.)'   , 'r,')
    call s:addMenu(menucmd, 'Rebuild-Schedule(&V)', 'ry')
    call s:addMenu(menucmd, 'Rebuild-Todo(&W)'    , 'rt')
  endif
  let submenu = '.HTML\ (&P)'
  let menucmd = 'amenu <silent> 41.335 '.a:menu.submenu.'.%s<Tab>'.leader.'%s %s'
  if g:qfixmemo_use_howm2html
    exe printf(sepcmd, 5)
    call s:addMenu(menucmd, 'HTML(&I)'                 , 'hi')
    call s:addMenu(menucmd, 'Rebuild-HTML(&R)'         , 'hr')
    call s:addMenu(menucmd, 'HTML(static)(&I)'         , 'hI')
    call s:addMenu(menucmd, 'Rebuild-HTML(static)(&R)' , 'hR')
  endif
  let sepcmd  = 'amenu <silent> 41.336 '.a:menu.'.-sep%d-			<Nop>'
  let menucmd = 'amenu <silent> 41.336 '.a:menu.'.%s<Tab>'.leader.'%s %s'
  exe printf(sepcmd, 6)
  call s:addMenu(menucmd, 'RandomWalk(&R)'        , 'rr')
  call s:addMenu(menucmd, 'Rebuild-RandomWalk(&X)', 'rR')
  exe printf(sepcmd, 7)
  call s:addMenu(menucmd, 'Rebuild-Keyword(&K)', 'rk')
  " exe printf(sepcmd, 8)
  " call s:addMenu(menucmd, 'Rename(&Z)',       'rn')
  " call s:addMenu(menucmd, 'Rename-files(&Z)', 'rN')
  if g:qfixmemo_use_howm_schedule
    exe printf(sepcmd, 9)
    call s:addMenu(menucmd, 'Help(&H)', 'H')
  endif
  exe printf(sepcmd, 10)
  let submenu = '.Buffer[Local]\ (&B)'
  let sepcmd  = 'amenu <silent> 41.337 '.a:menu.submenu.'.-sep%d-			<Nop>'
  let menucmd = 'amenu <silent> 41.337 '.a:menu.submenu.'.%s<Tab>'.leader.'%s %s'
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
  if exists('*QFixMemoMenubarPost')
    call QFixMemoMenubarPost(a:menu, a:leader)
  endif
endfunction
endif

function! s:addMenu(menu, acc, key)
  " exe printf(a:menu, a:acc, a:key, a:cmd)
  let cmd = s:qfixmemo_command(a:key).'<CR>'
  exe printf(a:menu, a:acc, a:key, cmd)
endfunction

""""""""""""""""""""""""""""""
" global keymap
""""""""""""""""""""""""""""""
" ユーザーキーマップ
if !exists('*QFixMemoKeymapPost')
function QFixMemoKeymapPost()
endfunction
endif

if exists('g:mapleader')
  let s:mapleader = g:mapleader
endif
let g:mapleader = g:qfixmemo_mapleader

if g:qfixmemo_menubar
  call QFixMemoMenubar('Memo(&M)', g:qfixmemo_mapleader)
endif
if g:qfixmemo_default_keymap
  call s:QFixMemoKeymap()
endif
call QFixMemoKeymapPost()

if exists('s:mapleader')
  let g:mapleader = s:mapleader
else
  silent! unlet g:mapleader
endif

""""""""""""""""""""""""""""""
let s:howm_ext = 'howm'
" 新規メモファイル名
if !exists('g:qfixmemo_filename')
  let g:qfixmemo_filename      = '%Y/%m/%Y-%m-%d-%H%M%S'
endif
" メモファイルの拡張子(qfixmemo_filenameから設定)
if !exists('g:qfixmemo_ext')
  let g:qfixmemo_ext = fnamemodify(g:qfixmemo_filename, ':e')
  let g:qfixmemo_ext = g:qfixmemo_ext != '' ? g:qfixmemo_ext : 'txt'
endif
" タイトルマーカー
if !exists('g:qfixmemo_title')
  let g:qfixmemo_title         = '='
endif
" コードブロック正規表現
if !exists('g:qfixmemo_code_block')
  let g:qfixmemo_code_block = [
    \ {'start':'^\s*```',    'end':'^\s*```'},
    \ {'start':'^>|.\{-}|$', 'end':'^||<$'},
  \]
endif
if !exists('g:QFixMRU_CodeBlock')
  let g:QFixMRU_CodeBlock = g:qfixmemo_code_block
endif
" タイトル検索のエスケープパターン
if !exists('g:qfixmemo_escape')
  let g:qfixmemo_escape = '[]~*.\#'
endif

" タイトル検索用正規表現設定
if !exists('*QFixMemoTitleRegxp')
" MRUタイトルの正規表現リスト
if !exists('g:QFixMRU_Title')
  " let g:QFixMRU_Title = {'mkd' : '^#',  'wiki' : '^='}
  let g:QFixMRU_Title = {}
endif
" MRUに登録しないファイル名(正規表現)
if !exists('g:QFixMRU_IgnoreFile')
  let g:QFixMRU_IgnoreFile = '/\.*$\|/pairlink/\|/__submenu'
endif
" MRUに登録しないタイトル(正規表現)
if !exists('g:QFixMRU_IgnoreTitle')
let g:QFixMRU_IgnoreTitle = '^\[\|\[:invisible'
endif

function QFixMemoTitleRegxp()
  let g:qfixmemo_ext = tolower(g:qfixmemo_ext)
  let l:qfixmemo_title = escape(g:qfixmemo_title, g:qfixmemo_escape)
  if !exists('g:QFixMRU_Title["'.g:qfixmemo_ext.'"]')
    let g:QFixMRU_Title[g:qfixmemo_ext] = '^'.l:qfixmemo_title. '[^'.g:qfixmemo_title[0].']'
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
endif
" MRU取得対象チェック
" 0 : QFixMRU_Titleを利用しない(カレント行がタイトル行扱い)
" 1 : QFixMRU_Titleを利用する
function! QFixMRUGetPre(file)
  let root = g:qfixmemo_dir
  if exists('g:QFixMRU_RootDir')
    let g:qfixmemo_dir = g:QFixMRU_RootDir
  endif
  let isQFixMemo = IsQFixMemo(fnamemodify(expand(a:file), ':p'))
  let g:qfixmemo_dir = root
  return isQFixMemo
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

function! s:QFixMemoVimEnterCmd()
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

" VimEnter
if !exists('*QFixMemoVimEnter')
function QFixMemoVimEnter()
endfunction
endif

" コマンド実行前処理
if !exists('*QFixMemoInit')
function QFixMemoInit()
endfunction
endif

function! s:VimEnter()
  call QFixMemoInit()
  call QFixMemoTitleRegxp()
  call QFixMemoVimEnter()
  if g:qfixmemo_use_howm_schedule == 2
    call howm_schedule#Init()
  endif
  if exists('g:qfixmemo_vimenter_cmd') && g:qfixmemo_vimenter_cmd != ''
    call s:QFixMemoVimEnterCmd()
  endif
endfunction
au VimEnter * call <SID>VimEnter()

" autoload test
augroup QFixMemo
  au!
  au BufNewFile,BufRead * call <SID>BufRead()
  au BufEnter           * call <SID>BufEnter()
augroup END

if !exists('g:qfixmemo_dir')
  let g:qfixmemo_dir           = '~/qfixmemo'
endif
" 常にqfixmemoファイルとして扱うファイルの正規表現
if !exists('g:qfixmemo_isqfixmemo_regxp')
  let g:qfixmemo_isqfixmemo_regxp = '\c\.'.s:howm_ext.'$'
endif

function! IsQFixMemo(file)
  let file = fnamemodify(a:file, ':p')
  if g:qfixmemo_isqfixmemo_regxp != '' && file =~ g:qfixmemo_isqfixmemo_regxp
    return 1
  endif
  if tolower(fnamemodify(file, ':e')) != tolower(g:qfixmemo_ext)
    return 0
  endif
  let file = QFixNormalizePath(file, 'compare')
  let head = fnamemodify(expand(g:qfixmemo_dir), ':p:h')
  let head = QFixNormalizePath(head, 'compare')
  if stridx(file, head) == 0
    return 1
  endif
  if !isdirectory(g:qfixmemo_dir)
    return 0
  endif
  let saved_ei = &eventignore
  set eventignore=all
  let prevPath = s:escape(getcwd(), ' ')
  silent! exe 'chdir ' . s:escape(g:qfixmemo_dir, ' ')
  let head = getcwd()
  silent! exe 'chdir ' . prevPath
  let &eventignore = saved_ei
  let head = QFixNormalizePath(head, 'compare')
  if stridx(file, head) == 0
    return 1
  endif
  return 0
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

function! s:escape(str, chars)
  return escape(a:str, a:chars.((has('win32')|| has('win64')) ? '#%&' : '#%$'))
endfunction

function! s:BufEnter()
  if !IsQFixMemo(expand('%:p'))
    return
  endif
  call qfixmemo#load()
  call QFixMemoBufEnter()
endfunction

function! s:BufRead()
  if !IsQFixMemo(expand('%:p'))
    return
  endif
  call qfixmemo#BufRead()
endfunction

" カレンダーコマンドをオーバーライド
if !exists('g:qfixmemo_calendar')
  let g:qfixmemo_calendar = 0
endif
command! -nargs=* HowmCalendar  call howm_calendar#Calendar(0, <f-args>)
command! -nargs=* HowmCalendarH call howm_calendar#Calendar(1, <f-args>)

au VimEnter * call <SID>CalVimEnter()
function! s:CalVimEnter()
  if !exists(':Calendar') || g:qfixmemo_calendar
    command! -nargs=* Calendar  call howm_calendar#Calendar(0, <f-args>)
    command! -nargs=* CalendarH call howm_calendar#Calendar(1, <f-args>)
  endif
endfunction

let &cpo = s:saved_cpo
unlet s:saved_cpo

" autoload読み込み
if g:qfixmemo_autoload
  finish
endif
call qfixmemo#load()

