" Vim syntax file
"
" Language:    qfix_memo
" Maintainer:  fuenor@gmail.com
" Last Change: 2015-02-24
scriptencoding utf-8

"----------
" default
"----------
hi def link qfixmemoTitle     Title
hi def link qfixmemoTitleDesc Delimiter
hi def link qfixmemoCategory  Statement

hi def link qfixmemoKeyword   Underlined
hi def link qfixmemoDate      Underlined
hi def link qfixmemoTime      Constant

if exists('g:qfixmemo_title')
  exe "syn region qfixmemoSubTitle start='^[".g:qfixmemo_title."]\\+' end='$' contains=qfixmemoTitleBullet,qfixmemoCategory keepend"
  exe "syn match qfixmemoTitleBullet contained '^\\s*[".g:qfixmemo_title."]\\+'"
endif

hi def link qfixmemoSubTitle    Identifier
hi def link qfixmemoTitleBullet Special

" URLとファイル
" syn match qfixmemoTextUrl  '\(http\|https\|ftp\|git\)://[-0-9a-zA-Z!#$%&'*+,./:;=?@_~]*'
" syn match qfixmemoTextFile '\(file\|rel\|memo\|howm\)://[-0-9a-zA-Z!#$%&'()*+,./:;=?@_~{}[\]\\]*'
" syn match qfixmemoTextFile '\zs\([A-Za-z]:[/\\]\|\~[/\\]\|[\\][\\]\|\.\.\?[/\\]\)[-0-9a-zA-Z!#$%&'()*+,./:;=?@_~{}[\]\\]\+\ze[^\])[:blank:]]\?'
" if !exists('g:openuri_unix_style_path') || g:openuri_unix_style_path
"   syn match qfixmemoTextFile '\zs\(/[^0-9[:blank:]]\)[-0-9a-zA-Z!#$%&'()*+,./:;=?@_~{}[\]\\]\+\ze[^\])[:blank:]]\?'
" endif
" syn match qfixmemoTextFile '\[:\?&\?\zs\(memo\|rel\|howm\|https\|http\|file\|ftp\|git\)://\([a-zA-Z]:\)\?[^:]\+\ze:[^\]]*]'
" syn match qfixmemoTextFile '\[:\?&\?\zs\([A-Za-z]:[/\\]\|\~[/\\]\|\.\.\?[/\\]\|[/\\]\)[^:]\+\ze:[^\]]*]'

hi def link qfixmemoTextUrl  Underlined
hi def link qfixmemoTextFile Underlined

" 引用文 (行頭の'> ')
syn match qfixmemoTextQuote '^\s*>\(\s.*\|$\)'
hi def link qfixmemoTextQuote Comment

" リスト (行頭の '-' '+')
syn region qfixmemoTextList start='^\s*[-+]\+\s*' end='\s:' end='$' contains=qfixmemoTextListBullet,qfixmemoTextListDefinition,qfixmemoTextUrl,qfixmemoTextFile keepend
syn match qfixmemoTextListBullet contained '^\s*[-+*]\+\s*'
syn match qfixmemoTextListColon  contained '\s:'
syn match qfixmemoTextListDefinition contained '\s:' contains=qfixmemoTextListColon

hi def link qfixmemoTextList       Constant
hi def link qfixmemoTextListBullet Statement
hi def link qfixmemoTextListColon  Label

" |*テーブル | 項目 |  (セル内で'*'を使うとタイトル)
syn match qfixmemoTextTable +^\s*|.*|$+ contains=qfixmemoTextTableSeparator,qfixmemoTextTableHeader,qfixmemoTextUrl,qfixmemoTextFile
syn match qfixmemoTextTableSeparator contained +|+
syn match qfixmemoTextTableHeader contained '|\s*\*[^|]\+' contains=qfixmemoTextTableSeparator

hi def link qfixmemoTextTableHeader    Title
hi def link qfixmemoTextTableSeparator Statement

" 定義リスト （行頭の':'と' :')
syn match qfixmemoTextDefinition '^\s*:.\{-}\s:' contains=qfixmemoTextDefColon
syn match qfixmemoTextDefColon  contained '^\s*:\|\s:'

hi def link qfixmemoTextDefinition Identifier
hi def link qfixmemoTextDefColon   Label

" TODO: FIXME: (行頭の'TODO:' 'FIXME:')
syn match qfixmemoTextWarning '^\s*\(TODO\|FIXME\):'
hi def link qfixmemoTextWarning TODO

" 区切り線
syn match qfixmemoTextHLine '-\{20,}'
syn match qfixmemoTextHLine '=\{20,}'
hi def link qfixmemoTextHLine Label

" キーワード ( ' か " で囲まれた文字列)
" syn region qfixmemoTextKeyword start=+"+ skip=+\\"+ end=+"+ end=+$+
" syn region qfixmemoTextKeyword start=+'+ skip=+\\'+ end=+'+ end=+$+
" hi link qfixmemoTextKeyword Define

" hatena (superpreと引用)
syn match hatenaBlockDelimiter '^>|.\{-}|$\|^||<$'
syn region hatenaSuperPre   matchgroup=hatenaBlockDelimiter start=+^>|[^|]*|$+ end=+^||<$+
syn region hatenaBlockQuote matchgroup=hatenaBlockDelimiter start=+^>>$+  end=+^<<$+ contains=ALL

hi def link hatenaSuperPre       Comment
hi def link hatenaBlockDelimiter DiffText

"----------
" ワイルドカードチャプター
"----------
if exists('g:qfixmemo_title') && g:qfixmemo_title !~ "[.]"
  syn region qfixmemoChapterNumber start='^\s*[.]\+\(\s\|$\)' end='$' contains=qfixmemoChapterBullet,qfixmemoChapterCategory keepend
endif
if exists('g:qfixmemo_title') && g:qfixmemo_title != '*'
  syn region qfixmemoMarkdownList start='^\s*\*' end='$' contains=qfixmemoMarkdownBullet,qfixmemoChapterCategory keepend
endif

" syn region qfixmemoChapterNumber start='^\s*\(\*\.\)\+\*' end='$' contains=qfixmemoChapterBullet,qfixmemoChapterCategory keepend
syn region qfixmemoChapterNumber start='^\s*\(\*\|\d\+\)\.\(\(\*\|\d\+\)\.\)*\(\*\|\d\+\.\?\)\(\s\|$\)' end='$' contains=qfixmemoChapterBullet,qfixmemoChapterCategory keepend
syn region qfixmemoChapterNumber start='^\s*\(\*\|\d\+\)\.\(\s\|$\)' end='$' contains=qfixmemoChapterBullet,qfixmemoChapterCategory keepend

syn match qfixmemoChapterCategory contained '\[.\{-}\]'
syn match qfixmemoChapterBullet contained '^\s*\(\*\.\)\+\*\?$'
syn match qfixmemoChapterBullet contained '^\s*[0-9][0-9.]* $'
syn match qfixmemoChapterBullet contained '^\s*\([0-9.*]\+\|[.*]\+\)'
syn match qfixmemoMarkdownBullet contained '^\s*\*\+'

hi def link qfixmemoChapterNumber   PreProc
hi def link qfixmemoChapterCategory Label
hi def link qfixmemoChapterBullet   Type
hi def link qfixmemoMarkdownList    Normal
hi def link qfixmemoMarkdownBullet  Type

"----------
" markdown style
"----------
if !exists('g:qfixmemo_title') || g:qfixmemo_title != '#'
  syn region qfixmemoSubTitle start='^[#]\+' end='$' contains=qfixmemoTitleBullet,qfixmemoCategory keepend
  syn match qfixmemoTitleBullet contained '^\s*[#]\+'
endif

syn match qfixmemoCode display "`.\{-}`"
syn match qfixmemoCodeSpace display "^    .*"

" github Fenced code blocks
syn match qfixmemoDelimiter '^```\s*[[:alnum:]]*$'

hi def link qfixmemoCode         Comment
hi def link qfixmemoCodeSpace    Comment
hi def link qfixmemoDelimiter    DiffText

"----------
" howm2html.vim
"----------
syn match qfixmemoEscapeTag '^&&.*$'
syn match qfixmemoEscapeTag '&<[^>]\+>'
hi def link qfixmemoEscapeTag Folded

"----------
" howmの予定・TODO
"----------
" runtime! syntax/howm_schedule.vim

if !exists('g:qfixmemo_wiki_syntax') || g:qfixmemo_wiki_syntax == 0
  finish
endif

"----------
" Wiki style syntax
"----------
let QFixHowm_WikiBold   = '\*'
let QFixHowm_WikiItalic = '_'
let QFixHowm_WikiDel    = '\~\~'
let QFixHowm_WikiSuper  = '\^'
let QFixHowm_WikiSub    = ',,'

let QFixHowm_WikiBoldItalic = '\*_'
let QFixHowm_WikiItalicBold = '_\*'

let QFixHowm_WikiRegxp  = '\(^\|\s\)%s\([^[:space:]]'.'.\{-}'.'[^[:space:]]\)%s\($\|\s\)'
let QFixHowm_WikiRegxpC = '%s\([^[:space:]]'.'.\{-}'.'[^[:space:]]\)%s'

if exists("+conceallevel")
  syntax conceal on
endif
setlocal conceallevel=3

exe 'syn match WikiBoldConceal   contained /'.QFixHowm_WikiBold.'/'
exe 'syn match WikiItalicConceal contained /'.QFixHowm_WikiItalic.'/'
exe 'syn match WikiDelConceal    contained /'.QFixHowm_WikiDel.'/'
exe 'syn match WikiSuperConceal  contained /'.QFixHowm_WikiSuper.'/'
exe 'syn match WikiSubConceal    contained /'.QFixHowm_WikiSub.'/'

exe 'syn match WikiBoldItalicConceal contained /'.QFixHowm_WikiBoldItalic.'/'
exe 'syn match WikiItalicBoldConceal contained /'.QFixHowm_WikiItalicBold.'/'

if exists("+conceallevel")
  syntax conceal off
endif

let regxp = printf(QFixHowm_WikiRegxp, QFixHowm_WikiBold, QFixHowm_WikiBold)
" let g:vimwiki_rxBold
exe 'syntax match WikiBold /'.regxp.'/ contains=WikiBoldConceal,WikiBoldItalic'
let regxp = printf(QFixHowm_WikiRegxp, QFixHowm_WikiItalic, QFixHowm_WikiItalic)
exe 'syntax match WikiItalic /'.regxp.'/ contains=WikiItalicConceal,WikiItalicBold'
let regxp = printf(QFixHowm_WikiRegxp, QFixHowm_WikiBoldItalic, QFixHowm_WikiItalicBold)
exe 'syntax match WikiBoldItalic /'.regxp.'/ contains=WikiBoldItalicConceal,WikiItalicBoldConceal '
let regxp = printf(QFixHowm_WikiRegxp, QFixHowm_WikiItalicBold, QFixHowm_WikiBoldItalic)
exe 'syntax match WikiItalicBold /'.regxp.'/ contains=WikiBoldItalicConceal,WikiItalicBoldConceal '

let regxp = printf(QFixHowm_WikiRegxpC, QFixHowm_WikiDel, QFixHowm_WikiDel)
exe 'syntax match WikiDel /'.regxp.'/ contains=WikiDelConceal'
let regxp = printf(QFixHowm_WikiRegxpC, QFixHowm_WikiSuper, QFixHowm_WikiSuper)
exe 'syntax match WikiSuper /'.regxp.'/ contains=WikiSuperConceal'
let regxp = printf(QFixHowm_WikiRegxpC, QFixHowm_WikiSub, QFixHowm_WikiSub)
exe 'syntax match WikiSub /'.regxp.'/ contains=WikiSubConceal'

hi WikiBold term=bold cterm=bold gui=bold
hi WikiItalic term=italic cterm=italic gui=italic
hi WikiBoldItalic term=bold cterm=bold gui=bold,italic
hi WikiItalicBold term=bold cterm=bold gui=bold,italic

hi def link WikiDel   Folded
hi def link WikiSuper SpellRare
hi def link WikiSub   SpellLocal
hi def link WikiPre   PreProc
hi def link WikiCode  PreProc

hi def link WikiBoldConceal   WikiIgnore
hi def link WikiItalicConceal WikiIgnore
hi def link WikiItalicBoldConceal WikiIgnore
hi def link WikiBoldItalicConceal WikiIgnore

hi def link WikiDelConceal    WikiIgnore
hi def link WikiSuperConceal  WikiIgnore
hi def link WikiSubConceal    WikiIgnore

" runtime! syntax/howm_memo.vim

