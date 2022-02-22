object FrmUpDown: TFrmUpDown
  Left = 0
  Top = 0
  Caption = 'Quoting Up & Down'
  ClientHeight = 293
  ClientWidth = 402
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
    Left = 0
    Top = 25
    Width = 402
    Height = 268
    Align = alClient
    ColCount = 6
    Ctl3D = False
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 2
    ParentCtl3D = False
    ScrollBars = ssVertical
    TabOrder = 0
    OnDrawCell = sgInfoDrawCell
    OnMouseDown = sgInfoMouseDown
    ExplicitTop = 29
    ExplicitWidth = 322
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 402
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 322
    object Button1: TButton
      Left = 2
      Top = 3
      Width = 57
      Height = 20
      Caption = 'Log'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object flashTimer: TTimer
    Enabled = False
    OnTimer = flashTimerTimer
    Left = 176
    Top = 184
  end
  object UpdateTimer: TTimer
    Enabled = False
    Interval = 500
    Left = 320
    Top = 136
  end
end
