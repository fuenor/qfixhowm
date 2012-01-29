"=============================================================================
"    Description: date & holiday library
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/qfixhowm
"=============================================================================
scriptencoding utf-8
let s:version = 100
" if exists('g:datelib_version') && g:datelib_version < s:version
"   let g:loaded_datelib_vim = 0
" endif
" if exists("g:loaded_datelib_vim") && g:loaded_datelib_vim && !exists('fudist')
"   finish
" endif
let g:datelib_version = s:version
let g:loaded_datelib_vim = 1
if v:version < 700 || &cp
  finish
endif

" strftime()基準の経過日数
function! datelib#Date2IntStrftime(year, month, day)
  return s:Date2Int(a:year, a:month, a:day) - g:DateStrftime
endfunction

" strftime()基準の曜日インデックス
" strftime()基準の経過日数から曜日インデックスを返すので g:DoWStrftime[idx] として使用する
" let idx = datelib#DoWIdxStrftime(datelib#Date2IntStrftime(year, month, day))
" let idx = datelib#DoWIdxStrftime(year, month, day)
function! datelib#DoWIdxStrftime(...)
  if a:0 == 1
    return (a:1 + g:DateStrftime)%7
  endif
  if a:0 == 3
    return (s:Date2Int(a:1, a:2, a:3)%7)
  endif
  return 0
endfunction

function! s:Date2Int(year, month, day)
  let year = a:year
  let month = a:month
  let day = a:day
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

" 曜日変換、シフトを行ったstrfime時間
" strftime()で使用可能
" cnvdow : 2*Mon, 3*Tue, etc.
" sft    : -1, +2, -Sun, +Wed, -Hol, etc.
function! datelib#StrftimeCnvDoWShift(year, month, day, cnvdow, sft)
  let year  = a:year
  let month = a:month
  let day   = a:day
  if day == 0
    let day = datelib#EndOfMonth(year, month, day)
  endif
  let sft   = a:sft

  let cnvdow = matchstr(a:cnvdow, '\(\d\s*\*\)\?\s*'.s:DoWregxp)
  if cnvdow == ''
    let dday = datelib#Date2IntStrftime(year, month, day)
    let time = dday * 24*60*60
  else
    let dow = substitute(cnvdow, '[*0-9]', '', 'g')
    let cnvdow = substitute(cnvdow, '[^0-9]', '', 'g')
    if cnvdow == 0 || cnvdow == ''
      let cnvdow = 1
    endif
    let fday = datelib#Date2IntStrftime(year, month, 1)
    let fdow = datelib#DoWIdxStrftime(fday)
    let dday = fday - fdow
    let dday += (cnvdow-1) * 7 + index(g:DoWStrftime, dow)
    let time = dday * 24*60*60
    let month = strftime('%m', time)
    if fdow > index(g:DoWStrftime, dow)
      let time += 7*24*60*60
    endif
  endif
  if sft =~ '[-+]\?\s*\d\+'
    let time += str2nr(sft)*24*60*60
  elseif sft =~ '[-+]\s*\c\(Hol\|Hdy\)'
    let t = str2nr(substitute(sft, '\c\(Hol\|Hdy\)', '1', '')) * 24*60*60
    while 1
      let y = strftime('%Y', time)
      let m = strftime('%m', time)
      let d = strftime('%d', time)
      let date = printf('%4.4d%2.2d%2.2d', y, m, d)
      if exists('s:holidaytbl[date]') == 0
        break
      endif
      let time += t
    endwhile
  elseif sft =~ '[-+]\s*'.s:DoWregxp
    let fday = time / (24*60*60)
    let fdow = datelib#DoWIdxStrftime(fday)
    if sft =~ g:DoWStrftime[fdow]
      let time += (sft =~ '+' ? 1 : -1) * 24*60*60
    endif
  endif
  return time
endfunction

" 月末
function! datelib#EndOfMonth(year, month, day)
  let year = a:year
  let month = a:month
  if month > 12
    let year += 1
    let month = month - 12
  endif
  let monthdays = [31,28,31,30,31,30,31,31,30,31,30,31]
  if (year%4 == 0 && year%100 != 0) || year%400 == 0
    let monthdays[1] = 29
  endif
  let day = a:day
  if monthdays[month-1] < day
    let day = monthdays[month-1]
  endif
  if day == 0
    let day = monthdays[month-1]
  endif
  return day
endfunction

" strftime()の基準年
if !exists('g:YearStrftime')
  let g:YearStrftime = 1970
endif
" strftime()の基準日数(1970-01-01)
if !exists('g:DateStrftime')
  let g:DateStrftime = s:Date2Int(g:YearStrftime, 1, 1)
endif
" 初週曜日(0000-01-01)
if !exists('g:DoWStrftime')
  let g:DoWStrftime = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
endif

"=============================================================================
" howmスタイル休日設定

" 休日定義ファイル
" https://sites.google.com/site/fudist/Home/qfixhowm#downloads
if !exists('g:calendar_holidayfile')
  " let g:calendar_holidayfile = '~/qfixmemo/Sche-Hd-0000-00-00-000000.howm'
  let g:calendar_holidayfile = ''
endif

""""""""""""""""""""""""""""""
" 指定日が休日かチェック
" 追加オプションがある場合、指定曜日は除く
" (主に日曜を排除するためにある)
""""""""""""""""""""""""""""""
function! datelib#HolidayCheck(year, month, day, ...)
  call datelib#MakeHolidayTable(a:year)
  let date = printf('%4.4d%2.2d%2.2d', a:year, a:month, a:day)
  if a:0
    let fday = datelib#Date2IntStrftime(a:year, a:month, a:day)
    let fdow = datelib#DoWIdxStrftime(fday)
    return (g:DoWStrftime[fdow] !~ a:1) * (exists('s:holidaytbl[date]') ? 1 : 0)
  endif
  return (exists('s:holidaytbl[date]') ? 1 : 0)
endfunction

""""""""""""""""""""""""""""""
" 少なくとも指定年の休日定義が含まれる辞書を返す
""""""""""""""""""""""""""""""
function! datelib#GetHolidayTable(year)
  call datelib#MakeHolidayTable(a:year)
  return s:holidaytbl
endfunction

" 指定年の予定を作成
let s:holidaytbl  = {}
let s:holidaydict = []
let s:usertbl  = {}
let s:userdict = []
function! datelib#MakeHolidayTable(year, ...)
  let hol = a:0
  for year in range(a:year-1, a:year+1)
    let yearid = year. (hol ? 'Hol' : '')
    if !exists('s:holidaytbl[yearid]')
      let s:holidaytbl[yearid] = '|exists|'
      if len(s:holidaydict) == 0
        let s:holidaydict = s:ReadScheduleFile(s:setholidayfile(), s:holidaytbl)
      endif
      call s:SetScheduleTable(year, s:holidaydict, s:holidaytbl, hol)
      if exists('g:calendar_userfile')
        if len(s:userdict) == 0
          let s:userdict = s:ReadScheduleFile(g:calendar_userfile, s:usertbl)
        endif
        call s:SetScheduleTable(year, s:userdict, s:usertbl, hol)
      endif
    endif
  endfor
endfunction

" 休日定義ファイルを読み込み
let s:DoWregxp = '\c\(Sun\|Mon\|Tue\|Wed\|Thu\|Fri\|Sat\|Hol\|Hdy\)'
function! s:ReadScheduleFile(files, table)
  let dict = []
  for file in a:files
    if !filereadable(file)
      continue
    endif
    let glist = readfile(file)
    if exists('g:qfixmemo_fileencoding')
      call map(glist, "iconv(v:val, g:qfixmemo_fileencoding, &enc)")
    endif
    let today = strftime('%Y%m%d')
    let sch_ext  = '-@!+~.'
    let sch_date = '^.\d\{4}.\d\{2}.\d\{2}.'
    let sch_dow  = s:DoWregxp
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
        if repeat == '' && sft !~ '\c\(Hol\|Hdy\)'
          let opt = (opt == '' || opt == 0) ? 1 : opt
          let time = datelib#StrftimeCnvDoWShift(year, month, day, cnvdow, sft)
          for i in range(opt)
            let date = strftime('%Y%m%d', time)
            let a:table[date] = text
            let time += 24*60*60
          endfor
          continue
        endif
      elseif cmd == '@@'
      elseif cmd == '@@@'
      else
        continue
      endif
      let hday = {'cmd':cmd, 'year':year, 'month':month, 'day':day, 'repeat':repeat, 'cnvdow':cnvdow, 'sft':sft, 'opt':opt, 'text':text}
      call add(dict, hday)
    endfor
  endfor
  return deepcopy(dict)
endfunction

function! s:setholidayfile()
  if g:calendar_holidayfile != ''
    let file = g:calendar_holidayfile
  elseif exists('g:QFixHowm_HolidayFile')
    let file = g:QFixHowm_HolidayFile
  else
    let file = 'Sche-Hd-0000-00-00-000000.*'
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
  let file = fnamemodify(file, ':p')
  exe 'lchdir ' . prevPath
  let file = substitute(expand(file), "\<NL>.*", '', '')
  let file = substitute(file, '\\', '/', 'g')
  return split(file, "\<NL>")
endfunction

function! s:SetScheduleTable(year, dict, table, hol)
  if len(a:dict)
    for d in a:dict
      if a:year < d['year']
        continue
      endif
      if !a:hol && d['sft'] =~ '\c\(Hol\|Hdy\)'
        continue
      elseif a:hol && d['sft'] !~ '\c\(Hol\|Hdy\)'
        continue
      endif
      if d['cmd'] == '@@@'
        let time = datelib#StrftimeCnvDoWShift(a:year, d['month'], d['day'], d['cnvdow'], d['sft'])
        let date = strftime('%Y%m%d', time)
        let a:table[date] = d['text']
        let opt = d['opt']
        let opt = (opt == '' || opt == 0) ? 1 : opt
        for i in range(opt)
          let date = strftime('%Y%m%d', time)
          let a:table[date] = d['text']
          let time += 24*60*60
        endfor
      elseif d['cmd'] == '@@'
        let opt = d['opt']
        let opt = (opt == '' || opt == 0) ? 1 : opt
        let start = a:year == d['year'] ? d['month'] : 1
        for month in range(start, 12)
          let time = datelib#StrftimeCnvDoWShift(a:year, month, d['day'], d['cnvdow'], d['sft'])
          for i in range(opt)
            let date = strftime('%Y%m%d', time)
            let a:table[date] = d['text']
            let time += 24*60*60
          endfor
        endfor
      elseif d['cmd'] == '@'
        " 単発予定は読み込み時に処理済み
        let opt = d['opt']
        let opt = (opt == '' || opt == 0) ? 1 : opt

        let smonth = a:year == d['year'] ? d['month'] : 1
        let sday   = a:year == d['year'] ? d['day']   : 1
        let repeat = d['repeat']
        let repeat = (repeat == '' || repeat <= 0) ? 1 : repeat
        let begin = datelib#Date2IntStrftime(d['year'], d['month'], d['day'])
        let begin += (repeat) * ((datelib#Date2IntStrftime(a:year, smonth, sday) - begin)/repeat)
        let time  = begin * 24*60*60
        let year  = strftime('%Y', time)
        let month = strftime('%m', time)
        let day   = strftime('%d', time)
        for rday in range(day, day+366, repeat)
          let time = datelib#StrftimeCnvDoWShift(year, month, rday, d['cnvdow'], d['sft'])
          for i in range(opt)
            let date = strftime('%Y%m%d', time)
            if stridx(date, a:year) != 0
              continue
            endif
            let a:table[date] = d['text']
            let time += 24*60*60
          endfor
        endfor
      else
        continue
      endif
    endfor
  endif
  return a:table
endfunction

