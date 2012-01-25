"=============================================================================
"    Description: Open URI
"                 see doc/openuri.jax
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home  (Japanese)
"  Last Modified: 2011-11-14 22:31
"=============================================================================
let s:version = 101
scriptencoding utf-8
if exists('g:disable_openuri') && g:disable_openuri == 1
  finish
endif
if exists('g:openuri_version') && g:openuri_version < s:version
  let g:loaded_openuri = 0
endif
if exists('g:loaded_openuri') && g:loaded_openuri && !exists('fudist')
  finish
endif
if v:version < 700 || &cp
  finish
endif
let g:openuri_version = s:version
let g:loaded_openuri = 1

" 文字列指定された場合は文字列をURIとして開く
" カーソル位置のURIを開いたら 1 を返す
function! openuri#open(...)
  call openuri#init()
  if a:0 && a:1 != ''
    let ret = s:openstr(a:1)
  else
    let ret = s:cursorline()
  endif
  return ret == 1
endfunction

""""""""""""""""""""""""""""""
command! -nargs=? Openuri call openuri#cursorline(<q-args>)
function! openuri#cursorline(...)
  let str = a:0 ? a:1 : ''
  if !openuri#open(str)
    exe "normal! \<CR>"
  endif
  return ''
endfunction

" default
let s:howmsuffix = 'howm'

function! openuri#AddScheme(key, path)
  call openuri#init()
  let g:openuri_scheme[a:key] = a:path
  return g:openuri_scheme
endfunction

function! openuri#init()
  let l:howm_dir = '~/howm'
  if exists('g:howm_dir')
    let l:howm_dir = g:howm_dir
  elseif exists('g:qfixmemo_dir')
    let l:howm_dir = g:qfixmemo_dir
  endif
  let l:memo_path = l:howm_dir
  if exists('g:qfixmemo_dir')
    let l:memo_path = g:qfixmemo_dir
  elseif exists('g:howm_dir')
    let l:memo_path = g:howm_dir
  endif
  if exists('g:openuri_memopath')
    let l:memo_path = g:openuri_memopath
  endif
  let l:rel_dir = l:memo_path
  if exists('g:openuri_relpath')
    let l:rel_dir = g:openuri_relpath
  elseif exists('g:QFixHowm_RelPath')
    let l:rel_dir = g:QFixHowm_RelPath
  endif

  let g:openuri_scheme['howm'] = l:howm_dir
  let g:openuri_scheme['memo'] = l:memo_path
  let g:openuri_scheme['rel']  = l:rel_dir
  let g:openuri_schemereg = ''
  for key in keys(g:openuri_scheme)
    let g:openuri_schemereg = g:openuri_schemereg.'\|'.key
  endfor

  if exists('g:QFixHowm_OpenVimExtReg')
    let g:openuri_vimextreg = g:QFixHowm_OpenVimExtReg
  endif
  if exists('g:QFixHowm_OpenURIcmd')
    let g:openuri_cmd = g:QFixHowm_OpenURIcmd
  endif
  if exists('g:QFixHowm_Edit')
    let g:openuri_edit = g:QFixHowm_Edit
  endif
endfunction

""""""""""""""""""""""""""""""
" カーソル位置のファイルを開く
""""""""""""""""""""""""""""""
" Vimで開くファイル指定
if !exists('g:openuri_vimextreg')
  let g:openuri_vimextreg = '\.\(txt\|mkd\|wiki\|rd\|vim\|js\|java\|py\|rb\|h\|c\|cpp\|ini\|conf\)$'
endif

" カーソル位置のファイルを開くコマンド
if !exists('g:openuri_cmd')
  if has('unix')
    let g:openuri_cmd = "call system('firefox %s &')"
  else
    " Internet Explorer
    let g:openuri_cmd = '!start "C:/Program Files/Internet Explorer/iexplore.exe" %s'
    " let g:openuri_cmd = '!start "rundll32.exe" url.dll,FileProtocolHandler %s'
  endif
  " netrw を使用する場合(:help gx)
  " let g:openuri_cmd = 'netrw'
endif
" netrw でリモートを使用
if !exists('g:openuri_netrw_remote')
  let g:openuri_netrw_remote = 0
endif

" scheme:// convert dictionary
if !exists('g:openuri_scheme')
  let g:openuri_scheme = {}
endif

" UNCパスを使用する
if !exists('g:openuri_use_UNC')
  let g:openuri_use_UNC = 1
  if has('unix')
    let g:openuri_use_UNC = 0
  endif
endif

" g:openuri_edit = 'tab'
if !exists('g:openuri_edit')
  let g:openuri_edit = ''
endif

" はてなのhttp記法のゴミ : を取り除く
if !exists('g:openuri_remove_hatenatag')
  let g:openuri_remove_hatenatag = 1
endif

function! s:cursorline()
  let prevcol = col('.')
  let str = getline('.')

  " >>>
  if exists('g:howm_glink_pattern') && g:howm_glink_pattern != ''
    let pos = match(str, g:howm_glink_pattern)
    if pos > -1 && col('.') >= pos
      let str = strpart(str, pos)
      let str = substitute(str, '^\s*\|\s*$', '', 'g')
      let str = substitute(str, '^'.g:howm_glink_pattern.'\s*', '', '')
      let imgsfx = '\.\(jpg\|jpeg\|png\|bmp\|gif\)$'
      if str =~ imgsfx
        let str = substitute(str, '^&', '', '')
      endif
      return s:openstr(str)
    endif
  endif

  " カーソル位置の文字列を拾う[:c:/temp/test.jpg:]や[:http://example.com:(title=hoge)]形式
  let col = col('.')
  let pathhead = '\([A-Za-z]:[/\\]\|\~[/\\]\|\.\.\?[/\\]\|[/\\]\)'
  let urireg = '\(\(http\|https\|file\|ftp'.g:openuri_schemereg.'\)://\|'.pathhead.'\)'
  let [lnum, colf] = searchpos('\[:\?&\?'.urireg, 'nbc', line('.'))
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
    if str != '' && col < (colf + len(str))
      if str =~ '^\[:\?'
        if str =~ '^\[:\?.*:vim\]$'
          let str = substitute(str, '^\[:\?\|:vim\]$', '', 'g')
          exe g:openuri_edit.'edit '. escape(str, '%#')
          return 1
        endif
        if g:openuri_remove_hatenatag
          let str = substitute(str, ':\(title=\|image[:=]\)\([^\]]*\)\?]$', ':]', '')
        endif
        let str = substitute(str, ':[^:\]]*]$', '', '')
      endif
      let str = substitute(str, '^\[:\?&\?', '', '')
      return s:openstr(str)
    endif
  endif

  " カーソル位置の文字列を拾う
  let urichr  =  "[-0-9a-zA-Z;/?@&=+$,_.!~*'()%:#]"
  let pathchr =  "[-0-9a-zA-Z;/?@&=+$,_.!~*'()%:{}[\\]\\\\]"
  let pathhead = '\([A-Za-z]:[/\\]\|\~[/\\]\)'
  let urireg = '\(\(http\|https\|file\|ftp'.g:openuri_schemereg.'\)://\|'.pathhead.'\)'
  let [lnum, colf] = searchpos(urireg, 'nbc', line('.'))
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

  let str = substitute(str, ':\+$', '', '')
  if str != ''
    return s:openstr(str)
  endif
  return "\<CR>"
endfunction

function! s:cnvScheme(dict, str)
  let str = a:str
  let g:openuri_schemereg = ''
  for key in keys(a:dict)
    let g:openuri_schemereg = g:openuri_schemereg.'\|'.key
    let path = substitute(fnamemodify(a:dict[key], ':p'), '\\', '/', 'g')
    let str = substitute(str, '^'.key.'://[/\\]\?', path, '')
  endfor
  return str
endfunction

function! s:openstr(str)
  let str = a:str

  let str = s:cnvScheme(g:openuri_scheme, str)
  if g:openuri_use_UNC == 0 && str =~ '^\\\\'
    return "\<CR>"
  endif

  let str = substitute(str, '[[:space:]]*$', '', '')
  let l:vimextreg = '\.'.s:howmsuffix.'$'
  if exists('g:QFixHowm_FileExt')
    let l:vimextreg = '\.'.g:QFixHowm_FileExt.'$'.'\|'.l:vimextreg
  endif
  if exists('g:qfixmemo_ext')
    let l:vimextreg = '\.'.g:qfixmemo_ext.'$'.'\|'.l:vimextreg
  endif
  if g:openuri_vimextreg != ''
    let l:vimextreg = '\('.l:vimextreg.'\)\|'.g:openuri_vimextreg
  endif

  let pathhead = '\([A-Za-z]:[/\\]\|\~[/\\]\|\.\.\?[/\\]\|\\\{2}\|[/\\]\)'
  if str =~ '^\(\(https\|http\|file\|ftp\)://\|'.pathhead.'\)$'
    return "\<CR>"
  endif

  " Vimか指定のプログラムで開く
  if str =~ '^'.pathhead
    if str !~ '^\\\\'
      let prevPath = escape(getcwd(), ' ')
      exe 'lchdir ' . escape(fnamemodify(expand('%'), ':h'), ' ')
      let str = fnamemodify(str, ':p')
      silent! exe 'lchdir ' . prevPath
    endif
    if str !~ l:vimextreg
      if g:openuri_cmd =~ '\c^'.'netrw'
        if has("win32") || has("win95") || has("win64") || has("win16")
          if &enc != 'cp932' && str =~ '[^[:print:]]'
            let str = iconv(str, &enc, 'cp932')
          endif
        endif
        " let str = 'file://'.str
        call netrw#NetrwBrowseX(str, g:openuri_netrw_remote)
        return 1
      endif
      let ext = tolower(fnamemodify(str, ':e'))
      if !exists('g:openuri_'.ext) && exists('g:QFixHowm_Opencmd_'.ext)
        exe 'let g:openuri_'.ext.' = g:QFixHowm_Opencmd_'.ext
      endif
      if exists('g:openuri_'.ext)
        let str = expand(str)
        if has("win32") || has("win95") || has("win64") || has("win16")
          if &enc != 'cp932' && str =~ '[^[:print:]]'
            let str = iconv(str, &enc, 'cp932')
          endif
        endif
        let str = substitute(str, '\\', '/', 'g')
        exe 'let cmd = g:openuri_'.ext
        let cmd = substitute(cmd, '["'."'".']\?%s["'."'".']\?', '', '')
        let cmd .= shellescape(str, 1)
        silent! exe cmd
        return 1
      endif
    else
      if str !~ '^\\\\'
        let dir = fnamemodify(str, ':h')
        if isdirectory(dir) == 0
          silent! call mkdir(dir, 'p')
        endif
        let str = substitute(str, '\\', '/', 'g')
      endif
      if has('unix')
        let str = escape(str, ' ')
      endif
      exe g:openuri_edit.'edit '. escape(str, '%#')
      return 1
    endif
    if fnamemodify(str, ':e') == ''
      let str = substitute(str, '\\', '/', 'g')
      if has('unix')
        let str = escape(str, ' ')
      endif
      exe g:openuri_edit.'edit '. escape(str, '%#')
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
  let uri = substitute(uri, '\\', '/', 'g')
  if uri == ''
    return "\<CR>"
  endif
  return s:openuri(uri)
endfunction

function! s:openuri(uri)
  let cmd = ''
  let bat = 0

  let uri = substitute(a:uri, '^\s*\|\s*$', '', 'g')
  if uri =~ '^\(https\?\|ftp\)://'
    let urichr  = "[-0-9a-zA-Z;/?@&=+$,_.!~*'()%:#]"
    let uri = matchstr(uri, urichr.'\+')
  endif
  if has("win32") || has("win95") || has("win64") || has("win16")
    if &enc != 'cp932' && uri =~ '^file://' && uri =~ '[^[:print:]]'
      let bat = 1
    endif
  endif
  if g:openuri_cmd =~ '\c^'.'netrw$'
    let str = uri
    if bat
      let str = iconv(uri, &enc, 'cp932')
    endif
    let pathhead = '\([A-Za-z]:[/\\]\|\~[/\\]\|\.\.\?[/\\]\|\\\{2}\|[/\\]\)'
    if str =~ '^'.pathhead
      " let str = 'file://'.str
    endif
    call netrw#NetrwBrowseX(uri, g:openuri_netrw_remote)
    return 1
  endif
  if g:openuri_cmd != ''
    let cmd = substitute(g:openuri_cmd, '^netrw|', '', '')
    if g:openuri_cmd =~ '\(rundll32\|iexplore\(\.exe\)\?\)' && uri =~ '^file://'
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
      let s:uricmdfile = fnamemodify(s:tempfile, ':p:h') . '/uricmd.bat'
      call writefile([cmd], s:uricmdfile)
      let cmd = '!start "'.s:uricmdfile.'"'
      silent! exe cmd
      return 1
    endif
    let cmd = substitute(cmd, '%s', escape(uri, '&'), '')
    let cmd = escape(cmd, '%#')
    silent! exe cmd
    return 1
  endif
  return "\<CR>"
endfunction

""""""""""""""""""""""""""""""
" URL Encode
""""""""""""""""""""""""""""""
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

""""""""""""""""""""""""""""""
" remove tempfile
""""""""""""""""""""""""""""""
if !exists('g:qfixtempname')
  let g:qfixtempname = tempname()
endif
let s:tempfile = g:qfixtempname

augroup OpenURI
  au!
  au VimLeave * call <SID>VimLeave()
augroup END

function! s:VimLeave()
  if exists('s:uricmdfile')
    call delete(s:uricmdfile)
  endif
endfunction

