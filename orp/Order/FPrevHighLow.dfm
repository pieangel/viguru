object FrmPrevHighLow: TFrmPrevHighLow
  Left = 0
  Top = 0
  Caption = #51204#44256#51204#51200
  ClientHeight = 310
  ClientWidth = 293
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
  object StatusBar1: TStatusBar
    Left = 0
    Top = 291
    Width = 293
    Height = 19
    Panels = <>
    ExplicitTop = 135
    ExplicitWidth = 290
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 293
    Height = 128
    Align = alTop
    Caption = 'Panel1'
    ParentColor = True
    TabOrder = 1
    object cbStart: TCheckBox
      Left = 13
      Top = -1
      Width = 47
      Height = 17
      Caption = 'Start'
      TabOrder = 0
      OnClick = cbStartClick
    end
    object ComboAccount: TComboBox
      Left = 115
      Top = 4
      Width = 124
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 1
      OnChange = ComboAccountChange
    end
    object GroupBox2: TGroupBox
      Left = 6
      Top = 22
      Width = 279
      Height = 103
      Caption = #51204#44256' '#51204#51200
      TabOrder = 2
      object Label13: TLabel
        Left = 103
        Top = 22
        Width = 8
        Height = 13
        Caption = '~'
      end
      object Label14: TLabel
        Left = 7
        Top = 77
        Width = 24
        Height = 13
        Caption = #51652#51077
      end
      object Label15: TLabel
        Left = 84
        Top = 77
        Width = 12
        Height = 13
        Caption = #52488
      end
      object Label16: TLabel
        Left = 182
        Top = 51
        Width = 12
        Height = 13
        Caption = #52488
      end
      object Label17: TLabel
        Left = 105
        Top = 50
        Width = 24
        Height = 13
        Caption = #52397#49328
      end
      object Label18: TLabel
        Left = 105
        Top = 77
        Width = 24
        Height = 13
        Caption = #49552#51208
      end
      object Label19: TLabel
        Left = 182
        Top = 78
        Width = 12
        Height = 13
        Caption = #54001
      end
      object Label20: TLabel
        Left = 7
        Top = 54
        Width = 24
        Height = 13
        Caption = #49688#47049
      end
      object Label3: TLabel
        Left = 10
        Top = 18
        Width = 23
        Height = 13
        Caption = 'start'
      end
      object Label23: TLabel
        Left = 202
        Top = 51
        Width = 21
        Height = 13
        Caption = 'MAX'
      end
      object Label1: TLabel
        Left = 202
        Top = 78
        Width = 24
        Height = 13
        Caption = #51092#47049
      end
      object dpEndTime: TDateTimePicker
        Left = 117
        Top = 18
        Width = 92
        Height = 21
        BiDiMode = bdLeftToRight
        Date = 38303.382118055550000000
        Time = 38303.382118055550000000
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ImeName = 'Korean Input System (IME 2000)'
        Kind = dtkTime
        ParentBiDiMode = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = False
        TabOrder = 0
      end
      object edtEntrySec: TEdit
        Tag = 3
        Left = 36
        Top = 74
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 1
        Text = '52'
        OnChange = edtQtyChange
      end
      object UpDown5: TUpDown
        Left = 66
        Top = 74
        Width = 15
        Height = 21
        Associate = edtEntrySec
        Min = 1
        Max = 59
        Position = 52
        TabOrder = 2
      end
      object UpDown6: TUpDown
        Left = 164
        Top = 47
        Width = 15
        Height = 21
        Associate = edtLiqSec
        Min = 1
        Max = 59
        Position = 2
        TabOrder = 3
      end
      object edtLiqSec: TEdit
        Tag = 1
        Left = 134
        Top = 47
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 4
        Text = '2'
        OnChange = edtQtyChange
      end
      object edtLossTick: TEdit
        Tag = 4
        Left = 134
        Top = 74
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 5
        Text = '2'
        OnChange = edtQtyChange
      end
      object UpDown7: TUpDown
        Left = 164
        Top = 74
        Width = 15
        Height = 21
        Associate = edtLossTick
        Min = 1
        Max = 10
        Position = 2
        TabOrder = 6
      end
      object edtQty: TEdit
        Left = 36
        Top = 48
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 7
        Text = '1'
        OnChange = edtQtyChange
      end
      object UpDown8: TUpDown
        Left = 66
        Top = 48
        Width = 15
        Height = 21
        Associate = edtQty
        Min = 1
        Position = 1
        TabOrder = 8
      end
      object dpstartTime: TDateTimePicker
        Left = 7
        Top = 18
        Width = 92
        Height = 21
        BiDiMode = bdLeftToRight
        Date = 38303.375694444450000000
        Time = 38303.375694444450000000
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ImeName = 'Korean Input System (IME 2000)'
        Kind = dtkTime
        ParentBiDiMode = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = False
        TabOrder = 9
      end
      object edtMaxOrder: TEdit
        Tag = 2
        Left = 226
        Top = 47
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 10
        Text = '3'
        OnChange = edtQtyChange
      end
      object UpDown9: TUpDown
        Left = 256
        Top = 47
        Width = 15
        Height = 21
        Associate = edtMaxOrder
        Min = 1
        Max = 50
        Position = 3
        TabOrder = 11
      end
      object edtVolume: TEdit
        Tag = 5
        Left = 226
        Top = 74
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 12
        Text = '10'
        OnChange = edtQtyChange
      end
      object UpDown1: TUpDown
        Left = 256
        Top = 74
        Width = 15
        Height = 21
        Associate = edtVolume
        Min = 1
        Max = 300
        Position = 10
        TabOrder = 13
      end
    end
  end
  object sgResult: TStringGrid
    Left = 0
    Top = 128
    Width = 293
    Height = 163
    Align = alClient
    ColCount = 3
    Ctl3D = False
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 2
    ParentCtl3D = False
    TabOrder = 2
    ExplicitTop = 137
    ExplicitHeight = 154
    ColWidths = (
      66
      37
      165)
  end
end
