object FrmConcernSymbols: TFrmConcernSymbols
  Left = 0
  Top = 0
  Caption = #44288#49900#51333#47785
  ClientHeight = 204
  ClientWidth = 747
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
  object sb: TStatusBar
    Left = 0
    Top = 185
    Width = 747
    Height = 19
    Panels = <>
  end
  object sgSymbols: TStringGrid
    Left = 0
    Top = 29
    Width = 747
    Height = 156
    Align = alClient
    Ctl3D = False
    DefaultRowHeight = 19
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    ParentCtl3D = False
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 747
    Height = 29
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 2
    DesignSize = (
      747
      29)
    object Button1: TButton
      Left = 694
      Top = 4
      Width = 49
      Height = 20
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Button1'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 352
    Top = 136
  end
end
