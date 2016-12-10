;;
;; Example UserBinds.ahk for CarmHelper.ahk
;; Author: Danil Valov <danil@valov.me>
;;
;;
;; *������� ����������:*
;;
;; ���� ����� ��������� ��������� � ��� � ����������� � ������� ���� (������� "�����" � ������ ����),
;; �� ���������� ������� `sendChatSavingMessage(����� ���������)`.
;;
;; ���� ����� ��������� ��������� ��� ���������� � ������� ����,
;; �� ���������� ������� `sendChatMessage(����� ���������)`.
;;
;; ���� ����� ������ ������ ����� � ������ ���� ��� ��������,
;; �� ���������� ������� `sendChatSavingMessage(����� ���������, False)`
;; - �������� False ��������� �������������� �������� ���������.
;;
;; ����������� ����� ���������, ������ ����� ������������ ����� � ������� (";").
;; ������:
;; sendChatMessage()       ; � ��� - �����������, �.�. ��� ����� ����� � �������
;;
;; ��� ��������� ���� ������ ����� ������ �� ��������� �������:
;; http://www.script-coding.com/AutoHotkey/KeyList.html
;; http://www.script-coding.com/AutoHotkey/Hotkeys.html
;;
;;
;; �����!
;; � ����� ������� ����� ���������� ������� `Return`, ����� ����� ����������� ��������� ����.
;;

!1::                       ; Alt + 1
{
  sendChatMessage("/do ���� ��������� �������� ������������� �� ������� �� ������ � ������")
  Sleep 1200               ; ����� ����� ��������� ��������, ����� �� ��������� "�� �����" � ����
  sendChatMessage("/me � ���������� ���� ���������� �� ������")
  Sleep 1200               ; ����� ����� ��������� ��������, ����� �� ��������� "�� �����" � ����
  sendChatMessage("/try �������� ����� ���������� � ��������")
  Sleep 1200               ; ����� ����� ��������� ��������, ����� �� ��������� "�� �����" � ����
  sendChatMessage("/do ���� ��������� �������� ������������� �� ������� �� ������ � ������")

  Return
}

!2::                       ; Alt + 2
{
  sendChatMessage("/me ������ ���� ���������")
  Sleep 1200               ; ����� ����� ��������� ��������, ����� �� ��������� "�� �����" � ����
  sendChatMessage("/try �������� ����� � ������������")
  Sleep 1200               ; ����� ����� ��������� ��������, ����� �� ��������� "�� �����" � ����
  sendChatMessage("/try ������ ���� ���������")

  Return
}

Numpad0::
{
  sendChatSavingMessage("/r [����� �1]", False)

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
   sendChatMessage("/me ��������� ������� ���� �328823")

   Return
}

Numpad4::
{
   sendChatMessage("/carm")

   Return
}

Numpad6::
{
   sendChatSavingMessage("/r [����� �1] ���������� ��������. ������:", False)

   Return
}

Numpad7::
{
   sendChatSavingMessage("/r [����� �1] ������� � ����. ����� ����������:", False)

   Return
}

Numpad9::
{
   sendChatMessage("/r [����� �1] ��������� � ���� (( /clist 3 ))")

   Return
}

NumpadDiv::
{
   sendChatMessage("/me �������� �������� �����������")

   Return
}

!NumpadDiv::
{
   sendChatMessage("������� �����")

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
   sendChatMessage("��� �����")

   Return
}

!NumpadAdd::
{
   sendChatMessage("�������")

   Return
}

NumpadSub::
{
   sendChatMessage("����� ���")

   Return
}

!NumpadSub::
{
   sendChatMessage("�������")

   Return
}

NumpadDot::
{
   sendChatSavingMessage("/r [����� �1] ������� �����, ����", False)

   Return
}

!NumpadDot::
{
   sendChatSavingMessage("/r [����� �1] ���� ������� �������! ����� �� ���������!", False)

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
