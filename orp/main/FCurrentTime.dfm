object FrmCurrentTime: TFrmCurrentTime
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = #54788#51116#49884#44033
  ClientHeight = 58
  ClientWidth = 205
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object plTime: TPanel
    Left = 0
    Top = 0
    Width = 205
    Height = 58
    Align = alClient
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -27
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentFont = False
    PopupMenu = popMenu
    TabOrder = 0
    OnDblClick = plTimeDblClick
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 32
  end
  object popMenu: TPopupMenu
    object N1: TMenuItem
      Caption = #54872#44221#49444#51221
      OnClick = N1Click
    end
  end
end
