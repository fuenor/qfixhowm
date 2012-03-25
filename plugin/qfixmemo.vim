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
if v:version < 700 || &cp
  finish
endif
let s:debug = exists('g:fudist') ? g:fudist : 0

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

" howm2htmlユーザーコマンド
command! -bang -nargs=* -range=% Howm2html call howm2html#Howm2html(<bang>0, <f-args>)
command! -bang -nargs=* Jump2html          call howm2html#Jump2html(<bang>0, <f-args>)
command! -nargs=* HowmHtmlConvFiles        call howm2html#HowmHtmlConvFiles('%', <q-args>)
command! -nargs=* -bang HowmHtmlUpdate     call howm2html#HowmHtmlConvFiles('%', <q-args>, '<bang>')

" デフォルトキーマップ
function! s:QFixMemoKeymap()
  if exists('*QFixMemoKeymap')
    call QFixMemoKeymap()
    return
  endif
  let leader = g:qfixmemo_mapleader

  call s:qfkeycmd(leader, '', '<Nop>')

  call s:qfkeycmd(leader, 'C'       , ':<C-u>call qfixmemo#EditInput()<CR>')
  call s:qfkeycmd(leader, 'c'       , ':<C-u>call qfixmemo#EditNew()<CR>')
  call s:qfkeycmd(leader, 'u'       , ':<C-u>call qfixmemo#Quickmemo()<CR>')
  call s:qfkeycmd(leader, 'U'       , ':<C-u>call qfixmemo#Quickmemo(0)<CR>')
  call s:qfkeycmd(leader, '<Space>' , ':<C-u>call qfixmemo#EditDiary(g:qfixmemo_diary)<CR>')
  call s:qfkeycmd(leader, 'j'       , ':<C-u>call qfixmemo#PairFile("%")<CR>')
  call s:qfkeycmd(leader, 'i'       , ':<C-u>call qfixmemo#SubMenu()<CR>')
  call s:qfkeycmd(leader, 'I'       , ':<C-u>call qfixmemo#SubMenu(0)<CR>')

  call s:qfkeycmd(leader, 'm'       , ':<C-u>call qfixmemo#ListMru()<CR>')
  call s:qfkeycmd(leader, 'l'       , ':<C-u>call qfixmemo#ListRecent()<CR>')
  call s:qfkeycmd(leader, 'L'       , ':<C-u>call qfixmemo#ListRecentTimeStamp()<CR>')
  call s:qfkeycmd(leader, 'a'       , ':<C-u>call qfixmemo#ListCmd()<CR>')
  call s:qfkeycmd(leader, 'ra'      , ':<C-u>call qfixmemo#ListCmd("nocache")<CR>')
  call s:qfkeycmd(leader, 'A'       , ':<C-u>call qfixmemo#ListFile(g:qfixmemo_diary)<CR>')
  call s:qfkeycmd(leader, 'rA'      , ':<C-u>call qfixmemo#Glob(g:qfixmemo_dir, "**/*", "open")<CR>')
  call s:qfkeycmd(leader, 'rN'      , ':<C-u>call qfixmemo#ListRenameFile(g:qfixmemo_filename)<CR>')

  call s:qfkeycmd(leader, 'rr'      , ':<C-u>call qfixmemo#RandomWalk(g:qfixmemo_random_file)<CR>')
  call s:qfkeycmd(leader, 'rR'      , ':<C-u>call qfixmemo#RebuildRandomCache(g:qfixmemo_random_file)<CR>')
  call s:qfkeycmd(leader, 'rk'      , ':<C-u>call qfixmemo#RebuildKeyword()<CR>')

  call s:qfkeycmd(leader, 's'       , ':<C-u>call qfixmemo#FGrep()<CR>')
  call s:qfkeycmd(leader, 'g'       , ':<C-u>call qfixmemo#Grep()<CR>')

  call s:qfkeycmd(leader, 'q'       , ':<C-u>call qfixmemo#Calendar()<CR>')
  call s:qfkeycmd(leader, 'Q'       , ':<C-u>call qfixmemo#Calendar("LR")<CR>')
  call s:qfkeycmd(leader, 'o'       , ':<C-u>call QFixMemoOutline()<CR>')

  call s:qfkeycmd(leader, 'd'       , ':<C-u>call qfixmemo#InsertDate("Date")<CR>')
  call s:qfkeycmd(leader, 'T'       , ':<C-u>call qfixmemo#InsertDate("Time")<CR>')

  if g:qfixmemo_use_howm_schedule
    let g:qfixmemo_howm_schedule_key = 1
    call s:qfkeycmd(leader, 't'     , ':<C-u>call qfixmemo#ListReminderCache("todo")<CR>')
    call s:qfkeycmd(leader, 'rt'    , ':<C-u>call qfixmemo#ListReminder("todo")<CR>')
    call s:qfkeycmd(leader, 'y'     , ':<C-u>call qfixmemo#ListReminderCache("schedule")<CR>')
    call s:qfkeycmd(leader, '<Tab>' , ':<C-u>call qfixmemo#ListReminderCache("schedule")<CR>')
    call s:qfkeycmd(leader, 'ry'    , ':<C-u>call qfixmemo#ListReminder("schedule")<CR>')
    call s:qfkeycmd(leader, 'rd'    , ':<C-u>call qfixmemo#GenerateRepeatDate()<CR>')
    call s:qfkeycmd(leader, ','     , ':<C-u>call qfixmemo#OpenMenu("cache")<CR>')
    call s:qfkeycmd(leader, 'r,'    , ':<C-u>call qfixmemo#OpenMenu()<CR>')
  endif

  if g:qfixmemo_use_howm2html
    call s:qfkeycmd(leader, 'hi'    , ':Howm2html!<CR>')
    call s:qfkeycmd(leader, 'hr'    , ':Howm2html<CR>')
    call s:qfkeycmd(leader, 'hI'    , ':Howm2html! %<CR>')
    call s:qfkeycmd(leader, 'hR'    , ':Howm2html %<CR>')
    call s:qfkeycmd(leader, 'hj'    , ':Jump2html!<CR>')
    call s:qfkeycmd(leader, 'hJ'    , ':Jump2html!<CR>')
  endif
endfunction

function! s:qfkeycmd(leader, key, cmd)
  exe 'silent! nnoremap <silent> <unique> '.a:leader.a:key.' '.a:cmd
endfunction

silent! function QFixMemoMenubar(menu, leader)
  let leader  = escape(a:leader, '\\')
  let sepcmd  = 'amenu <silent> 41.333 '.a:menu.'.-sep%d-			<Nop>'
  let menucmd = 'amenu <silent> 41.333 '.a:menu.'.%s<Tab>'.leader.'%s %s'
  call s:addMenu(menucmd, 'CreateNew(&C)'      , 'c', ':<C-u>call qfixmemo#EditNew()<CR>')
  call s:addMenu(menucmd, 'CreateNew(Name)(&N)', 'C', ':<C-u>call qfixmemo#EditInput()<CR>')
  call s:addMenu(menucmd, 'QuickMemo(&U)'      , 'u', ':<C-u>call qfixmemo#Quickmemo()<CR>')
  call s:addMenu(menucmd, 'Diary(&D)'    , '<Space>', ':<C-u>call qfixmemo#EditDiary(g:qfixmemo_diary)<CR>')
  call s:addMenu(menucmd, 'PairFile(&J)'       , 'j', ':<C-u>call qfixmemo#PairFile("%")<CR>')
  exe printf(sepcmd, 1)
  let sepcmd  = 'amenu <silent> 41.334 '.a:menu.'.-sep%d-			<Nop>'
  let menucmd = 'amenu <silent> 41.334 '.a:menu.'.%s<Tab>'.leader.'%s %s'
  call s:addMenu(menucmd, 'MRU(&M)'              , 'm', ':<C-u>call qfixmemo#ListMru()<CR>')
  call s:addMenu(menucmd, 'ListRecent(&L)'       , 'l', ':<C-u>call qfixmemo#ListRecent()<CR>')
  call s:addMenu(menucmd, 'ListRecent(Stamp)(&2)', 'L', ':<C-u>call qfixmemo#ListRecentTimeStamp()<CR>')

  if g:qfixmemo_qfixlist_cache
    call s:addMenu(menucmd, 'List(cache)(&E)', 'a',  ':<C-u>call qfixmemo#ListCmd()<CR>')
    call s:addMenu(menucmd, 'ListAll(&A)'    , 'ra', ':<C-u>call qfixmemo#ListCmd("nocahe")<CR>')
  else
    call s:addMenu(menucmd, 'ListAll(&A)',     'a',  ':<C-u>call qfixmemo#ListCmd()<CR>')
  endif
  call s:addMenu(menucmd, 'DiaryList(&O)',     'A',  ':<C-u>call qfixmemo#ListFile(g:qfixmemo_diary)<CR>')
  call s:addMenu(menucmd, 'FileList(&F)',      'rA', ':<C-u>call qfixmemo#Glob(g:qfixmemo_dir, "**/*", "open")<CR>')
  exe printf(sepcmd, 2)
  call s:addMenu(menucmd, 'Calendar(&Q)', 'q', ':<C-u>call qfixmemo#Calendar()<CR>')
  call s:addMenu(menucmd, 'SubMenu(&I)' , 'i', ':<C-u>call qfixmemo#SubMenu()<CR>')
  exe printf(sepcmd, 3)
  call s:addMenu(menucmd, 'FGrep(&S)', 's', ':<C-u>call qfixmemo#FGrep()<CR>')
  call s:addMenu(menucmd, 'Grep(&G)' , 'g', ':<C-u>call qfixmemo#Grep()<CR>')
  if g:qfixmemo_use_howm_schedule
    exe printf(sepcmd, 4)
    call s:addMenu(menucmd, 'Menu(&,)'            , ',',  ':<C-u>call qfixmemo#OpenMenu()<CR>')
    call s:addMenu(menucmd, 'Schedule(&Y)'        , 'y',  ':<C-u>call qfixmemo#ListReminder("schedule")<CR>')
    call s:addMenu(menucmd, 'Todo(&T)'            , 't',  ':<C-u>call qfixmemo#ListReminder("todo")<CR>')
    call s:addMenu(menucmd, 'Rebuild-Menu(&\.)'   , 'r,', ':<C-u>call qfixmemo#OpenMenu("cache")<CR>')
    call s:addMenu(menucmd, 'Rebuild-Schedule(&V)', 'ry', ':<C-u>call qfixmemo#ListReminderCache("schedule")<CR>')
    call s:addMenu(menucmd, 'Rebuild-Todo(&W)'    , 'rt', ':<C-u>call qfixmemo#ListReminderCache("todo")<CR>')
  endif
  let submenu = '.HTML\ (&P)'
  let menucmd = 'amenu <silent> 41.335 '.a:menu.submenu.'.%s<Tab>'.leader.'%s %s'
  if g:qfixmemo_use_howm2html
    exe printf(sepcmd, 5)
    call s:addMenu(menucmd, 'HTML(&I)'                 , 'hi', ':Howm2html!<CR>')
    call s:addMenu(menucmd, 'Rebuild-HTML(&R)'         , 'hr', ':Howm2html % <CR>')
    call s:addMenu(menucmd, 'HTML(static)(&I)'         , 'hI', ':Howm2html! % <CR>')
    call s:addMenu(menucmd, 'Rebuild-HTML(static)(&R)' , 'hR', ':Howm2html % <CR>')
  endif
  let sepcmd  = 'amenu <silent> 41.336 '.a:menu.'.-sep%d-			<Nop>'
  let menucmd = 'amenu <silent> 41.336 '.a:menu.'.%s<Tab>'.leader.'%s %s'
  exe printf(sepcmd, 6)
  call s:addMenu(menucmd, 'RandomWalk(&R)'        , 'rr', ':<C-u>call qfixmemo#RandomWalk(g:qfixmemo_random_file)<CR>')
  call s:addMenu(menucmd, 'Rebuild-RandomWalk(&X)', 'rR', ':<C-u>call qfixmemo#RebuildRandomCache(g:qfixmemo_random_file)<CR>')
  exe printf(sepcmd, 7)
  call s:addMenu(menucmd, 'Rebuild-Keyword(&K)', 'rk', ':<C-u>call qfixmemo#RebuildKeyword()<CR>')
  exe printf(sepcmd, 8)
  call s:addMenu(menucmd, 'Rename(&Z)',       'rn', ':<C-u>call qfixmemo#Rename()<CR>')
  call s:addMenu(menucmd, 'Rename-files(&Z)', 'rN', ':<C-u>call qfixmemo#ListRenameFile(g:qfixmemo_filename)<CR>')
  if g:qfixmemo_use_howm_schedule
    exe printf(sepcmd, 9)
    call s:addMenu(menucmd, 'Help(&H)', 'H', ':help '.g:qfixmemo_help.'<CR>')
  endif
  exe printf(sepcmd, 10)
  let submenu = '.Buffer[Local]\ (&B)'
  let sepcmd  = 'amenu <silent> 41.337 '.a:menu.submenu.'.-sep%d-			<Nop>'
  let menucmd = 'amenu <silent> 41.337 '.a:menu.submenu.'.%s<Tab>'.leader.'%s %s'
  exe printf(sepcmd, 1)
  call s:addMenu(menucmd, 'Outline(&O)', 'o',  ':<C-u>call QFixMemoOutline()<CR>')
  exe printf(sepcmd, 2)
  call s:addMenu(menucmd, 'NewEntry(&1)', 'P', ':<C-u>call qfixmemo#Template("top")<CR>')
  call s:addMenu(menucmd, 'NewEntry(&P)', 'p', ':<C-u>call qfixmemo#Template("prev")<CR>')
  call s:addMenu(menucmd, 'NewEntry(&N)', 'n', ':<C-u>call qfixmemo#Template("next")<CR>')
  call s:addMenu(menucmd, 'NewEntry(&B)', 'N', ':<C-u>call qfixmemo#Template("bottom")<CR>')
  exe printf(sepcmd, 3)
  call s:addMenu(menucmd, 'UpdateTime(&S)'    , 'S',  ':<C-u>call qfixmemo#UpdateTime(1)<CR>')
  call s:addMenu(menucmd, 'SortEntry(&S)'     , 'rs', ':<C-u>call qfixmemo#SortEntry("Normal")<CR>')
  call s:addMenu(menucmd, 'SortEntry(rev)(&S)', 'rS', ':<C-u>call qfixmemo#SortEntry("Reverse")<CR>')

  exe printf(sepcmd, 4)
  call s:addMenu(menucmd, 'DeleteEntry(&X)', 'x' ,':<C-u>call qfixmemo#DeleteEntry()<CR>')
  call s:addMenu(menucmd, 'MoveEntry(&M)'  , 'X' ,':<C-u>call qfixmemo#DeleteEntry("Move")<CR>')
  call s:addMenu(menucmd, 'DivideEntry(&W)', 'W' ,':<C-u>call qfixmemo#DivideEntry()<CR>')
  if exists('*QFixMemoMenubarPost')
    call QFixMemoMenubarPost(a:menu, a:leader)
  endif
endfunction

function! s:addMenu(menu, acc, key, cmd)
  exe printf(a:menu, a:acc, a:key, a:cmd)
endfunction

""""""""""""""""""""""""""""""
" global keymap
""""""""""""""""""""""""""""""
" ユーザーキーマップ
silent! function QFixMemoKeymapPost()
endfunction

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
" タイトル検索のエスケープパターン
if !exists('g:qfixmemo_escape')
  let g:qfixmemo_escape = '[]~*.\#'
endif

" タイトル検索用正規表現設定
if !exists('*QFixMemoTitleRegxp')
function QFixMemoTitleRegxp()
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
endif

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
  if !exists('g:calendar_action') || g:calendar_action == "<SID>CalendarDiary"
    let g:calendar_action = "howm_calendar#CalendarDiary"
  endif
  if !exists('g:calendar_sign') || g:calendar_sign =~ '<SID>CalendarSign_\?' || g:calendar_sign == "CalendarSign_"
    let g:calendar_sign   = "howm_calendar#CalendarSign"
  endif
  if g:qfixmemo_calendar
    if g:calendar_action == 'vimwiki_diary#calendar_action'
      let g:calendar_action = "howm_calendar#CalendarDiary"
    endif
    if g:calendar_sign == 'vimwiki_diary#calendar_sign'
      let g:calendar_sign   = "howm_calendar#CalendarSign"
    endif
  endif
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
  let head = expand(g:qfixmemo_dir)
  let head = QFixNormalizePath(head, 'compare')
  if stridx(file, head) == 0
    return 1
  endif
  return 0
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
  let g:qfixmemo_calendar = 1
endif
" calendar.vimのコマンドをqfixmemo-calendar.vimのハイライト表示に変更
if !exists('g:calendar_howm_syntax')
  let g:calendar_howm_syntax = 1
endif

au VimEnter * call <SID>CalVimEnter()
function! s:CalVimEnter()
  if !exists(':Calendar') || g:qfixmemo_calendar
    command! -nargs=* Calendar  call howm_calendar#Calendar(0,<f-args>)
    command! -nargs=* CalendarH call howm_calendar#Calendar(1,<f-args>)
  elseif g:calendar_howm_syntax
    command! -nargs=* Calendar  call Calendar(0,<f-args>) | call howm_calendar#CalendarPost()
    command! -nargs=* CalendarH call Calendar(1,<f-args>) | call howm_calendar#CalendarPost()
  endif
endfunction

" autoload読み込み
if g:qfixmemo_autoload
  finish
endif
call qfixmemo#load()

