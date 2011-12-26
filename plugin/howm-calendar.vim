" 本体は autoload/howm_calendar.vim
if !exists('g:howm_calendar_wincmd')
  let g:howm_calendar_wincmd = 'vertical topleft'
endif
if !exists('g:howm_calendar_count')
  let g:howm_calendar_count = 3
endif
if !exists(':Calendar')
  command! -nargs=* Calendar call Calendar(0,<f-args>) | call CalendarPost()
  function Calendar(...)
    call howm_calendar#QFixMemoCalendar(g:howm_calendar_wincmd, '__Calendar__', g:howm_calendar_count)
  endfunction
else
  " calendar.vimを使用している場合は休日表示用にデフォルトで読み込み
  call howm_calendar#init()
endif

