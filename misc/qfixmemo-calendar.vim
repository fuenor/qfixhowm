"=============================================================================
"    Description: howm style scheduler - calendar.vim
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/qfixhowm
"  Last Modified: 2011-11-01 18:13
"=============================================================================
let s:Version = 2.00
scriptencoding utf-8

if exists('enable_QFixMemoCalendar') && !enable_QFixMemoCalendar
  finish
endif
if exists('g:QFixMemoCalendar_version') && g:QFixCalendar_version < s:Version
  unlet loaded_QFixMemoCalendar_vim
endif
if exists("loaded_QFixMemoCalendar_vim") && !exists('fudist')
  finish
endif
let g:QFixMemoCalendar_version = s:Version
let loaded_QFixMemoCalendar_vim = 1
if v:version < 700 || &cp
  finish
endif

" calendar.vimで使う休日定義ファイル
" https://sites.google.com/site/fudist/Home/qfixhowm#downloads
if !exists('g:calendar_holidayfile')
  " let g:calendar_holidayfile = '~/qfixmemo/Sche-Hd-0000-00-00-000000.howm'
  let g:calendar_holidayfile = ''
endif
" 休日サインの設定
if !exists('g:calendar_flag')
  " サインには + ! # $ % & @ ? が使えます
  let g:calendar_flag=['', '+', '@', '#']
endif
" calendar.vimのコマンドをハイライト表示変更のためオーバーライド
if !exists('g:calendar_holiday_command')
  let g:calendar_holiday_command = 1
endif

"
"  Intro:
"
"  qfixmemo-calendar.vimはQFixMemoをカレンダー(calendar.vim)と連携させるための
"  プラグインです。
"  またcalendar.vimで休日が強調表示されないのですが、QFixMemoの休日定義ファイ
"  ルを利用して休日をカレンダー上で強調表示することもできます。
"  なお休日の強調表示は本プラグイン単独で行うので、QFixMemoは特に必要としませ
"  ん。
"  calendar.vimは以下にあります。
"  http://www.vim.org/scripts/script.php?script_id=52
"
"  1. 日記の設定
"
"     以下を .vimrcへ追加して日付上で<CR>を押すとQFixMemoで日記を書くことがで
"     きます。
"
"       let calendar_action = "QFixMemoCalendarDiary"
"       let calendar_sign   = "QFixMemoCalendarSign"
"
"  2. calendar.vimに休日を表示する
"
"    calendar.vimに表示する休日を定義するファイルにはQFixMemoの休日定義ファイ
"    ルを使用します。
"    https://sites.google.com/site/fudist/Home/qfixhowm#downloads
"    日本語部分は表示されないのでどちらでもかまいません。
"    適当なディレクトリにコピーした後、以下を .vimrcへ追加してください。
"
"      " calendar.vimで使う休日定義ファイル(パス等は環境に合わせてください)
"      let calendar_holidayfile = '~/qfixmemo/Sche-Hd-0000-00-00-000000.howm'
"
"    以降はサインが次の表のように表示されます。
"
"      |     |  普通日               |
"      |  +  |  日記が存在する       |
"      |  @  |  休日                 |
"      |  #  |  休日で日記が存在する |
"
"      このサインは以下のように定義されています。
"      calendar_flag = ['', '+', '@', '#']
"      サインには +!#$%&@? が使えるので好みに応じてg:calendar_flagを変更して
"      ください。
"      ただし後述するCalendarPost()で @ と # のハイライト表示を本プラグインで
"      変更しているのでCalendarPost()も適切に変更する必要があります。
"
"  2.1 休日サインのシンタックス表示
"     qfixmemo-calendar.vimで休日の強調表示を有効にして:Calendarを実行すると若
"     干表示が変わって、大抵の環境では休日が赤く表示されていると思います。
"     これはCalendarPost()で休日のサイン(@ #)をCalSundayに変更し、CalSundayを
"     WarningMsgに変更しているからです。
"     気に入らない場合は次を設定して無効化してください。
"       " calendar.vimのコマンドをハイライト表示変更のためオーバーライド
"       let g:calendar_holiday_command = 0
"
"     NOTE:
"     なおカーソルキーの左右等でデフォルト以外の月のカレンダーを表示させるよう
"     な場合はシンタックスハイライトがデフォルトに戻ってしまい、「休日」と「日
"     記の存在する日」とが色で区別できなくなることがあります。
"     :Calendarで再表示するとまた休日は赤く表示されますが、これを常に「休日」
"     と「日記のある日」の色を変えて表示したいという場合はcalendar.vimを改変す
"     る必要があります。
"
"     calendar.vimのシンタックスは function Calendar() のなかで毎回リセットさ
"     れ再定義されてしまいます。したがってシンタックス作成が終わった後に独自の
"     シンタックス設定を行なってやれば良いということになります。
"     具体的には calendar.vim Ver.2.5なら1166行目の function Calendar()の最後
"     に CalendarPost()を追加すると良いかと思います
"
"       function! Calendar(...)
"       ...(略)
"
"         " ruler
"         execute 'syn match CalRuler "'.vwruler.'"'
"
"         if search("\*","w") > 0
"           silent execute "normal! gg/\*\<cr>"
"         endif
"  ここ>>>  call CalendarPost()  " 独自の色分けのため追加
"         return ''
"       endfunction
"
"  2.2 休日定義のフォーマット
"
"    休日定義ファイルで使用可能な定義はQFixMemoの予定・TODOのサブセットです。
"    現在のところは次の3種類のみサポートされています。
"
"      [2010/01/11]@@@(2*Mon)0 成人の日
"      [2010/02/11]@@@0 建国記念の日
"      [2011/03/21]@0 春分の日
"
"    @@@ は年単位の繰り返しで、第2水曜を指定したい場合は(2*Wed)のように曜日指
"    定オプションを使用します。
"    @ は一回限りの指定です。
"

" コマンド乗っ取り
" ハイライトを変更されたくない場合は calendar_holiday_command = 0 を設定
if g:calendar_holidayfile != '' && g:calendar_holiday_command
  au VimEnter * command! -nargs=* Calendar  call Calendar(0,<f-args>) | call CalendarPost()
  au VimEnter * command! -nargs=* CalendarH call Calendar(1,<f-args>) | call CalendarPost()
endif

" 独自ハイライトへの変更
function! CalendarPost()
  if g:calendar_mark =~ 'left-fit'
    syn match CalSunday display "\s*[@#]\d*"
  elseif g:calendar_mark =~ 'right'
    syn match CalSunday display "\d*[@#]\s*"
  else
    syn match CalSunday display "[@#]\s*\d*"
  endif
  if s:holiday == 1 " 今日が休日
    hi link CalToday WarningMsg
  endif
  hi link CalSunday  WarningMsg
  hi link CalMemo    PreProc
endfunction

"=============================================================================
if !exists('calendar_action')
  let calendar_action = "QFixMemoCalendarDiary"
endif
if !exists('calendar_sign')
  let calendar_sign   = "QFixMemoCalendarSign"
endif

function! QFixMemoCalendarSign(day, month, year)
  let year  = printf("%4.4d",a:year)
  let month = printf("%2.2d",a:month)
  let day   = printf("%2.2d",a:day)
  let sfile = g:qfixmemo_diary.'.'.g:qfixmemo_ext
  let sfile = substitute(sfile, '%Y', year, 'g')
  let sfile = substitute(sfile, '%m', month, 'g')
  let sfile = substitute(sfile, '%d', day, 'g')
  let sfile = g:qfixmemo_dir.'/'.sfile
  let hday = <SID>holidaycheck(a:year, a:month, a:day)
  let id = filereadable(expand(sfile)) + hday*2
  return g:calendar_flag[id]
endfunction

function! QFixMemoCalendarDiary(day, month, year, week, dir)
  let year  = printf("%4.4d",a:year)
  let month = printf("%2.2d",a:month)
  let day   = printf("%2.2d",a:day)
  let file = g:qfixmemo_diary
  let file = substitute(file, '%Y', year, 'g')
  let file = substitute(file, '%m', month, 'g')
  let file = substitute(file, '%d', day, 'g')
  let winnr = bufwinnr(bufnr(file))
  let lwinnr = winnr('$')
  if filereadable(expand(file))
    if winnr > -1
      exec winnr.'wincmd w'
    else
      exe "e " . escape(file, ' ')
    endif
  else
    call qfixmemo#Edit(file)
  endif
  if lwinnr == 1
    Calendar
    wincmd p
  endif
endfunction

""""""""""""""""""""""""""""""
" dummy
function! s:holidaycheck(year, month, day)
  return 0
endfunction

"=============================================================================
if g:calendar_holidayfile == ''
  finish
endif

if g:calendar_sign == "<SID>CalendarSign"
  let g:calendar_sign   = "CalendarSign_"

  function! CalendarSign_(day, month, year)
    let sfile = g:calendar_diary."/".a:year."/".a:month."/".a:day.".cal"
    let hday = <SID>holidaycheck(a:year, a:month, a:day)
    let id = filereadable(expand(sfile)) + hday*2
    return g:calendar_flag[id]
  endfunction
endif

let s:init = 0
let g:holidaytbl = {}
function! s:holidaycheck(year, month, day)
  if !s:init
    call s:readholidayfile()
  endif
  if !exists('g:holidaytbl[a:year]') && s:init
    let g:holidaytbl[a:year] = 1
    " 今年の予定を作成
    for d in s:holidaydict
      if d[0] == '@@@'
        if d[4] != '' && d[5] != ''
          let time = GetDoWShiftTime(a:year, d[2], d[4], d[5])
          let date = strftime('%Y%m%d', time)
        else
          let date = printf('%4.4d%2.2d%2.2d', a:year, d[2], d[3])
        endif
      else
        continue
      endif
      let g:holidaytbl[date] = 1
    endfor
  endif
  let date = printf('%4.4d%2.2d%2.2d', a:year, a:month, a:day)
  return exists('g:holidaytbl[date]') ? 1 :0
endfunction

""""""""""""""""""""""""""""""
" 休日定義ファイルを読み込み
let s:holiday = 0
let s:holidaydict= []
function! s:readholidayfile()
  let file = expand(g:calendar_holidayfile)
  if !filereadable(file)
    let mes = printf("can't open file\n(%s)", file)
    let choice = confirm(mes, "&OK", 1, "W")
    return 1
  endif
  let glist = readfile(file)
  let today = strftime('%Y%m%d')
  let sch_date = '^.\d\{4}.\d\{2}.\d\{2}.'
  let sch_dow  = '\c\(Sun\|Mon\|Tue\|Wed\|Thu\|Fri\|Sat\|Hdy\)'
  let sch_cmd  = '[@]\{1,3}\(([0-9]*[-+*]\?'.sch_dow.'\?\([-+]\d\+\)\?)\)\?[0-9]*'

  for str in glist
    let date = matchstr(str, sch_date)
    let date = substitute(date, '[^0-9]', '', 'g')
    let year  = strpart(date, 0,  4)+0
    let month = strpart(date, 4,  2)+0
    let day   = strpart(date, 6,  2)+0
    let str = substitute(str, sch_date, '', '')
    let str = matchstr(str, '^'.sch_cmd)
    if str == ''
      continue
    endif
    let cmd = matchstr(str, '@\+')
    let opt = matchstr(str, '\d*$')
    let str = matchstr(str, '(\d\*'.sch_dow.')')
    let sft = matchstr(str, '\d')
    let dow = matchstr(str, sch_dow)
    if cmd == '@'
      let date = printf('%4.4d%2.2d%2.2d', year, month, day)
      let g:holidaytbl[date] = 1
      continue
    elseif cmd == '@@@'
    else
      continue
    endif
    call add(s:holidaydict, [cmd, year, month, day, sft, dow, opt])
  endfor
  let s:init = 1
  if <SID>holidaycheck(strftime('%Y'), strftime('%m'), strftime('%d'))
    let s:holiday = 1
  endif
  return 0
endfunction

""""""""""""""""""""""""""""""
" localtime()の起点日数(1970-01-01)
if !exists('g:Date2Int_FirstDay')
  let g:Date2Int_FirstDay = 719162
endif

let s:DoW = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
function! GetDoWShiftTime(year, month, sft, dow)
  let year = a:year
  let month = a:month
  let day = 1
  let sft = a:sft
  if sft == 0 || sft == ''
    let sft = 1
  endif
  let dow = a:dow
  let fday = Date2Int(year, month, day)
  let fdow = fday%7
  let day = fday - fday%7
  let day += (sft) * 7 + index(s:DoW, dow)
  let time = (day - g:Date2Int_FirstDay) * 24 * 60 *60
  return time
endfunction

function! Date2Int(year, month, day)
  let year = a:year
  let month = a:month
  let day = a:day

  if day == '00'
    let day = s:EndOfMonth(year, month, day)
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
  return today
endfunction

" 月末
function! s:EndOfMonth(year, month, day)
  let year = a:year
  let month = a:month
  if month > 12
    let year += 1
    let month = month - 12
  endif
  let day = a:day
  let monthdays = [31,28,31,30,31,30,31,31,30,31,30,31]
  if year%4 == 0 && year%100 != 0 || year%400 == 0
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

