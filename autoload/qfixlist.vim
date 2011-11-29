"=============================================================================
"    Description: grep wrapper
"                   http://sites.google.com/site/fudist/Home/grep
"                 addtional : myqfix.vim (preview)
"                   http://sites.google.com/site/fudist/Home/grep
"         Author: fuenor <fuenor@gmail.com>
"=============================================================================
let s:Version = 2.85
scriptencoding utf-8

" What Is This:
"   This plugin is grep wrapper.
"
" Install:
"   Put this file into your runtime directory.
"     > vimfiles/plugin or .vim/plugin
"   * addtional myqfix.vim
"
"   Windows : if you have grep.exe, set mygrepprg.
"             findstr(default) can not search utf-8 fileencoding.
"             > .vimrc
"             let mygrepprg='path/to/grep'
"             let mygrepprg='grep'
"
"  Usage: qfixlist#getqflist(pattern, path, filepattern, {fileencoding})
"
"    :let qflist = qfixlist#getqflist('^int', '~/usr/mysrc', '*.cpp')
"    " **/ means recursive
"    :let qflist = qfixlist#getqflist('words', '~/usr/mytxt', '**/*', 'utf-8')
"
"    " QuickFix
"    :call qfixlist#copen(qflist, search_path)
"    " QFixList window
"    :call qfixlist#open(qflist, search_path)
"    also you can use setqflist()
"
"    cached list
"    " quickfix
"    :call qfixlist#copen()
"    " qfixlist window
"    :call qfixlist#open()
"
"    addtinal options
"    | function     | option                     |
"    | Grep         | :let MyGrep_Regexp     = 1 |
"    | FGrep        | :let MyGrep_Regexp     = 0 |
"    | Ignorecase   | :let MyGrep_Ignorecase = 1 |
"    | Recursive    | :let MyGrep_Recursive  = 1 |
"    * these options reset to default after qfixlist#getqflist()

"=============================================================================
if exists('g:disable_QFixList') && g:disable_QFixList == 1
  finish
endif
if exists('g:QFixList_version') && g:QFixList_version < s:Version
  let g:loaded_QFixList = 0
endif
if exists('g:loaded_QFixList') && g:loaded_QFixList && !exists('g:fudist')
  finish
endif
let g:QFixList_version = s:Version
let g:loaded_QFixList = 1
if v:version < 700 || &cp
  finish
endif
let s:debug = exists('g:fudist') ? g:fudist : 0

if !exists('g:qfixlist_wincmd')
  let g:qfixlist_wincmd = 'rightbelow split'
endif
if !exists('g:qfixlist_preview_enable')
  let g:qfixlist_preview_enable = 1
endif
if !exists('g:qfixlist_close_on_jump')
  let g:qfixlist_close_on_jump = 0
endif
if !exists('g:qfixlist_winfixheight')
  let g:qfixlist_winfixheight = 1
endif
if !exists('g:qfixlist_winfixwidth')
  let g:qfixlist_winfixwidth = 0
endif

if !exists('g:qfixlist_autoclose')
  let g:qfixlist_autoclose = 0
endif
if !exists('g:qfixlist_after_wincmd')
  let g:qfixlist_after_wincmd = ''
endif
if !exists('g:qfixlist_use_fnamemodify')
  let g:qfixlist_use_fnamemodify = 0
endif

function! qfixlist#getqflist(pattern, dir, file, ...)
  let fenc = a:0 ? a:1 : &enc
  return qfixlist#search(a:pattern, a:dir, '', 0, fenc, a:file)
endfunction

function! qfixlist#grep(pattern, dir, file, ...)
  let fenc = a:0 ? a:1 : &enc
  return qfixlist#search(a:pattern, a:dir, '', 0, fenc, a:file)
endfunction

function! qfixlist#copen(...)
  if a:0 > 0
    let s:QFixList_qfCache = deepcopy(a:1)
  endif
  if a:0 > 1
    let s:QFixList_qfdir = a:2
  endif
  if len(s:QFixList_qfCache) == 0
    if g:MyGrep_ErrorMes != ''
      echohl ErrorMsg
      redraw | echo g:MyGrep_ErrorMes
      let g:MyGrep_ErrorMes = ''
      echohl None
    else
      redraw | echo 'QFixList : Nothing in list!'
    endif
    return
  endif
  let g:QFix_SearchPath = s:QFixList_qfdir
  redraw | echo 'QFixList : Set QuickFix list...'
  call QFixPclose()
  call QFixSetqflist(s:QFixList_qfCache)
  call QFixCopen()
  if a:0
    call cursor(1, 1)
  endif
  redraw | echo ''
  if g:MyGrep_ErrorMes != ''
    echohl ErrorMsg
    redraw | echo g:MyGrep_ErrorMes
    let g:MyGrep_ErrorMes = ''
    echohl None
  endif
endfunction

function! qfixlist#open(...)
  if g:qfixlist_autoclose
    call QFixCclose()
  endif
  let loaded = 1
  if a:0 > 0
    let s:QFixList_Cache = deepcopy(a:1)
    let loaded = 0
  endif
  if a:0 > 1
    let s:QFixList_dir = a:2
  endif
  if len(s:QFixList_Cache) == 0
    echohl ErrorMsg
    if g:MyGrep_ErrorMes != ''
      redraw | echo g:MyGrep_ErrorMes
      let g:MyGrep_ErrorMes = ''
    else
      redraw | echo 'QFixList : Nothing in list!'
    endif
    echohl None
    return
  endif
  call QFixPclose(1)
  let path = s:QFixList_dir
  let file = fnamemodify(tempname(), ':p:h').'/__QFix_List__'
  let winnr = bufwinnr(file)
  if winnr != -1
    exe winnr . 'wincmd w'
    return
  else
    let aftercmd = ''
    let prevbuf = bufnr('%')
    if &buftype != ''
      for i in range(1, winnr('$'))
        exe i . 'wincmd w'
        if &buftype == ''
          break
        endif
      endfor
      if &buftype != ''
        exe bufwinnr(prevbuf) . 'wincmd w'
        let aftercmd = g:qfixlist_after_wincmd
      endif
    endif
    silent! exe 'silent! '.g:qfixlist_wincmd.' '.file
    if !exists('b:qfixlist_def_height')
      let b:qfixlist_def_height = winheight(0)
    endif
    if !exists('b:qfixlist_height')
      let b:qfixlist_height = winheight(0)
    endif
    exe aftercmd
  endif
  if loaded
    silent! exe 'lchdir ' . escape(s:QFixList_dir, ' ')
    return
  endif
  silent! exe 'lchdir ' . escape(path, ' ')
  setlocal buftype=nowrite
  setlocal bufhidden=hide
  setlocal noswapfile
  setlocal nobuflisted
  setlocal nowrap
  setlocal cursorline

  silent! exe 'lchdir ' . escape(s:QFixList_dir, ' ')

  let glist = []
  if g:qfixlist_use_fnamemodify == 0
    let head = fnamemodify(expand(s:QFixList_dir), ':p')
    let head = QFixNormalizePath(head)
    for n in s:QFixList_Cache
      if !exists("n['filename']")
        let n['filename'] = fnamemodify(bufname(n['bufnr']), ':p')
        let file = QFixNormalizePath(fnamemodify(n['filename'], ':.'))
      else
        let file = n['filename'][len(head):]
        " let file = substitute(file, '^'.head, '', '')
        " let file = fnamemodify(n['filename'], ':.')
      endif
      let lnum = n['lnum']
      let text = n['text']
      let res = file.'|'.lnum.'| '.text
      call add(glist, res)
    endfor
  else
    for n in s:QFixList_Cache
      let file = fnamemodify(n['filename'], ':.')
      let lnum = n['lnum']
      let text = n['text']
      let res = file.'|'.lnum.'| '.text
      call add(glist, res)
    endfor
  endif

  setlocal modifiable
  exe 'set fenc='.&enc
  silent! %delete _
  call setline(1, glist)
  setlocal nomodifiable
  if a:0
    call cursor(1, 1)
  else
    let b:qfixlist_lnum = exists('b:qfixlist_lnum') ? b:qfixlist_lnum : line('.')
    call cursor(b:qfixlist_lnum, 1)
  endif
  nnoremap <buffer> <silent> q :<C-u>call <SID>Close()<CR>
  nnoremap <buffer> <silent> <CR> :<C-u>call <SID>CR()<CR>
  " nnoremap <buffer> <silent> <F5> :<C-u>call <SID>reopen()<CR>

  nnoremap <buffer> <silent> i :<C-u>call <SID>TogglePreview()<CR>
  nnoremap <buffer> <silent> J :<C-u>call <SID>ListCmd_J()<CR>
  nnoremap <buffer> <silent> I :<C-u>call <SID>TogglePreview()<CR>
  nnoremap <buffer> <silent> D :call <SID>Exec('delete','Delete')<CR>
  nnoremap <buffer> <silent> R :call <SID>Exec('delete','Remove')<CR>
  vnoremap <buffer> <silent> D :call <SID>Exec('delete','Delete')<CR>
  vnoremap <buffer> <silent> R :call <SID>Exec('delete','Remove')<CR>
  nnoremap <buffer> <silent> S :<C-u>call <SID>SortExec()<CR>
  nnoremap <buffer> <silent> s :<C-u>call <SID>Search('g!')<CR>
  nnoremap <buffer> <silent> r :<C-u>call <SID>Search('g')<CR>
  nnoremap <buffer> <silent> dd :call <SID>Exec('delete')<CR>
  vnoremap <buffer> <silent> d :call <SID>Exec('delete')<CR>
  nnoremap <buffer> <silent> p :<C-u>call <SID>Exec('put')<CR>
  nnoremap <buffer> <silent> P :<C-u>call <SID>Exec('put!')<CR>
  nnoremap <buffer> <silent> u :<C-u>call <SID>Exec('undo')<CR>
  nnoremap <buffer> <silent> <C-r> :<C-u>call <SID>Exec("redo")<CR>

  " nnoremap <buffer> <silent> <C-g> :<C-u>call <SID>Cmd_Copy2QF()<CR>
  nnoremap <buffer> <silent> & :<C-u>call <SID>Cmd_Copy2QF()<CR>
  nnoremap <buffer> <silent> A :MyGrepWriteResult<CR>
  silent! nnoremap <buffer> <unique> <silent> o :MyGrepWriteResult<CR>
  nnoremap <buffer> <silent> O :MyGrepReadResult<CR>

  if g:MyGrep_ErrorMes != ''
    echohl ErrorMsg
    redraw | echo g:MyGrep_ErrorMes
    let g:MyGrep_ErrorMes = ''
    echohl None
    let g:MyGrep_ErrorMes = ''
  endif
endfunction

function! qfixlist#Sort(cmd, sq)
  if a:cmd =~ 'mtime'
    let sq = sort(a:sq, "s:CompareTime")
  elseif a:cmd =~ 'name'
    let sq = sort(a:sq, "s:CompareName")
  elseif a:cmd =~ 'bufnr'
    let sq = sort(a:sq, "s:CompareBufnr")
  elseif a:cmd =~ 'text'
    let sq = sort(a:sq, "s:CompareText")
  endif
  if a:cmd =~ 'r.*'
    let sq = reverse(a:sq)
  endif
  return sq
endfunction

function! qfixlist#GetList(cmd)
  if a:cmd == 'copen' || a:cmd == 'quickfix'
    return [s:QFixList_qfCache, s:QFixList_qfdir]
  else
    return [s:QFixList_Cache, s:QFixList_dir]
  endif
endfunction

function! qfixlist#search(pattern, dir, cmd, days, fenc, file)
  let cmd = a:cmd
  redraw | echo 'QFixList : execute grep...'
  if a:days
    let g:MyGrep_FileListWipeTime = localtime() - a:days*24*60*60
  endif
  let prevPath = escape(getcwd(), ' ')
  let g:MyGrep_Return = 1
  let list = qfixlist#MyGrep(a:pattern, a:dir, a:file, a:fenc, 0)

  redraw | echo 'QFixList : Formatting...'
  silent! exe 'lchdir ' . escape(expand(a:dir), ' ')
  if g:qfixlist_use_fnamemodify == 0
    let head = fnamemodify(expand(a:dir), ':p')
    let head = QFixNormalizePath(head)
    for d in list
      let file = head . d['filename']
      " let file = fnamemodify(d['filename'], ':p')
      let d['filename'] = substitute(file, '\\', '/', 'g')
      let d['lnum'] = d['lnum'] + 0
    endfor
  else
    for d in list
      let file = fnamemodify(d['filename'], ':p')
      let d['filename'] = substitute(file, '\\', '/', 'g')
      let d['lnum'] = d['lnum'] + 0
    endfor
  endif
  silent! exe 'lchdir ' . prevPath

  redraw | echo 'QFixList : Sorting...'
  if cmd =~ 'mtime'
    let bname = ''
    let bmtime = 0
    for d in list
      if bname == d.filename
        let d['mtime'] = bmtime
      else
        let d['mtime'] = getftime(d.filename)
      endif
      let bname  = d.filename
      let bmtime = d.mtime
    endfor
    let list = sort(list, "s:CompareTime")
  elseif cmd =~ 'name'
    let list = sort(list, "s:CompareName")
  elseif cmd =~ 'text'
    let list = sort(list, "s:CompareText")
  endif
  if a:cmd =~ 'r.*'
    let list = reverse(list)
  endif
  let s:QFixList_qfdir = a:dir
  let s:QFixList_qfCache = list
  redraw | echo ''
  return list
endfunction

""""""""""""""""""""""""""""""
function! s:CompareName(v1, v2)
  if a:v1.filename == a:v2.filename
    return (a:v1.lnum > a:v2.lnum?1:-1)
  endif
  return ((a:v1.filename).a:v1.lnum> (a:v2.filename).a:v2.lnum?1:-1)
endfunction

function! s:CompareTime(v1, v2)
  if a:v1.mtime == a:v2.mtime
    if a:v1.filename != a:v2.filename
      return (a:v1['filename'] < a:v2['filename']?1:-1)
    endif
    return (a:v1['lnum'] > a:v2['lnum']?1:-1)
  endif
  return (a:v1['mtime'] < a:v2['mtime']?1:-1)
endfunction

function! s:CompareText(v1, v2)
  if a:v1.text == a:v2.text
    return 0
  endif
  return (a:v1.text > a:v2.text?1:-1)
endfunction

function! s:CompareBufnr(v1, v2)
  if a:v1.bufnr == a:v2.bufnr
    return (a:v1.lnum > a:v2.lnum?1:-1)
  endif
  return a:v1.bufnr>a:v2.bufnr?1:-1
endfunction

""""""""""""""""""""""""""""""
" QFixFiles
""""""""""""""""""""""""""""""
augroup QFixFiles
  au!
  autocmd BufWinEnter __QFix_List__ call <SID>BufWinEnter(g:qfixlist_preview_enable)
  autocmd BufEnter    __QFix_List__ call <SID>BufEnter()
  autocmd BufLeave    __QFix_List__ call <SID>BufLeave()
  autocmd CursorHold  __QFix_List__ call <SID>Preview()
  autocmd BufWinEnter      quickfix call <SID>QFBufWinEnter('__QFix_List__')
augroup END

let s:QFixList_dir   = ''
let s:QFixList_qfdir = ''
let s:QFixList_Cache = []
let s:QFixList_qfCache = []
let g:MyGrep_ErrorMes = ''

function! s:QFBufWinEnter(name)
  nnoremap <buffer> <silent> <C-g> :call <SID>Cmd_QFixListQFcopy('normal')<CR>
  vnoremap <buffer> <silent> <C-g> :call <SID>Cmd_QFixListQFcopy('visual')<CR>
  if !g:qfixlist_autoclose
    return
  endif
  let winnr = bufwinnr(a:name)
  if winnr != -1
    exe winnr.'wincmd w'
    close
    silent! wincmd p
  endif
endfunction

function! s:Cmd_QFixListQFcopy(mode) range
  let lastline = line('$')
  let firstline = a:firstline
  if a:firstline != a:lastline || a:mode =~ 'visual'
    let lastline = a:lastline
  else
    let firstline = 1
  endif
  redraw | echo 'QFixList : Copying...'

  if exists('b:qfixwin_buftype')
    let qf = b:qfixwin_buftype ? getloclist(0) : getqflist()
  else
    let qf = QFixGetqflist()
  endif
  let path = exists('g:loaded_QFixWin') ? QFixGetqfRootPath(qf) : getcwd()
  if lastline != line('$')
    call remove(qf, lastline, -1)
  endif
  if firstline > 1
    call remove(qf, 0, firstline - 2)
  endif
  call qfixlist#open(qf, path)
  redraw | echo ''
endfunction

function! s:BufWinEnter(preview)
  let b:PreviewEnable = a:preview
  call QFixAltWincmdMap()
  let &winfixheight = g:qfixlist_winfixheight
  let &winfixwidth  = g:qfixlist_winfixwidth

  syn match	qfFileName	"^[^|]*" nextgroup=qfSeparator
  syn match	qfSeparator	"|" nextgroup=qfLineNr contained
  syn match	qfLineNr	"[^|]*" contained contains=qfError
  syn match	qfError		"error" contained

  " The default highlighting.
  hi def link qfFileName	Directory
  hi def link qfLineNr	LineNr
  hi def link qfError	Error

  silent! exe 'lchdir ' . escape(s:QFixList_dir, ' ')
endfunction

function! s:ListCmd_J()
  let g:qfixlist_close_on_jump = !g:qfixlist_close_on_jump
  echo 'Close on jump : ' . (g:qfixlist_close_on_jump? 'ON' : 'OFF')
endfunction

function! s:reopen()
  close
  call qfixlist#open()
endfunction

function! s:BufEnter()
  let w = &lines - winheight(0) - &cmdheight - (&laststatus > 0 ? 1 : 0)
  if w > 0
    " let b:qfixlist_height = b:qfixlist_height < b:qfixlist_def_height ? b:qfixlist_def_height : b:qfixlist_height
    if exists('b:qfixlist_height') && b:qfixlist_height
      exe 'resize '. b:qfixlist_height
    endif
  endif
  if exists('b:qfixlist_width') && b:qfixlist_width
    " exe 'vertical resize '. s:qfixlist_width
  endif
endfunction

function! s:BufLeave()
  let b:qfixlist_height = winheight(0)
  let b:qfixlist_width = winwidth(0)
  let b:qfixlist_lnum = line('.')
  if b:PreviewEnable
    call QFixPclose(1)
  endif
endfunction

function! s:Preview()
  if b:PreviewEnable < 1
    return
  endif

  let [file, lnum] = s:Getfile('.')
  call QFixPreviewOpen(file, lnum)
endfunction

function! s:TogglePreview(...)
  let b:PreviewEnable = !b:PreviewEnable
  let g:qfixlist_preview_enable = b:PreviewEnable
  if !b:PreviewEnable
    call QFixPclose(1)
  endif
endfunction

function! s:CR()
  if b:PreviewEnable
    call QFixPclose(1)
  endif
  let [file, lnum] = s:Getfile('.')
  if g:qfixlist_close_on_jump
    silent! close
    exe 'edit '.escape(file, ' %#')
  else
    call QFixEditFile(file)
  endif
  call cursor(lnum, 1)
  exe 'normal! zz'
endfunction

function! s:Close()
  if !exists('g:loaded_QFixWin')
    close
    return
  endif
  if winnr('$') == 1 || (winnr('$') == 2 && b:PreviewEnable == 1)
    if tabpagenr('$') > 1
      tabclose
    else
      silent! b #
      " silent! close
    endif
  else
    close
  endif
endfunction

function! s:Getfile(lnum, ...)
  let l = a:lnum
  let str = getline(l)
  if a:0
    let head = a:1
    if str !~ '^'.head
      return ['', 0]
    endif
    let str = substitute(str, '^'.head, '', '')
  endif
  let file = substitute(str, '|.*$', '', '')
  silent! exe 'lchdir ' . escape(s:QFixList_dir, ' ')
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
  let mes = 'Sort type? (r:reverse)+(m:mtime, n:name, t:text) : '
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
  elseif pattern == 'r'
    let g:QFix_Sort = 'reverse'
  else
    return
  endif

  echo 'QFixList : Sorting...'
  let sq = []
  for n in range(1, line('$'))
    let [pfile, lnum] = s:Getfile(n)
    let text = substitute(getline(n), '[^|].*|[^|].*|', '', '')
    let mtime = getftime(pfile)
    let sepdat = {"filename":pfile, "lnum": lnum, "text":text, "mtime":mtime, "bufnr":-1}
    call add(sq, sepdat)
  endfor

  if g:QFix_Sort =~ 'mtime'
    let sq = qfixlist#Sort(g:QFix_Sort, sq)
  elseif g:QFix_Sort =~ 'name'
    let sq = qfixlist#Sort(g:QFix_Sort, sq)
  elseif g:QFix_Sort =~ 'text'
    let sq = qfixlist#Sort(g:QFix_Sort, sq)
  elseif g:QFix_Sort == 'reverse'
    let sq = reverse(sq)
  endif
  silent! exe 'lchdir ' . escape(s:QFixList_dir, ' ')
  let s:glist = []
  for d in sq
    let filename = fnamemodify(d['filename'], ':.')
    let line = printf("%s|%d|%s", filename, d['lnum'], d['text'])
    call add(s:glist, line)
  endfor
  setlocal modifiable
  silent! %delete _
  call setline(1, s:glist)
  setlocal nomodifiable
  call cursor(1,1)
  redraw|echo 'Sorted by '.g:QFix_Sort.'.'
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

function! s:Cmd_Copy2QF()
  redraw|echo 'QFixList : Copying...'
  let s:QFixList_qfdir = s:QFixList_dir
  let s:QFixList_qfCache = s:QFixList_Cache
  call qfixlist#copen()
  call cursor(1, 1)
  echo ''
endfunction

if !exists('g:qfixmemo_dir')
  let g:qfixmemo_dir = '~/qfixmemo'
endif
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
    let dst = fnamemodify(g:qfixmemo_dir, ':p') . fnamemodify(file, ':t')
    if a:cmd == 'Delete'
      call delete(file)
    elseif a:cmd == 'Remove'
      echohl ErrorMsg
      echo 'Remove' fnamemodify(file, ':t')
      echohl None
      call rename(file, dst)
    endif
  endfor
  return 1
endfunction

"================================================================================
"    Description: low level grep wrapper
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/grep
"================================================================================
let s:MSWindows = has('win95') + has('win16') + has('win32') + has('win64')

" 使用するgrep指定
if !exists('mygrepprg')
  let mygrepprg = 'internal'
  if has('win32') + has('win64') - has('win95') > 0
    let mygrepprg = 'findstr'
  endif
  if has('unix')
    let mygrepprg = 'grep'
  endif
endif
" 日本語が含まれる場合のgrep指定
if !exists('myjpgrepprg')
  let myjpgrepprg = ''
endif
" 検索対象外のファイル指定
if !exists('g:MyGrep_ExcludeReg')
  let g:MyGrep_ExcludeReg = '[~#]$\|\.dll$\|\.exe$\|\.lnk$\|\.o$\|\.obj$\|\.pdf$\|\.xls$'
endif
" 使用するgrepのエンコーディング指定
if !exists('g:MyGrep_ShellEncoding')
  let g:MyGrep_ShellEncoding = 'utf-8'
  if s:MSWindows
    let g:MyGrep_ShellEncoding = 'cp932'
  endif
endif
" grep側でファイルエンコーディングを変換している場合に
" 変換後のファイルエンコーディングを指定する
if !exists('g:MyGrep_FileEncoding')
  let g:MyGrep_FileEncoding = ''
endif
" ダメ文字対策
if !exists('g:MyGrep_Damemoji')
  let g:MyGrep_Damemoji = 2
endif
"「ダメ文字」リスト
let g:MyGrep_DamemojiReplaceDefault = ['[]','[ーソЫⅨ噂浬欺圭構蚕十申曾箪貼能表暴予禄兔喀媾彌拿杤歃濬畚秉綵臀藹觸軆鐔饅鷭偆砡纊犾]', '[ー―‐／＼＋±×ＡァゼソゾタダチボポマミАЪЫЬЭЮЯклмн院閏噂云運雲荏閲榎厭円魁骸浬馨蛙垣柿顎掛笠樫機擬欺犠疑祇義宮弓急救掘啓圭珪型契形鶏芸迎鯨后梗構江洪浩港砿鋼閤降察纂蚕讃賛酸餐施旨枝止宗充十従戎柔汁旬楯殉淳拭深申疹真神秦須酢図厨繊措曾曽楚狙疏捜掃挿掻叩端箪綻耽胆蛋畜竹筑蓄邸甜貼転顛点伝怒倒党冬如納能脳膿農覗倍培媒梅鼻票表評豹廟描府怖扶敷法房暴望某棒冒本翻凡盆諭夕予余与誉輿養慾抑欲蓮麓禄肋録論倭僉兌兔兢竸兩兪几處凩凭咫喙喀咯喊喟啻嘴嘶嘲嘸奸媼媾嫋嫂媽嫣學斈孺宀廖彈彌彎弯彑彖悳忿怡恠戞拏拿拆擔拈拜掉掟掵捫曄杣杤枉杰枩杼桀桍栲桎檗歇歃歉歐歙歔毬毫毳毯漾濕濬濔濘濱濮炮烟烋烝瓠畆畚畩畤畧畫痣痞痾痿磧禺秉秕秧秬秡窖窩竈窰紂綣綵緇綽綫總縵縹繃縷隋膽臀臂膺臉臍艝艚艟艤蕁藜藹蘊蘓蘋藾蛔蛞蛩蛬襦觴觸訃訖訐訌諚諫諳諧蹇躰軆躱躾軅軈轆轎轗轜錙鐚鐔鐓鐃鐇鐐閔閖閘閙顱饉饅饐饋饑饒驅驂驀驃鵝鷦鷭鷯鷽鸚鸛黠黥黨黯纊倞偆偰偂傔垬埈埇犾劯砡硎硤硺葈蒴蕓蕙]', '[ーソЫⅨ噂浬欺圭構蚕十申曾箪貼能表暴予禄兔喀媾彌拿杤歃濬畚秉綵臀藹觸軆鐔饅鷭偆砡纊犾－ポл榎掛弓芸鋼旨楯酢掃竹倒培怖翻慾處嘶斈忿掟桍毫烟痞窩縹艚蛞諫轎閖驂黥埈蒴僴礰]']
if !exists('g:MyGrep_DamemojiReplaceReg')
  let g:MyGrep_DamemojiReplaceReg = '(..)'
endif
if !exists('g:MyGrep_DamemojiReplace')
  let g:MyGrep_DamemojiReplace = '[]'
endif
if !exists('g:MyGrep_Encoding')
  let g:MyGrep_Encoding = ''
endif
" --includeオプションを使用する
if !exists('g:MyGrep_IncludeOpt')
  let g:MyGrep_IncludeOpt = 0
endif
" 検索時にカーソル位置の単語を拾う
if !exists('g:MyGrep_DefaultSearchWord')
  let g:MyGrep_DefaultSearchWord = 1
endif
" 検索ディレクトリはカレントディレクトリを基点にする
if !exists('g:MyGrep_CurrentDirMode')
  let g:MyGrep_CurrentDirMode = 1
endif
" デフォルトのファイルパターン
if !exists('g:MyGrep_FilePattern')
  let g:MyGrep_FilePattern = '*'
endif
" デフォルトのerrorformat
if !exists('g:MyGrep_errorformat')
  " let g:MyGrep_errorformat = '%f|%\\s%#%l|%m'
endif

" QFixHowm用の行儀の悪いオプション
let g:MyGrep_FileListWipeTime = 0
let g:MyGrep_qflist = []

""""""""""""""""""""""""""""""
function! qfixlist#ToggleDamemoji()
  let g:MyGrep_Damemoji = 2 * !g:MyGrep_Damemoji
  echo 'QFixList : Damemoji = '.(g:MyGrep_Damemoji ? 'ON' : 'OFF')
endfunction

function! qfixlist#ToggleGrepCurrentDirMode()
  let g:MyGrep_CurrentDirMode = !g:MyGrep_CurrentDirMode
  echo 'QFixList : CurrentDirMode = '.(g:MyGrep_CurrentDirMode ? 'ON' : 'OFF')
endfunction

function! qfixlist#ToggleGrepRecursiveMode()
  let g:MyGrep_RecursiveMode = !g:MyGrep_RecursiveMode
  echo 'QFixList : RecursiveMode = '.(g:MyGrep_RecursiveMode ? 'ON' : 'OFF')
endfunction

""""""""""""""""""""""""""""""
function! s:restore()
  if !exists('g:MyGrep_UseLocationList') || s:QFix_UseLocationList == g:MyGrep_UseLocationList
    return
  endif
  let g:QFix_Win             = s:QFix_Win
  let g:QFix_SearchPath      = s:QFix_SearchPath
  let g:QFix_UseLocationList = s:QFix_UseLocationList
endfunction

function! s:save()
  let s:QFix_UseLocationList = g:QFix_UseLocationList
  if !exists('g:MyGrep_UseLocationList') || g:QFix_UseLocationList == g:MyGrep_UseLocationList
    return
  endif
  let s:QFix_Win             = g:QFix_Win
  let s:QFix_SearchPath      = g:QFix_SearchPath
  let g:QFix_UseLocationList = g:MyGrep_UseLocationList
endfunction

""""""""""""""""""""""""""""""
" バッファのみgrep
" 無名バッファは検索できない。
""""""""""""""""""""""""""""""
function! qfixlist#BGrep(word, mode, addflag)
  let pattern = a:word
  let mes = "Buffers grep : "
  if a:addflag
    let mes = "Buffers grepadd : "
  endif
  if pattern == '' || a:mode == -1
    let pattern = expand("<cword>")
    if g:MyGrep_DefaultSearchWord == 0
      let pattern = ''
    endif
    if a:mode < 0
      let pattern = @0
    endif
    let pattern = input(mes, pattern)
  endif
  if pattern == '' | return | endif
  call s:save()
  if a:addflag && g:QFix_SearchPath != ''
    let disppath = g:QFix_SearchPath
  else
    let disppath = expand('%:p:h')
  endif
  let g:QFix_SearchPath = disppath
  let @/ = pattern
  call histadd('/', '\V' . @/)
  call histadd('@', pattern)
  let bufnr = bufnr('%')
  let save_cursor = getpos('.')
  if a:addflag == 0
    let ccmd = g:QFix_UseLocationList ? 'lexpr ""' : 'cexpr ""'
    silent! exe ccmd
  endif
  call QFixPclose()
  let vopt = g:QFix_UseLocationList ? 'l' : ''
  silent! exe ':bufdo | try | '.vopt.'vimgrepadd /' . pattern . '/j % | catch | endtry'
  silent! exe 'b'.bufnr
  if a:addflag
    let g:QFix_SearchPath = disppath
  endif
  let g:QFix_SearchResult = []
  let save_qflist = QFixGetqflist()
  if empty(save_qflist)
    redraw | echo 'QFixGrep : Not found!'
  else
    if g:QFix_HeightFixMode == 1
      let g:QFix_Height = g:QFix_HeightDefault
    endif
    call QFixCopen()
    call cursor(1, 1)
    redraw | echo ''
  endif
  call s:restore()
endfunction

""""""""""""""""""""""""""""""
" grep helper
""""""""""""""""""""""""""""""
if !exists('g:MyGrepcmd')
  let g:MyGrepcmd = '#prg# #defopt# #recopt# #opt# #useropt# #cmdopt# -f #searchWordFile# #searchPath#'
endif
if !exists('g:MyGrepcmd_useropt')
  let g:MyGrepcmd_useropt = ''
endif
if !exists('g:MyGrepcmd_regexp')
  let g:MyGrepcmd_regexp = '-nHIE'
endif
if !exists('g:MyGrepcmd_regexp_ignore')
  let g:MyGrepcmd_regexp_ignore = '-nHIEi'
endif
if !exists('g:MyGrepcmd_fix')
  let g:MyGrepcmd_fix = '-nHIF'
endif
if !exists('g:MyGrepcmd_fix_ignore')
  let g:MyGrepcmd_fix_ignore = '-nHIFi'
endif
if !exists('g:MyGrep_Ignorecase')
  let g:MyGrep_Ignorecase = 1
endif
if !exists('g:MyGrep_Regexp')
  let g:MyGrep_Regexp = 1
endif
if !exists('g:MyGrep_Recursive')
  let g:MyGrep_Recursive = 0
endif
if !exists('g:MyGrep_RecursiveMode')
  let g:MyGrep_RecursiveMode = 0
endif
if !exists('g:MyGrep_RecOpt')
  let g:MyGrep_RecOpt = '-R'
endif
if !exists('g:QFix_UseLocationList')
  let g:QFix_UseLocationList = 0
endif
if !exists('g:MyGrep_UseLocationList')
  " let g:MyGrep_UseLocationList = 0
endif
if !exists('g:QFix_SearchPath')
  let g:QFix_SearchPath = ''
endif
if !exists('g:MyGrep_StayGrepDir')
  let g:MyGrep_StayGrepDir = 0
endif
if !exists('g:MyGrep_yagrep_opt')
  let g:MyGrep_yagrep_opt = 0
endif
let g:MyGrep_cmdopt = ''
" 一時的にvimgrepを使用したいときに非0。使用後リセットされる。
let g:MyGrep_UseVimgrep = 0
" QuickFixに登録しない
let g:MyGrep_Return = 0

""""""""""""""""""""""""""""""
" 汎用Grep関数
" vimgrepならfencは無視される。
" addflag : grep検索結果追加
""""""""""""""""""""""""""""""
function! qfixlist#MyGrep(pattern, searchPath, filepattern, fenc, addflag, ...)
  let addflag = a:addflag
  let searchPath = a:searchPath
  let pattern = a:pattern
  let prevPath = escape(getcwd(), ' ')
  let g:MyGrep_ErrorMes = ''
  if g:MyGrep_ExcludeReg == ''
    let g:MyGrep_ExcludeReg = '^$'
  endif

  let vg = (g:mygrepprg == 'internal' || g:mygrepprg == '' || g:MyGrep_UseVimgrep != 0) ? 1 :0
  let cmdpath = searchPath == '' ? getcwd() : searchPath
  if vg == 0 && s:MSWindows && cmdpath =~ '^\(//\|\\\\\)'
    let host = matchstr(cmdpath, '^\(//\|\\\\\)[^/\\]\+')
    let host = substitute(host, '/', '\', 'g')
    echohl ErrorMsg
    let grepprg = fnamemodify(g:mygrepprg, ':t')
    redraw|echo 'using vimgrep... ('. grepprg .' does not support UNC path "' . host . '")'
    echohl None
    let g:MyGrep_UseVimgrep = 1
    let g:MyGrep_ErrorMes = 'QFixGrep : Vimgrep was used. (UNC path "' . host . '")'
  endif
  if vg == 0 && pattern != '' && pattern !~ '^[[:print:][:space:]]\+$'
    if a:fenc =~ 'le$' || (a:fenc !~ 'cp932\c' && g:mygrepprg == 'findstr') || a:fenc !~ g:MyGrep_Encoding
      echohl ErrorMsg
      redraw|echo 'using vimgrep... (grep does not support "' . a:fenc . '")'
      echohl None
      let g:MyGrep_ErrorMes = 'QFixGrep : Vimgrep was used. (invalid fenc = "'.a:fenc .'")'
      let g:MyGrep_UseVimgrep = 1
    endif
  endif
  if g:mygrepprg == 'internal' || g:mygrepprg == '' || g:MyGrep_UseVimgrep != 0
    silent! exe 'lchdir ' . escape(searchPath, ' ')
    let pattern = escape(pattern, '/')
    let vopt = g:QFix_UseLocationList ? 'l' : ''
    if addflag
      silent! exe ':'.vopt.'vimgrepadd /' . pattern . '/j ' . a:filepattern
    else
      silent! exe ':'.vopt.'vimgrep /' . pattern . '/j ' . a:filepattern
    endif
    "ここでバッファ削除
    let idx = 0
    let save_qflist = QFixGetqflist()
    for d in save_qflist
      if bufname(d.bufnr) =~ g:MyGrep_ExcludeReg
        call remove(save_qflist, idx)
        silent! exe 'silent! bd ' . d.bufnr
      else
        let idx = idx + 1
      endif
    endfor
    call QFixSetqflist(save_qflist)
    if g:MyGrep_StayGrepDir == 0
      silent! exe 'lchdir ' . prevPath
    endif
    let g:MyGrep_Regexp = 1
    let g:MyGrep_Ignorecase = 1
    let g:MyGrep_Recursive  = 0
    let g:MyGrep_UseVimgrep = 0
    if g:MyGrep_ErrorMes != ''
      echohl ErrorMsg
      redraw | echo g:MyGrep_ErrorMes
      echohl None
    endif
    if g:MyGrep_Return
      let g:MyGrep_Return = 0
      return save_qflist
    endif
    let g:QFix_SearchPath = searchPath
    return []
  endif

  let ccmd = g:QFix_UseLocationList ? 'lexpr ""' : 'cexpr ""'
  let l:mygrepprg = expand(g:mygrepprg)
  if !executable(l:mygrepprg)
    echohl ErrorMsg
    redraw|echom '"'.l:mygrepprg.'"'." is not executable!"
    echohl None
    let mes = '"'.l:mygrepprg.'" is not executable!'
    let choice = confirm(mes, "&OK", 1, "W")
    let g:MyGrep_Regexp = 1
    let g:MyGrep_Ignorecase = 1
    let g:MyGrep_Recursive  = 0
    let g:MyGrep_UseVimgrep = 0
    return []
  endif
  if g:MyGrep_ShellEncoding =~ 'utf8\c'
    let g:MyGrep_ShellEncoding = 'utf-8'
  endif
  if g:mygrepprg =~ 'yagrep\c'
    if g:MyGrep_yagrep_opt == 2
      let g:MyGrep_Damemoji = 0
    endif
  endif
  call s:SetGrepEnv('set', pattern)
  let _grepcmd = 'g:MyGrepcmd_regexp'
  if g:MyGrep_Regexp == 0
    let _grepcmd = 'g:MyGrepcmd_fix'
    let g:MyGrep_Regexp = 1
  else
    " だめ文字対策
    if g:MyGrep_Damemoji != 0 && a:fenc =~ 'cp932\c'
      let pp = match(pattern, g:MyGrep_DamemojiReplaceDefault[2])
      let pattern = substitute(pattern, g:MyGrep_DamemojiReplaceDefault[g:MyGrep_Damemoji], g:MyGrep_DamemojiReplaceReg, 'g')
      let pattern = substitute(pattern, g:MyGrep_DamemojiReplace, g:MyGrep_DamemojiReplaceReg, 'g')
      if pp > -1
        let g:MyGrep_ErrorMes = printf("QFixGrep : ダメ文字が含まれていました! regxp = %s", pattern)
        if pattern =~ '^[.*]\+$'
          let g:MyGrep_ErrorMes = "QFixGrep : ダメ文字しか含まれていません!"
          silent! exe ccmd
          let g:MyGrep_Regexp = 1
          let g:MyGrep_Ignorecase = 1
          let g:MyGrep_Recursive  = 0
          let g:MyGrep_UseVimgrep = 0
          call s:SetGrepEnv('restore')
          return []
        endif
      endif
    endif
  endif
  if g:MyGrep_Ignorecase > 0
    let _grepcmd = _grepcmd.'_ignore'
  endif
  let g:MyGrep_Ignorecase = 1
  let grepcmd = substitute(g:MyGrepcmd, '#defopt#', {_grepcmd}, '')
  let grepcmd = substitute(grepcmd, '#useropt#', g:MyGrepcmd_useropt, '')
  silent! exe 'lchdir ' . escape(searchPath, ' ')
  let retval = s:ExecGrep(grepcmd, g:mygrepprg, searchPath, pattern, &enc, a:fenc, a:filepattern)
  let pattern = s:ParseFilepattern(a:filepattern)
  let file = ''
  redraw|echo 'QFixGrep : Parsing...'
  let g:MyGrep_qflist = s:ParseSearchResult(searchPath, retval, pattern, g:MyGrep_ShellEncoding, a:fenc)
  call s:SetGrepEnv('restore')
  if g:MyGrep_Return
    let g:MyGrep_Return = 0
    if g:MyGrep_StayGrepDir == 0
      silent! exe 'lchdir ' . prevPath
    endif
    redraw|echo ''
    return g:MyGrep_qflist
  endif
  if a:0
    redraw|echo ''
  else
    redraw|echo 'QFixGrep : Set quickfix list...'
    let flag = addflag ? 'a' : ' '
    call QFixSetqflist(g:MyGrep_qflist, flag)
  endif
  if g:MyGrep_StayGrepDir == 0
    silent! exe 'lchdir ' . prevPath
  endif
  let g:QFix_SearchPath = searchPath
  redraw | echo ''
  if g:MyGrep_ErrorMes != ''
    echohl ErrorMsg
    redraw | echo g:MyGrep_ErrorMes
    echohl None
  endif
  return []
endfunction

let g:MyGrep_ErrorMes = ''
if !exists('g:qfixtempname')
  let g:qfixtempname = tempname()
endif
""""""""""""""""""""""""""""""
"findstr/jvgrep用に環境設定
""""""""""""""""""""""""""""""
function! s:SetGrepEnv(mode, ...)
  if a:mode == 'set'
    let s:mygrepprg = ''
    if g:myjpgrepprg != '' && a:0 && match(a:1, '[^[:print:]]') > -1
      let s:mygrepprg = g:mygrepprg
      let g:mygrepprg = g:myjpgrepprg
    endif
  endif
  if g:mygrepprg != 'findstr' && g:mygrepprg !~ 'jvgrep'
    return
  endif
  if a:mode == 'set'
    let s:MyGrepcmd                 = g:MyGrepcmd
    let s:MyGrepcmd_regexp          = g:MyGrepcmd_regexp
    let s:MyGrepcmd_regexp_ignore   = g:MyGrepcmd_regexp_ignore
    let s:MyGrepcmd_fix             = g:MyGrepcmd_fix
    let s:MyGrepcmd_fix_ignore      = g:MyGrepcmd_fix_ignore
    let s:MyGrepcmd_useropt         = g:MyGrepcmd_useropt
    let s:MyGrep_RecOpt             = g:MyGrep_RecOpt
    let s:MyGrep_Damemoji           = g:MyGrep_Damemoji
    let s:MyGrep_DamemojiReplaceReg = g:MyGrep_DamemojiReplaceReg
    let s:MyGrep_ShellEncoding      = g:MyGrep_ShellEncoding
    let s:MyGrep_FileEncoding       = g:MyGrep_FileEncoding

    if g:mygrepprg == 'findstr'
      let g:MyGrepcmd                 = '#prg# #defopt# #recopt# #opt# #useropt# /G:#searchWordFile# #searchPath#'
      let g:MyGrepcmd_regexp          = '/n /p /r'
      let g:MyGrepcmd_regexp_ignore   = '/n /p /r /i'
      let g:MyGrepcmd_fix             = '/n /p /l'
      let g:MyGrepcmd_fix_ignore      = '/n /p /l /i'
      let g:MyGrep_RecOpt             = '/s'
      let g:MyGrep_DamemojiReplaceReg = '..'
      let g:MyGrep_ShellEncoding      = 'cp932'
      let g:MyGrep_FileEncoding       = ''
    elseif g:mygrepprg =~ 'jvgrep'
      let g:MyGrepcmd_regexp          = ''
      let g:MyGrepcmd_regexp_ignore   = '-i' " TODO: works fixed match only.
      let g:MyGrepcmd_fix             = '-F'
      let g:MyGrepcmd_fix_ignore      = '-i -F'
      let g:MyGrep_RecOpt             = '-R'
      let g:MyGrep_Damemoji           = 0
    endif
  elseif a:mode == 'restore'
    if s:mygrepprg != ''
      let g:mygrepprg = s:mygrepprg
      let s:mygrepprg = ''
    endif
    let g:MyGrepcmd                 = s:MyGrepcmd
    let g:MyGrepcmd_regexp          = s:MyGrepcmd_regexp
    let g:MyGrepcmd_regexp_ignore   = s:MyGrepcmd_regexp_ignore
    let g:MyGrepcmd_fix             = s:MyGrepcmd_fix
    let g:MyGrepcmd_fix_ignore      = s:MyGrepcmd_fix_ignore
    let g:MyGrepcmd_useropt         = s:MyGrepcmd_useropt
    let g:MyGrep_RecOpt             = s:MyGrep_RecOpt
    let g:MyGrep_Damemoji           = s:MyGrep_Damemoji
    let g:MyGrep_DamemojiReplaceReg = s:MyGrep_DamemojiReplaceReg
    let g:MyGrep_ShellEncoding      = s:MyGrep_ShellEncoding
    let g:MyGrep_FileEncoding       = s:MyGrep_FileEncoding
  endif
endfunction

""""""""""""""""""""""""""""""
"検索語ファイルを作成してgrep
""""""""""""""""""""""""""""""
function! s:ExecGrep(cmd, prg, searchPath, searchWord, from_encoding, to_encoding, filepattern)
  if !isdirectory(expand(a:searchPath))
    let mes = printf('"%s" is not directory!', a:searchPath)
    let choice = confirm(mes, "&OK", 1, "W")
    let g:MyGrep_retval = ''
    return g:MyGrep_retval
  endif

  " iconv が使えない
  "  if a:from_encoding != a:to_encoding && !has('iconv')
  "    echoe 'QFixGrep : not found iconv!'
  "    let g:MyGrep_ErrorMes = 'QFixGrep : Not found iconv!'
  "    let choice = confirm(g:MyGrep_ErrorMes, "&OK")
  "    return []
  "  endif
  let cmd = a:cmd
  " プログラム設定
  let prg = fnamemodify(a:prg, ':t')
  let cmd = substitute(cmd, '#prg#', prg, 'g')

  let sPath = '*'
  let ropt = ''
  let opt = ''

  " 検索パス設定
  if match(a:filepattern, '^\*\*/') != -1 || g:MyGrep_RecursiveMode
    let g:MyGrep_Recursive = 1
  endif
  if s:debug
    "let filepattern = substitute(a:filepattern, '^\*\*/', '', '')
    "let sPath = filepattern
  endif
  if g:MyGrep_Recursive == 1
    let ropt = g:MyGrep_RecOpt
    let g:MyGrep_Recursive = 0
  endif
  if g:mygrepprg =~ 'yagrep\c'
    if a:to_encoding =~ 'cp932\c'
      let opt = '--ctype=SJIS'
    elseif a:to_encoding =~ 'euc\c'
      let opt = '--ctype=EUC'
    elseif a:to_encoding =~ 'utf-8\c'
      let opt = '--ctype=UTF8'
    endif
    let opt = opt .' -s'
    if g:MyGrep_yagrep_opt == 0
      let opt = ' -s'
    endif
  endif
  if g:MyGrep_IncludeOpt == 1
    let ipat = substitute(a:filepattern, '\*\*/', '', 'g')
    " TODO:空白で区切られたファイルの種類だけ--include=*.hoge
    " 簡単に試した限りでは、さほど速度向上にならない気がする。
    " さらに--includeオプションにバグのあるgrepも存在する。
    let opt = opt.' --include='.ipat
  endif
  let cmd = substitute(cmd, '#recopt#', ropt, '')
  let cmd = substitute(cmd, '#opt#', opt, '')
  let cmd = substitute(cmd, '#cmdopt#', g:MyGrep_cmdopt, '')
  let g:MyGrep_cmdopt = ''
  let cmd = substitute(cmd, '#searchPath#', escape(sPath, '\\'), 'g')

  " 検索語ファイル作成
  if match(cmd, '#searchWordFile#') != -1
    let searchWord = iconv(a:searchWord, a:from_encoding, a:to_encoding)
    let searchWordList = [searchWord]
    call writefile(searchWordList, g:qfixtempname, 'b')
    let cmd = substitute(cmd, '#searchWordFile#', s:GrepEscapeVimPattern(g:qfixtempname), 'g')
  endif
  if match(cmd, '#searchWord#') != -1
    let to_encoding = g:MyGrep_ShellEncoding
    let searchWord = iconv(a:searchWord, a:from_encoding, to_encoding)
    if g:mygrepprg =~ 'jvgrep'
      if match(searchWord, ' ')
        let searchWord = '"' . searchWord . '"'
      endif
    endif
    let cmd = substitute(cmd, '#searchWord#', s:GrepEscapeVimPattern(searchWord), 'g')
  endif

  " 検索実行
  let prevPath = escape(getcwd(), ' ')
  silent! exe 'lchdir ' . escape(a:searchPath, ' ')
  silent! let saved_path = $PATH
  let dir = fnamemodify(a:prg, ':h')
  if dir != '.'
    let dir = fnamemodify(a:prg, ':p:h')
    let delimiter = has('unix') ? ':' : ';'
    let $PATH = dir.delimiter.$PATH
  endif
  let g:MyGrep_retval = system(cmd)
  let g:MyGrep_path   = a:searchPath
  if s:debug
    let g:fudist_cmd = cmd
    let g:fudist_pat = a:filepattern
    let g:fudist_word = a:searchWord
  endif
  silent! let $PATH  = saved_path
  if exists('g:qfixtempname')
    silent! call delete(g:qfixtempname)
  endif
  return g:MyGrep_retval
endfunction

""""""""""""""""""""""""""""""
" ファイルパターンを変換
""""""""""""""""""""""""""""""
function! s:ParseFilepattern(filepattern)
  let filepattern = a:filepattern
  let filepattern = substitute(filepattern, '\*\*/', '', 'g')
  let filepattern = substitute(filepattern, '\s\+', ' ', 'g')
  let filepattern = substitute(filepattern, '^\s\|\s$', '', 'g')
  if filepattern == '*'
    let filepattern = '.*'
  else
    let filepattern = substitute(filepattern, ' ', '$\\|', 'g')
    let filepattern = substitute(filepattern, '\.', '\\.', 'g')
    let filepattern = substitute(filepattern, '*', '\.*', 'g')
    let filepattern = substitute(filepattern, '\\|\*', '\\|\.\*', 'g')
    let filepattern = filepattern.'$'
  endif
  return filepattern
endfunction

function! s:ParseSearchResult(searchPath, searchResult, filepattern, shellenc, fenc)
  let wipetime = g:MyGrep_FileListWipeTime
  let g:MyGrep_FileListWipeTime = 0
  let fe=a:fenc
  if g:MyGrep_FileEncoding != ''
    let fe = g:MyGrep_FileEncoding
  endif
  let parseResult = ''
  let searchResult = a:searchResult
  let prevfname = ''
  let qfmtime = -1
  let mtime = 0
  let fcnv = a:shellenc != &enc
  let ccnv = fe != &enc
  let qflist = []
  let recheck = 0
  let prevPath = escape(getcwd(), ' ')

  for buf in split(searchResult, '\n')
    while 1
      let bufidx = matchend(buf, ':\d\+:', 0, 1)
      if bufidx == -1
        break
      endif
      let extidx = match(buf, ':\d\+:', 0, 1)
      let fname  = strpart(buf, 0, extidx)
      if fcnv
        let fname = iconv(fname, a:shellenc, &enc)
      endif
      let outtime = 0
      if wipetime > 0
        if prevfname != fname
          let qfmtime = getftime(fname)
          let prevfname = fname
        endif
        if qfmtime < wipetime
          let outtime = 1
        endif
      endif
      let lnum = strpart(buf, extidx+1, bufidx-extidx-2)
      let text = strpart(buf, bufidx)
      if ccnv
        let text = iconv(text, fe, &enc)
      endif
      let lst = split(text, '\n')
      if lst == []
        break
      endif
      let content = lst[0]
      let content = strpart(content, 0, 1024-strlen(fname)-32)
      let content = substitute(content, "[\n\r]", "", "")
      if fname !~ '\c\.swp$\|\~$' && fname =~ a:filepattern && fname !~ g:MyGrep_ExcludeReg && outtime == 0
        call add(qflist, {'filename':fname, 'lnum':lnum, 'text':content})
      endif
      if lst[0] != text
        if ccnv
          let text = iconv(lst[0], &enc, fe)
        endif
        let buf = strpart(buf, bufidx + strlen(text))
        let buf = substitute(buf, '^\n', '', '')
      else
        break
      endif
    endwhile
  endfor
  silent! exe 'lchdir ' . prevPath
  if s:debug && len(qflist) == 0 && a:searchResult != ''
    " let mes = iconv(g:MyGrep_retval, a:shellenc, &enc)
    " redraw | echoe string(mes)
    " let choice = confirm(mes, "&OK")
  endif
  return qflist
endfunction

function! s:GrepEscapeVimPattern(pattern)
  let retval = escape(a:pattern, '\\.*+@{}<>~^$()|?[]%=&')
  let retval = retval
  return retval
endfunction

""""""""""""""""""""""""""""""
" 代替コマンド
""""""""""""""""""""""""""""""
if !exists('g:QFix_Height')
  let g:QFix_Height = 10
endif
if !exists('g:QFix_HeightDefault')
  let g:QFix_HeightDefault = QFix_Height
endif
if !exists('g:QFix_HeightFixMode')
  let g:QFix_HeightFixMode = 0
endif
" setqflist
if !exists('*QFixSetqflist')
function QFixSetqflist(sq, ...)
  let cmd = 'a:sq'. (a:0 == 0 ? '' : ",'".a:1."'")
  if g:QFix_UseLocationList
    exe 'call setloclist(0, '.cmd.')'
  else
    exe 'call setqflist('.cmd.')'
  endif
endfunction
endif
" getqflist
if !exists('*QFixGetqflist')
function QFixGetqflist()
  if g:QFix_UseLocationList
    return getloclist(0)
  else
    return getqflist()
  endif
endfunction
endif
" copen
if !exists('*QFixCopen')
command -nargs=* -bang QFixCopen call QFixCopen(<q-args>, <bang>0)
function QFixCopen(...)
  if g:QFix_UseLocationList
    silent! lopen
  else
    silent! copen
  endif
endfunction
endif
" cclose
if !exists('*QFixCclose')
command! QFixCclose call QFixCclose()
function! QFixCclose(...)
  if g:QFix_UseLocationList
    silent! lclose
  else
    silent! cclose
  endif
endfunction
endif
" preview
if !exists('*QFixPreviewOpen')
function QFixPreviewOpen(...)
endfunction
endif
" pclose
if !exists('*QFixPclose')
command QFixPclose call QFixPclose()
function QFixPclose(...)
endfunction
endif
if !exists('*QFixAltWincmdMap')
function QFixAltWincmdMap(...)
endfunction
endif
" MyGrepReadResult stab
if !exists('*MyGrepReadResult')
command! -count -nargs=* -bang MyGrepReadResult call MyGrepReadResult(<bang>0, <q-args>)
function! MyGrepReadResult(readflag, ...)
  echoe "MyGrepReadResult : cannot read QFixlib!"
endfunction
endif

" ロケーションリスト設定
if !exists('*QFixGrepLocationMode')
function! QFixLocationMode(...)
  let mode = a:0 ? a:1 : 0
  let mode = count ? count : mode
  if mode == 0
    let g:QFix_UseLocationList   = 0
    let g:MyGrep_UseLocationList = 0
  elseif mode == 1
    let g:QFix_UseLocationList   = 1
    let g:MyGrep_UseLocationList = 0
  elseif mode == 2
    let g:QFix_UseLocationList   = 1
    let g:MyGrep_UseLocationList = 1
  elseif mode == 3
    let g:QFix_UseLocationList   = 0
    let g:MyGrep_UseLocationList = 1
  elseif mode == 4
    let g:QFix_UseLocationList   = 0
    let g:MyGrep_UseLocationList = 0
  endif
endfunction
function QFixGrepLocationMode(...)
  let mode = a:0 ? a:1 : 0
  let mode = count ? count : mode
  call QFixLocationMode(mode)
  if a:0 > 1
    return
  endif
  echo printf('QFixWin (%s) : QFixGrep (%s)', (g:QFix_UseLocationList ? 'L' : 'Q'), (g:MyGrep_UseLocationList ? 'L' : 'Q'))
endfunction
endif

function! QFixNormalizePath(path, ...)
  let path = a:path
  " let path = expand(a:path)
  if s:MSWindows
    if a:0 " 比較しかしないならキャピタライズ
      let path = toupper(path)
    else
      " expand('~') で展開されるとドライブレターは大文字、
      " expand('c:/')ではそのままなので統一
      let path = substitute(path, '^\([a-z]\):', '\u\1:', '')
    endif
    let path = substitute(path, '\\', '/', 'g')
  endif
  return path
endfunction

