"=============================================================================
"    Description: howm style scheduler
"                 (要datelib.vim)
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/qfixhowm
"=============================================================================
let s:version = 257
scriptencoding utf-8

"=============================================================================
"    howmスタイルの予定・TODOを表示
"    (必要 qfixlist.vim)
"    (推奨 myqfix.vim, /syntax/howm_schedule.vim)
"
"    詳しい使い方は以下のサイトを参照してください。
"    http://sites.google.com/site/fudist/Home/qfixhowm/howm-reminder
"
"    QFixHowm以外でhowmスタイルの予定・TODOを使用したい場合は
"    /doc/howm_schedule.jaxを参照してください。
"
"     予定・TODO表示 (type : 'schedule' or 'todo')
"        :call howm_schedule#QFixHowmSchedule('schedule', 'c:/temp', 'utf-8')
"
"     QuickFixウィンドウを表示せずにQuickFixリスト取得も可能です。
"        " c:/temp以下を検索して予定・TODOのQuickFixリストを取得
"        let qflist = howm_schedule#QFixHowmScheduleQFList('schedule', 'c:/temp', 'utf-8')
"
"        " キャッシュされたQuickFixリスト取得
"        let [qflist, time] = howm_schedule#QFixHowmScheduleCachedQFList('schedule')
"
"        *qflistは getqflist()、timeは localtime() 参照
"
"     取得したqflistはqfixlist.vimでも表示可能です。
"        " QuickFix
"        :call qfixlist#copen(qflist, 'c:/temp')
"        " QFixList window
"        :call qfixlist#open(qflist, 'c:/temp')
"
"     datelib.vim
"       日付計算と休日定義についてはdatelib.vimを参照してください。
"
"=============================================================================
if exists('g:disable_HowmSchedule') && g:disable_HowmSchedule
  finish
endif
if exists('g:QFixHowmSchedule_version') && g:QFixHowmSchedule_version < s:version
  let g:loaded_HowmSchedule = 0
endif
if exists("g:loaded_HowmSchedule") && g:loaded_HowmSchedule && !exists('fudist')
  finish
endif
let g:QFixHowmSchedule_version = s:version
if v:version < 700 || &cp || !has('quickfix')
  finish
endif
let s:debug = exists('g:fudist') ? g:fudist : 0

""""""""""""""""""""""""""""""
" Do you like spagehtti?
" OK, go ahead. You have been warned!

let s:howm_dir = ''
let s:howm_fileencoding = ''
function! QFixHowmSchedule(type, dir, fenc, ...)
  let s:howm_dir          = a:dir
  let s:howm_fileencoding = a:fenc
  let mode = a:0 ? a:1 : ''
  let sq = s:QFixHowmListReminder_(a:type, mode)
  let s:howm_dir = ''
  let s:howm_fileencoding = ''
  return sq
endfunction

function! QFixHowmScheduleQFList(type, dir, fenc)
  return QFixHowmSchedule(a:type, a:dir, a:fenc, 'qflist')
endfunction

function! QFixHowmScheduleCachedQFList(mode)
  exe 'let time = s:LT_'.a:mode
  exe 'let sq = s:sq_'.a:mode
  return [sq, time]
endfunction

function! howm_schedule#QFixHowmSchedule(type, dir, fenc, ...)
  let s:howm_dir          = a:dir
  let s:howm_fileencoding = a:fenc
  let mode = a:0 ? a:1 : ''
  let sq = s:QFixHowmListReminder_(a:type, mode)
  let s:howm_dir = ''
  let s:howm_fileencoding = ''
  return sq
endfunction

function! howm_schedule#QFixHowmScheduleQFList(type, dir, fenc)
  return QFixHowmSchedule(a:type, a:dir, a:fenc, 'qflist')
endfunction

function! howm_schedule#QFixHowmScheduleCachedQFList(mode)
  exe 'let time = s:LT_'.a:mode
  exe 'let sq = s:sq_'.a:mode
  return [sq, time]
endfunction

""""""""""""""""""""""""""""""
let s:howmsuffix = 'howm'
" if !exists('howm_dir')
"   let howm_dir = '~/howm'
"   if exists('g:qfixmemo_dir')
"     let howm_dir = g:qfixmemo_dir
"   endif
" endif
" if !exists('QFixHowm_FileExt')
"   let QFixHowm_FileExt = ''
"   if exists('g:qfixmemo_filename')
"     let QFixHowm_FileExt = fnamemodify(g:qfixmemo_filename,':e')
"   endif
"   if g:QFixHowm_FileExt == '' && exists('g:howm_filename')
"     let g:QFixHowm_FileExt  = fnamemodify(g:howm_filename,':e')
"   endif
"   if g:QFixHowm_FileExt == ''
"     let g:QFixHowm_FileExt = 'txt'
"   endif
" endif
" if !exists('howm_fileencoding')
"   let howm_fileencoding = &enc
"   if exists('g:qfixmemo_fileencoding')
"     let howm_fileencoding = g:qfixmemo_fileencoding
"   endif
" endif

"キーマップリーダー
if !exists('g:QFixHowm_Key')
  if exists('g:howm_mapleader')
    let g:QFixHowm_Key = howm_mapleader
  else
    let g:QFixHowm_Key = 'g'
  endif
endif
"2ストローク目キーマップ
if !exists('g:QFixHowm_KeyB')
  let g:QFixHowm_KeyB = ','
endif
"キーマップを使用する
if !exists('g:QFixHowm_Default_Key')
  let g:QFixHowm_Default_Key = 1
endif
"メニューへの登録
if !exists('QFixHowm_MenuBar')
  let QFixHowm_MenuBar = 2
endif

"正規表現パーツ
if !exists('g:QFixHowm_DatePattern')
  let g:QFixHowm_DatePattern = '%Y-%m-%d'
endif

"予定・TODOを検索するルートディレクトリ
if !exists('g:QFixHowm_ScheduleSearchDir')
  let g:QFixHowm_ScheduleSearchDir = ''
endif
"予定・TODOを検索するファイル
if !exists('g:QFixHowm_ScheduleSearchFile')
  let g:QFixHowm_ScheduleSearchFile = ''
endif
"予定・TODOを検索する時vimgrepを使用する
if !exists('g:QFixHowm_ScheduleSearchVimgrep')
  let g:QFixHowm_ScheduleSearchVimgrep = 0
endif

"休日定義ファイル
if !exists('g:QFixHowm_HolidayFile')
  let g:QFixHowm_HolidayFile = 'Sche-Hd-0000-00-00-000000.*'
endif
"休日名
if !exists('g:QFixHowm_ReminderHolidayName')
  let g:QFixHowm_ReminderHolidayName = '元日\|成人の日\|建国記念の日\|昭和の日\|憲法記念日\|みどりの日\|こどもの日\|海の日\|敬老の日\|体育の日\|文化の日\|勤労感謝の日\|天皇誕生日\|春分の日\|秋分の日\|振替休日\|国民の休日\|日曜日'
endif

"予定やTODOのデフォルト値
if !exists('g:QFixHowm_ReminderDefault_Deadline')
  let g:QFixHowm_ReminderDefault_Deadline = 7
endif
if !exists('g:QFixHowm_ReminderDefault_Schedule')
  let g:QFixHowm_ReminderDefault_Schedule = 0
endif
if !exists('g:QFixHowm_ReminderDefault_Reminder')
  let g:QFixHowm_ReminderDefault_Reminder = 1
endif
if !exists('g:QFixHowm_ReminderDefault_Todo')
  let g:QFixHowm_ReminderDefault_Todo     = 7
endif
if !exists('g:QFixHowm_ReminderDefault_UD')
  let g:QFixHowm_ReminderDefault_UD       = 30
endif

",y の予定表示日数
if !exists('g:QFixHowm_ShowSchedule')
  let g:QFixHowm_ShowSchedule     = 10
endif
",t の予定表示日数
if !exists('g:QFixHowm_ShowScheduleTodo')
  let g:QFixHowm_ShowScheduleTodo = -1
endif
",,の予定表示日数
if !exists('g:QFixHowm_ShowScheduleMenu')
  let g:QFixHowm_ShowScheduleMenu = 10
endif
",y で表示する予定・TODO
if !exists('g:QFixHowm_ListReminder_ScheExt')
  let g:QFixHowm_ListReminder_ScheExt = '[@!.]'
endif
",t で表示する予定・TODO
if !exists('g:QFixHowm_ListReminder_TodoExt')
  let g:QFixHowm_ListReminder_TodoExt = '[-@+!~.]'
endif
"メニューファイル名
if !exists('g:QFixHowm_Menufile')
  let g:QFixHowm_Menufile = 'Menu-00-00-000000.'.s:howmsuffix
endif
"menuで表示する予定・TODO
if !exists('g:QFixHowm_ListReminder_MenuExt')
  let g:QFixHowm_ListReminder_MenuExt = '[-@+!~.]'
endif
"予定・TODOのキャッシュを保持する時間
if !exists('g:QFixHowm_ListReminderCacheTime')
  let g:QFixHowm_ListReminderCacheTime = 5*60
endif

"予定・TODOのソート優先順
if !exists('g:QFixHowm_ReminderPriority')
  let g:QFixHowm_ReminderPriority = {'@' : 1, '!' : 2, '+' : 3, '-' : 4, '~' : 5, '.' : 6}
endif
"予定・TODOの同一日、同一種類のソート正順/逆順
if !exists('g:QFixHowm_ReminderSortMode')
  let g:QFixHowm_ReminderSortMode = 1
endif
"今日の時刻の扱い
if !exists('g:QFixHowm_TodayLineType')
  let g:QFixHowm_TodayLineType = '@'
endif
"同一日、同一内容の予定・TODOは一つにまとめる
if !exists('g:QFixHowm_RemoveSameSchedule')
  let g:QFixHowm_RemoveSameSchedule = 1
endif
"予定を表示する際、曜日も表示する
if !exists('g:QFixHowm_ShowScheduleDayOfWeek')
  let g:QFixHowm_ShowScheduleDayOfWeek = 1
endif
"予定・TODOに今日の日付を表示
if !exists('g:QFixHowm_ShowTodayLine')
  let g:QFixHowm_ShowTodayLine = 3
endif
"予定・TODOの今日の日付表示用セパレータ
if !exists('g:QFixHowm_ShowTodayLineStr')
  let g:QFixHowm_ShowTodayLineStr = '------------------------------'
endif
"予定・TODOの今日の日付表示のファイルネーム
if !exists('g:QFixHowm_TodayFname')
  let g:QFixHowm_TodayFname = '='
endif

"予定・TODOでプレビュー表示を有効にする
if !exists('g:QFixHowm_SchedulePreview')
  let g:QFixHowm_SchedulePreview = 1
endif
"予定やTodoのプライオリティレベルが、これ未満のエントリは削除する
if !exists('g:QFixHowm_RemovePriority')
  let g:QFixHowm_RemovePriority = 1
endif
"予定やTodoのプライオリティレベルが、今日よりこれ以下なら削除する。
if !exists('g:QFixHowm_RemovePriorityDays')
  let g:QFixHowm_RemovePriorityDays = 0
endif
"リマインダの継続期間のオフセット
if !exists('g:QFixHowm_ReminderOffset')
  let g:QFixHowm_ReminderOffset = 0
endif
"終了日指定のオフセット
if !exists('g:QFixHowm_EndDateOffset')
  let g:QFixHowm_EndDateOffset = 0
endif

"strftime()の基準年
if !exists('g:YearStrftime')
  let g:YearStrftime = 1970
endif
" strftime()の初週曜日
if !exists('g:DoWStrftime')
  let g:DoWStrftime = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
endif
"GMTとの時差
if !exists('g:QFixHowm_ST')
  let g:QFixHowm_ST = -9
endif

"タイトルフィルタ用正規表現
if !exists('g:QFixHowm_TitleFilterReg')
  let g:QFixHowm_TitleFilterReg = ''
endif

" "タブで編集('tab'を設定)
" if !exists('QFixHowm_Edit')
"   let QFixHowm_Edit = ''
" endif

if !exists('g:howm_schedule_key')
  let g:howm_schedule_key = 0
endif

let s:QFixHowm_Key = g:QFixHowm_Key . g:QFixHowm_KeyB
if g:QFixHowm_Default_Key > 0 && g:howm_schedule_key
  exe 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'t     :<C-u>call QFixHowmListReminderCache("todo")<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'rt    :<C-u>call QFixHowmListReminder("todo")<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'y     :<C-u>call QFixHowmListReminderCache("schedule")<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'<Tab> :<C-u>call QFixHowmListReminderCache("schedule")<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'ry    :<C-u>call QFixHowmListReminder("schedule")<CR>'
  exe 'silent! nnoremap <unique> <silent> '.s:QFixHowm_Key.'rd    :<C-u>call QFixHowmGenerateRepeatDate()<CR>'
  exe "silent! nnoremap <unique> <silent> ".s:QFixHowm_Key."d     :call QFixHowmInsertDate('Date')<CR>"
  exe "silent! nnoremap <unique> <silent> ".s:QFixHowm_Key."T     :call QFixHowmInsertDate('Time')<CR>"
endif

""""""""""""""""""""""""""""""
" commands
""""""""""""""""""""""""""""""
" ShowReminder commands
command! -count -nargs=* QFixHowmListReminderSche      call QFixHowmListReminder("schedule")
command! -count -nargs=* QFixHowmListReminderTodo      call QFixHowmListReminder("todo")
command! -count -nargs=* QFixHowmListReminderScheCache call QFixHowmListReminderCache("schedule")
command! -count -nargs=* QFixHowmListReminderTodoCache call QFixHowmListReminderCache("todo")

function! s:makeRegxp(dpattern)
  let s:hts_date     = a:dpattern
  let s:hts_time     = '%H:%M'
  let s:hts_dateTime = s:hts_date . ' '. s:hts_time

  "let s:sch_date     = '\d\{4}-\d\{2}-\d\{2}'
  let s:sch_date = s:hts_date
  let s:sch_date = substitute(s:sch_date, '%Y', '\\d\\{4}', 'g')
  let s:sch_date = substitute(s:sch_date, '%m', '\\d\\{2}', 'g')
  let s:sch_date = substitute(s:sch_date, '%d', '\\d\\{2}', 'g')
  let g:QFixHowm_Date = s:sch_date

  let s:sch_date_eom = s:hts_date
  let s:sch_date_eom = substitute(s:sch_date_eom, '%Y', '\\d\\{4}', 'g')
  let s:sch_date_eom = substitute(s:sch_date_eom, '%m', '\\d\\{2}', 'g')
  let s:sch_date_eom = substitute(s:sch_date_eom, '%d', '00', 'g')

  let s:sch_printfDate = s:hts_date
  let s:sch_printfDate = substitute(s:sch_printfDate, '%Y', '%4.4d', 'g')
  let s:sch_printfDate = substitute(s:sch_printfDate, '%m', '%2.2d', 'g')
  let s:sch_printfDate = substitute(s:sch_printfDate, '%d', '%2.2d', 'g')

  let s:sch_ExtGrep = s:hts_date. ' ' . s:hts_time
  let s:sch_ExtGrep = substitute(s:sch_ExtGrep, '%Y', '[0-9][0-9][0-9][0-9]', 'g')
  let s:sch_ExtGrep = substitute(s:sch_ExtGrep, '%m', '[0-9][0-9]', 'g')
  let s:sch_ExtGrep = substitute(s:sch_ExtGrep, '%d', '[0-9][0-9]', 'g')
  let s:sch_ExtGrep = substitute(s:sch_ExtGrep, '%H', '[0-9][0-9]', 'g')
  let s:sch_ExtGrep = substitute(s:sch_ExtGrep, '%M', '[0-9][0-9]', 'g')

  let s:sch_ExtGrepS = s:hts_date. '( ' . s:hts_time . ')?'
  let s:sch_ExtGrepS = substitute(s:sch_ExtGrepS, '%Y', '[0-9][0-9][0-9][0-9]', 'g')
  let s:sch_ExtGrepS = substitute(s:sch_ExtGrepS, '%m', '[0-9][0-9]', 'g')
  let s:sch_ExtGrepS = substitute(s:sch_ExtGrepS, '%d', '[0-9][0-9]', 'g')
  let s:sch_ExtGrepS = substitute(s:sch_ExtGrepS, '%H', '[0-9][0-9]', 'g')
  let s:sch_ExtGrepS = substitute(s:sch_ExtGrepS, '%M', '[0-9][0-9]', 'g')

  "let s:sch_time     = '\d\{2}:\d\{2}'
  let s:sch_time = s:hts_time
  let s:sch_time = substitute(s:sch_time, '%H', '\\d\\{2}', '')
  let s:sch_time = substitute(s:sch_time, '%M', '\\d\\{2}', '')

  let s:sch_dateT    = '\['.s:sch_date.'\( '.s:sch_time.'\)\?\]'
  let s:sch_dateTime = '\['.s:sch_date.' '.s:sch_time.'\]'
  let s:sch_dow      = '\c\(\(Sun\|Mon\|Tue\|Wed\|Thu\|Fri\|Sat\|Hol\|Hdy\)\)'
  let s:sch_ext      = '-@!+~.'
  let s:sch_Ext      = '['.s:sch_ext.']'
  let s:sch_notExt   = '[^'.s:sch_ext.']'
  let s:sch_dateCmd  = s:sch_dateT . s:sch_Ext . '\{1,3}\(([0-9]*[-+*]\?'.s:sch_dow.'\?)\)\?[0-9]*'
  let s:sch_cmd      = s:sch_Ext . '\{1,3}\(([0-9]*[-+*]\?'.s:sch_dow.'\?\([-+]\d\+\)\?)\)\?[0-9]*'
  let s:Recentmode_Date   = '(\d\{12})'
  let g:qfixmemo_scheduleformat = s:sch_dateCmd
endfunction
call s:makeRegxp(g:QFixHowm_DatePattern)

let s:LT_schedule = 0
let s:sq_schedule = []
let s:LT_todo = 0
let s:sq_todo = []
let s:LT_menu = 0
let s:sq_menu = []
let s:sq_reminder = []
if !exists('g:qfixtempname')
  let g:qfixtempname = tempname()
endif
let s:howmtempfile = g:qfixtempname

" jvgrep使用時に正規表現[-abc]の - をエスケープして実行
if !exists('g:QFixHowm_jvgrep_escape_hyphen')
  let g:QFixHowm_jvgrep_escape_hyphen = 1
endif

function! QFixHowmInsertDate(fmt)
  let fmt = s:hts_dateTime
  if a:fmt == 'Date'
    let fmt = s:hts_date
  endif
  let str = strftime('['.fmt.']')
  silent! put=str
  startinsert!
endfunction

let s:reminder_cache = 0
function! QFixHowmListReminderCache(mode)
  if count > 0
    if a:mode =~ 'schedule'
      let g:QFixHowm_ShowSchedule = count
    elseif a:mode =~ 'todo'
      let g:QFixHowmListReminderTodo = count
    endif
  endif
  if exists('*QFixHowmInit') && QFixHowmInit()
    return
  endif
  exe 'let lt = localtime() - s:LT_' . a:mode
  if count
    " let lt = g:QFixHowm_ListReminderCacheTime + 1
  endif
  if g:QFixHowm_ListReminderCacheTime > 0 && lt < g:QFixHowm_ListReminderCacheTime
    let s:reminder_cache = 1
    exe 'let sq_reminder = s:sq_' . a:mode
    return QFixHowmListReminder(a:mode)
  else
    return QFixHowmListReminder(a:mode)
  endif
endfunction

function! QFixHowmListReminder(mode)
  if count > 0
    if a:mode =~ 'schedule'
      let g:QFixHowm_ShowSchedule = count
    elseif a:mode =~ 'todo'
      let g:QFixHowmListReminderTodo = count
    endif
  endif
  if exists('*QFixHowmInit') && QFixHowmInit()
    return []
  endif
  if a:mode =~ 'menu'
    let saved_sq = getloclist(0)
  endif
  let sq = s:QFixHowmListReminder_(a:mode)
  if a:mode =~ 'menu'
    call setloclist(0, saved_sq)
  endif
  return sq
endfunction

function! s:QFixHowmListReminder_(mode,...)
  if exists('*QFixHowmInit') && QFixHowmInit()
    return []
  endif
  let addflag = 0
  let l:howm_dir = '~/howm'
  let l:howm_dir = exists('g:howm_dir') ? g:howm_dir : l:howm_dir
  let l:howm_dir = exists('g:qfixmemo_dir') ? g:qfixmemo_dir : l:howm_dir
  let l:howm_dir = s:howm_dir != '' ? s:howm_dir : l:howm_dir
  if g:QFixHowm_ScheduleSearchDir != ''
    let l:howm_dir = g:QFixHowm_ScheduleSearchDir
  endif
  let l:SearchFile = '**/*.*'
  if exists('g:QFixHowm_SearchHowmFile')
    let l:SearchFile = g:QFixHowm_SearchHowmFile
  endif
  if g:QFixHowm_ScheduleSearchFile != ''
    let l:SearchFile = g:QFixHowm_ScheduleSearchFile
  endif

  if s:reminder_cache == 0
    let holiday_sq = s:HolidayVimgrep(l:howm_dir, g:QFixHowm_HolidayFile)
  endif
  call QFixPclose(1)
  let prevPath = escape(getcwd(), ' ')
  silent! exe 'lchdir ' . escape(l:howm_dir, ' ')
  let ext = s:sch_Ext
  if a:mode =~ 'todo'
    let ext = g:QFixHowm_ListReminder_TodoExt
    if g:QFixHowm_ShowScheduleTodo < 0
      let ext = substitute(ext, '@', '', '')
    endif
  elseif a:mode =~ 'schedule'
    let ext = g:QFixHowm_ListReminder_ScheExt
    if g:QFixHowm_ShowSchedule < 0
      let ext = substitute(ext, '@', '', '')
    endif
  elseif a:mode =~ 'menu'
    let ext = g:QFixHowm_ListReminder_MenuExt
    if g:QFixHowm_ShowScheduleMenu < 0
      let ext = substitute(ext, '@', '', '')
    endif
  endif
  if g:QFixHowm_RemovePriority > -1
    let ext = substitute(ext, '\.', '', '')
  endif
  if !exists('g:mygrepprg') || g:mygrepprg == 'internal' || g:mygrepprg == '' || g:QFixHowm_ScheduleSearchVimgrep
    let g:MyGrep_UseVimgrep = 1
    let searchWord = '^\s*'.s:sch_dateT.ext
  elseif g:mygrepprg == 'findstr'
    let searchWord = s:hts_date
    let searchWord = substitute(searchWord, '%Y', '[0-9][0-9][0-9][0-9]', '')
    let searchWord = substitute(searchWord, '%m', '[0-9][0-9]', '')
    let searchWord = substitute(searchWord, '%d', '[0-9][0-9]', '')
    let searchWord = '^[ \t]*\['.searchWord.'[0-9: ]*\]'.ext
  else
    let searchWord = '^[ \t]*\['.s:sch_ExtGrepS.'\]'.ext
    if g:mygrepprg =~ 'jvgrep' && g:QFixHowm_jvgrep_escape_hyphen
      let searchWord = substitute(searchWord, '\(^\|[^\\]\)[-', '\1[\\-', 'g')
    endif
  endif
  let searchPath = l:howm_dir
  if s:reminder_cache == 0
    redraw | echo 'QFixHowm : execute grep...'
    let l:howm_fileencoding = &enc
    let l:howm_fileencoding = exists('g:howm_fileencoding') ? g:howm_fileencoding : l:howm_fileencoding
    let l:howm_fileencoding = exists('g:qfixmemo_fileencoding') ? g:qfixmemo_fileencoding : l:howm_fileencoding
    let l:howm_fileencoding = s:howm_fileencoding != '' ? s:howm_fileencoding : l:howm_fileencoding
    if exists('*MultiHowmDirGrep')
      if g:QFixHowm_ScheduleSearchDir == ''
        let addflag = MultiHowmDirGrep(searchWord, searchPath, l:SearchFile, l:howm_fileencoding, addflag)
      else
        let addflag = MultiHowmDirGrep(searchWord, searchPath, l:SearchFile, l:howm_fileencoding, addflag, 'g:QFixHowm_ScheduleSearchDir')
      endif
    endif
    let sq = qfixlist#grep(searchWord, searchPath, l:SearchFile, l:howm_fileencoding)
    call extend(sq, holiday_sq)
    let s:UseTitleFilter = 1
    call QFixHowmTitleFilter(sq)
    redraw|echo 'QFixHowm : Sorting...'
    let sq = s:QFixHowmSortReminderPre(sq)
    exe 'let s:sq_' . a:mode . ' = deepcopy(sq)'
    exe 'let s:LT_' . a:mode . ' = localtime()'
  else
    exe 'let sq = deepcopy(s:sq_' . a:mode . ')'
  endif
  let sq = s:QFixHowmSortReminder(sq, a:mode)
  let sq = s:AddTodayLine(sq)
  let sq = s:CnvDayOfWeek(sq)
  if a:mode == 'menu' || (a:0 && a:1 == 'qflist')
    let s:reminder_cache = 0
    redraw | echo ''
    return sq
  endif
  if empty(sq)
    redraw | echo 'QFixHowm : Not found!'
  else
    let g:QFix_SearchPath = l:howm_dir
    " redraw|echo 'QFixHowm : Set quickfix list...'
    " call QFixSetqflist(sq)
    " call QFixCopen()
    call qfixlist#copen(sq, g:QFix_SearchPath)
    call cursor(1, 1)
    if g:QFixHowm_SchedulePreview == 0 && g:QFix_PreviewEnable == 1
      let g:QFix_PreviewEnable = -1
    endif
    exe 'normal! zz'
    if s:reminder_cache
      exe 'let lt = localtime() - s:LT_' . a:mode
      redraw|echo 'QFixHowm : Cached '.a:mode . '. ('.lt/60.' minutes ago)'
    endif
  endif
  silent! exe 'lchdir ' . prevPath
  let s:reminder_cache = 0
  return sq
endfunction

" 日付を今日までの日数に変換
function! QFixHowmDate2Int(str)
  let str = a:str
  let retval = 'time'
  "422(22)フォーマット前提の ザ・決め打ち
  let str   = substitute(str, '[^0-9]','', 'g')
  let year  = matchstr(str, '\d\{4}')
  let str   = substitute(str, '\d\{4}','', '')
  let month = matchstr(str, '\d\{2}')
  let str   = substitute(str, '\d\{2}','', '')
  let day   = matchstr(str, '\d\{2}')
  let str   = substitute(str, '\d\{2} \?','', '')
  let hour  = matchstr(str, '\d\{2}')
  let str   = substitute(str, '\d\{2}:\?','', '')
  let min   = matchstr(str, '\d\{2}')
  if hour == '' || min == ''
    let retval = 'date'
    let hour  = strftime('%H', localtime())
    let min   = strftime('%M', localtime())
  endif
  if day == '00'
    let day = s:Overday(year, month, day)
  endif

  " 1・2月 → 前年の13・14月
  if month <= 2
    let year = year - 1
    let month = month + 12
  endif
  let dy = 365 * (year - 1) " 経過年数×365日
  let c = year / 100
  let dl = (year / 4) - c + (c / 4)  " うるう年分
  let dm = (month * 979 - 1033) / 32 " 1月1日から month 月1日までの日数
  let today = dy + dl + dm + day - 1

  if retval =~ 'date'
    return today
  endif

  let today = today - g:DateStrftime
  let sec = today * 24*60*60 + g:QFixHowm_ST * (60 * 60) "JST = -9
  let sec = sec + hour * (60 * 60) + min * 60

  return sec
endfunction

" 月末日処理
function! s:Overday(year, month, day)
  let year = a:year
  let month = a:month
  if month > 12
    let year += 1
    let month = month - 12
  endif
  let day = a:day
  let monthdays = [31,28,31,30,31,30,31,31,30,31,30,31]
  if (year%4 == 0 && year%100 != 0) || year%400 == 0
    let monthdays[1] = 29
  endif
  if monthdays[month-1] < day
    let day = monthdays[month-1]
  endif
  if day == 0
    let day = monthdays[month-1]
  endif
  return day
endfunction

" 休日リスト作成
function! s:HolidayVimgrep(dir, file)
  " WindowsでDOSプロンプトを出さないために vimgrepを使用
  " ファイルが一つなので、パフォーマンスには影響がない
  let dir = a:dir
  let file = a:file
  let hdir = fnamemodify(file, ':h')
  if hdir != '.'
    let dir = hdir
    let file = fnamemodify(file, ':t')
  endif
  let dir = expand(dir)
  let dir = substitute(dir, '\\', '/', 'g')
  let ext = '[@]'
  let pattern = '^'.s:sch_dateT.ext
  let prevPath = escape(getcwd(), ' ')
  exe 'lchdir ' . escape(dir, ' ')
  let saved_sq = getloclist(0)
  lexpr ""
  let cmd = 'lvimgrep /' . escape(pattern, '/') . '/j ' . escape(file, ' ')
  silent! exe cmd
  silent! exe 'lchdir ' . prevPath
  let sq = getloclist(0)
  let sq = s:QFixHowmSortReminderPre(sq)
  let sq = s:QFixHowmSortReminder(sq, 'holiday')
  call filter(sq, "v:val['lnum']")
  let s:HolidayList = []
  for d in sq
    let day = QFixHowmDate2Int(d['text'])
    call add(s:HolidayList, day)
  endfor
  let sq = getloclist(0)
  for d in sq
    let d['bufnr'] = ''
    let d['col'] = ''
    let d['filename'] = file
  endfor
  call setloclist(0, saved_sq)
  return sq
endfunction

"休日のみを取りだしてリストを作成する。
function! s:MakeHolidayList(sq)
  let s:HolidayList = []
  for d in a:sq
    let day = QFixHowmDate2Int(d['text'])
    call add(s:HolidayList, day)
  endfor
  return a:sq
endfunction

" リマインダーにpriorityをセットしてソートする
function! s:QFixHowmSortReminder(sq, mode)
  let qflist = a:sq
  let today = QFixHowmDate2Int(strftime(s:hts_date))
  let tsec = localtime()
  if exists('g:QFixHowmToday')
    let today = QFixHowmDate2Int(g:QFixHowmToday)
    let tsec  = QFixHowmDate2Int(g:QFixHowmToday . ' 00:00')
  endif

  let ttime = (today - g:QFixHowm_ReminderDefault_Schedule - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9
  let todaychk = strftime(s:hts_date, ttime)

  let idx = 0
  for d in qflist
    let d.text = substitute(d.text, '^\s*', '','')
    let str = matchstr(d.text, '^\['.s:sch_date)
    let str = substitute(str, '^\[', '', '')
    let searchWord = ']'.s:sch_cmd
    let cmd = matchstr(d.text, searchWord)
    let cmd = substitute(cmd, '^]', '', '')
    let opt = matchstr(cmd, '[0-9]*$')

    let str = s:CnvRepeatDate(cmd, opt, str)
    let d.text = '[' . str . strpart(d.text, 11)
    let desc  = escape(cmd[0], '~')
    let dow = ''
    if g:QFixHowm_ShowScheduleDayOfWeek
      let dow = ' '.g:DoWStrftime[QFixHowmDate2Int(str)%7]
    endif
    if cmd =~ '@' && opt > 1 && opt >= 2
      let dow = opt . dow
    endif
    let d.text = substitute(d.text, ']'.escape(cmd, '~*'),  ']'. desc . dow . '', '')
    let d.text = substitute(d.text, dow.'\s*', dow.' ', '')
    let cmd = cmd[0]
    if opt == ''
      if cmd =~ '^-'
        let opt = g:QFixHowm_ReminderDefault_Reminder
      elseif cmd =~ '^+'
        let opt = g:QFixHowm_ReminderDefault_Todo
      elseif cmd =~ '^\!'
        let opt = g:QFixHowm_ReminderDefault_Deadline
      elseif cmd =~ '^\~'
        let opt = g:QFixHowm_ReminderDefault_UD
      elseif cmd =~ '^@'
        let opt = g:QFixHowm_ReminderDefault_Schedule
        let opt = -1
      elseif cmd =~ '^\.'
        let opt = 0
      endif
    endif
    let priority = QFixHowmDate2Int(str)
    let priority = s:QFixHowmGetPriority(priority, cmd, opt, today)
    let d['priority'] = priority
    let d['typepriority'] = g:QFixHowm_ReminderPriority[cmd]
    let showSchedule = g:QFixHowm_ShowSchedule
    if a:mode == 'todo'
      let showSchedule = g:QFixHowm_ShowScheduleTodo
    elseif a:mode == 'menu'
      let showSchedule = g:QFixHowm_ShowScheduleMenu
    endif
    let showSchedule = showSchedule - 1
    if showSchedule > -1
      let ext = '[@]'
      let searchWord = s:sch_dateT.ext
      let dowpat = searchWord . '\s*'.s:sch_dow.'\? '
      if d.text =~ searchWord
        if d.priority > today+showSchedule || d.priority < 0
          call remove(qflist, idx)
          continue
        endif
      endif
    elseif cmd =~ '^@'
      call remove(qflist, idx)
      continue
    endif
    if exists('g:QFixHowmToday')
      let d.text = d.text . "\t\t(" . priority . ")"
    else
      if priority < g:QFixHowm_RemovePriority
        call remove(qflist, idx)
        continue
      endif
      if g:QFixHowm_RemovePriorityDays && priority < today - g:QFixHowm_RemovePriorityDays
        call remove(qflist, idx)
        continue
      endif
    endif
    if cmd =~ '^@' && g:QFixHowm_ReminderSortMode
      let priority = today - (priority - today)
      let qflist[idx]['priority'] = priority
    endif
    let d.text = substitute(d.text, '\s*&'.s:sch_dateT.'\.\s*', ' ', '')
    let d.text = substitute(d.text, '\s*$', '', '')
    let idx = idx + 1
  endfor

  return qflist
endfunction

function! s:QFixHowmSortReminderPre(sq)
  let qflist = a:sq
  let today = QFixHowmDate2Int(strftime(s:hts_date))
  let tsec = localtime()
  if exists('g:QFixHowmToday')
    let today = QFixHowmDate2Int(g:QFixHowmToday)
    let tsec  = QFixHowmDate2Int(g:QFixHowmToday . ' 00:00')
  endif

  let ttime = (today - g:QFixHowm_ReminderDefault_Schedule - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9
  let todaychk = strftime(s:hts_date, ttime)

  let idx = 0
  for d in qflist
    let d.text = substitute(d.text, '\s*', '','')
    let str = matchstr(d.text, '^\['.s:sch_date)
    let str = substitute(str, '^\[', '', '')
    let searchWord = ']'.s:sch_cmd
    let cmd = matchstr(d.text, searchWord)
    let cmd = substitute(cmd, '^]', '', '')
    let opt = matchstr(cmd, '[0-9]*$')

    " 単発予定で非表示を除去
    if cmd == '@' && opt == '' && str !~ s:sch_date_eom
      if str < todaychk
        call remove(qflist, idx)
        continue
      endif
    endif
    " 終了指定対象を除去
    let estr = matchstr(d.text, '&'.s:sch_dateT.'\.')
    let estr = substitute(estr, '^&', '','')
    let elen = strlen(estr)
    if elen > 14
      let esec = QFixHowmDate2Int(estr)
      if estr != '' && tsec > esec
        call remove(qflist, idx)
        continue
      endif
    else
      let eday = QFixHowmDate2Int(estr)
      if estr != '' && today > eday + g:QFixHowm_EndDateOffset
        call remove(qflist, idx)
        continue
      endif
    endif
    let idx += 1
  endfor
  return qflist
endfunction

" リマインダーに今日の日付と時刻表示を追加
function! s:AddTodayLine(qflist)
  let qflist = a:qflist
  let today = QFixHowmDate2Int(strftime(s:hts_date))
  if exists('g:QFixHowmToday')
    let today = QFixHowmDate2Int(g:QFixHowmToday)
  endif
  let l:howm_dir = '~/howm'
  let l:howm_dir = exists('g:howm_dir') ? g:howm_dir : l:howm_dir
  let l:howm_dir = exists('g:qfixmemo_dir') ? g:qfixmemo_dir : l:howm_dir
  let l:howm_dir = s:howm_dir != '' ? s:howm_dir : l:howm_dir
  if g:QFixHowm_ScheduleSearchDir != ''
    let l:howm_dir = expand(g:QFixHowm_ScheduleSearchDir)
  endif
  let l:howm_dir = QFixNormalizePath(l:howm_dir)
  let todayfname = g:QFixHowm_TodayFname
  let todaypriority = g:QFixHowm_ReminderPriority[g:QFixHowm_TodayLineType]
  let sepdat = {"priority":today, "text": strftime('['.s:hts_dateTime.']$'), "typepriority":todaypriority, "filename":todayfname, "lnum":0}
  call add(qflist, sepdat)
  let qflist = sort(qflist, "s:QFixComparePriority")

  let idx = 0
  let QFixHowmReminderTodayLineBeg = 0
  let QFixHowmReminderTodayLine = 0
  let prevtext = ''
  let prevpriority = -1
  let tline = 0
  for d in qflist
    if d.priority == prevpriority && d.text == prevtext && g:QFixHowm_RemoveSameSchedule == 1
      call remove(qflist, tline)
      continue
    endif
    let tline += 1
    let prevtext = d.text
    let prevpriority = d.priority
    if g:QFixHowm_ReminderSortMode
      if d.priority > today
        let QFixHowmReminderTodayLineBeg = QFixHowmReminderTodayLineBeg + 1
      endif
      if d.priority < today
        continue
      endif
    else
      if d.priority < today
        let QFixHowmReminderTodayLineBeg = QFixHowmReminderTodayLineBeg + 1
      endif
      if d.priority > today
        continue
      endif
    endif
    let QFixHowmReminderTodayLine += 1
  endfor

  let ttime = (today - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9
  let str = strftime('['.s:hts_date.']')
  let dow = ' '
  if g:QFixHowm_ShowScheduleDayOfWeek
    let dow = ' '.g:DoWStrftime[QFixHowmDate2Int(str)%7] . ' '
  endif
  if g:QFixHowm_ShowTodayLine >= 2
    let str = strftime('['.s:hts_date.']')
  endif
  let str = strftime('['.s:hts_dateTime.']')
  let file = l:howm_dir . '/' . g:QFixHowm_ShowTodayLineStr
  let text = str . dow . '||'.g:QFixHowm_ShowTodayLineStr
  let file = todayfname
  let text = g:QFixHowm_ShowTodayLineStr . ' ' . str . dow . g:QFixHowm_ShowTodayLineStr
  let lnum = '-1'
  let sep = {"filename": file, "lnum": lnum, "text": text}
  if g:QFixHowm_ShowTodayLine > 0
    call insert(qflist, sep, QFixHowmReminderTodayLine)
  endif
  let QFixHowmReminderTodayLine += 1
  let str = strftime('['.s:hts_date.']')
  let text = g:QFixHowm_ShowTodayLineStr
  let sep = {"filename": file, "lnum": lnum, "text": text}
  if g:QFixHowm_ShowTodayLine > 0
    call insert(qflist, sep, QFixHowmReminderTodayLineBeg)
  endif
  let text = g:QFixHowm_ShowTodayLineStr . strftime(' '.s:hts_time .' ') .g:QFixHowm_ShowTodayLineStr
  let hastime = 0
  for idx in range(len(qflist))
    if idx <= QFixHowmReminderTodayLineBeg
      continue
    endif
    if idx >= QFixHowmReminderTodayLine
      break
    endif
    let hastime += (match(qflist[idx].text, '^'.s:sch_dateTime) > -1)
  endfor
  let removebeg = 0
  for idx in range(len(qflist))
    if qflist[idx].lnum == 0
      if g:QFixHowm_ShowTodayLine >= 2 && hastime > 1 && idx+1 != QFixHowmReminderTodayLine
        let qflist[idx].text = text
        if idx-1 == QFixHowmReminderTodayLineBeg
          let removebeg = 1
        endif
      else
        call remove(qflist, idx)
        let QFixHowmReminderTodayLine -= 1
        break
      endif
    endif
  endfor
  if QFixHowmReminderTodayLineBeg+1 == QFixHowmReminderTodayLine || QFixHowmReminderTodayLineBeg == 0 || removebeg || g:QFixHowm_ShowTodayLine < 3
    if len(qflist) > QFixHowmReminderTodayLineBeg
      call remove(qflist, QFixHowmReminderTodayLineBeg)
    endif
  endif
  return qflist
endfunction

" 曜日表示変更
function! s:CnvDayOfWeek(qf)
  if !exists('g:QFixHowm_DayOfWeekDic')
    return a:qf
  endif
  let pattern = '^' . s:sch_dateT . s:sch_Ext . ' '.s:sch_dow.' '
  for idx in range(len(a:qf))
    let text = a:qf[idx].text
    let dow = matchstr(text, pattern)
    let dow = matchstr(text, s:sch_dow)
    if dow == ''
      continue
    endif
    let to_dow = g:QFixHowm_DayOfWeekDic[dow]
    let a:qf[idx].text = substitute(text, dow, to_dow, '')
  endfor
  return a:qf
endfunction

" 繰り返す予定のプライオリティをセットする。
" FIXME: Too slow!
" リピート基準日に今日の日付を使用する(テスト)
if !exists('g:QFixHowm_AltRepeatAction')
  let g:QFixHowm_AltRepeatAction = ''
endif
function! s:CnvRepeatDate(cmd, opt, str, ...)
  let cmd = a:cmd
  let opt = a:opt
  let str = a:str
  if len(cmd) == 1 && opt == '' && str !~ s:sch_date_eom
    return str
  endif
  let sft = ''
  " 月末指定のオフセットを特別扱い
  if cmd =~ '([-+]\d\+)'
    let sft = substitute(matchstr(cmd, '[-+]\d\+)'), '[^-0-9]', '', 'g')
    let cmd = substitute(cmd, '([-+]\d\+)$', '', '')
  endif
  if cmd =~ '('.s:sch_dow
    let cmd = substitute(cmd, '(\('.s:sch_dow.'\)', '(1*\1', '')
  endif

  if g:QFixHowm_AltRepeatAction != '' && cmd =~ '^'.g:QFixHowm_AltRepeatAction.'(\d\+\([-+]'.s:sch_dow.'\)\?)'
    let str = strftime(g:QFixHowm_DatePattern)
  endif

  if opt == ''
    let opt = 0
  endif
  let done = 0
  if a:0 > 0
    let done = 1
  endif
  if done == 0
    let rstr = s:CnvRepeatDateR(cmd, opt, str, done)
  else
    let rstr = s:CnvRepeatDateN(cmd, opt, str, done)
  endif
  if sft != ''
    let sec = QFixHowmDate2Int(rstr.' 00:00')
    let sec = sec + sft * 24 *60 *60
    let rstr = strftime(s:hts_date, sec)
  endif
  return rstr
endfunction

" 次の繰り返し予定日
function! s:CnvRepeatDateN(cmd, opt, str, done)
  let cmd = a:cmd
  let opt = a:opt
  if opt == ''
    let opt = 0
  endif
  let str = a:str
  let pstr = a:str
  let nstr = a:str
  let done = a:done

  let actday = QFixHowmDate2Int(str)
  let today  = QFixHowmDate2Int(strftime(s:hts_date))
  if exists('g:QFixHowmToday')
    let today = QFixHowmDate2Int(g:QFixHowmToday)
  endif
  let ttime = (today - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9

  let desc  = escape(cmd[0], '~')
  let desc0 = '^'. desc . '\{1,3}'.'\c([1-5]\*'.s:sch_dow.'\([-+]\d\+\)\?)'
  let desc1 = '^'. desc . '\c([0-9]\+\([-+]\?'.s:sch_dow.'\)\?)'
  let desc2 = '^'. desc . '\{2}'
  let desc3 = '^'. desc . '\{3}'

  "曜日指定
  if cmd =~ desc0
    let ofs = 0
    if cmd =~ '[-+]\d\+)'
      let ofs = substitute(matchstr(cmd, '[-+]\d\+)'), '[^-0-9]', '', 'g')
      let cmd = substitute(cmd, '[-+]\d\+)', ')', '')
    endif

    let ayear  = matchstr(str, '^\d\{4}')
    let amonth = strpart(substitute(str, '[^0-9]', '', 'g'), 4, 2)
    let aday   = matchstr(substitute(a:str, '[^0-9]', '', 'g'), '\d\{2}$')
    let atoday = QFixHowmDate2Int(a:str) + 1

    let stoday = QFixHowmDate2Int(strftime(s:hts_date))
    if exists('g:QFixHowmToday')
      let stoday = QFixHowmDate2Int(g:QFixHowmToday)
    endif
    if atoday > stoday
      let stoday = atoday
    endif
    if done
      let st = atoday + 1
      if st > stoday
        let stoday = st
      endif
    endif
    let sttime = (stoday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)

    let syear  = strftime('%Y', sttime)
    let smonth = strftime('%m', sttime)
    let sday   = strftime('%d', sttime)

    let dow = matchstr(cmd, s:sch_dow)
    let sft = matchstr(cmd, '[0-9]')
    if sft == ''
      let sft = 1
    endif

    let year  = syear
    let month = amonth
    if cmd =~ desc.'\{3}'
    elseif cmd =~ desc.'\{2}'
      let month = smonth
    endif

    let sday = s:CnvDoW(year, month, sft, dow, ofs)
    let sttime = (sday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)
    let year  = strftime('%Y', sttime)
    let month = strftime('%m', sttime)
    let sstr = strftime(s:hts_date, sttime)

    if sday > stoday
      let nstr = strftime(s:hts_date, sttime)
      let pstr = strftime(s:hts_date, sttime)
    else
      let pstr = strftime(s:hts_date, sttime)
      if cmd =~ desc.'\{3}'
        let year = year + 1
        let month = amonth
      elseif cmd =~ desc.'\{2}'
        let month = month + 1
      endif
      if month > 12
        let year = year + 1
        let month = 1
      endif
      let sday = s:CnvDoW(year, month, sft, dow, ofs)
      let sttime = (sday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)
      let nstr = strftime(s:hts_date, sttime)
    endif
    let pday = QFixHowmDate2Int(pstr)
    let nday = QFixHowmDate2Int(nstr)
    if done
      return nstr
    endif
    if cmd =~ '^@'
      if pday >= stoday || pday+opt > stoday
        return pstr
      else
        return nstr
      endif
    endif
    if stoday == pday
      return pstr
    else
      return nstr
    endif
  endif
  "間隔指定の繰り返し
  if cmd =~ desc1
    let step = matchstr(cmd, '\d\+')
    if step == 0
      let str = s:DayOfWeekShift(cmd, str)
      return str
    endif
    if step == 1
      if actday < today
        let tday = today
      else
        let tday = actday + step
      endif
    else
      if actday < today
        let tday = actday + step * (1 + ((today - actday - 1) / step))
      else
        let tday = actday + step
      endif
    endif
    let tday = tday - g:DateStrftime
    let ttime = tday * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9
    let str = strftime(s:hts_date, ttime)
    if done
      return str
    endif
    let str = s:DayOfWeekShift(cmd, str)
    let sday = QFixHowmDate2Int(str)
    if sday < today
      let tday = tday + step
      let ttime = tday * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9
      let str = strftime(s:hts_date, ttime)
    endif
    return str
  endif

  "年単位の繰り返し
  if cmd =~ desc3
    "曜日シフトで前日の予定が今日の予定の場合
    let sstr = s:DayOfWeekShift(cmd, str)
    let sday = QFixHowmDate2Int(sstr)
    if sday >= today
      if done
        "return str
      else
        return sstr
      endif
    endif
    if today >= actday && done == 0
      let year = strftime('%Y', ttime)
      let sstr = printf("%4.4d", year) . strpart(str, 4)
      let ssstr = s:DayOfWeekShift(cmd, sstr)
      let sday = QFixHowmDate2Int(ssstr)
      if sday < today
        let year = strftime('%Y', ttime) + 1
        let sstr = printf("%4.4d", year) . strpart(str, 4)
      endif
      let str = sstr
    else
      let year = matchstr(str, '^\d\{4}') + 1
      if year < strftime('%Y', ttime)
        let year = strftime('%Y', ttime)
      endif
      let sstr = printf("%4.4d", year) . strpart(str, 4)
      let ssstr = s:DayOfWeekShift(cmd, sstr)
      let sday = QFixHowmDate2Int(ssstr)
      if sday < today
        let year = strftime('%Y', ttime) + 1
        let sstr = printf("%4.4d", year) . strpart(str, 4)
      endif
      let str = sstr
    endif
    if done
      return str
    endif
    let sstr = s:DayOfWeekShift(cmd, str)
    let sday = QFixHowmDate2Int(sstr)
    return sstr
  endif

  "月単位の繰り返し
  if cmd =~ desc2
    let year  = strftime('%Y', ttime)
    let month = strftime('%m', ttime)
    let day   = strftime('%d', ttime)
    let ayear = matchstr(str, '^\d\{4}')
    let amonth = strpart(substitute(str, '[^0-9]', '', 'g'), 4, 2)
    let aday  = matchstr(substitute(a:str, '[^0-9]', '', 'g'), '\d\{2}$')
    let str = a:str

    if today > actday
      let ofs =0
      if month == amonth
        let ofs = 1
      endif
      let tstr = printf(s:sch_printfDate, year, month + ofs, s:Overday(year, month+ofs, aday))
      let pfsec = QFixHowmDate2Int(tstr.' 00:00')
      let tstr = strftime(s:hts_date, pfsec)
      let sstr = s:DayOfWeekShift(cmd, tstr)
      let tday = QFixHowmDate2Int(sstr)
      if tday >= today
        if done > 0
          return tstr
        else
          return sstr
        endif
      endif
      let tstr = printf(s:sch_printfDate, year, month, s:Overday(year, month, aday))
      let sec = QFixHowmDate2Int(tstr.' 00:00')
      let tstr = strftime(s:hts_date, sec)
      let sstr = s:DayOfWeekShift(cmd, tstr)
      let tday = QFixHowmDate2Int(sstr)
      if tday >= today
        if done > 0
          return tstr
        else
          let sstr = s:DayOfWeekShift(cmd, tstr)
          return sstr
        endif
      else
        let tstr = printf(s:sch_printfDate, year, month+1, s:Overday(year, month+1, aday))
        let sec = QFixHowmDate2Int(tstr.' 00:00')
        let tstr = strftime(s:hts_date, sec)
        return tstr
      endif
    else
      let tstr = printf(s:sch_printfDate, ayear, amonth+1, s:Overday(ayear, amonth+1, aday))
      let sec = QFixHowmDate2Int(tstr.' 00:00')
      let tstr = strftime(s:hts_date, sec)
      if done > 0
        return tstr
      else
        let sstr = s:DayOfWeekShift(cmd, tstr)
        return sstr
      endif
    endif
  endif

  "ここで曜日チェックしてずらす
  if done == 0
    return s:DayOfWeekShift(cmd, str)
  endif
  return str
endfunction

" 前の繰り返し予定日
function! s:CnvRepeatDateR(cmd, opt, str, done)
  let cmd = a:cmd
  let opt = a:opt
  if opt == ''
    let opt = 0
  endif
  let str = a:str
  let pstr = str
  let today = QFixHowmDate2Int(strftime(s:hts_date))
  if exists('g:QFixHowmToday')
    let today = QFixHowmDate2Int(g:QFixHowmToday)
  endif
  let done = a:done
  let actday = QFixHowmDate2Int(str)

  let desc  = escape(cmd[0], '~')
  let desc0 = '^'. desc . '\{1,3}'.'\c([1-5]\*'.s:sch_dow.'\([-+]\d\+\)\?)'
  let desc1 = '^'. desc . '\c([0-9]\+\([-+]\?'.s:sch_dow.'\)\?)'
  let desc2 = '^'. desc . '\{2}'
  let desc3 = '^'. desc . '\{3}'
  let ttime = (today - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9
  "次のアクティベートタイム
  let nstr = s:CnvRepeatDateN(cmd, opt, str, done)
  let nactday = QFixHowmDate2Int(nstr)
  if cmd =~ desc0
    "曜日指定の繰り返し
    let ofs = 0
    if cmd =~ '[-+]\d\+)'
      let ofs = substitute(matchstr(cmd, '[-+]\d\+)'), '[^-0-9]', '', 'g')
      let cmd = substitute(cmd, '[-+]\d\+)', ')', '')
    endif
    let stoday = QFixHowmDate2Int(nstr)
    let sttime = (stoday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)
    let syear  = strftime('%Y', sttime)
    let smonth = strftime('%m', sttime)
    let sday   = strftime('%d', sttime)
    if cmd =~ desc.'\{3}'
      let syear = syear - 1
    elseif cmd =~ desc.'\{2}'
      let smonth = smonth - 1
      if smonth < 1
        let syear = syear - 1
        let smonth = 12
      endif
    endif
    let sttime = (stoday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)

    let dow = matchstr(cmd, s:sch_dow)
    let sft = matchstr(cmd, '[0-9]')
    if sft == ''
      let sft = 1
    endif

    let sday = s:CnvDoW(syear, smonth, sft, dow, ofs)
    let sttime = (sday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)
    let pstr = strftime(s:hts_date, sttime)
  elseif cmd =~ desc1
    "間隔指定の繰り返し
    let step  = matchstr(cmd, '\d\+')
    "曜日シフトされていない間隔指定日を求める
    let ncmd = substitute(cmd, '\c[-+]'.s:sch_dow,'','')
    let nnstr = s:CnvRepeatDateN(ncmd, opt, str, done)
    let nnactday = QFixHowmDate2Int(nstr)

    let pday = nnactday - step
    let tday = pday - g:DateStrftime
    let ttime = tday * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9
    let pstr = strftime(s:hts_date, ttime)
  elseif cmd =~ desc3
    "年単位の繰り返し
    let year = matchstr(nstr, '^\d\{4}') - 1
    let pstr = printf("%4.4d", year) . strpart(str, 4)
  elseif cmd =~ desc2
    "月単位の繰り返し
    let year = matchstr(nstr, '^\d\{4}')
    let month = strpart(substitute(nstr, '[^0-9]', '', 'g'), 4, 2) - 1
    if month < 1
      let month = 12
      let year = year - 1
    endif
    let day  = matchstr(a:str, '\d\{2}$')
    let day = s:Overday(year, month, day)
    let pstr = printf(s:sch_printfDate, year, month, day)
    let pfsec = QFixHowmDate2Int(pstr.' 00:00')
    let pstr = strftime(s:hts_date, pfsec)
  endif
  "ここで曜日チェックしてずらす
  let pstr = s:DayOfWeekShift(cmd, pstr)
  let pactday = QFixHowmDate2Int(pstr)
  if cmd =~ '^@'
    if pactday >= today || pactday+opt > today
      return pstr
    else
      return nstr
    endif
  endif
  if cmd =~ '^-'
    if nactday == today
      return nstr
    endif
    if pactday >= actday
      return pstr
    endif
  endif
  if cmd =~ desc0
    let stoday = QFixHowmDate2Int(a:str)
    let sttime = (stoday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)
    let syear  = strftime('%Y', sttime)
    let smonth = strftime('%m', sttime)
    let sday   = strftime('%d', sttime)

    let dow = matchstr(cmd, s:sch_dow)
    let sft = matchstr(cmd, '[0-9]')
    if sft == ''
      let sft = 1
    endif

    let sday = s:CnvDoW(syear, smonth, sft, dow, ofs)
    let sttime = (sday - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)
    let pstr = strftime(s:hts_date, sttime)
    return pstr
  endif
  let str = s:DayOfWeekShift(cmd, str)
  return str
endfunction

"指定月のsft回目のdow曜日+ofs日を返す
function! s:CnvDoW(year, month, sft, dow, ofs)
  let year = a:year
  let month = a:month
  let sft = a:sft
  if sft == 0 || sft == ''
    let sft = 1
  endif
  let dow = a:dow
  let ofs = a:ofs
  " if exists('*datelib#StrftimeCnvDoWShift') || exists('g:loaded_QFixMemoCalendar_vim')
    let cnvdow = sft.'*'.dow
    let time = datelib#StrftimeCnvDoWShift(year, month, 1, cnvdow, ofs)
    return (time/(24*60*60) + g:DateStrftime)
"   endif
"   let sstr = printf(s:sch_printfDate, year, month, 1)
"   let pfsec = QFixHowmDate2Int(sstr.' 00:00')
"   let sstr = strftime(s:hts_date, pfsec)
"   let fday = QFixHowmDate2Int(sstr)
"   let fdow = fday%7
"   let day = fday - fday%7
"   let tday = day + (sft-1) * 7 + index(g:DoWStrftime, dow)
"
"   let day = tday - g:DateStrftime - (sft-1) * 7
"   let ttime = day * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60) "JST = -9
"   let month = strftime('%m', ttime)
"   if month != a:month
"     let tday = tday + 7
"   endif
"   let tday += ofs
"   return tday
endfunction

"曜日シフト
function! s:DayOfWeekShift(cmd, str)
  let cmd = a:cmd
  let str = a:str

  " if exists('*datelib#StrftimeCnvDoWShift') || exists('g:loaded_QFixMemoCalendar_vim')
    let str = substitute(str, '[^0-9]', '', 'g')
    let year  = strpart(str, 0, 4)
    let month = strpart(str, 4, 2)
    let day   = strpart(str, 6, 2)
    let cnvdow = ''
    let sft = matchstr(cmd, '[-+]'.s:sch_dow)
    call datelib#MakeHolidayTable(year)
    let time = datelib#StrftimeCnvDoWShift(year, month, day, cnvdow, sft)
    return strftime(s:hts_date, time)
"   endif
"
"   let actday = QFixHowmDate2Int(str)
"
"   let dow = matchstr(cmd, '[-+*]\?'.s:sch_dow)
"   let sft = matchstr(dow, '[-+*]')
"   if sft == '' || sft == '*'
"     return str
"   endif
"   let dow = substitute(dow, '[-+]', '', 'g')
"
"   "休日シフト
"   if dow =~ '\c\(Hol\|Hdy\)' && exists('s:HolidayList') && s:HolidayList != []
"     while 1
"       if count(s:HolidayList, actday) == 0  && '\c'.g:DoWStrftime[actday%7] !~ 'Sun'
"         break
"       endif
"       let sec = QFixHowmDate2Int(str.' 00:00')
"       let sec = sec + (sft == '-' ? -1: 1) * 24 *60 *60
"       let str = strftime(s:hts_date, sec)
"       let actday = QFixHowmDate2Int(str)
"     endwhile
"     return str
"   endif
"
"   if '\c'.g:DoWStrftime[actday%7] =~ dow && dow != ''
"     let sec = QFixHowmDate2Int(str.' 00:00')
"     let sec = sec + (sft == '-' ? -1: 1) * 24 *60 *60
"     let str = strftime(s:hts_date, sec)
"   endif
"   return str
endfunction

"日付からプライオリティをセットする。
"todayを基準値とし、コマンドとオプションによってプライオリティ値が計算される。
function! s:QFixHowmGetPriority(priority, cmd, opt, today)
  let priority = a:priority
  let cmd = a:cmd
  let opt = a:opt
  let today = a:today
  let days = 1

  if cmd =~ '^-'
    "* 指定日に浮きあがり, 以後は徐々に沈む
    "* 指定日までは底に潜伏
    "  沈むのを遅くするには, 猶予日数で指定(デフォルト 1 日)
    "  継続期間は 1+猶予日数
    if today >= priority
      if (today > priority + (opt-1+g:QFixHowm_ReminderOffset) * days)
        let priority = priority + (opt-1+g:QFixHowm_ReminderOffset) * days
      else
        let priority = today
      endif
    else
      let priority = 0
    endif
  elseif cmd =~ '^+'
    "* 指定日から, 徐々に浮きあがってくる
    "* 指定日までは底に潜伏
    "  浮きあがる速さは, 猶予日数で指定(デフォルト 7 日)
    if priority  <= today
      let priority = today - opt * days + today - priority
      if priority > today
        let priority = today
      endif
    else
      let priority = 0
    endif
  elseif cmd =~ '^\!'
    "# 指定日が近づくと, 浮きあがってくる
    "# 指定日以降は, 一番上に浮きっぱなし
    "  何日前から浮きはじめるかは, 猶予日数で指定(デフォルト 7 日)
    if today + opt * days >= priority
      let priority = today - (priority - today)
    else
      let priority = 0
    endif
  elseif cmd =~ '^\~'
    "# 指定日から, 浮き沈みをくりかえす
    "# 指定日までは底に潜伏
    let cycle = opt / 2
    if priority <= today
      let term = priority - today
      let len = term % cycle
      if (term / opt) % 2
        let priority = today - len
      else
        let priority = today - cycle + len
      endif
    else
      let priority = 0
    endif
  elseif cmd =~ '^@'
    "todo一覧ではなく, 予定表に表示
    let postshow = g:QFixHowm_ReminderDefault_Schedule
    if opt == 0
      let postshow = opt
    endif
    if opt <= 1
      let opt = 0
    endif
    if today > priority + opt + postshow
      let priority = -1
    endif
    if opt > 1
      if today > priority && today < priority + opt
        let priority = today
      endif
    endif
  elseif cmd =~ '^\.'
    "実行済で常に底
    let priority = -1
  endif
  return priority
endfunction

"priorityソート関数
function! s:QFixComparePriority(v1, v2)
  if a:v1.priority != a:v2.priority
    return (a:v1.priority <= a:v2.priority?1:-1)
  endif
  if a:v1.typepriority != a:v2.typepriority
    return (a:v1.typepriority >= a:v2.typepriority?1:-1)
  endif
  if a:v1.text != a:v2.text
    if g:QFixHowm_ReminderSortMode == 0
      return (a:v1.text < a:v2.text?1:-1)
    else
      let v1text = substitute(a:v1.text, '^\(\['.s:sch_date.'\) ', '\1}', '')
      let v2text = substitute(a:v2.text, '^\(\['.s:sch_date.'\) ', '\1}', '')
      return (v1text >= v2text?1:-1)
      return (a:v1.text >= a:v2.text?1:-1)
    endif
  endif
  return 1
endfunction

"繰り返し予定展開
function! QFixHowmGenerateRepeatDate()
  let save_cursor = getpos('.')
  let loop = count
  if loop == 0
    let loop = 1
  endif
  let ptext = matchstr(getline('.'), '^\s*')
  let searchWord = '^\s*'.s:sch_dateCmd
  let text = matchstr(getline('.'), searchWord)
  if text == ""
    return
  endif
  let tstr = matchstr(text, '^\s*\['.s:sch_date)
  let tstr = substitute(tstr, '^\s*\[', '', '')
  let searchWord = ']'.s:sch_cmd
  let cmd = matchstr(getline('.'), searchWord)
  let cmd = substitute(cmd, '^]', '', '')

  "単発予定は一日繰り返しにする
  let pattern = '^\('.s:sch_Ext.'\)\(\d\|$\)'
  if cmd =~ pattern
    let cmd = substitute(cmd, pattern, '\1(1)\2', '')
  endif
  let pattern = '^\('.s:sch_Ext.'(\)\([-+]'.s:sch_dow.')\)'
  if cmd =~ pattern
    let cmd = substitute(cmd, pattern, '\11\2', '')
  endif

  let rep = ''
  if cmd =~ '['.s:sch_ext.']\{2}'
    let rep = substitute(tstr, '^\(\d\{4}.\d\{2}.\)\(\d\{2}\).*', '\2', '')
  endif
  let opt = matchstr(cmd, '[0-9]*$')
  if rep
    let tstr = substitute(tstr, '^\(\d\{4}.\d\{2}.\)\d\{2}', '\1'.rep, '')
  endif
  let cpattern = s:CnvRepeatDate(cmd, opt, tstr, -1)
  let str = getline('.')
  let pstr = ''
  for n in range(loop)
    if rep == '00'
      let tstr = substitute(tstr, '^\(\d\{4}.\d\{2}.\)\d\{2}', '\1'.rep, '')
    endif
    let cpattern = s:CnvRepeatDate(cmd, opt, tstr, -1)
    let str = substitute(str, '^\s*\['.s:sch_date, '['.cpattern, '')
    let tstr = matchstr(str, '^\s*\['.s:sch_date)
    let tstr = substitute(tstr, '^\s*\[', '', '')
    let ostr = str
    "単発予定に変換
    let dstr = matchstr(ostr, s:sch_date)
    let dstr = s:DayOfWeekShift(cmd, dstr)
    let ostr = substitute(ostr, s:sch_date, dstr, '')
    let ostr = substitute(ostr, '\(]\)\('.s:sch_Ext.'\)\{1,3}', '\1\2', '')
    let ostr = substitute(ostr, '\(]'.s:sch_Ext.'\)'.'([0-9]*[-+*]\?'.s:sch_dow.'\?\([-+]\d\+\)\?)', '\1', '')
    let pstr = pstr . "\<NL>" . ptext .ostr
  endfor
  let pstr = substitute(pstr, "^\<NL>", '', '')
  put=pstr
  call setpos('.', save_cursor)
  return
endfunction

"タイトルと予定・TODOで指定文字列を含むものを非表示にする
let s:UseTitleFilter = 0
function! QFixHowmTitleFilter(sq)
  if s:UseTitleFilter == 0 || g:QFixHowm_TitleFilterReg == ''
    return
  endif
  let s:UseTitleFilter = 0
  call filter(a:sq, "v:val['text'] !~ g:QFixHowm_TitleFilterReg")
endfunction

"=============================================================================
"Quickfix(schedule mode)
"=============================================================================
"Quickfixウィンドウ上での曜日変換表示
if exists('g:QFixHowm_JpDayOfWeek') && g:QFixHowm_JpDayOfWeek
  let g:QFixHowm_DayOfWeekDic = {'Sun' : "日", 'Mon' : "月", 'Tue' : "火", 'Wed' : "水", 'Thu' : "木", 'Fri' : "金", 'Sat' : "土"}
  let g:QFixHowm_DayOfWeekReg = '\c\(Sun\|Mon\|Tue\|Wed\|Thu\|Fri\|Sat\|日\|月\|火\|水\|木\|金\|土\)'
endif
"Quickfixウィンドウ上でハイライトする曜日
if !exists('g:QFixHowm_DayOfWeekReg')
  let g:QFixHowm_DayOfWeekReg = '\c\(Sun\|Mon\|Tue\|Wed\|Thu\|Fri\|Sat\)'
endif

augroup QFixHowm
  "後で再定義される
  au!
  au BufWinEnter quickfix call <SID>QFixHowmBufWinEnter()
augroup END

" デフォルトシンタックスファイル
if !exists('g:howm_schedule_syntax_file')
  let g:howm_schedule_syntax_file = 'howm_schedule.vim'
  if exists('g:qfixmemo_syntax_file')
    let g:howm_schedule_syntax_file = g:qfixmemo_syntax_file
  endif
endif

function! s:QFixHowmBufWinEnter()
  exe 'runtime! syntax/'.g:howm_schedule_syntax_file
  setlocal ft=qf
  call QFixHowmQFsyntax()
endfunction

"Quickfixウィンドウのシンタックス表示
function! QFixHowmQFsyntax()
  let pattern = s:sch_dateT
  let dowpat = '\s*'. g:QFixHowm_DayOfWeekReg . '\?'
  exe 'syntax match howmSchedule "'.pattern.'@\d*' .dowpat.' "'
  exe 'syntax match howmDeadline "'.pattern.'!\d*' .dowpat.' "'
  exe 'syntax match howmTodo     "'.pattern.'+\d*' .dowpat.' "'
  exe 'syntax match howmReminder "'.pattern.'-\d*' .dowpat.' "'
  exe 'syntax match howmTodoUD   "'.pattern.'\~\d*'.dowpat.' "'
  exe 'syntax match howmFinished "'.pattern.'\."'
  let pattern = ' \?'. g:QFixHowm_ReminderHolidayName
  exe 'syntax match howmHoliday "'.pattern .'"'
  if exists('g:QFixHowm_UserHolidayName')
    let pattern = ' \?'.g:QFixHowm_UserHolidayName
    exe 'syntax match howmHoliday "'.pattern .'"'
  endif
  if exists('g:QFixHowm_UserSpecialdayName')
    let pattern = ' \?'.g:QFixHowm_UserSpecialdayName
    exe 'syntax match howmSpecial "'.pattern .'"'
  endif
endfunction

"=============================================================================
"howm以外のバッファを使用するためのヘルパー関数
"=============================================================================
"howmバッファを使用する
if !exists('g:QFixHowm_HowmMode')
  let g:QFixHowm_HowmMode = 1
endif
if !exists('g:QFixHowm_UserFileExt')
  let g:QFixHowm_UserFileExt = 'mkd'
endif
if !exists('g:QFixHowm_UserFileType')
  let g:QFixHowm_UserFileType = 'markdown'
endif
" HowmMode = 0 の時 URIを QFixHowmで開く
if !exists('g:QFixHowm_UserURIopen')
  let g:QFixHowm_UserURIopen = 1
endif
" HowmMode = 0 の時 URIを QFixHowmで開く(VimWiki)
if !exists('g:QFixHowm_UserURIopen_wiki')
  let g:QFixHowm_UserURIopen_wiki = 0
endif
" ユーザアクションロックの最大数
if !exists('g:QFixHowm_UserSwActionLockMax')
  let g:QFixHowm_UserSwActionLockMax = 8
endif

" function! QFixHowmBufferBufEnter()
"   if !IsQFixHowmFile('%')
"     return
"   endif
"   nnoremap <silent> <buffer> <CR> :<C-u>call QFixHowmActionLock()<CR>
"   let ext = fnamemodify(expand('%'), ':e')
"   if !g:QFixHowm_HowmMode && (ext == g:QFixHowm_UserFileExt)
"     call QFixHowmUserAutocmd(ext)
"   endif
" endfunction

" silent! function QFixHowmUserAutocmd(ext)
"   if a:ext == 'wiki'
"     nnoremap <silent> <buffer> <CR> :call QFixHowmUserModeCR('VimwikiFollowLink')<CR>
"   else
"     nnoremap <silent> <buffer> <CR> :call QFixHowmUserModeCR()<CR>
"   endif
" endfunction

silent! function QFixHowmUserModeCR(...)
  if QFixHowmScheduleAction()
    return
  endif
  let cmd = a:0 ? a:1 : "normal! \<CR>"
  exe cmd
endfunction

function! QFixHowmScheduleAction()
  if QFixHowmUserScheduleAction()
    return 1
  endif
  let str = QFixHowmScheduleActionStr()
  if str == "\<ESC>"
    return 1
  endif
  if str == "\<CR>"
    return 0
  endif
  let str = substitute(str, "\<CR>", "|", "g")
  let str = substitute(str, "|$", "", "")
  silent! exe str
  return 1
endfunction

if !exists('*QFixHowmUserScheduleAction')
" アクションロックのユーザー拡張用
" 非0を返すとアクションロック終了
function QFixHowmUserScheduleAction()
  return 0
endfunction
endif

function! QFixHowmScheduleActionStr()
  let save_cursor = getpos('.')
  call setpos('.', save_cursor)
  let s:QFixHowmMA = 0
  let ret = QFixHowmMacroAction()
  if ret != "\<CR>"
    return printf(':call feedkeys("%s", "t")', ret)
  endif
  " let save_cursor = getpos('.')
  " let uriopen = g:QFixHowm_UserURIopen
  " if exists('g:QFixHowm_UserURIopen_'.g:QFixHowm_UserFileExt)
  "   exe 'let uriopen = g:QFixHowm_UserURIopen_'.g:QFixHowm_UserFileExt
  " endif
  " if uriopen == 1
  "   call setpos('.', save_cursor)
  "   let ret = QFixHowmOpenCursorline()
  "   if ret == 1
  "     return "\<ESC>"
  "   endif
  " endif
  call setpos('.', save_cursor)
  let ret = QFixHowmDateActionLock()
  if ret != "\<CR>"
    return ret
  endif
  call setpos('.', save_cursor)
  let ret = QFixHowmTimeActionLock()
  if ret != "\<CR>"
    return ret
  endif
  call setpos('.', save_cursor)
  let swaction = 'g:QFixHowm_UserSwActionLock'
  if exists(swaction)
    exe 'let ret = QFixHowmSwitchActionLock('.swaction.')'
    if ret != "\<CR>"
      return ret
    endif
  endif
  call setpos('.', save_cursor)
  let range = g:QFixHowm_UserSwActionLockMax
  if exists(swaction.'Max')
    exe 'let range = '.swaction.'Max'
  endif
  for i in range(1, range)
    if !exists(swaction.i)
      continue
    endif
    call setpos('.', save_cursor)
    exe 'let action = '.swaction.i
    if action != []
      let ret = QFixHowmSwitchActionLock(action)
      if ret != "\<CR>"
        return ret
      endif
    endif
  endfor
  call setpos('.', save_cursor)
  if col('.') < 36 && getline('.') =~ '^'.s:sch_dateT.s:sch_Ext
    let ret = QFixHowmSwitchActionLock(g:QFixHowm_ScheduleSwActionLock, 1)
    if ret != "\<CR>"
      return ret
    endif
  endif
  if exists('g:QFixHowm_SwitchListActionLock')
    call setpos('.', save_cursor)
    let swaction = 'g:QFixHowm_SwitchListActionLock'
    exe 'let ret = QFixHowmSwitchActionLock('.swaction.')'
    if ret != "\<CR>"
      return ret
    endif
  endif
  call setpos('.', save_cursor)
  let ret = QFixHowmSwitchActionLock(['{_}'])
  if ret != "\<CR>"
    return ret
  endif
  call setpos('.', save_cursor)
  if getline('.') =~ '^'.s:sch_dateT.s:sch_Ext
    call cursor('.', 1)
    let ret = QFixHowmRepeatDateActionLock()
    if ret != "\<CR>"
      return ret
    endif
  endif
  " call setpos('.', save_cursor)
  " let ret = QFixHowmOpenKeywordLink()
  " if ret != "\<CR>"
  "   return ret
  " endif
  call setpos('.', save_cursor)
  return "\<CR>"
endfunction

silent! function QFixHowmOpenCursorline()
  return openuri#open()
endfunction

" if !exists('*QFixHowmOpenKeywordLink')
" function QFixHowmOpenKeywordLink()
"   return "\<CR>"
" endfunction
" endif

" " howm_schedule.vim用
" function! QFixHowmOpenKeywordLink()
"   if qfixmemo#OpenKeywordLink()
"     return "\<ESC>"
"   endif
"   return "\<CR>"
" endfunction

" " come-from/goto link
" if !exists('howm_glink_pattern')
"   let howm_glink_pattern = '>>>'
" endif
" if !exists('howm_clink_pattern')
"   let howm_clink_pattern = '<<<'
" endif
" "howmリンクパターン
" if !exists('g:QFixHowm_Link')
"   let g:QFixHowm_Link = '\('.g:howm_clink_pattern.'\|'.g:howm_glink_pattern.'\)'
" endif

"=============================================================================
" アクションロック
"=============================================================================
"日付のデフォルトアクションロック
if !exists('g:QFixHowm_DateActionLockDefault')
  let g:QFixHowm_DateActionLockDefault = 1
endif
"ユーザーマクロアクションロックの識別子
if !exists('g:QFixHowm_MacroActionPattern')
  let g:QFixHowm_MacroActionPattern = '<|>'
endif
"ユーザーマクロアクションのキーマップ
if !exists('g:QFixHowm_MacroActionKey')
  let g:QFixHowm_MacroActionKey = 'M'
endif
let s:QFixHowmALSPat = ''

"アクションロック用ハイライト
let g:QFixHowm_keyword = ''
function! QFixHowmHighlight()
  if !IsQFixHowmFile('%')
    return
  endif
  if &syntax == ''
    return
  endif
  silent! syntax clear actionlockKeyword
  if g:QFixHowm_keyword != ''
    exe 'syntax match actionlockKeyword display "\V'.g:QFixHowm_keyword.'"'
  endif
endfunction

"アクションロック実行
"TODO:strを取得しない形に修正する
" function! QFixHowmActionLock()
"   let RegisterBackup = [@0, @1, @2, @3, @4, @5, @6, @7, @8, @9, @/, @", @"]
"   if has('gui_running')
"     silent! let RegisterBackup[12] = @*
"   endif
"   let s:QFixHowmMA = 0
"   let str = QFixHowmActionLockStr()
"   if s:QFixHowmMA
"     exe 'normal '. str
"   elseif str == "\<CR>"
"     silent! exe "normal! \<CR>"
"   elseif str == "\<ESC>"
"   else
"     let str = substitute(str, "\<CR>", "|", "g")
"     let str = substitute(str, "|$", "", "")
"     silent! exe str
"   endif
"   for n in range(10)
"     silent! exe 'let @'.n.'=RegisterBackup['.n.']'
"   endfor
"   let @/ = RegisterBackup[10]
"   let @" = RegisterBackup[11]
"   if has('gui_running')
"     silent! let @* = RegisterBackup[12]
"   endif
"   return
" endfunction

" function! QFixHowmActionLockStr()
"    let save_cursor = getpos('.')
"    call setpos('.', save_cursor)
"    let ret = QFixHowmMacroAction()
"    if ret != "\<CR>"
"      let s:QFixHowmMA = 1
"      return ret
"    endif
"    if ret != "\<CR>"
"      let s:QFixHowmMA = 1
"      return ret
"    endif
"    call setpos('.', save_cursor)
"    let ret = QFixHowmOpenCursorline()
"    if ret == 1
"      return "\<ESC>"
"    endif
"    call setpos('.', save_cursor)
"    let text = getline('.')
"    let stridx = match(text, g:QFixHowm_Link)
"    if stridx > -1 && col('.') > stridx
"      let pattern = matchstr(text, g:QFixHowm_Link.'\s*.*$')
"      let pattern = substitute(pattern, '^'.g:QFixHowm_Link.'\s*', '', '')
"      let s:QFixHowmALSPat = pattern
"      call QFixHowmActionLockSearch(0)
"      return "\<ESC>"
"    endif
"    call setpos('.', save_cursor)
"    let ret = QFixHowmDateActionLock()
"    if ret != "\<CR>"
"      return ret
"    endif
"    call setpos('.', save_cursor)
"    let ret = QFixHowmTimeActionLock()
"    if ret != "\<CR>"
"      return ret
"    endif
"    call setpos('.', save_cursor)
"    if col('.') < 36 && getline('.') =~ '^'.s:sch_dateT.s:sch_Ext
"      let ret = QFixHowmSwitchActionLock(g:QFixHowm_ScheduleSwActionLock, 1)
"      if ret != "\<CR>"
"        return ret
"      endif
"    endif
"    call setpos('.', save_cursor)
"    let ret = QFixHowmRepeatDateActionLock()
"    if ret != "\<CR>"
"      return ret
"    endif
"    call setpos('.', save_cursor)
"    let ret = QFixHowmKeywordLinkSearch()
"    if ret != "\<CR>"
"      return ret
"    endif
"    call setpos('.', save_cursor)
"    let ret = QFixHowmSwitchActionLock(g:QFixHowm_SwitchListActionLock)
"    if ret != "\<CR>"
"      return ret
"    endif
"    call setpos('.', save_cursor)
"    let ret = QFixHowmSwitchActionLock(['{_}'])
"    if ret != "\<CR>"
"      return ret
"    endif
"    call setpos('.', save_cursor)
"    if exists('g:QFixHowm_UserSwActionLock')
"      let ret = QFixHowmSwitchActionLock(g:QFixHowm_UserSwActionLock)
"      if ret != "\<CR>"
"        return ret
"      endif
"    endif
"    call setpos('.', save_cursor)
"
"    for i in range(1, g:QFixHowm_UserSwActionLockMax)
"      if !exists('g:QFixHowm_UserSwActionLock'.i)
"        continue
"      endif
"      call setpos('.', save_cursor)
"      exe 'let action = '.'g:QFixHowm_UserSwActionLock'.i
"      if action != []
"        let ret = QFixHowmSwitchActionLock(action)
"        if ret != "\<CR>"
"          return ret
"        endif
"      endif
"    endfor
"    call setpos('.', save_cursor)
"    if getline('.') =~ '^'.s:sch_dateT.s:sch_Ext
"      call cursor('.', 1)
"      let ret = QFixHowmRepeatDateActionLock()
"      if ret != "\<CR>"
"        return ret
"      endif
"    endif
"    call setpos('.', save_cursor)
"    return "\<CR>"
" endfunction

" let g:QFixHowm_KeywordList = []

"キーワードリンク検索
" function! QFixHowmKeywordLinkSearch()
"   let save_cursor = getpos('.')
"   let l:QFixHowm_keyword = g:QFixHowm_keyword
"   let col = col('.')
"   let lstr = getline('.')
"
"   for word in g:QFixHowm_KeywordList
"     let len = strlen(word)
"     let pos = stridx(lstr, word)
"     if pos == -1 || col < pos+1
"       continue
"     endif
"     let str = strpart(lstr, col-len, 2*len)
"     if stridx(str, word) > -1
"       let s:QFixHowmALSPat = word
"
"       let l:QFixHowm_Wiki = 0
"       if exists('g:QFixHowm_Wiki')
"         let l:QFixHowm_Wiki = g:QFixHowm_Wiki
"       elseif exists('g:qfixmemo_keyword_mode')
"         let l:QFixHowm_Wiki = g:qfixmemo_keyword_mode
"       endif
"       if l:QFixHowm_Wiki > 0
"         let link = word
"         if l:QFixHowm_Wiki == 1
"           let file = g:howm_dir
"           if exists('g:QFixHowm_WikiDir')
"             let file = g:howm_dir . '/'.g:QFixHowm_WikiDir
"           endif
"           let file = file .'/'.link.'.'.g:QFixHowm_FileExt
"           call QFixEditFile(file)
"         elseif l:QFixHowm_Wiki == 2
"           let cmd = ':e '
"           let subdir = vimwiki#current_subdir()
"           call vimwiki#open_link(cmd, subdir.link)
"         endif
"         return "\<ESC>"
"       endif
"       call QFixHowmActionLockSearch(0)
"       return "\<ESC>"
"     endif
"   endfor
"   return "\<CR>"
" endfunction

"アクションロック用サーチ
" function! QFixHowmActionLockSearch(regmode, ...)
"   let g:MyGrep_Regexp = a:regmode
"   let pattern = s:QFixHowmALSPat
"   if a:0 > 0
"     let pattern = input(a:1, pattern)
"   endif
"   if pattern == ''
"     return "\<CR>"
"   endif
"   call histadd('@', pattern)
"   call QFixHowmListAll(pattern, 0)
" endfunction

"ユーザーマクロのアクションロック
let s:QFixHowm_MacroActionCmd = ''
function! QFixHowmMacroAction()
  if g:QFixHowm_MacroActionKey == '' || g:QFixHowm_MacroActionPattern == ''
    return "\<CR>"
  endif
  if expand('%:t') !~ g:QFixHowm_Menufile
    " return "\<CR>"
  endif
  let text = getline('.')
  if text !~ g:QFixHowm_MacroActionPattern
    return "\<CR>"
  endif
  let text = substitute(text, '.*'.g:QFixHowm_MacroActionPattern, "", "")
  let s:QFixHowm_MacroActionCmd = text
  exe "nmap <silent> <buffer>" . s:QFixHowm_Key . g:QFixHowm_MacroActionKey . " " . ":<C-u>:QFixCclose<CR>" .substitute(s:QFixHowm_MacroActionCmd, '^\s*', '', '')
  return s:QFixHowm_Key . g:QFixHowm_MacroActionKey
endfunction

""""""""""""""""""""""""""""""
" スイッチアクションロック
function! QFixHowmSwitchActionLock(list, ...)
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
      let cpattern = strftime('['.s:hts_dateTime.'].')
    endif
    let prevcol = (a:0 == 0 ? start : col('.'))
    let nr = strlen(substitute(pattern, '.', '.', 'g'))
    return ":call cursor(".prevline.",".start.")\<CR>:exe 'normal! c".nr."l".cpattern."'\<CR>:call cursor(".prevline.",".prevcol.")\<CR>"
  endfor
  return "\<CR>"
endfunction

"曜日のアクションロック
if !exists('g:QFixHowm_ScheduleSwActionLock')
  let g:QFixHowm_ScheduleSwActionLock= ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Hol']
endif

" 時間のアクションロック
function! QFixHowmTimeActionLock()
  if col('.') > matchend(getline('.'), '^\s*'.s:sch_dateTime) || getline('.') !~ '^\s*'.s:sch_dateTime
    return "\<CR>"
  endif
  let prevline = line('.')
  let prevcol = col('.')

  let pattern = ' '.s:sch_time.']'
  let len = 7 "sizeof pattern
  let start = col('.') - len
  if start < 0
    let start = 0
  endif
  let end = col('.') + len
  let str = strpart(getline('.'), start, end-start)
  if str !~ pattern
    return "\<CR>"
  endif
  let start = start + match(str, pattern) + 1
  if col('.') < start
    return "\<CR>"
  endif

  let pattern = s:sch_time
  let len = 5 "sizeof pattern
  let start = col('.') - len
  if start < 0
    let start = 0
  endif
  let end = col('.') + len
  let str = strpart(getline('.'), start, end-start)
  if str !~ pattern
    return "\<CR>"
  endif
  let start = start + match(str, pattern) + 1
  if col('.') < start
    return "\<CR>"
  endif

  let dpattern = matchstr(str, pattern)
  let pattern = input(' 01-059, 60-999, 01000-02359, 2400- ([+-]min), hhmm/0-59 (set), . (current) : ', '')
  if pattern == ''
    return "\<ESC>"
  elseif pattern == '.'
    let cpattern = strftime(s:hts_time)
  elseif pattern =~ '^\d\{2}:\d\{2}'
    let sec = QFixHowmDate2Int(strftime(s:hts_date).' '.pattern)
    let cpattern = strftime(s:hts_time, sec)
  elseif pattern =~ '[-+]\?\d\+'
    let num = substitute(pattern, '^[0+]*', '', '')
    if pattern =~ '^\d\{4}$' && num < 2400
      let sec = QFixHowmDate2Int(strftime(s:hts_date).' '.pattern)
      let sec = sec
      let cpattern = strftime(s:hts_time, sec)
    elseif pattern =~ '^\d$' || (pattern =~ '^\d\{2}$' && num < 60 && num == pattern)
      let cpattern = substitute(dpattern, '\d\d$', '', '') . printf('%2.2d', num)
    else
      let sec = QFixHowmDate2Int(strftime(s:hts_date).' '.dpattern)
      let sec = sec + num*60
      let cpattern = strftime(s:hts_time, sec)
    endif
  else
    return ":call cursor(".prevline.",".prevcol.")\<CR>"
  endif
  return ":call cursor(line('.'),".start.")\<CR>:exe 'normal! c".len."l".cpattern."'\<CR>:call cursor(".prevline.",".prevcol.")\<CR>"
endfunction

" 日付のアクションロック
function! QFixHowmDateActionLock()
  if col('.') > matchend(getline('.'), '^\s*'.s:sch_dateT) || getline('.') !~ '^\s*'.s:sch_dateT
    return "\<CR>"
  endif
  let prevline = line('.')
  let prevcol = col('.')
  let pattern = s:sch_date
  let len = strlen(strftime(s:hts_date))
  let start = col('.') - len
  if start < 0
    let start = 0
  endif
  let end = col('.') + len
  let str = strpart(getline('.'), start, end-start)
  if str !~ pattern
    return "\<CR>"
  endif
  let start = start + match(str, pattern) + 1
  if col('.') < start
    return "\<CR>"
  endif
  let dpattern = matchstr(str, pattern)
  let pattern = input(' 01-031,32-999 ([+-]day), yymmdd/mmdd/1-31 (set), . (today) : ', '')
  if pattern == ''
    return "\<ESC>"
    " let pattern = dpattern
    " if g:QFixHowm_DateActionLockDefault == 0
    "   return "\<ESC>"
    " endif
    " if g:QFixHowm_DateActionLockDefault == 1
    "   "TODO:vimgrepだったら/をエスケープ
    "   let patten = escape(pattern, '/')
    "   let s:QFixHowmALSPat = pattern
    "   call QFixHowmActionLockSearch(1, 'QFixHowm Grep : ')
    "   return "\<ESC>"
    " endif
    " if g:QFixHowm_DateActionLockDefault == 2
    "   call QFixHowmListReminder('schedule')
    "   return "\<ESC>"
    " endif
    " if g:QFixHowm_DateActionLockDefault == 3
    "   call QFixHowmListReminder('todo')
    "   return "\<ESC>"
    " endif
    " return "\<CR>"
  elseif pattern == '.'
    let cpattern = strftime(s:hts_date)
  elseif pattern =~ '^[-+]\d\+$'
    let pattern = substitute(pattern, '^[+0]*', '', '')
    let sec = pattern * 24*60*60
    let sec = sec + QFixHowmDate2Int(dpattern.' 00:00')
    let cpattern = strftime(s:hts_date, sec)
  elseif pattern =~ '^\d\{8}$' || pattern =~ '^'.s:sch_date.'$'
    let pattern = substitute(pattern, '[^0-9]', '', 'g')
    let sec = QFixHowmDate2Int(pattern.' 00:00')
    let cpattern = strftime(s:hts_date, sec)
    let year = strpart(pattern, 0, 4)
    if cpattern !~ s:sch_date || year < g:YearStrftime
      let month = strpart(pattern, 4, 2)
      let day = strpart(pattern, 6, 2)
      let cpattern = substitute(g:QFixHowm_DatePattern, '%Y', year, '')
      let cpattern = substitute(cpattern, '%m', month, '')
      let cpattern = substitute(cpattern, '%d', day, '')
    endif
  elseif pattern =~ '^\d\{6}$'
    let sec = QFixHowmDate2Int('20'.pattern.' 00:00')
    let cpattern = strftime(s:hts_date, sec)
    if cpattern !~ s:sch_date
      let year  = '20' . strpart(pattern, 0, 2)
      let month = strpart(pattern, 2, 2)
      let day   = strpart(pattern, 4, 2)
      let cpattern = substitute(g:QFixHowm_DatePattern, '%Y', year, '')
      let cpattern = substitute(cpattern, '%m', month, '')
      let cpattern = substitute(cpattern, '%d', day, '')
    endif
  elseif pattern =~ '^\d\{4}$'
    let head = matchstr(dpattern, '\d\{4}')
    let sec = QFixHowmDate2Int(head . pattern.' 00:00')
    let cpattern = strftime(s:hts_date, sec)
  elseif pattern =~ '^\d\{1,3}$'
    if pattern[0] != '0' && pattern < 32
      let head = substitute(dpattern, '\d\{2}$', '', '')
      let cpattern = head . printf('%2.2d', pattern)
      let sec = QFixHowmDate2Int(cpattern .' 00:00')
    else
      if pattern + 0 == 0
        let cpattern = strftime(s:hts_date)
        let sec = QFixHowmDate2Int(cpattern.' 00:00')
        let sec = QFixHowmDate2Int(cpattern.' 00:00')
      else
        let pattern = substitute(pattern, '^[+0]*', '', '')
        let sec = pattern * 24*60*60
        let sec = sec + QFixHowmDate2Int(dpattern.' 00:00')
      endif
    endif
    let cpattern = strftime(s:hts_date, sec)
  else
    return ":call cursor(".prevline.",".prevcol.")\<CR>"
  endif
  return ":call cursor(line('.'),".start.")\<CR>:exe 'normal! c".len."l".cpattern."'\<CR>:call cursor(".prevline.",".prevcol.")\<CR>"
endfunction

" 繰り返し予定のアクションロック
function! QFixHowmRepeatDateActionLock()
  let prevline = line('.')
  let prevcol = col('.')
  let start = 2
  let cpattern = strftime(s:hts_date)
  let len = strlen(cpattern)
  let searchWord = '^\s*'.s:sch_dateCmd
  let text = matchstr(getline('.'), searchWord)
  if text == "" || col('.') > strlen(text)
    return "\<CR>"
  endif
  let str = matchstr(text, '^\s*\['.s:sch_date)
  let str = substitute(str, '^\s*\[', '', '')
  let searchWord = ']'.s:sch_cmd
  let cmd = matchstr(getline('.'), searchWord)
  let cmd = substitute(cmd, '^]', '', '')
  if cmd =~ '^\.'
    return "\<CR>"
  endif
  let opt = matchstr(cmd, '[0-9]*$')
  let clen = matchstr(cmd, '^'.s:sch_Ext.'\+')
  let ccmd = matchstr(cmd, s:sch_Ext.'(')
  if strlen(ccmd) == 0 && strlen(clen) == 1
    let searchWord = '^\s*'.s:sch_dateT
    let len = matchend(getline('.'), searchWord) + 1
    return ":call cursor(line('.'),".len.")\<CR>:exe 'normal! r.'\<CR>:call cursor(".prevline.",".prevcol.")\<CR>"
  endif
  let cpattern = s:CnvRepeatDate(cmd, opt, str, -1)
  if match(str, '\d\{4}.\d\{2}.00') == 0
    let cpattern = substitute(cpattern, '\(\d\{4}.\d\{2}.\)\d\{2}', '\100', '')
  endif
  let start = 2 + match(getline('.'), s:sch_dateT)
  return ":call cursor(line('.'),".start.")\<CR>:exe 'normal! c".len."l".cpattern."'\<CR>:call cursor(".prevline.",".prevcol.")\<CR>"
endfunction

""""""""""""""""""""""""""""""
"Quickfixウィンドウの定義部分を取り出す
"休日・祝日の予定もエクスポート対象にする
if !exists('g:QFixHowmExportHoliday')
  let g:QFixHowmExportHoliday = 0
endif
function! QFixHowmCmd_ScheduleList(...) range
  if !exists("*QFixHowmExportSchedule")
    return
  endif
  let prevPath = escape(getcwd(), ' ')

  let firstline = 1
  let cnt = line('$')
  if a:firstline != a:lastline || a:0 > 0
    let cnt = a:lastline - a:firstline + 1
    let firstline = a:firstline
  endif

  let schlist = []
  let l:QFixHowm_Title = '\d\+| '.s:sch_dateT.s:sch_Ext
  let save_cursor = getpos('.')
  for n in range(cnt)
    call cursor(firstline+n, 1)
    let qfline = getline('.')
    if qfline !~ l:QFixHowm_Title
      continue
    endif
    let holiday = g:QFixHowm_ReminderHolidayName
    if exists('g:QFixHowm_UserHolidayName')
      let holiday = g:QFixHowm_ReminderHolidayName . '\|' .g:QFixHowm_UserHolidayName
    endif
    let hdreg = '^'.s:sch_dateTime .'@ '.g:QFixHowm_DayOfWeekReg.' \?'.'\('.holiday.'\)'
    if qfline =~ holiday && g:QFixHowmExportHoliday == 0
      continue
    endif
    let file = QFixGet('file')
    let lnum = QFixGet('lnum')
    let ddat = {"qffile": file, "qflnum": lnum, "qfline": qfline}
    call add(schlist, ddat)
  endfor
  call setpos('.', save_cursor)

  call QFixPclose(1)
  let h = g:QFix_Height
  for d in schlist
    call s:QFixHowmMakeScheduleList(d)
  endfor
  let g:QFix_Height = h
  if schlist != []
    call s:QFixHowmParseScheduleList(schlist)
    call QFixHowmExportSchedule(schlist)
  else
    call QFixCopen()
    call cursor(1, 1)
  endif
  return schlist
endfunction

function! s:QFixHowmMakeScheduleList(sdic)
  let file = a:sdic['qffile']
  let lnum = a:sdic['qflnum']
  let tpattern = qfixmemo#TitleRegxp()
  let [entry, flnum, llnum] = QFixMRUGet('entry', file, lnum, tpattern)
  let a:sdic['orgline'] = entry[0]
  call remove(entry, 0)
  let a:sdic['Description'] = entry
  return a:sdic['Description']
endfunction

function! s:QFixHowmParseScheduleList(sdic)
  for d in a:sdic
    let pattern = '.*'.s:sch_dateT.s:sch_Ext.'\d*\s*'.g:QFixHowm_DayOfWeekReg.'\?\s*'
    let d['Summary'] = substitute(d['qfline'], pattern, '', '')
    let pattern = '\['.s:sch_date
    let d['StartDate'] = strpart(matchstr(d['qfline'], pattern), 1)
    let d['StartDate'] = substitute(d['StartDate'], '[/]', '-', 'g')
    let pattern = '\['.s:sch_date . ' '. s:sch_time
    let d['StartTime'] = strpart(matchstr(d['qfline'], pattern), 12)
    let pattern = '&\['.s:sch_date
    let d['EndDate'] = strpart(matchstr(d['orgline'], pattern), 2)
    let d['EndDate'] = substitute(d['EndDate'], '[/]', '-', 'g')
    let pattern = '&\['.s:sch_date.' '. s:sch_time
    let d['EndTime'] = strpart(matchstr(d['orgline'], pattern), 13)
    if d['EndTime'] == ''
      let d['EndDate'] = QFixHowmAddDate(d['EndDate'], g:QFixHowm_EndDateOffset)
    endif

    let pattern = s:sch_dateCmd
    let d['define']  = strpart(matchstr(d['orgline'], pattern), 0)
    let pattern = ']'.s:sch_cmd
    let d['command'] = strpart(matchstr(d['orgline'], pattern), 1)
    let d['duration'] = matchstr(d['command'], '\d\+$')

    let duration = d['duration']
    let cmd = d['command'][0]
    if duration == ''
      if cmd == '@'
        "@のデフォルトオプションは表示だけに関係する
        let duration = 1
      elseif cmd == '!'
        let duration = g:QFixHowm_ReminderDefault_Deadline
      elseif cmd == '-'
        let duration = g:QFixHowm_ReminderDefault_Reminder
      elseif cmd == '+'
        let duration = g:QFixHowm_ReminderDefault_Todo
      elseif cmd == '~'
        let duration = g:QFixHowm_ReminderDefault_UD
      else
        let duration = 0
      endif
    else
      "@のオプションは0,1の継続期間が同じ
      if cmd == '@'
        if duration < 2
          let duration = 1
        endif
      endif
    endif
    "-の継続期間は duration+1日
    if cmd == '-'
      let duration = duration + g:QFixHowm_ReminderOffset
    endif
    let d['duration'] = duration
  endfor
endfunction

function! QFixHowmAddDate(date, param)
  let day = QFixHowmDate2Int(a:date) + a:param
  let sttime = (day - g:DateStrftime) * 24 * 60 * 60 + g:QFixHowm_ST * (60 * 60)
  let str = strftime(s:hts_date, sttime)
  return matchstr(str, s:sch_date)
endfunction

function! HowmSchedueCachedTime(mode)
  exe 'let time = s:LT_'.a:mode
  return time
endfunction

"strftime()の基準日数(1970-01-01)
if !exists('g:DateStrftime')
  " let g:DateStrftime = 719162
  let g:DateStrftime = QFixHowmDate2Int(printf('%4.4d%2.2d%2.2d', g:YearStrftime, 1, 1))
endif

let loaded_HowmSchedule = 1

" 予定・TODOのみ使用したい場合
if exists('g:HowmSchedule_only') && g:HowmSchedule_only
  finish
endif

"=============================================================================
" for autoload
function! howm_schedule#init()
endfunction

function! howm_schedule#Init()
endfunction

"=============================================================================
"折りたたみに ワイルドカードチャプターを使用する
if !exists('g:QFixHowm_WildCardChapter')
  let g:QFixHowm_WildCardChapter = 0
endif
"階層付きテキストもワイルドカードチャプター変換の対象にする
if !exists('g:QFixHowm_WildCardChapterMode')
  let g:QFixHowm_WildCardChapterMode = 1
endif
"チャプターのタイトル行を折りたたみに含める/含めない
if !exists('g:QFixHowm_FoldingChapterTitle')
  let g:QFixHowm_FoldingChapterTitle = 0
endif
"折りたたみのパターン
if !exists('g:QFixHowm_FoldingPattern')
  let g:QFixHowm_FoldingPattern = '^[=.*]'
endif
"折りたたみのレベル設定
if !exists('g:QFixHowm_FoldingMode')
  let g:QFixHowm_FoldingMode = 0
endif

" *. 形式のワイルドカードチャプター対応フォールディング
let s:schepat = '^\s*'.s:sch_dateT.s:sch_Ext
silent! function QFixHowmFoldingLevelWCC(lnum)
  let s:titlepat = '^'.escape(g:QFixHowm_Title, g:QFixHowm_EscapeTitle).'\([^'.g:QFixHowm_Title.']\|$\)'
  let text = getline(a:lnum)
  if text =~ s:titlepat || text =~ s:schepat
    if g:QFixHowm_Folding == 1
      return '>1'
    endif
    return '0'
  endif
  "カードチャプターに応じて折りたたみレベルを設定する
  let wild = '\(\(\d\+\|\*\)\.\)\+\(\d\+\|\*\)\?'
  let str = matchstr(text, '^\s*'.wild.'\s*')
  let str = substitute(str, '\d\+', '*', 'g')
  let level = strlen(substitute(str, '[^*]', '' , 'g'))
  if level == 0 && g:QFixHowm_FoldingPattern != ""
    let str = matchstr(text, g:QFixHowm_FoldingPattern.'\+')
    let str = substitute(str, '[^'.str[0].'].*$', '', 'g')
    let level = strlen(str)
  endif
  if g:QFixHowm_FoldingMode == 0
    if level
      if g:QFixHowm_FoldingChapterTitle == 0
        return '>1'
      endif
      return '0'
    endif
    return '1'
  elseif g:QFixHowm_FoldingMode == 1
    if level
      return '>'.level
    endif
    return 'a'
  endif
  return '1'
endfunction

" *. 形式のワイルドカードチャプターを数字に変換
silent! function CnvWildcardChapter(...) range
  let firstline = a:firstline
  let lastline = a:lastline
  if a:0 == 0
    let firstline = 1
    let lastline = line('$')
  endif
  let top = 0
  let wild = '\(\*\.\)\+\*\?\s*'
  if g:QFixHowm_WildCardChapterMode
    let wild = wild . '\|^\.\+\s*'
  endif
  let nwild = '\(\d\+\.\)\+\(\d\+\)\?'
  let chap = [top, 0, 0, 0, 0, 0, 0, 0]
  let plevel = 1
  let save_cursor = getpos('.')
  for l in range(firstline, lastline)
    let str = matchstr(getline(l), '^\s*'.nwild.'\s*')
    if str != ''
      for c in range(8)
        let ch = matchstr(str,'\d\+', 0 ,c+1)
        let chap[c] = 0
        if ch != ''
          let chap[c] = ch
        endif
      endfor
      continue
    endif
    let str = matchstr(getline(l), '^\s*'.wild)
    let len = strlen(str)
    if str[0] == '.'
      let str = substitute(str, '\.', '*.', 'g')
      if strlen(substitute(str, '\s*$', '', '')) > 2
        let str = substitute(str, '\.\(\s*\)$', '\1', 'g')
      endif
    endif
    let level = strlen(substitute(str, '[^*]', '' , 'g'))
    if level == 0
      continue
    endif
    let chap[level-1] = chap[level-1] + 1
    if level < plevel
      for n in range(level, 8-1)
        let chap[n] = 0
      endfor
    endif
    let plevel = level
    for n in range(level)
      let str = substitute(str, '\*', chap[n], '')
    endfor
    let nstr = str . strpart(getline(l), len)
    let sline = line('.')
    call setline(l, [nstr])
  endfor
  call setpos('.', save_cursor)
endfunction

if !exists('*QFixHowmInit')
let s:QFixHowm_Init  = 0
function QFixHowmInit()
  if s:QFixHowm_Init
    return 0
  endif
  let l:howm_dir = '~/howm'
  let l:howm_dir = exists('g:howm_dir') ? g:howm_dir : l:howm_dir
  let l:howm_dir = exists('g:qfixmemo_dir') ? g:qfixmemo_dir : l:howm_dir
  let l:howm_dir = s:howm_dir != '' ? s:howm_dir : l:howm_dir
  let dir = expand(l:howm_dir)
  if isdirectory(dir) == 0
    let mes = printf('"%s" is not directory!', l:howm_dir)
    let choice = confirm(mes, "&OK", 1, "W")
    return 1
  endif
  let s:QFixHowm_Init = 1
  return 0
endfunction
endif

if !exists('*QFixPclose')
command QFixPclose call QFixPclose()
function QFixPclose(...)
endfunction
endif
