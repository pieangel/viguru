object DistributionForm: TDistributionForm
  Left = 0
  Top = 0
  Caption = 'Statistical Test'
  ClientHeight = 516
  ClientWidth = 702
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
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 574
    Top = 0
    Width = 128
    Height = 516
    Align = alRight
    TabOrder = 0
    object Bevel1: TBevel
      Left = 1
      Top = 1
      Width = 126
      Height = 32
      Align = alTop
      Shape = bsSpacer
    end
    object CheckListLegend: TCheckListBox
      Left = 1
      Top = 33
      Width = 126
      Height = 247
      Align = alClient
      ImeName = '??? ?? ??? (IME 2000)'
      ItemHeight = 13
      TabOrder = 0
      OnClick = PaintBoxChartPaint
    end
    object CheckBoxAll: TCheckBox
      Left = 6
      Top = 13
      Width = 97
      Height = 17
      Caption = 'All'
      TabOrder = 1
      OnClick = CheckBoxAllClick
    end
    object Panel5: TPanel
      Left = 1
      Top = 443
      Width = 126
      Height = 72
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      object SpeedButtonExportDistribution: TSpeedButton
        Tag = 200
        Left = 8
        Top = 9
        Width = 110
        Height = 24
        Caption = 'Export Distribution'
        OnClick = SpeedButtonExportClick
      end
      object SpeedButtonExportChiSqMap: TSpeedButton
        Tag = 300
        Left = 8
        Top = 39
        Width = 110
        Height = 24
        Caption = 'Export ChiSq Map'
        OnClick = SpeedButtonExportClick
      end
    end
    object MemoPercentiles: TMemo
      Left = 1
      Top = 280
      Width = 126
      Height = 163
      Align = alBottom
      ImeName = 'Korean Input System (IME 2000)'
      TabOrder = 3
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 574
    Height = 516
    Align = alClient
    TabOrder = 1
    object PageControl: TPageControl
      Left = 1
      Top = 1
      Width = 572
      Height = 514
      ActivePage = TabSheet4
      Align = alClient
      TabOrder = 0
      TabPosition = tpBottom
      OnChange = PageControlChange
      object TabSheet1: TTabSheet
        Caption = 'Stationarity'
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object PaintBoxChart: TPaintBox
          Tag = 1
          Left = 0
          Top = 33
          Width = 564
          Height = 455
          Align = alClient
          Constraints.MinHeight = 100
          Constraints.MinWidth = 100
          OnMouseDown = PaintBoxChartMouseDown
          OnMouseMove = PaintBoxChartMouseMove
          OnMouseUp = PaintBoxChartMouseUp
          OnPaint = PaintBoxChartPaint
          ExplicitLeft = 8
          ExplicitTop = 30
          ExplicitWidth = 551
        end
        object Panel4: TPanel
          Left = 0
          Top = 0
          Width = 564
          Height = 33
          Align = alTop
          BevelInner = bvLowered
          TabOrder = 0
          object SpeedButtonSelect: TSpeedButton
            Tag = 1
            Left = 6
            Top = 6
            Width = 23
            Height = 22
            Hint = 'Setup profile'
            AllowAllUp = True
            GroupIndex = 1
            Down = True
            Flat = True
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              0400000000000001000000000000000000001000000000000000000000000000
              8000008000000080800080000000800080008080000080808000C0C0C0000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00BBBBBBBBBBBB
              BBBBBBBBBBBBBBBBBBBBBBBBBBBBB0BBBBBBBBBBBBBB8FBBBBBBBBBBBBBB00BB
              BBBBBBBBBBB8FFBBBBBBBBBBBBBB00BBBBBBBBB8BBB8FFBBBBBBBBBB0BB00BBB
              BBBBBBB8FB8FFBBBBBBBBBBB00B00BBBBBBBBBB8FF8FFBBBBBBBBBBB0000BBBB
              BBBBBBB8FFFFB8BBBBBBBBBB0000000BBBBBBBB8FFFFFFFBBBBBBBBB000000BB
              BBBBBBB8FFFFFFBBBBBBBBBB00000BBBBBBBBBB8FFFFFBBBBBBBBBBB0000BBBB
              BBBBBBB8FFFFBBBBBBBBBBBB000BBBBBBBBBBBBBFFFBBBBBBBBBBBBB00BBBBBB
              BBBBBBBBFFBBBBBBBBBBBBBB0BBBBBBBBBBBBBBBFBBBBBBBBBBBBBBBBBBBBBBB
              BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = ToolButtonClick
          end
          object SpeedButtonHairs: TSpeedButton
            Tag = 2
            Left = 32
            Top = 6
            Width = 23
            Height = 22
            Hint = 'Setup Chart'
            AllowAllUp = True
            GroupIndex = 1
            Flat = True
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              0400000000000001000000000000000000001000000000000000000000000000
              8000008000000080800080000000800080008080000080808000C0C0C0000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00BBBBBBBBBBBB
              BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBFBBBBBBBBBBBBBBB0BBBBBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBBBBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBBBBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBF888BBBBCCCB0000B00000BBB888FFFFBFFFFFBBCCCBBBBB0BBB
              BBBBFFF8BBBBFBBBBBBBBBBBBBBB0BBBBBBBBBBBBBBBFBBBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBFBBBBBBBBBBBBBBB0BBBBBBBBBBBBBBBFBBBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBFBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = ToolButtonClick
          end
          object Bevel3: TBevel
            Left = 59
            Top = 8
            Width = 6
            Height = 18
            Shape = bsLeftLine
          end
          object RadioButtonPDF: TRadioButton
            Left = 71
            Top = 10
            Width = 41
            Height = 17
            Caption = 'PDF'
            Checked = True
            TabOrder = 0
            TabStop = True
            OnClick = PaintBoxChartPaint
          end
          object RadioButtonCDF: TRadioButton
            Left = 119
            Top = 10
            Width = 41
            Height = 17
            Caption = 'CDF'
            TabOrder = 1
            OnClick = PaintBoxChartPaint
          end
          object RadioButtonQuantile: TRadioButton
            Left = 166
            Top = 10
            Width = 67
            Height = 17
            Caption = 'Quantile'
            TabOrder = 2
            OnClick = PaintBoxChartPaint
          end
          object RadioButtonQQ: TRadioButton
            Left = 230
            Top = 10
            Width = 43
            Height = 17
            Caption = 'Q-Q'
            TabOrder = 3
            OnClick = PaintBoxChartPaint
          end
          object RadioButtonChiSqMap: TRadioButton
            Left = 279
            Top = 10
            Width = 98
            Height = 17
            Caption = 'Chi-Sqaure Map'
            TabOrder = 4
            OnClick = PaintBoxChartPaint
          end
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Independence'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
      end
      object TabSheet3: TTabSheet
        Caption = 'Randomness'
        ImageIndex = 2
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
      end
      object TabSheet4: TTabSheet
        Caption = 'Parameters'
        ImageIndex = 3
        object PaintBoxParams: TPaintBox
          Tag = 1
          Left = 0
          Top = 33
          Width = 564
          Height = 455
          Align = alClient
          Constraints.MinHeight = 100
          Constraints.MinWidth = 100
          OnMouseDown = PaintBoxChartMouseDown
          OnMouseMove = PaintBoxChartMouseMove
          OnMouseUp = PaintBoxChartMouseUp
          OnPaint = PaintBoxChartPaint
          ExplicitLeft = 8
          ExplicitTop = 30
          ExplicitWidth = 551
        end
        object Panel1: TPanel
          Left = 0
          Top = 0
          Width = 564
          Height = 33
          Align = alTop
          BevelInner = bvLowered
          TabOrder = 0
          object SpeedButton1: TSpeedButton
            Tag = 1
            Left = 6
            Top = 6
            Width = 23
            Height = 22
            Hint = 'Setup profile'
            AllowAllUp = True
            GroupIndex = 1
            Down = True
            Flat = True
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              0400000000000001000000000000000000001000000000000000000000000000
              8000008000000080800080000000800080008080000080808000C0C0C0000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00BBBBBBBBBBBB
              BBBBBBBBBBBBBBBBBBBBBBBBBBBBB0BBBBBBBBBBBBBB8FBBBBBBBBBBBBBB00BB
              BBBBBBBBBBB8FFBBBBBBBBBBBBBB00BBBBBBBBB8BBB8FFBBBBBBBBBB0BB00BBB
              BBBBBBB8FB8FFBBBBBBBBBBB00B00BBBBBBBBBB8FF8FFBBBBBBBBBBB0000BBBB
              BBBBBBB8FFFFB8BBBBBBBBBB0000000BBBBBBBB8FFFFFFFBBBBBBBBB000000BB
              BBBBBBB8FFFFFFBBBBBBBBBB00000BBBBBBBBBB8FFFFFBBBBBBBBBBB0000BBBB
              BBBBBBB8FFFFBBBBBBBBBBBB000BBBBBBBBBBBBBFFFBBBBBBBBBBBBB00BBBBBB
              BBBBBBBBFFBBBBBBBBBBBBBB0BBBBBBBBBBBBBBBFBBBBBBBBBBBBBBBBBBBBBBB
              BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = ToolButtonClick
          end
          object SpeedButton2: TSpeedButton
            Tag = 2
            Left = 32
            Top = 6
            Width = 23
            Height = 22
            Hint = 'Setup Chart'
            AllowAllUp = True
            GroupIndex = 1
            Flat = True
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              0400000000000001000000000000000000001000000000000000000000000000
              8000008000000080800080000000800080008080000080808000C0C0C0000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00BBBBBBBBBBBB
              BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBFBBBBBBBBBBBBBBB0BBBBBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBBBBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBBBBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBF888BBBBCCCB0000B00000BBB888FFFFBFFFFFBBCCCBBBBB0BBB
              BBBBFFF8BBBBFBBBBBBBBBBBBBBB0BBBBBBBBBBBBBBBFBBBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBFBBBBBBBBBBBBBBB0BBBBBBBBBBBBBBBFBBBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBFBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = ToolButtonClick
          end
          object Bevel2: TBevel
            Left = 59
            Top = 8
            Width = 6
            Height = 18
            Shape = bsLeftLine
          end
          object SpeedButton3: TSpeedButton
            Left = 526
            Top = 6
            Width = 23
            Height = 22
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              04000000000000010000130B0000130B00001000000000000000000000000000
              800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333330070
              7700333333337777777733333333008088003333333377F73377333333330088
              88003333333377FFFF7733333333000000003FFFFFFF77777777000000000000
              000077777777777777770FFFFFFF0FFFFFF07F3333337F3333370FFFFFFF0FFF
              FFF07F3FF3FF7FFFFFF70F00F0080CCC9CC07F773773777777770FFFFFFFF039
              99337F3FFFF3F7F777F30F0000F0F09999937F7777373777777F0FFFFFFFF999
              99997F3FF3FFF77777770F00F000003999337F773777773777F30FFFF0FF0339
              99337F3FF7F3733777F30F08F0F0337999337F7737F73F7777330FFFF0039999
              93337FFFF7737777733300000033333333337777773333333333}
            NumGlyphs = 2
            OnClick = SpeedButton3Click
          end
          object CheckBoxMin: TCheckBox
            Left = 71
            Top = 10
            Width = 50
            Height = 17
            Caption = 'Min'
            TabOrder = 0
            OnClick = CheckBoxParametersClick
          end
          object CheckBoxMax: TCheckBox
            Left = 111
            Top = 10
            Width = 50
            Height = 17
            Caption = 'Max'
            TabOrder = 1
            OnClick = CheckBoxParametersClick
          end
          object CheckBoxMean: TCheckBox
            Left = 159
            Top = 10
            Width = 50
            Height = 17
            Caption = 'Mean'
            TabOrder = 2
            OnClick = CheckBoxParametersClick
          end
          object CheckBoxStddev: TCheckBox
            Left = 215
            Top = 10
            Width = 66
            Height = 17
            Caption = 'StdDev'
            Checked = True
            State = cbChecked
            TabOrder = 3
            OnClick = CheckBoxParametersClick
          end
          object CheckBoxPcnt20: TCheckBox
            Left = 279
            Top = 10
            Width = 50
            Height = 17
            Caption = '20%'
            TabOrder = 4
            OnClick = CheckBoxParametersClick
          end
          object CheckBoxPcnt40: TCheckBox
            Left = 327
            Top = 10
            Width = 50
            Height = 17
            Caption = '40%'
            TabOrder = 5
            OnClick = CheckBoxParametersClick
          end
          object CheckBoxPcnt60: TCheckBox
            Left = 375
            Top = 10
            Width = 50
            Height = 17
            Caption = '60%'
            TabOrder = 6
            OnClick = CheckBoxParametersClick
          end
          object CheckBoxPcnt80: TCheckBox
            Left = 423
            Top = 10
            Width = 50
            Height = 17
            Caption = '80%'
            TabOrder = 7
            OnClick = CheckBoxParametersClick
          end
          object CheckBoxMS: TCheckBox
            Left = 470
            Top = 10
            Width = 50
            Height = 17
            Caption = 'M+S'
            TabOrder = 8
            OnClick = CheckBoxParametersClick
          end
        end
      end
      object TabSheet5: TTabSheet
        Caption = 'P-Table'
        ImageIndex = 4
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object PaintBoxPTable: TPaintBox
          Tag = 1
          Left = 0
          Top = 33
          Width = 564
          Height = 455
          Align = alClient
          Constraints.MinHeight = 100
          Constraints.MinWidth = 100
          OnMouseDown = PaintBoxChartMouseDown
          OnMouseMove = PaintBoxChartMouseMove
          OnMouseUp = PaintBoxChartMouseUp
          OnPaint = PaintBoxChartPaint
          ExplicitLeft = 8
          ExplicitTop = 30
          ExplicitWidth = 551
        end
        object Panel6: TPanel
          Left = 0
          Top = 0
          Width = 564
          Height = 33
          Align = alTop
          BevelInner = bvLowered
          TabOrder = 0
          object SpeedButton4: TSpeedButton
            Tag = 1
            Left = 6
            Top = 6
            Width = 23
            Height = 22
            Hint = 'Setup profile'
            AllowAllUp = True
            GroupIndex = 1
            Down = True
            Flat = True
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              0400000000000001000000000000000000001000000000000000000000000000
              8000008000000080800080000000800080008080000080808000C0C0C0000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00BBBBBBBBBBBB
              BBBBBBBBBBBBBBBBBBBBBBBBBBBBB0BBBBBBBBBBBBBB8FBBBBBBBBBBBBBB00BB
              BBBBBBBBBBB8FFBBBBBBBBBBBBBB00BBBBBBBBB8BBB8FFBBBBBBBBBB0BB00BBB
              BBBBBBB8FB8FFBBBBBBBBBBB00B00BBBBBBBBBB8FF8FFBBBBBBBBBBB0000BBBB
              BBBBBBB8FFFFB8BBBBBBBBBB0000000BBBBBBBB8FFFFFFFBBBBBBBBB000000BB
              BBBBBBB8FFFFFFBBBBBBBBBB00000BBBBBBBBBB8FFFFFBBBBBBBBBBB0000BBBB
              BBBBBBB8FFFFBBBBBBBBBBBB000BBBBBBBBBBBBBFFFBBBBBBBBBBBBB00BBBBBB
              BBBBBBBBFFBBBBBBBBBBBBBB0BBBBBBBBBBBBBBBFBBBBBBBBBBBBBBBBBBBBBBB
              BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = ToolButtonClick
          end
          object SpeedButton5: TSpeedButton
            Tag = 2
            Left = 32
            Top = 6
            Width = 23
            Height = 22
            Hint = 'Setup Chart'
            AllowAllUp = True
            GroupIndex = 1
            Flat = True
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              0400000000000001000000000000000000001000000000000000000000000000
              8000008000000080800080000000800080008080000080808000C0C0C0000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00BBBBBBBBBBBB
              BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBFBBBBBBBBBBBBBBB0BBBBBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBBBBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBBBBBBBBBBBBBBF8BBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBF888BBBBCCCB0000B00000BBB888FFFFBFFFFFBBCCCBBBBB0BBB
              BBBBFFF8BBBBFBBBBBBBBBBBBBBB0BBBBBBBBBBBBBBBFBBBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBFBBBBBBBBBBBBBBB0BBBBBBBBBBBBBBBFBBBBBBBBBBBBBBB0BBB
              BBBBBBBBBBBBFBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = ToolButtonClick
          end
          object Bevel4: TBevel
            Left = 59
            Top = 8
            Width = 6
            Height = 18
            Shape = bsLeftLine
          end
          object SpeedButton6: TSpeedButton
            Left = 526
            Top = 6
            Width = 23
            Height = 22
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              04000000000000010000130B0000130B00001000000000000000000000000000
              800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333330070
              7700333333337777777733333333008088003333333377F73377333333330088
              88003333333377FFFF7733333333000000003FFFFFFF77777777000000000000
              000077777777777777770FFFFFFF0FFFFFF07F3333337F3333370FFFFFFF0FFF
              FFF07F3FF3FF7FFFFFF70F00F0080CCC9CC07F773773777777770FFFFFFFF039
              99337F3FFFF3F7F777F30F0000F0F09999937F7777373777777F0FFFFFFFF999
              99997F3FF3FFF77777770F00F000003999337F773777773777F30FFFF0FF0339
              99337F3FF7F3733777F30F08F0F0337999337F7737F73F7777330FFFF0039999
              93337FFFF7737777733300000033333333337777773333333333}
            NumGlyphs = 2
            OnClick = SpeedButton3Click
          end
          object RadioButtonMin: TRadioButton
            Left = 71
            Top = 10
            Width = 41
            Height = 17
            Caption = 'Min'
            TabOrder = 0
            OnClick = RadioButtonClick
          end
          object RadioButtonMax: TRadioButton
            Left = 112
            Top = 10
            Width = 41
            Height = 17
            Caption = 'Max'
            TabOrder = 1
            OnClick = RadioButtonClick
          end
          object RadioButtonMean: TRadioButton
            Left = 159
            Top = 10
            Width = 50
            Height = 17
            Caption = 'Mean'
            TabOrder = 2
            OnClick = RadioButtonClick
          end
          object RadioButtonStdDev: TRadioButton
            Left = 207
            Top = 10
            Width = 58
            Height = 17
            Caption = 'StdDev'
            Checked = True
            TabOrder = 3
            TabStop = True
            OnClick = RadioButtonClick
          end
          object RadioButton20: TRadioButton
            Left = 271
            Top = 10
            Width = 41
            Height = 17
            Caption = '20%'
            TabOrder = 4
            OnClick = RadioButtonClick
          end
          object RadioButton40: TRadioButton
            Left = 318
            Top = 10
            Width = 41
            Height = 17
            Caption = '40%'
            TabOrder = 5
            OnClick = RadioButtonClick
          end
          object RadioButton60: TRadioButton
            Left = 365
            Top = 10
            Width = 41
            Height = 17
            Caption = '60%'
            TabOrder = 6
            OnClick = RadioButtonClick
          end
          object RadioButton80: TRadioButton
            Left = 412
            Top = 10
            Width = 41
            Height = 17
            Caption = '80%'
            TabOrder = 7
            OnClick = RadioButtonClick
          end
          object RadioButtonMS: TRadioButton
            Left = 467
            Top = 10
            Width = 53
            Height = 17
            Caption = 'M+S'
            TabOrder = 8
            OnClick = RadioButtonClick
          end
        end
      end
    end
  end
  object SaveDialog: TSaveDialog
    Left = 800
  end
end
