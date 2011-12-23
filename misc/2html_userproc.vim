"
" howm2html用ユーザー定義コマンド
" syntax/2html.vimを使用してhatenaのスーパーpreタグをVimのsyntaxで変換する。
" このファイルをqfixapp/pluginなどruntimepathの通った場所へコピーしてください。
"
" misc/css/howm2html.cssとmisc/css/peachpuff.cssをHTML出力先へコピーすると
" スーパーpreは色付けして表示されます。
"

if &cp
  finish
endif

" 2html.vimの場所
if !exists('g:HowmHtml_2html')
  let g:HowmHtml_2html = 'syntax/2html.vim'
endif
if !exists('g:HowmHtml_colorscheme')
  let g:HowmHtml_colorscheme = 'peachpuff'
endif

" Howm2htmlのユーザー変換
func! HowmHtmlUserProc(file)
  if !g:fudist_manual
    call s:HatenaListExtra()
    call s:Markdown2HatenaDefine()
  endif
  call s:Convert2HTMLSnippet()
endfunc

" はてなリスト形式の:をタブにコンバート
func! s:HatenaListExtra(...)
  let save_cursor = getpos('.')
  call cursor(1,1)
  while 1
    let define = search('^[-+]', 'W')
    if define == 0
      break
    endif
    let idx = 1
    while 1
      if define+idx > line('$')
        break
      endif
      let str = getline(define+idx)
      if str !~ '^:'
        break
      endif
      let str = substitute(str, '^:', '\t', '')
      call setline(define+idx, str)
      let idx += 1
    endwhile
    let lastdefine = define
  endwhile
  call setpos('.', save_cursor)
endfunc

" Markdown定義リストをはてな定義リスト形式にコンバート
func! s:Markdown2HatenaDefine(...)
  let save_cursor = getpos('.')

  let lastdefine = 0
  call cursor(1,1)
  while 1
    let define = search('^:', 'W')
    if define == 0
      break
    endif
    let str = ':'.getline(define-1) . ' :'
    call setline(define-1, str)
    let str = substitute(getline(define), '^:', '\t', '')
    call setline(define, str)

    let idx = 1
    while 1
      if define+idx > line('$')
        break
      endif
      let str = getline(define+idx)
      if str !~ '^:'
        break
      endif
      let str = substitute(str, '^:', '\t', '')
      call setline(define+idx, str)
      let idx += 1
    endwhile
    let lastdefine = define
  endwhile
  call setpos('.', save_cursor)
endfunc

" はてなのスーパーpreをhtmlタグでハイライト
func! s:Convert2HTMLSnippet(...)
  let saved_colorscheme = g:colors_name
  let save_cursor = getpos('.')
  let color = g:HowmHtml_colorscheme
  if a:0
    let color = a:1
  endif
  exe 'colorscheme ' . color
  call cursor(1,1)
  while 1
    let firstline = search('^>|.\+|$', 'cW')
    if firstline == 0
      break
    endif
    let lastline = search('^||<$', 'W')
    if lastline == 0
      break
    endif
    let type = substitute(getline(firstline), '^>|\||$', '', 'g')
    if type == ''
      continue
    endif
    let firstline += 1
    let lastline -= 1
    let rstr = s:Convert2HTMLCode(firstline, lastline, type, 'xhtml')
    call map(rstr, "substitute(v:val, '<br\\( /\\)\\?>$', '', '')")
    " howm2html用に &&を埋め込み
    call map(rstr, '"&&" . v:val')
    call setline(firstline, rstr)
  endwhile
  call setpos('.', save_cursor)
  exe 'colorscheme '.saved_colorscheme
endfunc

func! s:Convert2HTMLCode(line1, line2, ftype, htmltype)
  let orgtype = &ft
  if a:line2 >= a:line1
    let g:html_start_line = a:line1
    let g:html_end_line = a:line2
  else
    let g:html_start_line = a:line2
    let g:html_end_line = a:line1
  endif

  if exists('g:use_xhtml')
    let s:use_xhtml = g:use_xhtml
  endif
  if exists('g:html_use_css')
    let s:html_use_css = g:html_use_css
  endif

  if exists('g:html_no_progress')
    let s:html_no_progress = g:html_no_progress
  endif
  if exists('g:html_number_lines')
    let s:html_number_lines = g:html_number_lines
  endif
  if exists('g:html_no_pre')
    let s:html_no_pre = g:html_no_pre
  endif
  if exists('g:html_ignore_folding')
    let s:html_ignore_folding = g:html_ignore_folding
  endif
  if exists('g:html_no_foldcolumn')
    let s:html_no_foldcolumn = g:html_no_foldcolumn
  endif
  if exists('g:html_whole_filler')
    let s:html_whole_filler = g:html_whole_filler
  endif

  let g:html_no_progress    = 1
  let g:html_number_lines   = 0
  let g:html_no_pre         = 1
  let g:html_ignore_folding = 1
  let g:html_no_foldcolumn  = 1
  let g:html_whole_filler   = 1

  " css で指定したい場合
  if a:htmltype == 'xhtml'
    let g:use_xhtml    = 1
    let g:html_use_css = 1
  endif

  exe 'set ft='.a:ftype
  exe 'silent runtime '.g:HowmHtml_2html
  setlocal bufhidden=wipe
  setlocal buftype=nofile
  setlocal nobuflisted
  setlocal noswapfile
  call cursor(1, 1)
  let fline = search('^<style type="text/css">' , 'cW')
  let lline = search('^</style>' , 'cW')
  let g:TOHtmlSnippetCSS = getline(fline, lline)
  let fline = search('^<body' , 'ncW')
  let g:TOHtmlSnippet = getline(fline+1, line('$')-2)
  close
  exe 'set ft='.orgtype

  if exists('s:use_xhtml')
    let g:use_xhtml = s:use_xhtml
  else
    unlet g:use_xhtml
  endif
  if exists('s:html_use_css')
    let g:html_use_css = s:html_use_css
  else
    unlet g:html_use_css
  endif

  call s:remove('html_no_progress')
  call s:remove('html_number_lines')
  call s:remove('html_no_pre')
  call s:remove('html_ignore_folding')
  call s:remove('html_no_foldcolumn')
  call s:remove('html_whole_filler')

  unlet g:html_start_line
  unlet g:html_end_line
  return g:TOHtmlSnippet
endfunc

func! s:remove(var)
  if exists('s:'.a:var)
    exe 'let g:'.a:var.'=s:'.a:var
    exe 'unlet s:'.a:var
  else
    exe 'unlet g:'.a:var
  endif
endfunc

" テスト用
if !exists('g:fudist_manual')
  let g:fudist_manual = 0
endif

