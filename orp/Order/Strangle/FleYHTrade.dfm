object FrmYHTrade: TFrmYHTrade
  Left = 0
  Top = 0
  Caption = 'YH'
  ClientHeight = 281
  ClientWidth = 408
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
    Width = 408
    Height = 113
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 11
      Top = 35
      Width = 51
      Height = 13
      Caption = #49688'         '#47049
    end
    object Label3: TLabel
      Left = 11
      Top = 62
      Width = 52
      Height = 13
      Caption = #51652#51077' Ratio'
    end
    object Label2: TLabel
      Left = 114
      Top = 35
      Width = 48
      Height = 13
      Caption = #51652#51077#54943#49688
    end
    object Label6: TLabel
      Left = 114
      Top = 62
      Width = 52
      Height = 13
      Caption = #52397#49328' Ratio'
    end
    object Label4: TLabel
      Left = 247
      Top = 35
      Width = 24
      Height = 13
      Caption = 'Term'
    end
    object Label5: TLabel
      Left = 333
      Top = 35
      Width = 16
      Height = 13
      Caption = 'Min'
    end
    object Label7: TLabel
      Left = 104
      Top = 90
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label8: TLabel
      Left = 11
      Top = 90
      Width = 48
      Height = 13
      Caption = #50741#49496#44032#44201
    end
    object Label11: TLabel
      Left = 155
      Top = 90
      Width = 24
      Height = 13
      Caption = #49552#51061
    end
    object Label9: TLabel
      Left = 270
      Top = 89
      Width = 48
      Height = 13
      Caption = #52572#45824#49552#49892
    end
    object cbStart: TCheckBox
      Left = 9
      Top = 3
      Width = 47
      Height = 17
      Caption = 'Start'
      TabOrder = 0
      OnClick = cbStartClick
    end
    object ComboAccount: TComboBox
      Left = 63
      Top = 2
      Width = 154
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 1
      OnChange = ComboAccountChange
    end
    object btnSymbol: TButton
      Left = 225
      Top = 1
      Width = 52
      Height = 21
      Caption = #51333#47785
      TabOrder = 2
      OnClick = btnSymbolClick
    end
    object edtQty: TEdit
      Left = 69
      Top = 32
      Width = 39
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 3
      Text = '5'
    end
    object edtEntryR: TEdit
      Left = 69
      Top = 59
      Width = 39
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 4
      Text = '-24'
    end
    object edtEntryCnt: TEdit
      Left = 172
      Top = 32
      Width = 50
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 5
      Text = '2'
    end
    object edtClearR: TEdit
      Left = 172
      Top = 59
      Width = 50
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 6
      Text = '24'
    end
    object edtTerm: TEdit
      Left = 277
      Top = 32
      Width = 50
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 7
      Text = '20'
    end
    object edtMaxPL: TEdit
      Left = 321
      Top = 86
      Width = 80
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 8
      Text = '0'
    end
    object edtLow: TEdit
      Left = 65
      Top = 87
      Width = 33
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 9
      Text = '0.5'
    end
    object edtHigh: TEdit
      Left = 118
      Top = 87
      Width = 33
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 10
      Text = '2.0'
    end
    object cbOpen: TCheckBox
      Left = 347
      Top = 3
      Width = 47
      Height = 17
      Caption = #49884#44032
      TabOrder = 11
      OnClick = cbStartClick
    end
    object edtPL: TEdit
      Left = 184
      Top = 86
      Width = 80
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 12
    end
    object btnClear: TButton
      Left = 283
      Top = 1
      Width = 52
      Height = 21
      Caption = #52397#49328
      TabOrder = 13
      OnClick = btnClearClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 113
    Width = 408
    Height = 168
    Align = alClient
    TabOrder = 1
    object sgOpt: TStringGrid
      Left = 1
      Top = 1
      Width = 406
      Height = 147
      Align = alClient
      ColCount = 8
      DefaultColWidth = 75
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 9
      ScrollBars = ssNone
      TabOrder = 0
      OnDrawCell = sgOptDrawCell
    end
    object StatusBar1: TStatusBar
      Left = 1
      Top = 148
      Width = 406
      Height = 19
      Panels = <
        item
          Alignment = taRightJustify
          Width = 50
        end>
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 368
    Top = 32
  end
end
