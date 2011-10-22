"=============================================================================
"    Description: Open URI
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home  (Japanese)
"  Last Modified: 2011-10-16 19:06
"=============================================================================
let s:Version = 1.00
scriptencoding utf-8

" カーソル位置のURIを開いたら 1 を返す
" 文字列指定された場合は文字列をURIとして開く
function! openuri#open(...)
  call openuri#init()
  if a:0 && a:1 != ''
    let ret = s:openstr(a:1)
  else
    let ret = s:cursorline()
  endif
  if ret == "\<CR>"
    return 0
  endif
  return ret
endfunction

function! openuri#init()
  if exists('g:QFixHowm_Convert') && g:QFixHowm_Convert
    return
  endif
  if exists('g:qfixmemo_dir')
    let g:howm_dir = g:qfixmemo_dir
  endif
  if exists('g:qfixmemo_ext')
    let g:QFixHowm_FileExt = g:qfixmemo_ext
  endif
  if exists('g:qfixmemo_openuri_cmd')
    let g:QFixHowm_OpenURIcmd = g:qfixmemo_openuri_cmd
  endif
  if exists('g:qfixmemo_openuri_vimextreg')
    let g:QFixHowm_OpenVimExtReg = g:qfixmemo_openuri_vimextreg
  endif
  if exists('g:qfixmemo_relpath')
    let g:QFixHowm_RelPath = g:qfixmemo_relpath
  endif
endfunction

if !exists('howm_dir')
  let howm_dir          = '~/howm'
endif
let s:howmsuffix        = 'howm'
if !exists('howm_filename')
  let howm_filename     = '%Y/%m/%Y-%m-%d-%H%M%S.'.s:howmsuffix
endif
let g:QFixHowm_FileExt  = fnamemodify(g:howm_filename,':e')
if !exists('howm_glink_pattern')
  let howm_glink_pattern = '>>>'
endif
" タブで編集('tab'を設定)
if !exists('QFixHowm_Edit')
  let QFixHowm_Edit = ''
endif

command! QFixHowmOpenCursorline call QFixHowmOpenCursorline()
" カーソル位置のURIを開いたら 1 を返す
silent! function QFixHowmOpenCursorline()
  return openuri#open()
endfunction

""""""""""""""""""""""""""""""
" カーソル位置のファイルを開くアクションロック
""""""""""""""""""""""""""""""
" カーソル位置のファイルを開くアクションロック
if !exists('g:QFixHowm_OpenURIcmd')
  if !exists('g:MyOpenURI_cmd')
    let g:QFixHowm_OpenURIcmd = ""
    if has('unix')
      let g:QFixHowm_OpenURIcmd = "call system('firefox %s &')"
    else
      " Internet Explorer
      let g:QFixHowm_OpenURIcmd = '!start "C:/Program Files/Internet Explorer/iexplore.exe" %s'
      let g:QFixHowm_OpenURIcmd = '!start "rundll32.exe" url.dll,FileProtocolHandler %s'
    endif
  else
    let g:QFixHowm_OpenURIcmd = g:MyOpenURI_cmd
  endif
endif

" Vimで開くファイルリンク
if !exists('g:QFixHowm_OpenVimExtReg')
  if !exists('g:MyOpenVim_ExtReg')
    let g:QFixHowm_OpenVimExtReg = '\.txt$\|\.vim$\|\.js$\|\.java$\|\.py$\|\.rb$\|\.h$\|\.c$\|\.cpp$\|\.ini$\|\.conf$'
  else
    let g:QFixHowm_OpenVimExtReg = g:MyOpenVim_ExtReg
  endif
endif
" rel://
if !exists('g:QFixHowm_RelPath')
  let g:QFixHowm_RelPath = g:howm_dir
endif

" はてなのhttp記法のゴミを取り除く
if !exists('g:QFixHowm_removeHatenaTag')
  let g:QFixHowm_removeHatenaTag = 1
endif

function! s:cursorline()
  let prevcol = col('.')
  let prevline = line('.')
  let str = getline('.')
  let l:howm_dir = substitute(g:howm_dir, '\\', '/', 'g')
  let l:QFixHowm_RelPath = substitute(g:QFixHowm_RelPath, '\\', '/', 'g')

  " >>>
  let pos = match(str, g:howm_glink_pattern)
  if pos > -1 && col('.') >= pos
    let str = strpart(str, pos)
    let str = substitute(str, '^\s*\|\s*$', '', 'g')
    let str = substitute(str, '^'.g:howm_glink_pattern.'\s*', '', '')
    let path = l:QFixHowm_RelPath . (str =~ 'rel://[^/\\]' ? '/' : '')
    let str = substitute(str, 'rel://', path, '')
    let path = l:howm_dir . (str =~ 'howm://[^/\\]' ? '/' : '')
    let str = substitute(str, 'memo://', path, '')
    let str = substitute(str, 'howm://', path, '')
    let imgsfx = '\(\.jpg\|\.jpeg\|\.png\|\.bmp\|\.gif\)$'
    if str =~ imgsfx
      let str = substitute(str, '^&', '', '')
    endif
    return s:openstr(str)
  endif

  " カーソル位置の文字列を拾う[:c:/temp/test.jpg:]や[:http://example.com:(title=hoge)]形式
  let col = col('.')
  let pathhead = '\([A-Za-z]:[/\\]\|\~/\)'
  let urireg = '\(\(memo\|rel\|howm\|http\|https\|file\|ftp\)://\|'.pathhead.'\)'
  let [lnum, colf] = searchpos('\[:\?&\?'.urireg, 'bc', line('.'))
  if lnum != 0 && colf != 0
    let str = strpart(getline('.'), colf-1)
    let lstr = substitute(str, '\[:\?&\?'.urireg, '', '')
    let len = matchend(lstr, ':[^\]]*]')
    if len < 0
      let str = ''
    else
      let len += matchend(str, '\[:\?&\?'.urireg)
      let str = strpart(str, 0, len)
    endif
    call cursor(prevline, prevcol)
    if str != '' && col < (colf + len(str))
      if str =~ '^\[:\?'
        let str = substitute(str, ':\(title=\|image[:=]\)\([^\]]*\)\?]$', ':]', '')
        let str = substitute(str, ':[^:\]]*]$', '', '')
      endif
      let str = substitute(str, '^\[:\?&\?', '', '')
      let path = l:QFixHowm_RelPath . (str =~ 'rel://[^/\\]' ? '/' : '')
      let str = substitute(str, 'rel://', path, '')
      let path = l:howm_dir . (str =~ 'howm://[^/\\]' ? '/' : '')
      let str = substitute(str, 'memo://', path, '')
      let str = substitute(str, 'howm://', path, '')
      return s:openstr(str)
    endif
  endif

  " カーソル位置の文字列を拾う
  let urichr  =  "[-0-9a-zA-Z;/?:@&=+$,_.!~*'()%#]"
  let pathchr =  "[-0-9a-zA-Z;/?:@&=+$,_.!~*'()%{}[\\]\\\\]"
  let pathhead = '\([A-Za-z]:[/\\]\|\~/\)'
  let urireg = '\(\(memo\|rel\|howm\|http\|https\|file\|ftp\)://\|'.pathhead.'\)'
  let [lnum, colf] = searchpos(urireg, 'bc', line('.'))
  if colf == 0 && lnum == 0
    return "\<CR>"
  endif
  let str = strpart(getline('.'), colf-1)
  if str =~ '^https\?:\|^ftp:'
    let str = matchstr(str, urichr.'\+')
  else
    let str = matchstr(str, pathchr.'\+')
  endif
  if colf > prevcol || colf + strlen(str) <= prevcol
    return "\<CR>"
  endif
  call cursor(prevline, prevcol)

  let str = substitute(str, ':$\|\(|:title=\|:image\|:image[:=]\)'.pathchr.'*$', '', '')
  if str != ''
    let path = l:QFixHowm_RelPath . (str =~ 'rel://[^/\\]' ? '/' : '')
    let str = substitute(str, 'rel://', path, '')
    let path = l:howm_dir . (str =~ 'howm://[^/\\]' ? '/' : '')
    let str = substitute(str, 'memo://', path, '')
    let str = substitute(str, 'howm://', path, '')
    return s:openstr(str)
  endif
  return "\<CR>"
endfunction

function! s:openstr(str)
  let str = a:str
  let str = substitute(str, '[[:space:]]*$', '', '')
  let l:MyOpenVim_ExtReg = '\.'.g:QFixHowm_FileExt.'$'.'\|\.'.s:howmsuffix.'$'
  if g:QFixHowm_OpenVimExtReg != ''
    let l:MyOpenVim_ExtReg = l:MyOpenVim_ExtReg.'\|'.g:QFixHowm_OpenVimExtReg
  endif

  " Vimか指定のプログラムで開く
  let pathhead = '\([A-Za-z]:[/\\]\|\~/\|/\)'
  if str =~ '^'.pathhead
    if str !~ l:MyOpenVim_ExtReg
      let ext = tolower(fnamemodify(str, ':e'))
      if exists('g:qfixmemo_openuri_'.ext)
        exec 'let g:QFixHowm_Opencmd_'.ext.' = g:qfixmemo_openuri_'.ext
      endif
      if exists('g:QFixHowm_Opencmd_'.ext)
        exec 'let cmd = g:QFixHowm_Opencmd_'.ext
        let str = expand(str)
        if has('unix')
          let str = escape(str, ' ')
        endif
        let cmd = substitute(cmd, '%s', escape(str, '&\'), '')
        let cmd = escape(cmd, '%#')
        silent! exec cmd
        return 1
      endif
    else
      let str = expand(str)
      if has('unix')
        let str = escape(str, ' ')
      endif
      exec g:QFixHowm_Edit.'edit '. escape(str, '%#')
      return 1
    endif
    if fnamemodify(str, ':e') == ''
      let str = expand(str)
      if has('unix')
        let str = escape(str, ' ')
      endif
      exec g:QFixHowm_Edit.'edit '. escape(str, '%#')
      return 1
    endif
  endif

  let urireg = '\(\(https\|http\|file\|ftp\)://\|'.pathhead.'\)'
  if str !~ '^'.urireg
    return "\<CR>"
  endif
  " あとはブラウザで開く
  let uri = str
  if uri =~ '^file://'
    let uri = substitute(uri, '^file://', '', '')
    let uri = expand(uri)
    let uri = 'file://'.uri
  endif
  if uri =~ '^'.pathhead
    let uri = expand(uri)
    let uri = 'file://'.uri
  endif
  let uri = substitute(uri, '\', '/', 'g')
  if uri == ''
    return "\<CR>"
  endif
  return s:openuri(uri)
endfunction

function! s:openuri(uri)
  let cmd = ''
  let bat = 0

  let uri = a:uri
  if uri =~ '^http[s]\?\|^ftp'
    let char = "[-A-Za-z0-9-_./~,$!*'();:@=&+]"
    let uri = substitute(uri, '\s\+.*$', '', '')
    if g:QFixHowm_removeHatenaTag
      let uri = substitute(uri, ':\(\(title\|image\)=[^\]]\+\)\?$', '', '')
    endif
  endif
  if has('win32') || has('win64')
    if &enc != 'cp932' && uri =~ '^file://' && uri =~ '[^[:print:]]'
      let bat = 1
    endif
  endif
  if g:QFixHowm_OpenURIcmd != ''
    let cmd = g:QFixHowm_OpenURIcmd
    if g:QFixHowm_OpenURIcmd =~ '\(rundll32\|iexplore\(\.exe\)\?\)' && uri =~ '^file://'
    else
      let uri = s:EncodeURL(uri, &enc)
    endif
    " Windowsで &encが cp932以外か !start cmd /c が指定されていたらバッチ化して実行
    if bat || cmd =~ '^!start\s*cmd\(\.exe\)\?\s*/c'
      let cmd = substitute(cmd, '^[^"]\+', '', '')
      let uri = substitute(uri, '&', '"\&"', 'g')
      let uri = substitute(uri, '%', '%%', 'g')
      let cmd = substitute(cmd, '%s', escape(uri, '&'), '')
      let cmd = iconv(cmd, &enc, 'cp932')
      let s:uricmdfile = fnamemodify(s:howmtempfile, ':p:h') . '/uricmd.bat'
      call writefile([cmd], s:uricmdfile)
      let cmd = '!start "'.s:uricmdfile.'"'
      silent! exec cmd
      return 1
    endif
    let cmd = substitute(cmd, '%s', escape(uri, '&'), '')
    let cmd = escape(cmd, '%#')
    silent! exec cmd
    return 1
  endif
  return "\<CR>"
endfunction

function! s:EncodeURL(str, ...)
  let to_enc = 'utf8'
  if a:0
    let to_enc = a:1
  endif
  let str = iconv(a:str, &enc, to_enc)
  let save_enc = &enc
  let &enc = to_enc
  " FIXME:本当は'[^-0-9a-zA-Z._~]'を変換？
  let str = substitute(str, '[^[:print:]]', '\=s:URLByte2hex(s:URLStr2byte(submatch(0)))', 'g')
  let str = substitute(str, ' ', '%20', 'g')
  let &enc = save_enc
  return str
endfunction

function! s:URLStr2byte(str)
  return map(range(len(a:str)), 'char2nr(a:str[v:val])')
endfunction

function! s:URLByte2hex(bytes)
  return join(map(copy(a:bytes), 'printf("%%%02X", v:val)'), '')
endfunction

