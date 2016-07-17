"=============================================================================
"    Description: howm形式の予定・TODOアラーム
"                 QFixHowmのプラグインとしても使用できます。
"     Maintainer: fuenor@gmail.com
"                 http://sites.google.com/site/fudist/Home/qfixhowm
"=============================================================================
scriptencoding utf-8

" 指定時間になるとアラームメッセージを表示します。
" Vim 7.4.1578以降であれば非同期タイマーを利用しますが、それ以前ではCursorHold
" を利用するので、トリガはキー入力後から updatetimeが経過した時になります。
"
" (!!! CursorHold使用時の注意 !!!)
"
" CursorHoldで利用する場合は予定時間を超えた後、何かキータイプやウィンドウ切替
" などの操作を行っている事が必要になります。
" 放置しっぱなしでは、CursorHold イベントが呼び出されないので呼び出されません。
" そういうわけで、CursorHold使用時は基本Vimでずっと作業しているような人向けです。
" 当然タイミングによってはアラームが表示されないので、動作を理解した上であまり
" 信用せずに使用してください。
"
" またCursorHoldで使用する場合はupdatetimeを適切に設定してください。
"
"   set updatetime=4000
"
" # 使用方法
"
" デフォルトでは'~/alarm.howm' (HowmAlarmFileで指定)に書かれた予定が使用されます。
" 書式はhowm形式になります。
"
" (例)
" [2009-07-07 18:00]@ 表示される予定。今日の日付で近い時間に設定してみてください。
"
" この例だと2009年7月7日の18:00を過ぎた後に、Vimを起動しているとアラーム表示さ
" れます。
" ファイルエンコーディングは let howm_fileencoding で、未指定時はencoding (内
" 部エンコーディング)が使用されます。
"
" # アラーム形式
"
" [2000-01-01 18:00]@ なんか予定を書きます [T:-30]
"
" 実際に必要なのは行頭の [2000-01-01 18:00]だけです。
" 予定の中に以下の文字列があると、表示形式と時間のオフセットを選べます。
" [T:+10] 指定時間の10分後に表示(時間のオフセット指定)
" [N:]    指定時間にコマンドラインにノーマル表示
" [S:-30] 指定時間の30分前にコマンドラインに強調表示
" [D:+10] 指定時間の10分後にダイアログを出して表示
" [R:+10] 指定時間から10分ごとに表示します。
"
" 毎日の繰り返し予定も使えます
" [0000-00-00 18:00]@ 毎日18:00に繰り返す予定
" この場合表示形式は選べますが、時間のオフセットは無視されます。
"
" 再読込は :HowmAlarmReadFile <ファイル名(省略可)> です。
"
" # QFixHowmとの連携
"
" QFixHowmを使用しているなら、HowmAlarmUseQFixHowmを設定すると起動時にQFixHowm
" の予定を取り込みます。
"
" 0 : QFixHowmと連携しない(g:HowmAlarmFileのみ読み込み)
" 1 : 起動時に前回作成したQFixHowmの予定を取り込み
" 2 : 一日一回、起動時にQFixHowm予定を更新
" 3 : 起動時に毎回QFixHowm予定を更新
" 4 : 一日一回、起動時にQFixHowm予定を更新(実行後に予定を表示)
" 5 : 起動時に毎回QFixHowm予定を更新(実行後に予定を表示)
"
" おすすめは2です。
" let g:HowmAlarmUseQFixHowm = 2
"
" g,yで表示されるうち [2000-01-01 18:00]@ のように時刻まで含まれた予定が登録さ
" れます。
" 再作成したい場合は g,ry で予定ファイルを再作成します。
"
" なお、QFixHowmの予定を取り込んでも HowmAlarmFileの予定も有効です。
"

if exists("loaded_HowmAlarm") && !exists('fudist')
  finish
endif
if exists('disable_HowmAlarm') && disable_HowmAlarm
  finish
endif
let loaded_HowmAlarm = 1

" 使用する定義ファイル
if !exists('g:HowmAlarmFile')
  let g:HowmAlarmFile = '~/.alarm.howm'
endif

" QFixHowmの予定保存ファイル
if !exists('g:QFixHowmAlarmFile')
  let g:QFixHowmAlarmFile = '~/.howm-alarm.howm'
endif

" 予定の表示形式
" 0:表示しない 1:ノーマル 2:強調表示 3:ダイアログ
if !exists('g:HowmAlarmDispMode')
  let g:HowmAlarmDispMode = 3
endif

" Vim起動時の処理
" 0 : QFixHowmと連携しない(g:HowmAlarmFileのみ読み込み)
" 1 : 起動時に前回作成したQFixHowmの予定を取り込み
" 2 : 一日一回、起動時にQFixHowm予定を更新
" 3 : 起動時に毎回QFixHowm予定を更新
" 4 : 一日一回、起動時にQFixHowm予定を更新
" 5 : 起動時に毎回QFixHowm予定を更新
if !exists('g:HowmAlarmUseQFixHowm')
  let g:HowmAlarmUseQFixHowm = 2
endif

" QFixHowmからの取り込みでHowmAlarmに登録しない正規表現
if !exists('g:QFixHowmAlarmFilterReg')
  let g:QFixHowmAlarmFilterReg = ''
endif

" アラームが表示される時間のデフォルトオフセット
" 10なら10分前に表示される
if !exists('g:HowmAlarmTimeOffset')
  let g:HowmAlarmTimeOffset = 0
endif

" 時間オフセットが定義されている時、予定時間にもアラーム表示する
" (一つの予定に付き二回表示される)
if !exists('g:HowmAlarmDefaultAlarm')
  let g:HowmAlarmDefaultAlarm = 0
endif

" 起動時に指定分前の予定も表示する
" 10なら起動時に現時刻から10分前までの予定が表示される。
if !exists('g:HowmAlarmRegOffset')
  let g:HowmAlarmRegOffset = 0
endif

" アラーム表示
" .vimrc等で定義されている場合はそちらが優先される
if !exists('*DoHowmAlarm')
function DoHowmAlarm(alarm)
  let alarm = a:alarm
  let dmode = ''
  if alarm['cmd'] != ''
    let dmode = alarm['cmd'][1]
  endif
  if g:HowmAlarmDispMode == 3 || dmode == 'D'
    call confirm(alarm['text'], "&OK")
  else
    if g:HowmAlarmDispMode == 2 || dmode == 'S'
      echohl ErrorMsg
    endif
    if dmode == 'N'
      echohl None
    endif
    redraw| echom alarm['text']
    echohl None
  endif
endfunction
endif

" -------------------------
" 正規表現パーツ
if !exists('g:QFixHowm_DatePattern')
  let g:QFixHowm_DatePattern = '%Y-%m-%d'
endif
let s:hts_date     = g:QFixHowm_DatePattern
let s:hts_time     = '%H:%M'
let s:hts_dateTime = g:QFixHowm_DatePattern . ' '. s:hts_time

let s:sch_dateTime = s:hts_dateTime
let s:sch_dateTime = substitute(s:sch_dateTime, '%Y', '\\d\\{4}', '')
let s:sch_dateTime = substitute(s:sch_dateTime, '%m', '\\d\\{2}', '')
let s:sch_dateTime = substitute(s:sch_dateTime, '%d', '\\d\\{2}', '')
let s:sch_dateTime = substitute(s:sch_dateTime, '%H', '\\d\\{2}', '')
let s:sch_dateTime = substitute(s:sch_dateTime, '%M', '\\d\\{2}', '')
let s:sch_rdate    = s:hts_date
let s:sch_rdate    = substitute(s:sch_rdate, '%Y', '0000', '')
let s:sch_rdate    = substitute(s:sch_rdate, '%m', '00', '')
let s:sch_rdate    = substitute(s:sch_rdate, '%d', '00', '')
let s:HowmAlarm = []
let s:HowmAlarmId = -1

function! s:HowmAlarmSet()
  " timer_startはpatch 7.4.1578以降
  if v:version > 704 || (v:version == 704 && has('patch1578'))
    if g:HowmAlarmDispMode == 0 || len(s:HowmAlarm) == 0
      return
    endif
    if (s:HowmAlarmId != -1)
      call timer_stop(s:HowmAlarmId)
      let s:HowmAlarmId = -1
    endif
    let time = (s:HowmAlarm[0]['time'] - localtime()) * 1000
    let s:HowmAlarmId = timer_start(time, 'HowmAlarmHandler')
  else
    augroup HowmAlarm
      autocmd!
      autocmd CursorHold  * call <SID>CursorHold()
      autocmd CursorHoldI * call <SID>CursorHold()
    augroup END
  endif
endfunction

if v:version > 704 || (v:version == 704 && has('patch1578'))
function! HowmAlarmHandler(timerId)
  if s:Alarm() == 0
    return
  endif
  call s:HowmAlarmSet()
endfunction
endif

command! -bang -nargs=? QFixHowmAlarmReadFile call <SID>QFixHowmAlarmReadFile(<bang>0)

augroup HowmAlarm
  autocmd!
  autocmd VimEnter * call <SID>QFixHowmAlarmReadFileVimEnter(g:HowmAlarmUseQFixHowm)
augroup END

function! QFixHowmAlarmReadFile_qf(qf)
  call s:QFixHowmAlarmReadFile(3, a:qf)
endfunction

function! s:QFixHowmAlarmReadFileVimEnter(mode, ...)
  call s:QFixHowmAlarmReadFile(a:mode)
  if (a:mode == 4 || a:mode == 5) && exists('g:loaded_qfixmemo_init')
    call feedkeys(g:qfixmemo_mapleader.'y', 't')
  endif
endfunction

function! s:QFixHowmAlarmReadFile(mode, ...)
  " strftime()の基準日数
  if !exists('g:DateStrftime')
    let g:DateStrftime = 719162
  endif
  " GMTとの時差
  if !exists('g:QFixHowm_ST')
    let g:QFixHowm_ST = -9
  endif
  if !exists('g:howm_fileencoding')
    let g:howm_fileencoding = &enc
  endif
  if !exists('g:QFixHowm_TitleFilterReg')
    let g:QFixHowm_TitleFilterReg = ''
  endif
  call s:HowmAlarmReadFile(g:HowmAlarmFile, 0)
  if a:mode > 0 && exists('g:loaded_qfixmemo_init')
    let elist = []
    let file = expand(g:QFixHowmAlarmFile)
    let ftime = getftime(file)
    let today = s:HowmDate2Int(strftime(s:hts_date) . ' 00:00')
    if (a:mode != 1) && (today > ftime || a:0 || a:mode == 3 || a:mode == 5)
      if a:0
        let sq = a:1
      else
        if qfixmemo#Init()
          return
        endif
        call howm_schedule#Init()
        let sq = QFixHowmListReminder_qf('schedule')
      endif
      if len(sq) > 0
        let tfmt = '^\s*\['.s:sch_dateTime.'][-@!+~.]'
        for d in sq
          if d['text'] =~ tfmt
            if g:QFixHowmAlarmFilterReg == ''
              call add(elist, d['text'])
            elseif d['text'] !~ g:QFixHowmAlarmFilterReg
              call add(elist, d['text'])
            endif
          endif
        endfor
        call writefile(elist, file)
      endif
    elseif filereadable(file)
      let elist = readfile(file)
    endif
    if len(elist)
      call s:_HowmAlarmSet(elist)
    endif
  endif
  call s:HowmAlarmSet()
endfunction

command! -bang -nargs=* HowmAlarmReadFile call <SID>HowmAlarmReadFile(<q-args>, <bang>0)
" modeは登録済みのアラームを削除しないで追加するフラグ
function! s:HowmAlarmReadFile(file, mode)
  let file = a:file
  if file == ''
    let file = g:HowmAlarmFile
  endif
  let file = expand(file)
  if !filereadable(file)
    return
  endif
  " readfileはエンコーディング判定も行わないことに注意。
  let retval = readfile(file)
  if a:mode == 0
    let s:HowmAlarm = []
  endif
  return s:_HowmAlarmSet(retval)
endfunction

function! s:_HowmAlarmSet(retval)
  let cmdfmt = '\[[TNSDR]:\([-+]\?\d\+\)\?\]'
  let tfmt = '^\s*\['.s:sch_dateTime.'][-@!+~.]'
  let rfmt = '^\s*\['.s:sch_rdate.' \d\{2}:\d\{2}][-@!~+.]'
  for d in a:retval
    let text = d
    if text == '' || text !~ tfmt
      continue
    endif
    let text = substitute(text, '^\s*', '', '')
    if g:howm_fileencoding != &enc
      let text = iconv(text, g:howm_fileencoding, &enc)
    endif
    let cmd = matchstr(text, cmdfmt)
    let text = substitute(text, cmdfmt, '', '')
    if text =~ rfmt || cmd[1] == 'R'
      call s:RegRepeatAlarm(text, cmd)
    else
      call s:RegAlarm(text, cmd)
    endif
  endfor
  let s:HowmAlarm = sort(s:HowmAlarm, "<SID>CompareTime")
  return s:HowmAlarm
endfunction

function! s:RegAlarm(text, cmd)
  let ctime = localtime()-g:HowmAlarmRegOffset*60
  let text = a:text
  let cmd = a:cmd
  let rep = 0
  let rep = matchstr(cmd, '\d\+')*60
  if match(cmd, 'R:\d\+') == -1
    let rep = 0
  endif
  let ofs = matchstr(cmd, '-\?\d\+')
  if ofs == ''
    let ofs = - g:HowmAlarmTimeOffset
  endif
  let sec = s:HowmDate2Int(text) + ofs * 60
  if sec >= ctime
    let ddat = {"time": sec, "text": text, "cmd":cmd, "repeat":rep, "id": -1}
    call add(s:HowmAlarm, ddat)
  endif
  if ofs != 0 && g:HowmAlarmDefaultAlarm
    let sec = s:HowmDate2Int(text)
    if sec >= ctime || cmd[1] == 'R'
      let ddat = {"time": sec, "text": text, "cmd":cmd, "repeat":rep, "id": -1}
      call add(s:HowmAlarm, ddat)
    endif
  endif
endfunction

function! s:RegRepeatAlarm(text, cmd)
  let text = a:text
  let cmd = a:cmd
  let ctime  = strftime("%H:%M", localtime()-g:HowmAlarmRegOffset*60)
  let sctime = localtime()-g:HowmAlarmRegOffset*60
  let time  = matchstr(text, '\d\{2}:\d\{2}')
  let rep = matchstr(cmd, '\d\+')*60
  if match(cmd, 'R:+\?\d\+') == -1
    let rep = 24*60*60
  endif
  let stime = s:HowmDate2Int(strftime(s:hts_date). ' '. time )
  if stime >= sctime
    let sec = stime
  else
    let c = 1+(localtime()-stime)/rep
    let sec = s:HowmDate2Int(strftime(s:hts_date, localtime()+c*rep) . ' '. time )
  endif
  let ddat = {"time": sec, "text": text, "cmd":cmd, "repeat":rep, "id": -1}
  call add(s:HowmAlarm, ddat)
endfunction

function! s:CompareTime(v1, v2)
  return (a:v1.time > a:v2.time?1:-1)
endfunction

function! s:CursorHold()
  if g:HowmAlarmDispMode == 0 || s:HowmAlarm == [] || localtime() <= s:HowmAlarm[0]['time']
    return
  endif
  call s:Alarm()
endfunction

function! s:Alarm(...)
  if g:HowmAlarmDispMode == 0 || len(s:HowmAlarm) == 0
    return 0
  endif
  if s:HowmAlarm[0]['time'] - localtime() < 0
    if a:0 == 0 || a:1 !=0
      call DoHowmAlarm(s:HowmAlarm[0])
    endif
    let re = remove(s:HowmAlarm, 0)
    if re['repeat'] > 0
      let rep = re['repeat']
      let c = 1+(localtime()-re['time'])/rep
      let sec = c*rep
      let re['time'] = re['time'] + sec
      call add(s:HowmAlarm, re)
      let s:HowmAlarm = sort(s:HowmAlarm, "<SID>CompareTime")
    endif
  endif
  return len(s:HowmAlarm)
endfunction

function! s:HowmDate2Int(str)
  let str = a:str
  let retval = 'time'
  " ザ・決め打ち
  let str   = substitute(str, '[^0-9]','', 'g')
  let year  = matchstr(str, '\d\{4}')
  let str   = substitute(str, '\d\{4}-\?','', '')
  let month = matchstr(str, '\d\{2}')
  let str   = substitute(str, '\d\{2}-\?','', '')
  let day   = matchstr(str, '\d\{2}')
  let str   = substitute(str, '\d\{2} \?','', '')
  let hour  = matchstr(str, '\d\{2}')
  let str   = substitute(str, '\d\{2}:\?','', '')
  let min   = matchstr(str, '\d\{2}')
  if hour == '' || min == ''
    let retval = 'date'
    let hour  = strftime('%H', localtime())
    let min   = strftime('%M', localtime())
  endif

  " 1・2月 → 前年の13・14月
  if month <= 2
    let year = year - 1
    let month = month + 12
  endif
  let dy = 365 * (year - 1) " 経過年数×365日
  let c = year / 100
  let dl = (year / 4) - c + (c / 4)  " うるう年分
  let dm = (month * 979 - 1033) / 32 " 1月1日から month 月1日までの日数
  let today = dy + dl + dm + day - 1

  if retval =~ 'date'
    return today
  endif

  let today = today - g:DateStrftime
  let sec = today * 24*60*60 + g:QFixHowm_ST * (60 * 60) "JST = -9
  let sec = sec + hour * (60 * 60) + min * 60

  return sec
endfunction

