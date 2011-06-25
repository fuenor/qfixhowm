"=============================================================================
"    Description: QFixMemo user functon
"  Last Modified: 0000-00-00 00:00
"=============================================================================
scriptencoding UTF-8

""""""""""""""""""""""""""""""
" user function
""""""""""""""""""""""""""""""
" キーマップ
function! QFixMemoKeymapPost()
  " nnoremap <silent> <Leader>a :<C-u>call qfixmemo#ListCache('open')<CR>
endfunction

" ローカルキーマップ
function! QFixMemoLocalKeymapPost()
  " nnoremap <silent> <buffer> <LocalLeader>f :<C-u>call qfixmemo#FGrep()<CR>
endfunction

" BufNewFile,BufRead
function! QFixMemoBufRead()
endfunction

" BufReadPost
function! QFixMemoBufReadPost()
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

" BufWinEnter
function! QFixMemoBufWinEnter()
endfunction

" BufEnter
function! QFixMemoBufEnter()
endfunction

" VimEnter
function! QFixMemoVimEnter()
endfunction

" Initialize
function! QFixMemoInit()
endfunction
