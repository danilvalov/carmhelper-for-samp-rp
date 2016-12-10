;;
;; HotKeyRegister Module for CarmHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;

HotKeyRegister(HotKey, Callback)
{
  if (HotKey && StrLen(HotKey)) {
    Hotkey, % HotKey, % Callback
  }

  Return
}
