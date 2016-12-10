;;
;; UnloadingReport Plugin for CarmHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class UnloadingReport
{
  _shippingToHundred := 97
  _messageFormat := "/r [Взвод №1] На складе %Warehouse% %Cargo%. %MessageEndPart%"
  _messageFormatEnd := "Возвращаюсь на базу."
  _messageFormatEndFullWithoutRemainingCargo := "Остатков нет. Возвращаюсь на базу."
  _messageFormatEndFullWithRemainingCargo := "Остатки (%RemainingCargo%) везу в ..."
  _warehouseName := ""
  _warehouseCargo := 0
  _remainingCargo := 0

  _generateNameDec(NumStr, OneItemName, TwoItemName, FiveItemName)
  {
    if ((SubStr(NumStr, StrLen(NumStr)) > 1) && (SubStr(NumStr, StrLen(NumStr)) < 5) && (!(SubStr(NumStr, StrLen(NumStr) - 1, 1) = 1))) {
      Return NumStr " " TwoItemName
    } else if((SubStr(NumStr, StrLen(NumStr)) = 1) && ((StrLen(NumStr) < 2) || (!(SubStr(NumStr, StrLen(NumStr) - 1, 1) = 1)))) {
      Return NumStr " " OneItemName
    } else {
      Return NumStr " " FiveItemName
    }
  }

  readShippingToHundred()
  {
    Global Config

    ShippingToHundred := Config["plugins"]["UnloadingReport"]["ShippingToHundred"]
    ShippingToHundred := RegExReplace(ShippingToHundred, "[^0-9]", "")

    if (StrLen(ShippingToHundred)) {
      this._shippingToHundred := ShippingToHundred
    }

    Return
  }

  readMessageFormat()
  {
    Global Config

    MessageFormat := Config["plugins"]["UnloadingReport"]["MessageFormat"]
    MessageFormatEnd := Config["plugins"]["UnloadingReport"]["MessageFormatEnd"]
    MessageFormatEndFullWithoutRemainingCargo := Config["plugins"]["UnloadingReport"]["MessageFormatEndFullWithoutRemainingCargo"]
    MessageFormatEndFullWithRemainingCargo := Config["plugins"]["UnloadingReport"]["MessageFormatEndFullWithRemainingCargo"]

    if (StrLen(MessageFormat)) {
      this._messageFormat := MessageFormat
    }

    this._messageFormatEnd := MessageFormatEnd
    this._messageFormatEndFullWithoutRemainingCargo := MessageFormatEndFullWithoutRemainingCargo
    this._messageFormatEndWithRemainingCargo := MessageFormatEndFullWithRemainingCargo

    Return
  }

  unloadingReportChatlogChecker(MessageString)
  {
    if (SubStr(MessageString, 1, 10) = " На складе") && (InStr(MessageString, ":") > 0) {
      WarehouseName := SubStr(MessageString, 12)
      WarehouseName := SubStr(WarehouseName, 1, InStr(WarehouseName, ":") - 1)
      WarehouseCargo := SubStr(MessageString, InStr(MessageString, ":") + 2)
      WarehouseCargo := SubStr(WarehouseCargo, 1, InStr(WarehouseCargo, "/") - 1)
      WarehouseCargo := Round(WarehouseCargo / 1000)

      this._warehouseName := WarehouseName
      this._warehouseCargo := WarehouseCargo
    } else if (SubStr(MessageString, 1, 12) = " Материалов:") {
      RemainingCargo := SubStr(MessageString, InStr(MessageString, ":") + 2)
      RemainingCargo := SubStr(RemainingCargo, 1, InStr(RemainingCargo, "/") - 1)
      RemainingCargo := Round(RemainingCargo / 1000)

      this._remainingCargo := RemainingCargo
    }
  }

  sendUnloadingReport()
  {
    Chatlog.reader()

    WarehouseName := this._warehouseName
    WarehouseCargo := this._warehouseCargo
    RemainingCargo := this._remainingCargo
    Message := this._messageFormat
    MessageEndPart := ""
    IsSending := True

    if (WarehouseName <> "") AND (WarehouseCargo > 0) {
      if (WarehouseCargo >= this._shippingToHundred)
        WarehouseCargo = 100

      Message := StrReplace(Message, "%Warehouse%", WarehouseName)
      Message := StrReplace(Message, "%Cargo%", this._generateNameDec(WarehouseCargo, "тонна", "тонны", "тонн"))

      if (WarehouseCargo = 100) {
        if (RemainingCargo > 0) {
          MessageEndPart := StrReplace(this._messageFormatEndFullWithRemainingCargo, "%RemainingCargo%", this._generateNameDec(RemainingCargo, "тонна", "тонны", "тонн"))
        } else {
          MessageEndPart := this._messageFormatEndFullWithoutRemainingCargo
        }
      } else {
        MessageEndPart := this._messageFormatEnd
      }

      if (SubStr(RTrim(MessageEndPart), -2) = "...") {
        MessageEndPart := SubStr(RTrim(MessageEndPart), 1, -4)

        IsSending := False
      }

      Message := Message " " MessageEndPart

      sendChatSavingMessage(Message, IsSending)
    } else {
      sendChatSavingMessage("Нет данных по складам", False)
    }

    Return
  }

  init()
  {
    this.readShippingToHundred()
    this.readMessageFormat()

    Return
  }
}

UnloadingReport := new UnloadingReport()

UnloadingReportChatlogChecker(ChatlogString)
{
  UnloadingReport.unloadingReportChatlogChecker(ChatlogString)
}

Chatlog.checker.Insert("UnloadingReportChatlogChecker")

HotKeyRegister(Config["plugins"]["UnloadingReport"]["Key"], "UnloadingReportHotKey")

UnloadingReport.init()
