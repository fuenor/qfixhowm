"=============================================================================
"    Description: Vim Script grep
"                 qfixlistで使用するためのgrepスクリプト
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home  (Japanese)
"=============================================================================
scriptencoding utf-8

" fuenor@gmail.com
"
"   let mygrepprg='agrep.vim'
" を設定するとqfixlistで使用される。
"
" 検索部分は
"   function! #MyGrepSearch(searchWord, from_encoding, to_encoding, searchPath, options)
"   from_encoding : searchWordのエンコーディング
"   to_encoding   : 検索対象ファイルのエンコーディング
"
" 戻り値は HInr準拠のフォーマット file:lnum:text で返す
"
" * qfixlistで使用する場合 (myqfix.vimが存在する場合)
"   fileはフルパスではなく searchPath で切り詰めたファイル名かつ
"   g:MyGrep_ShellEncodingで指定されたエンコーディングに変換する。
"   textに関してはファイルエンコーディングとto_encodingが一致するはずなので変
"   換の必要はない。
"   (ただし異なるエンコーディングもgrep可能なら to_encoding に変換する必要がある)

function! agrep#MyGrepScript(searchWord, from_encoding, to_encoding, searchPath, options)
  let searchWord = escape(a:searchWord, "~@=")
  let searchWord = iconv(searchWord, a:from_encoding, a:to_encoding)
  if a:options =~ "\\CF"
    let searchWord = "\\V".escape(searchWord, "\\")
  else
    let searchWord = "\\v".searchWord
  endif
  if a:options !~ "\\Ci"
    let searchWord = "\\C".searchWord
  endif
  let qflist = s:glob(fnamemodify(a:searchPath, ':p'), '**/*')
  redraw | echo 'grep.vim : seaching...'
  let retval = ''
  for file in qflist
    let filename = file
    if exists('*QFixNormalizePath')
      let filename = QFixNormalizePath(filename)
      let cwd      = QFixNormalizePath(a:searchPath)
      if match(filename, cwd) == 0
        let filename = strpart(filename, strlen(cwd)+1)
      endif
      let filename = iconv(filename, &enc, g:MyGrep_ShellEncoding)
    endif
    let lnum = 1
    let tlist = readfile(file, '')
    for text in tlist
      if text =~ a:searchWord
        let retval = retval.filename.':'.lnum.':'.text."\<NL>"
      endif
      let lnum += 1
    endfor
  endfor
  redraw | echo ''
  return retval
endfunction

" 検索対象外のファイル指定
if !exists('g:MyGrep_ExcludeReg')
  if exists('g:QFix_PreviewExclude')
    let g:MyGrep_ExcludeReg = '[~#]$\|'.g:QFix_PreviewExclude
  else
    let g:MyGrep_ExcludeReg = '[~#]$\|\.pdf$\|\.xls$\|\.mp3$\|\.mpg$\|\.avi$\|\.wmv$\|\.jpg$\|\.bmp$\|\.png$\|\.zip$\|\.rar$\|\.exe$\|\.dll$\|\.o$\|\.obj$\|\.lnk$'
  endif
endif

function! s:glob(path, file)
  let prevPath = escape(getcwd(), ' ')
  let path = expand(a:path)
  if !isdirectory(path)
    let mes = printf('"%s" is not directory.', a:path)
    let choice = confirm(mes, "&OK", 1, "W")
    return []
  endif
  if path !~ '[\\/]$'
    let path .= '/'
  endif
  exe 'lchdir ' . escape(path, ' ')
  redraw | echo 'grep.vim : glob...'
  let files = split(glob(a:file), '\n')
  let qflist = []
  let lnum = 1
  let text = ''
  let from = g:qfixmemo_fileencoding
  let to   = &enc
  for n in files
    let n = path . n
    let n = fnamemodify(n, ':p')
    if !isdirectory(n) && n !~ g:MyGrep_ExcludeReg
      call add(qflist, n)
    endif
  endfor
  exe 'lchdir ' . prevPath
  return qflist
endfunction

