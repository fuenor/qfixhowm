"=============================================================================
"    Description: grep & list
"                 required  : mygrep.vim
"                             http://sites.google.com/site/fudist/Home/grep
"                 addtional : myqfix.vim (preview)
"                             http://sites.google.com/site/fudist/Home/grep
"         Author: fuenor <fuenor@gmail.com>
"=============================================================================
let s:Version = 1.00
scriptencoding utf-8

" What Is This:
"   This plugin is grep wrapper.
"
" Install:
"   Put this file and mygrep.vim into your runtime directory.
"     > vimfiles/plugin or .vim/plugin
"   * addtional myqfix.vim
"
"   Windows : if you have grep.exe, set mygrepprg.
"             findstr(default) can not search utf-8 fileencoding.
"             > .vimrc
"             let mygrepprg='path/to/grep'
"             let mygrepprg='grep'
"
"  Usage: qfixlist#grep(pattern, path, filepattern, {fileencoding})
"
"    :let qflist = qfixlist#grep('^int', '~/usr/mysrc', '*.cpp')
"    " **/ means recursive
"    :let qflist = qfixlist#grep('words', '~/usr/mytxt', '**/*', 'utf-8')
"    " quickfix
"    :call qfixlist#copen(qflist, search_path)
"    " qfixlist window
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
"    * these options reset to default after qfixlist#grep()

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
  redraw | echo 'QFixList : Set quickfix list...'
  call QFixPclose()
  call QFixSetqflist(s:QFixList_qfCache)
  QFixCopen
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
    QFixCclose
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
  let list = MyGrep(a:pattern, a:dir, a:file, a:fenc, 0)

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

