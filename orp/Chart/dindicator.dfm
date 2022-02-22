object IndicatorDialog: TIndicatorDialog
  Left = 405
  Top = 137
  BorderStyle = bsDialog
  Caption = #51648#54364' '#52628#44032
  ClientHeight = 405
  ClientWidth = 270
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonOK: TButton
    Left = 18
    Top = 376
    Width = 67
    Height = 25
    Caption = #49440' '#53469'(&S)'
    Default = True
    TabOrder = 0
    OnClick = ButtonOKClick
  end
  object Button2: TButton
    Left = 100
    Top = 376
    Width = 67
    Height = 25
    Caption = #52712' '#49548'(&C)'
    ModalResult = 2
    TabOrder = 1
  end
  object Button1: TButton
    Left = 184
    Top = 376
    Width = 67
    Height = 25
    Caption = #46020#50880#47568'(&H)'
    ModalResult = 2
    TabOrder = 2
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 270
    Height = 369
    ActivePage = TabSheet1
    Align = alTop
    TabOrder = 3
    object TabSheet1: TTabSheet
      Caption = #51648#54364
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ListIndicators: TListBox
        Left = 0
        Top = 0
        Width = 262
        Height = 341
        Align = alClient
        ImeName = #54620#44397#50612'('#54620#44544')'
        ItemHeight = 13
        Items.Strings = (
          #44144#47000#47049
          'MA'
          'MACD'
          'Momentum'
          'DMI'
          'CCI'
          'EMA'
          'Parabolic'
          'RSI'
          'Stochastic'
          'OBV'
          'Bollingers Bands'
          #51060#44201#46020)
        TabOrder = 0
        OnDblClick = ListIndicatorsDblClick
      end
    end
  end
end
