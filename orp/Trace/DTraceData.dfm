object TraceData: TTraceData
  Left = 0
  Top = 0
  Caption = '...'
  ClientHeight = 301
  ClientWidth = 500
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
  object pageTrace: TPageControl
    Left = 0
    Top = 0
    Width = 500
    Height = 301
    ActivePage = tsPL
    Align = alClient
    TabOrder = 0
    object tsOrder: TTabSheet
      Caption = #51452#47928
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 418
      ExplicitHeight = 265
    end
    object tsPL: TTabSheet
      Caption = #49552#51061
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 418
      ExplicitHeight = 265
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 492
        Height = 28
        Align = alTop
        TabOrder = 0
        object cbAcnt: TComboBox
          Left = 6
          Top = 3
          Width = 145
          Height = 21
          Style = csDropDownList
          ImeName = 'Microsoft IME 2003'
          ItemHeight = 0
          TabOrder = 0
          OnChange = cbAcntChange
        end
      end
      object sgPL: TStringGrid
        Left = 0
        Top = 28
        Width = 492
        Height = 245
        Align = alClient
        DefaultRowHeight = 17
        FixedCols = 0
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 1
      end
    end
  end
  object TimerPL: TTimer
    OnTimer = TimerPLTimer
    Left = 464
    Top = 176
  end
end
