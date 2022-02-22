object FrmBullSignal: TFrmBullSignal
  Left = 0
  Top = 0
  Caption = 'Bull '#49888#54840' '#52628#51201
  ClientHeight = 629
  ClientWidth = 637
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
  object sgBull: TStringGrid
    Left = 0
    Top = 30
    Width = 637
    Height = 599
    Align = alClient
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 2
    TabOrder = 0
    ExplicitLeft = 216
    ExplicitTop = 176
    ExplicitWidth = 320
    ExplicitHeight = 120
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 637
    Height = 30
    Align = alTop
    TabOrder = 1
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 344
    Top = 216
  end
end
