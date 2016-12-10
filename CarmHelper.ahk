;;
;; CarmHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

#UseHook
#NoEnv
#SingleInstance force
#Include %A_ScriptDir%
SetWorkingDir %A_ScriptDir%


; VersionChecker

#Include %A_ScriptDir%\scripts\VersionChecker.ahk

#Include %A_ScriptDir%\Updater.ahk

#Include %A_ScriptDir%\scripts\ConfigReader.ahk

If (FileExist(".cache\CarmHelper.ahk")) {
	Run .cache\CarmHelper.ahk %1%
	ExitApp
	Return
}

CarmHelper := {}
CarmHelper["Modules"] := []
CarmHelper["Plugins"] := []

Loop, Files, %A_ScriptDir%\modules\*.*, D
{
  CarmHelper["Modules"].Insert(A_LoopFileName)
}

Loop, % Config["EnabledPlugins"].MaxIndex()
{
  CarmHelper["Plugins"].Insert(Config["EnabledPlugins"][A_Index])
}


MergedFile =

MergedFile .= "#UseHook`n"
MergedFile .= "#NoEnv`n"
MergedFile .= "#IfWinActive GTA:SA:MP`n"
MergedFile .= "#SingleInstance force`n"
MergedFile .= "#Include " A_ScriptDir "`n"
MergedFile .= "SetWorkingDir " A_ScriptDir "`n"

MergedFile .= "`n`n`;`; Configs`n`n"
MergedFile .= "#Include scripts\ConfigReader.ahk`n"

MergedFile .= "`n`n`;`; Libraries`n`n"

Loop, Files, %A_ScriptDir%\libraries\*.ahk, F
{
  MergedFile .= "#Include libraries\" A_LoopFileName "`n"
}

MergedFile .= "`n`n`;`; Modules Funcs`n`n"

Loop, % CarmHelper["Modules"].MaxIndex()
{
  ModuleName := CarmHelper["Modules"][A_Index]

  If (FileExist(A_ScriptDir "\modules\" ModuleName "\Funcs.ahk")) {
    MergedFile .= "#Include modules\" ModuleName "\Funcs.ahk`n"
  }
}

MergedFile .= "`n`n`;`; Plugins Funcs`n`n"

Loop, % CarmHelper["Plugins"].MaxIndex()
{
  PluginName := CarmHelper["Plugins"][A_Index]

  If (FileExist(A_ScriptDir "\plugins\" PluginName "\Funcs.ahk")) {
    MergedFile .= "#Include plugins\" PluginName "\Funcs.ahk`n`n"
  }
}

MergedFile .= "`n`n`;`; GUI`n`n"
MergedFile .= "#Include GUI.ahk`n"

MergedFile .= "`n`n`;`; Modules Binds`n`n"

Loop, % CarmHelper["Modules"].MaxIndex()
{
  ModuleName := CarmHelper["Modules"][A_Index]

  If (FileExist(A_ScriptDir "\modules\" ModuleName "\Binds.ahk")) {
    MergedFile .= "#Include modules\" ModuleName "\Binds.ahk`n`n"
  }
}

MergedFile .= "`n`n`;`; Binds`n`n"

MergedFile .= "#Include *i UserBinds.ahk`n"

MergedFile .= "`n`nReturn`n`n"

MergedFile .= "`n`n`;`; Modules Labels`n`n"

Loop, % CarmHelper["Modules"].MaxIndex()
{
  ModuleName := CarmHelper["Modules"][A_Index]

  If (FileExist(A_ScriptDir "\modules\" ModuleName "\Labels.ahk")) {
    MergedFile .= "#Include modules\" ModuleName "\Labels.ahk`n`n"
  }
}

MergedFile .= "`n`n`;`; Plugins Labels`n`n"

Loop, % CarmHelper["Plugins"].MaxIndex()
{
  PluginName := CarmHelper["Plugins"][A_Index]

  If (FileExist(A_ScriptDir "\plugins\" PluginName "\Labels.ahk")) {
    MergedFile .= "#Include plugins\" PluginName "\Labels.ahk`n`n"
  }
}

FileAppend, %MergedFile%`n, .cache\CarmHelper.ahk

Sleep 1000

Run .cache\CarmHelper.ahk %1%
