object QuoteTrace: TQuoteTrace
  Left = 0
  Top = 0
  Caption = #51452#47928#52628#52636
  ClientHeight = 603
  ClientWidth = 379
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #44404#47548#52404
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 12
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 379
    Height = 66
    Align = alTop
    TabOrder = 0
    object SpeedButton1: TSpeedButton
      Left = 252
      Top = 38
      Width = 57
      Height = 22
      Caption = 'Prev'
      OnClick = SpeedButton1Click
    end
    object SpeedButton2: TSpeedButton
      Left = 315
      Top = 38
      Width = 58
      Height = 22
      Caption = 'Next'
      OnClick = SpeedButton2Click
    end
    object Label1: TLabel
      Left = 271
      Top = 11
      Width = 54
      Height = 12
      Caption = 'ShowCnt :'
    end
    object Label2: TLabel
      Left = 138
      Top = 11
      Width = 36
      Height = 12
      Caption = 'Qty : '
    end
    object Label3: TLabel
      Left = 204
      Top = 11
      Width = 24
      Height = 12
      Caption = 'H : '
    end
    object DateTimePickerTime: TDateTimePicker
      Left = 5
      Top = 38
      Width = 90
      Height = 20
      Date = 38303.375000000000000000
      Time = 38303.375000000000000000
      ImeName = 'Korean Input System (IME 2000)'
      Kind = dtkTime
      TabOrder = 0
    end
    object ButtonGoto: TBitBtn
      Left = 101
      Top = 35
      Width = 65
      Height = 25
      Caption = 'Goto'
      TabOrder = 1
      OnClick = ButtonGotoClick
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
        FF00FFFF00FFFF00FF95440D853C136D3327703425873D1296450DFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFA04B0C70372ACD7727E8AD70F3
        CCA1F4CDA3E9B176D07C2C6F3529A64F0AFF00FFFF00FFFF00FFFF00FFFF00FF
        86411DC0620BF0C292FFFEFAFEFAF7F5E3D1F5E2D0FDF8F4FFFFFDF2C99EC669
        117B3A21FF00FFFF00FFFF00FFAF5201C16107F7DBBDFEFDFBE0A369CE6F15C9
        6100C96000CD6D10DE9D5FFDFAF7FAE5CCC6680DA64E06FF00FFFF00FF8C451C
        ECBD8BFFFFFFDC964FC75900CA6200CA6400CD6B08CA6100C65800D58433FDFA
        F8F3CB9F6F3528FF00FFBB5F0ACE7721FFFDFBE6AF78E2A363EBC196CF6E0ACA
        6100DB944CECC7A2CC6808C55400DFA161FFFFFFCF7B2895440CAF5507E5AA6F
        FFFFFFDB8833E9B580FFFFFFF2D4B5D47719DC954CFFFFFFF2D9C0D0731ECB66
        04FDFAF7E9B175873D11A04D10F0CAA1FCF4EDE08C38EEBF8EFFFFFFFFFFFFF7
        E6D5E8B581FFFEFEFFFFFFFAF0E5D68537F4DEC8F3CEA4703525AF5507F2CDA6
        FDF7F0E79C4EF2C79BFFFFFFFFFFFFF6DBC1E9B580FFFFFFFFFFFFF4DEC8D27B
        27F5E2CDF3CCA16D3428BB5F0AEEBC88FFFFFFF0B373F6D0A8FFFFFFF5D4B1E2
        903CE8AC6FFFFFFFEDC7A1CB6508CD6A09FEFCFBE7AC6D853B13BF6006E5A059
        FFFDFAFBDDBEFBD2A8F9D5B0EEA85FE79A4BEAB074EBBE90D16F0BC75900E2AA
        71FFFFFE6B342C94440CFF00FFC36204FAD9B8FFFFFFFEDCB8F7B775F0AE69E9
        A156E29242D87D20CF6A04DB924AFFFFFFEFC08CA04A08FF00FFFF00FFD57F2B
        E79E55FEEBD7FFFFFFFBDFC2F1B87DE9A259E29444DE9142E8B786FFFFFFF6D8
        B7BE5F06A04A08FF00FFFF00FFFF00FFC6670CE69E55FAD9B6FFFBF6FFFFFFFE
        F8F2FDF6EFFFFFFFFEF9F2ECB884BE5F09753826FF00FFFF00FFFF00FFFF00FF
        FF00FFD27E2CC06005E49F5AEEBA86F2CAA0F0C599E4A768CC741E8E451AA64D
        06FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFB96113A24F0E8E
        451A8E451AA24F0EB25A0FFF00FFFF00FFFF00FFFF00FFFF00FF}
    end
    object cbSymbol: TComboBox
      Left = 3
      Top = 8
      Width = 118
      Height = 20
      Style = csDropDownList
      ImeName = 'Microsoft IME 2003'
      ItemHeight = 0
      TabOrder = 2
      OnChange = cbSymbolChange
    end
    object edtCnt: TEdit
      Left = 327
      Top = 8
      Width = 39
      Height = 20
      ImeName = 'Microsoft IME 2003'
      TabOrder = 3
      Text = '50'
      OnExit = edtCntExit
      OnKeyPress = edtCntKeyPress
    end
    object edtQty: TEdit
      Left = 159
      Top = 8
      Width = 29
      Height = 20
      ImeName = 'Microsoft IME 2003'
      TabOrder = 4
      Text = '20'
      OnExit = edtQtyExit
      OnKeyPress = edtCntKeyPress
    end
    object edtHoga: TEdit
      Left = 223
      Top = 8
      Width = 27
      Height = 20
      ImeName = 'Microsoft IME 2003'
      TabOrder = 5
      Text = '5'
      OnExit = edtQtyExit
      OnKeyPress = edtCntKeyPress
    end
  end
  object sgInfo: TStringGrid
    Left = 0
    Top = 66
    Width = 379
    Height = 537
    Align = alClient
    DefaultRowHeight = 17
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    TabOrder = 1
    OnDrawCell = sgInfoDrawCell
    OnMouseDown = sgInfoMouseDown
  end
end
