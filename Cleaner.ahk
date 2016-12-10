;;
;; Cleaner for CarmHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

#UseHook
#NoEnv
#SingleInstance force
#Include %A_ScriptDir%
SetWorkingDir %A_ScriptDir%

DetectHiddenWindows, On

IsOpened := 0

IfWinExist, % A_ScriptDir "\.cache\CarmHelper.ahk"
{
  IsOpened := 1
  WinClose, % A_ScriptDir "\.cache\CarmHelper.ahk ahk_class AutoHotkey"
}

FileRemoveDir, .cache, 1

RegDelete, HKEY_CURRENT_USER\Software\CarmHelper

MsgBox, Все настройки CarmHelper.ahk были сброшены на настройки по-умолчанию.

if (IsOpened) {
  Run CarmHelper.ahk
}
