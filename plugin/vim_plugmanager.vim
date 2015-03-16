" Date Create: 2015-03-05 11:26:01
" Last Change: 2015-03-16 18:30:47
" Author: Artur Sh. Mamedbekov (Artur-Mamedbekov@yandex.ru)
" License: GNU GPL v3 (http://www.gnu.org/copyleft/gpl.html)

let s:Plugin = vim_lib#sys#Plugin#

let s:p = s:Plugin.new('vim_plugmanager', '1')

"" {{{
" Отобразить список установленных и подключенных плагинов.
"" }}}
call s:p.menu('Plugins', 'plugList', '1')

"" {{{
" Отобразить список установленных и подключенных плагинов.
"" }}}
call s:p.comm('PlugmanagerList', 'plugList()')

call s:p.reg()
