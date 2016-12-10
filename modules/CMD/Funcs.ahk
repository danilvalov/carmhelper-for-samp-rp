;;
;; CMD Module for CarmHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

ClipPutText(Text, LocaleID=0x419)
{
  CF_TEXT:=1, CF_LOCALE:=16, GMEM_MOVEABLE:=2
  TextLen   :=StrLen(Text)
  HmemText  :=DllCall("GlobalAlloc", "UInt", GMEM_MOVEABLE, "UInt", TextLen+1)  ; ������ ������������
  HmemLocale:=DllCall("GlobalAlloc", "UInt", GMEM_MOVEABLE, "UInt", 4)  ; ������, ������������ ������.
  If(!HmemText || !HmemLocale)
    Return
  PtrText   :=DllCall("GlobalLock",  "UInt", HmemText)   ; �������� ������, ������ ��������������
  PtrLocale :=DllCall("GlobalLock",  "UInt", HmemLocale) ; � ��������� (������).
  DllCall("msvcrt\memcpy", "UInt", PtrText, "Str", Text, "UInt", TextLen+1, "Cdecl") ; ����������� ������.
  NumPut(LocaleID, PtrLocale+0)                   ; ������ �������������� ������.
  DllCall("GlobalUnlock",     "UInt", HmemText)   ; ����������� ������.
  DllCall("GlobalUnlock",     "UInt", HmemLocale)
  If not DllCall("OpenClipboard", "UInt", 0)      ; �������� ������ ������.
  {
    DllCall("GlobalFree", "UInt", HmemText)    ; ������������ ������,
    DllCall("GlobalFree", "UInt", HmemLocale)  ; ���� ������� �� �������.
    Return
  }
  DllCall("EmptyClipboard")                     ; �������.
  DllCall("SetClipboardData", "UInt", CF_TEXT,   "UInt", HmemText)   ; ��������� ������.
  DllCall("SetClipboardData", "UInt", CF_LOCALE, "UInt", HmemLocale)
  DllCall("CloseClipboard")     ; ��������.
}

ClipGetText(CodePage=1251)
{
  CF_TEXT:=1, CF_UNICODETEXT:=13, Format:=0
  If not DllCall("OpenClipboard", "UInt", 0)                 ; �������� ������ ������.
    Return
  Loop
  {
    Format:=DllCall("EnumClipboardFormats", "UInt", Format)  ; ������� ��������.
    If(Format=0 || Format=CF_TEXT || Format=CF_UNICODETEXT)
      Break
  }
  If(Format=0) {      ; ������ �� �������.
    DllCall("CloseClipboard")
    Return
  }
  If(Format=CF_TEXT)
  {
    HmemText:=DllCall("GetClipboardData", "UInt", CF_TEXT)  ; ��������� ������ ������.
    PtrText :=DllCall("GlobalLock",       "UInt", HmemText) ; ����������� ������ � ���������.
    TextLen :=DllCall("msvcrt\strlen",    "UInt", PtrText, "Cdecl")  ; ��������� ����� ���������� ������.
    VarSetCapacity(Text, TextLen+1)  ; ���������� ��� ���� �����.
    DllCall("msvcrt\memcpy", "Str", Text, "UInt", PtrText, "UInt", TextLen+1, "Cdecl") ; ����� � ����������.
    DllCall("GlobalUnlock", "UInt", HmemText)  ; ����������� ������.
  }
  Else If(Format=CF_UNICODETEXT)
  {
    HmemTextW:=DllCall("GetClipboardData", "UInt", CF_UNICODETEXT)
    PtrTextW :=DllCall("GlobalLock",       "UInt", HmemTextW)
    TextLen  :=DllCall("msvcrt\wcslen",    "UInt", PtrTextW, "Cdecl")
    VarSetCapacity(Text, TextLen+1)
    DllCall("WideCharToMultiByte", "UInt", CodePage, "UInt", 0, "UInt", PtrTextW
                                 , "Int", TextLen+1, "Str", Text, "Int", TextLen+1
                                 , "UInt", 0, "Int", 0)  ; ����������� �� Unicode � ANSI.
    DllCall("GlobalUnlock", "UInt", HmemTextW)
  }
  DllCall("CloseClipboard")  ; ��������.
  Return Text
}

class CMD
{
  commands := {}

  __getLocale()
  {
    SetFormat, Integer, H

    WinGet, WinID,, A
    ThreadID := DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
    InputLocaleID := DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")

    SetFormat, Integer, D

    Return %InputLocaleID%
  }

  __setLocale(Locale)
  {
    SendMessage, 0x50,, %Locale%,, A

    Return
  }

  __hasValueInArray(Array, Value)
  {
    for Key, Val in Array {
      if (Val = Value) {
        Return Key
      }
    }
    Return 0
  }

  __strToLower(String)
  {
    StringLower, String, String

    Return String
  }

  get()
  {
    Locale_Default := this.__getLocale()

    ClipboardReset := ClipGetText()
    Sleep 10
    Clipboard =

    this.__setLocale(0x4090409)

    if (IsInChat()) {
      SendInput ^a^c{Right}
      Sleep 100
      ChatInput := ClipGetText()
      if (SubStr(ChatInput, 1, 1) = "/" && StrLen(Trim(ChatInput)) > 1) {
        ChatInput := Trim(ChatInput)
        ChatInputEx := StrSplit(ChatInput, " ")
        Command := RegExReplace(this.__strToLower(ChatInputEx[1]), "[^a-z]", "")
        Callback := this.commands[Command]
        if (Callback) {
          Sleep 10
          CallbackSplit := StrSplit(Callback, ".")
          if (CallbackSplit.MaxIndex() = 1) {
            if (isFunc(%CallbackFunc%)) {
              %Callback%(ChatInputEx)
            }
          } else if (CallbackSplit.MaxIndex() = 2) {
            CallbackFunc := CallbackSplit[1]
            if (isFunc(%CallbackFunc%[CallbackSplit[2]])) {
              %CallbackFunc%[CallbackSplit[2]](ChatInputEx)
            }
          }
        }
      }
    }

    Sleep 10
    this.__setLocale(Locale_Default)
    Sleep 10
    ClipPutText(ClipboardReset)

    Return
  }
}

CMD := new CMD()
