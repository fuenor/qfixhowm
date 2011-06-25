"=============================================================================
"    Description: QFixHowm環境変更スクリプト
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/qfixhowm
"  Last Modified: 2011-03-26 10:47
"        Version: 1.05
"=============================================================================
scriptencoding cp932

if exists('disable_QFixWin') && disable_QFixWin
  finish
endif
if exists('disable_MyHowm') && disable_MyHowm
  finish
endif
if exists("disable_MyHowmChEnv") && disable_MyHowmChEnv == 1
  finish
endif
if exists("loaded_MyHowmChEnv")
  finish
endif
let loaded_MyHowmChEnv = 1
if v:version < 700 || &cp
  finish
endif

" スクリプトファイル名
if !exists('g:QFixHowmChEnvFile')
  let g:QFixHowmChEnvFile = '~/.howmenv.vim'
endif
" 基準ディレクトリ
if !exists('g:QFixHowm_ChDir')
  let g:QFixHowm_ChDir = '~/howm'
  if exists('g:QFixHowm_RootDir')
    let g:QFixHowm_ChDir = g:QFixHowm_RootDir
  elseif exists('g:howm_dir')
    let g:QFixHowm_ChDir = g:howm_dir
  endif
endif
" デフォルト拡張子設定(howm-chenv.vimのみ有効)
if !exists('g:QFixHowmChEnv_FileExt')
  let g:QFixHowmChEnv_FileExt = 'howm'
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
  else
    let g:QFixHowm_HowmMode       = 1
    let suffix                    = g:QFixHowm_FileExt
    " let suffix                  = 'howm'
    " let g:QFixHowm_FileType     = 'howm_memo'
    " let g:QFixHowm_FileExt      = suffix
    let g:QFixHowm_RandomWalkFile = s:QFixHowm_RandomWalkFile . '-' . a:dir
  endif

  let g:QFixHowm_Title = matchstr(a:title, '^[^[:space:]]\+')
  let title = strpart(a:title, strlen(g:QFixHowm_Title))
  let title = substitute(title, '^\s*\|\s*$', '', 'g')
  let g:QFixHowm_DefaultTag = title

  let g:howm_dir                 = g:QFixHowm_ChDir . '/' . a:dir
  if a:fname     == 'month'
    let g:howm_filename          = '%Y/%Y-%m.'.suffix
  elseif a:fname == 'day'
    let g:howm_filename          = '%Y/%m/%Y-%m-%d.'.suffix
  elseif a:fname == 'time'
    let g:howm_filename          = '%Y/%m/%Y-%m-%d-%H%M%S.'.suffix
  else
    " do nothing
  endif
  let g:howm_filename            = fnamemodify(g:howm_filename,          ':r').'.'.suffix
  let g:QFixHowm_DiaryFile       = fnamemodify(g:QFixHowm_DiaryFile,     ':r').'.'.suffix
  let g:QFixHowm_QuickMemoFile   = fnamemodify(g:QFixHowm_QuickMemoFile, ':r').'.'.suffix

  " QFixHowm_HowmModeを切り替えた場合は必ず呼び出してください。
  silent! call QFixHowmSetup()
  echo "howm_dir = ".g:howm_dir
  silent! call MyMemoInit()

  " スクリプト作成
  let file = expand(g:QFixHowmChEnvFile)
  let str = []
  let cmd = 'silent call HowmChEnv('."'".a:dir."', '".a:fname."', '".a:title."')"
  cal add(str, cmd)
  let ostr = readfile(file)
  if str != ostr
    call writefile(str, file)
  endif
endfunction

silent! exec 'silent! source '.g:QFixHowmChEnvFile
if !filereadable(expand(g:QFixHowmChEnvFile))
  silent! call HowmChEnv('', 'time', '=')
endif

