" Vim syntax file
"
" Language:    howm schedule
" Maintainer:  fuenor@gmail.com
" Last Change: 2011-09-04 22:11

if exists("b:howm_schedule_syntax")
  " finish
endif

if &background == 'dark'
  hi howmTodo     ctermfg=Yellow      guifg=Yellow
  hi howmTodoUD   ctermfg=Magenta     guifg=LightRed
  hi howmSchedule ctermfg=Green       guifg=Green
  hi howmReminder ctermfg=Cyan        guifg=Cyan
  hi howmFinished ctermfg=DarkGrey    guifg=DarkGrey
else
  hi howmTodo     ctermfg=DarkYellow  guifg=DarkGoldenrod
  hi howmTodoUD   ctermfg=DarkMagenta guifg=DarkMagenta
  hi howmSchedule ctermfg=DarkGreen   guifg=DarkGreen
  hi howmReminder ctermfg=Blue        guifg=Blue
  hi howmFinished ctermfg=DarkGrey    guifg=Grey
endif
hi howmDeadline ctermfg=Red     guifg=Red
hi howmHoliday  ctermfg=Magenta guifg=Magenta
hi howmSpecial  ctermfg=Red     guifg=Red
hi def link howmNormal Normal

hi def link actionlockDate Underlined
hi def link actionlockTime Constant

if exists('g:QFixHowm_Date')
  exec 'syn match actionlockDate contained "'.g:QFixHowm_Date.'" '
else
  syn match actionlockDate contained "\d\{4}-\d\{2}-\d\{2}"
endif
syn match actionlockTime  contained "\d\d:\d\d\(:\d\d\)\?"

let s:pattern = '\[\d\{4}-\d\{2}-\d\{2}\( \d\{2}:\d\{2}\)\?]'
if exists('g:QFixHowm_Date')
  let s:pattern = '\['.g:QFixHowm_Date.'\( \d\{2}:\d\{2}\)\?]'
endif
let s:epat = '\{1,3}\((\([0-9]\+\)\?\([-+*]\?\c\(\(Sun\|Mon\|Tue\|Wed\|Thu\|Fri\|Sat\|Hol\|Hdy\)\?\([-+]\d\+\)\?\)\?\))\)\?\d*'
exe 'syn match howmNormal   "^'   .s:pattern.'"               contains=actionlockDate,actionlockTime'
exe 'syn match howmSchedule "^\s*'.s:pattern.'@' . s:epat .'" contains=actionlockDate,actionlockTime'
exe 'syn match howmDeadline "^\s*'.s:pattern.'!' . s:epat .'" contains=actionlockDate,actionlockTime'
exe 'syn match howmTodo     "^\s*'.s:pattern.'+' . s:epat .'" contains=actionlockDate,actionlockTime'
exe 'syn match howmReminder "^\s*'.s:pattern.'-' . s:epat .'" contains=actionlockDate,actionlockTime'
exe 'syn match howmTodoUD   "^\s*'.s:pattern.'\~'. s:epat .'" contains=actionlockDate,actionlockTime'
exe 'syn match howmFinished "^\s*'.s:pattern.'\."'
let s:pattern = '&\[\d\{4}-\d\{2}-\d\{2}\( \d\{2}:\d\{2}\)\?]\.'
if exists('g:QFixHowm_Date')
  let s:pattern = '&\['.g:QFixHowm_Date.'\( \d\{2}:\d\{2}\)\?]\.'
endif
exe 'syn match howmFinished "'.s:pattern.'"'

syn match txtUrl  '\(http\|https\|file\|ftp\)://[-0-9a-zA-Z;/?:@&=+$,_.!~*'()%#]*'
syn match txtFile '\(memo\|rel\|howm\)://[-0-9a-zA-Z;/?:@&=+$,_.!~*'()%#}[\]\\]*'
syn match txtFile '\([A-Za-z]:[/\\]\|\~[/\\]\)[-0-9a-zA-Z;/?:@&=+$,_.!~*'()%{}[\]\\]\+'
syn match txtFile '\[:\?&\?\zs\(memo\|rel\|howm\|https\|http\|file\|ftp\)://[^:]\+\ze:[^\]]*]'
syn match txtFile '\[:\?&\?\zs\([A-Za-z]:[/\\]\|\~[/\\]\|\.\.\?[/\\]\|[/\\]\)[^:]\+\ze:[^\]]*]'

hi def link txtFile Underlined
hi def link txtUrl  Underlined

if exists('g:howm_glink_pattern') && g:howm_glink_pattern != ''
  exe "syn match howmLink '" . g:howm_glink_pattern . ".*'" . '"'
endif
if exists('g:howm_clink_pattern') && g:howm_clink_pattern != ''
  exe "syn match howmLink '" . g:howm_clink_pattern . ".*'" . '"'
endif

hi def link howmLink  Underlined

" macro action
if exists('g:QFixHowm_MacroActionKey') && exists('g:QFixHowm_MacroActionPattern')
  if g:QFixHowm_MacroActionKey != '' && g:QFixHowm_MacroActionPattern != ''
    exe 'syn match actionlockMacroAction "^.*'.g:QFixHowm_MacroActionPattern.'.*$" contains=actionlockMacroActionDefine'
    exe 'syn match actionlockMacroActionDefine "'.g:QFixHowm_MacroActionPattern.'.*$"'
  endif
endif
hi def link actionlockMacroActionDefine howmFinished
hi def link actionlockMacroAction       Underlined

syn match actionlockList "\s*{[- +!$%&?*_<>=.\\]}"
hi def link actionlockList Type

" for changelog
if exists('b:current_syntax') && b:current_syntax == "changelog"
  syn region changelogFiles start="^\s\+[+*]\s" end=":\s" end="^$" contains=changelogBullet,changelogColon,changelogError,howmSchedule,howmDeadline,howmTodo,howmReminder,howmTodoUD,howmFinished keepend
endif

let b:howm_schedule_syntax = 1

