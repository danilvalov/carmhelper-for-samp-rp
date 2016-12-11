;;
;; SOS Plugin for CarmHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

class SOS
{
  _messageFormat := "/r [����� �1] ��� %POS%"

  getPosition(X, Y)
  {
    Letters = �,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�,�
    StringSplit, LettersArray, Letters, `,

    Y := Y * (-1)
    X := X + 3000
    Y := Y + 3000
    X := Floor(X / 250) + 1
    Y := Floor(Y / 250) + 1

    Return % LettersArray%Y% "-" X
  }

  readMessageFormat()
  {
    Global Config

    MessageFormat := Config["plugins"]["SOS"]["MessageFormat"]

    if (StrLen(MessageFormat)) {
      this._messageFormat := MessageFormat
    }

    Return
  }

  sendSOS()
  {
    Position := ""
    Coordinates := getCoordinates()
    IsSending := !!Coordinates

    if (IsSending) {
      Position := this.getPosition(Coordinates[1], Coordinates[2])
    }

    Message := this._messageFormat
    Message := StrReplace(Message, "%POS%", Position)

    if (IsSending) {
      sendChatMessage(Message)
    } else {
      addMessageToChatWindow("{FFFF00}������ � ����� ��������������� �� �������. �� �� ������ ������ �� �������:")

      sendChatSavingMessage(Message, False)
    }

    Return
  }

  init()
  {
    this.readMessageFormat()

    Return
  }
}

SOS := new SOS()

CMD.commands["sos"] := "SOS.sendSOS"

HotKeyRegister(Config["plugins"]["SOS"]["Key"], "SOSHotKey")

SOS.init()
