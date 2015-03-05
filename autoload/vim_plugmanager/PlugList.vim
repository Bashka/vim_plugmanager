" Date Create: 2015-03-05 11:36:30
" Last Change: 2015-03-06 00:26:38
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:System = vim_lib#sys#System#.new()
let s:Buffer = vim_lib#sys#Buffer#
let s:Content = vim_lib#sys#Content#.new()

let s:screen = s:Buffer.new('#Plugins-list#')
call s:screen.temp()
call s:screen.option('filetype', 'plugins-list')

function! s:screen.render() " {{{
  let l:levels = vim_lib#sys#Autoload#getLevels()
  let l:result = '" Plugins list (Press ? for help) "' . "\n\n" 
  for l:level in keys(l:levels)
    let l:result .= '" ' . l:level . ' "' . "\n"
    let l:result .= join(l:levels[l:level]['plugins'], "\n")
    let l:result .= "\n\n"
  endfor
  return l:result
endfunction " }}}

call s:screen.map('n', 'a', 'install')
call s:screen.map('n', 'dd', 'delete')

function! s:screen.install() " {{{
  let l:level = g:vim_lib#sys#Autoload#currentLevel
  " Выбор репозитория. {{{
  let l:repositories = ['github.com'] " Массив поддерживаемых репозиториев.
  let l:i = 0
  for l:repository in l:repositories
    call s:System.echo(l:i . '. ' . l:repository)
    let l:i += 1
  endfor
  let l:i = s:System.read('Select repository: ')
  if l:i != ''
    let l:repository = l:repositories[l:i]
  else
    return 0
  endif
  " }}}
  let l:name = s:System.read('Enter address of the plugin github: ')
  if l:name != ''
    call vim_plugmanager#install(l:level, l:name, l:repository)
    call self.redraw()
  endif
endfunction " }}}
function! s:screen.delete() " {{{
  let l:plug = expand('<cWORD>')
  " Определение уровня плагина. {{{
  let l:n = s:Content.pos()['l']
  while l:n
    let l:line = s:Content.line(l:n)
    if l:line =~ '^"'
      let l:level = strpart(l:line, 2, len(l:line) - 4) " Удаление коментария из пути уровня.
      break
    endif
    let l:n -= 1
  endwhile
  " }}}
  if s:System.confirm('Realy delete plugin "' . l:level . '::' . l:plug . '"?')
    call vim_plugmanager#delete(l:level, l:plug)
    call self.redraw()
  endif
endfunction " }}}

call s:screen.map('n', '?', 'showHelp')
" Подсказки. {{{
let s:screen.help = ['" Manual "',
      \ '',
      \ '" a - install plugin to the current level',
      \ '" dd - delete current plugin',
      \ ''
      \]
" }}}
function! s:screen.showHelp() " {{{
  if s:Content.line(1) != self.help[0]
    let self.pos = s:Content.pos()
    call s:Content.add(1, self.help)
  else
    call self.active()
    call s:Content.pos(self.pos)
  endif
endfunction " }}}

let vim_plugmanager#PlugList# = s:screen
