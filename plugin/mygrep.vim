scriptencoding utf-8

" qfixgrepとしての動作が不要な場合は、.vimrcでdisable_QFixGrepを1に設定してください。
if exists('g:disable_QFixGrep') && g:disable_QFixGrep
  finish
endif
if exists('g:disable_MyGrep') && g:disable_MyGrep
  finish
endif

call qfixgrep#init()

