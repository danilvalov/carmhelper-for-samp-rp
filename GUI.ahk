;;
;; GUI for CarmHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

#NoEnv
#SingleInstance Force

#Include scripts\ConfigReader.ahk

DetectHiddenWindows, On


class CarmHelperGui
{
  windowTitle := "��������� - CarmHelper.ahk"

  windowWidth := 900
  windowHeight := 700
  LabelWidth := 500

  plugins := {}

  __hasValueInArray(Array, Value)
  {

    for Key, Val in Array {
      if (Val = Value) {
        Return Key
      }
    }

    Return 0
  }

  __stringJoin(Array, Delimiter = ";")
  {
    Result =
    Loop
      If Not Array[A_Index] Or Not Result .= (Result ? Delimiter : "") Array[A_Index]
        Return Result
  }

  trayMenuGeneration()
  {
    Menu, Tray, NoStandard
    Menu, Tray, Add, CarmHelper, SettingsGuiOpen
    Menu, Tray, Disable, CarmHelper
    Menu, Tray, Add
    Menu, Tray, Add, �������������, ScriptReload
    Menu, Tray, Add, ���������, SettingsGuiOpen
    Menu, Tray, Default, ���������
    Menu, Tray, Add
    Menu, Tray, Add, �����, AppExit

    Return
  }

  guiGeneration()
  {
    Gui, Settings:New

    Gui, Settings:Default

    Gui, Settings:+LastFound

    this.pluginsViewGeneration()

    this.userBindsGeneration()

    Gui, Settings:Tab

    Gui, Settings:Add, Button, x10 gGuiSave, ���������

    Gui, Settings:Add, Button, x+5 gSettingsGuiClose, ��������

    Gui, Settings:Show, , % this.windowTitle

    Return WinExist()
  }

  modulesListRead()
  {
    Loop, Files, modules\*.*, D
    {
      If (FileExist("modules\" A_LoopFileName "\Meta.ini")) {
        this.modules[A_LoopFileName] := {}

        this.modules[A_LoopFileName]["About"] := ConfigReader.readIniSection("modules\" A_LoopFileName "\Meta.ini", "About")
        this.modules[A_LoopFileName]["Config"] := ConfigReader.readIniSection("modules\" A_LoopFileName "\Meta.ini", "Config")
        this.modules[A_LoopFileName]["Options"] := ConfigReader.readIniSection("modules\" A_LoopFileName "\Meta.ini", "Options")
      }
    }

    Return
  }

  pluginsListRead()
  {
    Global Config

    Loop, Files, plugins\*.*, D
    {
      If (FileExist("plugins\" A_LoopFileName "\Meta.ini")) {
        this.plugins[A_LoopFileName] := {}

        this.plugins[A_LoopFileName]["About"] := ConfigReader.readIniSection("plugins\" A_LoopFileName "\Meta.ini", "About")
        this.plugins[A_LoopFileName]["Config"] := ConfigReader.readIniSection("plugins\" A_LoopFileName "\Meta.ini", "Config")
        this.plugins[A_LoopFileName]["Options"] := ConfigReader.readIniSection("plugins\" A_LoopFileName "\Meta.ini", "Options")
        this.plugins[A_LoopFileName]["Enabled"] := !!this.__hasValueInArray(Config["EnabledPlugins"], A_LoopFileName)
      }
    }

    Return
  }

  pluginsViewGeneration()
  {
    this.modulesListRead()
    this.pluginsListRead()

    TabString := "�������|������"
    TabString := this.tabListGenerator(TabString)

    TabWidth := this.windowWidth - 20
    TabHeight := this.windowHeight - 40
    this.LabelWidth := TabWidth - 35
    Gui, Settings:Add, Tab2, w%TabWidth% h%TabHeight%, %TabString%

    this.modulesTabsGeneration()

    this.pluginsListGeneration()

    this.pluginsTabsGeneration()

    Return
  }

  modulesTabsGeneration()
  {
    Global Config

    LabelWidth := this.LabelWidth

    For ModuleName, ModuleVariableObject in Config["modules"] {
      ModuleDescription := this.modules[ModuleName]["About"]["Description"]
      Gui, Settings:Tab, %ModuleName%, , Exact
      Gui, Settings:Font, Bold
      Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+15, %ModuleName%
      Gui, Settings:Font
      Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+10, %ModuleDescription%

      For VariableName, VariableValue in ModuleVariableObject {
        VariableDescription := StrSplit(this.modules[ModuleName]["Options"][VariableName], "|")[2]

        this.inputGeneration("Module" ModuleName VariableName, VariableValue, VariableDescription, LabelWidth)
      }
    }

    Return
  }

  pluginsListGeneration()
  {
    Global
    Local LabelWidth := this.LabelWidth

    Gui, Settings:Tab, 1

    Local PluginName, PluginData

    For PluginName, PluginData in this.plugins {
        Local PluginStatus := PluginData["Enabled"]
        Local PluginDescription := PluginData["About"]["Description"]
        Gui, Settings:Add, Checkbox, +Wrap w%LabelWidth% y+15 vGuiPlugin%PluginName%Status checked%PluginStatus%, %PluginName% - %PluginDescription%
    }

    Return
  }

  pluginsTabsGeneration()
  {
    Global Config

    LabelWidth := this.LabelWidth

    For PluginName, PluginVariableObject in Config["plugins"] {
      if (this.plugins[PluginName]["Enabled"]) {
        PluginDescription := this.plugins[PluginName]["About"]["Description"]
        Gui, Settings:Tab, %PluginName%, , Exact
        Gui, Settings:Font, Bold
        Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+15, %PluginName%
        Gui, Settings:Font
        Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+10, %PluginDescription%

        For VariableName, VariableValue in PluginVariableObject {
          VariableDescription := StrSplit(this.plugins[PluginName]["Options"][VariableName], "|")[2]

          this.inputGeneration("Plugin" PluginName VariableName, VariableValue, VariableDescription)
        }
      }
    }

    Return
  }

  inputGeneration(VariableName, VariableValue, VariableDescription)
  {
    Global
    Local LabelWidth := this.LabelWidth

    if (SubStr(VariableName, -2) = "Key") {
      Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+15, %VariableDescription%:
      Gui, Settings:Add, Hotkey, w150 vGui%VariableName%Input y+5, %VariableValue%
    } else if (SubStr(VariableName, -6) = "Boolean") {
      if (SubStr(VariableDescription, 1, 4) = "1 - ") {
        VariableDescription := SubStr(VariableDescription, 5)
      }
      Gui, Settings:Add, Checkbox, +Wrap w%LabelWidth% y+15 vGui%VariableName%Input checked%VariableValue%, %VariableDescription%
    } else if (SubStr(VariableName, -3) = "File") {
       Local TextAreaWidth := this.windowWidth - 45
       Local TextAreaRowsCount := (this.windowHeight - 170) / 14
       Local FileContents
       FileRead, FileContents, %VariableValue%
       Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+15, %VariableDescription%:
       Gui, Settings:Add, Edit, r%TextAreaRowsCount% w%TextAreaWidth% vGui%VariableName%Input, %FileContents%
     } else {
      Gui, Settings:Add, Text, +Wrap w%LabelWidth% y+15, %VariableDescription%:
      if (StrLen(VariableValue) >= 10 || StrLen(VariableValue) = 0) {
        Gui, Settings:Add, Edit, w%LabelWidth% vGui%VariableName%Input y+5, %VariableValue%
      } else {
        Gui, Settings:Add, Edit, w150 vGui%VariableName%Input y+5, %VariableValue%
      }
    }

    Return
  }

  tabListGenerator(TabString)
  {
    Global Config

    For ModuleName, ModuleVariable in Config["modules"] {
      TabString := TabString "|" ModuleName
    }

    For PluginName, PluginVariables in Config["plugins"] {
      if (this.plugins[PluginName]["Enabled"]) {
        TabString := TabString "|" PluginName
      }
    }

    Return TabString
  }

  userBindsGeneration()
  {
    Global

    Gui, Settings:Tab, 2

    Local UserBindsWidth := this.windowWidth - 45
    Local UserBindsRowsCount := (this.windowHeight - 60) / 14
    Local FileContents
    FileRead, FileContents, UserBinds.ahk
    Gui, Settings:Add, Edit, r%UserBindsRowsCount% w%UserBindsWidth% vGuiUserBindsInput, %FileContents%

    Gui, Settings:Tab

    Return
  }

  changeKeyboardLayoutToDefault()
  {
    RegRead, DefaultKeyboardLayout , HKEY_CURRENT_USER, Keyboard Layout\Preload, 1
    DefaultKeyboardLayout := DllCall("LoadKeyboardLayout", "Str", DefaultKeyboardLayout , "Int", 1)
    PostMessage, 0x50, 0, %DefaultKeyboardLayout%, , ahk_id %A_ScriptHWND%
    SendMessage, 0x50,, %DefaultKeyboardLayout%, , ahk_id %A_ScriptHWND%

    Return
  }

  dataUpdate()
  {
    Global Config

    this.changeKeyboardLayoutToDefault()

    For ModuleName, ModuleVariableObject in Config["modules"] {
      For ModuleVariableName, ModuleVariableData in ModuleVariableObject {
        ModuleVariableInputName = GuiModule%ModuleName%%ModuleVariableName%Input
        GuiControlGet, %ModuleVariableInputName%, Settings:
        ModuleVariableInputValue := %ModuleVariableInputName%

        if (SubStr(ModuleVariableName, -3) <> "File") {
          Config["modules"][ModuleName][ModuleVariableName] := ModuleVariableInputValue
        } else {
          this.textAreaSave(ModuleVariableData, ModuleVariableInputValue)
        }
      }
    }

    For PluginName, PluginVariableObject in this.plugins {
      GuiControlGet, GuiPlugin%PluginName%Status, Settings:

      this.plugins[PluginName]["Status"] := GuiPlugin%PluginName%Status
    }

    For PluginName, PluginVariableObject in Config["plugins"] {
      For PluginVariableName, PluginVariableData in PluginVariableObject {
        PluginVariableInputName = GuiPlugin%PluginName%%PluginVariableName%Input
        GuiControlGet, %PluginVariableInputName%, Settings:
        PluginVariableInputValue := %PluginVariableInputName%

        if (SubStr(PluginVariableName, -3) <> "File") {
          Config["plugins"][PluginName][PluginVariableName] := PluginVariableInputValue
        } else {
          this.textAreaSave(PluginVariableData, PluginVariableInputValue)
        }
      }
    }

    this.pluginsStatusesSave()

    this.configSave()

    this.userBindsSave()

    Return
  }

  pluginsStatusesSave()
  {
    Global Config

    EnabledPlugins := []

    For PluginName, PluginData in this.plugins {
      If (PluginData["Status"]) {
        EnabledPlugins.Insert(PluginName)
      }
    }

    Config["EnabledPlugins"] := EnabledPlugins

    Return
  }

  saveOption(OptionName, OptionValue, OptionType, OptionPath)
  {
    if (OptionType = "Array") {
      OptionType := "REG_MULTI_SZ"
    } else if (OptionType = "Number") {
      OptionType := "REG_DWORD"
    } else {
      OptionType := "REG_SZ"
    }

    if (!OptionPath) {
      OptionPath := ""
    } else {
      OptionPath := "\" OptionPath
    }

    RegWrite, % OptionType, % "HKEY_CURRENT_USER\Software\CarmHelper" OptionPath, % OptionName, % OptionValue

    Return
  }

  configSave()
  {
    Global Config

    this.saveOption("EnabledPlugins", this.__stringJoin(Config["EnabledPlugins"], "`n"), "Array", "")

    For ModuleName, ModuleVariablesData in Config["modules"] {
      For ModuleVariableName, ModuleVariableValue in ModuleVariablesData {
        this.saveOption(ModuleVariableName, ModuleVariableValue, "String", "modules\" ModuleName)
      }
    }

    Loop, % Config["EnabledPlugins"].MaxIndex()
    {
      PluginName := Config["EnabledPlugins"][A_Index]
      PluginVariablesData := Config["plugins"][PluginName]

      For PluginVariableName, PluginVariableValue in PluginVariablesData {
        this.saveOption(PluginVariableName, PluginVariableValue, "String", "plugins\" PluginName)
      }
    }

    Return
  }

  textAreaSave(File, Value)
  {
    FileDelete, .cache\%File%.tmp

    FileAppend, % Value, .cache\%File%.tmp
    FileCopy, .cache\%File%.tmp, %File%, 1
    FileDelete, .cache\%File%.tmp

    Return
  }

  userBindsSave()
  {
    FileDelete, .cache\UserBinds.ahk.tmp

    GuiControlGet, GuiUserBindsInput, Settings:
    FileAppend, %GuiUserBindsInput%, .cache\UserBinds.ahk.tmp
    FileCopy, .cache\UserBinds.ahk.tmp, UserBinds.ahk, 1
    FileDelete, .cache\UserBinds.ahk.tmp

    Return
  }

  guiClose()
  {
    Gui, Settings:Destroy

    Return
  }

  open()
  {
    IfWinExist, % this.windowTitle
    {
      WinActivate
    } else {
      this.guiGeneration()
    }

    Return
  }

  done()
  {
    Gui, Settings:Submit, NoHide

    this.dataUpdate()

    FullPath := A_ScriptFullPath

    If (SubStr(FullPath, -(StrLen(".cache\CarmHelper.ahk") - 1)) = ".cache\CarmHelper.ahk") {
      FullPath := "CarmHelper.ahk"
    }

    If (FileExist(".cache\CarmHelper.ahk")) {
      FileDelete, .cache\CarmHelper.ahk
    }

    Run "%A_AhkPath%" /r "%FullPath%" /saved
    ExitApp

    Return
  }
}

CarmHelperGui := new CarmHelperGui()

CurrentAttribute = %1%
if (CurrentAttribute = "/saved") {
  if (A_ScriptName = "CarmHelper.ahk") {
    CarmHelperGui.trayMenuGeneration()
  }

  CarmHelperGui.open()

  MsgBox, �������� ������ ��������� �������.`n����� ��������� ��� ���������.
} else if (A_ScriptName <> "CarmHelper.ahk") {
  CarmHelperGui.open()
} else {
  CarmHelperGui.trayMenuGeneration()

  if (!Config["FirstLaunch"]) {
    CarmHelperGui.saveOption("FirstLaunch", "1", "Number", "")
    CarmHelperGui.open()

    MsgBox, ��� ������������ CarmHelper.ahk`n- ������� ������� ��� ������ � ��������� LVa SAMP-RP.`n`n������ ����� ���������� ��������� ��������� �������.`n��� ����� ������� ����� ���� ���� ���, � ������ ��� ���������`n����� ����������� �� ���������� �������������.`n`n����� �� ������ ��������/��������� �������, ������ �� ���������.`n`n����� ����� � ���� �������� � �������, ������ �������� 2 ����`n�� ������ ������ CarmHelper'� ������ ����� � ���� (����� � ������).
  }
}

Return

SettingsGuiOpen:
{
  CarmHelperGui.open()

  Return
}

GuiSave:
{
  CarmHelperGui.done()

  Return
}

ButtonCancel:
SettingsGuiClose:
{
  if (A_ScriptName <> "CarmHelper.ahk") {
    ExitApp
  } else {
    CarmHelperGui.guiClose()
  }

  Return
}

ScriptReload:
{
  Run "%A_AhkPath%" CarmHelper.ahk
  ExitApp

  Return
}

AppExit:
{
  ExitApp

  Return
}
