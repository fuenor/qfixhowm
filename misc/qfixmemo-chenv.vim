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

" スクリプトファイル名
if !exists('g:qfixmemo_chenv_file')
  let g:qfixmemo_chenv_file = '~/.qfixmemoenv.vim'
endif
" 基準ディレクトリ
if !exists('g:qfixmemo_chdir')
  let g:qfixmemo_chdir = '~/qfixmemo'
  if exists('g:QFixMemo_RootDir')
    let g:qfixmemo_chdir = g:QFixMemo_RootDir
  elseif exists('g:qfixmemo_dir')
    let g:qfixmemo_chdir = g:qfixmemo_dir
  endif
endif

" ランダム表示保存ファイル
if !exists('g:qfixmemo_random_file')
  let g:qfixmemo_random_file = '~/.qfixmemo-random'
endif
let s:qfixmemo_random_file = g:qfixmemo_random_file

command! -nargs=1 QFixMemoChdir let qfixmemo_dir = qfixmemo_chdir.<q-args> |echo "qfixmemo_dir = ".qfixmemo_dir
function! QFixMemoChEnv(dir, fname, title)
  let g:qfixmemo_dir = g:qfixmemo_chdir . '/' . a:dir
  let g:qfixmemo_dir = substitute(g:qfixmemo_dir, '[/\\]$', '', '')

  if a:dir =~ '-mkd$'
    " let g:qfixmemo_ext        = 'mkd'
    let g:qfixmemo_filetype    = 'markdown'
  elseif a:dir =~ 'vimwiki$'
    " let g:qfixmemo_ext        = 'wiki'
    let g:qfixmemo_filetype    = 'vimwiki'
  else
    " let g:qfixmemo_ext        = 'txt'
    let g:qfixmemo_filetype    = 'qfix_memo'
  endif
  let g:qfixmemo_random_file = s:qfixmemo_random_file . '-' . a:dir

  " タイトルマーカーとタイトル行のタグ設定
  let g:qfixmemo_title = matchstr(a:title, '^[^[:space:]]\+')
  let title = strpart(a:title, strlen(g:qfixmemo_title))
  let title = substitute(title, '^\s*\|\s*$', '', 'g')
  let g:qfixmemo_template_tag = title

  if a:fname     == 'month'
    let g:qfixmemo_filename = '%Y/%Y-%m'
  elseif a:fname == 'day'
    let g:qfixmemo_filename = '%Y/%m/%Y-%m-%d'
  elseif a:fname == 'time'
    let g:qfixmemo_filename = '%Y/%m/%Y-%m-%d-%H%M%S'
  else
    " do nothing
  endif

  echo "qfixmemo_dir = ".g:qfixmemo_dir

  " スクリプト作成
  let file = expand(g:qfixmemo_chenv_file)
  let str = []
  let cmd = 'silent call QFixMemoChEnv('."'".a:dir."', '".a:fname."', '".a:title."')"
  cal add(str, cmd)
  let ostr = readfile(file)
  if str != ostr
    call writefile(str, file)
  endif
endfunction

silent! exec 'silent! source '.g:qfixmemo_chenv_file
if !filereadable(expand(g:qfixmemo_chenv_file))
  silent! call QFixMemoChEnv('', 'time', '=')
endif

