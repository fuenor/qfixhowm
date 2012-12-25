"=============================================================================
"    Description: Vim Script grep
"                 Vimスクリプトによるgrep
"                 Vimで正常に開けるエンコーディングなら、異なるエンコーディン
"                 グが混在していてもgrep可能
"         Author: fuenor <fuenor@gmail.com>
"=============================================================================
scriptencoding utf-8

" fuenor@gmail.com
"
" 検索関数
"   agrep#MyGrepScript(searchWord, to_encoding, searchPath, options)
"   searchWord  : 検索文字列
"                 エンコーディングは内部エンコーディングと同じ
"   to_encoding : 検索対象のファイルエンコーディング
"   searchPath  : 検索パス
"                 現在 *.txt などのファイル名指定には対応していない
"   options     : オプション
"                 -F -i -R (固定文字列検索、大小文字の同一視、再帰検索)
"
" 戻り値
"   該当行を file:lnum:text で返す
"
"   file : ファイル名
"          g:MyGrep_ShellEncodingで指定されたエンコーディングに変換
"   lnum : 該当行番号
"   text : 該当行の内容
"          to_encodingで指定されたエンコーディングに変換
"
" 異なるエンコーディングが混在していてもgrep可能にする
"   let g:MyGrep_MultiEncodingGrepScript = 1
"
" QFixGrep/QFixHowm/QFixMemo
"   次を設定するとqfixlistで使用される。
"   let mygrepprg='agrep.vim'
"   日本語を含む場合のみ使用するなら次のように設定する
"   let myjpgrepprg='agrep.vim'
"

" 検索対象外のファイル指定
if !exists('g:MyGrep_ExcludeReg')
  if exists('g:QFix_PreviewExclude')
    let g:MyGrep_ExcludeReg = '[~#]$\|'.g:QFix_PreviewExclude
  else
    let g:MyGrep_ExcludeReg = '[~#]$\|\.pdf$\|\.xls$\|\.mp3$\|\.mpg$\|\.avi$\|\.wmv$\|\.jpg$\|\.bmp$\|\.png$\|\.gif$\|\.zip$\|\.rar$\|\.exe$\|\.dll$\|\.o$\|\.obj$\|\.lnk$'
  endif
endif
" 使用するgrep(shell)のエンコーディング指定
let s:MSWindows = has('win95') || has('win16') || has('win32') || has('win64')
if !exists('g:MyGrep_ShellEncoding')
  let g:MyGrep_ShellEncoding = 'utf-8'
  if s:MSWindows && !has('win32unix')
    let g:MyGrep_ShellEncoding = 'cp932'
  endif
endif
" 異なるエンコーディングが混在していてもgrep可能にする
if !exists('g:MyGrep_MultiEncodingGrepScript')
  let g:MyGrep_MultiEncodingGrepScript = 0
endif
if !exists('g:qfixtempname')
  let g:qfixtempname = tempname()
endif
let s:tempfile = g:qfixtempname

function! agrep#MyGrepScript(searchWord, to_encoding, searchPath, options)
  let globfile = a:options =~ "\\C-[a-zA-Z]*R" ? '**/*' : '*'
  let qflist = s:glob(fnamemodify(a:searchPath, ':p'), globfile)
  if qflist == []
    return ''
  endif
  redraw | echo 'agrep.vim : searching...'
  let searchWord = escape(a:searchWord, "~@=")
  if a:options =~ "\\C-[a-zA-Z]*F"
    let searchWord = "\\V".escape(searchWord, "\\")
  else
    let searchWord = "\\v".searchWord
  endif
  if a:options !~ "\\C-[a-zA-Z]*i"
    let searchWord = "\\C".searchWord
  endif
  " 高速化のためテンポラリバッファを使用
  let prevPath = escape(getcwd(), ' ')
  silent! exe 'lchdir ' . escape(path, ' ')
  silent! exe 'silent! split '.s:tempfile
  silent! setlocal bt=nofile bh=hide noswf nobl

  let retval = ''
  let path = substitute(fnamemodify(a:searchPath, ':p'), '\\', '/', 'g')
  let path = substitute(path, '[\\/]$', '', '')
  for file in qflist
    if file =~ g:MyGrep_ExcludeReg
      continue
    endif
    let filename = iconv(substitute(file, '\\', '/', 'g'), &enc, g:MyGrep_ShellEncoding)
    let lnum = 1
    if g:MyGrep_MultiEncodingGrepScript
      let tlist = s:readfile(path.'/'.file, '')
    else
      let tlist = readfile(path.'/'.file, '')
      call map(tlist, "iconv(v:val, a:to_encoding, &enc)")
    endif
    for text in tlist
      if match(text, searchWord) > -1
        let text = iconv(text, &enc, a:to_encoding)
        let retval = retval.filename.':'.lnum.':'.text."\<NL>"
      endif
      let lnum += 1
    endfor
  endfor
  silent! close
  exe 'lchdir ' . prevPath
  redraw | echo ''
  return retval
endfunction

function! s:readfile(mfile, ...)
  let tlist = []
  silent! 1,$delete _
  let mfile = a:mfile
  let cmd = '0read '
  let opt = ''
  silent! exe cmd . ' ' . opt .' '. escape(mfile, ' #%')
  let tlist = getline(1, '$')
  return tlist
endfunction

function! s:glob(path, file)
  let prevPath = escape(getcwd(), ' ')
  let path = expand(a:path)
  if !isdirectory(path)
    let mes = printf('"%s" is not directory.', a:path)
    let choice = confirm(mes, "&OK", 1, "W")
    return []
  endif
  exe 'lchdir ' . escape(path, ' ')
  redraw | echo 'agrep.vim : glob...'
  let files = split(glob(a:file), '\n')
  let qflist = []
  for n in files
    if !isdirectory(n)
      call add(qflist, n)
    endif
  endfor
  exe 'lchdir ' . prevPath
  return qflist
endfunction

