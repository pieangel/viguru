object FrmFOSideVol: TFrmFOSideVol
  Left = 0
  Top = 0
  ClientHeight = 143
  ClientWidth = 169
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object sgInfo: TStringGrid
    Left = 19
    Top = 8
    Width = 131
    Height = 84
    ColCount = 2
    DefaultColWidth = 50
    DefaultRowHeight = 19
    DefaultDrawing = False
    RowCount = 4
    ScrollBars = ssNone
    TabOrder = 0
    OnDrawCell = sgInfoDrawCell
    ColWidths = (
      50
      75)
  end
  object Button1: TButton
    Left = 76
    Top = 104
    Width = 75
    Height = 25
    Caption = 'ReSet'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 24
    Top = 112
  end
end
