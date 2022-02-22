object FraOrderManage: TFraOrderManage
  Left = 0
  Top = 0
  Width = 367
  Height = 103
  TabOrder = 0
  object plLeft: TPanel
    Left = 0
    Top = 0
    Width = 367
    Height = 100
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentFont = False
    TabOrder = 0
    object gbOrder: TGroupBox
      Left = 191
      Top = -1
      Width = 174
      Height = 78
      Hint = #48276#50948#45236' '#52404#44208#44032#45733' '#51452#47928' '#52712#49548
      Align = alCustom
      Color = clBtnFace
      ParentBackground = False
      ParentColor = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      object Label4: TLabel
        Left = 51
        Top = 60
        Width = 34
        Height = 13
        Caption = #47588#49688' : '
      end
      object Label5: TLabel
        Left = 51
        Top = 35
        Width = 34
        Height = 13
        Caption = #47588#46020' : '
      end
      object lbTag: TLabel
        Left = 122
        Top = 58
        Width = 49
        Height = 16
        Alignment = taRightJustify
        AutoSize = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object cbRun: TCheckBox
        Left = 8
        Top = 10
        Width = 42
        Height = 17
        Caption = #49892#54665
        TabOrder = 0
        OnClick = cbRunClick
      end
      object edtAsk2: TEdit
        Left = 83
        Top = 30
        Width = 23
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 1
        Text = '1'
        OnChange = edtAsk2Change
        OnKeyPress = edtAsk2KeyPress
      end
      object edtBid2: TEdit
        Left = 82
        Top = 55
        Width = 23
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 2
        Text = '1'
        OnChange = edtAsk2Change
        OnKeyPress = edtAsk2KeyPress
      end
      object Button2: TButton
        Left = 6
        Top = 52
        Width = 39
        Height = 22
        Caption = 'Logs'
        TabOrder = 3
        OnClick = Button2Click
      end
      object udAsk2: TUpDown
        Left = 106
        Top = 30
        Width = 16
        Height = 21
        Associate = edtAsk2
        Min = 1
        Position = 1
        TabOrder = 4
      end
      object udBid2: TUpDown
        Left = 105
        Top = 55
        Width = 16
        Height = 21
        Associate = edtBid2
        Min = 1
        Position = 1
        TabOrder = 5
      end
      object cbVolStop: TCheckBox
        Left = 52
        Top = 10
        Width = 67
        Height = 17
        Caption = #51092#47049#49828#53457
        TabOrder = 6
        OnClick = cbVolStopClick
      end
      object cbUseMoth: TCheckBox
        Left = 121
        Top = 10
        Width = 49
        Height = 17
        Caption = 'Moth'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMaroon
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 7
        OnClick = cbUseMothClick
      end
    end
    object gbPos: TGroupBox
      Tag = 1
      Left = 3
      Top = -1
      Width = 187
      Height = 78
      Hint = #48276#50948#45236' '#52404#44208#44032#45733' '#51452#47928#52712#49548' ( '#52572#45824#54252#51648#49496' '#44256#47140' )'
      Align = alCustom
      Color = clBtnFace
      ParentBackground = False
      ParentColor = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      object Label1: TLabel
        Left = 44
        Top = 36
        Width = 31
        Height = 13
        Caption = #47588#46020': '
      end
      object Label2: TLabel
        Left = 44
        Top = 58
        Width = 31
        Height = 13
        Caption = #47588#49688': '
      end
      object Label3: TLabel
        Left = 113
        Top = 36
        Width = 34
        Height = 13
        Caption = #47588#46020' : '
      end
      object Label6: TLabel
        Left = 113
        Top = 59
        Width = 34
        Height = 13
        Caption = #47588#49688' : '
      end
      object chSavePosRun: TCheckBox
        Left = 4
        Top = 10
        Width = 51
        Height = 17
        Caption = #49892#54665
        TabOrder = 0
        OnClick = chSavePosRunClick
      end
      object edtAsk: TEdit
        Left = 73
        Top = 31
        Width = 23
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 1
        Text = '1'
        OnChange = edtAskChange
        OnKeyPress = edtAsk2KeyPress
      end
      object edtBid: TEdit
        Left = 73
        Top = 54
        Width = 23
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 2
        Text = '1'
        OnChange = edtAskChange
        OnKeyPress = edtAsk2KeyPress
      end
      object edtAskPos: TEdit
        Left = 146
        Top = 31
        Width = 23
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 3
        Text = '1'
        OnChange = edtAskChange
        OnKeyPress = edtAskPosKeyPress
      end
      object Button1: TButton
        Tag = 1
        Left = 4
        Top = 51
        Width = 39
        Height = 22
        Caption = 'Logs'
        TabOrder = 4
        OnClick = Button2Click
      end
      object Panel2: TPanel
        Left = 47
        Top = 7
        Width = 60
        Height = 22
        Caption = #54840#44032' '#47112#48296
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 5
      end
      object Panel3: TPanel
        Left = 111
        Top = 8
        Width = 72
        Height = 22
        Caption = #54252#51648#49496#49688#47049
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 6
      end
      object edtBidPos: TEdit
        Left = 146
        Top = 54
        Width = 23
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 7
        Text = '1'
        OnChange = edtAskChange
        OnKeyPress = edtAskPosKeyPress
      end
      object udAsk: TUpDown
        Left = 96
        Top = 31
        Width = 16
        Height = 21
        Associate = edtAsk
        Min = 1
        Position = 1
        TabOrder = 8
      end
      object udBid: TUpDown
        Left = 96
        Top = 54
        Width = 16
        Height = 21
        Associate = edtBid
        Min = 1
        Position = 1
        TabOrder = 9
      end
      object udAskPos: TUpDown
        Left = 169
        Top = 31
        Width = 16
        Height = 21
        Associate = edtAskPos
        Min = 1
        Max = 9000
        Position = 1
        TabOrder = 10
      end
      object udBidPos: TUpDown
        Left = 169
        Top = 54
        Width = 16
        Height = 21
        Associate = edtBidPos
        Min = 1
        Max = 9000
        Position = 1
        TabOrder = 11
      end
    end
    object stBar: TStatusBar
      Left = 1
      Top = 78
      Width = 365
      Height = 21
      Panels = <
        item
          Width = 150
        end
        item
          Width = 50
        end>
    end
  end
  object plRight: TPanel
    Left = 0
    Top = 100
    Width = 367
    Height = 3
    Align = alClient
    TabOrder = 1
    object GroupBox1: TGroupBox
      Left = 1
      Top = 1
      Width = 365
      Height = 50
      Align = alTop
      Caption = #51204#52404' '#52712#49548
      Color = clBtnFace
      ParentBackground = False
      ParentColor = False
      TabOrder = 0
      Visible = False
      object Label7: TLabel
        Left = 68
        Top = 21
        Width = 34
        Height = 13
        Caption = #44148#49688' : '
      end
      object Label8: TLabel
        Left = 139
        Top = 20
        Width = 41
        Height = 13
        Caption = 'Inteval :'
      end
      object edtAllCnlQty: TEdit
        Left = 100
        Top = 16
        Width = 37
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 0
        Text = '10'
        OnKeyPress = edtAsk2KeyPress
      end
      object edtAllCnlInterval: TEdit
        Left = 181
        Top = 16
        Width = 37
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 1
        Text = '300'
        OnKeyPress = edtAsk2KeyPress
      end
      object Button3: TButton
        Tag = 1
        Left = 12
        Top = 18
        Width = 39
        Height = 22
        Caption = #49892' '#54665
        TabOrder = 2
        OnClick = Button3Click
      end
      object Button4: TButton
        Tag = 2
        Left = 225
        Top = 16
        Width = 39
        Height = 22
        Caption = 'Logs'
        TabOrder = 3
        OnClick = Button2Click
      end
    end
  end
  object CnlTimer: TTimer
    Enabled = False
    OnTimer = CnlTimerTimer
    Left = 96
    Top = 72
  end
end
