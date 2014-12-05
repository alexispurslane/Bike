let SessionLoad = 1
if &cp | set nocp | endif
let s:so_save = &so | let s:siso_save = &siso | set so=0 siso=0
let v:this_session=expand("<sfile>:p")
silent only
cd ~/Dropbox/bike
if expand('%') == '' && !&modified && line('$') <= 1 && getline(1) == ''
  let s:wipebuf = bufnr('%')
endif
set shortmess=aoO
badd +203 runtime/bootstrap.rb
badd +29 Wheels.bk
badd +1 context.rb
badd +12 runtime/context.rb
badd +63 runtime/method.rb
badd +23 ~/.nvim/syntax/bk.vim
badd +203 interpreter.rb
badd +31 TODO.md
badd +16 lexer.rb
badd +267 grammar.y
badd +82 nodes.rb
badd +3 doc/LambdaNode.html
badd +1 ra
badd +5 runtime/object.rb
badd +1 doc/ImportNode.html
badd +1 doc/Context.html
badd +20 runtime/class.rb
badd +660 doc/DefNode.html
badd +7 runtime.rb
badd +43 bin/bike
argglobal
silent! argdel *
edit runtime/bootstrap.rb
set splitbelow splitright
wincmd t
set winheight=1 winwidth=1
argglobal
setlocal fdm=manual
setlocal fde=0
setlocal fmr={{{,}}}
setlocal fdi=#
setlocal fdl=0
setlocal fml=1
setlocal fdn=20
setlocal nofen
silent! normal! zE
let s:l = 1 - ((0 * winheight(0) + 24) / 48)
if s:l < 1 | let s:l = 1 | endif
exe s:l
normal! zt
1
normal! 0
tabnext 1
if exists('s:wipebuf')
  silent exe 'bwipe ' . s:wipebuf
endif
unlet! s:wipebuf
set winheight=1 winwidth=20 shortmess=filnxtToO
let s:sx = expand("<sfile>:p:r")."x.vim"
if file_readable(s:sx)
  exe "source " . fnameescape(s:sx)
endif
let &so = s:so_save | let &siso = s:siso_save
doautoall SessionLoadPost
let g:this_obsession = v:this_session
unlet SessionLoad
" vim: set ft=vim :
