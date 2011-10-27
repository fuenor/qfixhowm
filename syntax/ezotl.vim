" vim syntax file
"
" language:    eazy outline
" maintainer:  fuenor@gmail.com
" last change: 2011-10-25 23:40
scriptencoding utf-8

hi link ezotlBullet     Type
hi link ezotlList       Constant
hi link ezotlComment    Comment
hi link ezotlWarningMsg WarningMsg

hi link ezotlTab0   Identifier
hi link ezotlTab1   Statement
hi link ezotlTab2   Special
hi link ezotlTab3   Type
hi link ezotlTab4   PreProc

syn match ezotlBullet /^\t*[-+.*・]\+/ contained
syn match ezotlList /^\s*[-+].*/ contains=ezotlBullet
syn match ezotlComment /^\s*[#].*/
syn match ezotlWarningMsg /!!!/
" syn region ezotlWarningMsg start=+!!!+ end=+!!!+ end=+$+ keepend
"
syn match ezotlTab0 /^\s*[.*・].*/   contains=ezotlBullet
syn match ezotlTab1 /^\t\{1}[^\t].*/ contains=ezotlBullet,ezotlList,ezotlComment,ezotlWarningMsg,ezotlTab0,qfixmemoKeyword,actionlockKeyword
syn match ezotlTab2 /^\t\{2}[^\t].*/ contains=ezotlBullet,ezotlList,ezotlComment,ezotlWarningMsg,ezotlTab0,qfixmemoKeyword,actionlockKeyword
syn match ezotlTab3 /^\t\{3}[^\t].*/ contains=ezotlBullet,ezotlList,ezotlComment,ezotlWarningMsg,ezotlTab0,qfixmemoKeyword,actionlockKeyword
syn match ezotlTab4 /^\t\{4}[^\t].*/ contains=ezotlBullet,ezotlList,ezotlComment,ezotlWarningMsg,ezotlTab0,qfixmemoKeyword,actionlockKeyword

