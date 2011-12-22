"
" howm2html用ユーザー定義コマンド
" /h2h/2html_mod.vimを使用してhatenaのスーパーpreタグをVimのsyntaxで変換する。
" このファイルをqfixapp/pluginなどruntimepathの通った場所へコピーしてください。
"
" misc/css/howm2html.cssとmisc/css/peachpuff.cssをHTML出力先へコピーすると
" 色付けして表示されます。
"

if &cp
  finish
endif

" 2html.modの場所
if !exists('g:HowmHtml_2html_mod')
  let g:HowmHtml_2html_mod = 'misc/h2h/2html_mod.vim'
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
  let color = 'peachpuff'
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
    "howm2html用に &&を埋め込み
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

  "css で指定したい場合
  if a:htmltype == 'xhtml'
    let g:use_xhtml    = 1
    let g:html_use_css = 1
  endif

  exe 'set ft='.a:ftype
  exe 'silent runtime '.g:HowmHtml_2html_mod
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

  unlet g:html_start_line
  unlet g:html_end_line
  return g:TOHtmlSnippet
endfunc

" テスト用
if !exists('g:fudist_manual')
  let g:fudist_manual = 0
endif

