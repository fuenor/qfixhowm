"=============================================================================
"    Description: HTML converter for QFixMemo
"                 openuri.vim required
"     Maintainer: fuenor@gmail.com
"                 http://dl.dropbox.com/u/1736409/howm/howm2html.html
"=============================================================================
let s:version  = '1.31'
scriptencoding utf-8

if exists('g:disable_Howm2html') && g:disable_Howm2html == 1
  finish
endif
if exists("g:loaded_Howm2html") && !exists('g:fudist')
  finish
endif
if v:version < 700 || &cp
  finish
endif
let g:loaded_Howm2html = 1

" ユーザーコマンド
" ----------------------------------------------------------------------------
" |:Howm2html              | 現バッファのエントリをテンポラリHTML変換        |
" |:Howm2html %            | 現バッファのエントリを静的HTMLとしてにHTML変換  |
" |:Howm2html (ファイル名) | 指定ファイルのエントリを静的HTMLとしてHTML変換  |
" |:Howm2html!             | ! を付けて実行するとHTML出力後にブラウザで表示  |
" |:Howm2html -pub         | HTML出力先に HowmHtml_publish_htmldirを使用する |
" |:Howm2html -nolocallink | ローカルリンク(c:/temp等)をfile://へ変換しない  |
" |:Howm2html -locallink   | ローカルリンク(c:/temp等)をfile://へ変換        |
" |:Howm2html -cursor      | カーソル位置のエントリのみHTML変換              |
" |:Howm2html -Blogger     | Blogger用出力                                   |
" | HowmHtmlConvFiles      | 指定ファイル内のファイル名を利用して変換        |
" ----------------------------------------------------------------------------
" -テンポラリHTML変換の場合、出力ファイル名は HowmHtml_DefaultNameが使用されます。
" -% かファイル名を指定した場合は、拡張子をhtmlに変更したファイル名で出力されます。

" HTML出力ディレクトリ
if !exists('g:HowmHtml_htmldir')
  let g:HowmHtml_htmldir = '~/howm2html'
endif
" (完成版の)HTML出力ディレクトリ
if !exists('g:HowmHtml_publish_htmldir')
  let g:HowmHtml_publish_htmldir = g:HowmHtml_htmldir
endif
" デフォルトの出力ファイル名
" ファイル名を指定している場合はそちらが優先されます。
if !exists('g:HowmHtml_DefaultName')
  let g:HowmHtml_DefaultName = 'howm2html.html'
  if exists('g:fudist')
    let g:HowmHtml_DefaultName = 'temp.html'
  endif
endif
if !exists('g:HowmHtml_HomePage')
  let g:HowmHtml_HomePage = 'index.html'
endif

" ファイル基準ディレクトリ(%BASEDIR%)
if !exists('g:HowmHtml_basedir')
  let g:HowmHtml_basedir = ''
  if exists('g:qfixmemo_dir')
    let g:HowmHtml_basedir = g:qfixmemo_dir
  elseif exists('g:howm_dir')
    let g:HowmHtml_basedir = g:howm_dir
  endif
endif

" includeモードのファイル基準ディレクトリ
if !exists('HowmHtml_ref_basedir')
  let HowmHtml_ref_basedir = HowmHtml_basedir
endif

" howm://
if exists('g:qfixmemo_dir')
  let s:howm_dir = g:qfixmemo_dir
endif
if !exists('s:howm_dir')
  let s:howm_dir = exists('g:qfixmemo_dir') ? g:qfixmemo_dir : '~/howm'
endif
if !exists('g:howm_publish_dir')
  let g:howm_publish_dir = s:howm_dir
endif
if !exists('g:HowmHtml_base_relmode')
  let g:HowmHtml_base_relmode = 0
endif

" rel://
if !exists('g:HowmHtml_RelPath')
  let g:HowmHtml_RelPath = s:howm_dir
  if exists('g:QFixHowm_RelPath')
    let g:HowmHtml_RelPath = g:QFixHowm_RelPath
  elseif exists('g:openuri_relpath')
    let g:HowmHtml_RelPath = g:openuri_relpath
  elseif exists('g:qfixmemo_root')
    let g:HowmHtml_RelPath = g:qfixmemo_root
  elseif exists('g:QFixHowm_RootDir')
    let g:HowmHtml_RelPath = g:QFixHowm_RootDir
  endif
endif

if !exists('g:HowmHtml_publish_RelPath')
  let g:HowmHtml_publish_RelPath = g:HowmHtml_RelPath
endif

" HowmHtmlのルートディレクトリ(%ROOT%)
if !exists('HowmHtml_root')
  let HowmHtml_root = HowmHtml_basedir
endif
if !exists('HowmHtml_publish_root')
  let HowmHtml_publish_root = HowmHtml_root
endif

" htmlファイルのエンコーディング(utf-8, Shift_JIS, euc-jp)
if !exists('HowmHtml_encoding')
  let HowmHtml_encoding = 'utf-8'
endif
" 出力するhtmlファイルの拡張子
if !exists('HowmHtml_suffix')
  let HowmHtml_suffix = 'html'
endif
" 出力するhtmlファイルの拡張子の置換方法
" | :t:r | 拡張子を置き換え|
" | :t   | ファイル名に追加|
if !exists('HowmHtml_suffix_mode')
  let HowmHtml_suffix_mode = ':t:r'
endif

" 表示するサイト名
if !exists('HowmHtml_SightName')
  let HowmHtml_SightName = 'Howm2html'
endif
" 表示する説明
" 無定義の場合はファイル名が使用される
if !exists('HowmHtml_Description')
  let HowmHtml_Description = ''
endif

" Vicunaを使用する
if !exists('HowmHtml_Vicuna')
  let g:HowmHtml_Vicuna = ''
endif
" BODYCLASSを使用する
if !exists('HowmHtml_BodyClass')
  let g:HowmHtml_BodyClass = 'double-l'
endif
" Vicunaのサイドバーにチャプターも表示する
if !exists('HowmHtml_VicunaChapter')
  let g:HowmHtml_VicunaChapter = 0
endif
" HTMLに適用されるCSSファイル名
if !exists('HowmHtml_cssname')
  let HowmHtml_cssname = '%BASEDIR%/howm2html.css'
endif

" サムネイルサイズ (ピクセル数またはパーセント)
if !exists('HowmHtml_imgproperty')
  let HowmHtml_imgproperty = 'width ="25%"'
endif
if !exists('HowmHtml_imgproperty2')
  let HowmHtml_imgproperty2 = ''
endif
" 独自タグのコンバートレベル
" 2:はてな記法を使用
" 1:URIリンクを使用
" 0:使用しない
if !exists('HowmHtml_ConvertLevel')
  let HowmHtml_ConvertLevel = 2
endif
" コンバートに使用する関数
if !exists('g:HowmHtml_ConvertFunc')
  " let g:HowmHtml_ConvertFunc = '<SID>H2HStr2HTML'
  let g:HowmHtml_ConvertFunc = '<SID>HowmStr2HTML'
  if exists('g:qfixmemo_filetype') && g:qfixmemo_filetype == 'markdown'
    " let g:HowmHtml_ConvertFunc = '<SID>MarkdownStr2HTML'
  endif
endif
" コンバートに使用するコマンド
if !exists('g:HowmHtml_ConvertCmd')
  let g:HowmHtml_ConvertCmd = 'markdown.pl'
  " let g:HowmHtml_ConvertCmd = '"C:/Program Files/Pandoc/bin/pandoc" -f markdown'
endif
" コンバートで使用する一時ファイルのエンコーディング
if !exists('g:HowmHtml_ConvertFenc')
  let g:HowmHtml_ConvertFenc = 'utf-8'
endif

" HTML変換する時、対象外にするタイトルの正規表現
if !exists('HowmHtml_IgnoreTitle')
  let HowmHtml_IgnoreTitle = ''
endif
" -pub でHTML変換する時、対象外にするタイトルの正規表現
if !exists('HowmHtml_PublishIgnoreTitle')
  let HowmHtml_PublishIgnoreTitle = ''
endif

" タイトルのアンカー記号
if !exists('HowmHtml_Bullet')
  let HowmHtml_Bullet = '■'
endif
" <p></p> で文章を囲まずbodyに直接書く
if !exists('HowmHtml_br_mode')
  let HowmHtml_br_mode = 0
endif
" チャプターにジャンプしない場合は 0
if !exists('g:HowmHtml_Jumpmode')
  let g:HowmHtml_Jumpmode = 1
endif

if !exists('g:HowmHtml_DatePattern')
  let g:HowmHtml_DatePattern = '%Y-%m-%d %H:%M'
endif
if !exists('g:HowmHtml_JpJoinStr')
  let g:HowmHtml_JpJoinStr = 0
endif

" pdf変換用コマンド
if !exists('g:HowmHtml_html2pdf')
  let g:HowmHtml_html2pdf = '!"C:\Program Files\wkhtmltopdf\wkhtmltopdf" --disable-javascript %s'
endif
" pdf出力ディレクトリ
" 空白を含むパスは指定できない。
if !exists('g:HowmHtml_pdfdir')
  let g:HowmHtml_pdfdir = 'c:/temp'
  if has('unix')
    let g:HowmHtml_pdfdir = '~/pdf'
  endif
endif
" wkhtmltopdf用に <img src ="file:// のfile://をカット
if !exists('g:HowmHtml_pdf_imgsrc')
  let g:HowmHtml_pdf_imgsrc = 1
  if g:HowmHtml_html2pdf =~ 'wkhtmltopdf'
    let g:HowmHtml_pdf_imgsrc = 0
  endif
endif

"--------------------------------
" QFixHowm共通
"--------------------------------
" タイトル行識別子
if !exists('g:HowmHtml_Title')
  let g:HowmHtml_Title = '='
  let g:HowmHtml_Title = exists('g:QFixHowm_Title') ? g:QFixHowm_Title : g:HowmHtml_Title
  let g:HowmHtml_Title = exists('g:qfixmemo_title') ? g:qfixmemo_title : g:HowmHtml_Title
endif

" if !exists('g:howm_fileencoding')
"   let g:howm_fileencoding = &enc
" endif
" タイトル検索のエスケープパターン
if !exists('g:QFixHowm_EscapeTitle')
  let g:QFixHowm_EscapeTitle = '~*.\'
endif
" goto リンク
if !exists('g:howm_glink_pattern')
  let g:howm_glink_pattern = '>>>'
endif
" 連結表示で使用するセパレータ
if !exists('g:QFixHowm_MergeEntrySeparator')
  let g:QFixHowm_MergeEntrySeparator = "=========================="
endif
" " オートタイトル文字数
" if !exists('g:QFixHowm_Replace_Title_Len')
"   let g:QFixHowm_Replace_Title_Len = 64
" endif

" ブラウザ指定
if !exists('g:HowmHtml_OpenURIcmd')
  if exists('g:openuri_cmd') && g:openuri_cmd !~ 'netrw\|rundll32'
    let g:HowmHtml_OpenURIcmd = g:openuri_cmd
  elseif exists('g:QFixHowm_OpenURIcmd') && g:QFixHowm_OpenURIcmd !~ 'netrw\|rundll32'
    let g:HowmHtml_OpenURIcmd = g:QFixHowm_OpenURIcmd
  elseif has('unix')
    let g:HowmHtml_OpenURIcmd = "call system('firefox %s &')"
  else
    " Internet Explorer
    let g:HowmHtml_OpenURIcmd = '!start "C:/Program Files/Internet Explorer/iexplore.exe" %s'
  endif
endif

" はてなのhttp記法のゴミを取り除く
if !exists('g:HowmHtml_removeHatenaTag')
  let g:HowmHtml_removeHatenaTag = 1
endif
" スーパーpreのタグフォーマット
if !exists('g:HowmHtml_preFormat')
  let g:HowmHtml_preFormat = '<code><pre class="%s">'
endif
let g:QFixHowm_UserCmdline = 0
let s:HowmHtml_Title = '__%arienai title%=='

" エントリの内容をタグに変換する
function! HowmHtmlTagConvert(list, htmlname, anchor)
  let strlist = a:list

  " JpFormatの折り返しを元に戻す
  if g:HowmHtml_JpJoinStr && exists('g:JpFormatMarker') && g:JpFormatMarker != ''
    let strlist = s:JpJoinStr(strlist, g:JpFormatMarker)
  endif

  let func = g:HowmHtml_ConvertFunc
  let html = eval(func.'(strlist, a:htmlname, a:anchor)')

  " Vicunaサイドバー用
  if s:subheader == 1 && g:HowmHtml_VicunaChapter
    cal add(s:entries, '</ul>')
    let s:subheader = 0
  endif
  return html
endfunction

let s:mkdfile = tempname()
au VimLeave * silent! call delete(s:mkdfile)

" ノーマル変換
function! s:H2HStr2HTML(list, ...)
  let list = a:list

  let from = &enc
  let to = g:HowmHtml_ConvertFenc
  if from != to
    call map(list, 'iconv(v:val, from, to)')
  endif
  call writefile(list, s:mkdfile)
  let cmd = g:HowmHtml_ConvertCmd.' '.s:mkdfile
  let html = split(system(cmd), '[\r\n]\+')
  if from != to
    call map(html, 'iconv(v:val, to, from)')
  endif

  return html
endfunction

" markdownを変換
function! s:MarkdownStr2HTML(list, ...)
  let list = a:list
  call map(list, 'substitute(v:val, "^\\(\\[\\d\\{4}[-/]\\d\\{2}[-/]\\d\\{2}\\)\\( \\d\\{2}:\\d\\{2}\\)\\?\\(].*\\)", "<ul class=\"info\"><li class=\"date\">\\1\\2\\3</li></ul>", "")')

  let from = &enc
  let to = g:HowmHtml_ConvertFenc
  if from != to
    call map(list, 'iconv(v:val, from, to)')
  endif
  call writefile(list, s:mkdfile)
  let cmd = g:HowmHtml_ConvertCmd.' '.s:mkdfile
  let html = split(system(cmd), '[\n\r]')
  if from != to
    call map(html, 'iconv(v:val, to, from)')
  endif

  let pathhead = '\([A-Za-z]:[/\\]\|\~/\)'
  for i in range(len(html))
    let str = html[i]
    if str =~ '\[:\?.\{-}\.\(jpg\|jpeg\|png\|bmp\|gif\):.\{-}\]'
      let html[i] = s:howmLinktag(str)
    endif
  endfor

  return html
endfunction

" FIXME:いろいろおかしい
"
function! s:HowmStr2HTML(list, htmlname, anchor)
  let html = []
  let prehtml = []
  let pre    = 0
  let quote  = 0
  let header = 0
  let jump   = 0
  let table  = 0
  let list   = 0
  let define = 0
  let strlist = a:list
  let brtag = s:Blogger ? '' : '<br />'

  " 処理の都合上空行を追加
  call add(strlist, '')

  let idx = 0
  let prequote = 0
  let folding = 0
  for str in strlist
    if str =~ '^&&.*&&$'
      " 本文が && で囲まれていたら、HTMLには出力しない
      continue
    elseif str =~ '^&&'
      " 行頭のみが && なら、&& を削除してそのまま出力
      let str = substitute(str, '^&&', '', '')
      call add(html, str)
      let idx += 1
      continue
    endif
    " HTMLの使用不可文字
    " 先に一括変換してしまうので注意！
    let str = substitute(str, '&', '\&amp;', 'g')
    let str = substitute(str, '>', '\&gt;', 'g')
    let str = substitute(str, '<', '\&lt;', 'g')
    let ostr = str
    let [saved_header, saved_list, saved_table, saved_folding, saved_define] = [header, list, table, folding, define]
    if g:HowmHtml_ConvertLevel > 0
      " リンクタグ (>>> http:// c:\temp)
      let str = s:howmLinktag(str)
    endif
    if g:HowmHtml_ConvertLevel > 1
      let str = s:WikiLinkAndTag(str)
    endif

    let prevstr = str
    if g:HowmHtml_ConvertLevel > 1
      if prequote == 0
        " <ul><ol> リスト (行頭の-+)
        let [close, str, list]  = s:howmListtag(str, list)
        if close != ''
          call add(html, close)
        endif
        " <table> テーブル (|で区切る)
        let [close, str, table] = s:howmTabletag(str, table)
        if close != ''
          call add(html, close)
        endif
        " <dl> 定義リスト (:で区切る)
        let [close, str, define] = s:howmDeftag(str, define)
        if close != ''
          call add(html, close)
        endif
        if str =~ '^===='
          " 続きを読む
          let [str, folding] = s:howmFolding(str, folding, a:anchor)
        elseif str =~ '^[.*=]'
          " <h3>～<h6> .*= のアウトライン
          let [str, header, jump] = s:howmOutline(str, a:htmlname, a:anchor, header, jump)
        endif
      endif
    endif

    " preと引用
    if g:HowmHtml_ConvertLevel > 1
      if prequote == 0
        if str =~ '^&gt;|\(.*|\)\?$'
          let class = substitute(str, '^&gt;|\||$', '', 'g')
          if class == ''
            let class = '<pre>'
          else
            let class = printf(g:HowmHtml_preFormat, class)
          endif
          let str = class
          let prequote = 1
        elseif str =~ '^&gt;&gt;$'
          let str = '<blockquote><p>'
          let prequote = 2
        elseif str =~ '^&gt;\(\s\|$\)'
          call add(html, '<blockquote><p>')
          let str = str. brtag
          let prequote = 3
        endif
      elseif prequote == 1 && str =~ '^||&lt;$'
        let str = '</pre></code>'
        let prequote = 0
      elseif prequote == 1 && str =~ '^|&lt;$'
        let str = '</pre>'
        let prequote = 0
      elseif prequote == 2 && str =~ '^&lt;&lt;$'
        let str = '</p></blockquote>'
        let prequote = 0
      elseif prequote == 3 && str !~ '^&gt;\(\s\|$\)'
        call add(html, '</p></blockquote>')
        let prequote = 0
      elseif prequote
        let str = ostr
        if prequote > 1
          let str = str. brtag
        endif
      endif
    endif
    if prequote > 0
      let header = saved_header
      let folding = saved_folding
    endif
    if ostr =~ '^[.*=]' && ostr !~ '^===='
      let jump += 1
    endif

    " <p>タグでくくるか、<br />を付加
    if list != 0 && str =~ '^\t'
      let str = brtag.str
    elseif define != 0 && str =~ '^\t'
      if idx && html[-1] !~ '</dt><dd>$'
        let str = brtag.str
      endif
    elseif prevstr == str && prequote == 0
      " howmタイムスタンプ
      if str =~ '^\[\d\{4}[-/]\d\{2}[-/]\d\{2} \d\{2}:\d\{2}]\([^-@+!.~]\|$\)'
        let str = '<ul class="info"><li class="date">'.str.'</li></ul>'
        if s:Blogger
          continue
        endif
      elseif s:Blogger
        " nothing to do
      elseif g:HowmHtml_br_mode
        " if g:HowmHtml_ConvertLevel > 1
        "   let str = s:WikiLinkAndTag(str)
        " endif
        let str = str.'<br />'
      elseif str == ''
        let str = ''
      else
        " if g:HowmHtml_ConvertLevel > 1
        "   let str = s:WikiLinkAndTag(str)
        " endif
        let str = '<p>'.str.'</p>'
      endif
    endif
    " エスケープされたHTMLタグを有効化
    let str = s:howmEscapehtml(str)
    call add(html, str)
    let idx += 1
  endfor

  if g:HowmHtml_br_mode == 0 && s:Blogger == 0
    for idx in range(1, len(html)-1)
      if html[idx] =~ '^<p>' && html[idx-1] =~ '</p>$'
        let html[idx] = substitute(html[idx], '^<p>', '', '')
        let html[idx-1] = substitute(html[idx-1], '</p>$', '<br />', '')
      endif
      if html[idx]=~ '^<p></p>$'
        let html[idx] = '<br />'
      endif
      if html[idx] == '' && html[idx-1] == ''
        let html[idx-1] = '<br />'
      endif
    endfor
  endif

  " 追加した空行を削除
  call remove(html, -1)
  " 最終行が <br />なら削除
  if len(html) > 0 && html[-1] == '<br />'
    call remove(html, -1)
  endif
  " 「続きを読む」の閉じタグ
  if folding
    for n in range(folding)
      call add(html, '</div>')
    endfor
    let s:Folding = 1
  endif
  return html
endfunction

" 強調表示
if !exists('g:HowmHtml_SyntaxList')
  let g:HowmHtml_SyntaxList = [
    \ ['\*_', '\&amp;\&lt;b\&gt;\&amp;\&lt;span class="italic"\&gt;', '_\*', '\&amp;\&lt;/span\&gt;\&amp;\&lt;/b\&gt;'],
    \ ['_\*', '\&amp;\&lt;b\&gt;\&amp;\&lt;span class="italic"\&gt;', '\*_', '\&amp;\&lt;/span\&gt;\&amp;\&lt;/b\&gt;'],
    \ ['\*', '\&amp;\&lt;b\&gt;', '\*', '\&amp;\&lt;/b\&gt;'],
    \ ['\*', '\&amp;\&lt;b\&gt;', '\*', '\&amp;\&lt;/b\&gt;'],
    \ ['_', '\&amp;\&lt;span class="italic"\&gt;',   '_', '\&amp;\&lt;/span\&gt;'],
  \ ]
endif
if !exists('g:HowmHtml_SyntaxListNSP')
  let g:HowmHtml_SyntaxListNSP = [
    \ ['\~\~', '\&amp;\&lt;del\&gt;', '\~\~', '\&amp;\&lt;/del\&gt;'],
    \ ['\^', '\&amp;\&lt;sup\&gt;\&amp;\&lt;small\&gt;', '\^', '\&amp;\&lt;/small\&gt;\&amp;\&lt;/sup\&gt;'],
    \ [',,',  '\&amp;\&lt;sub\&gt;\&amp;\&lt;small\&gt;', ',,', '\&amp;\&lt;/small\&gt;\&amp;\&lt;/sub\&gt;']
  \ ]
endif

if !exists('g:HowmHtml_WikiSyntax')
  let g:HowmHtml_WikiSyntax = 0
endif
if !exists('g:HowmHtml_WikiKeyword')
  let g:HowmHtml_WikiKeyword = 0
endif
function! s:WikiLinkAndTag(str)
  let str = a:str
  if g:HowmHtml_WikiSyntax
    for tag in g:HowmHtml_SyntaxList
      " let reg = '\(^\|\s\)'.tag[0].'\([^[:space:]]'.'.\{-}'.'[^[:space:]]\)'.tag[2].'\($\|\s\)'
      let reg = '\(^\|\s\)'.tag[0].'\([^[:space:]]'.'.\{-}'.'\)'.tag[2].'\($\|\s\)'
      if str =~ reg
        let str = substitute(str, reg, tag[1].'\2'.tag[3], 'g')
        continue
      endif
    endfor
    for tag in g:HowmHtml_SyntaxListNSP
      " let reg = tag[0].'\([^[:space:]]'.'.\{-}'.'[^[:space:]]\)'.tag[2]
      let reg = tag[0].'\([^[:space:]]'.'.\{-}'.'\)'.tag[2]
      if str =~ reg
        let str = substitute(str, reg, tag[1].'\1'.tag[3], 'g')
        continue
      endif
    endfor
  endif

  " wikiスタイルリンク
  let u_token = '---h2-h--word---'
  let link = '[howm://'.u_token.'.'.g:HowmHtml_suffix.':title='.u_token.']'
  let HowmHtml_base_relmode = g:HowmHtml_base_relmode
  let g:HowmHtml_base_relmode = 1
  let link = s:howmLinktag(link)
  let g:HowmHtml_base_relmode = HowmHtml_base_relmode

  if g:HowmHtml_WikiKeyword == 1
    while 1
      if str =~ '\[\[[^\]]\+\]\]'
        let word = matchstr(str, '\[\[[^\]]\+\]\]', '')
        let word = substitute(word, '[[\]]', '', 'g')
        let str = substitute(str, '\[\[[^\]]\+\]\]', link, '')
        let str = substitute(str, u_token, word, 'g')
        continue
      endif
      break
    endwhile
  elseif g:HowmHtml_WikiKeyword == 2
    let link = substitute(link, '^\[\|]$', '', 'g')
    let KeywordDic = QFixHowmGetKeyword()
    for word in KeywordDic
      let str = substitute(str, '\V'.escape(word, '\'), link, 'g')
      let str = substitute(str, u_token, word, 'g')
    endfor
  endif
  return str
endfunction

if !exists('g:HowmHtml_KeywordList')
  let g:HowmHtml_KeywordList = []
endif

silent! function QFixHowmGetKeyword()
  return g:HowmHtml_KeywordList
endfunction

"
" HTMLヘッダ出力
"
function! HowmHTML(type, ...)
  let from = &enc
  let to   = g:HowmHtml_encoding
  let to   = to == 'Shift_JIS' ? 'cp932' : to
  let fenc = g:HowmHtml_encoding

  if a:type == 'footer'
    let foot = []
    call extend(foot, g:HowmHtml_HttpFooter)
    if a:0
      call extend(foot, a:1, g:HowmHtml_HttpFooterExtend)
    endif
    let root = s:root
    call map(foot, 'substitute(v:val, "%DATE%", s:date, "g")')
    call map(foot, 'substitute(v:val, "%ROOT%", root, "g")')
    call map(foot, 'substitute(v:val, "%BASEDIR%/\\?", s:basedir, "g")')
    call map(foot, 'substitute(v:val, "%VERSION%", s:version, "g")')
    call map(foot, 'iconv(v:val, from, to)')
    return foot
  endif

  let title = ''
  let file = ''
  let summary = ''
  if a:0
    let title = fnamemodify(a:1, ':p:t:r')
    let file = fnamemodify(a:1, ':p:r')
    let suffix = 'howm'
    if exists('g:qfixmemo_ext')
      let suffix = g:qfixmemo_ext
    elseif exists('g:QFixHowm_FileExt')
      let suffix = g:QFixHowm_FileExt
    endif
    let file  = file .'.'. suffix
  endif

  if a:0 > 1
    let subject = substitute(a:2, '^. ', '', '')
    let htmlname = a:3
  else
    let subject = file
    let htmlname = g:HowmHtml_DefaultName
  endif

  let sightname = g:HowmHtml_SightName
  let description = substitute(file, '\\', '/', 'g')
  if g:HowmHtml_Description != ''
    let description = g:HowmHtml_Description
  endif

  let header = deepcopy(g:HowmHtml_HttpHeader)
  if exists('g:HowmHtml_UserScript')
    let header = extend(header, g:HowmHtml_UserScript)
  endif
  let header = extend(header, g:HowmHtml_HttpBody)

  let title = escape(title, '"')
  let sightname = escape(sightname, '\\"')
  let subject = escape(subject, '\\"')
  let description = escape(description, '\\"')
  let cssname = s:HowmHtml_cssname
  if htmlname != g:HowmHtml_DefaultName && cssname !~ '%BASEDIR%\|%ROOT%'
    let cssname = '%BASEDIR%'.s:HowmHtml_cssname
  endif

  let root = s:root

  call map(header, 'substitute(v:val, "%ENCODING%", fenc, "g")')
  call map(header, 'substitute(v:val, "%TITLE%", title, "g")')
  call map(header, 'substitute(v:val, "%VICUNA%", g:HowmHtml_Vicuna, "g")')
  let bodyclass = g:HowmHtml_Vicuna == '' ? g:HowmHtml_BodyClass : g:HowmHtml_Vicuna
  call map(header, 'substitute(v:val, "%BODYCLASS%", bodyclass, "g")')
  call map(header, 'substitute(v:val, "%CSSNAME%", cssname, "g")')
  call map(header, 'substitute(v:val, "%SIGHTNAME%", sightname, "g")')
  call map(header, 'substitute(v:val, "%DESCRIPTION%", description, "g")')
  call map(header, 'substitute(v:val, "%ROOT%", root, "g")')
  call map(header, 'substitute(v:val, "%BASEDIR%/\\?", s:basedir, "g")')
  call map(header, 'substitute(v:val, "%FILENAME%", file, "g")')
  call map(header, 'substitute(v:val, "%SUBJECT%", subject, "g")')
  call map(header, 'substitute(v:val, "%VERSION%", s:version, "g")')
  call map(header, 'iconv(v:val, from, to)')
  return header
endfunction

" HTML出力本体
function! HowmHtmlConvert(list, htmlname)
  let htmlname = a:htmlname
  let from = &enc
  " HTMLの文字エンコーディング
  let to   = g:HowmHtml_encoding
  let to   = to == 'Shift_JIS' ? 'cp932' : to

  let html = []

  " メインループ
  let anchor = 0
  let s:entries = []
  let s:Folding = 0
  let footscript = []
  let bullet = g:HowmHtml_Bullet
  for d in a:list
    " タイトル行
    let fline = d['start']
    let fname = d['filename']
    let anchor = d['index']+1

    let g:HowmHtml_Title = '='
    let g:HowmHtml_Title = exists('g:QFixHowm_Title') ? g:QFixHowm_Title : g:HowmHtml_Title
    let g:HowmHtml_Title = exists('g:qfixmemo_title') ? g:qfixmemo_title : g:HowmHtml_Title
    let l:HowmHtml_Title = escape(g:HowmHtml_Title, g:QFixHowm_EscapeTitle)
    if l:HowmHtml_Title == ''
      let l:HowmHtml_Title = s:HowmHtml_Title
    endif
    let title = substitute(d['title'], '^'.l:HowmHtml_Title, '', '')
    let pattern = '<a href="#t%s" title="t%s" name="t%s" id="t%s">%s</a>%s'
    if g:HowmHtml_BodyClass != '' || g:HowmHtml_Vicuna != '' || bullet == ''
      let pattern = '<a href="#t%s" title="t%s" name="t%s" id="t%s">%s%s</a>'
      call add(s:entries, '<li><a href="#t'.anchor.'" title="t'.anchor.'">'.title.'</a></li>')
    endif
    let atitle = printf(pattern, anchor, anchor, anchor, anchor, bullet, title)

    " タグの変換
    let s:subheader = 0
    let text = HowmHtmlTagConvert(d['text'], htmlname, anchor)

    " エントリに構造を付加
    let tlevel = 2 + s:Blogger
    let esection = printf('<div class="section entry" id="e%s"><h%d>%s</h%d>', anchor, tlevel, atitle, tlevel)
    call insert(text, '<div class="textBody">')
    call insert(text, esection)
    call add(text, '</div></div>')
    call map(text, 'iconv(v:val, from, to)')

    let html = extend(html, text)
  endfor

  if s:Blogger
    let from = g:HowmHtml_encoding
    let from = from == 'Shift_JIS' ? 'cp932' : to
    let to   = 'utf-8'
    call map(html, 'iconv(v:val, from, to)')
    return html
  endif

  if g:HowmHtml_Vicuna != '' || g:HowmHtml_BodyClass != ''
    let topicPath = g:HowmHtml_TopicPath
    call map(topicPath, 'substitute(v:val, "%ROOT%", s:root, "")')
    call map(topicPath, 'substitute(v:val, "%BASEDIR%/\\?", s:basedir, "g")')
    call map(topicPath, 'iconv(v:val, from, to)')
    call extend(html, topicPath)
  endif

  if (g:HowmHtml_Vicuna != '' && g:HowmHtml_Vicuna !~ 'single') || (g:HowmHtml_BodyClass != '' && g:HowmHtml_BodyClass !~ 'single')
    call extend(html, s:VicunaUtil('multi'))
  endif

  " HTMLヘッダ
  let html = extend(HowmHTML('header', fnamemodify(a:list[0]['filename'], ':p'), a:list[0]['title'], htmlname), html)
  " HTMLフッタ
  if s:Folding == 1
    call extend(footscript, g:HowmHtml_Folding)
    call map(footscript, 'substitute(v:val, "%ENTRIES%", anchor, "")')
    call map(footscript, 'iconv(v:val, from, to)')
  endif
  call extend(html, HowmHTML('footer', footscript))
  return html
endfunction

let s:LocalLink = 1
let s:h2hfile = ''
" コンバータ呼び出し
" ファイルの入出力など
function! howm2html#Howm2html(output, ...)
  let l:QFixHowm_FileExt = 'howm'
  if exists('g:qfixmemo_ext')
    let l:QFixHowm_FileExt = g:qfixmemo_ext
  elseif exists('g:QFixHowm_FileExt')
    let l:QFixHowm_FileExt = g:QFixHowm_FileExt
  endif

  let save_cursor = getpos('.')
  let htmldir  = g:HowmHtml_htmldir
  let htmlname = g:HowmHtml_DefaultName
  let glist = ['']
  let file = substitute(fnamemodify(expand('%'), ':p'), '\\', '/', 'g')
  let publish = ''
  let s:publish = publish
  let currentmode = 0
  let jumpmode = 1
  let readmode = 0
  let pname = ''
  let pdf = 0
  let s:LocalLink = 1
  let locallink = 0
  let s:Blogger = 0
  let s:date = strftime(g:HowmHtml_DatePattern)
  let s:HowmHtml_cssname = g:HowmHtml_cssname
  if g:HowmHtml_Vicuna != ''
    let s:HowmHtml_cssname = '%BASEDIR%/vicuna.css'
  endif
  if exists('g:QFixHowm_RelPath')
    let g:HowmHtml_RelPath = g:QFixHowm_RelPath
  endif
  let s:HowmHtml_RelPath = g:HowmHtml_RelPath
  let s:howm_dir = '~/howm'
  if exists('g:qfixmemo_dir')
    let s:howm_dir = g:qfixmemo_dir
  elseif exists('g:howm_dir')
    let s:howm_dir = g:howm_dir
  endif
  let s:HowmHtml_basedir = g:HowmHtml_basedir
  let indexmode = 0
  if s:h2hfile != ''
    let file = s:h2hfile
    let htmlname = fnamemodify(file, g:HowmHtml_suffix_mode).'.'.g:HowmHtml_suffix
  endif
  let s:h2hfile = ''
  redraw|echo 'Howm2html : Processing...'
  for d in a:000
    if d =~ '^-cursor$' || d =~ '^-current$'
      let currentmode = 1
      let jumpmode = 1
      let readmode = 0
    elseif d =~ '^-Blogger$'
      let s:Blogger = 1
      let s:HowmHtml_RelPath = g:HowmHtml_publish_RelPath
      " let s:howm_dir = g:howm_publish_dir
      let s:publish = '(publish)'
      let s:LocalLink = 0
      let htmldir = g:HowmHtml_publish_htmldir
    elseif d =~ '^-nolocallink$'
      let locallink = -1
    elseif d =~ '^-pdf$'
      let pdf = 1
    elseif d =~ '^-locallink$'
      let locallink = 1
    elseif d =~ '^-publish\d*$' || d =~ '^-pub\d*$'
      let pname = substitute(d, '^-', '', '')
      let pname = substitute(pname, 'pub\(\d*\)$', 'publish\1', '')
      let pname = substitute(pname, 'public', 'publish', '')
      exec 'let htmldir = g:HowmHtml_'.pname.'_htmldir'
      let publish = '('.pname.')'
      let pname = match(pname, '\d\+$')
      if exists('g:HowmHtml_PublishLocalLink')
        let s:LocalLink = g:HowmHtml_PublishLocalLink
      endif
      let s:HowmHtml_RelPath = g:HowmHtml_publish_RelPath
      " let s:howm_dir = g:howm_publish_dir
      let s:publish = publish
    elseif d =~ '^-ref$' || d =~ '^-include$'
      let s:HowmHtml_basedir = g:HowmHtml_ref_basedir
      if htmlname == g:HowmHtml_DefaultName
        let file = expand('%')
        let file = fnamemodify(file, ':p')
        let htmlname = fnamemodify(file, g:HowmHtml_suffix_mode).'.'.g:HowmHtml_suffix
      endif
      let indexmode = 1
    elseif d !~ '^-' && d != '' && currentmode == 0
      let readmode = 1
      if d != '%'
        let jumpmode = 0
      endif
      let d = substitute(d, '^"\|"$', '', 'g')
      let d = substitute(d, 'memo://', 'howm://', '')
      let d = substitute(d, 'howm://', s:howm_dir.'/', '')
      let file = expand(d)
      let file = fnamemodify(file, ':p')
      if !filereadable(file)
        echoe "file does not readable : ".file
        return
      endif
      let htmlname = fnamemodify(file, g:HowmHtml_suffix_mode).'.'.g:HowmHtml_suffix
    endif
  endfor

  let ext = fnamemodify(file, ':e')
  if file =~ '\.ref\.'.ext.'$'
    let s:HowmHtml_basedir = g:HowmHtml_ref_basedir
    let htmlname = fnamemodify(file, ':t')
    let htmlname = substitute(htmlname, '\.ref\.'.ext .'$', '\.'.g:HowmHtml_suffix, '')
    let indexmode = 1
  endif
  if publish != '' && htmlname == g:HowmHtml_DefaultName
    let htmlname = fnamemodify(file, ':t')
    let htmlname = substitute(htmlname, '\.ref\.'.ext .'$', '\.'.g:HowmHtml_suffix, '')
    let htmlname = fnamemodify(htmlname, g:HowmHtml_suffix_mode).'.'.g:HowmHtml_suffix
  endif
  if locallink != 0
    let s:LocalLink = locallink == -1 ? 0 : 1
  endif
  let s:basedir = ''
  if s:HowmHtml_basedir != ''
    let srcdir = QFixNormalizePath(fnamemodify(expand(file), ':p:h'))
    let basedir = g:HowmHtml_ref_basedir
    let basedir = QFixNormalizePath(fnamemodify(expand(basedir), ':p:h'))
    if match(srcdir, basedir) == -1
      let basedir = g:HowmHtml_basedir
      let basedir = QFixNormalizePath(fnamemodify(expand(basedir), ':p:h'))
      let publish = ''
      let htmldir  = g:HowmHtml_htmldir
      let htmlname = g:HowmHtml_DefaultName
    endif
    let bdir = ''
    if basedir != srcdir
      let bdir = s:Convert2Relpath(srcdir, basedir)
      if htmlname != g:HowmHtml_DefaultName
        let htmldir = htmldir.'/'.bdir
        let htmldir = substitute(htmldir, '/$', '', '')
      endif
      let bdir = s:Convert2Relpath(basedir, srcdir)
    endif
    let s:basedir = bdir
  endif
  if htmlname == g:HowmHtml_DefaultName
    let s:basedir = ''
  endif
  " let s:HowmHtml_basedir = g:HowmHtml_basedir
  if indexmode
    " let s:HowmHtml_basedir = g:HowmHtml_ref_basedir
  endif
  if publish == ''
    let s:root = g:HowmHtml_root
  else
    let s:root = g:HowmHtml_publish_root
  endif
  if !bufloaded(file) && !filereadable(file)
    let glist = getline(1, line('$'))
  endif

  " ファイル指定ならバッファを開いて読込
  " if readmode == 1
    silent! exec 'split '
    silent! exec 'silent! e '.s:howmtempfile
    setlocal buftype=nofile
    setlocal noswapfile
    setlocal bufhidden=hide
    setlocal nobuflisted

    silent! %delete _
    if bufloaded(file) "バッファが存在する場合
      let glist = getbufline(file, 1,'$')
      call setline(1, glist)
    elseif filereadable(file)
      let cmd = '-r '
      let ftype = fnamemodify(file, ':e')

      if exists('g:loaded_qfixmemo_init') && ftype == g:qfixmemo_ext
        if exists('g:qfixmemo_fileencoding') && exists('g:qfixmemo_forceencoding') && g:qfixmemo_forceencoding
          let cmd = cmd.' ++enc='.g:qfixmemo_fileencoding
        endif
      elseif exists('g:loaded_MyHowm') && ftype == g:QFixHowm_FileExt
        if exists('g:howm_fileencoding') && exists('g:QFixHowm_ForceEncoding') && g:QFixHowm_ForceEncoding
          let cmd = cmd.' ++enc='.g:howm_fileencoding
        endif
      endif
      silent! exec cmd.' '.escape(expand(file), ' ')
      silent! $delete _
    else
      call setline(1, glist)
    endif
    if indexmode == 1
      let suffix = '\.howm$'
      if exists('g:qfixmemo_ext')
        let suffix = '\.'.g:qfixmemo_ext . '$'
      elseif exists('g:QFixHowm_FileExt')
        let suffix = '\.'.g:QFixHowm_FileExt . '$'
      endif
      let glist = ['']
      for n in range(1, line('$'))
        let str = getline(n)
        if str =~ '^&&'
          call add(glist, str)
          continue
        endif
        let str = substitute(str, '|.*$', '', '')
        if str =~ suffix
          let ifile = substitute(str, '^\s*\('.g:howm_glink_pattern.'\|file://\)\s*', '', '')
          let ifile = substitute(ifile, 'memo://', 'howm://', '')
          let relpath = g:HowmHtml_root
          let ifile = substitute(ifile, 'howm://%ROOT%', escape(relpath, '%#'), '')
          let relpath = s:howm_dir . (ifile =~ 'howm://[^/\\]' ? '/' : '')
          let ifile = substitute(ifile, 'howm://', relpath, '')
          let relpath = g:HowmHtml_RelPath . (ifile =~ 'rel://[^/\\]' ? '/' : '')
          let ifile = substitute(ifile, 'rel://', relpath, '')
          let path = fnamemodify(file, ':p:h')
          silent exec 'lchdir ' . escape(path, ' ')
          let ifile = fnamemodify(expand(ifile), ':p')
          if filereadable(ifile)
            let alttext = readfile(ifile)
            if len(alttext)
              let from = &enc
              let from = exists('g:howm_fileencoding') ? g:howm_fileencoding : from
              let from = exists('g:qfixmemo_fileencoding') ? g:qfixmemo_fileencoding : from
              call map(alttext, 'iconv(v:val, from, &enc)')
              call extend(glist, alttext)
            endif
          endif
        endif
      endfor
      silent! 1,$delete _
      call setline(1, glist)
    endif
    call HowmHtmlCodeHighlight(file)
    if exists('*HowmHtmlUserProc') && exists('g:fudist')
      call HowmHtmlUserProc(file)
    endif
  " endif

  let g:HowmHtml_Title = '='
  let g:HowmHtml_Title = exists('g:QFixHowm_Title') ? g:QFixHowm_Title : g:HowmHtml_Title
  let g:HowmHtml_Title = exists('g:qfixmemo_title') ? g:qfixmemo_title : g:HowmHtml_Title
  let l:HowmHtml_Title = escape(g:HowmHtml_Title, g:QFixHowm_EscapeTitle)
  if l:HowmHtml_Title == ''
    let l:HowmHtml_Title = s:HowmHtml_Title
  endif
  let pattern = '^'.l:HowmHtml_Title.'\(\s\|$\)'

  if getline('.') =~ '^'.g:QFixHowm_MergeEntrySeparator.g:howm_glink_pattern
    call cursor(line('.')+1, '1')
  endif
  if currentmode
    call setpos('.', save_cursor)
  endif
  let fline = search(pattern, 'cbW')
  let entryline = fline
  call cursor(1, 1)
  let fline = search(pattern, 'cW')

  let list = []
  let idx = 0
  while fline > 0
    let lline = search(pattern, 'W')
    let lline = (lline == 0 ? line('$') : lline - 1)
    let llineofs = 0
    if getline(lline) =~ '^'.g:QFixHowm_MergeEntrySeparator.g:howm_glink_pattern
      let llineofs = 1
    endif
    let flag = 1

    if g:HowmHtml_IgnoreTitle != ''
      if getline(fline) =~ g:HowmHtml_IgnoreTitle
        let flag = 0
      endif
    endif
    if g:HowmHtml_PublishIgnoreTitle != ''
      if publish != '' && getline(fline) =~ g:HowmHtml_PublishIgnoreTitle
        let flag = 0
      endif
    endif
    if currentmode && fline != entryline
      let flag = 0
    endif
    if flag
      let text = getline(fline+1, lline-llineofs)
      let dat = {"title": getline(fline), "text": text, "filename": file, "start":fline, "end":lline-llineofs, "flag":flag, "index":idx}
      call add(list, dat)
    endif
    if lline == line('$')
      break
    endif
    let fline = lline+1
    if flag
      let idx += 1
    endif
  endwhile

  if list == []
    let title = ''
    let text = getline(1, '$')
    let trlen = 64
    let trlen = exists('g:QFixHowm_Replace_Title_Len') ? g:QFixHowm_Replace_Title_Len : trlen
    let trlen = exists('g:qfixmemo_title_length') ? g:qfixmemo_title_length : trlen
    for d in text
      if d !~ '^\s*$'
        let title = substitute(text[0], '\%>'.trlen.'v.*','','')
        if strlen(text[0]) > trlen
          let title = title . '...'
        endif
        break
      else
        call remove(text, 0)
      endif
    endfor
    if title == '' && len(text) == 0
      call setpos('.', save_cursor)
      echohl ErrorMsg
      redraw|echo 'Howm2html : No entry!'
      echohl None
      " if readmode == 1
        setlocal buftype=nofile
        silent! bd!
      " endif
      return
    endif
    let dat = {"title": title, "text": text, "filename": file, "start":1, "end":len(text)+1, "flag":1, "index":1}
    call add(list, dat)
  endif

  " if readmode == 1
    setlocal buftype=nofile
    silent! bd!
  " endif

  let htmldir = expand(htmldir)
  if isdirectory(htmldir) == 0
    call mkdir(htmldir, 'p')
  endif
  let s:htmldir = htmldir

  let start = reltime()
  let html = HowmHtmlConvert(list, htmlname)
  " echoe reltimestr(reltime(start))
  if s:Blogger
    let g:HowmHtml_Blogger = ''
    for d in html
      let g:HowmHtml_Blogger = g:HowmHtml_Blogger."\<NL>". d
    endfor
    silent! call setreg('*', g:HowmHtml_Blogger)
    silent! call setreg('"', g:HowmHtml_Blogger)
    return html
  endif

  " html出力
  let file = expand(htmldir.'/'.htmlname)
  let hdir = fnamemodify(file, ':h')
  if isdirectory(hdir) == 0
    call mkdir(hdir, 'p')
  endif
  call writefile(html, file)

  call setpos('.', save_cursor)
  redraw|echo 'Howm2html'.publish.' : ' . file
  if pdf
    if g:HowmHtml_pdf_imgsrc == 0
      let file = htmldir.'/'.htmlname.'.pdf.html'
      let file = expand(file)
      call map(html, 'substitute(v:val, "<img src=\"file://", "<img src=\"", "g")')
      call writefile(html, file)
    endif
    let pdfname = g:HowmHtml_pdfdir.'/'. fnamemodify(htmlname, ':t:r') .'.pdf'
    " 変換処理呼び出し
    let cmd = g:HowmHtml_html2pdf
    let param = file . ' ' . pdfname
    let cmd = substitute(cmd, '%s', escape(param, '&'), '')
    let cmd = escape(cmd, '%#')
    silent exec cmd
    if g:HowmHtml_pdf_imgsrc == 0 && filereadable(file)
      call delete(file)
    endif
    redraw|echo 'Html2pdf'.publish.' : ' . file
  endif

  " ブラウザ起動
  if a:output && pdf == 0
    let uri = 'file://'.file
    if jumpmode
      let anchor = s:getanchor()
      let uri = uri . anchor
    endif
    call s:OpenUri(uri)
  endif
endfunction

" スーパーpreをコードハイライト
if !exists('g:HowmHtml_CodeHighlight')
  let g:HowmHtml_CodeHighlight = 1
endif
" コードハイライトに使うカラースキーム
if !exists('g:HowmHtml_colorscheme')
  let g:HowmHtml_colorscheme = 'peachpuff'
endif
" 2html.vimの場所
if !exists('g:HowmHtml_2html')
  let g:HowmHtml_2html = 'syntax/2html.vim'
endif

func! HowmHtmlCodeHighlight(file)
  if !g:HowmHtml_CodeHighlight
    return
  endif
  if g:HowmHtml_ConvertFunc == '<SID>H2HStr2HTML'
    return
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
    let class = substitute(getline(firstline), '^>|\||$', '', 'g')
    let class = printf(g:HowmHtml_preFormat, class)
    if g:HowmHtml_ConvertFunc != '<SID>HowmStr2HTML'
      call setline(firstline, class)
      call setline(lastline, '</pre></code>')
    endif
    let firstline += 1
    let lastline -= 1
    let rstr = s:Convert2HTMLCode(firstline, lastline, type, 'xhtml')
    call map(rstr, "substitute(v:val, '<br\\( /\\)\\?>$', '', '')")
    if g:HowmHtml_ConvertFunc == '<SID>HowmStr2HTML'
      " howm2html用に &&を埋め込み
      call map(rstr, '"&&" . v:val')
    endif
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
  let g:fudist_manual = 1
endif

function! s:JpJoinStr(str, marker)
  if len(a:str) == 0
    return []
  endif
  let str = []
  let idx = 0
  let prev = ''
  for s in a:str
    if prev =~ a:marker.'$'
      let str[idx-1] = substitute(str[idx-1], a:marker.'$', '', '').s
    else
      let str = add(str, s)
      let idx += 1
    endif
    let prev = s
  endfor
  return str
endfunction

" ユーザーコマンド
command! -bang -nargs=* -range=% Howm2html call howm2html#Howm2html(<bang>0, <f-args>)
command! -bang -nargs=* Jump2html          call howm2html#Jump2html(<bang>0, <f-args>)
command! -nargs=* HowmHtmlConvFiles        call howm2html#HowmHtmlConvFiles('%', <q-args>)
command! -nargs=* -bang HowmHtmlUpdate     call howm2html#HowmHtmlConvFiles('%', <q-args>, '<bang>')

if !exists('s:howmtempfile')
  let s:howmtempfile = tempname()
endif

" カーソル位置のHTMLを開く
function! howm2html#Jump2html(mode, ...)
  let pdir = g:HowmHtml_publish_htmldir
  let pmode = '(publish)'
  let opt = ''
  for d in a:000
    if d =~ '^-current$' || d =~ '^-cursor$'
      let opt = d
    endif
  endfor
  let dir = [pdir, g:HowmHtml_htmldir]
  if a:mode == 1
    let dir = [g:HowmHtml_htmldir, pdir]
  endif

  let reldir = ''
  if !exists('s:HowmHtml_basedir')
    let s:HowmHtml_basedir = g:HowmHtml_basedir
  endif
  if s:HowmHtml_basedir != ''
    let srcdir = expand(fnamemodify(expand('%'), ':p:h'))
    let reldir = substitute(srcdir, '^'.expand(s:HowmHtml_basedir), '', '')
    if reldir == srcdir
      let reldir = ''
    endif
  endif
  let htmlname = fnamemodify(expand('%'), g:HowmHtml_suffix_mode).'.'.g:HowmHtml_suffix
  for idx in range(2)
    let htmldir = dir[idx].reldir
    let file = expand(htmldir.'/'.htmlname)
    if filereadable(file)
      let idx = -1
      break
    endif
  endfor
  if idx != -1
    exec 'Howm2html! '.opt
    redraw|echo 'Jump2html : Temporary mode!'
    return
  endif
  let pmode = htmldir == pdir.reldir ? "(publish) " : ""

  let file = substitute(file, '\\', '/', 'g')
  let uri = 'file://'.file
  let save_cursor = getpos('.')
  let g:HowmHtml_Title = '='
  let g:HowmHtml_Title = exists('g:QFixHowm_Title') ? g:QFixHowm_Title : g:HowmHtml_Title
  let g:HowmHtml_Title = exists('g:qfixmemo_title') ? g:qfixmemo_title : g:HowmHtml_Title
  let l:HowmHtml_Title = escape(g:HowmHtml_Title, g:QFixHowm_EscapeTitle)
  if l:HowmHtml_Title == ''
    let l:HowmHtml_Title = s:HowmHtml_Title
  endif
  let pattern = '^'.l:HowmHtml_Title.'\(\s\|$\)'
  let fline = search(pattern, 'cbW')
  let tline = fline
  if fline == 0
    echohl ErrorMsg
    redraw|echo 'Jump2html : No entry!'
    echohl None
    return
  endif
  call setpos('.', save_cursor)
  let anchor = s:getanchor()
  let file = file . anchor
  let uri = 'file://'.file
  redraw|echo 'Jump2html'.pmode.' : '.htmlname.anchor
  call s:OpenUri(uri)
endfunction

function! s:getanchor()
  let save_cursor = getpos('.')
  let prevline = line('.')
  let g:HowmHtml_Title = '='
  let g:HowmHtml_Title = exists('g:QFixHowm_Title') ? g:QFixHowm_Title : g:HowmHtml_Title
  let g:HowmHtml_Title = exists('g:qfixmemo_title') ? g:qfixmemo_title : g:HowmHtml_Title
  let l:HowmHtml_Title = escape(g:HowmHtml_Title, g:QFixHowm_EscapeTitle)
  if l:HowmHtml_Title == ''
    let l:HowmHtml_Title = s:HowmHtml_Title
  endif
  let pattern = '^'.l:HowmHtml_Title.'\(\s\|$\)'
  let fline = search(pattern, 'cbW')
  if fline == 0
    return ''
  endif
  let tline = fline
  let idx = 0
  while 1
    let fline = search(pattern, 'bW')
    if fline == 0
      break
    endif
    let idx += 1
  endwhile
  let idx += 1
  let anchor = '#e'.idx
  let janchor = '#j'.idx

  call setpos('.', save_cursor)

  let pattern = '.*='
  let pattern = '^['.pattern.']'
  let idx = -1
  call cursor(tline, '1')
  while 1
    let hline = search(pattern, 'W')
    if hline == 0
      break
    endif
    if hline > prevline
      break
    endif
    if getline(hline) =~ '^===='
      continue
    endif
    let idx += 1
  endwhile
  if idx > -1 && g:HowmHtml_Jumpmode == 1
    let anchor = janchor.idx
  endif
  call setpos('.', save_cursor)
  return anchor
endfunction

" ブラウザ起動
function! s:OpenUri(uri)
  let cmd = ''
  let uri = a:uri
  let done = 0
  if g:HowmHtml_OpenURIcmd =~ '^\s*netrw'
    let uri = substitute(uri, '\\', '/', 'g')
    silent! let done = openuri#open(uri)
    if done
      return 1
    endif
  endif
  let uri = substitute(uri, '\\', '/', 'g')
  if exists('g:HowmHtml_OpenURIcmd') && g:HowmHtml_OpenURIcmd != ''
    if g:HowmHtml_OpenURIcmd !~ 'iexplore.exe'
      let uri = substitute(uri, ' ', '%20', 'g')
    endif
    let cmd = g:HowmHtml_OpenURIcmd
    let cmd = substitute(cmd, '^netrw|', '', '')
    let cmd = substitute(cmd, '%s', escape(uri, '&'), '')
    let cmd = escape(cmd, '%#')
    silent exec cmd
    return 1
  endif
endfunction

let s:firstrun = 0
" エクスポートコマンド
silent! function QFixHowmUserCmd(list)
  let htmldir  = g:HowmHtml_htmldir
  let htmlname = g:HowmHtml_DefaultName
  let s:date = strftime(g:HowmHtml_DatePattern)
  let s:publish = ''
  let s:HowmHtml_basedir = g:HowmHtml_basedir
  let s:Blogger = 0

  let s:HowmHtml_cssname = g:HowmHtml_cssname
  if g:HowmHtml_Vicuna != ''
    let s:HowmHtml_cssname = '%BASEDIR%/vicuna.css'
  endif
  if exists('g:QFixHowm_RelPath')
    let g:HowmHtml_RelPath = g:QFixHowm_RelPath
  endif
  let s:HowmHtml_RelPath = g:HowmHtml_RelPath
  let s:howm_dir = '~/howm'
  if exists('g:qfixmemo_dir')
    let s:howm_dir = g:qfixmemo_dir
  elseif exists('g:howm_dir')
    let s:howm_dir = g:howm_dir
  endif
  let s:basedir = ''
  let s:root = g:HowmHtml_root

  let htmldir = expand(htmldir)
  if isdirectory(htmldir) == 0
    call mkdir(htmldir, 'p')
  endif
  let list = deepcopy(a:list)
  for idx in range(len(list))
    let list[idx]['index'] = idx
  endfor
  let html = HowmHtmlConvert(list, htmlname)

  " html出力
  let file = htmldir.'/'.htmlname
  let hdir = fnamemodify(expand(file), ':h')
  if isdirectory(hdir) == 0
    call mkdir(hdir, 'p')
  endif
  call writefile(html, file)

  let tidx = ''
  if g:QFixHowm_UserCmdline > 0
    let tidx = '#e'.g:QFixHowm_UserCmdline
  endif
  redraw|echom 'Howm2html : ' . file
  " ブラウザ起動
  let uri = 'file://'.file.tidx
  call s:OpenUri(uri)

  " Quickfixウィンドウを開く
  OpenQFixWin
  let s:firstrun = 1
endfunction

" エスケープされたHTMLタグ
function! s:howmEscapehtml(str)
  let str = a:str
  let lstr = matchstr(str, '&amp;&lt;.*')
  if lstr == ''
    return str
  endif
  let str = substitute(str, '&amp;&lt;.*', '' ,'')
  while lstr != ''
    let lstr = substitute(lstr, '&amp;&lt;', '<', '')
    let lstr = substitute(lstr, '&gt;', '>', '')
    let tstr = matchstr(lstr, '^[^>]*>')
    let lstr = substitute(lstr, '^[^>]*>', '', '')
    let str = str . tstr . substitute(lstr, '&amp;&lt;.*', '', '')
    let lstr = matchstr(lstr, '&amp;&lt;.*')
  endwhile
  return str
endfunction

" 末尾に<br />を付加
function! s:howmAddbr(str)
  let str = a:str
  let lstr = a:str
  let lstr = substitute(lstr, '&lt;', '<', 'g')
  let lstr = substitute(lstr, '&gt;', '>', 'g')
  let do = 1

  let do -= (str =~ '<[^>]\+>$')
  let do -= (lstr =~ '&amp;<[^<>]\+>$')
  let do += (str =~ '</a>$')

  if do > 0
    let str = substitute(str, '$', '<br />', '')
  endif
  return str
endfunction

" リスト
let s:ptag = []
function! s:howmListtag(str, list)
  let str = a:str
  let idx = a:list
  let etag = {'-' : 'ul', '+' : "ol"}
  " let lreg= '^\s*[-+]'
  let lreg= '^[-+]'
  let close = ''

  let h = matchstr(str, lreg)
  let h = matchstr(h, '[^[:space:]]\+')
  let i = h == '' ? 0 : len(matchstr(str, h.'\+'))
  if h != ''
    let str = substitute(str, lreg.'\+', '', '')
  endif

  let listtop = 1
  if h != ''
    if len(s:ptag) > 0
      let pt = s:ptag[-1]
      let ct = etag[h]
      if pt != ct
        let listtop = 0
      endif
    endif
  endif
  if listtop == 0
"    return [close, str, idx]
  endif

  if i > idx && h != ''
    let l = i - idx
    let tag = ''
    for n in range(l)
      let tag = tag.'<'.etag[h].'>'
      call add(s:ptag, etag[h])
    endfor
    let str = tag.'<li>'.str
    let idx += l
  elseif i < idx && h != ''
    let l = idx - i
    for n in range(l)
      let close = '</li></'.s:ptag[-1].'>'.close
      call remove(s:ptag, -1)
    endfor
    let idx -= l
    let str = '<li>'.str
  elseif i == idx && h != ''
    let str = '</li><li>'.str
  elseif idx > 0 && h == '' && str =~ '^\t'
    " 行頭がタブならリストの文章
  elseif idx > 0 && h == ''
    for d in s:ptag
      let close = '</li></'.d.'>'.close
    endfor
    let s:ptag = []
    let idx = 0
  endif
  return [close, str, idx]
endfunction

" テーブルタグ
function! s:howmTabletag(str, table)
  let str = a:str
  let table = a:table
  let close = ''
  if (table == 0 && str !~ '^|') || (table && (str !~ '^|\|^\t'))
    if table == 1
      let table = 0
      let close = '</table>'
    endif
    return [close, str, table]
  endif
  let str = substitute(str, '|', '||', 'g')
  if str =~ '^\t'
    let str = substitute(str, '|', '</td>', '')
    let str = substitute(str, '^\t', '<br />', '')
  endif
  let str = substitute(str, '^|\||$', '', 'g')
  let str = substitute(str, '^|', '<tr>|', 'g')
  let str = substitute(str, '|$', '|</tr>', 'g')
  let str = substitute(str, '|\s*\*\([^|]*\)|', '<th>\1</th>', 'g')
  let str = substitute(str, '|\([^|]*\)|', '<td>\1</td>', 'g')
  let str = substitute(str, '</td>|', '</td><td>', '')
  let str = substitute(str, '|</tr>', '</td></tr>', '')
  let str = substitute(str, '|', '<td>', '')
  if table == 0
    let str = '<table>' . str
  endif
  let table = 1
  return [close, str, table]
endfunction

" 定義リストタグ
function! s:howmDeftag(str, define)
  let str = a:str
  let define = a:define
  let close = ''
  " if str !~ '^:.\+\s\+:.\+'
  if str !~ '^:.\+\s\+:'
    if define == 1
      if str !~ '^\t'
        let define = 0
        let close = '</dd></dl>'
      endif
    endif
    return [close, str, define]
  endif
  if str =~ '^:'
    if define == 0
      let str = substitute(str, '^:', '<dl><dt>', '')
      let define = 1
    else
      let str = substitute(str, '^:', '</dd><dt>', '')
    endif
    let str = substitute(str, '\s\+:', '</dt><dd>', '')
  endif
  return [close, str, define]
endfunction

function! s:howmFolding(str, folding, anchor)
  let folding = a:folding
  let anchor = a:anchor
  if a:str =~ '^=\{4}'
    if folding
      return [' '.a:str, folding]
    endif
    let id = 'foldt'.anchor
    let aid = 'a_'.id
    let str = '<p><a href="javascript:void(0)" class="folding" name="'.aid.'" id="'.aid.'" onclick="ToggleFolding('."'".id."'".');" style="display:none;">続きを読む</a></p><div id="'.id.'" style="display:block;">'
    let folding += 1
    return [str, folding]
  else
    return [a:str, folding]
  endif
endfunction

" 行頭の .*= をアウトラインとみなす
" .は空白が必要
if !exists('g:HowmHtml_NoAnchorHeader')
  let g:HowmHtml_NoAnchorHeader = 4
endif
function! s:howmOutline(str, htmlname, anchor, header, jump)
  let str = a:str
  let header = a:header
  let jump = a:jump

  let bullet = matchstr(str, '^[.*=]\+\s*')
  if bullet == '' || (bullet =~ '^\.\+$' && bullet != str)
    return [str, header, jump]
  endif
  let bullet = matchstr(bullet, '^[.*=]\+')
  let l = len(bullet) + 2 + s:Blogger
  let g:HowmHtml_Title = '='
  let g:HowmHtml_Title = exists('g:QFixHowm_Title') ? g:QFixHowm_Title : g:HowmHtml_Title
  let g:HowmHtml_Title = exists('g:qfixmemo_title') ? g:qfixmemo_title : g:HowmHtml_Title
  if g:HowmHtml_Title == bullet[0]
    let l -= 1
  endif
  let str = substitute(str, '^[.*=]\+', '', '')
  let l = l > 6 ? 6 : l
  let janchor = 'j'.a:anchor.jump
  if l >= g:HowmHtml_NoAnchorHeader
    let str = '<h'.l.' id="'.janchor.'">'.str.'</h'.l.'>'
  else
    let bullet = g:HowmHtml_Bullet
    let anchor = 'h'.a:anchor.header
    if g:HowmHtml_VicunaChapter
      if s:subheader == 0
        cal add(s:entries, '<ul>')
        let s:subheader = 1
      endif
      let sstr = printf('<li><a href="%s" title="%s" name="%s" id="%s">%s</a></li>', '#'.anchor, anchor, anchor, anchor, str)
      cal add(s:entries, sstr)
    endif
    let str = printf('<h%d id="%s"><a href="%s" title="%s" name="%s" id="%s">%s</a>%s</h%d>', l, janchor, '#'.anchor, anchor, anchor, anchor, bullet, str, l)
    let header += 1
  endif
  return [str, header, jump]
endfunction

" リンクタグ
function! s:howmLinktag(str)
  let urireg = '\([A-Za-z]:[/\\]\|\~/\|&gt;&gt;&gt;\)'
  if a:str !~ urireg
    return a:str
  endif

  let str = a:str

  let glink = substitute(g:howm_glink_pattern, '>', '\&gt;', 'g')
  let glink = substitute(glink, '<', '\&lt;', 'g')

  let gstr = matchstr(str, glink.'.*$')
  let str = substitute(str, glink.'.*$', '', '')

  let pathchr  = '[-!#%&+,.{}/0-9:;=?@A-Za-z_~\\]'
  let str = s:uri2tag(str, pathchr)

  let pathchr  = '.'
  if gstr != ''
    let gstr = substitute(gstr, '^'.glink.'\s*/\(.\+\)', escape(glink, '&').' file:///\1', '')
    let gstr = s:uri2tag(gstr, pathchr)
    " let gstr = substitute(gstr, '^'.glink.'\s*', '', '')
  endif

  let str = str . gstr
  return str
endfunction

function! s:uri2tag(str, pathchr)
  let str = a:str

  let imgsfx   = '\(\.jpg\|\.jpeg\|\.png\|\.bmp\|\.gif\)$'
  let imgp = g:HowmHtml_imgproperty

  let pathhead = '\([A-Za-z]:[/\\]\|\~/\)'
  let urireg = '\(\(memo\|howm\|rel\|https\|http\|file\|ftp\)://\|'.pathhead.'\)'.a:pathchr.'\+'
  if s:LocalLink == 0
    let urireg = '\(https\|http\|ftp\)://'.a:pathchr.'\+'
  endif

  let lstr = matchstr(str, urireg.'.*$', '', '')
  let str = substitute(str, urireg.'.*$', '', '')

  let suffix = '^$'
  if exists('g:qfixmemo_ext')
    let suffix = '\.'.g:qfixmemo_ext . '$'
  elseif exists('g:QFixHowm_FileExt')
    let suffix = '\.'.g:QFixHowm_FileExt . '$'
  endif
  while lstr != ''
    let alttext = ''
    let altimguri = ''
    let thumbnail = 0
    let imgp = g:HowmHtml_imgproperty
    let uri = matchstr(lstr, urireg)
    let urilen = strlen(uri)
    let uri = substitute(uri, 'memo://', 'howm://', '')
    let file = uri
    if uri =~ 'howm://'
      if g:HowmHtml_base_relmode == 0 && s:publish == ''
        let suri = substitute(uri, 'howm:///\?', s:howm_dir.'/', '')
      else
        let suri = substitute(uri, 'howm:///\?', s:basedir, '')
      endif
      if uri =~ suffix
        let hrelpath = s:howm_dir . (uri =~ 'howm://[^/\\]' ? '/' : '')
        let file = substitute(file, 'howm://', hrelpath, '')
        if filereadable(file)
          let alttext = readfile(file, '', 1)[0]
          let alttext = substitute(alttext, '^.\s*', '', '')
          let from = &enc
          let from = exists('g:howm_fileencoding') ? g:howm_fileencoding : from
          let from = exists('g:qfixmemo_fileencoding') ? g:qfixmemo_fileencoding : from
          let alttext = iconv(alttext, from, &enc)
        endif
        let relpath = g:HowmHtml_htmldir
        if s:publish != ''
          let relpath = g:HowmHtml_publish_htmldir
        endif
        let relpath = relpath . (uri =~ 'howm://[^/\\]' ? '/' : '')
        let hfile = substitute(uri, 'howm://', relpath, '')
        let huri = fnamemodify(hfile, g:HowmHtml_suffix_mode).'.'.g:HowmHtml_suffix
        let huri = fnamemodify(hfile, ':h').'/'. huri
        " if filereadable(huri) || s:publish != ''
          let uri = substitute(uri, 'howm:///\?', s:basedir, '')
          let uri = fnamemodify(uri, ':h').'/'. fnamemodify(huri, ':t')
        " else
        "   let uri = suri
        " endif
      else
        let uri = suri
      endif
    endif

    let relpath = s:root
    let uri = substitute(uri, 'file://%ROOT%', escape(relpath, '%#'), '')
    let relpath = s:HowmHtml_RelPath . (uri =~ 'rel://[^/\\]' ? '/' : '')
    let uri = substitute(uri, 'rel://', relpath, '')
    if uri == ''
      let str = str.lstr
      break
    endif
    " <a hrefを特別扱い
    if str =~ '&amp;&lt;\s*a\s*href\s*=\s*"\s*$'
      let lstr = substitute(lstr, '^'.urireg, '', '')
      let kstr = matchstr(lstr, urireg.'.*$', '', '')
      if kstr == ''
        let str = str.uri.lstr
        break
      endif
      let str = str . uri . substitute(lstr, urireg.'.*$', '', '')
      let lstr = kstr
      continue
    endif
    let addchr = ''
    " [::]記法
    let hurireg = ':]\|:image]\|:\(title=\|image[:=]\)[^\]]*'
    if str =~ '\[:\(&amp;\)\?$'
      let hurireg = ':[^:\]]*]'
    endif
    if str =~ '\[:\?\(&amp;\)\?$' && lstr =~ hurireg
      let hreg = ''
      if uri !~ hurireg
        let hreg = hurireg
      elseif uri !~ ']$'
        let hreg = ']'
        let addchr = ']'
      endif
      if hreg != ''
        let hstr = strpart(lstr, urilen)
        let hlen = matchend(hstr, hreg)
        let uri = uri. strpart(hstr, 0, hlen)
        let lstr = strpart(lstr, 0, urilen) . strpart(hstr, hlen)
      endif
      if uri =~ ']$'
        let addchr = ']'
      endif
      let uri = substitute(uri, ']$', '', '')
      if str =~ '\[:\(&amp;\)\?$'
        let halttext = substitute(uri, '.*:', '', '')
        if halttext != ''
          let alttext = halttext
        endif
        let uri = matchstr(uri, '.*:')
        let uri = substitute(uri, ':$', '', '')
      endif
      let imgtext = substitute(uri, '^.*\(:image[^\]]*\)$', '\1', '')
      if imgtext =~ ':image$'
        let imgp = ''
        let uri = substitute(uri, ':image$', '', '')
      elseif imgtext =~ '^:image[:=]'
        let imgp = ''
        if imgtext =~ ':small$'
          let imgp = 'width="25%"'
        elseif imgtext =~ ':large$'
          let imgp = 'width="50%"'
        elseif imgtext =~ ':thumbnail$'
          let imgp = ''
          let thumbnail = 1
        else
          let w = matchstr(imgtext, ':w\d\+$')
          let h = matchstr(imgtext, ':h\d\+$')
          if w != '' || h != ''
            let imgp = w . h
            let imgp = substitute(imgp, ':w\(\d\+\)', 'width="\1"', '')
            let imgp = substitute(imgp, ':h\(\d\+\)', ' height="\1"', '')
          endif
        endif
        let imgtext = substitute(imgtext, '\(:large\|:small\|:h\d\+\|:w\d\+\|:thumbnail\)$', '', '')
        if imgtext =~ '^:image='
          let altimguri = substitute(imgtext, '^:image=\?', '', '')
          let altimguri = substitute(altimguri, ':\?$', '', '')
        endif
      endif
      if str =~ '\[\(&amp;\)\?$'
        let halttext = substitute(uri, '^.*\(:title=[^\]]*\)$', '\1', '')
        let halttext = substitute(halttext, '^:title=\|:$', '', 'g')
        if halttext != ''
          let alttext = halttext
        endif
      endif
      let uri = substitute(uri, hurireg.'$', '', '')
      let uri = substitute(uri, ':$', '', '')
      let str = substitute(str, ':\?\(&amp;\)\?$', '\1', '')
    endif
    let uri = substitute(uri, '\\', '/', 'g')
    let orguri = uri
    if alttext != ''
      let orguri = alttext
    endif
    if uri =~ '^'.pathhead
      let uri = expand(uri)
      let uri = substitute(uri, '\\', '/', 'g')
      let uri = 'file://'.uri
    endif
    if uri =~ '^file://'
      let uri = 'file://'.expand(substitute(uri, 'file://', '', ''))
      let uri = substitute(uri, '\\', '/', 'g')
    endif
    " FIXME:対症療法
    if uri =~ '^file://e://$' || uri =~ '^file://p://$' || uri =~ '^file://s://$' || uri =~ '^file://l://$' || uri =~ '^file://m://$' || uri =~ '^file://o://$'
      let uri = matchstr(lstr, urireg)
      let str = str.uri
      let lstr = substitute(lstr, urireg, '', '')
      let str = str.substitute(lstr, urireg.'.*$', '', '')
      let lstr = matchstr(lstr, urireg.'.*$', '', '')
      continue
    endif
    if uri =~ imgsfx || altimguri != ''
      if str =~ '&amp;$'
        let str = substitute(str, '&amp;$', '', '')
        let imgp = g:HowmHtml_imgproperty2
      endif
      let altimguri = altimguri == '' ? uri : altimguri
      if thumbnail == 1
        let altimguri = substitute(altimguri, '\.\([^.]\+\)$', '.th.\1', '')
      endif

      let uri = printf('<a href="%s"><img src="%s" %s alt="%s" /></a>', uri, altimguri, imgp, orguri)
    else
      let uri = printf('<a href="%s">%s</a>', uri, orguri)
    endif
    let lstr = strpart(lstr, urilen)
    let str = str.uri.addchr
    let str = str.substitute(lstr, urireg.'.*$', '', '')
    let lstr = matchstr(lstr, urireg.'.*$')
  endwhile
  return str
endfunction

" 相対パスへ変換
function! s:Convert2Relpath(uri, dir)
  let uri = a:uri
  let dst = QFixNormalizePath(fnamemodify(substitute(uri, '^file://', '', ''), ':p'))
  let src = QFixNormalizePath(fnamemodify(a:dir, ':p'))
  let base = substitute(src, '\\', '/', 'g')
  while 1
    if matchend(dst, base) > 0
      break
    endif
    let base = substitute(base, '[^/]*/$', '', '')
    if base == ''
      return uri
    endif
  endwhile
  let uri = strpart(dst, strlen(base))
  let src = strpart(src, strlen(base))
  let src = substitute(src, '[^/]\+/', '../','g')
  let uri = src.uri
  if uri == ''
    return a:uri
  endif
  return uri
endfunction

let HowmHtml_Folding = [
  \ '<script type="text/javascript">',
  \ '(function hideFolding(){',
  \ '  for (i = 1; i <= %ENTRIES%; i++) {',
  \ '    var id = "foldt"+i.toString()',
  \ '    ToggleFolding(id);',
  \ '  }',
  \ '})()',
  \ 'function ToggleFolding(hideID) {',
  \ '  var id = document.getElementById(hideID);',
  \ '  if (id) {',
  \ '    id.style.display = id.style.display == "none" ? "block" : "none";',
  \ '  }',
  \ '  id = document.getElementById("a_"+hideID);',
  \ '  if (id) {',
  \ '    id.style.display = id.style.display == "none" ? "block" : "none";',
  \ '  }',
  \ '}',
  \ '</script>'
\]

if !exists('HowmHtml_HttpHeader')
  let HowmHtml_HttpHeader = [
    \ '<?xml version="1.0" encoding="%ENCODING%"?>',
    \ '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
    \ '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="ja" lang="ja">',
    \ '<head>',
    \ '<meta http-equiv="Content-Type" content="text/html; charset=%ENCODING%" />',
    \ '<meta http-equiv="Content-Script-Type" content="text/javascript" />',
    \ '<meta http-equiv="Content-Style-Type" content="text/css" />',
    \ '<meta name="generator" content="howm2html" />',
    \ '<meta name="description" content="%FILENAME%" />',
    \ '<title> %SUBJECT% (%SIGHTNAME%)</title>',
    \ '<link rel="stylesheet" type="text/css" href="%CSSNAME%" />'
  \]
endif
if !exists('HowmHtml_HttpBody')
  let HowmHtml_HttpBody = [
    \ '</head>',
    \ '<body class="mainIndex %BODYCLASS%">',
    \ '<div id="header"><p class="siteName"><a href="%BASEDIR%" title="Toplink">%SIGHTNAME%</a></p><p class="description">%DESCRIPTION%</p></div>',
    \ '<div id="content"><div id="main">',
    \ '<h1>%TITLE%</h1>'
  \]
endif
if !exists('HowmHtml_HttpFooter')
  let HowmHtml_HttpFooter = [
    \ '</div></div>',
    \ '<div id="footer"><address>%DATE% (Howm2html ver. %VERSION%)</address></div>',
    \ '</body>',
    \ '</html>'
  \]
endif
if !exists('HowmHtml_TopicPath')
  let HowmHtml_TopicPath = [
    \ '<p class="topicPath"><a href="javascript:history.back()" title="Prev">&lt;&lt;&nbsp;Prev</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="#header" title="PageTop">PageTop</a></p>'
  \]
endif

if !exists('HowmHtml_HttpFooterExtend')
  let HowmHtml_HttpFooterExtend = 1
endif

if !exists('HowmHtml_Entries')
  let HowmHtml_Entries = ['<dt>Entries</dt><dd><ul>']
endif
let s:entries = []
function! s:VicunaUtil(mode)
  let mode = a:mode
  let from = &enc
  let to   = g:HowmHtml_encoding
  let to   = to == 'Shift_JIS' ? 'cp932' : to

  let foot = [
    \ '</div>',
    \ '<div id="utilities">',
    \ '<dl class="navi">',
  \]
  call extend(foot, g:HowmHtml_Entries)
  call extend(foot, s:entries)
  call add(foot, '</ul></dd>')
  if exists('g:HowmHtml_Navi')
    call extend(foot, g:HowmHtml_Navi)
  endif
  call add(foot, '</dl>')
  if exists('g:HowmHtml_Others')
    call add(foot, '<dl class="others">')
    call extend(foot, g:HowmHtml_Others)
    call add(foot, '</dl>')
  endif
  call map(foot, 'substitute(v:val, "%ROOT%", s:root, "g")')
  call map(foot, 'substitute(v:val, "%BASEDIR%/\\?", s:basedir, "g")')
  call map(foot, 'substitute(v:val, "%VERSION%", s:version, "g")')
  call map(foot, 'iconv(v:val, from, to)')
  return foot
endfunction

if !exists('g:HowmHtml_recent')
  let g:HowmHtml_recent = 5
endif
if !exists('g:HowmHtml_index_file')
  let g:HowmHtml_index_file = 'index.ref.howm'
endif
if !exists('g:HowmHtml_index_entry')
  let g:HowmHtml_index_entry = []
endif

function! howm2html#HowmHtmlConvFiles(file, param, ...)
  let s:howm_dir = '~/howm'
  if exists('g:qfixmemo_dir')
    let s:howm_dir = g:qfixmemo_dir
  elseif exists('g:howm_dir')
    let s:howm_dir = g:howm_dir
  endif
  let l:HowmHtml_Vicuna = g:HowmHtml_Vicuna
  let file = a:file
  if file =='%'
    let file = fnamemodify(expand('%'), ':p')
  endif
  let file = fnamemodify(expand(file), ':p')
  if a:0
    " let file = fnamemodify(expand(file), ':p')
  endif
  let from = &enc
  let from = exists('g:howm_fileencoding') ? g:howm_fileencoding : from
  let from = exists('g:qfixmemo_fileencoding') ? g:qfixmemo_fileencoding : from
  let to   = &enc
  let glist = readfile(file)
  call map(glist, 'iconv(v:val, from, to)')
  let flist = []
  for d in glist
    if d == 'finish'
      break
    endif
    let file = matchstr(d, '^[^|]*')
    let ifile = substitute(file, '^>>>\s*', '', '')
    let ifile = substitute(ifile, 'memo://', 'howm://', '')
    let ifile = substitute(ifile, 'howm://', s:howm_dir.'/', 'g')
    if filereadable(ifile)
      let s:h2hfile = ifile
      call add(flist, ifile)
      exe 'Howm2html '.a:param
    endif
  endfor
  if a:0 > 0
    if len(flist) > g:HowmHtml_recent
      call remove(flist, g:HowmHtml_recent, -1)
    endif
    call extend(flist, g:HowmHtml_index_entry, 1)
    let file = g:HowmHtml_ref_basedir . '/' . g:HowmHtml_index_file
    let file = expand(file, ':p')
    let hdir = fnamemodify(expand(file), ':h')
    if isdirectory(hdir) == 0
      call mkdir(hdir, 'p')
    endif
    call writefile(flist, file)
    let s:h2hfile = file
    exe 'Howm2html'.a:1.' '.a:param
  endif
  let g:HowmHtml_Vicuna = l:HowmHtml_Vicuna
endfunction

let s:MSWindows = has('win95') + has('win16') + has('win32') + has('win64')
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

