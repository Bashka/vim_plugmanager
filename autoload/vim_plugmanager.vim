" Date Create: 2015-03-05 11:26:34
" Last Change: 2015-06-07 20:28:46
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:File = vim_lib#base#File#
let s:System = vim_lib#sys#System#.new()

let g:vim_plugmanager#._installedPlugins = []

"" {{{
" Метод подключает все установленные плагины с помощью команды Plugin в конеце файла plugins.vim
"" }}}
function! vim_plugmanager#_enableInstalledPlugins(level) " {{{
  let s:plugsFile = s:File.absolute(a:level . s:File.slash . 'plugins.vim')
  if !s:plugsFile.isFile()
    call s:plugsFile.create()
  endif

  for l:plug in g:vim_plugmanager#._installedPlugins
    call s:plugsFile.write("Plugin '" . l:plug . "'")
  endfor
endfunction " }}}

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
" Плагин не будет установлен, если он уже подключен.
" Важно помнить, что установка плагина с помощью данного метода требует дальнейшего подключения его с помощью команды Plugin.
" @param string level Уровень загрузки, для которого будет устанавливаться плагин.
" @param string name Имя плагина в формате логин/имя для репозитория GitHub.
"" }}}
function! vim_plugmanager#install(level, name) " {{{
  let l:realname = strpart(a:name, stridx(a:name, '/') + 1)
  if vim_lib#sys#Autoload#isPlug(l:realname)
    return 0
  endif

  " Создание каталога для плагина
  let l:levels = g:vim_lib#sys#Autoload#levels
  let l:plugdir = s:File.absolute(a:level . s:File.slash . l:levels[a:level]['plugdir'] . s:File.slash . l:realname)
  if !l:plugdir.isDir()
    call l:plugdir.createDir()
  endif

  " Копирование плагина
  call s:System.exe('git clone --recursive https://github.com/' . a:name . ' ' . l:plugdir.getAddress())

  " Индексация документации
  let l:doc = l:plugdir.getChild('doc')
  if l:doc.isDir()
    exe 'helptags ' . l:doc.getAddress()
  endif

  call add(l:levels[a:level]['plugins'], l:realname)
  call insert(g:vim_plugmanager#._installedPlugins, l:plugdir.getName())

  " Разрешение зависимостей
  let l:pluginInfoFile = l:plugdir.getChild('plugman.vim')
  if l:pluginInfoFile.isExists() && l:pluginInfoFile.isFile()
    exe 'let l:pluginInfo = ' . join(l:pluginInfoFile.read(), '')
    if has_key(l:pluginInfo, 'requires')
      for [l:usedPlug, l:usedVersion] in items(l:pluginInfo['requires'])
        call vim_plugmanager#install(a:level, l:usedPlug)
      endfor
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
  endif
endfunction " }}}
