"=============================================================================
"    Description: QFixMemo user functon
"  Last Modified: 0000-00-00 00:00
"=============================================================================
scriptencoding UTF-8

""""""""""""""""""""""""""""""
" このファイルはQFixMemoのpluginディレクトリなどruntimepathの通った場所へコピー
" して使います。
" 必要なイベント処理関数をfinishの前に設定して好みの処理を加えてください。
" イベント処理関数は.vimrc等で設定してもかまいません。
" 全てのイベントはQFixMemoファイルに対してのみ実行されます。
"
" NOTE: QFixHowm Ver.3として使用する場合
" コマンド実行前にenv-cnv.vimの QFixHowmSetup() が実行されQFixMemoオプションと
" QFixHowmオプションの値が同一であることが保証されます。
" ただしデフォルトではQFixHowmのオプションはユーザーが設定していない限りほとん
" ど存在しないのでQFixMemoのオプションのみが存在している状態です。
" したがって処理自体はQFixMemoオプションを使用して行う必要があります。
" QFixMemo/QFixHowmのオプション対応関係についてはenv-cnv.vimの QFixHowmSetup()
" を参照してみてください。
" またユーザー定義のイベント処理関数内でQFixMemoのオプションを変更した場合は
" (対応するQFixHowmオプションが実際に存在するなら)設定値のコピーを行う必要があ
" ります。
" QFixMemoBufWritePre() はenv-cnv.vimでも使用されているので、デフォルトの保存
" 設定を上書きすることになるので気をつけてください。
""""""""""""""""""""""""""""""

finish

" BufNewFile,BufRead
function! QFixMemoBufRead()
endfunction

" BufReadPost
function! QFixMemoBufReadPost()
endfunction

" BufWinEnter
function! QFixMemoBufWinEnter()
endfunction

" BufEnter
function! QFixMemoBufEnter()
endfunction

" BufWritePre
function! QFixMemoBufWritePre()
  " タイトル行付加
  call qfixmemo#AddTitle()
  " タイムスタンプ付加
  call qfixmemo#AddTime()
  " タイムスタンプアップデート
  " call qfixmemo#UpdateTime()
  " Wikiスタイルのキーワードリンク作成
  call qfixmemo#AddKeyword()
  " ファイル末の空行を削除
  call qfixmemo#DeleteNullLines()
endfunction

" BufWritePost
function! QFixMemoBufWritePost()
endfunction

" キーマップ
" キーマップを変更した場合はメニューバー定義も変更してください。

" グローバルキーマップ(デフォルト)
function! QFixMemoKeymap()
  " QFixMemoKeymap()を設定するとデフォルトのキーマップ自体が定義されなくなります。
  " グローバルキーマップの全てを設定したい場合に使います
  " nnoremap <silent> <Leader>a :<C-u>call qfixmemo#ListCache('open')<CR>
endfunction

" グローバルキーマップ変更
" キーマップを変更した場合はメニューバー定義を好みのものに変更してください。
function! QFixMemoKeymapPost()
  " グローバルキーマップを一部変更したい場合に使います
  " nnoremap <silent> <Leader>a :<C-u>call qfixmemo#ListCache('open')<CR>
endfunction

" バッファローカルキーマップ(デフォルト)
function! QFixMemoLocalKeymap()
  " QFixMemoLocalKeymap()を設定するとデフォルトのバッファローカルキーマップ自体が定義されなくなります。
  " バッファローカルキーマップの全てを設定したい場合に使います
  " nnoremap <silent> <buffer> <LocalLeader>f :<C-u>call qfixmemo#FGrep()<CR>
endfunction

" バッファローカルキーマップ変更
function! QFixMemoLocalKeymapPost()
  " バッファローカルキーマップを一部変更したい場合に使います
  " nnoremap <silent> <buffer> <LocalLeader>f :<C-u>call qfixmemo#FGrep()<CR>
endfunction

" メニューバー
function! QFixMemoMenubar(menu, leader)
  " g:qfixmemo_menubar が非0の場合に呼び出されます。
  " デフォルトのメニューバーアイテムはすべて作成されなくなります。
endfunction

" メニューバー変更
function! QFixMemoMenubarPost(menu, leader)
  " g:qfixmemo_menubar が非0の場合に呼び出されます。
  " メニューバーアイテムを一部変更したい場合に使用してください。
endfunction

