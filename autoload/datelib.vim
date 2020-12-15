"=============================================================================
"    Description: date & holiday library
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/qfixhowm
"=============================================================================
scriptencoding utf-8
let s:version = 101
" if exists('g:datelib_version') && g:datelib_version < s:version
"   let g:loaded_datelib_vim = 0
" endif
" if exists("g:loaded_datelib_vim") && g:loaded_datelib_vim && !exists('fudist')
"   finish
" endif
let g:datelib_version = s:version
let g:loaded_datelib_vim = 1
if v:version < 700
  finish
endif

" strftime()の基準年
if !exists('g:YearStrftime')
  let g:YearStrftime = 1970
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
  elseif sft =~ '[-+]\s*\c\(Hol\|Hdy\|Wdy\|Holiday\|Weekday\)'
    let t = str2nr(substitute(sft, '\c\(Hol\|Hdy\|Wdy\|Holiday\|Weekday\)', '1', '')) * 24*60*60
    while 1
      let y = strftime('%Y', time)
      let m = strftime('%m', time)
      let d = strftime('%d', time)
      let date = printf('%4.4d%2.2d%2.2d', y, m, d)

      if ((exists('s:holidaytbl[date]') == 0) && (sft !~ '\c\(Weekday\|Wdy\)' || (s:Date2Int(y, m, d) % 7) != 5))
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

" strftime()の基準日数(1970-01-01)
if !exists('g:DateStrftime')
  let g:DateStrftime = s:Date2Int(g:YearStrftime, 1, 1)
endif
" 初週曜日(0001-01-01)
if !exists('g:DoWStrftime')
  let g:DoWStrftime = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
endif

"=============================================================================
" howmスタイル休日設定

" 休日定義ファイル
if !exists('g:calendar_holidayfile')
  " let g:calendar_holidayfile = '~/qfixmemo/Sche-Hd-0000-00-00-000000.howm'
  let g:calendar_holidayfile = ''
endif
" 休日定義ファイルのfileencoding は自動判定されるがBOMは扱えない。
" BOM付きファイルエンコーディングを使用する場合は
" let g:calendar_holidayfile_fileencoding = 'auto'
" のように指定する。
" ただしcalendar_holidayfile_fileencodingを指定すると画面が乱れる場合がある。

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
  return deepcopy(s:holidaytbl)
endfunction

if !exists('g:DL_SundayStr')
  let g:DL_SundayStr = '日曜日'
endif
if !exists('g:DL_SubstituteHolidayStr')
  let g:DL_SubstituteHolidayStr = '振替休日'
endif
if !exists('g:DL_SubstituteHolidayReg')
  let g:DL_SubstituteHolidayReg = g:DL_SundayStr
endif
if !exists('g:DL_VernalEquinoxStr')
  let g:DL_VernalEquinoxStr = '春分の日'
endif
if !exists('g:DL_AutumnEquinoxStr')
  let g:DL_AutumnEquinoxStr = '秋分の日'
endif
" 春分/秋分
let g:DL_Equinox = 0
" 振替休日
let g:DL_SubstituteHoliday = 0


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
      call s:SetEquinox(year, s:holidaytbl)
      call s:Furikae(year, s:holidaytbl)
      if exists('g:calendar_userfile')
        if len(s:userdict) == 0
          let s:userdict = s:ReadScheduleFile(g:calendar_userfile, s:usertbl)
        endif
        call s:SetScheduleTable(year, s:userdict, s:usertbl, hol)
      endif
    endif
  endfor
endfunction

if !exists('g:qfixtempname')
  let g:qfixtempname = tempname()
endif

" 休日定義ファイルを読み込み
let s:DoWregxp = '\c\(Sun\|Mon\|Tue\|Wed\|Thu\|Fri\|Sat\|Hol\|Hdy\|Wdy\|Holiday\|Weekday\)'
function! s:ReadScheduleFile(files, table)
  let dict = []
  for file in a:files
    if !filereadable(file)
      continue
    endif
    let glist = s:readfile(file)
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
      if month == 0 && day == 0
        if str =~ '^\s*@\d*\s*Sunday\s*=\s*'
          " 現時点では未使用
          let g:DL_SundayStr = substitute(str, '^.*=\s*\|\s*$', '', 'g')
        elseif str =~ '^\s*@\d*\s*Substitute\s*=\s*'
          let g:DL_SubstituteHolidayStr = substitute(str, '^.*=\s*\|\s*$', '', 'g')
        elseif str =~ '^\s*@\d*\s*'.g:DL_VernalEquinoxStr || str =~ '^\s*@\d*\s*'.g:DL_AutumnEquinoxStr
          let g:DL_Equinox = year > 0 ? year : 1
        elseif str =~ '^\s*@\d*\s*'.g:DL_SubstituteHolidayStr
          if str =~ '=\s*[^\s]\+\s*$'
            let g:DL_SubstituteHolidayReg = substitute(str, '^.*=\s*\|\s*$', '', 'g')
          endif
          let g:DL_SubstituteHoliday = year > 0 ? year : 1
        endif
        continue
      endif
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

function! s:readfile(file)
  let file = a:file
  let list = readfile(file)

  " BOMに対応しないファイルエンコーディング簡易判定
  let fromenc = split(&fencs, ',')
  let to = "utf-8"
  for from in fromenc
    if from =~? to || from =~? 'ucs-bom\|default\|latin'
      continue
    endif
    let tlist = deepcopy(list)
    call map(tlist, 'iconv(v:val, from, to)')
    let flist = deepcopy(tlist)
    call map(flist, 'iconv(v:val, to, from)')
    if flist == list
      return map(list, 'iconv(v:val, from, &enc)')
    endif
  endfor

  if exists('g:calendar_holidayfile_fileencoding') && g:calendar_holidayfile_fileencoding != ''
    return s:readfilebuf(a:file)
  endif

  " BOM付きの場合は一行目がBOM付きのまま渡される。
  return map(list, 'iconv(v:val, "utf-8", &enc)')
endfunction

function! s:readfilebuf(file)
  silent! let prevPath = s:escape(getcwd(), ' ')
  " 高速化のためテンポラリバッファを使用
  silent! exe 'silent! botright split '.g:qfixtempname
  silent! setlocal bt=nofile bh=hide noswf nobl
  let file = a:file
  let tlist = []
  silent! 1,$delete _
  let cmd = '0read '
  let opt = ''
  silent! exe cmd . ' ' . opt .' '. s:escape(file, ' ')
  let tlist = getline(1, '$')
  silent! close
  silent! exe 'chdir ' . prevPath
  return tlist
endfunction

function! s:setholidayfile()
  if g:calendar_holidayfile != ''
    let file = g:calendar_holidayfile
  elseif exists('g:QFixHowm_HolidayFile') && g:QFixHowm_HolidayFile != ''
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
  let prevPath = s:escape(getcwd(), ' ')
  silent! exe 'chdir ' . s:escape(l:howm_dir, ' ')
  let file = fnamemodify(file, ':p')
  exe 'chdir ' . prevPath
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
      if !a:hol && d['sft'] =~ '\c\(Hol\|Hdy\|Wdy\|Holiday\|Weekday\)'
        continue
      elseif a:hol && d['sft'] !~ '\c\(Hol\|Hdy\|Wdy\|Holiday\|Weekday\)'
        continue
      endif
      if d['cmd'] == '@@@'
        let time = datelib#StrftimeCnvDoWShift(a:year, d['month'], d['day'], d['cnvdow'], d['sft'])
        let date = strftime('%Y%m%d', time)
        let text = substitute(d['text'], '\s*&\[\d\{4}[-/]\d\{2}[-/]\d\{2}\]\.', '', 'g')
        let etime = s:endstr2time(d['text'])
        if (etime > 0) && (time > etime)
          continue
        endif
        let opt = d['opt']
        let opt = (opt == '' || opt == 0) ? 1 : opt
        for i in range(opt)
          let date = strftime('%Y%m%d', time)
          let a:table[date] = text
          let time += 24*60*60
        endfor
      elseif d['cmd'] == '@@'
        let opt = d['opt']
        let opt = (opt == '' || opt == 0) ? 1 : opt
        let start = a:year == d['year'] ? d['month'] : 1
        let text = substitute(d['text'], '\s*&\[\d\{4}[-/]\d\{2}[-/]\d\{2}\]\.', '', 'g')
        let etime = s:endstr2time(d['text'])
        for month in range(start, 12)
          let time = datelib#StrftimeCnvDoWShift(a:year, month, d['day'], d['cnvdow'], d['sft'])
          if (etime > 0) && (time > etime)
            continue
          endif
          for i in range(opt)
            let date = strftime('%Y%m%d', time)
            let a:table[date] = text
            let time += 24*60*60
          endfor
        endfor
      elseif d['cmd'] == '@'
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
        let time = datelib#StrftimeCnvDoWShift(year, month, day, d['cnvdow'], d['sft'])
        let date = strftime('%Y%m%d', time)
        let a:table[date] = d['text']
      else
        continue
      endif
    endfor
  endif
  return a:table
endfunction

function! s:endstr2time(str)
  let enddate = substitute(matchstr(a:str, '&\[\d\{4}[-/]\d\{2}[-/]\d\{2}\]\.'), '[^0-9]', '', 'g')
  if enddate == ''
    return -1
  endif
  let etime = datelib#Date2IntStrftime(strpart(enddate, 0, 4), strpart(enddate, 4, 2), strpart(enddate, 6, 2)) *24*60*60
  return etime
endfunction

function! s:SetEquinox(year, table)
  if g:DL_Equinox  == 0 || a:year < g:DL_Equinox || a:year < g:YearStrftime
    return
  endif

  let year = a:year
  let mod = year % 4

  let text = g:DL_VernalEquinoxStr
  let month = 3
  if mod == 0
    if year >= 1900 && year <= 1956
      let day = 21
    elseif year >= 1960 && year <= 2088
      let day = 20
    elseif year >= 2092 && year <= 2096
      let day = 19
    endif
  elseif mod == 1
    if year >= 1901 && year <= 1989
      let day = 21
    elseif year >= 1993 && year <= 2097
      let day = 20
    endif
  elseif mod == 2
    if year >= 1902 && year <= 2022
      let day = 21
    elseif year >= 2026 && year <= 2098
      let day = 20
    endif
  elseif mod == 3
    if year >= 1903 && year <= 1923
      let day = 22
    elseif year >= 1927 && year <= 2055
      let day = 21
    elseif year >= 2059 && year <= 2099
      let day = 20
    endif
  endif
  let date = printf('%4.4d%2.2d%2.2d', year, month, day)
  let a:table[date] = text

  let text = g:DL_AutumnEquinoxStr
  let month = 9
  if mod == 0
    if year >= 1900 && year <= 2008
      let day = 23
    elseif year >= 2012 && year <= 2096
      let day = 22
    endif
  elseif mod == 1
    if year >= 1901 && year <= 1917
      let day = 24
    elseif year >= 1921 && year <= 2041
      let day = 23
    elseif year >= 2045 && year <= 2097
      let day = 22
    endif
  elseif mod == 2
    if year >= 1902 && year <= 1946
      let day = 24
    elseif year >= 1950 && year <= 2074
      let day = 23
    elseif year >= 2078 && year <= 2098
      let day = 22
    endif
  elseif mod == 3
    if year >= 1903 && year <= 1979
      let day = 24
    elseif year >= 1983 && year <= 2099
      let day = 23
    endif
  endif
  let date = printf('%4.4d%2.2d%2.2d', year, month, day)
  let a:table[date] = text
endfunction

function! s:Furikae(year, table)
  if g:DL_SubstituteHoliday < 0 || a:year < g:DL_SubstituteHoliday || a:year < g:YearStrftime
    return
  endif
  let year = a:year
  for [key, value] in items(a:table)
    if key !~ '^'.year.'\d\{2}\d\{2}' || value =~ g:DL_SubstituteHolidayReg
      continue
    endif
    let month = strpart(key, 4, 2)
    let day = strpart(key, 6, 2)
    if s:Date2Int(year, month, day) % 7 != 6
      continue
    endif

    " 日曜なので振替
    let i = 0
    while 1
      let time = datelib#Date2IntStrftime(year, month, day+i)*24*60*60
      let date = strftime('%Y%m%d', time)
      if !exists('a:table[date]')
        break
      endif
      let i += 1
    endwhile
    let a:table[date] = g:DL_SubstituteHolidayStr
  endfor
endfunction

function! s:escape(str, chars)
  return escape(a:str, a:chars.((has('win32')|| has('win64')) ? '#%&' : '#%$'))
endfunction

