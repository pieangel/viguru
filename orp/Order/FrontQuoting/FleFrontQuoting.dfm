object FrontQuotingForm: TFrontQuotingForm
  Left = 0
  Top = 0
  Caption = 'Front Quoting'
  ClientHeight = 298
  ClientWidth = 603
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 21
    Width = 161
    Height = 277
    Align = alLeft
    ParentColor = True
    TabOrder = 0
    object gbBid: TGroupBox
      Left = 1
      Top = 1
      Width = 159
      Height = 275
      Align = alClient
      ParentBackground = False
      TabOrder = 0
      object Label6: TLabel
        Left = 15
        Top = 8
        Width = 48
        Height = 13
        Caption = #54840'        '#44032
      end
      object Label7: TLabel
        Left = 14
        Top = 34
        Width = 48
        Height = 13
        Caption = #49444#51221#51092#47049
      end
      object Label8: TLabel
        Left = 14
        Top = 87
        Width = 48
        Height = 13
        Caption = #51452#47928#49688#47049
      end
      object Label9: TLabel
        Left = 14
        Top = 60
        Width = 48
        Height = 13
        Caption = #51452#47928#44148#49688
      end
      object cbBid: TComboBox
        Left = 68
        Top = 3
        Width = 83
        Height = 21
        Style = csDropDownList
        BiDiMode = bdLeftToRight
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        ItemHeight = 13
        ItemIndex = 2
        ParentBiDiMode = False
        TabOrder = 0
        Text = '3'
        OnChange = cbBidChange
        Items.Strings = (
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8'
          '9'
          '10')
      end
      object edtBidQty: TEdit
        Tag = 20
        Left = 67
        Top = 84
        Width = 82
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 1
        Text = '10'
        OnChange = edtBidHogaChange
        OnKeyPress = edtBidHogaKeyPress
      end
      object edtBidCnt: TEdit
        Tag = 30
        Left = 67
        Top = 57
        Width = 82
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 2
        Text = '1'
        OnChange = edtBidHogaChange
        OnKeyPress = edtBidHogaKeyPress
      end
      object cbBidFront: TCheckBox
        Left = 14
        Top = 111
        Width = 49
        Height = 17
        Caption = 'Front'
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = cbBidFrontClick
      end
      object panAsk: TPanel
        Tag = 2
        Left = 81
        Top = 219
        Width = 67
        Height = 25
        BevelInner = bvRaised
        Caption = 'ASK START'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 4
        OnClick = panBidClick
      end
      object panBid: TPanel
        Left = 12
        Top = 219
        Width = 67
        Height = 25
        BevelInner = bvRaised
        Caption = 'BID START'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 5
        OnClick = panBidClick
      end
      object cbFillOrd: TCheckBox
        Left = 72
        Top = 111
        Width = 79
        Height = 17
        Caption = #51452#47928#52292#50864#44592
        TabOrder = 6
        OnClick = cbBidFrontClick
      end
      object edtStart: TEdit
        Tag = 20
        Left = 112
        Top = 153
        Width = 18
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 7
        Text = '10'
        OnChange = edtBidHogaChange
        OnKeyPress = edtBidHogaKeyPress
      end
      object dtStart: TDateTimePicker
        Left = 13
        Top = 153
        Width = 99
        Height = 21
        BiDiMode = bdLeftToRight
        Date = 38303.375011574070000000
        Time = 38303.375011574070000000
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
        TabOrder = 8
        OnChange = edtBidHogaChange
      end
      object udMs: TUpDown
        Left = 130
        Top = 153
        Width = 17
        Height = 21
        Associate = edtStart
        Max = 59
        Position = 10
        TabOrder = 9
      end
      object cbStart: TCheckBox
        Left = 14
        Top = 130
        Width = 97
        Height = 17
        Caption = #49884#51089#49884#44033' '#49324#50857
        TabOrder = 10
        OnClick = cbBidFrontClick
      end
      object cbVol: TComboBox
        Left = 68
        Top = 31
        Width = 82
        Height = 21
        DropDownCount = 10
        ImeName = 'Microsoft Office IME 2007'
        ItemHeight = 13
        TabOrder = 11
        Text = '100'
        OnChange = edtBidHogaChange
        OnKeyPress = edtBidHogaKeyPress
      end
      object btnStart: TButton
        Left = 13
        Top = 247
        Width = 67
        Height = 25
        Caption = 'Start'
        TabOrder = 12
        OnClick = btnStartClick
      end
      object cbVolStop: TCheckBox
        Left = 14
        Top = 176
        Width = 69
        Height = 17
        Caption = #51092#47049#49828#53457
        TabOrder = 13
        OnClick = cbBidFrontClick
      end
      object edtVolStop: TEdit
        Tag = 20
        Left = 34
        Top = 195
        Width = 30
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 14
        Text = '10'
        OnChange = edtBidHogaChange
        OnKeyPress = edtBidHogaKeyPress
      end
      object edtVolStopFill: TEdit
        Tag = 20
        Left = 85
        Top = 195
        Width = 30
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 15
        Text = '10'
        OnChange = edtBidHogaChange
        OnKeyPress = edtBidHogaKeyPress
      end
      object cbVolStopOR: TCheckBox
        Left = 119
        Top = 197
        Width = 38
        Height = 17
        Caption = 'OR'
        TabOrder = 16
        OnClick = cbBidFrontClick
      end
      object cbQty: TCheckBox
        Left = 14
        Top = 197
        Width = 16
        Height = 17
        TabOrder = 17
        OnClick = cbBidFrontClick
      end
      object cbFill: TCheckBox
        Left = 67
        Top = 197
        Width = 16
        Height = 17
        TabOrder = 18
        OnClick = cbBidFrontClick
      end
    end
    object btnStop: TButton
      Left = 81
      Top = 248
      Width = 67
      Height = 25
      Caption = 'Stop'
      TabOrder = 1
      OnClick = btnStopClick
    end
  end
  object Panel2: TPanel
    Left = 161
    Top = 21
    Width = 442
    Height = 277
    Align = alClient
    TabOrder = 1
    object listOrder: TListView
      Left = 1
      Top = 1
      Width = 440
      Height = 275
      Align = alClient
      Columns = <
        item
          Caption = #48264#54840
          Width = 40
        end
        item
          Alignment = taCenter
          Caption = #49884#44036
          Width = 80
        end
        item
          Alignment = taCenter
          Caption = #51333#47785#53076#46300
          Width = 90
        end
        item
          Alignment = taCenter
          Caption = #54840#44032
        end
        item
          Alignment = taRightJustify
          Caption = #51092#47049
          Width = 40
        end
        item
          Alignment = taRightJustify
          Caption = #44032#44201
        end>
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 603
    Height = 21
    Align = alTop
    ParentColor = True
    TabOrder = 2
    object SpeedButton1: TSpeedButton
      Left = 202
      Top = 0
      Width = 23
      Height = 19
      Caption = '...'
      OnClick = ButtonSymbolClick
    end
    object ButtonSymbol: TSpeedButton
      Left = 242
      Top = 0
      Width = 23
      Height = 19
      Caption = '...'
      OnClick = ButtonSymbolClick
    end
    object ComboAccount: TComboBox
      Left = 0
      Top = 0
      Width = 137
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 0
      OnChange = ComboAccountChange
    end
    object ComboSymbol: TComboBox
      Left = 136
      Top = 0
      Width = 105
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 1
      OnChange = ComboSymbolChange
    end
    object btnLoad: TButton
      Left = 268
      Top = 0
      Width = 54
      Height = 19
      Caption = 'Load'
      TabOrder = 2
      OnClick = btnLoadClick
    end
    object btnClear: TButton
      Left = 325
      Top = 0
      Width = 54
      Height = 19
      Caption = 'Clear'
      TabOrder = 3
      OnClick = btnClearClick
    end
    object Panel4: TPanel
      Left = 380
      Top = 0
      Width = 60
      Height = 19
      TabOrder = 4
    end
    object Panel5: TPanel
      Left = 440
      Top = 0
      Width = 60
      Height = 19
      TabOrder = 5
    end
    object cbUseMoth: TCheckBox
      Left = 507
      Top = 3
      Width = 82
      Height = 17
      Caption = 'Use Moth'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      TabOrder = 6
      OnClick = cbUseMothClick
    end
  end
end
