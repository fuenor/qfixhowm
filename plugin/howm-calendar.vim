"=============================================================================
"    Description: howm style scheduler - calendar.vim
"                 (要datelib.vim)
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/qfixhowm
"        Version: 2.00
"=============================================================================
scriptencoding utf-8
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
function! CalendarPost()
  if g:calendar_howm_syntax == 0
    return
  endif
  let ch = g:calendar_flag[2] . '_'
  exe 'syn match CalConceal /['.ch.']/ contained'
  let ch = g:calendar_flag[2] . g:calendar_flag[3]
  if g:calendar_mark =~ 'left-fit'
    exe 'syn match CalHoliday display "\s*['.ch.']\d*" contains=CalConceal'
  elseif g:calendar_mark =~ 'right'
    exe 'syn match CalHoliday display "\d*['.ch.']\s*" contains=CalConceal'
  else
    exe 'syn match CalHoliday display "['.ch.']\s*\d*" contains=CalConceal'
  endif
  " 今日が休日
  if datelib#HolidayCheck(strftime('%Y'), strftime('%m'), strftime('%d'), 'Sun')
    hi link CalToday CalHoliday
  endif
  hi link CalMemo    PreProc
  hi link CalSunday  WarningMsg
  exe 'hi def link CalHoliday '.g:calendar_CalHoliday
  hi def link CalConceal Ignore
endfunction

function! s:CalendarPost(win)
  augroup Calendar
    au!
    if a:win
      exe 'au BufEnter __Calendar resize '.winheight(0)
    else
      exe 'au BufEnter __Calendar vertical resize '.winwidth(0)
    endif
  augroup END
endfunction

function! QFixMemoCalendarSign(day, month, year, ...)
  let year  = printf("%4.4d",a:year)
  let month = printf("%2.2d",a:month)
  let day   = printf("%2.2d",a:day)
  let file = ''
  if exists('g:qfixmemo_diary') && exists('g:qfixmemo_dir')
    let file = g:qfixmemo_diary
    let ext = tolower(fnamemodify(file, ':e'))
    let ext = exists('g:qfixmemo_ext') ? g:qfixmemo_ext : ext
    if tolower(fnamemodify(file, ':e')) != g:qfixmemo_ext
      let file .= '.' . g:qfixmemo_ext
    endif
    let file = substitute(file, '%Y', year, 'g')
    let file = substitute(file, '%m', month, 'g')
    let file = substitute(file, '%d', day, 'g')
    let file = g:qfixmemo_dir.'/'.file
  endif
  if a:0
    return file
  endif
  let hday = datelib#HolidayCheck(a:year, a:month, a:day, 'Sun')
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
    silent! wincmd p
  endif
endfunction

"=============================================================================
if !exists("g:calendar_diary")
  let g:calendar_diary = "~/diary"
endif

function! s:CalendarDiary(day, month, year, week, dir)
  call confirm("diary plugin requiard.", 'OK')
endfunction

function! CalendarSign_(day, month, year)
  let sfile = g:calendar_diary."/".a:year."/".a:month."/".a:day.".cal"
  let hday = datelib#HolidayCheck(a:year, a:month, a:day, 'Sun')
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
"    Description: QFixMemo Calendar
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/qfixhowm
"=============================================================================
let s:Version = 1.03
scriptencoding utf-8
if v:version < 700 || &cp
  finish
endif

if exists('g:QFixMemoCalendar_version') && g:QFixMemoCalendar_version < s:Version
  let g:loaded_QFixMemoCalendar_vim = 0
endif
if exists("g:loaded_QFixMemoCalendar_vim") && g:loaded_QFixMemoCalendar_vim && !exists('fudist')
  finish
endif
let g:QFixMemoCalendar_version = s:Version
let g:loaded_QFixMemoCalendar_vim = 1

" 曜日表示
" 0 : 英語
" 1 : 日本語
" 2 : 日本語+陰暦
if !exists('g:calendar_jp')
  let g:calendar_jp = 2 * ($LANG =~ 'ja')
endif
" カレンダーボード
if !exists('g:calendar_footer')
  let g:calendar_footer = [
    \ '  {num}<CR> : Diary',
    \ '  ex. <CR> or 16<CR>',
    \ '  -----------------',
    \ '  <S-Left>|<S-Right>',
    \ '  -----------------',
    \ '   i  o : Prev/Next',
    \ '   <  > : Prev/Next',
    \ '    .   : Command',
    \ '    t   : Today',
    \ '    q   : Close',
    \ '    r   : Reload',
    \]
endif

" サブメニューにカレンダー表示
if !exists('g:submenu_calendar_syntax')
  let g:submenu_calendar_syntax = 'howm_calendar'
endif
if !exists('g:submenu_calendar_lmargin')
  let g:submenu_calendar_lmargin = ''
endif
if !exists('g:submenu_calendar_winfixheight')
  let g:submenu_calendar_winfixheight = 1
endif
if !exists('g:submenu_calendar_winfixwidth')
  let g:submenu_calendar_winfixwidth = 1
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
  let init = 0
  let windir = a:dircmd
  let win = windir =~ 'vert'
  let winsize = 0 "winwidth(0)
  let parent = 0
  if a:0 && a:1 =~ 'parent'
    let parent = 1
    let winsize = winwidth(0)
  endif
  let l:calendar_width = 3*7+strlen(g:submenu_calendar_lmargin)+1
  let l:calendar_width += g:calendar_mark =~ 'right'
  if parent == 0
    let winsize = l:calendar_width
  else
    let l:calendar_width = winwidth(0)
    let winsize = winwidth(0)
  endif
  let pbufnr = parent ? bufnr('%') : 0
  let b:calendar_pbuf = parent ? bufnr('%') : 0
  let saved_ei = &eventignore
  set eventignore=BufEnter,BufLeave
  exe 'silent! ' . windir . ' ' . (winsize == 0 ? '' : string(winsize)) . 'split '.escape(file, ' ')
  let &eventignore = saved_ei
  if !exists('b:calendar_width')
    let b:calendar_width = winsize
    let b:submenu_calendar_lmargin = g:submenu_calendar_lmargin
    let b:submenu_calendar_lmargin .= g:calendar_mark =~ 'right' ? ' ' : ''
    let init = 1
  endif
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal nobuflisted
  setlocal noswapfile
  setlocal nolist
  setlocal nowrap
  setlocal nonumber
  setlocal nomodifiable
  let &winfixheight = g:submenu_calendar_winfixheight
  let &winfixwidth  = g:submenu_calendar_winfixwidth
  setlocal foldcolumn=0
  let cbufnr = bufnr('%')
  if exists('g:QFix_PreviewUpdatetime')
    let b:qfixwin_updatetime = 1
    exe 'setlocal updatetime='.g:QFix_PreviewUpdatetime
  endif
  if a:0 && a:1 =~ 'parent'
    let calid = 1
    augroup CalMsgP
      au!
      exe 'au CursorHold '.a:file.' call <SID>Msg(1)'
    augroup END
    setlocal statusline=\ %{g:calendar_statusline1}
  else
    let calid = 0
    augroup CalMsg
      au!
      exe 'au CursorHold '.a:file.' call <SID>Msg(0)'
    augroup END
    setlocal statusline=\ %{g:calendar_statusline0}
  endif
  call s:build(a:cnt)
  let winheight = line('$')
  let b:dircmd = windir
  let b:calendar_winfixheight = a:0
  let b:calendar_resize = 0
  if parent
    let b:calendar_resize = parent + (a:1 =~ 'resize' ? 1 :0)
    call s:winfixheight(winheight)
    " サブメニューと同時にウィンドウクローズするためのフック
    exe 'augroup SubmenuCalendar'.cbufnr
      au!
      exe 'au BufWinLeave * call <SID>SCBufWinLeave('.pbufnr.','.cbufnr.')'
    augroup END
  elseif win
    let b:calendar_resize = 1
  else
    let b:calendar_resize = 1
    call s:winfixheight(winheight)
  endif
  " オートリサイズ
  exe 'augroup SubmenuCalendar'.cbufnr
    exe 'au BufEnter    * call <SID>SCBufEnter('.pbufnr.','.cbufnr.')'
  augroup END
  if init
    call search('\.')
    call search('\*')
  endif
  call <SID>syntax()
  call CalendarPost()
  if a:0 && a:1 =~ 'parent'
    call search('\*')
  endif
  call <SID>Msg(calid)

  nnoremap <silent> <buffer> q    :close<CR>
  nnoremap <silent> <buffer> >    :<C-u>call <SID>CR('>>')<CR>
  nnoremap <silent> <buffer> <    :<C-u>call <SID>CR('<<')<CR>
  nnoremap <silent> <buffer> i    :<C-u>call <SID>CR('<<')<CR>
  nnoremap <silent> <buffer> I    :<C-u>call <SID>CR('>>')<CR>
  nnoremap <silent> <buffer> o    :<C-u>call <SID>CR('>>')<CR>
  nnoremap <silent> <buffer> O    :<C-u>call <SID>CR('<<')<CR>
  nnoremap <silent> <buffer> r    :<C-u>call <SID>CR('r')<CR>
  nnoremap <silent> <buffer> t    :<C-u>call <SID>CR('today')<CR>
  nnoremap <silent> <buffer> .    :<C-u>call <SID>CR('.')<CR>
  nnoremap <silent> <buffer> <CR> :<C-u>call <SID>CR()<CR>
  " nnoremap <silent> <buffer> <Up>    :<C-u>call <SID>CR('up')<CR>
  " nnoremap <silent> <buffer> <Down>  :<C-u>call <SID>CR('down')<CR>
  nnoremap <silent> <buffer> <S-Up>    :<C-u>call <SID>CR('<<')<CR>
  nnoremap <silent> <buffer> <S-Down>  :<C-u>call <SID>CR('>>')<CR>
  nnoremap <silent> <buffer> <S-Right> :<C-u>call <SID>CR('>>')<CR>
  nnoremap <silent> <buffer> <S-Left>  :<C-u>call <SID>CR('<<')<CR>
  if a:0
    silent! wincmd p
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
  let save_cursor = getpos('.')
  call cursor(line('.'), col('$'))
  let [lnum, col] = searchpos('\d\{4}/\d\{2}', 'ncbW')
  call setpos('.', save_cursor)
  let lnum = lnum == 0 ? 1 : lnum
  let str = getline(lnum)
  let year  = matchstr(str, '\d\{4}')
  let month = matchstr(str, '/\zs\d\{2}')
  if key =~ '<\+\|>\+'
    let b:month += key =~ '>' ? 1 : -1
    call s:build()
    call s:winfixheight(b:calendar_height)
    let pl = line('.') - search(key, 'cnb')
    let nl = line('.') - search(key, 'cn')
    if abs(pl) <= abs(nl)
      call search(key, 'cb')
    else
      call search(key, 'c')
    endif
  elseif key =~ '^\d\+$'
    " 特殊バッファしかない
    if exists('*QFixWinnr') && QFixWinnr() == -1
      let vert = b:dircmd =~ 'vert'
      let hjkl = b:dircmd =~ '\(^\|\s*\)\(rightb\|bel\|bo\)'
      if vert
        exe (hjkl ? 'leftabove vsplit' : 'rightbelow vsplit ')
        bprev
      else
        exe (hjkl ? 'leftabove split' : 'rightbelow split')
        bprev
      endif
    endif
    exe 'call '.g:calendar_action.'(key, month, year, "", "")'
  elseif key =~ 'up\|down'
    let b:month += key =~ 'up' ? -1 : 1
    call s:build()
    call s:winfixheight(b:calendar_height)
    call search('\.', 'c')
  elseif a:0 && a:1 == '.'
    if expand('<cWORD>') =~ '\.'
      " call s:CR('today')
    else
      call search('\.', 'cb')
    endif
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
  let save_cursor = getpos('.')
  let num = exists('b:calendar_count') ? b:calendar_count : 3
  let num = a:0 ? a:1 : num
  let b:calendar_count = num
  setlocal modifiable
  let glist = s:CalendarStr(num)
  if num > 1
    call extend(glist, g:calendar_footer)
  endif
  let b:calendar_height = len(glist)
  silent! %delete _
  call setline(1, glist)
  if num > 1
    call cursor(1, 1)
    exe 'normal! z-'
    call setpos('.', save_cursor)
  endif
  setlocal nomodifiable
endfunction

let g:calendar_statusline0 = ''
let g:calendar_statusline1 = ''
function! s:Msg(id)
  let msg = CalendarInfo()
  exe "let g:calendar_statusline".a:id." = len(msg) == 0 ? '' : msg[0]"
  call map(msg, "substitute(v:val, '^', '_', '')")

  let save_cursor = getpos('.')
  setlocal modifiable
  let lnum = search('^\s*_', 'ncW')
  silent! exe '%s/^_.*/_/g'
  if lnum && len(msg) > 0
    call setline(lnum, msg[0])
  endif
  setlocal nomodifiable
  call setpos('.', save_cursor)
endfunction

if !exists('*CalendarInfo')
function CalendarInfo()
  if getline('.') =~ '< \. >'
    if expand('<cWORD>') == '<'
      return [' Prev Month']
    elseif expand('<cWORD>') == '.'
      return [' Today']
    elseif expand('<cWORD>') == '>'
      return [' Next Month']
    endif
    return []
  endif
  let save_cursor = getpos('.')
  call cursor(line('.'), col('$'))
  let [lnum, col] = searchpos('\d\{4}/\d\{2}', 'ncbW')
  call setpos('.', save_cursor)

  let lnum = lnum == 0 ? 1 : lnum
  let str = getline(lnum)
  let year  = matchstr(str, '\d\{4}')
  let month = matchstr(str, '/\zs\d\{2}')
  let day = expand('<cword>')

  if day == 24 && month == 12
    return [' Merry Xmas!']
  elseif day == 31 && month == 10
    return [' Trick or Treat?']
  elseif day == 1 && month == 1
    return [' Happy New Year!']
  endif

  let file = expand(QFixMemoCalendarSign(day, month, year, 'filename'))
  if filereadable(file)
    let info = readfile(file, '', 1)
    if exists('g:qfixmemo_fileencoding')
      call map(info, "iconv(v:val, g:qfixmemo_fileencoding, &enc)")
    endif
    return info
  endif

  let tbl = datelib#GetHolidayTable(year)
  let date = printf('%4.4d%2.2d%2.2d', year, month, day)
  if exists('tbl[date]') && tbl[date] != ''
    return [tbl[date]]
  endif
  return []
endfunction
endif

let s:cal = '  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31'
if !exists('g:calendar_dow')
  let g:calendar_dow   = ' Su Mo Tu We Th Fr Sa'
  if g:calendar_jp
    let g:calendar_dow = ' 日 月 火 水 木 金 土'
  endif
endif
if !exists('g:calendar_month')
  let g:calendar_month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
  if g:calendar_jp == 2
    let g:calendar_month = ['睦月', '如月', '弥生', '卯月', '皐月', '水無月', '文月', '葉月', '長月', '神無月', '霜月', '師走']
  endif
endif
function! s:CalendarStr(...)
  let loop = a:0 ? a:1 : 1
  let glist = []
  let year  = exists('b:year' ) ? b:year  : strftime('%Y')
  let month = exists('b:month') ? b:month : strftime('%m')
  let day   = exists('b:day'  ) ? b:day   : strftime('%d')
  let time = datelib#Date2IntStrftime(year, month, day) * 24*60*60
  let b:year  = strftime('%Y', time)
  let b:month = strftime('%m', time)
  let b:day   = strftime('%d', time)
  let month -= (loop > 2)
  for cnt in range(loop)
    let fday = datelib#Date2IntStrftime(year, month, 1)
    let time = fday * 24*60*60
    let year  = strftime('%Y', time)
    let month = strftime('%m', time)
    let day   = strftime('%d', time)
    let str = s:cal
    let eom = datelib#EndOfMonth(year, month, 0)
    let str = substitute(str, printf('\s%2.2d', eom+1).'.*$', '', '')
    if g:calendar_mark =~ 'right'
      let str = substitute(str, '^ ', '', '').' '
    endif
    let fdow = datelib#DoWIdxStrftime(fday)
    " 日曜から始める(0000/01/01は月曜)
    let fdow = fdow == 6 ? 0 : (fdow+1)
    for n in range(fdow)
      let str  = '   '.str
    endfor
    let ty = strftime('%Y')
    let tm = strftime('%m')
    let td = str2nr(strftime('%d'))
    for n in range(1, eom)
      exe 'let id = '.g:calendar_sign.'(n, month, year)'
      if n == td && month == tm && year == ty
        let id = '*'
      endif
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
    let str = substitute(str, '\(.\{21}\)', '\1|', 'g')
    let list = split(str, '|')
    exe 'let list[-1] .= printf("%'.(strlen(list[0])-strlen(list[-1])).'s", "")'
    call insert(list, g:calendar_dow)
    let mruler = printf(' < . > %4.4d/%2.2d %s', year, month, g:calendar_month[month-1])
    call insert(list, mruler)
    call map(list, 'substitute(v:val, "^", b:submenu_calendar_lmargin, "")')
    let month += 1
    if loop > 1
      call extend(list, ['_'])
    endif
    call extend(glist, list)
  endfor
  return glist
endfunction

function! s:SCBufWinLeave(pbuf, cbuf)
  if expand('<abuf>') == a:pbuf
    let winnr = bufwinnr(a:cbuf)
    if winnr != -1
      exe winnr.'wincmd w'
      silent! close
      silent! wincmd p
    endif
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
  if !exists('b:calendar_resize')
    return
  endif
  if expand('<abuf>') == a:cbuf
    if b:calendar_resize
      if exists('g:calendar_width_'.a:pbuf)
        exe "let b:calendar_width = g:calendar_width_".a:pbuf
      endif
      if winwidth(0) < b:calendar_width || b:calendar_resize " == 1
        exe 'vertical resize '.b:calendar_width
      endif
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
    exe 'resize '.a:h
  endif
endfunction

function! s:syntax()
  syn clear
  exe 'syn match CalSaturday display /\d\+.\?$/'

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
  syn match CalHeader display '< \. > \d\{4}/\d\{2} [^ ]\+' contains=CalCmd
  syn match CalCmd '< \. >' contained

  " ruler
  exe 'syn match CalRulerNC display  "'.substitute(g:calendar_dow, '^\s*\|\s*$', '', '').'"'
  exe 'syn match CalSunday  display "'.'^'.b:submenu_calendar_lmargin.' \?[+!$%&?]\? \{,2}\d\+" contains=CalToday'
  syn match CalInfo display '\s*_.*$' contains=CalConceal

  hi def link CalCmd      Type
  hi def link CalNavi     Search
  hi def link CalSaturday Statement
  hi def link CalSunday   Type
  hi def link CalRuler    StatusLine
  hi def link CalRulerNC  StatusLineNC
  hi def link CalWeeknm   Comment
  hi def link CalToday    Directory
  hi def link CalHeader   Special
  hi def link CalMemo     PreProc
  hi def link CalInfo     Identifier
  exe 'runtime! syntax/'.g:submenu_calendar_syntax
endfunction

