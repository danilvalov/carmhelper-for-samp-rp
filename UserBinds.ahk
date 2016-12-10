;;
;; Example UserBinds.ahk for CarmHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;
;;
;; *Краткая инструкция:*
;;
;; Если хотим отправить сообщение в чат с сохранением в истории чата (клавиша "вверх" в строке чата),
;; то используем команду `sendChatSavingMessage(Текст сообщения)`.
;;
;; Если хотим отправить сообщения без сохранения в истории чата,
;; то используем команду `sendChatMessage(Текст сообщения)`.
;;
;; Если хотим просто ввести текст в строку чата без отправки,
;; то используем команду `sendChatSavingMessage(Текст сообщения, False)`
;; - параметр False отключает автоматическую отправку сообщения.
;;
;; Комментарии можно вставлять, указав перед комментарием точку с запятой (";").
;; Пример:
;; sendChatMessage()       ; А это - комментарий, т.к. идёт после точки с запятой
;;
;; Как вписывать коды клавиш можно узнать по следующим ссылкам:
;; http://www.script-coding.com/AutoHotkey/KeyList.html
;; http://www.script-coding.com/AutoHotkey/Hotkeys.html
;;
;;
;; ВАЖНО!
;; В конце каждого бинда оставляйте команду `Return`, иначе будет срабатывать следующий бинд.
;;

!1::                       ; Alt + 1
{
  sendChatMessage("/do Борт грузовика открылся автоматически по нажатию на кнопку в кабине")
  Sleep 1200               ; Пауза перед следующей командой, чтобы не сработало "Не флуди" в чате
  sendChatMessage("/me с кряхтением взял боеприпасы со склада")
  Sleep 1200               ; Пауза перед следующей командой, чтобы не сработало "Не флуди" в чате
  sendChatMessage("/try небрежно кинул боеприпасы в грузовик")
  Sleep 1200               ; Пауза перед следующей командой, чтобы не сработало "Не флуди" в чате
  sendChatMessage("/do Борт грузовика закрылся автоматически по нажатию на кнопку в кабине")

  Return
}

!2::                       ; Alt + 2
{
  sendChatMessage("/me открыл борт грузовика")
  Sleep 1200               ; Пауза перед следующей командой, чтобы не сработало "Не флуди" в чате
  sendChatMessage("/try выгрузил ящики с боеприпасами")
  Sleep 1200               ; Пауза перед следующей командой, чтобы не сработало "Не флуди" в чате
  sendChatMessage("/try закрыл борт грузовика")

  Return
}

Numpad0::
{
  sendChatSavingMessage("/r [Взвод №1]", False)

  Return
}

Numpad1::
{
   sendChatMessage("/clist 3")

   Return
}

!Numpad1::
{
   sendChatMessage("/clist 0")

   Return
}

Numpad2::
{
   sendChatMessage("/me предъявил путевой лист №328823")

   Return
}

Numpad4::
{
   sendChatMessage("/carm")

   Return
}

Numpad6::
{
   sendChatSavingMessage("/r [Взвод №1] Заканчиваю поставки. Литраж:", False)

   Return
}

Numpad7::
{
   sendChatSavingMessage("/r [Взвод №1] Выезжаю с базы. Пункт назначения:", False)

   Return
}

Numpad9::
{
   sendChatMessage("/r [Взвод №1] Подъезжаю к базе (( /clist 3 ))")

   Return
}

NumpadDiv::
{
   sendChatMessage("/me выполнил воинское приветствие")

   Return
}

!NumpadDiv::
{
   sendChatMessage("Здравия желаю")

   Return
}

NumpadMult::
{
   sendChatMessage(")")

   Return
}

!NumpadMult::
{
   sendChatMessage(":D")

   Return
}

NumpadAdd::
{
   sendChatMessage("Так точно")

   Return
}

!NumpadAdd::
{
   sendChatMessage("Принято")

   Return
}

NumpadSub::
{
   sendChatMessage("Никак нет")

   Return
}

!NumpadSub::
{
   sendChatMessage("Виноват")

   Return
}

NumpadDot::
{
   sendChatSavingMessage("/r [Взвод №1] Здравия желаю, база", False)

   Return
}

!NumpadDot::
{
   sendChatSavingMessage("/r [Взвод №1] ОБОР угоняет матовоз! Огонь на поражение!", False)

   Return
}

F12::
{
   sendChatMessage("/clist 7")

   Return
}

!Q::
{
   sendChatMessage("/time")

   Return
}
