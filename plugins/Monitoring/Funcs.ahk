;;
;; Monitoring Plugin for CarmHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class Monitoring
{
  _shippingToHundred := 97
  _messageFormat := "/r [Мониторинг] ЛСПД - %LSPD% | СФПД - %SFPD% | ЛВПД - %LVPD% | ФБР - %FBI% |  СФа - %SFA%"
  _factions := ["LSPD", "LVPD", "SFPD", "SFA", "FBI"]
  _factionsKeywords := {}
  _warehouseStatuses := {}
  _punctuationList := ["|", "\", "/", ".", ","]

  __strToLower(String)
  {
    StringLower, String, String

    Return String
  }

  checkRadioMessage(MessageString)
  {
    Return RegExMatch(MessageString, "^\s(Рядовой|Ефрейтор|Мл.сержант|Сержант|Ст.сержант|Старшина|Прапорщик|Мл.Лейтенант|Лейтенант|Ст.Лейтенант|Капитан|Майор|Подполковник|Полковник|Генерал)\s\s[a-zA-Z0-9\_]{3,20}:\s\s")
  }

  readFactionKeywords()
  {
    Global Config

    For FactionIndex, FactionName in this._factions {
      ConfigKeywordsString := Config["plugins"]["Monitoring"]["Keywords" FactionName]

      if (StrLen(ConfigKeywordsString)) {
        ConfigKeywordsArray := StrSplit(ConfigKeywordsString, ",")

        For ConfigKeywordIndex, ConfigKeyword in ConfigKeywordsArray {
          this._factionsKeywords[this.__strToLower(ConfigKeyword)] := FactionName
        }
      }
    }

    Return
  }

  readShippingToHundred()
  {
    Global Config

    ShippingToHundred := Config["plugins"]["Monitoring"]["ShippingToHundred"]
    ShippingToHundred := RegExReplace(ShippingToHundred, "[^0-9]", "")

    if (StrLen(ShippingToHundred)) {
      this._shippingToHundred := ShippingToHundred
    }

    Return
  }

  readMessageFormat()
  {
    Global Config

    MessageFormat := Config["plugins"]["Monitoring"]["MessageFormat"]

    if (StrLen(MessageFormat)) {
      this._messageFormat := MessageFormat
    }

    Return
  }

  clear(Data)
  {
    Chatlog.reader()

    this._factionsWarehousesStatus := {}

    Return
  }

  warehousesChecker(MessageSource)
  {
    for FactionKeyword, FactionName in this._factionsKeywords {
      MessageString := MessageSource
      IsMonitoring := False
      Cargo := ""

      if (FactionKeyword <> "" && FactionName <> "") {
        if (InStr(this.__strToLower(MessageString), FactionKeyword) > 0) {
          if ((InStr(this.__strToLower(MessageString), "код") == 0 && InStr(this.__strToLower(MessageString), "жетон") == 0 && (this.checkRadioMessage(MessageString) || SubStr(MessageString, 1, 2) == "- ") || SubStr(MessageString, 1, 5) == " SMS:" || InStr(MessageString, " шепнул(а): ") > 0)) {
            if (this.checkRadioMessage(MessageString))
              MessageString := Trim(SubStr(MessageString, InStr(MessageString, ":") + 2))
            if (InStr(this.__strToLower(MessageString), "мониторинг") <> 0)
              IsMonitoring := True
            if (SubStr(MessageString, 1, 1) = "[")
              MessageString := SubStr(MessageString, InStr(MessageString, "]") + 1)
            if (SubStr(MessageString, 1, 2) = "- ")
              MessageString := SubStr(MessageString, 3, StrLen(MessageString))
            if (InStr(MessageString, " шепнул(а): ") > 0)
              MessageString := SubStr(MessageString, InStr(MessageString, ": ") + 1)
            if (SubStr(MessageString, 1, 5) = " SMS:") {
              MessageString := SubStr(MessageString, 7)
              MessageString := SubStr(MessageString, 1, InStr(MessageString, "Отправитель") - 3)
            }

            LeftMessage := SubStr(MessageString, 1, InStr(this.__strToLower(MessageString), FactionKeyword) - 1)
            RightMessage := SubStr(MessageString, InStr(this.__strToLower(MessageString), FactionKeyword) + StrLen(FactionKeyword) + 1)

            if (RegExMatch(RightMessage, "(\d){2,6}")) {
              for PunctuationKey, PunctuationValue in this._punctuationList {
                if (InStr(RightMessage, PunctuationValue) <> 0)
                  RightMessage := SubStr(RightMessage, 1, InStr(RightMessage, PunctuationValue) - 1)
              }

              RegExMatch(RightMessage, "(\d){2,6}", RightMatchResult)
              if (RightMatchResult <> "") {
                Cargo := RightMatchResult
              }
            } else if (RegExMatch(LeftMessage, "(\d){2,6}")) && (!IsMonitoring) {
              for PunctuationKey, PunctuationValue in this._punctuationList {
                if (InStr(LeftMessage, PunctuationValue) > 1)
                  LeftMessage := SubStr(LeftMessage, InStr(LeftMessage, PunctuationValue) - 1)
              }

              StartPos = 1
              LeftMatchResult =

              Loop
              {
                if (!RegExMatch(LeftMessage, "(\d){2,6}", MatchResult, StartPos))
                	Break
                LeftMatchResult := MatchResult
                StartPos := StrLen(MatchResult) + InStr(LeftMessage, MatchResult, StartPos + StrLen(MatchResult))
              }

              if (LeftMatchResult <> "") {
                Cargo := LeftMatchResult
              }
            }

            if (Cargo == "00") OR (Cargo == "000") {
              this._warehouseStatuses[FactionName] := ""
            } else if (Cargo > 0) {
              if (Cargo <= 100) || (Cargo >= 10000) {
                if (Cargo >= 10000)
                  Cargo := Round(Cargo / 1000)
                if (Cargo >= this._shippingToHundred)
                  Cargo = 100
                this._warehouseStatuses[FactionName] := Cargo
              }
            }
          }
        }
      }
    }
  }

  sendMonitoring()
  {
    Chatlog.reader()

    LSPD := Monitoring._warehouseStatuses["LSPD"]
    SFPD := Monitoring._warehouseStatuses["SFPD"]
    LVPD := Monitoring._warehouseStatuses["LVPD"]
    FBI := Monitoring._warehouseStatuses["FBI"]
    SFA := Monitoring._warehouseStatuses["SFA"]

    IsSending := StrLen(LSPD) || StrLen(SFPD) || StrLen(LVPD) || StrLen(FBI) || StrLen(SFA)

    Message := this._messageFormat
    Message := StrReplace(Message, "%LSPD%", LSPD)
    Message := StrReplace(Message, "%SFPD%", SFPD)
    Message := StrReplace(Message, "%LVPD%", LVPD)
    Message := StrReplace(Message, "%FBI%", FBI)
    Message := StrReplace(Message, "%SFA%", SFA)

    if (!IsSending) {
      addMessageToChatWindow("{FFFF00}Данные по складам не найдены в чате. Но вы можете ввести их вручную:")
    }

    sendChatSavingMessage(Message, IsSending)

    Return
  }

  init()
  {
    this.readFactionKeywords()
    this.readShippingToHundred()
    this.readMessageFormat()

    Return
  }
}

Monitoring := new Monitoring()

CMD.commands["mclear"] := "Monitoring.clear"
CMD.commands["monitor"] := "Monitoring.sendMonitoring"
CMD.commands["monitoring"] := "Monitoring.sendMonitoring"

MonitoringChatlogChecker(ChatlogString)
{
  Monitoring.warehousesChecker(ChatlogString)
}

Chatlog.checker.Insert("MonitoringChatlogChecker")

HotKeyRegister(Config["plugins"]["Monitoring"]["Key"], "MonitoringHotKey")
HotKeyRegister(Config["plugins"]["Monitoring"]["ClearKey"], "MonitoringClearHotKey")

Monitoring.init()
