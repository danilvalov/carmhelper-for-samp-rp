;;
;; Updater for CarmHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

#NoEnv
#SingleInstance Force

#Include libraries\JSON.ahk
#Include libraries\Zip.ahk
#Include scripts\ConfigReader.ahk

DetectHiddenWindows, On

FirstAttribute = %1%

class Updater
{
  GetUpdateDir(FullPathToProjectDir) {
    Loop, Files, % FullPathToProjectDir ".cache\updateDir\*.*", D
    {
      Return FullPathToProjectDir ".cache\updateDir\" A_LoopFileName
    }

    Return False
  }

  UpdateDir(FullPathToProjectDir) {
    UpdateDirPath := this.GetUpdateDir(FullPathToProjectDir)

    Loop, Files, % UpdateDirPath "\*.*", FD
    {
      if A_LoopFileAttrib contains D
      {
        FileCopyDir, % UpdateDirPath "\" A_LoopFileName, % FullPathToProjectDir "\" A_LoopFileName, 1
      } else {
        if A_LoopFileName not contains UserBinds.ahk,.gitignore
        {
          FileCopy, % UpdateDirPath "\" A_LoopFileName, % FullPathToProjectDir "\" A_LoopFileName, 1
        }
      }
    }

    Return
  }

  RemoveOldVersion() {
    Loop, Files, % UpdateDirPath "\*.*", FD
    {
      if A_LoopFileAttrib contains D
      {
        if A_LoopFileName not contains .cache
        {
          FileRemoveDir, %A_LoopFileName%, 1
        }
      } else {
        if A_LoopFileName not contains UserBinds.ahk
        {
          FileDelete, %A_LoopFileName%
        }
      }
    }

    Return
  }

  Update() {
    FullPathToProjectDir := SubStr(A_ScriptFullPath, 1, -StrLen(".cache\Updater.ahk"))

    IfWinExist, % FullPathToProjectDir ".cache\CarmHelper.ahk"
    {
      WinClose, % FullPathToProjectDir ".cache\CarmHelper.ahk ahk_class AutoHotkey"
    }

    FileRead, Repository_JSON, *P65001 .cache\repository.json
    FileDelete, .cache\repository.json
    Repository_Data := JSON.parse(Repository_JSON)

    FileRemoveDir, .cache\updateDir, 1

    UrlDownloadToFile, % Repository_Data["zipball_url"], .cache\update.zip

    this.RemoveOldVersion()

    Unz(FullPathToProjectDir ".cache\update.zip", FullPathToProjectDir ".cache\updateDir")

    this.UpdateDir(FullPathToProjectDir)

    NextFullPath := FullPathToProjectDir "Updater.ahk"
    Run %NextFullPath% /updated

    ExitApp

    Return
  }

  Updated() {
    Global Config

    FileRemoveDir, .cache, 1

    MsgBox, % "CarmHelper ������� ������� �� ������ " Config["About"]["Version"] " (" Config["About"]["LastUpdate"] ").`n������ ��������� �����������.`n`n����� ������� ������ ""OK"" ���������� CarmHelper."

    Run CarmHelper.ahk

    ExitApp

    Return
  }

  CheckUpdate() {
    Global Config

    UrlDownloadToFile, % Config["RepositoryUrl"], .cache\repository.json
    FileRead, Repository_JSON, *P65001 .cache\repository.json
    Repository_Data := JSON.parse(Repository_JSON)

    if (Config["About"]["Version"] < Repository_Data["tag_name"]) {
      MsgBox, 4, , % "�������� ���������� CarmHelper.ahk:`n������: " Repository_Data["tag_name"] ".`n`n��� ������:`n`n" StrReplace(Repository_Data["body"], "\r\n", "`n") "`n`n�� ������� ���������� ����� ������?"
      IfMsgBox, Yes
      {
        FileCopy, Updater.ahk, .cache\Updater.ahk, 1
        Run .cache\Updater.ahk
        ExitApp
        Return
      }
    }

    FileDelete, .cache\repository.json
    Return
  }

  __New() {
    Global FirstAttribute

    Sleep 100

    if (SubStr(A_ScriptFullPath, -(StrLen(".cache\Updater.ahk") - 1)) = ".cache\Updater.ahk") {
      this.Update()
    } else if (FirstAttribute = "/updated") {
      this.Updated()
    } else {
      this.CheckUpdate()
    }

    Return
  }
}

Updater := new Updater()
