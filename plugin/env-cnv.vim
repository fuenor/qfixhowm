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
" コンバートを切っても基本的なコマンドや動作はほぼ同一に扱えます。
" 予定・TODOについてはコンバートを切ってもQFixHowmのオプションがそのまま適用さ
" れます。
" doc/howm_schedule.jax
"
" ・ドキュメントについては以下を参照してください。
" doc/qfixmemo.jax
" (Vimで閲覧するとヘルプとしてハイライトされます)
" http://github.com/fuenor/qfixmemo/blob/master/doc/qfixmemo.jax
"
" ・QFixHowm Ver.3の実装概要については以下を参照して下さい
" https://sites.google.com/site/fudist/Home/qfixdev/ver3
"
" CAUTION: ファイルの読み込み順がファイル名順である事に依存しています。
"          (env-cnv.vimの初期化がqfixmemo.vimより先に行われると仮定)
"-----------------------------------------------------------------------------

""""""""""""""""""""""""""""""
" イベント処理
""""""""""""""""""""""""""""""
" howm_schedule.vimをautoloadで読み込む
if !exists('g:QFixHowm_Autoload')
  let g:QFixHowm_Autoload = 1
endif
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

" VimEnter
function! QFixMemoVimEnter()
  call QFixHowmSetup()
  if g:QFixHowm_Autoload == 0
    call howm_schedule#Init()
  endif
endfunction

" 初期化
function! QFixMemoInit(init)
  call QFixHowmSetup()
  call howm_schedule#Init()
  if a:init
    return
  endif
endfunction

""""""""""""""""""""""""""""""
" オプションコンバート
""""""""""""""""""""""""""""""
let s:howmsuffix         = 'howm'
" 常にqfixmemoファイルとして扱うファイルの正規表現
let g:qfixmemo_isqfixmemo_regxp = '\c\.'.s:howmsuffix.'$'
if !exists('howm_dir')
  let howm_dir           = '~/howm'
endif
if !exists('howm_filename')
  let howm_filename      = '%Y/%m/%Y-%m-%d-%H%M%S.'.s:howmsuffix
endif
if !exists('QFixHowm_FileExt')
  let g:QFixHowm_FileExt = fnamemodify(g:howm_filename,':e')
endif
if !exists('howm_fileencoding')
  let howm_fileencoding  = &enc
endif
if !exists('howm_fileformat')
  let howm_fileformat    = &ff
endif
" ファイル読込の際に、ファイルエンコーディングを強制する
if !exists('g:QFixHowm_ForceEncoding')
  let g:QFixHowm_ForceEncoding = 1
endif
" howmファイルタイプ
if !exists('QFixHowm_FileType')
  let QFixHowm_FileType = 'howm_memo'
endif

" キーマップリーダー
if !exists('g:QFixHowm_Key')
  let g:QFixHowm_Key = 'g'
endif
if !exists('g:QFixHowm_KeyB')
  let g:QFixHowm_KeyB = ','
endif
let g:qfixmemo_mapleader = g:QFixHowm_Key . g:QFixHowm_KeyB

" タイトル行識別子
if !exists('g:QFixHowm_Title')
  let g:QFixHowm_Title = '='
endif
" オートタイトル文字数
if !exists('g:QFixHowm_Replace_Title_Len')
  let g:QFixHowm_Replace_Title_Len = 64
endif
" タイムスタンプ
if !exists('g:QFixHowm_DatePattern')
  let g:QFixHowm_DatePattern = '%Y-%m-%d'
endif
let g:qfixmemo_timeformat = '['. g:QFixHowm_DatePattern . ' %H:%M]'
" howmテンプレート
if !exists('g:QFixHowm_Template')
  let g:QFixHowm_Template = [
    \ "%TITLE% %TAG%",
    \ "%DATE%",
    \ ""
  \]
endif
" howmテンプレート(カーソル移動)
if !exists('g:QFixHowm_Cmd_NewEntry')
  let g:QFixHowm_Cmd_NewEntry = "$a"
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
" デフォルトタグ
if !exists('g:QFixHowm_DefaultTag')
  let g:QFixHowm_DefaultTag = ''
endif

" クイックメモファイル名
if !exists('g:QFixHowm_QuickMemoFile')
  let g:QFixHowm_QuickMemoFile = 'Qmem-00-0000-00-00-000000.'.g:QFixHowm_FileExt
endif
let g:qfixmemo_quickmemo = g:QFixHowm_QuickMemoFile
" 日記メモファイル名
if !exists('g:QFixHowm_DiaryFile')
  let g:QFixHowm_DiaryFile = fnamemodify(g:howm_filename, ':h').'/%Y-%m-%d-000000.'.g:QFixHowm_FileExt
endif
" ペアリンクされたhowmファイルの保存場所
if !exists('g:QFixHowm_PairLinkDir')
  let g:QFixHowm_PairLinkDir = 'pairlink'
endif
" ファイル名をタイトル行から生成したファイル名へ変更する場合の文字数
if !exists('g:QFixHowm_FilenameLen')
  let g:QFixHowm_FilenameLen = len(fnamemodify(strftime(g:howm_filename), ':t:r'))
endif

" 折りたたみを有効にする。
if !exists('g:QFixHowm_Folding')
  let g:QFixHowm_Folding = 1
endif
" スプリットで開く
if !exists('g:QFixHowm_SplitMode')
  let g:QFixHowm_SplitMode = 0
endif

" 検索時にカーソル位置の単語を拾う
if !exists('g:QFixHowm_DefaultSearchWord')
  let g:QFixHowm_DefaultSearchWord = 1
endif
" タイトルリスト(,a)にキャッシュ表示を割り当て
if !exists('g:QFixHowm_TitleListCache')
 let g:QFixHowm_TitleListCache = 1
endif
" 最近更新したファイル検索日数
if !exists('g:QFixHowm_RecentDays')
  let g:QFixHowm_RecentDays = 5
endif
let g:qfixmemo_recentdays = g:QFixHowm_RecentDays

" ランダム表示数
if !exists('g:QFixHowm_RandomWalkColumns')
  let g:QFixHowm_RandomWalkColumns = 10
endif
" ランダム表示しない正規表現
if !exists('g:QFixHowm_RandomWalkExclude')
  let g:QFixHowm_RandomWalkExclude = ''
endif
" ランダム表示保存ファイル
if !exists('g:QFixHowm_RandomWalkFile')
  let g:QFixHowm_RandomWalkFile = '~/.howm-random'
endif
" ランダム表示保存ファイル更新間隔
if !exists('g:QFixHowm_RandomWalkUpdate')
  let g:QFixHowm_RandomWalkUpdate = 10
endif
let g:qfixmemo_random_columns = g:QFixHowm_RandomWalkColumns

" キーワードリンク
if !exists('g:QFixHowm_keywordfile')
  let g:QFixHowm_keywordfile = '~/.howm-keys'
endif
" キーワードをgrepするのではなく対応するファイルを開く
if !exists('g:QFixHowm_Wiki')
  let g:QFixHowm_Wiki = 0
endif
" キーワードに対応するファイルで開く場合のディレクトリ
if !exists('g:QFixHowm_WikiDir')
  let g:QFixHowm_WikiDir = 'wikidir'
endif

" rel://
if !exists('g:QFixHowm_RelPath')
  let g:QFixHowm_RelPath = g:howm_dir
endif
" 基準ディレクトリ
if !exists('g:QFixMRU_RootDir') && exists('g:QFixHowm_RootDir')
  let g:QFixMRU_RootDir = g:QFixHowm_RootDir
endif
if !exists('g:qfixmemo_root_dir') && exists('g:QFixHowm_RootDir')
  let g:qfixmemo_root_dir = g:QFixHowm_RootDir
endif

" サブウィンドウのタイトル
if !exists('g:SubWindow_Title')
  let g:SubWindow_Title = '__submenu__'
endif
" サブウィンドウのサイズ
if !exists('g:SubWindow_Size')
  let g:SubWindow_Size = 30
endif
" サブウィンドウを出す方向
if !exists('g:SubWindow_Direction')
  let g:SubWindow_Direction = "topleft vertical"
endif
" サブウィンドウのwrap
if !exists('g:SubWindow_Wrap')
  let g:SubWindow_Wrap = 1
endif
" サブメニューのシングルモード
if !exists('g:SubWindow_SingleMode')
  let g:SubWindow_SingleMode = 1
endif

" 起動時コマンド
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

" メニューバーへ登録
if exists('g:QFixHowm_MenuBar')
  let g:qfixmemo_menubar = g:QFixHowm_MenuBar
endif
" リストからファイルを開いたらファイルを閉じる
if !exists('g:QFixHowm_ListCloseOnJump')
  let g:QFixHowm_ListCloseOnJump = 0
endif
let g:qfixlist_close_on_jump = g:QFixHowm_ListCloseOnJump

" 日付のデフォルトアクションロックを無効化
let g:QFixHowm_DateActionLockDefault = 0

function! QFixHowmSetup()
  " ファイル/ディレクトリ設定
  let g:howm_dir = substitute(g:howm_dir, '[/\\]$', '', '')
  let g:qfixmemo_dir           = g:howm_dir
  let g:qfixmemo_filename      = fnamemodify(g:howm_filename, ':r')
  let g:qfixmemo_fileencoding  = g:howm_fileencoding
  let g:qfixmemo_fileformat    = g:howm_fileformat
  let g:qfixmemo_ext           = g:QFixHowm_FileExt
  let g:qfixmemo_filetype      = g:QFixHowm_FileType
  let g:qfixmemo_forceencoding = g:QFixHowm_ForceEncoding
  let g:qfixmemo_title         = g:QFixHowm_Title
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

  let g:qfixmemo_diary         = fnamemodify(g:QFixHowm_DiaryFile, ':r')
  let g:qfixmemo_quickmemo     = g:QFixHowm_QuickMemoFile
  let g:qfixmemo_pairfile_dir  = g:QFixHowm_PairLinkDir

  " サブウィンドウ(デフォルト)
  let g:qfixmemo_submenu_title       = g:SubWindow_Title
  let g:qfixmemo_submenu_direction   = g:SubWindow_Direction
  let g:qfixmemo_submenu_size        = g:SubWindow_Size
  let g:qfixmemo_submenu_wrap        = g:SubWindow_Wrap
  let g:qfixmemo_submenu_single_mode = g:SubWindow_SingleMode

  " カウント指定コマンド
  for i in range(1, 9)
    if exists('g:QFixHowm_QuickMemoFile'.i)
      exe printf('let g:qfixmemo_quickmemo%d=g:QFixHowm_QuickMemoFile%d', i, i)
    endif
    if exists('g:SubWindow_Title'.i)
      exe printf('let g:qfixmemo_submenu_title%d=g:SubWindow_Title%d', i, i)
    endif
    if exists('g:SubWindow_Size'.i)
      exe printf('let g:qfixmemo_submenu_size%d=g:SubWindow_Size%d', i, i)
    endif
    if exists('g:SubWindow_Wrap'.i)
      exe printf('let g:qfixmemo_submenu_wrap%d=g:SubWindow_Wrap%d', i, i)
    endif
    if exists('g:SubWindow_Direction'.i)
      exe printf('let g:qfixmemo_submenu_direction%d=g:SubWindow_Direction%d', i, i)
    endif
  endfor

  " テンプレート
  let g:qfixmemo_timeformat = '['. g:QFixHowm_DatePattern . ' %H:%M]'
  call qfixmemo#SetTimeFormatRegxp(g:qfixmemo_timeformat)
  let g:qfixmemo_template        = g:QFixHowm_Template
  let g:qfixmemo_template_keycmd = g:QFixHowm_Cmd_NewEntry
  let g:qfixmemo_template_tag    = g:QFixHowm_DefaultTag
  silent! exe 'let qfixmemo_template_'.g:qfixmemo_ext.' = deepcopy(g:QFixHowm_Template_'.g:qfixmemo_ext . ')'
  silent! exe 'let qfixmemo_template_keycmd_'.g:qfixmemo_ext.' = g:QFixHowm_Cmd_NewEntry_'.g:qfixmemo_ext

  " misc
  let g:qfixmemo_title_length   = g:QFixHowm_Replace_Title_Len
  let g:qfixmemo_folding        = g:QFixHowm_Folding
  let g:qfixmemo_splitmode      = g:QFixHowm_SplitMode
  let g:qfixmemo_grep_cword     = g:QFixHowm_DefaultSearchWord
  let g:qfixmemo_rename_length  = g:QFixHowm_FilenameLen
  let g:qfixmemo_use_list_cache = g:QFixHowm_TitleListCache

  " ランダム
  let g:qfixmemo_random_file    = g:QFixHowm_RandomWalkFile
  let g:qfixmemo_random_time    = g:QFixHowm_RandomWalkUpdate*24*60*60
  let g:qfixmemo_random_exclude = g:QFixHowm_RandomWalkExclude

  " キーワード
  let g:qfixmemo_keyword_mode = g:QFixHowm_Wiki
  let g:qfixmemo_keyword_dir  = g:QFixHowm_WikiDir
  let g:qfixmemo_keyword_file = g:QFixHowm_keywordfile
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
if !exists('g:QFixHowm_Menufile')
  let g:QFixHowm_Menufile = 'Menu-00-00-000000.'.s:howmsuffix
endif
" come-fromリンク
if !exists('g:howm_clink_pattern')
  let g:howm_clink_pattern = '<<<'
endif
function! QFixMemoRebuildKeyword(dir, fenc)
  silent! cexpr ''
  let file = g:howm_dir
  let file = g:QFixHowm_MenuDir == '' ? g:howm_dir : g:QFixHowm_MenuDir
  let file = expand(file) . '/' . g:QFixHowm_Menufile
  silent! exec 'vimgrep /\('.g:howm_clink_pattern.'\|'.'\[\[[^\]]\+\]\]'.'\)/j '. escape(file, ' ')
  let qflist = getqflist()
  silent! cexpr ''
  return qflist
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
  call cursor(1,1)
  call qfixmemo#Syntax()
  setlocal nomodifiable
  nnoremap <silent> <buffer> <CR> :call QFixMemoUserModeCR()<CR>
endfunction

" calendar.vim
function! QFixHowmCreateNewFile(...)
  if a:0
    let hfile = a:1
  else
    let hfile = g:qfixmemo_diary
  endif
  call qfixmemo#Edit(hfile)
endfunction

