"================================================================================
"    Description: 日本語Grepヘルパー
"         Author: fuenor <fuenor@gmail.com>
"                 http://sites.google.com/site/fudist/Home/grep
"  Last Modified: 2011-10-16 21:29
"================================================================================
let s:Version = 2.83
scriptencoding utf-8

if exists('enable_MyGrep')
  let disable_MyGrep = !enable_MyGrep
endif
if exists('disable_MyGrep') && disable_MyGrep
  finish
endif
if exists("loaded_MyGrep") && !exists('fudist')
  finish
endif
if v:version < 700 || &cp
  finish
endif
let loaded_MyGrep = 1

let s:debug = 0
if exists('g:fudist') && g:fudist
  let s:debug = 1
endif

"メニューへの登録
if !exists('MyGrep_MenuBar')
  let MyGrep_MenuBar = 2
endif

"使用するgrep指定
if !exists('mygrepprg')
  let mygrepprg = 'internal'
  let UseFindstr = has('win32') + has('win64') - has('win95')
  if UseFindstr > 0
    let mygrepprg = 'findstr'
  endif
  if has('unix')
    let mygrepprg = 'grep'
  endif
endif
" 日本語が含まれる場合のgrep指定
let s:MSWindows = has('win95') + has('win16') + has('win32') + has('win64')
if !exists('myjpgrepprg')
  let myjpgrepprg = ''
endif
"使用するgrepのエンコーディング指定
if !exists('g:MyGrep_ShellEncoding')
  let g:MyGrep_ShellEncoding = 'utf-8'
  if s:MSWindows
    let g:MyGrep_ShellEncoding = 'cp932'
  endif
endif
"検索対象外のファイル指定
if !exists('g:MyGrep_ExcludeReg')
  let g:MyGrep_ExcludeReg = '[~#]$\|\.dll$\|\.exe$\|\.lnk$\|\.o$\|\.obj$\|\.pdf$\|\.xls$'
endif

"ダメ文字対策
if !exists('g:MyGrep_Damemoji')
  let g:MyGrep_Damemoji = 2
endif
"「ダメ文字」リスト
let g:MyGrep_DamemojiReplaceDefault = ['[]','[ーソЫⅨ噂浬欺圭構蚕十申曾箪貼能表暴予禄兔喀媾彌拿杤歃濬畚秉綵臀藹觸軆鐔饅鷭偆砡纊犾]', '[ー―‐／＼＋±×ＡァゼソゾタダチボポマミАЪЫЬЭЮЯклмн院閏噂云運雲荏閲榎厭円魁骸浬馨蛙垣柿顎掛笠樫機擬欺犠疑祇義宮弓急救掘啓圭珪型契形鶏芸迎鯨后梗構江洪浩港砿鋼閤降察纂蚕讃賛酸餐施旨枝止宗充十従戎柔汁旬楯殉淳拭深申疹真神秦須酢図厨繊措曾曽楚狙疏捜掃挿掻叩端箪綻耽胆蛋畜竹筑蓄邸甜貼転顛点伝怒倒党冬如納能脳膿農覗倍培媒梅鼻票表評豹廟描府怖扶敷法房暴望某棒冒本翻凡盆諭夕予余与誉輿養慾抑欲蓮麓禄肋録論倭僉兌兔兢竸兩兪几處凩凭咫喙喀咯喊喟啻嘴嘶嘲嘸奸媼媾嫋嫂媽嫣學斈孺宀廖彈彌彎弯彑彖悳忿怡恠戞拏拿拆擔拈拜掉掟掵捫曄杣杤枉杰枩杼桀桍栲桎檗歇歃歉歐歙歔毬毫毳毯漾濕濬濔濘濱濮炮烟烋烝瓠畆畚畩畤畧畫痣痞痾痿磧禺秉秕秧秬秡窖窩竈窰紂綣綵緇綽綫總縵縹繃縷隋膽臀臂膺臉臍艝艚艟艤蕁藜藹蘊蘓蘋藾蛔蛞蛩蛬襦觴觸訃訖訐訌諚諫諳諧蹇躰軆躱躾軅軈轆轎轗轜錙鐚鐔鐓鐃鐇鐐閔閖閘閙顱饉饅饐饋饑饒驅驂驀驃鵝鷦鷭鷯鷽鸚鸛黠黥黨黯纊倞偆偰偂傔垬埈埇犾劯砡硎硤硺葈蒴蕓蕙]', '[ーソЫⅨ噂浬欺圭構蚕十申曾箪貼能表暴予禄兔喀媾彌拿杤歃濬畚秉綵臀藹觸軆鐔饅鷭偆砡纊犾－ポл榎掛弓芸鋼旨楯酢掃竹倒培怖翻慾處嘶斈忿掟桍毫烟痞窩縹艚蛞諫轎閖驂黥埈蒴僴礰]']

if !exists('g:MyGrep_DamemojiReplaceReg')
  let g:MyGrep_DamemojiReplaceReg = '(..)'
endif
if !exists('g:MyGrep_DamemojiReplace')
  let g:MyGrep_DamemojiReplace = '[]'
endif
if !exists('g:MyGrep_Encoding')
  let g:MyGrep_Encoding = ''
endif
"--includeオプションを使用する
if !exists('g:MyGrep_IncludeOpt')
  let g:MyGrep_IncludeOpt = 0
endif

if !exists('g:QFix_Height')
  let g:QFix_Height = 10
endif
if !exists('g:QFix_HeightMax')
  let g:QFix_HeightMax = 0
endif
if !exists('g:QFix_HeightDefault')
  let g:QFix_HeightDefault = QFix_Height
endif
if !exists('g:QFix_HeightFixMode')
  let g:QFix_HeightFixMode = 0
endif
if !exists('g:QFix_CopenCmd')
  let g:QFix_CopenCmd = ''
endif

"検索時にカーソル位置の単語を拾う
if !exists('g:MyGrep_DefaultSearchWord')
  let g:MyGrep_DefaultSearchWord = 1
endif

"検索ディレクトリはカレントディレクトリを基点にする
if !exists('g:MyGrep_CurrentDirMode')
  let g:MyGrep_CurrentDirMode = 1
endif

"コマンドラインコマンドを使用する
if !exists('g:MyGrep_UseCommand')
  let g:MyGrep_UseCommand = 1
endif

"デフォルトのファイルパターン
if !exists('g:MyGrep_FilePattern')
  let g:MyGrep_FilePattern = '*'
endif
"デフォルトのerrorformat
if !exists('g:MyGrep_errorformat')
"  let g:MyGrep_errorformat = '%f|%\\s%#%l|%m'
endif

"QFixHowm用の行儀の悪いオプション
let g:MyGrep_FileListWipeTime = 0
let g:MyGrep_qflist = []

""""""""""""""""""""""""""""""
"ユーザ呼び出し用コマンド
""""""""""""""""""""""""""""""
if !exists('g:MyGrep_SearchPathMode')
  let g:MyGrep_SearchPathMode = 1
endif

if g:MyGrep_UseCommand == 1
  command! -nargs=? -bang BGrep        call BGrep(<q-args>, <bang>0, 0)
  command! -nargs=? -bang Vimgrep      call UGrep('vimgrep', <q-args>, g:MyGrep_SearchPathMode, 0)
  command! -nargs=? -bang VGrep        call UGrep('vimgrep', <q-args>, g:MyGrep_SearchPathMode, 0)

  command! -nargs=? -bang BGrepadd     call BGrep(<q-args>, <bang>0, 1)
  command! -nargs=? -bang VGrepadd     call UGrep('vimgrep', <q-args>, g:MyGrep_SearchPathMode, 1)
  command! -nargs=? -bang Vimgrepadd   call UGrep('vimgrep', <q-args>, g:MyGrep_SearchPathMode, 1)

  command! -nargs=* -bang Grep        call CGrep( 0, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang FGrep       call CGrep( 1, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang EGrep       call CGrep( 0, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang RGrep       call RCGrep(0, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang RFGrep      call RCGrep(1, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang REGrep      call RCGrep(0, g:MyGrep_SearchPathMode, 0, <q-args>)

  command! -nargs=* -bang Grepadd     call CGrep( 0, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang FGrepadd    call CGrep( 1, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang EGrepadd    call CGrep( 0, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang RGrepadd    call RCGrep(0, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang RFGrepadd   call RCGrep(1, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang REGrepadd   call RCGrep(0, g:MyGrep_SearchPathMode, 1, <q-args>)

  command! -nargs=* -bang QFGrep      call CGrep( 0, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang QFGrepadd   call CGrep( 0, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang QFFGrep     call CGrep( 1, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang QFFGrepadd  call CGrep( 1, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang QFRGrep     call RCGrep(0, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang QFRGrepadd  call RCGrep(0, g:MyGrep_SearchPathMode, 1, <q-args>)
  command! -nargs=* -bang QFRFGrep    call RCGrep(1, g:MyGrep_SearchPathMode, 0, <q-args>)
  command! -nargs=* -bang QFRFGrepadd call RCGrep(1, g:MyGrep_SearchPathMode, 1, <q-args>)
endif

command! -nargs=? -bang QFBGrep call BGrep(<q-args>, <bang>0, 0)
command! -nargs=? -bang QFVGrep call VGrep(<q-args>, g:MyGrep_SearchPathMode, 0)

command! -nargs=? -bang QFBGrepadd call BGrep(<q-args>, <bang>0, 1)
command! -nargs=? -bang QFVGrepadd call VGrep(<q-args>, g:MyGrep_SearchPathMode, 1)

if !exists('g:MyGrep_Key')
  let g:MyGrep_Key = 'g'
  if exists('g:QFixHowm_Key')
    let g:MyGrep_Key = g:QFixHowm_Key
  endif
endif
if !exists('g:MyGrep_KeyB')
  let g:MyGrep_KeyB = ','
  if exists('g:QFixHowm_KeyB')
    let g:MyGrep_KeyB = g:QFixHowm_KeyB
  endif
endif
let s:MyGrep_Key = g:MyGrep_Key . g:MyGrep_KeyB

if MyGrep_MenuBar
  let s:MyGrep_Key = escape(s:MyGrep_Key, '\\')
  let s:menu = '&Tools.QFixGrep(&G)'
  if MyGrep_MenuBar == 2
    let s:menu = 'Grep(&G)'
  elseif MyGrep_MenuBar == 3
    let s:menu = 'QFixApp(&Q).QFixGrep(&G)'
  endif
  exec 'amenu <silent> 41.331 '.s:menu.'.Grep(&G)<Tab>'.s:MyGrep_Key.'e  :QFGrep!<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.FGrep(&F)<Tab>'.s:MyGrep_Key.'f  :QFFGrep!<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.RGrep(&R)<Tab>'.s:MyGrep_Key.'re  :QFRGrep!<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.RFGrep(&R)<Tab>'.s:MyGrep_Key.'rf  :QFRFGrep!<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.GrepBuffer(&B)<TAB>'.s:MyGrep_Key.'b :BGrep<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.Vimgrep(&V)<Tab>'.s:MyGrep_Key.'v  :QFVGrep!<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.-sep1-			<Nop>'

  exec 'amenu <silent> 41.331 '.s:menu.'.Grepadd(&G)<Tab>'.s:MyGrep_Key.'E  :QFGrepadd!<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.FGrepadd(&F)<Tab>'.s:MyGrep_Key.'F  :QFFGrepadd!<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.RGrepadd(&R)<Tab>'.s:MyGrep_Key.'rE  :QFRGrepadd!<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.RFGrepadd(&R)<Tab>'.s:MyGrep_Key.'rF  :QFRFGrepadd!<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.GrepBufferadd(&B)<TAB>'.s:MyGrep_Key.'B  :BGrepadd<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.Vimgrepadd(&V)<Tab>'.s:MyGrep_Key.'V  :QFVGrepadd!<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.-sep2-			<Nop>'
  exec 'amenu <silent> 41.331 '.s:menu.'.CurrentDirMode(&M)<Tab>'.s:MyGrep_Key.'rM  :ToggleGrepCurrentDirMode<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.RecursiveMode(&D)<Tab>'.s:MyGrep_Key.'rD  :ToggleGrepRecursiveMode<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.SetFileEncoding(&S)<Tab>'.s:MyGrep_Key.'rS  :call s:SetFileEncoding()<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.-sep3-			<Nop>'
  exec 'amenu <silent> 41.331 '.s:menu.'.Load\ Quickfix(&L)<Tab>'.s:MyGrep_Key.'k  :MyGrepReadResult<CR>\|:QFixCopen<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.Load\ Quickfix[Local]\ (&O)<Tab>O :MyGrepReadResult<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.Save\ Quickfix[Local]\ (&A)<Tab>A :MyGrepWriteResult<CR>'
  exec 'amenu <silent> 41.331 '.s:menu.'.-sep4-			<Nop>'
  exec 'amenu <silent> 41.331 '.s:menu.'.Help(&H)<Tab>'.s:MyGrep_Key.'H  :<C-u>call QFixGrepHelp_()<CR>'

  if MyGrep_MenuBar == 1
    exec 'amenu <silent> 40.333 &Tools.-sepend-			<Nop>'
  endif
  let s:MyGrep_Key = g:MyGrep_Key . g:MyGrep_KeyB
endif

exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'b  :call BGrep("", 0, 0)<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'b  :call BGrep("", -1, 0)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'e  :QFGrep!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'e  :call Grep("", -1, "Grep", 0)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'f  :QFFGrep!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'f  :call FGrep("", -1, 0)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'re  :QFRGrep!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'re  :call RGrep("", -1, "RGrep", 0)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rf  :QFRFGrep!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'rf  :call RFGrep("", -1, 0)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'v  :QFVGrep!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'v  :call VGrep("", -1, 0)<CR>'

exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rM  :ToggleGrepCurrentDirMode<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rD  :ToggleGrepRecursiveMode<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rS  :call <SID>SetFileEncoding()<CR>'

exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'B  :BGrepadd<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'E  :QFGrepadd!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'E  :call Grep("", -1, "Grep", 1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'F  :QFFGrepadd!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'F  :call FGrep("", -1, 1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rE  :QFRGrepadd!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'rE  :call RGrep("", -1, "RGrep", 1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'rF  :QFRFGrepadd!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'rF  :call RFGrep("", -1, 1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'RE  :QFRGrepadd!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'RE  :call RGrep("", -1, "RGrep", 1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'RF  :QFRFGrepadd!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'RF  :call RFGrep("", -1, 1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'V  :QFVGrepadd!<CR>'
exec 'silent! vnoremap <unique> <silent> '.s:MyGrep_Key.'V  :call VGrep("", -1, 1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'k :MyGrepReadResult<CR>\|:QFixCopen<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'H :call QFixGrepHelp()<CR>'

exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'. :<C-u>call QFixGrepLocationMode()<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'0 :<C-u>call QFixGrepLocationMode(0)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'1 :<C-u>call QFixGrepLocationMode(1)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'2 :<C-u>call QFixGrepLocationMode(2)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'3 :<C-u>call QFixGrepLocationMode(3)<CR>'
exec 'silent! nnoremap <unique> <silent> '.s:MyGrep_Key.'4 :<C-u>call QFixGrepLocationMode(4)<CR>'

autocmd BufWinEnter quickfix exec 'silent! nnoremap <unique> <buffer> <silent> '.s:MyGrep_Key.'w :MyGrepWriteResult<CR>'

""""""""""""""""""""""""""""""
"ユーザ呼び出し用コマンド本体
""""""""""""""""""""""""""""""
command! -bang ToggleDamemoji let MyGrep_Damemoji = <bang>0?2:!MyGrep_Damemoji|echo 'QFixGrep : Damemoji = '.(MyGrep_Damemoji?'ON':'OFF')
command! -bang ToggleGrepCurrentDirMode let MyGrep_CurrentDirMode = <bang>0?1:!MyGrep_CurrentDirMode|echo 'QFixGrep : CurrentDirMode = '.(MyGrep_CurrentDirMode?'ON':'OFF')
command! -bang ToggleGrepRecursiveMode let MyGrep_RecursiveMode = <bang>0?1:!MyGrep_RecursiveMode|echo 'QFixGrep : RecursiveMode = '.(MyGrep_RecursiveMode?'ON':'OFF')

""""""""""""""""""""""""""""""
function! VGrep(word, mode, addflag)
  let addflag = a:addflag
  let title = 'Vimgrep'
  if addflag
    let title = 'Vimgrepadd'
  endif
  let g:MyGrep_UseVimgrep = 1
  call Grep(a:word, a:mode, title, addflag)
endfunction

""""""""""""""""""""""""""""""
function! RFGrep(word, mode, addflag)
  let g:MyGrep_Recursive = 1
  return FGrep(a:word, a:mode, a:addflag)
endfunction

""""""""""""""""""""""""""""""
function! FGrep(word, mode, addflag)
  let addflag = a:addflag
  let title = 'FGrep'
  if addflag
    let title = 'FGrepadd'
  endif
  if g:MyGrep_Recursive == 1
    let title = 'R'.title
  endif
  let pattern = a:word
  let g:MyGrep_Regexp = 0
  call Grep(pattern, a:mode, title, addflag)
endfunction

""""""""""""""""""""""""""""""
function! UGrep(cmd, args, mode, addflag)
  if a:args == ''
    if a:cmd == 'grep'
      let title = a:addflag? 'Grepadd' : 'Grep'
      if g:MyGrep_Recursive == 1
        let title = 'R'.title
      endif
      return Grep('', a:mode, title, a:addflag)
    elseif a:cmd == 'grep -F'
      return FGrep('', a:mode, a:addflag)
    elseif a:cmd =~ 'vimgrep'
      return VGrep('', a:mode, a:addflag)
    endif
    return Grep('', a:mode, title, a:addflag)
  endif
  call s:save()
  let addflag = a:addflag
  let g:QFix_SearchPath = getcwd()
  if a:mode
    let disppath = expand('%:p:h')
  else
    let disppath = g:QFix_SearchPath
  endif
  let g:QFix_SearchPath = disppath
  let bufnr = bufnr('%')
  let save_cursor = getpos('.')
  if addflag == 0
    let ccmd = g:QFix_UseLocationList ? 'lexpr ""' : 'cexpr ""'
    exec ccmd
  endif
  call QFixPclose()
  call QFixCclose()
  if g:QFix_SearchPath != ''
  " silent! exec 'lchdir ' . escape(g:QFix_SearchPath, ' ')
  endif
  if addflag
    let g:QFix_SearchPath = disppath
  endif

  let cmd = a:cmd
  if cmd =~ 'vimgrep' && g:QFix_UseLocationList
    let cmd = 'l'.cmd
  endif
  let cmd = cmd.' '. a:args
  exec cmd
  let g:QFix_SearchResult = []
  let save_qflist = QFixGetqflist()
  if empty(save_qflist)
    redraw | echo 'QFixGrep : Not found!'
  else
    if g:QFix_HeightFixMode == 1
      let g:QFix_Height = g:QFix_HeightDefault
    endif
    QFixCopen
    call cursor(1, 1)
    redraw | echo ''
  endif
  call s:restore()
endfunction

""""""""""""""""""""""""""""""
function! RGrep(word, mode, title, addflag)
  let g:MyGrep_Recursive = 1
  let title = a:title
  let title = a:addflag ? title.'add' : title
  return Grep(a:word, a:mode, title, a:addflag)
endfunction

""""""""""""""""""""""""""""""
let s:MyGrep_Fenc = ''
function! Grep(word, mode, title, addflag)
  let addflag = a:addflag
  let pattern = a:word
  let extpattern = ''
  let extpat = '\(\s\+\(\*\*\/\)\?\*\.[^.]\+\)\+$'
  if pattern =~ extpat
    let extpattern = matchstr(pattern, extpat)
    let pattern = substitute(pattern, extpat, '', '')
  endif
  if pattern == '' || a:mode == -1
    let pattern = expand("<cword>")
    if g:MyGrep_DefaultSearchWord == 0
      let pattern = ''
    endif
    if a:mode == -1
      exec 'normal! vgvy'
      let pattern = @0
    endif
    let pattern = input(a:title." : ", pattern)
  endif
  if pattern == ''
    let g:MyGrep_Regexp = 1
    let g:MyGrep_Ignorecase = 1
    let g:MyGrep_Recursive  = 0
    let g:MyGrep_UseVimgrep = 0
    return
  endif
  let filepattern = '*'
  if expand('%:e') != ''
    let filepattern = '*.' . expand('%:e')
  endif
  if g:MyGrep_FilePattern != ''
    let filepattern = g:MyGrep_FilePattern
  endif
  if extpattern == ''
    let filepattern = input("filepattern (rcsv: **/*) : ", filepattern)
  else
    let filepattern = extpattern
  endif
  if filepattern == '' | return | endif
  call s:save()
  let @/ = '\V'.pattern
  call histadd('/', @/)
  call histadd('@', pattern)
  if match(pattern, '\C[A-Z]') != -1
    let g:MyGrep_Ignorecase = 0
  endif
  if a:mode == 0
    let searchPath = getcwd()
  else
    let searchPath = expand('%:p:h')
  endif
  if g:MyGrep_CurrentDirMode == 1
    let searchPath = getcwd()
  endif
  let fenc = &fileencoding
  if fenc == ''
    let fenc = &enc
  endif
  if s:MyGrep_Fenc != ''
    let fenc = s:MyGrep_Fenc
  endif
  let prevPath = escape(getcwd(), ' ')
  if a:addflag && g:QFix_SearchPath != ''
    let disppath = g:QFix_SearchPath
  else
    let disppath = searchPath
  endif
  let g:QFix_SearchPath = disppath
  if exists('*QFixSaveHeight')
    call QFixSaveHeight(0)
  endif
  call QFixPclose()
  call QFixCclose()
  call MyGrep(pattern, searchPath, filepattern, fenc, addflag)
  if g:QFix_SearchPath != ''
  " silent! exec 'lchdir ' . escape(g:QFix_SearchPath, ' ')
  endif
  let save_qflist = QFixGetqflist()
  if empty(save_qflist)
    redraw | echo 'QFixGrep : Not found!'
    echo pattern.' | '.fenc.' | '.filepattern.' | '. searchPath
  else
    if g:QFix_HeightFixMode == 1
      let g:QFix_Height = g:QFix_HeightDefault
    endif
    if a:addflag
      let g:QFix_SearchPath = disppath
    endif
    QFixCopen
    call cursor(1, 1)
    redraw | echo ''
  endif
  if g:MyGrep_ErrorMes != ''
    echohl ErrorMsg
    redraw | echo g:MyGrep_ErrorMes
    echohl None
  endif
  " silent! exec 'lchdir ' . prevPath
  call s:restore()
endfunction

function! s:SetFileEncoding()
  let mes = 'QFixGrep : grep fileencoding = '
  let s:MyGrep_Fenc = input(mes, s:MyGrep_Fenc)
endfunction

function! s:restore()
  if !exists('g:MyGrep_UseLocationList') || s:QFix_UseLocationList == g:MyGrep_UseLocationList
    return
  endif
  let g:QFix_Win             = s:QFix_Win
  let g:QFix_SearchPath      = s:QFix_SearchPath
  let g:QFix_UseLocationList = s:QFix_UseLocationList
endfunction

function! s:save()
  let s:QFix_UseLocationList = g:QFix_UseLocationList
  if !exists('g:MyGrep_UseLocationList') || g:QFix_UseLocationList == g:MyGrep_UseLocationList
    return
  endif
  let s:QFix_Win             = g:QFix_Win
  let s:QFix_SearchPath      = g:QFix_SearchPath
  let g:QFix_UseLocationList = g:MyGrep_UseLocationList
endfunction

""""""""""""""""""""""""""""""
"バッファのみgrep
"無名バッファは検索できない。
""""""""""""""""""""""""""""""
function! BGrep(word, mode, addflag)
  let pattern = a:word
  let mes = "Buffers grep : "
  if a:addflag
    let mes = "Buffers grepadd : "
  endif
  if pattern == '' || a:mode == -1
    let pattern = expand("<cword>")
    if g:MyGrep_DefaultSearchWord == 0
      let pattern = ''
    endif
    if a:mode < 0
      let pattern = @0
    endif
    let pattern = input(mes, pattern)
  endif
  if pattern == '' | return | endif
  call s:save()
  if a:addflag && g:QFix_SearchPath != ''
    let disppath = g:QFix_SearchPath
  else
    let disppath = expand('%:p:h')
  endif
  let g:QFix_SearchPath = disppath
  let @/ = pattern
  call histadd('/', '\V' . @/)
  call histadd('@', pattern)
  let bufnr = bufnr('%')
  let save_cursor = getpos('.')
  if a:addflag == 0
    let ccmd = g:QFix_UseLocationList ? 'lexpr ""' : 'cexpr ""'
    silent! exec ccmd
  endif
  call QFixPclose()
  call QFixCclose()
  let vopt = g:QFix_UseLocationList ? 'l' : ''
  silent! exec ':bufdo | try | '.vopt.'vimgrepadd /' . pattern . '/j % | catch | endtry'
  silent! exec 'b'.bufnr
  if a:addflag
    let g:QFix_SearchPath = disppath
  endif
  let g:QFix_SearchResult = []
  let save_qflist = QFixGetqflist()
  if empty(save_qflist)
    redraw | echo 'QFixGrep : Not found!'
  else
    if g:QFix_HeightFixMode == 1
      let g:QFix_Height = g:QFix_HeightDefault
    endif
    QFixCopen
    call cursor(1, 1)
    redraw | echo ''
  endif
  call s:restore()
endfunction

""""""""""""""""""""""""""""""
"grep helper
""""""""""""""""""""""""""""""
if !exists('g:MyGrepcmd')
  let g:MyGrepcmd = '#prg# #defopt# #recopt# #opt# #useropt# #cmdopt# -f #searchWordFile# #searchPath#'
endif
if !exists('g:MyGrepcmd_useropt')
  let g:MyGrepcmd_useropt = ''
endif
if !exists('g:MyGrepcmd_regexp')
  let g:MyGrepcmd_regexp = '-nHIE'
endif
if !exists('g:MyGrepcmd_regexp_ignore')
  let g:MyGrepcmd_regexp_ignore = '-nHIEi'
endif
if !exists('g:MyGrepcmd_fix')
  let g:MyGrepcmd_fix = '-nHIF'
endif
if !exists('g:MyGrepcmd_fix_ignore')
  let g:MyGrepcmd_fix_ignore = '-nHIFi'
endif
"オプション
if !exists('g:MyGrep_StayGrepDir')
  let g:MyGrep_StayGrepDir = 0
endif
if !exists('g:MyGrep_Ignorecase')
  let g:MyGrep_Ignorecase = 1
endif
if !exists('g:MyGrep_Regexp')
  let g:MyGrep_Regexp = 1
endif
if !exists('g:MyGrep_Recursive')
  let g:MyGrep_Recursive = 0
endif
if !exists('g:MyGrep_RecursiveMode')
  let g:MyGrep_RecursiveMode = 0
endif
if !exists('g:MyGrep_RecOpt')
  let g:MyGrep_RecOpt = '-R'
endif

if !exists('g:MyGrep_yagrep_opt')
  let g:MyGrep_yagrep_opt = 0
endif
if !exists('g:QFix_SearchPath')
  let g:QFix_SearchPath = ''
endif
if !exists('g:QFix_UseLocationList')
  let g:QFix_UseLocationList = 0
endif

if !exists('g:MyGrep_UseLocationList')
  " let g:MyGrep_UseLocationList = 0
endif
let g:MyGrep_cmdopt = ''
"一時的にvimgrepを使用したいときに非0。使用後リセットされる。
let g:MyGrep_UseVimgrep = 0
"quickfixに登録しない
let g:MyGrep_Return = 0

""""""""""""""""""""""""""""""
"汎用Grep関数
"vimgrepならfencは無視される。
"addflag : grep検索結果追加
""""""""""""""""""""""""""""""
function! MyGrepadd(pattern, searchPath, filepattern, fenc)
  return MyGrep(a:pattern, a:searchPath, a:filepattern, a:fenc, 1)
endfunction

function! MyGrep(pattern, searchPath, filepattern, fenc, addflag, ...)
  let addflag = a:addflag
  let searchPath = a:searchPath
  let pattern = a:pattern
  let prevPath = escape(getcwd(), ' ')
  let g:MyGrep_ErrorMes = ''
  if g:MyGrep_ExcludeReg == ''
    let g:MyGrep_ExcludeReg = '^$'
  endif

  let vg = (g:mygrepprg == 'internal' || g:mygrepprg == '' || g:MyGrep_UseVimgrep != 0) ? 1 :0
  let cmdpath = searchPath == '' ? getcwd() : searchPath
  if vg == 0 && s:MSWindows && cmdpath =~ '^\(//\|\\\\\)'
    let host = matchstr(cmdpath, '^\(//\|\\\\\)[^/\\]\+')
    let host = substitute(host, '/', '\', 'g')
    echohl ErrorMsg
    let grepprg = fnamemodify(g:mygrepprg, ':t')
    redraw|echo 'using vimgrep... ('. grepprg .' does not support UNC path "' . host . '")'
    echohl None
    let g:MyGrep_UseVimgrep = 1
    let g:MyGrep_ErrorMes = 'QFixGrep : Vimgrep was used. (UNC path "' . host . '")'
  endif
  if vg == 0 && pattern != '' && pattern !~ '^[[:print:][:space:]]\+$'
    if a:fenc =~ 'le$' || (a:fenc !~ 'cp932\c' && g:mygrepprg == 'findstr') || a:fenc !~ g:MyGrep_Encoding
      echohl ErrorMsg
      redraw|echo 'using vimgrep... (grep does not support "' . a:fenc . '")'
      echohl None
      let g:MyGrep_ErrorMes = 'QFixGrep : Vimgrep was used. (invalid fenc = "'.a:fenc .'")'
      let g:MyGrep_UseVimgrep = 1
    endif
  endif
  if g:mygrepprg == 'internal' || g:mygrepprg == '' || g:MyGrep_UseVimgrep != 0
    silent! exec 'lchdir ' . escape(searchPath, ' ')
    let pattern = escape(pattern, '/')
    let vopt = g:QFix_UseLocationList ? 'l' : ''
    if addflag
      silent! exec ':'.vopt.'vimgrepadd /' . pattern . '/j ' . a:filepattern
    else
      silent! exec ':'.vopt.'vimgrep /' . pattern . '/j ' . a:filepattern
    endif
    "ここでバッファ削除
    let idx = 0
    let save_qflist = QFixGetqflist()
    for d in save_qflist
      if bufname(d.bufnr) =~ g:MyGrep_ExcludeReg
        call remove(save_qflist, idx)
        silent! exec 'silent! bd ' . d.bufnr
      else
        let idx = idx + 1
      endif
    endfor
    call QFixSetqflist(save_qflist)
    if g:MyGrep_StayGrepDir == 0
      silent! exec 'lchdir ' . prevPath
    endif
    let g:MyGrep_Regexp = 1
    let g:MyGrep_Ignorecase = 1
    let g:MyGrep_Recursive  = 0
    let g:MyGrep_UseVimgrep = 0
    if g:MyGrep_ErrorMes != ''
      echohl ErrorMsg
      redraw | echo g:MyGrep_ErrorMes
      echohl None
    endif
    if g:MyGrep_Return
      let g:MyGrep_Return = 0
      return save_qflist
    endif
    call QFixEnable(searchPath)
    return []
  endif

  let ccmd = g:QFix_UseLocationList ? 'lexpr ""' : 'cexpr ""'
  let l:mygrepprg = expand(g:mygrepprg)
  if !executable(l:mygrepprg)
    echohl ErrorMsg
    redraw|echom '"'.l:mygrepprg.'"'." is not executable!"
    echohl None
    let mes = '"'.l:mygrepprg.'" is not executable!'
    let choice = confirm(mes, "&OK")
    let g:MyGrep_Regexp = 1
    let g:MyGrep_Ignorecase = 1
    let g:MyGrep_Recursive  = 0
    let g:MyGrep_UseVimgrep = 0
    return []
  endif
  if g:MyGrep_ShellEncoding =~ 'utf8\c'
    let g:MyGrep_ShellEncoding = 'utf-8'
  endif
  if g:mygrepprg =~ 'yagrep\c'
    if g:MyGrep_yagrep_opt == 2
      let g:MyGrep_Damemoji = 0
    endif
  endif
  call s:SetGrepEnv('set', pattern)
  let _grepcmd = 'g:MyGrepcmd_regexp'
  if g:MyGrep_Regexp == 0
    let _grepcmd = 'g:MyGrepcmd_fix'
    let g:MyGrep_Regexp = 1
  else
    "だめ文字対策
    if g:MyGrep_Damemoji != 0 && a:fenc =~ 'cp932\c'
      let pp = match(pattern, g:MyGrep_DamemojiReplaceDefault[2])
      let pattern = substitute(pattern, g:MyGrep_DamemojiReplaceDefault[g:MyGrep_Damemoji], g:MyGrep_DamemojiReplaceReg, 'g')
      let pattern = substitute(pattern, g:MyGrep_DamemojiReplace, g:MyGrep_DamemojiReplaceReg, 'g')
      if pp > -1
        let g:MyGrep_ErrorMes = printf("QFixGrep : ダメ文字が含まれていました! regxp = %s", pattern)
        if pattern =~ '^[.*]\+$'
          let g:MyGrep_ErrorMes = "QFixGrep : ダメ文字しか含まれていません!"
          silent! exec ccmd
          let g:MyGrep_Regexp = 1
          let g:MyGrep_Ignorecase = 1
          let g:MyGrep_Recursive  = 0
          let g:MyGrep_UseVimgrep = 0
          call s:SetGrepEnv('restore')
          return []
        endif
      endif
    endif
  endif
  if g:MyGrep_Ignorecase > 0
    let _grepcmd = _grepcmd.'_ignore'
  endif
  let g:MyGrep_Ignorecase = 1
  let grepcmd = substitute(g:MyGrepcmd, '#defopt#', {_grepcmd}, '')
  let grepcmd = substitute(grepcmd, '#useropt#', g:MyGrepcmd_useropt, '')
  silent! exec 'lchdir ' . escape(searchPath, ' ')
  let retval = s:ExecGrep(grepcmd, g:mygrepprg, searchPath, pattern, &enc, a:fenc, a:filepattern)
  let pattern = s:ParseFilepattern(a:filepattern)
  let file = ''
  redraw|echo 'QFixGrep : Parsing...'
  let g:MyGrep_qflist = s:ParseSearchResult(searchPath, retval, pattern, g:MyGrep_ShellEncoding, a:fenc)
  call s:SetGrepEnv('restore')
  if g:MyGrep_Return
    let g:MyGrep_Return = 0
    if g:MyGrep_StayGrepDir == 0
      silent! exec 'lchdir ' . prevPath
    endif
    redraw|echo ''
    return g:MyGrep_qflist
  endif
  if a:0
    redraw|echo ''
  else
    redraw|echo 'QFixGrep : Set quickfix list...'
    let flag = addflag ? 'a' : ' '
    call QFixSetqflist(g:MyGrep_qflist, flag)
  endif
  if g:MyGrep_StayGrepDir == 0
    silent! exec 'lchdir ' . prevPath
  endif
  call QFixEnable(searchPath)
  redraw | echo ''
  if g:MyGrep_ErrorMes != ''
    echohl ErrorMsg
    redraw | echo g:MyGrep_ErrorMes
    echohl None
  endif
  return []
endfunction

let g:MyGrep_ErrorMes = ''
if !exists('g:qfixtempname')
  let g:qfixtempname = tempname()
endif

""""""""""""""""""""""""""""""
"findstr/jvgrep用に環境設定
""""""""""""""""""""""""""""""
function! s:SetGrepEnv(mode, ...)
  if a:mode == 'set'
    let s:mygrepprg = ''
    if g:myjpgrepprg != '' && a:0 && match(a:1, '[^[:print:]]') > -1
      let s:mygrepprg = g:mygrepprg
      let g:mygrepprg = g:myjpgrepprg
    endif
  endif
  if g:mygrepprg != 'findstr' && g:mygrepprg !~ 'jvgrep'
    return
  endif
  if a:mode == 'set'
    let s:MyGrepcmd                 = g:MyGrepcmd
    let s:MyGrepcmd_regexp          = g:MyGrepcmd_regexp
    let s:MyGrepcmd_regexp_ignore   = g:MyGrepcmd_regexp_ignore
    let s:MyGrepcmd_fix             = g:MyGrepcmd_fix
    let s:MyGrepcmd_fix_ignore      = g:MyGrepcmd_fix_ignore
    let s:MyGrepcmd_useropt         = g:MyGrepcmd_useropt
    let s:MyGrep_RecOpt             = g:MyGrep_RecOpt
    let s:MyGrep_Damemoji           = g:MyGrep_Damemoji
    let s:MyGrep_DamemojiReplaceReg = g:MyGrep_DamemojiReplaceReg
    let s:MyGrep_ShellEncoding      = g:MyGrep_ShellEncoding

    if g:mygrepprg == 'findstr'
      let g:MyGrepcmd                 = '#prg# #defopt# #recopt# #opt# #useropt# /G:#searchWordFile# #searchPath#'
      let g:MyGrepcmd_regexp          = '/n /p /r'
      let g:MyGrepcmd_regexp_ignore   = '/n /p /r /i'
      let g:MyGrepcmd_fix             = '/n /p /l'
      let g:MyGrepcmd_fix_ignore      = '/n /p /l /i'
      let g:MyGrep_RecOpt             = '/s'
      let g:MyGrep_DamemojiReplaceReg = '..'
      let g:MyGrep_ShellEncoding      = 'cp932'
    elseif g:mygrepprg =~ 'jvgrep'
      let g:MyGrepcmd_regexp          = ''
      let g:MyGrepcmd_regexp_ignore   = '-i' " TODO: works fixed match only.
      let g:MyGrepcmd_fix             = '-F'
      let g:MyGrepcmd_fix_ignore      = '-i -F'
      let g:MyGrep_RecOpt             = '-R'
      let g:MyGrep_Damemoji           = 0
    endif
  elseif a:mode == 'restore'
    if s:mygrepprg != ''
      let g:mygrepprg = s:mygrepprg
      let s:mygrepprg = ''
    endif
    let g:MyGrepcmd                 = s:MyGrepcmd
    let g:MyGrepcmd_regexp          = s:MyGrepcmd_regexp
    let g:MyGrepcmd_regexp_ignore   = s:MyGrepcmd_regexp_ignore
    let g:MyGrepcmd_fix             = s:MyGrepcmd_fix
    let g:MyGrepcmd_fix_ignore      = s:MyGrepcmd_fix_ignore
    let g:MyGrepcmd_useropt         = s:MyGrepcmd_useropt
    let g:MyGrep_RecOpt             = s:MyGrep_RecOpt
    let g:MyGrep_Damemoji           = s:MyGrep_Damemoji
    let g:MyGrep_DamemojiReplaceReg = s:MyGrep_DamemojiReplaceReg
    let g:MyGrep_ShellEncoding      = s:MyGrep_ShellEncoding
  endif
endfunction

""""""""""""""""""""""""""""""
"検索語ファイルを作成してgrep
""""""""""""""""""""""""""""""
function! s:ExecGrep(cmd, prg, searchPath, searchWord, from_encoding, to_encoding, filepattern)
  if !isdirectory(expand(a:searchPath))
    let mes = printf('QFixGrep : %s is not directory!', a:searchPath)
    let choice = confirm(mes, "&OK")
    let g:MyGrep_retval = ''
    return g:MyGrep_retval
  endif

  " iconv が使えない
  "  if a:from_encoding != a:to_encoding && !has('iconv')
  "    echoe 'QFixGrep : not found iconv!'
  "    let g:MyGrep_ErrorMes = 'QFixGrep : Not found iconv!'
  "    let choice = confirm(g:MyGrep_ErrorMes, "&OK")
  "    return
  "  endif
  let cmd = a:cmd
  " プログラム設定
  let prg = fnamemodify(a:prg, ':t')
  let cmd = substitute(cmd, '#prg#', prg, 'g')

  let sPath = '*'
  let ropt = ''
  let opt = ''

  " 検索パス設定
  if match(a:filepattern, '^\*\*/') != -1 || g:MyGrep_RecursiveMode
    let g:MyGrep_Recursive = 1
  endif
  if s:debug
    "let filepattern = substitute(a:filepattern, '^\*\*/', '', '')
    "let sPath = filepattern
  endif
  if g:MyGrep_Recursive == 1
    let ropt = g:MyGrep_RecOpt
    let g:MyGrep_Recursive = 0
  endif
  if g:mygrepprg =~ 'yagrep\c'
    if a:to_encoding =~ 'cp932\c'
      let opt = '--ctype=SJIS'
    elseif a:to_encoding =~ 'euc\c'
      let opt = '--ctype=EUC'
    elseif a:to_encoding =~ 'utf-8\c'
      let opt = '--ctype=UTF8'
    endif
    let opt = opt .' -s'
    if g:MyGrep_yagrep_opt == 0
      let opt = ' -s'
    endif
  endif
  if g:MyGrep_IncludeOpt == 1
    let ipat = substitute(a:filepattern, '\*\*/', '', 'g')
    "TODO:空白で区切られたファイルの種類だけ--include=*.hoge
    "簡単に試した限りでは、さほど速度向上にならない気がする。
    "さらに--includeオプションにバグのあるgrepも存在する。
    let opt = opt.' --include='.ipat
  endif
  let cmd = substitute(cmd, '#recopt#', ropt, '')
  let cmd = substitute(cmd, '#opt#', opt, '')
  let cmd = substitute(cmd, '#cmdopt#', g:MyGrep_cmdopt, '')
  let g:MyGrep_cmdopt = ''
  let cmd = substitute(cmd, '#searchPath#', escape(sPath, '\\'), 'g')

  " 検索語ファイル作成
  if match(cmd, '#searchWordFile#') != -1
    let searchWord = iconv(a:searchWord, a:from_encoding, a:to_encoding)
    let searchWordList = [searchWord]
    call writefile(searchWordList, g:qfixtempname, 'b')
    let cmd = substitute(cmd, '#searchWordFile#', s:GrepEscapeVimPattern(g:qfixtempname), 'g')
  endif
  if match(cmd, '#searchWord#') != -1
    let to_encoding = g:MyGrep_ShellEncoding
    let searchWord = iconv(a:searchWord, a:from_encoding, to_encoding)
    if g:mygrepprg =~ 'jvgrep'
      if match(searchWord, ' ')
        let searchWord = '"' . searchWord . '"'
      endif
    endif
    let cmd = substitute(cmd, '#searchWord#', s:GrepEscapeVimPattern(searchWord), 'g')
  endif

  " 検索実行
  let prevPath = escape(getcwd(), ' ')
  silent! exec 'lchdir ' . escape(a:searchPath, ' ')
  silent! let saved_path = $PATH
  let dir = fnamemodify(a:prg, ':h')
  if dir != '.'
    let dir = fnamemodify(a:prg, ':p:h')
    let delimiter = has('unix') ? ':' : ';'
    let $PATH = dir.delimiter.$PATH
  endif
  let g:MyGrep_retval = system(cmd)
  let g:MyGrep_path   = a:searchPath
  if s:debug
    let g:fudist_cmd = cmd
    let g:fudist_pat = a:filepattern
    let g:fudist_word = a:searchWord
  endif
  silent! let $PATH  = saved_path
  if exists('g:qfixtempname')
    silent! call delete(g:qfixtempname)
  endif
  return g:MyGrep_retval
endfunction

""""""""""""""""""""""""""""""
"ファイルパターンを変換
""""""""""""""""""""""""""""""
function! s:ParseFilepattern(filepattern)
  let filepattern = a:filepattern
  let filepattern = substitute(filepattern, '\*\*/', '', 'g')
  let filepattern = substitute(filepattern, '\s\+', ' ', 'g')
  let filepattern = substitute(filepattern, '^\s\|\s$', '', 'g')
  if filepattern == '*'
    let filepattern = '.*'
  else
    let filepattern = substitute(filepattern, ' ', '$\\|', 'g')
    let filepattern = substitute(filepattern, '\.', '\\.', 'g')
    let filepattern = substitute(filepattern, '*', '\.*', 'g')
    let filepattern = substitute(filepattern, '\\|\*', '\\|\.\*', 'g')
    let filepattern = filepattern.'$'
  endif
  return filepattern
endfunction

function! s:ParseSearchResult(searchPath, searchResult, filepattern, shellenc, fenc)
  let wipetime = g:MyGrep_FileListWipeTime
  let g:MyGrep_FileListWipeTime = 0
  let fe=a:fenc
  if g:mygrepprg =~ 'jvgrep'
    let fe = g:MyGrep_ShellEncoding
  endif
  let parseResult = ''
  let searchResult = a:searchResult
  let prevfname = ''
  let qfmtime = -1
  let mtime = 0
  let fcnv = a:shellenc != &enc
  let ccnv = fe != &enc
  let qflist = []
  let recheck = 0
  let prevPath = escape(getcwd(), ' ')

  for buf in split(searchResult, '\n')
    while 1
      let bufidx = matchend(buf, ':\d\+:', 0, 1)
      if bufidx == -1
        break
      endif
      let extidx = match(buf, ':\d\+:', 0, 1)
      let fname  = strpart(buf, 0, extidx)
      if fcnv
        let fname = iconv(fname, a:shellenc, &enc)
      endif
      let outtime = 0
      if wipetime > 0
        if prevfname != fname
          let qfmtime = getftime(fname)
          let prevfname = fname
        endif
        if qfmtime < wipetime
          let outtime = 1
        endif
      endif
      let lnum = strpart(buf, extidx+1, bufidx-extidx-2)
      let text = strpart(buf, bufidx)
      if ccnv
        let text = iconv(text, fe, &enc)
      endif
      let lst = split(text, '\n')
      if lst == []
        break
      endif
      let content = lst[0]
      let content = strpart(content, 0, 1024-strlen(fname)-32)
      let content = substitute(content, "[\n\r]", "", "")
      if fname !~ '\c\.swp$\|\~$' && fname =~ a:filepattern && fname !~ g:MyGrep_ExcludeReg && outtime == 0
        call add(qflist, {'filename':fname, 'lnum':lnum, 'text':content})
      endif
      if lst[0] != text
        if ccnv
          let text = iconv(lst[0], &enc, fe)
        endif
        let buf = strpart(buf, bufidx + strlen(text))
        let buf = substitute(buf, '^\n', '', '')
      else
        break
      endif
    endwhile
  endfor
  silent! exec 'lchdir ' . prevPath
  if s:debug && len(qflist) == 0 && a:searchResult != ''
    " let mes = iconv(g:MyGrep_retval, a:shellenc, &enc)
    " redraw | echoe string(mes)
    " let choice = confirm(mes, "&OK")
  endif
  return qflist
endfunction

"正規表現エスケープ
function! s:GrepEscapeVimPattern(pattern)
  let retval = escape(a:pattern, '\\.*+@{}<>~^$()|?[]%=&')
  let retval = retval
  return retval
endfunction

""""""""""""""""""""""""""""""
"代替コマンド
""""""""""""""""""""""""""""""
"setqflist代替
silent! function QFixSetqflist(sq, ...)
  let cmd = 'a:sq'. (a:0 == 0 ? '' : ",'".a:1."'")
  if g:QFix_UseLocationList
    exec 'call setloclist(0, '.cmd.')'
  else
    exec 'call setqflist('.cmd.')'
  endif
endfunction

"getqflist代替
silent! function QFixGetqflist()
  if g:QFix_UseLocationList
    return getloclist(0)
  else
    return getqflist()
  endif
endfunction

"ロケーションリスト設定
function! QFixGrepLocationMode(...)
  let mode = a:0 ? a:1 : 0
  let mode = count ? count : mode
  if mode == 0
    let g:QFix_UseLocationList   = 0
    let g:MyGrep_UseLocationList = 0
  elseif mode == 1
    let g:QFix_UseLocationList   = 1
    let g:MyGrep_UseLocationList = 0
  elseif mode == 2
    let g:QFix_UseLocationList   = 1
    let g:MyGrep_UseLocationList = 1
  elseif mode == 3
    let g:QFix_UseLocationList   = 0
    let g:MyGrep_UseLocationList = 1
  elseif mode == 4
    let g:QFix_UseLocationList   = 0
    let g:MyGrep_UseLocationList = 0
  else
    return
  endif
  if a:0 > 1
    return
  endif
  echo printf('QFixWin (%s) : QFixGrep (%s)', (g:QFix_UseLocationList ? 'L' : 'Q'), (g:MyGrep_UseLocationList ? 'L' : 'Q'))
endfunction

"copen代替
silent! command -nargs=* -bang QFixCopen call QFixCopen(<q-args>, <bang>0)
silent! function QFixCopen(cmd, mode)
  if g:QFix_UseLocationList
    silent! lopen
  else
    silent! copen
  endif
endfunction

"cclose代替
command! QFixCclose call QFixCclose()
function! QFixCclose()
  if g:QFix_UseLocationList
    silent! lclose
  else
    silent! cclose
  endif
endfunction

"pclose代替
silent! command QFixPclose call QFixPclose()
silent! function! QFixPclose()
  silent! pclose!
endfunction

" MyGrepReadResult stab
if !exists('*MyGrepReadResult')
  command! -count -nargs=* -bang MyGrepReadResult call MyGrepReadResult(<bang>0, <q-args>)
  function! MyGrepReadResult(readflag, ...)
    echoe "MyGrepReadResult : cannot read QFixlib!"
  endfunction
endif

""""""""""""""""""""""""""""""
" MyQFixライブラリを使用可能にする。
""""""""""""""""""""""""""""""
function! QFixEnable(path)
  let g:QFix_SearchPath = a:path
endfunction

""""""""""""""""""""""""""""""
"コマンドラインからのgrep
""""""""""""""""""""""""""""""
let s:rMyGrep_Recursive = 0
function! RCGrep(mode, bang, addflag,  arg)
  let s:rMyGrep_Recursive = 1
  call CGrep(a:mode, a:bang, a:addflag, a:arg)
endfunction

function! CGrep(mode, bang, addflag,  arg)
  let mode = a:mode
  let addflag = a:addflag
  let opt = ''
  let pattern = ''
  let filepattern = ''
  let path = ''
  let type = 0
  let g:MyGrep_cmdopt = ''

  let g:MyGrep_Regexp = 1
  let g:MyGrep_Ignorecase = 1
  let g:MyGrep_Recursive  = 0
  let g:MyGrep_UseVimgrep = 0

  if s:rMyGrep_Recursive
    let g:MyGrep_Recursive  = 1
  endif
  let s:rMyGrep_Recursive = 0
  let opt = matchstr(a:arg, '^\(\s*[-/][^ ]\+\)\+')
  let fenc = matchstr(opt, '--fenc=[^\s]\+')
  let fenc = substitute(fenc, '--fenc=', '', '')
  if fenc == ''
    let fenc = &fenc
  endif
  let opt = substitute(opt,'--fenc=[^\s]\+', '', '')

  let pattern = substitute(a:arg, '^\(\s*[-/][^ ]\+\)\+', '', '')
  let pattern = matchstr(pattern, '^.*[^\\]\s')
  let pattern = substitute(pattern, '\s*$\|^\s*', '', 'g')
  if pattern =~ '^".*"$'
    let pattern = substitute(pattern, '^"\|"$', '', 'g')
  endif
  " \で " をエスケープ？
  if pattern =~ '^\\".*\\"$'
    let pattern = substitute(pattern, '^\\"\|\\"$', '"', 'g')
  endif
  let str = substitute(a:arg, '^.*[^\\]\s', '', '')
  let str = substitute(str, '\\ ', ' ', 'g')
  let path = fnamemodify(str, ':p:h')
  if path == ''
    let path = expand('%:p:h')
  endif
  let filepattern = fnamemodify(str, ':t')
  if pattern =~ '^\s*$'
    if mode
      return UGrep('grep -F', pattern, a:bang, addflag)
    endif
    return UGrep('grep', pattern, a:bang, addflag)
  endif
  call s:save()
  if mode
    let g:MyGrep_Regexp = 0
  endif
  let g:MyGrep_cmdopt = opt
  call MyGrep(pattern, path, filepattern, fenc, addflag)
  let save_qflist = QFixGetqflist()
  if empty(save_qflist)
    redraw | echo 'QFixGrep : Not found!'
    echo pattern.' | '.fenc.' | '.filepattern.' | '. path
  else
    if g:QFix_HeightFixMode == 1
      let g:QFix_Height = g:QFix_HeightDefault
    endif
    QFixCopen
    call cursor(1, 1)
  endif
  call s:restore()
endfunction

let s:QFixGrep_Helpfile = 'QFixGrepHelp'
function! QFixGrepHelp()
  if exists('*QFixHowmHelp')
    return QFixHowmHelp()
  endif
  return QFixGrepHelp_()
endfunction

function! QFixGrepHelp_()
  call mygrep_msg#help()
  silent! exec 'split ' . s:QFixGrep_Helpfile
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  "setlocal nobuflisted
  call setline(1, g:QFixGrepHelpList)
  call cursor(1,1)
endfunction

""""""""""""""""""""""""""""""
" Windowsパス正規化
" pathは呼び出し側でexpandされていることを前提
"
" ドライブレターのみキャピタライズしたpathを返す。
" 追加オプションに 'compare'を指定すると
" Windowsのみキャピタライズしたpathを返す。
" 非Windowsではそのままのpathを返す。
""""""""""""""""""""""""""""""
function! QFixNormalizePath(path, ...)
  let path = a:path
  " let path = expand(a:path)
  if s:MSWindows
    if a:0 " 比較しかしないならキャピタライズ
      let path = toupper(path)
    else
      " expand('~') で展開されるとドライブレターは大文字、
      " expand('c:/')ではそのままなので統一
      let path = substitute(path, '^\([a-z]\):', '\u\1:', '')
    endif
    let path = substitute(path, '\\', '/', 'g')
  endif
  return path
endfunction

