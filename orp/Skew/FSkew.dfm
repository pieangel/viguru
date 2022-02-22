object SkewForm: TSkewForm
  Left = 0
  Top = 0
  Caption = 'Skew'
  ClientHeight = 449
  ClientWidth = 731
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClick = FormCreate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 731
    Height = 32
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 9
      Width = 43
      Height = 13
      Caption = 'Account:'
    end
    object ButtonRecovery: TSpeedButton
      Tag = 10
      Left = 441
      Top = 5
      Width = 119
      Height = 22
      Hint = '??/???? ????'
      Caption = 'Load training set...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
    end
    object Bevel1: TBevel
      Left = 214
      Top = 10
      Width = 9
      Height = 11
      Shape = bsLeftLine
    end
    object ComboAccount: TComboBox
      Left = 57
      Top = 8
      Width = 153
      Height = 18
      Style = csOwnerDrawFixed
      ImeName = '???(??) (MS-IME95)'
      ItemHeight = 12
      TabOrder = 0
    end
    object RadioButton1: TRadioButton
      Left = 229
      Top = 8
      Width = 60
      Height = 17
      Caption = 'Training'
      Checked = True
      TabOrder = 1
      TabStop = True
    end
    object RadioButton2: TRadioButton
      Left = 375
      Top = 8
      Width = 60
      Height = 17
      Caption = 'Trading'
      TabOrder = 2
    end
    object RadioButton3: TRadioButton
      Left = 295
      Top = 8
      Width = 74
      Height = 17
      Caption = 'Monitoring'
      TabOrder = 3
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 430
    Width = 731
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Text = 'Training'
        Width = 70
      end
      item
        Alignment = taCenter
        Text = '2007-04-10'
        Width = 80
      end
      item
        Alignment = taCenter
        Text = 'Training Count: 100'
        Width = 150
      end
      item
        Width = 50
      end>
  end
  object Panel3: TPanel
    Left = 0
    Top = 32
    Width = 731
    Height = 398
    Align = alClient
    TabOrder = 2
    ExplicitWidth = 392
    object PageControl1: TPageControl
      Left = 1
      Top = 1
      Width = 729
      Height = 396
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 390
      ExplicitHeight = 223
      object TabSheet1: TTabSheet
        Caption = 'Skew Graph'
        ExplicitWidth = 382
        ExplicitHeight = 195
        object PaintBoxSkew: TPaintBox
          Left = 0
          Top = 0
          Width = 721
          Height = 368
          Align = alClient
          OnPaint = PaintBoxSkewPaint
          ExplicitTop = -2
          ExplicitWidth = 342
          ExplicitHeight = 235
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Skew Table'
        ImageIndex = 1
        ExplicitWidth = 382
        ExplicitHeight = 195
        object StringGridPoints: TStringGrid
          Left = 0
          Top = 0
          Width = 721
          Height = 368
          Align = alClient
          DefaultRowHeight = 16
          TabOrder = 0
          ExplicitWidth = 382
          ExplicitHeight = 195
        end
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 208
    Top = 320
    object EF1: TMenuItem
      Caption = 'EF ??'
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object N1: TMenuItem
      Caption = '????'
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object N3: TMenuItem
      Caption = '??????'
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 576
    Top = 8
  end
end
