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
" QFixMemoBufWritePre() はデフォルトの整形処理で使用されているので必要な処理を
" 削除しないよう気をつけてください。
"
" NOTE: QFixHowm Ver.3として使用する場合
" コマンド実行前にはenv-cnv.vimの QFixHowmSetup() が実行されQFixMemoオプションと
" QFixHowmオプションの値が同一であることが保証されます。
" しかしユーザーがオプションを直接書き換えている直後のイベントでは同一性は保証
" されません。
" したがって(対応するQFixHowmオプションが実際に存在するなら)設定値のコピーを行
" うか QFixHowmSetup() を呼び出す必要があります。
"
" なおデフォルトではQFixHowmのオプションはユーザーが設定していない限りほとんど
" 存在しないので、基本的に処理自体はQFixMemoオプションを使用して行う必要があり
" ます。
" QFixMemo/QFixHowmのオプション対応関係についてはenv-cnv.vimの QFixHowmSetup()
" を参照してみてください。
" QFixHowm Ver.3では QFixMemoInit()をデフォルトで使用しています。
""""""""""""""""""""""""""""""

finish

" コマンド実行前処理
function! QFixMemoInit()
endfunction

" VimEnter
function! QFixMemoVimEnter()
endfunction

" BufNewFile,BufRead
function! QFixMemoBufRead()
endfunction

" BufEnter
function! QFixMemoBufEnter()
endfunction

" BufWinEnter
function! QFixMemoBufWinEnter()
endfunction

" BufLeave
function! QFixMemoBufLeave()
endfunction

" BufWritePre
" let g:qfixmemo_use_addtitle        = 1
" let g:qfixmemo_use_addtime         = 1
" let g:qfixmemo_use_updatetime      = 0
" let g:qfixmemo_use_deletenulllines = 1
" let g:qfixmemo_use_keyword         = 1
"
" 各関数は call qfixmemo#AddTitle(1) のように1を指定すると
" qfixmemo_use_addtitle の値にかかわらず強制処理します。
function! QFixMemoBufWritePre()
  " タイトル行付加
  call qfixmemo#AddTitle()
  " タイムスタンプ付加
  call qfixmemo#AddTime()
  " タイムスタンプアップデート
  call qfixmemo#UpdateTime()
  " ファイル末の空行を削除
  call qfixmemo#DeleteNullLines()
  " キーワードリンク作成
  call qfixmemo#AddKeyword()
endfunction

" BufWritePost
function! QFixMemoBufWritePost()
endfunction

" キーマップ
" キーマップを変更した場合は必要ならメニューバー定義も変更してください。

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

