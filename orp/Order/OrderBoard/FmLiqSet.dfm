object FrmLiqSet: TFrmLiqSet
  Left = 0
  Top = 0
  Width = 337
  Height = 78
  Color = clBtnFace
  ParentBackground = False
  ParentColor = False
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  object GroupBox3: TGroupBox
    Left = 0
    Top = 2
    Width = 309
    Height = 72
    Caption = #52404#44208#49884' '#51060#51061'/'#49552#49892#49444#51221' ( '#54217#44512#44032#44592#51456' )'
    TabOrder = 0
    object cbPrfLiquid: TCheckBox
      Left = 7
      Top = 21
      Width = 71
      Height = 17
      Caption = #51060#51061#49892#54788
      TabOrder = 0
    end
    object cbLosLiquid: TCheckBox
      Left = 7
      Top = 42
      Width = 71
      Height = 17
      Caption = #49552#49892#51228#54620
      TabOrder = 1
    end
    object udPrfTick: TUpDown
      Left = 110
      Top = 18
      Width = 16
      Height = 21
      Associate = edtPrfTick
      Max = 1000
      Position = 5
      TabOrder = 2
    end
    object udLosTick: TUpDown
      Left = 110
      Top = 39
      Width = 16
      Height = 21
      Associate = edtLosTick
      Max = 1000
      Position = 5
      TabOrder = 3
    end
    object edtPrfTick: TAlignedEdit
      Left = 76
      Top = 18
      Width = 34
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 4
      Text = '5'
      Alignment = clRight
      AlignType = atNumber
    end
    object edtLosTick: TAlignedEdit
      Tag = 1
      Left = 76
      Top = 39
      Width = 34
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 5
      Text = '5'
      Alignment = clRight
      AlignType = atNumber
    end
    object GroupBox5: TGroupBox
      Left = 183
      Top = 14
      Width = 122
      Height = 54
      Caption = #51452#47928#50976#54805
      TabOrder = 6
      object rbMarket: TRadioButton
        Left = 4
        Top = 14
        Width = 58
        Height = 17
        Caption = #49884#51109#44032
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object rbHoga: TRadioButton
        Left = 4
        Top = 33
        Width = 49
        Height = 17
        Caption = 'STOP'
        TabOrder = 1
      end
      object udLiqTick: TUpDown
        Left = 102
        Top = 29
        Width = 16
        Height = 21
        Associate = edtLiqTick
        Max = 10
        TabOrder = 2
      end
      object edtLiqTick: TAlignedEdit
        Tag = 2
        Left = 73
        Top = 29
        Width = 29
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 3
        Text = '0'
        Alignment = clRight
        AlignType = atNumber
      end
    end
    object Button5: TButton
      Left = 133
      Top = 18
      Width = 42
      Height = 21
      Caption = #51201#50857
      TabOrder = 7
    end
  end
end
