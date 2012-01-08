"=============================================================================
"    Description: Preview for mru.vim
"                 (myqfix.vim required)
"                 このプラグインはmru.vimにプレビュー表示を追加します。
"                 任意のバッファにプレビューを追加したい場合のテンプレートとし
"                 て使用してください。
"         Author: fuenor <fuenor@gmail.com>
"        Version: 2.00
"=============================================================================
scriptencoding utf-8
if exists('g:loaded_MRUpreview') && !exists('g:fudist')
  finish
endif
let g:loaded_MRUpreview = 1

if v:version < 700
  finish
endif

" プレビューの初期値
if !exists('g:QFix_MRUPreviewEnable')
  let g:QFix_MRUPreviewEnable = 1
endif

augroup MRUPreview
  au!
  autocmd BufWinEnter __MRU_Files__ call <SID>BufWinEnter(g:QFix_MRUPreviewEnable)
  autocmd BufLeave    __MRU_Files__ call <SID>BufLeave()
  autocmd CursorHold  __MRU_Files__ call <SID>Preview()
augroup END

function! s:Preview()
  if !g:QFix_MRUPreviewEnable
    return
  endif
  " ファイル名と行番号を取得してプレビューウィンドウを表示
  let file = substitute(getline('.'), '^.*|\s*', '', '')
  let lnum = 1
  call QFixPreviewOpen(file, lnum)
endfunction

function! s:BufWinEnter(preview)
  " プレビューを使用するならQFixAltWincmdMap()は必ず実行
  " 単にCursorHold用に updatetimeを設定したいだけなら
  " let b:qfixwin_updatetime = 1 だけでもよい
  call QFixAltWincmdMap()
  nnoremap <buffer> <silent> i :<C-u>call <SID>TogglePreview()<CR>
endfunction

function! s:BufLeave()
  call QFixPclose('force')
endfunction

function! s:TogglePreview()
  let g:QFix_MRUPreviewEnable = !g:QFix_MRUPreviewEnable
  call QFixPclose('force')
endfunction

" myqfix.vimが存在しない場合のエラー対策
if !exists('*QFixPclose')
function QFixPclose(...)
endfunction
endif

if !exists('*QFixPreviewOpen')
function! QFixPreviewOpen(...)
endfunction
endif

if !exists('*QFixAltWincmdMap')
function! QFixAltWincmdMap(...)
endfunction
endif

"-----------------------------------------------------------------------------
" ここから先は 改変版mru.vim用の特殊処理で、単に任意バッファにプレビューを追加
" する場合には不要です。
" https://sites.google.com/site/fudist/Home/modify
" mru.vim+プレビューの終了時に呼び出し元バッファへ戻ってウィンドウサイズを復元
" するようにしています。
function! MRUPre()
  let s:pbuf = bufnr('%')
  let s:wh = winheight(0)
  let s:ww = winwidth(0)
endfunction

function! MRUPost()
  let @/=b:saved_mru_search
  noh
  call QFixPclose(1)
  close
  let winnr = bufwinnr(s:pbuf)
  if winnr != -1
    exe winnr.'wincmd w'
    let w = &lines - winheight(0) - &cmdheight - (&laststatus > 0 ? 1 : 0)
    if w > 0
      exe 'resize '. s:wh
    endif
    exe 'vertical resize '. s:ww
  endif
endfunction

