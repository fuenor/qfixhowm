"=============================================================================
"    Description: QFixHowm option convert function
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home  (Japanese)
"  Last Modified: 0000-00-00 00:00
"=============================================================================
let s:Version = 1.00
scriptencoding utf-8

if !exists('g:QFixHowm_Convert')
  let QFixHowm_Convert = 1
endif
if exists('g:QFixHowm_Convert') && g:QFixHowm_Convert == 0
  finish
endif
"-----------------------------------------------------------------------------
" このファイルでオプションコンバートを行っているため、QFixMemoはQFixHowmとオプ
" ション互換のプラグインとして動作しています。
"
" 以下をVimの設定ファイルへ設定追加するとQFixHowmオプションのコンバートを行わ
" なくなります。
"
" " QFixHowmとのオプションコンバートを行わない
" let QFixHowm_Convert = 0
"
" コンバートを切っても基本的なコマンドや動作はQFixMemoとしてほぼ同一に扱えます。
" QFixMemoのドキュメントについては以下を参照してください。
" doc/qfixmemo.jax
" http://github.com/fuenor/qfixmemo/blob/master/doc/qfixmemo.jax
"
" 予定・TODOについてはコンバートを切ってもQFixHowmのオプションがそのまま適用さ
" れます。
" http://sites.google.com/site/fudist/Home/qfixhowm/howm-reminder
" doc/howm_schedule.jax
"
" QFixHowm Ver.3の実装概要については以下を参照して下さい
" https://sites.google.com/site/fudist/Home/qfixdev/ver3
"
" CAUTION: ファイルの読み込み順がファイル名順である事に依存しています。
"          (env-cnv.vimの初期化がqfixmemo.vimより先に行われると仮定)
"-----------------------------------------------------------------------------

""""""""""""""""""""""""""""""
" イベント処理
""""""""""""""""""""""""""""""
" howmファイルの自動整形を使用する
if !exists('g:QFixHowm_Autoformat')
  let g:QFixHowm_Autoformat = 1
endif
"更新時間を管理する
if !exists('g:QFixHowm_RecentMode')
  let g:QFixHowm_RecentMode = 0
endif
" 更新時間埋め込み
if !exists('g:QFixHowm_SaveTime')
  let g:QFixHowm_SaveTime = 0
endif
if g:QFixHowm_RecentMode == 2
  let g:QFixHowm_SaveTime = 2
endif

" BufWritePre
function! QFixMemoBufWritePre()
  if g:QFixHowm_Autoformat > 0
    " タイトル行付加
    call qfixmemo#AddTitle()
    if g:QFixHowm_SaveTime > -1
      " タイムスタンプ付加
      call qfixmemo#AddTime()
    endif
    if g:QFixHowm_SaveTime == 2
      " タイムスタンプアップデート
      call qfixmemo#UpdateTime()
    endif
  endif
  " キーワード作成
  call qfixmemo#AddKeyword()
  " ファイル末の空行を削除
  if g:QFixHowm_Autoformat > 0
    call qfixmemo#DeleteNullLines()
  endif
endfunction

" BufWinEnter quickfix
silent! function QFixMemoQFBufWinEnterPost()
  if exists("*QFixHowmExportSchedule")
    nnoremap <buffer> <silent> !  :call QFixHowmCmd_ScheduleList()<CR>
    vnoremap <buffer> <silent> !  :call QFixHowmCmd_ScheduleList('visual')<CR>
  endif
endfunction

" 初期化
function! QFixMemoInit(init)
  call QFixHowmSetup()
endfunction

""""""""""""""""""""""""""""""
" オプションコンバート
""""""""""""""""""""""""""""""
let s:howmsuffix = 'howm'
" 常にqfixmemoファイルとして扱うファイルの正規表現
let g:qfixmemo_isqfixmemo_regxp = '\c\.'.s:howmsuffix.'$'

" キーマップリーダー
if !exists('g:qfixmemo_mapleader')
  let g:qfixmemo_mapleader = 'g,'
endif
if exists('g:QFixHowm_Key') || exists('g:QFixHowm_KeyB')
  if !exists('g:QFixHowm_Key')
    let g:QFixHowm_Key = 'g'
  endif
  if !exists('g:QFixHowm_KeyB')
    let g:QFixHowm_KeyB = ','
  endif
  let g:qfixmemo_mapleader = g:QFixHowm_Key . g:QFixHowm_KeyB
endif

" QFixMemo/QFixHowmでデフォルトが異なるオプション
if !exists('g:qfixmemo_dir')
  let g:qfixmemo_dir = '~/howm'
endif
if !exists('g:qfixmemo_filename')
  let g:qfixmemo_filename = '%Y/%m/%Y-%m-%d-%H%M%S.'.s:howmsuffix
endif
if !exists('g:qfixmemo_ext')
  let g:qfixmemo_ext = fnamemodify(g:qfixmemo_filename,':e')
endif
if !exists('g:qfixmemo_filetype')
  let g:qfixmemo_filetype = 'howm_memo'
endif
if !exists('g:qfixmemo_diary')
  let g:qfixmemo_diary = '%Y/%m/%Y-%m-%d-000000'
endif
if !exists('g:qfixmemo_pairfile_dir')
  let g:qfixmemo_pairfile_dir = 'pairlink'
endif
if !exists('g:qfixmemo_recentdays')
  let g:qfixmemo_recentdays = 5
endif
if !exists('g:qfixmemo_keyword_mode')
  let g:qfixmemo_keyword_mode = 0
endif
if !exists('g:qfixmemo_keyword_dir')
  let g:qfixmemo_keyword_dir = ''
endif
if !exists('g:qfixmemo_keyword_file')
  let g:qfixmemo_keyword_file = '~/.howm-keys'
endif
if !exists('g:qfixmemo_random_file')
  let g:qfixmemo_random_file = '~/.howm-random'
endif

" 最低限必要なオプション
if !exists('g:howm_dir')
  let g:howm_dir = g:qfixmemo_dir
endif
if !exists('g:howm_filename')
  let g:howm_filename = g:qfixmemo_filename
endif
if !exists('g:QFixHowm_FileExt')
  let g:QFixHowm_FileExt  = fnamemodify(g:howm_filename, ':e')
endif
if !exists('g:QFixHowm_FileType')
  let g:QFixHowm_FileType = g:qfixmemo_filetype
endif
let g:qfixmemo_dir      = g:howm_dir
let g:qfixmemo_filename = g:howm_filename
let g:qfixmemo_ext      = g:QFixHowm_FileExt
let g:qfixmemo_filetype = g:QFixHowm_FileType
" howm_filenameから生成されるオプション
if exists('g:howm_filename')
  if !exists('g:QFixHowm_DiaryFile') && !exists('g:qfixmemo_diary')
    let g:QFixHowm_DiaryFile = fnamemodify(g:howm_filename, ':h').'/%Y-%m-%d-000000.'.g:QFixHowm_FileExt
  endif
  if !exists('g:QFixHowm_QuickMemoFile') && !exists('g:qfixmemo_quickmemo')
    let g:QFixHowm_QuickMemoFile = 'Qmem-00-0000-00-00-000000.'.g:QFixHowm_FileExt
  endif
  if !exists('g:QFixHowm_FilenameLen') && !exists('g:qfixmemo_rename_length')
    let g:QFixHowm_FilenameLen = len(fnamemodify(strftime(g:howm_filename), ':t:r'))
  endif
endif

" howmテンプレート
if !exists('g:qfixmemo_template')
  let g:qfixmemo_template = [
    \ "%TITLE% %TAG%",
    \ "%DATE%",
    \ ""
  \]
endif
" howmテンプレート(カーソル移動)
if !exists('g:qfixmemo_template_keycmd')
  let g:qfixmemo_template_keycmd = "$a"
endif
" mkdテンプレート
if !exists('g:QFixHowm_Template_mkd')
  let g:QFixHowm_Template_mkd = [
    \ "%TITLE% %TAG%",
    \ ""
  \]
endif
" mkdテンプレート(カーソル移動)
if !exists('g:QFixHowm_Cmd_NewEntry_mkd')
  let g:QFixHowm_Cmd_NewEntry_mkd = "$a"
endif

" 基準ディレクトリ
if !exists('g:QFixMRU_RootDir') && exists('g:QFixHowm_RootDir')
  let g:QFixMRU_RootDir = g:QFixHowm_RootDir
endif
if !exists('g:qfixmemo_root_dir') && exists('g:QFixHowm_RootDir')
  let g:qfixmemo_root_dir = g:QFixHowm_RootDir
endif
" rel://
if !exists('g:QFixHowm_RelPath')
  let g:QFixHowm_RelPath = g:howm_dir
endif
" メニュー
if exists('g:qfixmemo_menu_title')
  if !exists('g:QFixHowm_MenuDir')
    let g:QFixHowm_MenuDir  = fnamemodify(g:qfixmemo_menu_title, ':p:h')
  endif
  if !exists('g:QFixHowm_Menufile')
    let g:QFixHowm_Menufile = fnamemodify(g:qfixmemo_menu_title, ':t')
  endif
endif

" 一度だけ初期化するオプション
if exists('g:QFixHowm_RecentDays')
  let g:qfixmemo_recentdays = g:QFixHowm_RecentDays
endif
if exists('g:QFixHowm_CalendarWinCmd')
  let g:qfixmemo_calendar_wincmd = g:QFixHowm_CalendarWinCmd
endif
if exists('g:QFixHowm_UseLocationList')
  let g:qfixmemo_use_location_list = g:QFixHowm_UseLocationList
endif
if exists('g:QFixHowm_ListCloseOnJump')
  let g:qfixlist_close_on_jump = g:QFixHowm_ListCloseOnJump
endif
if exists('g:QFixHowm_MenuBar')
  let g:qfixmemo_menubar = g:QFixHowm_MenuBar
endif
let g:QFixHowm_DateActionLockDefault = 0
if exists('g:QFixHowm_VimEnterCmd')
  let g:qfixmemo_vimenter_cmd  = g:QFixHowm_VimEnterCmd
endif
if exists('g:QFixHowm_VimEnterTime')
  let g:qfixmemo_vimenter_time = g:QFixHowm_VimEnterTime
endif
if exists('g:QFixHowm_VimEnterFile')
  let g:qfixmemo_vimenter_file = g:QFixHowm_VimEnterFile
endif
if exists('g:QFixHowm_VimEnterMsg')
  let g:qfixmemo_vimenter_msg  = g:QFixHowm_VimEnterMsg
endif

let s:cnvopt = [
  \ ['let g:howm_dir = substitute(%s, "[/\\]$", "", "")', 'g:howm_dir'],
  \ ['let g:qfixmemo_dir          = %s', 'g:howm_dir'],
  \ ["let g:qfixmemo_filename = fnamemodify(%s, ':r')", 'g:howm_filename'],
  \ ['let g:qfixmemo_ext          = %s', 'g:QFixHowm_FileExt'],
  \ ['let g:qfixmemo_fileencoding = %s', 'g:howm_fileencoding'],
  \ ['let g:qfixmemo_fileformat   = %s', 'g:howm_fileformat'],
  \ ['let g:qfixmemo_filetype     = %s', 'g:QFixHowm_FileType'],
  \ ['let g:qfixmemo_quickmemo    = %s', 'g:QFixHowm_QuickMemoFile'],
  \ ['let g:qfixmemo_diary        = %s', 'g:QFixHowm_DiaryFile'],
  \ ['let g:qfixmemo_pairfile_dir = %s', 'g:QFixHowm_PairLinkDir'],
  \ ['let g:qfixmemo_title         = %s', 'g:QFixHowm_Title'],
  \ ['let g:qfixmemo_title_length  = %s', 'g:QFixHowm_Replace_Title_Len'],
  \ ['let g:qfixmemo_forceencoding = %s', 'g:QFixHowm_ForceEncoding'],
  \ ['let g:qfixmemo_folding       = %s', 'g:QFixHowm_Folding'],
  \ ['let g:qfixmemo_grep_cword    = %s', 'g:QFixHowm_DefaultSearchWord'],
  \ ['let g:qfixmemo_splitmode     = %s', 'g:QFixHowm_SplitMode'],
  \ ['let g:qfixmemo_rename_length = %s', 'g:QFixHowm_FilenameLen'],
  \ ['let g:qfixmemo_swlist_action = %s', 'g:QFixHowm_SwitchListActionLock'],
  \ ['let g:qfixmemo_switch_action = %s', 'g:QFixHowm_UserSwActionLock'],
  \ ['let g:qfixmemo_use_list_cache = %s', 'g:QFixHowm_TitleListCache'],
  \ ['let g:qfixmemo_template        = %s', 'g:QFixHowm_Template'],
  \ ['let g:qfixmemo_template_keycmd = %s', 'g:QFixHowm_Cmd_NewEntry'],
  \ ['let g:qfixmemo_template_tag    = %s', 'g:QFixHowm_DefaultTag'],
  \ ['let g:qfixmemo_submenu_title           = %s', 'g:SubWindow_Title'],
  \ ['let g:qfixmemo_submenu_direction       = %s', 'g:SubWindow_Direction'],
  \ ['let g:qfixmemo_submenu_size            = %s', 'g:SubWindow_Size'],
  \ ['let g:qfixmemo_submenu_wrap            = %s', 'g:SubWindow_Wrap'],
  \ ['let g:qfixmemo_submenu_calendar_wincmd = %s', 'g:SubWindow_CalendarWinCmd'],
  \ ['let g:qfixmemo_submenu_single_mode     = %s', 'g:SubWindow_SingleMode'],
  \ ['let g:qfixmemo_calendar_count = %s', 'g:QFixHowm_CalendarCount'],
  \ ['let g:qfixmemo_random_columns = %s', 'g:QFixHowm_RandomWalkColumns'],
  \ ['let g:qfixmemo_random_exclude = %s', 'g:QFixHowm_RandomWalkExclude'],
  \ ['let g:qfixmemo_random_file    = %s', 'g:QFixHowm_RandomWalkFile',],
  \ ['let g:qfixmemo_random_time    = %s*24*60*60', 'g:QFixHowm_RandomWalkUpdate'],
  \ ['let g:qfixmemo_keyword_mode = %s', 'g:QFixHowm_Wiki'],
  \ ['let g:qfixmemo_keyword_dir  = %s', 'g:QFixHowm_WikiDir'],
  \ ['let g:qfixmemo_keyword_file = %s', 'g:QFixHowm_keywordfile'],
  \ ]

function! QFixHowmSetup()
  " オプションコンバート
  for opt in s:cnvopt
    if exists(opt[1])
      exe printf(opt[0], opt[1])
    endif
  endfor

  " タイトル検索の正規表現作成
  call QFixMemoTitleRegxp()

  " ファイルタイプに QFixHowm_FileType以外を使用する
  if exists('g:QFixHowm_HowmMode') && g:QFixHowm_HowmMode == 0
    if exists('g:QFixHowm_UserFileExt')
      let g:qfixmemo_ext = g:QFixHowm_UserFileExt
    endif
    if exists('g:QFixHowm_UserFileType')
      let g:qfixmemo_filetype = g:QFixHowm_UserFileType
    endif
  endif

  " テンプレート
  if exists('g:QFixHowm_Template_'.g:qfixmemo_ext)
    exe 'let qfixmemo_template_'.g:qfixmemo_ext.' = g:QFixHowm_Template_'.g:qfixmemo_ext
  endif
  if exists('g:QFixHowm_Cmd_NewEntry_'.g:qfixmemo_ext)
    exe 'let qfixmemo_template_keycmd_'.g:qfixmemo_ext.' = g:QFixHowm_Cmd_NewEntry_'.g:qfixmemo_ext
  endif

  " カウント指定コマンド
  for i in range(1, 9)
    if exists('g:QFixHowm_QuickMemoFile'.i)
      exe printf('let g:qfixmemo_quickmemo%d=g:QFixHowm_QuickMemoFile%d', i, i)
    endif
    if exists('g:SubWindow_Title'.i)
      exe printf('let g:qfixmemo_submenu_title%d=g:SubWindow_Title%d', i, i)
    endif
    if exists('g:SubWindow_Direction'.i)
      exe printf('let g:qfixmemo_submenu_direction%d=g:SubWindow_Direction%d', i, i)
    endif
    if exists('g:SubWindow_Size'.i)
      exe printf('let g:qfixmemo_submenu_size%d=g:SubWindow_Size%d', i, i)
    endif
    if exists('g:SubWindow_Wrap'.i)
      exe printf('let g:qfixmemo_submenu_wrap%d=g:SubWindow_Wrap%d', i, i)
    endif
    if exists('g:SubWindow_CalendarWinCmd'.i)
      exe printf('let g:qfixmemo_submenu_calendar_wincmd%d=g:SubWindow_CalendarWinCmd%d', i, i)
    endif
    if exists('g:QFixHowm_UserSwActionLock'.i)
      exe printf('let g:qfixmemo_switch_action%d=g:QFixHowm_UserSwActionLock%d', i, i)
    endif
  endfor
endfunction

""""""""""""""""""""""""""""""
" global keymap
""""""""""""""""""""""""""""""
if exists('g:mapleader')
  let s:mapleader = g:mapleader
endif
let g:mapleader = g:qfixmemo_mapleader

if g:QFixHowm_RecentMode == 2
  silent! nnoremap <silent> <Leader>L :<C-u>call qfixmemo#ListRecent()<CR>
  silent! nnoremap <silent> <Leader>l :<C-u>call qfixmemo#ListRecentTimeStamp()<CR>

  function! QFixMemoMenubarPost(menu, leader)
    silent! exe 'aunmenu Memo(&M).ListRecent(&L)'
    silent! exe 'aunmenu Memo(&M).ListRecent(Stamp)(&2)'
    let menucmd = 'amenu <silent> 41.333 '.a:menu.'.%s<Tab>'.a:leader.'%s :call feedkeys("'.a:leader.'%s","t")<CR>'
    call s:addMenu(menucmd, 'ListRecent(Stamp)(&l)', 'l')
    call s:addMenu(menucmd, 'ListRecent(&2)'       , 'L')
  endfunction
  function! s:addMenu(menu, acc, cmd)
    exe printf(a:menu, a:acc, a:cmd, a:cmd)
  endfunction
endif

if exists('s:mapleader')
  let g:mapleader = s:mapleader
else
  unlet g:mapleader
endif

""""""""""""""""""""""""""""""
" misc
""""""""""""""""""""""""""""""
" <CR>アクション
function! QFixMemoUserModeCR(...)
  call howm_schedule#Init()
  call QFixHowmUserModeCR()
endfunction

" メニュー画面のcome-fromリンクキーワードを返す
" メニューファイルディレクトリ
if !exists('g:QFixHowm_MenuDir')
  let g:QFixHowm_MenuDir = ''
endif
" メニューファイル名
if !exists('g:QFixHowm_Menufile') || g:QFixHowm_Menufile == ''
  let g:QFixHowm_Menufile = 'Menu-00-00-000000.'.s:howmsuffix
endif
" come-fromリンク
if !exists('g:howm_clink_pattern')
  let g:howm_clink_pattern = '<<<'
endif
function! QFixMemoRebuildKeyword(dir, fenc)
  let saved_sq = getloclist(0)
  let file = g:howm_dir
  let file = g:QFixHowm_MenuDir == '' ? g:howm_dir : g:QFixHowm_MenuDir
  let file = expand(file) . '/' . g:QFixHowm_Menufile
  silent! exe 'lvimgrep /\('.g:howm_clink_pattern.'\|'.'\[\[[^\]]\+\]\]'.'\)/j '. escape(file, ' ')
  let qflist = getloclist(0)
  call setloclist(0, saved_sq)
  return qflist
endfunction

" ヘルプ
function! QFixHowmHelp()
  call qfixmemo#Init()
  silent! exec 'split '
  let file = escape(expand(g:qfixmemo_dir), ' ')
  let file .= '/' . 'QFixMemoHelp'
  silent! exec 'edit ' . file
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  call myhowm_msg#HelpInit()
  call setline(1, g:QFixHowmHelpList)
  call cursor(1, 1)
  call qfixmemo#Syntax()
  setlocal nomodifiable
  nnoremap <silent> <buffer> <CR> :call QFixMemoUserModeCR()<CR>
endfunction

" howm-calendar.vim
function! QFixHowmCreateNewFile(...)
  if a:0
    let hfile = a:1
  else
    let hfile = g:qfixmemo_diary
  endif
  call qfixmemo#Edit(hfile)
endfunction

" フォールディングレベル計算
" 折りたたみに ワイルドカードチャプターを使用する
if !exists('g:QFixHowm_WildCardChapter')
  let g:QFixHowm_WildCardChapter = 0
endif
function! QFixMemoSetFolding()
  call howm_schedule#Init()
  if exists('*QFixHowmSetFolding')
    call QFixHowmSetFolding()
    return
  endif
  setlocal nofoldenable
  setlocal foldmethod=expr
  if g:QFixHowm_WildCardChapter
    setlocal foldexpr=QFixHowmFoldingLevelWCC(v:lnum)
  elseif exists('*QFixHowmFoldingLevel')
    setlocal foldexpr=QFixHowmFoldingLevel(v:lnum)
  else
    setlocal foldexpr=getline(v:lnum)=~g:QFixHowm_FoldingPattern?'>1':'1'
  endif
endfunction

