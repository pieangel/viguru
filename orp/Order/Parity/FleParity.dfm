object FrmParity: TFrmParity
  Left = 0
  Top = 0
  Caption = 'Parity'
  ClientHeight = 285
  ClientWidth = 372
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
    Width = 372
    Height = 128
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 388
    object Label3: TLabel
      Left = 9
      Top = 38
      Width = 45
      Height = 13
      Caption = #49688'       '#47049
    end
    object Label4: TLabel
      Left = 155
      Top = 61
      Width = 31
      Height = 13
      Caption = 'Status'
    end
    object Label2: TLabel
      Left = 155
      Top = 105
      Width = 19
      Height = 13
      Caption = 'Avg'
    end
    object Label1: TLabel
      Left = 9
      Top = 84
      Width = 48
      Height = 13
      Caption = #49440#47932#44032#44201
    end
    object Label8: TLabel
      Left = 8
      Top = 61
      Width = 48
      Height = 13
      Caption = #50741#49496#44032#44201
    end
    object Label7: TLabel
      Left = 99
      Top = 60
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label11: TLabel
      Left = 155
      Top = 84
      Width = 24
      Height = 13
      Caption = #49552#51061
    end
    object Label5: TLabel
      Left = 27
      Top = 105
      Width = 19
      Height = 13
      Caption = 'Gap'
    end
    object Label6: TLabel
      Left = 155
      Top = 38
      Width = 24
      Height = 13
      Caption = #44592#51456
    end
    object Label9: TLabel
      Left = 228
      Top = 38
      Width = 24
      Height = 13
      Caption = #48176#49688
    end
    object ComboAccount: TComboBox
      Left = 66
      Top = 6
      Width = 137
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 0
      OnChange = ComboAccountChange
    end
    object cbStart: TCheckBox
      Left = 9
      Top = 8
      Width = 49
      Height = 17
      Caption = 'Start'
      TabOrder = 1
      OnClick = cbStartClick
    end
    object edtGap: TEdit
      Left = 62
      Top = 103
      Width = 79
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 2
    end
    object edtQty: TEdit
      Left = 62
      Top = 33
      Width = 79
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 3
      Text = '1'
    end
    object edtStatus: TEdit
      Left = 190
      Top = 57
      Width = 97
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 4
    end
    object edtAvg: TEdit
      Left = 190
      Top = 103
      Width = 96
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 5
    end
    object edtPrice: TEdit
      Left = 62
      Top = 80
      Width = 79
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 6
    end
    object btnClear: TButton
      Left = 265
      Top = 6
      Width = 52
      Height = 21
      Caption = #52397#49328
      TabOrder = 7
      OnClick = btnClearClick
    end
    object btnSymbol: TButton
      Left = 209
      Top = 6
      Width = 52
      Height = 21
      Caption = #51333#47785
      TabOrder = 8
    end
    object edtLow: TEdit
      Left = 62
      Top = 57
      Width = 33
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 9
      Text = '0.5'
    end
    object edtHigh: TEdit
      Left = 110
      Top = 57
      Width = 33
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 10
      Text = '1.5'
    end
    object edtPL: TEdit
      Left = 190
      Top = 80
      Width = 96
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 11
    end
    object edtBase: TEdit
      Left = 190
      Top = 33
      Width = 31
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 12
      Text = '10'
    end
    object rgType: TRadioGroup
      Left = 293
      Top = 33
      Width = 75
      Height = 91
      Caption = 'OrderType'
      ItemIndex = 0
      Items.Strings = (
        #52628#49464
        #50577#47588#49688)
      TabOrder = 13
      OnClick = rgTypeClick
    end
    object edtMultiple: TEdit
      Left = 256
      Top = 33
      Width = 31
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 14
      Text = '7'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 128
    Width = 372
    Height = 157
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 601
    ExplicitHeight = 153
    object sgOpt: TStringGrid
      Left = 1
      Top = 1
      Width = 370
      Height = 136
      Align = alClient
      DefaultColWidth = 75
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 20
      ScrollBars = ssNone
      TabOrder = 0
      OnDrawCell = sgOptDrawCell
      ExplicitWidth = 367
      ExplicitHeight = 120
    end
    object StatusBar1: TStatusBar
      Left = 1
      Top = 137
      Width = 370
      Height = 19
      Panels = <
        item
          Alignment = taRightJustify
          Width = 50
        end>
      ExplicitTop = 231
      ExplicitWidth = 386
    end
  end
end
