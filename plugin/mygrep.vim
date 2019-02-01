scriptencoding utf-8

" qfixgrepとしての動作が不要な場合は、.vimrcでdisable_QFixGrepを1に設定してください。
if exists('g:disable_QFixGrep') && g:disable_QFixGrep
  finish
endif
if exists('g:disable_MyGrep') && g:disable_MyGrep
  finish
endif

""""""""""""""""""""""""""""""
" コマンドラインコマンド
""""""""""""""""""""""""""""""
" コマンドライン用コマンドを追加する
" let g:MyGrep_Commands = 1
" 以下のように.vimrcへ追加して、必要なコマンドのみ個別に有効化も可能
" command! -nargs=* -bang Vimgrep     call qfixgrep#QFixCmdGrep('Vimgrep', <q-args>)

if exists('g:MyGrep_Commands') && g:MyGrep_Commands > 0
  command! -nargs=* -bang BGrep       call qfixgrep#BGrep(<q-args>, <bang>0, 0)
  command! -nargs=* -bang Vimgrep     call qfixgrep#QFixCmdGrep('Vimgrep', <q-args>)
  command! -nargs=* -bang VGrep       call qfixgrep#QFixCmdGrep('Vimgrep', <q-args>)

  command! -nargs=* -bang BGrepadd    call qfixgrep#BGrep(<q-args>, <bang>0, 1)
  command! -nargs=* -bang VGrepadd    call qfixgrep#QFixCmdGrep('Vimgrepadd', <q-args>)
  command! -nargs=* -bang Vimgrepadd  call qfixgrep#QFixCmdGrep('Vimgrepadd', <q-args>)

  command! -nargs=* -bang Grep        call qfixgrep#QFixCmdGrep('Grep',   <q-args>)
  command! -nargs=* -bang EGrep       call qfixgrep#QFixCmdGrep('Grep',   <q-args>)
  command! -nargs=* -bang FGrep       call qfixgrep#QFixCmdGrep('FGrep',  <q-args>)
  command! -nargs=* -bang RGrep       call qfixgrep#QFixCmdGrep('RGrep',  <q-args>)
  command! -nargs=* -bang REGrep      call qfixgrep#QFixCmdGrep('RGrep',  <q-args>)
  command! -nargs=* -bang RFGrep      call qfixgrep#QFixCmdGrep('RFGrep', <q-args>)

  command! -nargs=* -bang Grepadd     call qfixgrep#QFixCmdGrep('Grepadd',   <q-args>)
  command! -nargs=* -bang EGrepadd    call qfixgrep#QFixCmdGrep('Grepadd',   <q-args>)
  command! -nargs=* -bang FGrepadd    call qfixgrep#QFixCmdGrep('FGrepadd',  <q-args>)
  command! -nargs=* -bang RGrepadd    call qfixgrep#QFixCmdGrep('RGrepadd',  <q-args>)
  command! -nargs=* -bang REGrepadd   call qfixgrep#QFixCmdGrep('RGrepadd',  <q-args>)
  command! -nargs=* -bang RFGrepadd   call qfixgrep#QFixCmdGrep('RFGrepadd', <q-args>)
endif

call qfixgrep#init()

