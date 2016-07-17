"=============================================================================
"    Description: QFixHowm環境変更スクリプト
"
"        CAUTION: このスクリプトは "QFixHowm" 専用です。
"                 "QFixMemo"として使用している場合は
"                 "qfixmemo-chenv.vim"を使用してください。
"
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/qfixhowm
"  Last Modified: 2013-07-29 18:23
"        Version: 1.08
"=============================================================================
scriptencoding utf-8

if exists('disable_MyHowm') && disable_MyHowm
  finish
endif
if exists("disable_QFixHowmChEnv") && disable_QFixHowmChEnv
  finish
endif
if exists("disable_MyHowmChEnv") && disable_MyHowmChEnv
  finish
endif
if exists("loaded_QFixHowmChEnv")
  finish
endif
let loaded_QFixHowmChEnv = 1
if v:version < 700
  finish
endif

" (設定例)
" 以下を .vimrcへ追加
"
" " 現メモディレクトリ表示
" nnoremap <silent> g,hh :echo howm_dir<CR>
" " 環境変更コマンド
" nnoremap <silent> g,ha :call HowmChEnv('',         'time', '=')<CR>
" nnoremap <silent> g,hm :call HowmChEnv('main',     'time', '=')<CR>
" nnoremap <silent> g,hw :call HowmChEnv('work',     'day',  '=')<CR>
" nnoremap <silent> g,hc :call HowmChEnv('pc',       'time', '= [:pc]')<CR>
" nnoremap <silent> g,hd :call HowmChEnv('howm-mkd', 'time', '#')<CR>
" nnoremap <silent> g,hd :call HowmChEnv('howm-org', 'time', '.')<CR>
" nnoremap <silent> g,hv :call HowmChEnv('vimwiki',  'time', '=')<CR>
"
" (オプション解説)
" :call HowmChEnv(dir, fileformat, title)
"
" dir
" 使用するディレクトリ指定
" 基準ディレクトリ下の dir が付加されたディレクトリを使用する
" 基準ディレクトリは以下の順番で決定される
"   1. QFixHowm_ChDir
"   2. QFixHowm_RootDir
"   3. qfixmemo_dir
"   4. howm_dir
"
" なおdirの最後に -mkd がつくとファイルタイプが markdown、-org ならorg、
" vimwikiなら vimwikiに設定される。
"
" format
" 生成するファイル名指定
" | month  | 月単位   |
" | day    | 日単位   |
" | time   | 時刻単位 |
"
" title
" 最初の空白までをタイトル記号として QFixHowm_Title へ設定。
" 空白以降はタグとして QFixHowm_DefaultTag へ登録される

" NOTE:
" 通常MRUリストは howm_dirを基準とする相対パスで保持するがhowm_dirを切り替える
" 場合には基準ディレクトリが異なるためパスを維持できなくなる。
" 対処として本プラグインではMRUの基準ディレクトリQFixMRU_RootDirに
" 本プラグインの基準ディレクトリ QFixHowm_ChDirを設定する。
" ユーザーが独自にQFixMRU_RootDirを指定する場合は QFixHowmの基準ディレクトリよ
" り上位のディレクトリを指定する必要がある。

" スクリプトファイル名
if !exists('g:QFixHowmChEnvFile')
  let g:QFixHowmChEnvFile = '~/.howmenv.vim'
endif
" 基準ディレクトリ
if !exists('g:QFixHowm_ChDir')
  let g:QFixHowm_ChDir = '~/howm'
  if exists('g:QFixHowm_RootDir')
    let g:QFixHowm_ChDir = g:QFixHowm_ChDir
  elseif exists('g:qfixmemo_dir')
    let g:QFixHowm_ChDir = g:qfixmemo_dir
  elseif exists('g:howm_dir')
    let g:QFixHowm_ChDir = g:howm_dir
  endif
endif
" MRUの基準ディレクトリを設定する
if !exists('g:QFixMRU_RootDir')
  let g:QFixMRU_RootDir = g:QFixHowm_ChDir
  if exists('g:QFixHowm_RootDir')
    let g:QFixMRU_RootDir = g:QFixHowm_RootDir
  endif
endif
" デフォルト拡張子設定(howm-chenv.vimのみ有効)
if !exists('g:QFixHowmChEnv_FileExt')
  let g:QFixHowmChEnv_FileExt = ''
  if exists('g:howm_filename')
    let g:QFixHowmChEnv_FileExt = fnamemodify(g:howm_filename, ':e')
  endif
  if exists('g:QFixHowm_FileExt')
    let g:QFixHowmChEnv_FileExt = g:QFixHowm_FileExt
  endif
  if g:QFixHowmChEnv_FileExt == ''
    let g:QFixHowmChEnv_FileExt = 'txt'
  endif
endif
" デフォルトファイルタイプ(howm-chenv.vimのみ有効)
if !exists('g:QFixHowmChEnv_FileType')
  let g:QFixHowmChEnv_FileType = ''
  if exists('g:QFixHowm_FileType')
    let g:QFixHowmChEnv_FileType = g:QFixHowm_FileType
  endif
  if g:QFixHowmChEnv_FileType == ''
    let g:QFixHowmChEnv_FileType = 'howm_memo'
  endif
endif

" デフォルト設定
if !exists('g:howm_filename')
  let g:howm_filename     = '%Y/%m/%Y-%m-%d-%H%M%S.'.g:QFixHowmChEnv_FileExt
endif
if !exists('g:QFixHowm_FileExt')
  let g:QFixHowm_FileExt  = fnamemodify(g:howm_filename,':e')
endif

" ランダム表示保存ファイル
if !exists('g:QFixHowm_RandomWalkFile')
  let g:QFixHowm_RandomWalkFile = '~/.howm-random'
endif
let s:QFixHowm_RandomWalkFile = g:QFixHowm_RandomWalkFile

command! -nargs=1 HowmChdir let howm_dir = QFixHowm_ChDir.<q-args> |echo "howm_dir = ".howm_dir
function! HowmChEnv(dir, fname, title)
  if exists('g:QFixMRU_state') && g:QFixMRU_state == 1
    call QFixMRUWrite(0)
    call QFixMRUWrite(1)
  endif
  if a:dir =~ 'vimwiki$'
    let g:QFixHowm_HowmMode       = 0
    let suffix                    = 'wiki'
    let g:QFixHowm_UserFileType   = 'vimwiki'
    let g:QFixHowm_UserFileExt    = suffix
    let g:QFixHowm_RandomWalkFile = s:QFixHowm_RandomWalkFile . '-' . suffix
  elseif a:dir =~ '-mkd$'
    let g:QFixHowm_HowmMode       = 0
    let suffix                    = 'mkd'
    let g:QFixHowm_UserFileType   = 'markdown'
    let g:QFixHowm_UserFileExt    = suffix
    let g:QFixHowm_RandomWalkFile = s:QFixHowm_RandomWalkFile . '-' . suffix
  elseif a:dir =~ '-org$'
    let g:QFixHowm_HowmMode       = 0
    let suffix                    = 'org'
    let g:QFixHowm_UserFileType   = 'org'
    let g:QFixHowm_UserFileExt    = suffix
    let g:QFixHowm_RandomWalkFile = s:QFixHowm_RandomWalkFile . '-' . suffix
  else
    let g:QFixHowm_HowmMode       = 1
    let suffix                    = g:QFixHowmChEnv_FileExt
    let g:QFixHowm_FileType       = g:QFixHowmChEnv_FileType
    let g:QFixHowm_FileExt        = suffix
    let g:QFixHowm_RandomWalkFile = s:QFixHowm_RandomWalkFile . '-' . a:dir
  endif

  let g:QFixHowm_Title = matchstr(a:title, '^[^[:space:]]\+')
  let title = strpart(a:title, strlen(g:QFixHowm_Title))
  let title = substitute(title, '^\s*\|\s*$', '', 'g')
  let g:QFixHowm_DefaultTag = title

  let g:howm_dir                 = g:QFixHowm_ChDir . '/' . a:dir
  let g:howm_dir                 = substitute(g:howm_dir, '[/\\]$', '', '')
  if a:fname     == 'month'
    let g:howm_filename          = '%Y/%Y-%m.'.suffix
  elseif a:fname == 'day'
    let g:howm_filename          = '%Y/%m/%Y-%m-%d.'.suffix
  elseif a:fname == 'time'
    let g:howm_filename          = '%Y/%m/%Y-%m-%d-%H%M%S.'.suffix
  endif

  let g:howm_filename            = fnamemodify(g:howm_filename,          ':r').'.'.suffix
  if exists('g:QFixHowm_DiaryFile')
    let g:QFixHowm_DiaryFile     = fnamemodify(g:QFixHowm_DiaryFile,     ':r').'.'.suffix
  endif
  if exists('g:QFixHowm_QuickMemoFile')
    let g:QFixHowm_QuickMemoFile = fnamemodify(g:QFixHowm_QuickMemoFile, ':r').'.'.suffix
  endif

  " QFixMemoオプションへ変換
  if exists('*QFixHowmSetup')
    call QFixHowmSetup()
  endif
  echo "howm_dir : ". (a:dir != "" ? a:dir : 'all')

  " スクリプト作成
  let file = expand(g:QFixHowmChEnvFile)
  let dir = fnamemodify(file, ':p:h')
  if (isdirectory(dir) == 0)
    silent! call mkdir(dir, 'p')
  endif
  let str = []
  let cmd = 'silent call HowmChEnv('."'".a:dir."', '".a:fname."', '".a:title."')"
  cal add(str, cmd)
  let ostr = readfile(file)
  if str != ostr
    call writefile(str, file)
  endif
  if exists('g:fudist') && g:fudist
    let g:qfixmemo_random_dir = g:qfixmemo_dir
  endif
endfunction

silent! exec 'silent! source '.g:QFixHowmChEnvFile
if !filereadable(expand(g:QFixHowmChEnvFile))
  silent! call HowmChEnv('', 'time', '=')
endif

" for keymap compatibility
function! QFixMemoChEnv(dir, fname, title)
  return HowmChEnv(a:dir, a:fname, a:title)
endfunction

