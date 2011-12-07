" vim syntax file
"
" Language:      eazy outline
" Maintainer:    fuenor@gmail.com
" Last Modified: 2011-11-02 22:22
scriptencoding utf-8

hi def link ezotlBullet     Type
hi def link ezotlListBullet Type
hi def link ezotlList       Constant
hi def link ezotlComment    Comment
hi def link ezotlWarningMsg WarningMsg
hi def link ezotlTitle      Identifier

hi def link ezotlTab0   Normal
hi def link ezotlTab1   Special
hi def link ezotlTab2   Statement
hi def link ezotlTab3   Type
hi def link ezotlTab4   PreProc

if exists("+conceallevel")
  syntax conceal on
  setlocal conceallevel=3
endif
syn match ezotlBullet /^\t*\zs[.*・]\ze/ contained
if exists("+conceallevel")
  syntax conceal off
endif

syn match ezotlTitle    /^\s*[.*・].*/ contains=ezotlBullet
syn match ezotlList       /^\s*[-+].*/ contains=ezotlListBullet
syn match ezotlListBullet /^\s*[-+]\+/ contained
syn match ezotlComment    /^\s*[#].*/
syn match ezotlWarningMsg /!!!/
" syn region ezotlWarningMsg start=+!!!+ end=+!!!+ end=+$+ keepend

syn match ezotlTab1 /^\t\{1}[^\t].*/ contains=ezotlBullet,ezotlList,ezotlComment,ezotlWarningMsg,ezotlTitle,qfixmemoKeyword,actionlockKeyword
syn match ezotlTab2 /^\t\{2}[^\t].*/ contains=ezotlBullet,ezotlList,ezotlComment,ezotlWarningMsg,ezotlTitle,qfixmemoKeyword,actionlockKeyword
syn match ezotlTab3 /^\t\{3}[^\t].*/ contains=ezotlBullet,ezotlList,ezotlComment,ezotlWarningMsg,ezotlTitle,qfixmemoKeyword,actionlockKeyword
syn match ezotlTab4 /^\t\{4}[^\t].*/ contains=ezotlBullet,ezotlList,ezotlComment,ezotlWarningMsg,ezotlTitle,qfixmemoKeyword,actionlockKeyword

