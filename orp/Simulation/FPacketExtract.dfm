object FrmPacketExt: TFrmPacketExt
  Left = 0
  Top = 0
  Caption = #54056#53431' '#48977#44592
  ClientHeight = 293
  ClientWidth = 426
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 426
    Height = 28
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 0
    object BtnCohesionSymbol: TSpeedButton
      Left = 267
      Top = 5
      Width = 23
      Height = 19
      Caption = '...'
      OnClick = BtnCohesionSymbolClick
    end
    object ComboAccount: TComboBox
      Left = 4
      Top = 4
      Width = 148
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 0
      OnChange = ComboAccountChange
    end
    object cbSymbol: TComboBox
      Left = 156
      Top = 5
      Width = 98
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 1
      OnChange = cbSymbolChange
    end
  end
  object sgData: TStringGrid
    Left = 0
    Top = 28
    Width = 426
    Height = 265
    Align = alClient
    DefaultRowHeight = 19
    FixedCols = 0
    TabOrder = 1
    ExplicitLeft = 48
    ExplicitTop = 80
    ExplicitWidth = 320
    ExplicitHeight = 120
  end
end
