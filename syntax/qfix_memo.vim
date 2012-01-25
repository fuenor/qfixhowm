" Vim syntax file
"
" Language:    qfixmemo
" Maintainer:  fuenor@gmail.com
" Last Change: 2011-12-06 20:01
scriptencoding utf-8

" URLとファイル
syn match txtUrl  '\(http\|https\|file\|ftp\)://[-0-9a-zA-Z;/?:@&=+$,_.!~*'()%#]*'
syn match txtFile '\(memo\|rel\|howm\)://[-0-9a-zA-Z;/?:@&=+$,_.!~*'()%#}[\]\\]*'
syn match txtFile '\([A-Za-z]:[/\\]\|\~[/\\]\)[-0-9a-zA-Z;/?:@&=+$,_.!~*'()%{}[\]\\]\+'
syn match txtFile '\[:\?&\?\zs\(memo\|rel\|howm\|https\|http\|file\|ftp\)://[^:]\+\ze:[^\]]*]'
syn match txtFile '\[:\?&\?\zs\([A-Za-z]:[/\\]\|\~[/\\]\|\.\.\?[/\\]\|[/\\]\)[^:]\+\ze:[^\]]*]'

hi def link txtUrl  Underlined
hi def link txtFile Underlined

" 引用文 (行頭の'> ')
syn match txtQuote '^\s*>\(\s.*\|$\)'
hi def link txtQuote Comment

" リスト (行頭の '-' '+')
syn region txtList start='^\s*[-+]\+\s*' end='\s:' end='$' contains=txtListBullet,txtListDefinition,txtUrl,txtFile keepend
syn match txtListBullet contained '^\s*[-+*]\+\s*'
syn match txtListColon  contained '\s:'
syn match txtListDefinition contained '\s:' contains=txtListColon

hi def link txtList       Constant
hi def link txtListBullet Statement
hi def link txtListColon  Label

" |*テーブル | 項目 |  (セル内で'*'を使うとタイトル)
syn match txtTable +^\s*|.*|$+ contains=txtTableSeparator,txtTableHeader,txtUrl,txtFile
syn match txtTableSeparator contained +|+
syn match txtTableHeader contained '|\s*\*[^|]\+' contains=txtTableSeparator

hi def link txtTableHeader    Title
hi def link txtTableSeparator Statement

" 定義リスト （行頭の':'と' :')
syn match txtDefinition '^\s*:.\{-}\s:' contains=txtDefColon
syn match txtDefColon  contained '^\s*:\|\s:'

hi def link txtDefinition Identifier
hi def link txtDefColon Label

" TODO: FIXME: (行頭の'TODO:' 'FIXME:')
syn match txtWarning '^\s*\(TODO\|FIXME\):'
hi def link txtWarning TODO

" 区切り線
syn match txtHLine '-\{20,}'
syn match txtHLine '=\{20,}'
hi def link txtHLine Label

" キーワード ( ' か " で囲まれた文字列)
" syn region txtKeyword start=+"+ skip=+\\"+ end=+"+ end=+$+
" syn region txtKeyword start=+'+ skip=+\\'+ end=+'+ end=+$+
" hi link txtKeyword Define

" hatena (superpreと引用)
syn region hatenaSuperPre   matchgroup=hatenaBlockDelimiter start=+^>|[^|]*|$+ end=+^||<$+
syn region hatenaBlockQuote matchgroup=hatenaBlockDelimiter start=+^>>$+  end=+^<<$+ contains=ALL
hi def link hatenaSuperPre       Comment
hi def link hatenaBlockDelimiter Delimiter

"----------
" ワイルドカードチャプター
"----------
syn region memoTitle start='^[=]\+' end='$' contains=titleBullet,titleCategory keepend
syn region chapterTitle start='^\s*[*]' end='$' contains=chapterBullet,titleCategory keepend
syn region chapterNumber start='^\s*\(*\|\d\+\)\.\(\(*\|\d\+\)\.\)*\(*\|\d\+\)\(\s\|$\)' end='$' contains=chapterBullet,titleCategory keepend
syn region chapterNumber start='^\s*\(*\|\d\+\)\.\(\s\|$\)' end='$' contains=chapterBullet,titleCategory keepend
syn region chapterNumber start='^[.]\+\s' end='$' contains=chapterBullet,titleCategory keepend

syn match titleBullet   contained '^\s*[.*=]\+'
syn match titleCategory contained '\[.\{-}\]'
syn match chapterBullet contained '^\s*\(\*\.\)\+\*\?$'
syn match chapterBullet contained '^\s*[0-9][0-9.]* $'
syn match chapterBullet contained '^\s*\([0-9.*]\+\|[.*=]\+\)'

hi def link memoTitle       Title
hi def link titleBullet     Special
hi def link titleCategory   Label
hi def link chapterTitle    Define
hi def link chapterNumber   Identifier
hi def link chapterBullet   Type

"----------
" howm2html.vim
"----------
syn match escapeTAG '^&&.*$'
syn match escapeTAG '&<[^>]\+>'
hi def link escapeTAG Folded

"「」強調
syn region MyJpKagi display start=+「\zs+ end=+\ze」+

" howmの予定・TODO
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

