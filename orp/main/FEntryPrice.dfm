object FrmEntryPrice: TFrmEntryPrice
  Left = 0
  Top = 0
  Caption = 'Entry Price'
  ClientHeight = 291
  ClientWidth = 290
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
    Width = 290
    Height = 266
    Align = alClient
    ColCount = 8
    Ctl3D = False
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 2
    ParentCtl3D = False
    ScrollBars = ssVertical
    TabOrder = 0
    OnDrawCell = sgInfoDrawCell
    OnMouseDown = sgInfoMouseDown
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 290
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      290
      25)
    object Button1: TButton
      Left = 2
      Top = 3
      Width = 57
      Height = 20
      Caption = 'Log'
      TabOrder = 0
      OnClick = Button1Click
    end
    object cbAll: TCheckBox
      Left = 255
      Top = 2
      Width = 35
      Height = 17
      Anchors = [akRight, akBottom]
      Caption = 'All'
      TabOrder = 1
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
