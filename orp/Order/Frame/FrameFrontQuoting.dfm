object FraFrontQuoting: TFraFrontQuoting
  Left = 0
  Top = 0
  Width = 367
  Height = 229
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 367
    Height = 229
    Align = alClient
    TabOrder = 0
    object plLeft: TPanel
      Left = 1
      Top = 1
      Width = 365
      Height = 125
      Align = alTop
      TabOrder = 0
      object btnExpand: TSpeedButton
        Tag = 1
        Left = 1
        Top = 109
        Width = 363
        Height = 15
        Align = alBottom
        AllowAllUp = True
        GroupIndex = 2
        Caption = #9660
        OnClick = btnExpandClick
        ExplicitTop = 105
        ExplicitWidth = 416
      end
      object gbBid: TGroupBox
        Left = 3
        Top = 26
        Width = 359
        Height = 88
        ParentBackground = False
        TabOrder = 0
        object Label6: TLabel
          Left = 5
          Top = 15
          Width = 48
          Height = 13
          Caption = #54840'        '#44032
        end
        object Label7: TLabel
          Left = 110
          Top = 13
          Width = 48
          Height = 13
          Caption = #49444#51221#51092#47049
        end
        object Label8: TLabel
          Left = 110
          Top = 40
          Width = 48
          Height = 13
          Caption = #51452#47928#49688#47049
        end
        object Label9: TLabel
          Left = 5
          Top = 40
          Width = 48
          Height = 13
          Caption = #51452#47928#44148#49688
        end
        object lbTag: TLabel
          Left = 295
          Top = 46
          Width = 60
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
        object cbBid: TComboBox
          Left = 58
          Top = 10
          Width = 46
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
          Left = 164
          Top = 37
          Width = 47
          Height = 21
          ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
          TabOrder = 1
          Text = '10'
          OnChange = cbBidChange
          OnKeyPress = edtBidCntKeyPress
        end
        object edtBidCnt: TEdit
          Tag = 30
          Left = 58
          Top = 37
          Width = 46
          Height = 21
          ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
          TabOrder = 2
          Text = '1'
          OnChange = cbBidChange
          OnKeyPress = edtBidCntKeyPress
        end
        object cbBidFront: TCheckBox
          Left = 220
          Top = 10
          Width = 54
          Height = 17
          Caption = 'Front'
          Checked = True
          State = cbChecked
          TabOrder = 3
          OnClick = cbBidFrontClick
        end
        object cbFillOrd: TCheckBox
          Left = 220
          Top = 27
          Width = 84
          Height = 17
          Caption = #51452#47928#52292#50864#44592
          TabOrder = 4
          OnClick = cbBidFrontClick
        end
        object edtStart: TEdit
          Tag = 20
          Left = 169
          Top = 62
          Width = 23
          Height = 21
          ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
          TabOrder = 5
          Text = '10'
          OnChange = cbBidChange
          OnKeyPress = edtBidCntKeyPress
        end
        object dtStart: TDateTimePicker
          Left = 75
          Top = 62
          Width = 94
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
          TabOrder = 6
          OnChange = cbBidChange
        end
        object udMs: TUpDown
          Left = 192
          Top = 62
          Width = 21
          Height = 21
          Associate = edtStart
          Max = 59
          Position = 10
          TabOrder = 7
        end
        object cbStart: TCheckBox
          Left = 4
          Top = 64
          Width = 70
          Height = 17
          Caption = #49884#51089#49884#44033
          TabOrder = 8
          OnClick = cbBidFrontClick
        end
        object cbVol: TComboBox
          Left = 164
          Top = 10
          Width = 47
          Height = 21
          DropDownCount = 10
          ImeName = 'Microsoft Office IME 2007'
          ItemHeight = 13
          TabOrder = 9
          Text = '100'
          OnChange = cbBidChange
        end
        object cbVolStop: TCheckBox
          Left = 220
          Top = 45
          Width = 74
          Height = 17
          Caption = #51092#47049#49828#53457
          TabOrder = 10
          OnClick = cbBidFrontClick
        end
        object edtVolStop: TEdit
          Tag = 20
          Left = 235
          Top = 64
          Width = 29
          Height = 21
          ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
          TabOrder = 11
          Text = '10'
          OnChange = cbBidChange
          OnKeyPress = edtBidCntKeyPress
        end
        object cbFill: TCheckBox
          Left = 268
          Top = 65
          Width = 14
          Height = 17
          TabOrder = 12
          OnClick = cbBidFrontClick
        end
        object cbQty: TCheckBox
          Left = 220
          Top = 64
          Width = 15
          Height = 17
          TabOrder = 13
          OnClick = cbBidFrontClick
        end
        object edtVolStopFill: TEdit
          Tag = 20
          Left = 283
          Top = 64
          Width = 29
          Height = 21
          ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
          TabOrder = 14
          Text = '10'
          OnChange = cbBidChange
          OnKeyPress = edtBidCntKeyPress
        end
        object cbVolStopOR: TCheckBox
          Left = 317
          Top = 65
          Width = 36
          Height = 18
          Caption = 'OR'
          TabOrder = 15
          OnClick = cbBidFrontClick
        end
        object cbUseMoth: TCheckBox
          Left = 305
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
          TabOrder = 16
          OnClick = cbUseMothClick
        end
      end
      object Panel4: TPanel
        Left = 67
        Top = 3
        Width = 60
        Height = 21
        TabOrder = 1
      end
      object Panel5: TPanel
        Left = 4
        Top = 3
        Width = 60
        Height = 21
        TabOrder = 2
      end
      object panBid: TPanel
        Left = 136
        Top = 2
        Width = 60
        Height = 23
        BevelInner = bvRaised
        Caption = 'BID START'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentFont = False
        TabOrder = 3
        OnClick = panBidClick
      end
      object panAsk: TPanel
        Tag = 2
        Left = 198
        Top = 2
        Width = 60
        Height = 23
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
      object btnStop: TButton
        Left = 311
        Top = 2
        Width = 50
        Height = 23
        Caption = 'Stop'
        TabOrder = 5
        OnClick = btnStopClick
      end
      object btnStart: TButton
        Left = 262
        Top = 2
        Width = 50
        Height = 23
        Caption = 'Start'
        TabOrder = 6
        OnClick = btnStartClick
      end
    end
    object plRight: TPanel
      Left = 1
      Top = 126
      Width = 365
      Height = 102
      Align = alClient
      TabOrder = 1
      object Panel6: TPanel
        Left = 1
        Top = 1
        Width = 363
        Height = 24
        Align = alTop
        TabOrder = 0
        object btnClear: TButton
          Left = 66
          Top = 2
          Width = 54
          Height = 19
          Caption = 'Clear'
          TabOrder = 0
          OnClick = btnClearClick
        end
        object btnLoad: TButton
          Left = 6
          Top = 2
          Width = 54
          Height = 19
          Caption = 'Load'
          TabOrder = 1
          OnClick = btnLoadClick
        end
      end
      object Panel7: TPanel
        Left = 1
        Top = 25
        Width = 363
        Height = 76
        Align = alClient
        TabOrder = 1
        object listOrder: TListView
          Left = 1
          Top = 1
          Width = 361
          Height = 74
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
    end
  end
end
