"=============================================================================
"    Description: QFixMemo環境変更スクリプト
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/qfixhowm
"  Last Modified: 0000-00-00 00:00
"        Version: 1.00
"=============================================================================
scriptencoding UTF-8

if exists('disable_QFixWin') && disable_QFixWin
  finish
endif
if exists('disable_qfixmemo') && disable_qfixmemo
  finish
endif
if exists("disable_QFixMemoChEnv") && disable_QFixMemoChEnv == 1
  finish
endif
if exists("loaded_QFixMemoChEnv")
  finish
endif
let loaded_QFixMemoChEnv = 1
if v:version < 700 || &cp
  finish
endif

" (設定例)
" 以下を .vimrcへ追加
"
" " 現メモディレクトリ表示
" nnoremap <silent> g,hh :echo qfixmemo_dir<CR>
" " 環境変更コマンド
" nnoremap <silent> g,ha :call QFixMemoChEnv('',         'time', '=')<CR>
" nnoremap <silent> g,hm :call QFixMemoChEnv('main',     'time', '=')<CR>
" nnoremap <silent> g,hw :call QFixMemoChEnv('work',     'day',  '=')<CR>
" nnoremap <silent> g,hc :call QFixMemoChEnv('pc',       'time', '= [:pc]')<CR>
" nnoremap <silent> g,hd :call QFixMemoChEnv('memo-mkd', 'time', '#')<CR>
" nnoremap <silent> g,hd :call QFixMemoChEnv('memo-org', 'time', '.')<CR>
" nnoremap <silent> g,hv :call QFixMemoChEnv('vimwiki',  'time', '=')<CR>
"
" (オプション解説)
" :call QFixMemoChEnv(dir, fileformat, title)
"
" dir
" 使用するディレクトリ指定
" qfixmemo_chenv_dir を基準ディレクトリとして dir が付加される
" 基準ディレクトリは以下の順番で決定される
"   1. qfixmemo_chenv_dir
"   2. qfixmemo_root
"   3. qfixmemo_dir
"
" なおdirの最後に -mkd がつくとファイルタイプが markdown、-org ならorg、
" vimwikiなら vimwikiに設定される。
"
" MRUリスト
" 通常MRUリストは qfixmemo_dirを基準とする相対パスで保持するがqfixmemo_dirを切
" り替える場合には基準ディレクトリが異なるためパスを維持できなくなる。
" 対処として本プラグインではMRUの基準ディレクトリQFixMRU_RootDirに
" qfixmemo_chenv_dirを設定するが、独自にQFixMRU_RootDirを指定する場合は
" QFixMemoの基準ディレクトリより上位のディレクトリを指定する必要がある。
"
" format
" 生成するファイル名指定
" | month  | 月単位   |
" | day    | 日単位   |
" | time   | 時刻単位 |
"
" title
" 最初の空白までをタイトル記号として qfixmemo_title へ設定。
" 空白以降はタグとして qfixmemo_template_tag へ登録される
"
" NOTE:
" キーマップ定義にQFixMemoKeymapPost() を使用するとキーマップリーダーが自動変更される
" function! QFixMemoKeymapPost()
"   nnoremap <silent> <Leader>ha :call QFixMemoChEnv('',         'time', '=')<CR>
"   nnoremap <silent> <Leader>hm :call QFixMemoChEnv('main',     'time', '=')<CR>
"   nnoremap <silent> <Leader>hw :call QFixMemoChEnv('work',     'day',  '=')<CR>
"   nnoremap <silent> <Leader>hc :call QFixMemoChEnv('pc',       'time', '= [:pc]')<CR>
" endfunction

""""""""""""""""""""""""""""""
" スクリプトファイル名
if !exists('g:qfixmemo_chenv_file')
  let g:qfixmemo_chenv_file = '~/.qfixmemoenv.vim'
endif
" 基準ディレクトリ
if !exists('g:qfixmemo_chenv_dir')
  let g:qfixmemo_chenv_dir = '~/qfixmemo'
  if exists('g:qfixmemo_root')
    let g:qfixmemo_chenv_dir = g:qfixmemo_root
  elseif exists('g:qfixmemo_dir')
    let g:qfixmemo_chenv_dir = g:qfixmemo_dir
  endif
endif
" MRUの基準ディレクトリを設定する
if !exists('g:QFixMRU_RootDir')
  let g:QFixMRU_RootDir = g:qfixmemo_chenv_dir
endif
" デフォルト拡張子設定(qfixmemo-chenv.vimのみ有効)
if !exists('g:qfixmemo_chenv_ext')
  let g:qfixmemo_chenv_ext = ''
  if exists('g:qfixmemo_filename')
    let g:qfixmemo_chenv_ext = fnamemodify(g:qfixmemo_filename, ':e')
  endif
  if exists('g:qfixmemo_ext')
    let g:qfixmemo_chenv_ext = g:qfixmemo_ext
  endif
  if g:qfixmemo_chenv_ext == ''
    let g:qfixmemo_chenv_ext = 'txt'
  endif
endif
" デフォルトファイルタイプ(howm-chenv.vimのみ有効)
if !exists('g:qfixmemo_chenv_filetype')
  let g:qfixmemo_chenv_filetype = ''
  if exists('g:qfixmemo_filetype')
    let g:qfixmemo_chenv_filetype = g:qfixmemo_filetype
  endif
  if g:qfixmemo_chenv_filetype == ''
    let g:qfixmemo_chenv_filetype = 'qfix_memo'
  endif
endif

" ランダム表示保存ファイル
if !exists('g:qfixmemo_random_file')
  let g:qfixmemo_random_file = '~/.qfixmemo-random'
endif
let s:qfixmemo_random_file = g:qfixmemo_random_file

command! -nargs=1 QFixMemoChdir let qfixmemo_dir = qfixmemo_chenv_dir.<q-args> |echo "qfixmemo_dir = ".qfixmemo_dir
function! QFixMemoChEnv(dir, fname, title)
  let g:qfixmemo_dir = g:qfixmemo_chenv_dir . '/' . a:dir
  let g:qfixmemo_dir = substitute(g:qfixmemo_dir, '[/\\]$', '', '')

  " ファイル拡張子とファイルタイプの指定
  if a:dir =~ '-mkd$'
    let g:qfixmemo_ext       = 'mkd'
    let g:qfixmemo_filetype  = 'markdown'
  elseif a:dir =~ '-org$'
    let g:qfixmemo_ext       = 'org'
    let g:qfixmemo_filetype  = 'org'
  elseif a:dir =~ 'vimwiki$'
    let g:qfixmemo_ext       = 'wiki'
    let g:qfixmemo_filetype  = 'vimwiki'
  else
    let g:qfixmemo_ext       = g:qfixmemo_chenv_ext
    let g:qfixmemo_filetype  = g:qfixmemo_chenv_filetype
  endif
  let g:qfixmemo_random_dir  = g:qfixmemo_dir
  let g:qfixmemo_random_file = s:qfixmemo_random_file . '-' . a:dir

  " タイトルマーカーとタイトル行のタグ設定
  let g:qfixmemo_title = matchstr(a:title, '^[^[:space:]]\+')
  let title = strpart(a:title, strlen(g:qfixmemo_title))
  let title = substitute(title, '^\s*\|\s*$', '', 'g')
  let g:qfixmemo_template_tag = title

  " ファイル名設定
  if a:fname     == 'month'
    let g:qfixmemo_filename = '%Y/%Y-%m'
  elseif a:fname == 'day'
    let g:qfixmemo_filename = '%Y/%m/%Y-%m-%d'
  elseif a:fname == 'time'
    let g:qfixmemo_filename = '%Y/%m/%Y-%m-%d-%H%M%S'
  endif

  echo "qfixmemo_dir = ".g:qfixmemo_dir

  " スクリプト作成
  let file = expand(g:qfixmemo_chenv_file)
  let str = []
  let cmd = 'silent call QFixMemoChEnv('."'".a:dir."', '".a:fname."', '".a:title."')"
  call add(str, cmd)
  let ostr = readfile(file)
  if str != ostr
    call writefile(str, file)
  endif
endfunction

silent! exec 'silent! source '.g:qfixmemo_chenv_file
if !filereadable(expand(g:qfixmemo_chenv_file))
  silent! call QFixMemoChEnv('', 'time', '=')
endif

