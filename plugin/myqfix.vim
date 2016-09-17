scriptencoding utf-8

" プレビュー等のQuickFix拡張機能が不要な場合は、.vimrcでdisable_QFixWinを1に設
" 定してください。
if exists('g:disable_QFixWin') && g:disable_QFixWin
  finish
endif
if exists('g:disable_MyQFix') && g:disable_MyQFix
  finish
endif

call qfixwin#init()

