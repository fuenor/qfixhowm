scriptencoding utf-8

" デフォルトではqfixmemoコマンド実行時にautoload/qfixmru.vimが読み込まれます。
" qfixmruをqfixmemo専用ではなく汎用的なプラグインとして使用する場合は、.vimrc
" でqfixmru_preload=1を設定して、Vim起動時からQFixMRUを実行してください。
if exists('g:qfixmru_preload') && g:qfixmru_preload
  call qfixmru#init()
endif

