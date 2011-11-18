"=============================================================================
"    Description: howm style scheduler - calendar.vim
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/qfixhowm
"  Last Modified: 2011-11-05 20:41
"        Version: 2.00
"=============================================================================
if v:version < 700 || &cp
  finish
endif
" calendar.vimで使う休日定義ファイル
" https://sites.google.com/site/fudist/Home/qfixhowm#downloads
if !exists('g:calendar_holidayfile')
  " let g:calendar_holidayfile = '~/qfixmemo/Sche-Hd-0000-00-00-000000.howm'
  let g:calendar_holidayfile = ''
endif
" CalHolidayのハイライト指定
if !exists('g:calendar_CalHoliday')
  " let g:calendar_CalHoliday = 'CalMemo'
  let g:calendar_CalHoliday = 'CalSunday'
endif
" calendar.vimのコマンドをqfixmemo-calendar.vimのハイライト表示に変更
if !exists('g:calendar_howm_syntax')
  let g:calendar_howm_syntax = 1
endif
" サインの表示位置 left-fit, left, right
if !exists("g:calendar_mark")
 \|| (g:calendar_mark != 'left'
 \&& g:calendar_mark != 'left-fit'
 \&& g:calendar_mark != 'right')
  let g:calendar_mark = 'left-fit'
endif

" コマンド乗っ取り
" ハイライトを変更されたくない場合は calendar_howm_syntax = 0 を設定
if g:calendar_howm_syntax
  au VimEnter * command! -nargs=* Calendar  call Calendar(0,<f-args>) | call CalendarPost()
  au VimEnter * command! -nargs=* CalendarH call Calendar(1,<f-args>) | call CalendarPost()
endif

if !exists('g:calendar_flag')
  let g:calendar_flag=['', '+', '@', '#']
endif

if !exists('g:calendar_action')
  let g:calendar_action = "<SID>CalendarDiary"
endif
if !exists('g:calendar_sign') || g:calendar_sign == '<SID>CalendarSign'
  let g:calendar_sign = "CalendarSign_"
endif

" 独自ハイライトへの変更
let s:holiday = 0
function! CalendarPost()
  if g:calendar_howm_syntax == 0
    return
  endif
  syn match CalConceal /[@]/ contained
  if g:calendar_mark =~ 'left-fit'
    syn match CalHoliday display "\s*[@#]\d*" contains=CalConceal
  elseif g:calendar_mark =~ 'right'
    syn match CalHoliday display "\d*[@#]\s*" contains=CalConceal
  else
    syn match CalHoliday display "[@#]\s*\d*" contains=CalConceal
  endif
  if s:holiday == 1 " 今日が休日
    hi link CalToday CalHoliday
  endif
  hi link CalMemo    PreProc
  hi link CalSunday  WarningMsg
  exe 'hi def link CalHoliday '.g:calendar_CalHoliday
  hi CalConceal guifg=bg guibg=bg ctermfg=bg ctermbg=bg
endfunction

function! s:CalendarPost(win)
  augroup Calendar
    au!
    if a:win
      exe 'au BufEnter __Calendar normal! '.winheight(0) ."\<C-W>_"
    else
      exe 'au BufEnter __Calendar normal! '.winwidth(0) ."\<C-W>|"
    endif
  augroup END
endfunction

function! QFixMemoCalendarSign(day, month, year)
  let year  = printf("%4.4d",a:year)
  let month = printf("%2.2d",a:month)
  let day   = printf("%2.2d",a:day)
  let file = g:qfixmemo_diary
  if tolower(fnamemodify(file, ':e')) != g:qfixmemo_ext
    let file .= '.' . g:qfixmemo_ext
  endif
  let file = substitute(file, '%Y', year, 'g')
  let file = substitute(file, '%m', month, 'g')
  let file = substitute(file, '%d', day, 'g')
  let file = g:qfixmemo_dir.'/'.file
  let hday = HolidayCheck(a:year, a:month, a:day)
  let id = filereadable(expand(file)) + hday*2
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
  call qfixmemo#Edit(file)
  let lwinnr = winnr('$')
  if lwinnr == 1
    Calendar
    wincmd p
  endif
endfunction

"=============================================================================
" スタブ
function! HolidayCheck(year, month, day)
  return 0
endfunction

if !exists("g:calendar_diary")
  let g:calendar_diary = "~/diary"
endif

function! s:CalendarDiary(day, month, year, week, dir)
  call confirm("diary plugin requiard.", 'OK')
endfunction

function! CalendarSign_(day, month, year)
  let sfile = g:calendar_diary."/".a:year."/".a:month."/".a:day.".cal"
  let hday = HolidayCheck(a:year, a:month, a:day)
  let id = filereadable(expand(sfile)) + hday*2
  return g:calendar_flag[id]
endfunction

if !exists('g:howm_calendar_wincmd')
  let g:howm_calendar_wincmd = 'vertical topleft'
endif
if !exists('g:howm_calendar_count')
  let g:howm_calendar_count = 3
endif
if !exists('*Calendar')
  function Calendar(...)
    call QFixMemoCalendar(g:howm_calendar_wincmd, '__Calendar__', g:howm_calendar_count)
    if exists('g:fudist')
      call s:CalendarPost(a:0)
    endif
  endfunction
endif

"=============================================================================
"    Description: holiday definition table
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/qfixhowm
"  Last Modified: 2011-11-05 20:41
"=============================================================================
let s:Version = 1.00
scriptencoding utf-8
if v:version < 700 || &cp
  finish
endif

if exists('g:QFixMemoCalendar_version') && g:QFixMemoCalendar_version < s:Version
  unlet loaded_QFixMemoCalendar_vim
endif
if exists("loaded_QFixMemoCalendar_vim") && !exists('fudist')
  finish
endif
let g:QFixMemoCalendar_version = s:Version
let loaded_QFixMemoCalendar_vim = 1

" 休日定義ファイル
" https://sites.google.com/site/fudist/Home/qfixhowm#downloads
if !exists('g:calendar_holidayfile')
  " let g:calendar_holidayfile = '~/qfixmemo/Sche-Hd-0000-00-00-000000.howm'
  let g:calendar_holidayfile = ''
endif
" カレンダーボード
if !exists('g:calendar_footer')
  let g:calendar_footer = [
    \ '   Prev  |  Next',
    \ '  -----------------',
    \ '     <   |   >',
    \ '     i   |   o',
    \ '  -----------------',
    \ '    t .  : Today',
    \ '    r    : Reload',
    \ '  -----------------',
    \ '  {num}<CR> : diary',
    \ '  ex. <CR> or 16<CR>',
    \]
endif

""""""""""""""""""""""""""""""
" 指定日が休日かチェック
""""""""""""""""""""""""""""""
function! HolidayCheck(year, month, day)
  call s:MakeHolidayTbl(a:year)
  let date = printf('%4.4d%2.2d%2.2d', a:year, a:month, a:day)
  return exists('s:holidaytbl[date]') ? 1 : 0
endfunction

""""""""""""""""""""""""""""""
" 少なくとも指定年の休日定義が含まれる辞書を返す
""""""""""""""""""""""""""""""
function! GetHolidayDict(year)
  call s:MakeHolidayTbl(a:year)
  return deepcopy(s:holidaytbl)
endfunction

""""""""""""""""""""""""""""""
" localtime()基準の経過日
""""""""""""""""""""""""""""""
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
" strftime()の基準年
if !exists('g:YearStrftime')
  let g:YearStrftime = 1970
endif
" strftime()の基準日数(1970-01-01)
if !exists('g:DateStrftime')
  let g:DateStrftime = Date2Int(g:YearStrftime, 1, 1)
endif

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

" 今年の予定を作成
let s:holidaytbl = {}
function! s:MakeHolidayTbl(year)
  if len(s:holidaydict) == 0
    call s:readholidayfile()
  endif
  if !exists('s:holidaytbl[a:year]') && len(s:holidaydict)
    let s:holidaytbl[a:year] = '|exists|'
    if exists('*MakeUserHoliday')
      call MakeUserHoliday(s:holidaytbl, a:year)
    endif
    for d in s:holidaydict
      if d['cmd'] == '@@@'
        if a:year < d['year']
          continue
        elseif d['cnvdow'] != ''
          let time = s:GetCnvDoWTime(a:year, d['month'], d['cnvdow'], d['sft'])
          let date = strftime('%Y%m%d', time)
        else
          let date = printf('%4.4d%2.2d%2.2d', a:year, d['month'], d['day'])
        endif
        let s:holidaytbl[date] = d['text']
      elseif d['cmd'] == '@@'
        for month in range(1, 12)
          let day = s:EndOfMonth(a:year, month, d['day'])
          let date = printf('%4.4d%2.2d%2.2d', a:year, month, day)
          let s:holidaytbl[date] = d['text']
        endfor
      else
        continue
      endif
    endfor
  endif
endfunction

" 休日定義ファイルを読み込み
let s:holidaydict= []
function! s:readholidayfile()
  call s:setholidayfile()
  let file = expand(g:calendar_holidayfile)
  if file ==''
    return 1
  elseif !filereadable(file)
    let mes = printf("%s does not exist.", file)
    echo mes
    return 1
  endif
  let glist = readfile(file)
  let today = strftime('%Y%m%d')
  let sch_ext  = '-@!+~.'
  let sch_date = '^.\d\{4}.\d\{2}.\d\{2}.'
  let sch_dow  = '\c\(Sun\|Mon\|Tue\|Wed\|Thu\|Fri\|Sat\|Hdy\)'
  let sch_cmd  = '['.sch_ext.']\{1,3}\(([0-9]*[-+*]\?'.sch_dow.'\?\([-+]\d\+\)\?)\)\?[0-9]*'
  for str in glist
    let date = matchstr(str, sch_date)
    let date = substitute(date, '[^0-9]', '', 'g')
    let year  = strpart(date, 0,  4)+0
    let month = strpart(date, 4,  2)+0
    let day   = strpart(date, 6,  2)+0
    let str = substitute(str, sch_date, '', '')
    let cmdstr = matchstr(str, '^'.sch_cmd)
    if cmdstr == ''
      continue
    endif
    let cmd = matchstr(cmdstr, '['.sch_ext.']\+')
    let opt = matchstr(cmdstr, '\d*$')
    let cnvdow = matchstr(cmdstr, '(\(\d\*\)\?'.sch_dow)
    let cnvdow = substitute(cnvdow, '(', '', '')
    let sft = matchstr(cmdstr, '[-+]\(\d\+\|'.sch_dow.'\))')
    let sft = substitute(sft, ')', '', '')
    let repeat = matchstr(cmdstr, '(\d\+')
    let repeat = substitute(repeat, '(', '', '')
    let text = substitute(str, '^'.sch_cmd, '', '')
    if cmd == '@'
      if day == '00'
        let day = s:EndOfMonth(year, month, day)
      endif
      let date = printf('%4.4d%2.2d%2.2d', year, month, day)
      let s:holidaytbl[date] = text
      continue
    elseif cmd == '@@'
    elseif cmd == '@@@'
    else
      continue
    endif
    let hday = {'cmd':cmd, 'year':year, 'month':month, 'day':day, 'repeat':repeat, 'cnvdow':cnvdow, 'sft':sft, 'opt':opt, 'text':text}
    call add(s:holidaydict, hday)
  endfor
  if HolidayCheck(strftime('%Y'), strftime('%m'), strftime('%d'))
    let s:holiday = 1
  endif
  return 0
endfunction

function! s:setholidayfile()
  if g:calendar_holidayfile != ''
    return g:calendar_holidayfile
  endif
  if !exists('g:QFixHowm_HolidayFile')
    return ''
  endif
  if exists('g:QFixHowm_ScheduleSearchDir') && g:QFixHowm_ScheduleSearchDir != ''
    let l:howm_dir = g:QFixHowm_ScheduleSearchDir
  elseif exists('g:qfixmemo_root')
    let l:howm_dir = g:qfixmemo_root
  elseif exists('g:QFixHowm_RootDir')
    let l:howm_dir = g:QFixHowm_RootDir
  elseif exists('g:qfixmemo_dir')
    let l:howm_dir = g:qfixmemo_dir
  elseif exists('g:howm_dir')
    let l:howm_dir = g:howm_dir
  else
    let l:howm_dir = '~'
  endif
  let prevPath = escape(getcwd(), ' ')
  silent! exe 'lchdir ' . escape(l:howm_dir, ' ')
  let file = fnamemodify(g:QFixHowm_HolidayFile, ':p')
  let file = substitute(file, '\\', '/', 'g')
  exe 'lchdir ' . prevPath
  let g:calendar_holidayfile = file
  return file
endfunction

" 指定n曜日の秒数
let s:DoW = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
function! s:GetCnvDoWTime(year, month, cnvdow, sft)
  let year = a:year
  let month = a:month
  let sft = a:sft
  let cnvdow = substitute(a:cnvdow, '[^0-9]', '', 'g')
  if cnvdow == 0 || cnvdow == ''
    let cnvdow = 1
  endif
  let dow = substitute(a:cnvdow, '[*0-9]', '', 'g')
  let fday = Date2Int(year, month, 1)
  let fdow = fday%7
  let day = fday - fdow
  let day += (cnvdow-1) * 7 + index(s:DoW, dow)
  let time = (day - g:DateStrftime) * 24 * 60 *60
  let month = strftime('%m', time)
  if fdow > index(s:DoW, dow)
    let time += 7*24*60*60
  endif
  if sft =~ '[-+]\d\+'
    let time += str2nr(sft)*24*60*60
  endif
  return time
endfunction

"=============================================================================
" サブメニューにカレンダー表示
"=============================================================================
if !exists('g:submenu_calendar_syntax')
  let g:submenu_calendar_syntax = 'howm_calendar'
endif
if !exists('g:submenu_calendar_lmargin')
  let g:submenu_calendar_lmargin = ''
endif
if !exists('g:qfixtempname')
  let g:qfixtempname = tempname()
endif
function! QFixMemoCalendar(dircmd, file, cnt, ...)
  let file = fnamemodify(g:qfixtempname, ':p:h') .'/'. a:file
  let winnr = bufwinnr(file)
  if winnr != -1
    exe winnr.'wincmd w'
    return
  endif
  let windir = a:dircmd
  let win = windir =~ 'vert'
  let winsize = 0 "winwidth(0)
  let pbufnr = bufnr('%')
  exe 'silent! ' . windir . ' ' . (winsize == 0 ? '' : string(winsize)) . 'split '
  silent! exe 'edit '.escape(file, ' ')
  setlocal buftype=nowrite
  setlocal bufhidden=hide
  setlocal nobuflisted
  setlocal noswapfile
  setlocal nowrap
  setlocal nonumber
  setlocal nomodifiable
  setlocal winfixwidth
  setlocal winfixheight
  let b:dircmd = windir
  let b:calendar_winfixheight = a:0
  call s:build(a:cnt)
  let winheight = line('$')
  let winwidth = 1 + strlen(g:submenu_calendar_lmargin) + 3*7 + 1
  let b:calendar_width = winwidth
  let cbufnr = bufnr('%')
  let b:calendar_resize = 0
  if a:0
    let b:calendar_resize = a:1 =~ 'resize' ? 1 :0
    call s:winfixheight(winheight)
    exe 'normal! '.winwidth ."\<C-W>|"
    " サブメニューと同時にウィンドウクローズするためのフック
    exe 'augroup SubmenuCalendar'.cbufnr
      au!
      exe 'au BufWinLeave * call <SID>SCBufWinLeave('.pbufnr.','.cbufnr.')'
    augroup END
  elseif win
    let b:calendar_resize = 1
    exe 'normal! '.winwidth ."\<C-W>|"
  else
    let b:calendar_resize = 1
    call s:winfixheight(winheight)
  endif
  " オートリサイズ
  exe 'augroup SubmenuCalendar'.cbufnr
    exe 'au BufEnter    * call <SID>SCBufEnter('.pbufnr.','.cbufnr.')'
  augroup END
  call search('\.')
  call search('\*')
  call <SID>syntax()
  call CalendarPost()

  nnoremap <silent> <buffer> q    :close<CR>
  nnoremap <silent> <buffer> >    :<C-u>call <SID>CR('>')<CR>
  nnoremap <silent> <buffer> <    :<C-u>call <SID>CR('<')<CR>
  nnoremap <silent> <buffer> i    :<C-u>call <SID>CR('<')<CR>
  nnoremap <silent> <buffer> o    :<C-u>call <SID>CR('>')<CR>
  nnoremap <silent> <buffer> r    :<C-u>call <SID>CR('r')<CR>
  nnoremap <silent> <buffer> t    :<C-u>call <SID>CR('.')<CR>
  nnoremap <silent> <buffer> .    :<C-u>call <SID>CR('.')<CR>
  nnoremap <silent> <buffer> <CR> :<C-u>call <SID>CR()<CR>
  " nnoremap <silent> <buffer> <Up>    :<C-u>call <SID>CR('up')<CR>
  " nnoremap <silent> <buffer> <Down>  :<C-u>call <SID>CR('down')<CR>
  nnoremap <silent> <buffer> <Right> :<C-u>call <SID>CR('>')<CR>
  nnoremap <silent> <buffer> <Left>  :<C-u>call <SID>CR('<')<CR>
  if a:0
    wincmd p
  endif
endfunction

function! s:CR(...)
  if count == 0
    let key = expand('<cWORD>')
    if key !~ '[<>./]\|\(^[A-Z][a-z]\{2}$\)'
      let key = expand('<cword>')
    endif
    let key =  a:0 ? a:1 :key
  elseif count < 32
    let key = count
  else
    echo 'QFixCalendar : invalid argument.'
    return
  endif
  if key =~ '<\|>'
    let b:month += key =~ '>' ? 1 : -1
    call s:build()
    call s:winfixheight(b:calendar_height)
    call search(key, 'c')
  elseif key =~ '^\d\+$'
    let save_cursor = getpos('.')
    call cursor(line('.'), col('$'))
    let [lnum, col] = searchpos('\d\{4}/\d\{2}', 'ncbW')
    call setpos('.', save_cursor)
    let lnum = lnum == 0 ? 1 : lnum
    let str = getline(lnum)
    let y = matchstr(str, '\d\{4}')
    let m = matchstr(str, '/\zs\d\{2}')
    " TODO:特殊バッファしかない場合はとなりへ
    if QFixWinnr() == -1
      let vert = b:dircmd =~ 'vert'
      let hjkl = b:dircmd =~ '\(^\|\s*\)\(rightb\|bel\|bo\)'
      if vert
        exe 'wincmd '. (hjkl ? 'h' : 'l')
      else
        exe 'wincmd '. (hjkl ? 'k' : 'j')
      endif
    endif
    exe 'call '.g:calendar_action.'(key, m, y, "", "")'
  elseif key =~ 'up\|down'
    let b:month += key =~ 'up' ? -1 : 1
    call s:build()
    call s:winfixheight(b:calendar_height)
    call search('\.', 'c')
  elseif key =~ '[./]\|\(^[A-Z][a-z]\{2}$\)\|\ctoday'
    let str = expand('<cWORD>') =~ '\*' ? '\.' : '\*'
    let b:year  = strftime('%Y')
    let b:month = strftime('%m')
    let b:day   = strftime('%d')
    call s:build()
    call s:winfixheight(b:calendar_height)
    call search(str, 'c')
  elseif key =~ 'r'
    let save_cursor = getpos('.')
    call s:build()
    call s:winfixheight(b:calendar_height)
    call setpos('.', save_cursor)
  endif
endfunction

function! s:build(...)
  let num = exists('b:calendar_count') ? b:calendar_count : 3
  let num = a:0 ? a:1 : num
  let b:calendar_count = num
  setlocal modifiable
  let glist = s:CalendarStr(num)
  if num > 1
    call extend(glist, CalendarBoard())
  endif
  let b:calendar_height = len(glist)
  silent! %delete _
  call setline(1, glist)
  call cursor(1, 1)
  exe 'normal! z-'
  setlocal nomodifiable
endfunction

if !exists('*CalendarBoard')
function CalendarBoard()
  let month = strftime('%m')
  let day   = strftime('%d')
  if day == 24 && month == 12
    return extend(['    Merry Xmas!', ''], g:calendar_footer)
  elseif day == 31 && month == 10
    return extend(['   Trick or Treat?', ''], g:calendar_footer)
  elseif day == 1 && month == 1
    return extend(['   Happy New Year!', ''], g:calendar_footer)
  elseif s:holiday
    " 休日
  endif
  return g:calendar_footer
endfunction
endif

let s:cal = '  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31'
let s:mruler = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
function! s:CalendarStr(...)
  let loop = a:0 ? a:1 : 1
  let glist = []
  let year  = exists('b:year' ) ? b:year  : strftime('%Y')
  let month = exists('b:month') ? b:month : strftime('%m')
  let day   = exists('b:day'  ) ? b:day   : strftime('%d')
  let time = (Date2Int(year, month, day)-g:DateStrftime) * 24*60*60
  let b:year  = strftime('%Y', time)
  let b:month = strftime('%m', time)
  let b:day   = strftime('%d', time)
  let month -= (loop > 2)
  for cnt in range(loop)
    let fday = Date2Int(year, month, 1)
    let time = (fday-g:DateStrftime) * 24*60*60
    let year  = strftime('%Y', time)
    let month = strftime('%m', time)
    let day   = strftime('%d', time)
    let str = s:cal
    let eom = s:EndOfMonth(year, month, 0)
    let str = substitute(str, printf('\s%2.2d', eom+1).'.*$', '', '')
    let fday = Date2Int(year, month, 1)
    let fdow = fday%7
    " 日曜が 0 から始める
    let fdow = fdow == 6 ? 0 : (fdow+1)
    for n in range(fdow)
      let str  = '   '.str
    endfor
    let ty = strftime('%Y')
    let tm = strftime('%m')
    let td = str2nr(strftime('%d'))
    for n in range(1, eom)
      if n == td && month == tm && year == ty
        let str = substitute(str, printf(' \(%2d\)', n), '\*\1', '')
        continue
      endif
      let hday = HolidayCheck(year, month, n)
      exe 'let id = '.g:calendar_sign.'(n, month, year)'
      if id != ''
        if g:calendar_mark =~ 'left-fit'
          let str = substitute(str, printf('%3d', n), printf('%3s', id.string(n)), '')
        elseif g:calendar_mark =~ 'right'
          let str = substitute(str, printf('%2d ', n), printf('%2d%s', n, id), '')
        else
          let str = substitute(str, printf('%3d', n), printf('%s%2d', id, n), '')
        endif
      endif
    endfor
    if month == str2nr(strftime('%m')) && year == strftime('%Y')
      let str = substitute(str, printf('.\(%2.2d\)', day), '\*\1', '')
    endif
    let str = substitute(str, '\(.\{21}\)', '\1|', 'g')
    let list = split(str, '|')
    call insert(list, ' Su Mo Tu We Th Fr Sa')
    let mruler = printf('  < . > %4.4d/%2.2d %s', year, month, s:mruler[month-1])
    call insert(list, mruler)
    call map(list, 'substitute(v:val, "^", g:submenu_calendar_lmargin, "")')
    let month += 1
    if loop > 1
      call extend(list, [''])
    endif
    call extend(glist, list)
  endfor
  return glist
endfunction

function! s:SCBufWinLeave(pbuf, cbuf)
  if expand('<abuf>') == a:pbuf
    exe 'bd '.a:cbuf
    exe 'augroup SubmenuCalendar'.a:cbuf
      au!
    augroup END
  elseif expand('<abuf>') == a:cbuf
    exe 'augroup SubmenuCalendar'.a:cbuf
      au!
    augroup END
    if bufname('%') == bufname(expand('<abuf>')+0)
      silent! close
    endif
  endif
endfunction

function! s:SCBufEnter(pbuf, cbuf)
  if expand('<abuf>') == a:cbuf
    if b:calendar_resize
      exe 'normal! '.b:calendar_width  ."\<C-W>|"
      call s:winfixheight(b:calendar_height)
    endif
    let save_cursor = getpos('.')
    call cursor(1, 1)
    exe 'normal! z-'
    call setpos('.', save_cursor)
  endif
endfunction

function! s:winfixheight(h)
  if b:calendar_winfixheight
    exe 'normal! '.a:h ."\<C-W>_"
  endif
endfunction

function! s:syntax()
  syn clear
  exe 'syn match CalSaturday display /.\%>'.(3*7+strlen(g:submenu_calendar_lmargin)-2).'v[+!$%&?]\? *\d\+$/'

  " today
  if g:calendar_mark =~ 'left-fit'
    syn match CalToday display "\s*\*\d\+"
    syn match CalMemo display "\s*[+!$%&?]\d\+"
  elseif g:calendar_mark =~ 'right'
    syn match CalToday display "\d\+\*\s*"
    syn match CalMemo display "\d\+[+!$%&?]\s*"
  else
    syn match CalToday display "\*\s*\d\+"
    syn match CalMemo display "[+!$%&?]\s*\d\+"
  endif

  " header
  syn match CalHeader display "[^ ]*\d\+\/\d\+ [A-Z].."

  " ruler
  syn match Type '<\+\s*\.\s*>\+'
  let s:vwruler = "Su Mo Tu We Th Fr Sa"
  exe 'syn match CalRulerNC "'.s:vwruler.'"'

  exe 'syn match CalSunday  display "'.'^'.g:submenu_calendar_lmargin.'[+!$%&?]\? \{,2}\d\+" contains=CalToday'

  hi def link CalNavi     Search
  hi def link CalSaturday Statement
  hi def link CalSunday   Type
  hi def link CalRuler    StatusLine
  hi def link CalRulerNC  StatusLineNC
  hi def link CalWeeknm   Comment
  hi def link CalToday    Directory
  hi def link CalHeader   Special
  hi def link CalMemo     PreProc
  exe 'runtime! syntax/'.g:submenu_calendar_syntax
endfunction

