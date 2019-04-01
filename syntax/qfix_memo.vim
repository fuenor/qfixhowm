" Vim syntax file
" Language: qfix_memo

if exists("b:current_syntax")
  finish
endif

if !exists('g:qfixmemo_markdown_syntax')
  let g:qfixmemo_markdown_syntax = 1
endif
if g:qfixmemo_markdown_syntax
  runtime! syntax/markdown.vim
  syn match qfixmemoError "\w\@<=_\w\@="
  silent! syn clear markdownLineStart
  if !exists('g:qfixmemo_markdown_emphasis') || g:qfixmemo_markdown_emphasis == 0
    silent! syntax clear markdownBold
    silent! syntax clear markdownItalic
  endif
endif
let b:current_syntax = "qfix_memo"

"----------
" qfixmemo highlight link
"----------
hi def link qfixmemoTitle         Title
hi def link qfixmemoTitleBullet   Special
hi def link qfixmemoTitleCategory Identifier

hi def link qfixmemoDate Underlined
hi def link qfixmemoTime Constant

hi def link txtFile Underlined
hi def link txtUrl  Underlined

"----------
" contains markdown.vim
"----------
" syn region qfixmemoCodeBlock start="^\(    \|\t\)" end="$"
" hi def link qfixmemoQuote Comment

"----------
" default
"----------
" qfixmemo title
if exists('g:qfixmemo_title')
  exe 'syn region qfixmemoTitle start="^['.g:qfixmemo_title.']" end="$" keepend contains=qfixmemoTitleBullet,qfixmemoTitleCategory'
  exe 'syn match qfixmemoTitleBullet contained "^['.g:qfixmemo_title.']\{1,6}"'
  syn match qfixmemoTitleCategory contained '\[.\{-}\]'
endif

" qfixmemo timestamp
syn match qfixmemoDateTime '\s*\[\d\{4}[-/]\d\{2}[-/]\d\{2}\( \d\{2}\(:\d\{2}\)\{1,2}\)\?\]' contains=qfixmemoDate,qfixmemoTime
syn match qfixmemoDate contained '\d\{4}[-/]\d\{2}[-/]\d\{2}'
syn match qfixmemoTime contained '\d\{2}\(:\d\{2}\)\{1,2}'

" " qfixmemo link
syn match txtUrl  '\(http\|https\|ftp\|git\)://[-0-9a-zA-Z!#$%&'*+,./:;=?@_~]*'
syn match txtFile '\(file\|rel\|memo\|howm\)://[-0-9a-zA-Z!#$%&'()*+,./:;=?@_~{}[\]\\]*'
syn match txtFile '\zs\([A-Za-z]:[/\\]\|\~[/\\]\|[\\][\\]\|\.\.\?[/\\]\)[-0-9a-zA-Z!#$%&'()*+,./:;=?@_~{}[\]\\]\+\ze[^\])[:blank:]]\?'
if !exists('g:openuri_unix_style_path') || g:openuri_unix_style_path
  syn match txtFile '\zs\(/[-0-9a-zA-Z!#$%&'()*+,./:;=?@_~{}[\]\\]\+\)\{2,}\ze[^\])[:blank:]]\?'
endif
syn match txtFile '\[:\?&\?\zs\(memo\|rel\|howm\|https\|http\|file\|ftp\|git\)://\([a-zA-Z]:\)\?[^:]\+\ze:[^\]]*]'
syn match txtFile '\[:\?&\?\zs\([A-Za-z]:[/\\]\|\~[/\\]\|\.\.\?[/\\]\|[/\\]\)[^:]\+\ze:[^\]]*]'

" definition list （:define | explanation)
syn match qfixmemoDefinition '^:.\{-}\(\s:\||\)' contains=qfixmemoDefColon
syn match qfixmemoDefColon  contained '^:\|\s:\||'

hi def link qfixmemoDefinition Identifier
hi def link qfixmemoDefColon   Label

"----------
" chapter
"----------
if !exists('g:qfixmemo_title') || g:qfixmemo_title != '.'
  syn region qfixmemoChapter start='^\.\{1,6}\(\s\|$\)' end='$' contains=qfixmemoChapterBullet,qfixmemoChapterCategory keepend
endif

syn region qfixmemoChapter start='^\s*\(\*\|\d\+\)\.\(\(\*\|\d\+\)\.\)*\(\*\|\d\+\.\?\)\(\s\|$\)' end='$' contains=qfixmemoChapterBullet,qfixmemoChapterCategory keepend
syn region qfixmemoChapter start='^\s*\(\*\|\d\+\)\.\(\s\|$\)' end='$' contains=qfixmemoChapterBullet,qfixmemoChapterCategory keepend

syn match qfixmemoChapterCategory contained '\[.\{-}\]'
syn match qfixmemoChapterBullet contained '^\s*\(\*\.\)\+\*\?$'
syn match qfixmemoChapterBullet contained '^\s*[0-9][0-9.]* $'
syn match qfixmemoChapterBullet contained '^\s*\([0-9.*]\+\|[.*]\+\)'

hi def link qfixmemoChapter         Title
hi def link qfixmemoChapterCategory Identifier
hi def link qfixmemoChapterBullet   Label

" Table
syn match qfixmemoTextTable +^\s*|.*|$+ contains=qfixmemoTextTableSeparator,qfixmemoTextTableHeader,qfixmemoTextUrl,qfixmemoTextFile,qfixmemoEscapeTag
syn match qfixmemoTextTableSeparator contained +|+
syn match qfixmemoTextTableHeader contained '|:\?\s*[*#][^|]\+' contains=qfixmemoTextTableSeparator
hi def link qfixmemoTextTableHeader    Title
hi def link qfixmemoTextTableSeparator Statement

"----------
" markdown style
"----------
" title
if !exists('g:qfixmemo_title') || g:qfixmemo_title != '#'
  syn region qfixmemoSubTitle start="^#" end="$" keepend contains=qfixmemoSubTitleBullet,qfixmemoSubTitleCategory
  syn match qfixmemoSubTitleBullet contained '^#\{1,6}'
  syn match qfixmemoSubTitleCategory contained '\[.\{-}\]'
  hi def link qfixmemoSubTitle         qfixmemoTitle
  hi def link qfixmemoSubTitleBullet   qfixmemoTitleBullet
  hi def link qfixmemoSubTitleCategory qfixmemoTitleCategory
endif

" styling text
syn region htmlStrike start="<s>" end="</s>" contains=htmlTag,htmlEndTag keepend
if exists("$APPBASE")
  hi! link htmlStrike NonText
endif

" list
if !exists('g:qfixmemo_title') || g:qfixmemo_title != '*'
  syn region qfixmemoMarkdownList start='^\s*\* ' end='$' contains=qfixmemoMarkdownBullet,qfixmemoChapterCategory keepend
  syn match qfixmemoMarkdownBullet contained '^\s*\*'

  hi def link qfixmemoMarkdownList   Normal
  hi def link qfixmemoMarkdownBullet Number
endif

syn region qfixmemoList start='^\s*[-+]\+\s' end='$' contains=qfixmemoListBullet,qfixmemoListDefinition,htmlTag,htmlEndTag,qfixmemoEscapeTag keepend
syn match qfixmemoListBullet contained '^\s*+\+'
syn match qfixmemoListBullet contained '^\s*-\+'

hi def link qfixmemoList       Normal
hi def link qfixmemoListBullet Number

" fenced language
syn region qfixmemoBlock matchgroup=qfixmemoBlockDelimiter start=+^\s*```.*+ end=+^\s*```$+
hi def link qfixmemoBlockDelimiter Delimiter
syn match markdownBlockDelimiter '^```.\+$'
syn region markdownSuperPre matchgroup=markdownBlockDelimiter start=+^```.*$+ end=+^```+

" hi def link markdownSuperPre       Comment
hi def link markdownBlockDelimiter Delimiter

" block quote
syn region qfixmemoBlockQuote start='^>\s*' end='$' contains=qfixmemoBlockQuoteDelimiter,howmLink,hatenaSuperPre
syn match qfixmemoBlockQuoteDelimiter contained '^>[>[:space:]]*'
hi def link qfixmemoBlockQuote Comment
hi def link qfixmemoBlockQuoteDelimiter Comment

" horizontal rule
syn match qfixmemoHRule '^\(-\|- \)\{3,}[- ]*'
syn match qfixmemoHRule '^\(\*\|\* \)\{3,}[* ]*'
syn match qfixmemoHRule '^=\{7,}'

hi def link qfixmemoHRule Type

" code
syn match qfixmemoCode display '`.\{-}\(`\|$\)' contains=qfixmemoCodeDelimiter
syn match qfixmemoCodeDelimiter contained '`'

hi def link qfixmemoCode Define
hi def link qfixmemoCodeDelimiter Delimiter

"----------
" hatena
"----------
" pre, quote
syn match hatenaBlockDelimiter '^>|.\{-}|$\|^||<$'
syn region hatenaSuperPre matchgroup=hatenaBlockDelimiter start=+^>|[^|]*|$+ end=+^||<$+

hi def link hatenaSuperPre       Comment
hi def link hatenaBlockDelimiter Delimiter

"----------
" howm2html.vim
"----------
syn match qfixmemoEscapeTag '^&&.*$'
syn match qfixmemoEscapeTag '&<[^>]\+>' contains=txtUrl,txtFile
hi def link qfixmemoEscapeTag NonText

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

