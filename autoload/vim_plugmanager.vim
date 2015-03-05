" Date Create: 2015-03-05 11:26:34
" Last Change: 2015-03-06 00:15:40
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:File = vim_lib#base#File#
let s:System = vim_lib#sys#System#.new()

"" {{{
" Метод формирует список установленных и подключенных плагинов.
"" }}}
function! vim_plugmanager#plugList() " {{{
  let l:screen = g:vim_plugmanager#PlugList#
  if l:screen.getWinNum() != -1
    " Закрыть окно, если оно уже открыто.
    call l:screen.unload()
  else
    call l:screen.gactive('t')
  endif
endfunction " }}}

"" {{{
" Метод пытается установить заданный плагин.
" @param string level Уровень загрузки, для которого будет устанавливаться плагин.
" @param string name Имя плагина. Форматы имен для репозиториев: github.com - логин/имя.
" @param string repository Имя используемого репозитория.
"" }}}
function! vim_plugmanager#install(level, name, repository) " {{{
  let l:levels = g:vim_lib#sys#Autoload#levels
  " Определение каталога плагина. {{{
  if a:repository == 'github.com'
    let l:realname = strpart(a:name, stridx(a:name, '/') + 1)
    let l:plugdir = s:File.absolute(a:level . s:File.slash . l:levels[a:level]['plugdir'] . s:File.slash . l:realname)
  else
    let l:plugdir = s:File.absolute(a:level . s:File.slash . l:levels[a:level]['plugdir'] . s:File.slash . a:name)
  endif
  " }}}

  if !l:plugdir.isDir()
    if a:repository == 'github.com'
      call l:plugdir.createDir()
      call s:System.exe('git clone --recursive https://github.com/' . a:name . ' ' . l:plugdir.getAddress())
      let l:doc = l:plugdir.getChild('doc')
      if l:doc.isDir()
        exe 'helptags ' . l:doc.getAddress()
      endif
      call add(l:levels[a:level]['plugins'], l:realname)
      call s:System.echo('Enable plugin in your file .vimrc|_vimrc')
    else
      " Реализация других репозиториев.
    endif
  endif
endfunction " }}}

"" {{{
" Метод пытается удалить заданный плагин.
" @param string level Уровень загрузки, из которого будет удаляться плагин.
" @param string name Имя плагина.
"" }}}
function! vim_plugmanager#delete(level, name) " {{{
  let l:levels = g:vim_lib#sys#Autoload#levels
  let l:plugdir = s:File.absolute(a:level . s:File.slash . l:levels[a:level]['plugdir'] . s:File.slash . a:name)
  if l:plugdir.isDir()
    call l:plugdir.deleteDir()
    call remove(l:levels[a:level]['plugins'], index(l:levels[a:level]['plugins'], a:name))
    call s:System.echo('Disable plugin in your file .vimrc|_vimrc')
  endif
endfunction " }}}
