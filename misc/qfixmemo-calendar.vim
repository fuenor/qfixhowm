"=============================================================================
"    Description: QFixMemo for calendar.vim
"         Author: fuenor <fuenor@gmail.com>
"  Last Modified: 0000-00-00 00:00
"=============================================================================
let s:Version = 1.00
scriptencoding utf-8

if exists('disable_QFixWin') && disable_QFixWin
  finish
endif
if exists('enable_QFixMemoCalendar') && !enable_QFixMemoCalendar
  finish
endif
if exists('disable_QFixMemo') && disable_QFixMemo
  finish
endif
if exists("loaded_QFixCalendar_vim") && !exists('fudist')
  finish
endif
let loaded_QFixCalendar_vim = 1
if v:version < 700 || &cp
  finish
endif

if !exists('calendar_action')
  " let calendar_action = "QFixMemoCalendarDiary"
endif
if !exists('calendar_sign')
  " let calendar_sign   = "QFixMemoCalendarSign"
endif

function! QFixMemoCalendarSign(day, month, year)
  let year  = printf("%4.4d",a:year)
  let month = printf("%2.2d",a:month)
  let day   = printf("%2.2d",a:day)
  let sfile = g:qfixmemo_diary . '.' . g:qfixmemo_ext
  let sfile = substitute(sfile, '%Y', year, 'g')
  let sfile = substitute(sfile, '%m', month, 'g')
  let sfile = substitute(sfile, '%d', day, 'g')
  let sfile = g:qfixmemo_dir . '/' . sfile
  return filereadable(sfile)
endfunction

function! QFixMemoCalendarDiary(day, month, year, week, dir)
  let year  = printf("%4.4d",a:year)
  let month = printf("%2.2d",a:month)
  let day   = printf("%2.2d",a:day)
  let hfile = g:qfixmemo_diary
  let hfile = substitute(hfile, '%Y', year, 'g')
  let hfile = substitute(hfile, '%m', month, 'g')
  let hfile = substitute(hfile, '%d', day, 'g')
  let sfile = hfile
  let winnr = bufwinnr(bufnr(sfile))
  let lwinnr = winnr('$')
  set winfixwidth
  wincmd w
  if filereadable(sfile)
    if winnr > -1
      exec winnr.'wincmd w'
    else
      exe "e " . escape(sfile, ' ')
    endif
  else
    call qfixmemo#Edit(hfile)
  endif
  if lwinnr == 1
    Calendar
    wincmd p
  endif
endfunction

