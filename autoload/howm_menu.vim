"=============================================================================
"    Description: howm menu for qfixmemo
"         Author: fuenor <fuenor@gmail.com>
"        Version: 1.00
"=============================================================================
scriptencoding utf-8

if exists('g:loaded_HowmMenu') && g:loaded_HowmMenu && !exists('fudist')
  finish
endif
let g:loaded_HowmMenu = 1
if v:version < 700
  finish
endif

if !exists('g:HowmFiles_Sort')
  let g:HowmFiles_Sort = ''
endif

if !exists('g:QFixHowm_MenuCloseOnJump')
  let g:QFixHowm_MenuCloseOnJump = 1
endif
if !exists('g:QFixHowm_MenuHeight')
  let g:QFixHowm_MenuHeight = 0
endif
if !exists('g:QFixHowm_MenuWidth')
  let g:QFixHowm_MenuWidth = 0
endif
if !exists('g:QFixHowm_MenuWrap')
  let g:QFixHowm_MenuWrap = 0
endif
if !exists('g:QFixHowm_MenuPreview')
  let g:QFixHowm_MenuPreview = 0
endif
if !exists('g:QFixHowm_MenuCmd')
  let g:QFixHowm_MenuCmd = ''
endif
if !exists('g:QFixHowm_MenuWinCmd')
  let g:QFixHowm_MenuWinCmd = 'edit'
endif
if !exists('g:QFixHowm_MenuKey')
  let g:QFixHowm_MenuKey = 1
endif
if !exists('g:QFixHowm_MenuCalendar')
  let g:QFixHowm_MenuCalendar = 1
endif
if !exists('g:QFixHowm_MenuPreviewEnable')
  let g:QFixHowm_MenuPreviewEnable = 1
endif
if !exists('g:QFixHowm_Menu_winfixheight')
  let g:QFixHowm_Menu_winfixheight = 1
endif
if !exists('g:QFixHowm_Menu_winfixwidth')
  let g:QFixHowm_Menu_winfixwidth = 0
endif
if !exists('g:QFixHowm_MenuHeightMode')
  let g:QFixHowm_MenuHeightMode = 0
endif

let s:howmsuffix = 'howm'
let s:filehead = '\(howm\|sche\)://'
let s:calender_exists = 0

"メニューファイルディレクトリ
if !exists('g:QFixHowm_MenuDir')
  let g:QFixHowm_MenuDir = ''
  if exists('g:qfixmemo_menu_title')
    let g:QFixHowm_MenuDir  = fnamemodify(g:qfixmemo_menu_title, ':h')
  endif
endif
"メニューファイル名
if !exists('g:QFixHowm_Menufile')
  let g:QFixHowm_Menufile = 'Menu-00-00-000000.'.s:howmsuffix
  if exists('g:qfixmemo_menu_title')
    let g:QFixHowm_Menufile = fnamemodify(g:qfixmemo_menu_title, ':t')
  endif
endif
" メニュー画面に表示する MRUリストのエントリ数
if !exists('g:QFixHowm_MenuRecent')
  let g:QFixHowm_MenuRecent = 5
  if exists('g:qfixmemo_random_columns')
    let g:QFixHowm_MenuRecent = g:qfixmemo_random_columns
  endif
endif
if !exists('g:QFix_UseLocationList')
  let g:QFix_UseLocationList = 0
endif

""""""""""""""""""""""""""""""
augroup HowmFiles
  au!
  au BufWinEnter __HOWM_MENU__ call <SID>BufWinEnterMenu(g:QFixHowm_MenuPreviewEnable, s:filehead)
  au BufWinLeave __HOWM_MENU__ call <SID>BufWinLeaveMenu()
  au BufEnter    __HOWM_MENU__ call <SID>BufEnterMenu()
  au BufLeave    __HOWM_MENU__ call <SID>BufLeaveMenu()
  au CursorHold  __HOWM_MENU__ call <SID>PreviewMenu(s:filehead)
  exe 'au BufNewFile,BufRead '.g:QFixHowm_Menufile.' let b:qfixmemo_bufwrite_pre = 0'
augroup END

function! s:TogglePreview(...)
  let b:PreviewEnable = !b:PreviewEnable
  if a:0
    " let g:QFixHowm_MenuPreview = b:PreviewEnable
  else
    let g:QFixHowm_MenuPreviewEnable = b:PreviewEnable
  endif
  call QFixPclose(1)
  call s:keepsize()
endfunction

function! s:Getfile(lnum, ...)
  let l = a:lnum
  let str = getline(l)
  let dir = g:qfixmemo_dir
  if a:0
    let head = a:1
    if str !~ '^'.head
      return ['', 0]
    endif
    if g:QFixHowm_ScheduleSearchDir != '' && str =~ '^sche://'
      let dir = g:QFixHowm_ScheduleSearchDir
    endif
    let str = substitute(str, '^'.head, '', '')
  endif
  let file = substitute(str, '|.*$', '', '')
  silent! exe 'lchdir ' . escape(dir, ' ')
  let file = fnamemodify(file, ':p')
  if !filereadable(file)
    return ['', 0]
  endif
  let lnum = matchstr(str, '|\d\+\( col \d\+\)\?|')
  let lnum = matchstr(lnum, '\d\+')
  if lnum == ''
    let lnum = 1
  endif
  let file = substitute(file, '\\', '/', 'g')
  return [file, lnum]
endfunction

function! s:Search(cmd, ...)
  if a:0
    let _key = a:1
  else
    let mes = a:cmd == 'g' ? '(exclude)' : ''
    let _key = input('Search for pattern'.mes.' : ')
    if _key == ''
      return
    endif
  endif
  let @/=_key
  call s:Exec(a:cmd.'/'._key.'/d')
  call cursor(1, 1)
endfunction

function! s:SortExec(...)
  let mes = 'Sort type? (r:reverse)+(m:mtime, n:name, t:text, h:howmtime) : '
  if a:0
    let pattern = a:1
  else
    let pattern = input(mes, '')
  endif
  if pattern =~ 'r\?m'
    let g:QFix_Sort = substitute(pattern, 'm', 'mtime', '')
  elseif pattern =~ 'r\?n'
    let g:QFix_Sort = substitute(pattern, 'n', 'name', '')
  elseif pattern =~ 'r\?t'
    let g:QFix_Sort = substitute(pattern, 't', 'text', '')
  elseif pattern =~ 'r\?h'
    let g:QFix_Sort = substitute(pattern, 'h', 'howmtime', '')
  elseif pattern == 'r'
    let g:QFix_Sort = 'reverse'
  else
    return
  endif

  echo 'HowmFiles : Sorting...'
  let sq = []
  for n in range(1, line('$'))
    let [pfile, lnum] = s:Getfile(n)
    let text = substitute(getline(n), '[^|].*|[^|].*|', '', '')
    let mtime = getftime(pfile)
    let sepdat = {"filename":pfile, "lnum": lnum, "text":text, "mtime":mtime, "bufnr":-1}
    call add(sq, sepdat)
  endfor

  if g:QFix_Sort =~ 'howmtime'
    let sq = QFixHowmSort('howmtime', 0, sq)
    if pattern =~ 'r.*'
      let sq = reverse(sq)
    endif
    let g:QFix_Sort = 'howmtime'
  elseif g:QFix_Sort =~ 'mtime'
    let sq = s:Sort(g:QFix_Sort, sq)
  elseif g:QFix_Sort =~ 'name'
    let sq = s:Sort(g:QFix_Sort, sq)
  elseif g:QFix_Sort =~ 'text'
    let sq = s:Sort(g:QFix_Sort, sq)
  elseif g:QFix_Sort == 'reverse'
    let sq = reverse(sq)
  endif
  silent! exe 'lchdir ' . escape(g:qfixmemo_dir, ' ')
  let s:glist = []
  for d in sq
    let filename = fnamemodify(d['filename'], ':.')
    let line = printf("%s|%d| %s", filename, d['lnum'], d['text'])
    call add(s:glist, line)
  endfor
  setlocal modifiable
  silent! %delete _
  call setline(1, s:glist)
  setlocal nomodifiable
  call cursor(1, 1)
  redraw|echo 'Sorted by '.g:QFix_Sort.'.'
endfunction

function! s:Sort(cmd, sq)
  if a:cmd =~ 'mtime'
    let sq = sort(a:sq, "s:QFixCompareTime")
  elseif a:cmd =~ 'name'
    let sq = sort(a:sq, "s:QFixCompareName")
  elseif a:cmd =~ 'text'
    let sq = sort(a:sq, "s:QFixCompareText")
  endif
  if g:QFix_Sort =~ 'r.*'
    let sq = reverse(a:sq)
  endif
  let g:QFix_SearchResult = []
  return sq
endfunction

function! s:QFixCompareName(v1, v2)
  if a:v1.filename == a:v2.filename
    return (a:v1.lnum > a:v2.lnum?1:-1)
  endif
  return ((a:v1.filename) . a:v1.lnum> (a:v2.filename) . a:v2.lnum?1:-1)
endfunction

function! s:QFixCompareTime(v1, v2)
  if a:v1.mtime == a:v2.mtime
    if a:v1.filename != a:v2.filename
      return (a:v1.filename < a:v2.filename?1:-1)
    endif
    return (a:v1.lnum > a:v2.lnum?1:-1)
  endif
  return (a:v1.mtime < a:v2.mtime?1:-1)
endfunction

function! s:QFixCompareText(v1, v2)
  if a:v1.text == a:v2.text
    return (a:v1.filename < a:v2.filename?1:-1)
  endif
  return (a:v1.text < a:v2.text?1:-1)
endfunction

function! s:Cmd_RD(cmd, fline, lline)
  let [file, lnum] = s:Getfile(a:fline)
  if a:cmd == 'Delete'
    let mes = "!!! Delete file(s) !!!"
  elseif a:cmd == 'Remove'
    let mes = "!!! Remove to (".g:qfixmemo_dir.")"
  else
    return 0
  endif
  let choice = confirm(mes, "&Yes\n&Cancel", 2, "W")
  if choice != 1
    return 0
  endif
  for lnum in range(a:fline, a:lline)
    let [file, lnum] = s:Getfile(lnum)
    let dst = expand(g:qfixmemo_dir).'/'.fnamemodify(file, ':t')
    if a:cmd == 'Delete'
      call delete(file)
    elseif a:cmd == 'Remove'
      echoe 'Remove' fnamemodify(file, ':t')
      call rename(file, dst)
    endif
  endfor
  return 1
endfunction

function! s:Exec(cmd, ...) range
  let cmd = a:cmd
  if a:firstline != a:lastline
    let cmd = a:firstline.','.a:lastline.cmd
  endif
  if a:0
    if s:Cmd_RD(a:1, a:firstline, a:lastline) != 1
      return
    endif
  endif
  let mod = &modifiable ? '' : 'no'
  setlocal modifiable
  exe cmd
  exe 'setlocal '.mod.'modifiable'
endfunction

""""""""""""""""""""""""""""""
"メニュー画面
""""""""""""""""""""""""""""""
command! -count -nargs=* QFixHowmOpenMenuCache         call QFixHowmOpenMenu('cache')
command! -count -nargs=* QFixHowmOpenMenu              call QFixHowmOpenMenu()

let s:menubufnr = 0
function! howm_menu#Init()
endfunction

function! QFixHowmOpenMenu(...)
  call qfixmemo#Init()
  if count > 0
    let g:QFixHowm_ShowScheduleMenu = count
  endif
  redraw | echo 'QFixHowm : Open menu...'
  if exists('*QFixWinnr')
    let winnr = QFixWinnr()
    if winnr != -1
      exe winnr.'wincmd w'
    endif
  endif
  if &buftype == 'quickfix'
    silent! wincmd w
  endif
  let g:QFix_Disable = 1
  silent! let firstwin = s:GetBufferInfo()
  if g:QFixHowm_MenuDir == ''
    let mfile = g:qfixmemo_dir. '/'.g:QFixHowm_Menufile
  else
    let mfile = g:QFixHowm_MenuDir  . '/' . g:QFixHowm_Menufile
  endif
  let prevPath = escape(getcwd(), ' ')
  silent! exe 'lchdir ' . escape(g:qfixmemo_dir, ' ')
  let mfile = fnamemodify(mfile, ':p')
  silent! exe 'lchdir ' . prevPath
  let mfile = substitute(mfile, '\\', '/', 'g')
  let mfile = substitute(mfile, '/\+', '/', 'g')
  let mfilename = '__HOWM_MENU__'

  if !filereadable(mfile)
    let dir = fnamemodify(mfile, ':h')
    if isdirectory(dir) == 0 && dir != ''
      call mkdir(dir, 'p')
    endif
    let from = &enc
    let to   = g:qfixmemo_fileencoding
    call myhowm_msg#MenuInit()
    call map(g:QFixHowmMenuList, 'iconv(v:val, from, to)')
    call writefile(g:QFixHowmMenuList, mfile)
  endif
  let glist = qfixmemo#Readfile(mfile, g:qfixmemo_fileencoding)
  let use_reminder = count(glist, '%reminder')
  let use_recent   = count(glist, '%recent')
  let use_random   = count(glist, '%random')
  let from = g:qfixmemo_fileencoding
  let to   = &enc

  redraw|echo 'QFixHowm : Make mru list...'
  if use_recent
    let recent = QFixMRUGetList(g:qfixmemo_dir, g:QFixHowm_MenuRecent)
  endif
  if use_random
    redraw|echo 'QFixHowm : Read random cache...'
    let random = qfixmemo#RandomWalk(g:qfixmemo_random_file, 'qflist')
  endif
  let reminder = []
  if use_reminder
    redraw|echo 'QFixHowm : Make reminder cache...'
    let saved_ull = g:QFix_UseLocationList
    let g:QFix_UseLocationList = 1
    if a:0
      let reminder = QFixHowmListReminderCache("menu")
    else
      let reminder = QFixHowmListReminder("menu")
    endif
    let g:QFix_UseLocationList = saved_ull
  endif
  redraw|echo ''

  let menubuf = 0
  for i in range(1, winnr('$'))
    if fnamemodify(bufname(winbufnr(i)), ':t') == mfilename
      exe i . 'wincmd w'
      let menubuf = i
      let g:HowmMenuLnum = getpos('.')
      break
    endif
  endfor
  if s:menubufnr
    exe 'b '.s:menubufnr
  else
    if g:QFixHowm_MenuCmd != ''
      exe g:QFixHowm_MenuCmd
    endif
    silent! exe 'silent! '.g:QFixHowm_MenuWinCmd.' '.mfilename
    let s:menubufnr = bufnr('%')
  endif
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal modifiable
  exe 'setlocal fenc='.g:qfixmemo_fileencoding
  exe 'setlocal ff='.g:qfixmemo_fileformat
  let &winfixheight = g:QFixHowm_Menu_winfixheight
  let &winfixwidth  = g:QFixHowm_Menu_winfixwidth
  if g:QFixHowm_MenuWidth > 0
    exe "normal! ".g:QFixHowm_MenuWidth."\<C-W>|"
  endif
  if g:QFixHowm_MenuHeight > 0
    exe 'resize '. g:QFixHowm_MenuHeight
  endif
  silent! %delete _
  silent! exe 'silent! -1put=glist'
  silent! $delete _
  silent! exe 'lchdir ' . escape(g:qfixmemo_dir, ' ')
  call cursor(1, 1)
  if search('%menu%', 'cW') > 0
    let str = substitute(getline('.'), '%menu%', mfile, '')
    call setline(line('.'), str)
  endif
  call cursor(1, 1)
  if use_reminder
    call s:HowmMenuReplace(reminder, '^\s*%reminder', 'sche://')
  endif
  if use_recent
    call s:HowmMenuReplace(recent, '^\s*%recent', 'howm://')
  endif
  if use_random
    call s:HowmMenuReplace(random, '^\s*%random', 'howm://')
  endif
  call setpos('.', g:HowmMenuLnum)
  if exists("*QFixHowmOpenMenuPost")
    call QFixHowmOpenMenuPost()
  endif
  setlocal nomodifiable
  let g:QFixHowm_MenuKey = search('%".*"\[', 'ncw') ? g:QFixHowm_MenuKey : 0
  if g:QFixHowm_MenuKey
    call HowmMenuCmd_()
  endif
  if exists("*HowmMenuCmd")
    call HowmMenuCmd()
  endif
  if firstwin
    enew
    b #
  endif
  if bufwinnr('__Calendar__') == -1 && s:calender_exists == 0
    if g:QFixHowm_MenuCalendar
      call howm_calendar#QFixMemoCalendar(g:qfixmemo_calendar_wincmd, '__Calendar__', g:qfixmemo_calendar_count)
      let s:calender_exists = bufnr('__Calendar__')
      wincmd p
    endif
  elseif bufwinnr('__Calendar__') != -1
    " FIXME: s:HolidayVimgrep()中でlvimgrepを実行するとカレンダーが乱れる対策
    exe bufwinnr(bufnr('__Calendar__')) .'wincmd w'
    let save_cursor = getpos('.')
    call cursor(1, 1)
    exe 'normal! z-'
    call setpos('.', save_cursor)
    wincmd p
  endif
  let g:QFix_Disable = 0
endfunction

let s:first = 0
function! s:GetBufferInfo()
  if s:first
    return 0
  endif
  redir => bufoutput
  buffers
  redir END
  for buf in split(bufoutput, '\n')
    let bits = split(buf, '"')
    let b = {"attributes": bits[0], "line": substitute(bits[2], '\s*', '', '')}
    if bits[0] !~ '^\s*1\s' || bits[0] =~ '^\s*1\s*#'
      let s:first = 1
      return 0
    endif
  endfor
  return 1
endfunction

function! s:HowmMenuReplace(sq, rep, head)
  let glist = []
  for d in a:sq
    if exists('d["filename"]')
      let file = d['filename']
    else
      let file = bufname(d['bufnr'])
    endif
    let file = fnamemodify(file, ':.')
    let file = a:head.file
    let lnum = d['lnum'] < 1 ? 0 : d['lnum']
    call add(glist, printf("%s|%d| %s", file, lnum, d['text']))
  endfor
  let save_cursor = getpos('.')
  call cursor(1, 1)
  if search(a:rep, 'cW') > 0
    silent! delete _
    silent! exe 'silent! -1put=glist'
  endif
  call setpos('.', save_cursor)
endfunction

silent! function HowmMenuCmd_()
  call HowmMenuCmdMap(',')
  call HowmMenuCmdMap('r,')
  call HowmMenuCmdMap('I', 'H')
  call HowmMenuCmdMap('.', 'c')
  call HowmMenuCmdMap('u')
  call HowmMenuCmdMap('<Space>', ' ')
  call HowmMenuCmdMap('m')
  call HowmMenuCmdMap('o', 'l')
  call HowmMenuCmdMap('O', 'L')
  call HowmMenuCmdMap('A')
  call HowmMenuCmdMap('a')
  call HowmMenuCmdMap('ra')
  call HowmMenuCmdMap('s')
  call HowmMenuCmdMap('S', 'g')
  call HowmMenuCmdMap('<Tab>', 'y')
  call HowmMenuCmdMap('t')
  call HowmMenuCmdMap('ry')
  call HowmMenuCmdMap('rt')
  call HowmMenuCmdMap('rr')
  call HowmMenuCmdMap('rk')
  call HowmMenuCmdMap('rR')
  call HowmMenuCmdMap('rN')
  call HowmMenuCmdMap('rA')
  call HowmMenuCmdMap('R', 'rA')
endfunction

function! HowmMenuCmdMap(cmd, ...)
  let cmd = a:0 ? a:1 : a:cmd
  let cmd = ':call QFixHowmCmd("'.cmd.'")<CR>'
  exe 'silent! nnoremap <buffer> <silent> '.a:cmd.' '.cmd
endfunction

function! QFixHowmCmd(cmd)
  if g:qfixmemo_grep_cword
    let g:qfixmemo_grep_cword = -1
  endif
  let bufnr = bufnr('%')
  if a:cmd == ' '
    call qfixmemo#Edit(g:qfixmemo_diary)
  elseif a:cmd == 'c'
    call qfixmemo#EditNew()
  elseif a:cmd == 'u'
    call qfixmemo#Quickmemo()
  else
    let cmd = g:qfixmemo_mapleader.a:cmd
    call feedkeys(cmd, 'm')
  endif
  if g:QFixHowm_MenuCloseOnJump && a:cmd =~ '^[ cu]$'
    call <SID>HowmMenuClose(bufnr)
  endif
endfunction

function! s:HowmMenuClose(mbuf)
  let buf = bufnr('%')
  call s:CloseMenuPre()
  exe 'bd '.a:mbuf
  let winnr = bufwinnr(buf)
  exe winnr.'wincmd w'
endfunction

function! s:CloseMenuPre()
  call QFixPclose()
  call s:CloseCalendar()
endfunction

function! s:HowmMenuCR() range
  let save_cursor = getpos('.')
  if count
    call cursor(count, 1)
  endif
  call search('[^\s]', 'cb', line('.'))
  call search('[^\s]', 'cw', line('.'))
  let [lnum, fcol] = searchpos('%', 'ncb', line('.'))
  let [lnum, lcol] = searchpos(']', 'ncw', line('.'))
  let cmd = strpart(getline('.'), fcol, (lcol-fcol))
  let dcmd = matchstr(cmd, '"\s"\[[^ ]\+\]')
  if dcmd != ''
    let cmd = dcmd
  else
    let cmd = substitute(cmd, '\s\+.*$', '', '')
    let cmd = matchstr(cmd, '"[^ ]\+"\[[^ ]\+\]')
  endif
  if cmd != ''
    let cmd = substitute(matchstr(cmd, '".\+"'), '^"\|"$', '', 'g')
    if cmd =~ '^<.*>$'
      exe 'let cmd = '.'"\'.cmd.'"'
    endif
    call feedkeys(cmd, 'm')
    call setpos('.', save_cursor)
    return ''
  endif
  let [file, lnum] = s:Getfile('.', s:filehead)
  if !filereadable(file)
    call QFixMemoUserModeCR()
    return ''
  endif
  call QFixPclose()
  if g:QFixHowm_MenuCloseOnJump
    exe 'edit '.escape(file, ' %#')
  else
    if exists('*QFixEditFile')
      call QFixEditFile(file)
    else
      exe 'split '.escape(file, ' %#')
    endif
  endif
  call cursor(lnum, 1)
  exe 'normal! zz'
  return ''
endfunction

function! s:MenuCmd_J()
  let g:QFixHowm_MenuCloseOnJump = !g:QFixHowm_MenuCloseOnJump
  echo 'Close on jump : ' . (g:QFixHowm_MenuCloseOnJump? 'ON' : 'OFF')
endfunction

function! s:BufWinEnterMenu(preview, head)
  call QFixAltWincmdMap()
  let &wrap=g:QFixHowm_MenuWrap
  if !exists('b:PreviewEnable')
    let b:PreviewEnable = a:preview
  endif

  hi link QFMenuButton Special
  hi link QFMenuSButton Identifier
  exe 'set ft='.g:qfixmemo_filetype
  call qfixmemo#Syntax()
  runtime! syntax/howm_schedule.vim
  syn match txtUrl 'sche://'
  syn region QFMenuSButton start=+%"\zs+ end=+[^"]\+\ze"\[+ end='$'
  syn region QFMenuButton  start=+"\[\zs+ end=+[^\]]\+\ze\(\s\|]\)+ end='$'
  exe 'syn match mqfFileName "^'.a:head.'[^|]*"'.' nextgroup=qfSeparator'
  syn match qfSeparator "|" nextgroup=qfLineNr contained
  syn match qfLineNr    "[^|]*" contained contains=qfError
  syn match qfError     "error" contained

  hi link mqfFileName Directory
  hi link qfLineNr  LineNr
  hi link qfError Error
  call QFixHowmQFsyntax()

  nnoremap <buffer> <silent> J :<C-u>call <SID>MenuCmd_J()<CR>
  nnoremap <buffer> <silent> q :call <SID>Close()<CR>
  nnoremap <buffer> <silent> i :<C-u>call <SID>TogglePreview('menu')<CR>
  nnoremap <buffer> <silent> <CR> :<C-u>call <SID>HowmMenuCR()<CR>
  nnoremap <buffer> <silent> <2-LeftMouse> <ESC>:<C-u>call <SID>HowmMenuCR()<CR>
  silent! exe 'lchdir ' . escape(g:qfixmemo_dir, ' ')
  let s:howm_menu_height = winheight(0)
  let s:howm_menu_width = winwidth(0)
endfunction

function! s:BufWinLeaveMenu()
  call QFixPclose()
  let winnum = 1+(g:QFixHowm_MenuCalendar && (bufwinnr(s:calender_exists) != -1))
  if tabpagenr('$') > 1 && winnum > 1 && winnr('$') == winnum
    tabclose
  elseif tabpagenr('$') == 1 && winnr('$') == winnum
    call s:CloseCalendar()
    if bufname('%') == '__HOWM_MENU__'
      silent! b#
    endif
  else
    call s:CloseCalendar()
  endif
  let s:calender_exists = 0
endfunction

function! s:CloseCalendar()
  if g:QFixHowm_MenuCalendar && s:calender_exists > 0
    silent! exe 'bd '.s:calender_exists
    let s:calender_exists = -1
  endif
endfunction

function! s:Close()
  call QFixPclose()
  let winnum = 1+(g:QFixHowm_MenuCalendar && (bufwinnr(s:calender_exists) != -1))
  if tabpagenr('$') == 1 && winnr('$') == winnum
    silent! bprev
  else
    close
  endif
endfunction

let g:HowmMenuLnum = [0, 1, 1, 0]
function! s:BufEnterMenu()
  call s:keepsize()
endfunction

function! s:keepsize()
  let size = s:howm_menu_height
  if g:QFixHowm_MenuCalendar && s:calender_exists > 0 && g:qfixmemo_calendar_wincmd !~ 'vert'
    let size = s:howm_menu_height-10
  endif
  let w = &lines - winheight(0) - &cmdheight - (&laststatus > 0 ? 1 : 0)
  if w > 0
    exe 'resize' . size
  endif
  " exe 'vertical resize' . s:howm_menu_width
endfunction

function! s:BufLeaveMenu()
  if g:QFixHowm_MenuHeightMode
    let s:howm_menu_height = winheight(0)
    let s:howm_menu_width = winwidth(0)
  endif
  let g:HowmMenuLnum = getpos('.')
  if b:PreviewEnable
    call QFixPclose()
  endif
endfunction

function! s:PreviewMenu(head)
  if b:PreviewEnable < 1
    return
  endif
  let [file, lnum] = s:Getfile('.', a:head)
  if file == '' && g:QFixHowm_MenuPreview == 0
    call QFixPclose()
    call s:keepsize()
    return
  endif
  call QFixPreviewOpen(file, lnum)
endfunction

