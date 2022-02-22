object KOrderConfigDlg: TKOrderConfigDlg
  Left = 365
  Top = 255
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #53412#48372#46300' '#51452#47928' '#49444#51221
  ClientHeight = 420
  ClientWidth = 649
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548#52404
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 603
    Top = 28
    Width = 35
    Height = 13
    Caption = #51333#47785'A'
  end
  object Label3: TLabel
    Left = 603
    Top = 204
    Width = 35
    Height = 13
    Caption = #51333#47785'B'
  end
  object Bevel1: TBevel
    Left = 0
    Top = 205
    Width = 385
    Height = 77
  end
  object Label4: TLabel
    Left = 16
    Top = 237
    Width = 32
    Height = 13
    Caption = 'Ctrl'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548#52404
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 16
    Top = 213
    Width = 54
    Height = 13
    Caption = #44536#45285' : '
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548#52404
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 16
    Top = 261
    Width = 40
    Height = 13
    Caption = 'Alt :'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548#52404
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 8
    Top = 290
    Width = 100
    Height = 13
    Caption = '<<'#50676#47536' '#54868#47732'>>'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548#52404
    Font.Style = [fsBold]
    ParentFont = False
  end
  object BtnRunStop: TSpeedButton
    Left = 136
    Top = 285
    Width = 63
    Height = 22
    Caption = 'Stopped'
    OnClick = BtnRunStopClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 27
    Width = 385
    Height = 175
    BevelInner = bvSpace
    BevelOuter = bvLowered
    TabOrder = 0
    object PanelF1: TPanel
      Left = 8
      Top = 8
      Width = 25
      Height = 25
      Caption = 'F1'
      TabOrder = 0
      OnClick = KeyActionShow
    end
    object PanelF2: TPanel
      Left = 34
      Top = 8
      Width = 25
      Height = 25
      Caption = 'F2'
      TabOrder = 1
      OnClick = KeyActionShow
    end
    object PanelF3: TPanel
      Left = 60
      Top = 8
      Width = 25
      Height = 25
      Caption = 'F3'
      TabOrder = 2
      OnClick = KeyActionShow
    end
    object PanelF4: TPanel
      Left = 85
      Top = 8
      Width = 25
      Height = 25
      Caption = 'F4'
      TabOrder = 3
      OnClick = KeyActionShow
    end
    object PanelF5: TPanel
      Left = 139
      Top = 8
      Width = 25
      Height = 25
      Caption = 'F5'
      TabOrder = 4
      OnClick = KeyActionShow
    end
    object PanelF6: TPanel
      Left = 165
      Top = 8
      Width = 25
      Height = 25
      Caption = 'F6'
      TabOrder = 5
      OnClick = KeyActionShow
    end
    object Panel8: TPanel
      Left = 191
      Top = 8
      Width = 25
      Height = 25
      Caption = 'F7'
      TabOrder = 6
      OnClick = KeyActionShow
    end
    object Panel9: TPanel
      Left = 216
      Top = 8
      Width = 25
      Height = 25
      Caption = 'F8'
      TabOrder = 7
      OnClick = KeyActionShow
    end
    object Panel10: TPanel
      Left = 275
      Top = 8
      Width = 25
      Height = 25
      Caption = 'F9'
      TabOrder = 8
      OnClick = KeyActionShow
    end
    object Panel11: TPanel
      Left = 301
      Top = 8
      Width = 25
      Height = 25
      Caption = 'F10'
      TabOrder = 9
      OnClick = KeyActionShow
    end
    object Panel12: TPanel
      Left = 327
      Top = 8
      Width = 25
      Height = 25
      Caption = 'F11'
      TabOrder = 10
      OnClick = KeyActionShow
    end
    object Panel13: TPanel
      Left = 352
      Top = 8
      Width = 25
      Height = 25
      Caption = 'F12'
      TabOrder = 11
      OnClick = KeyActionShow
    end
    object PanelGrave: TPanel
      Tag = 96
      Left = 8
      Top = 40
      Width = 25
      Height = 25
      Caption = '`'
      TabOrder = 12
      OnClick = KeyActionShow
    end
    object PanelNum1: TPanel
      Tag = 49
      Left = 34
      Top = 40
      Width = 25
      Height = 25
      Caption = '1'
      TabOrder = 13
      OnClick = KeyActionShow
    end
    object PanelNum2: TPanel
      Tag = 50
      Left = 60
      Top = 40
      Width = 25
      Height = 25
      Caption = '2'
      TabOrder = 14
      OnClick = KeyActionShow
    end
    object PanelNum3: TPanel
      Tag = 51
      Left = 85
      Top = 40
      Width = 25
      Height = 25
      Caption = '3'
      TabOrder = 15
      OnClick = KeyActionShow
    end
    object PanelNum4: TPanel
      Tag = 52
      Left = 112
      Top = 40
      Width = 25
      Height = 25
      Caption = '4'
      TabOrder = 16
      OnClick = KeyActionShow
    end
    object PanelNum5: TPanel
      Tag = 53
      Left = 138
      Top = 40
      Width = 25
      Height = 25
      Caption = '5'
      TabOrder = 17
      OnClick = KeyActionShow
    end
    object PanelNum6: TPanel
      Tag = 54
      Left = 164
      Top = 40
      Width = 25
      Height = 25
      Caption = '6'
      TabOrder = 18
      OnClick = KeyActionShow
    end
    object PanelNum7: TPanel
      Tag = 55
      Left = 189
      Top = 40
      Width = 25
      Height = 25
      Caption = '7'
      TabOrder = 19
      OnClick = KeyActionShow
    end
    object PanelNum8: TPanel
      Tag = 56
      Left = 216
      Top = 40
      Width = 25
      Height = 25
      Caption = '8'
      TabOrder = 20
      OnClick = KeyActionShow
    end
    object PanelNum9: TPanel
      Tag = 57
      Left = 242
      Top = 40
      Width = 25
      Height = 25
      Caption = '9'
      TabOrder = 21
      OnClick = KeyActionShow
    end
    object PanelNum0: TPanel
      Tag = 48
      Left = 268
      Top = 40
      Width = 25
      Height = 25
      Caption = '0'
      TabOrder = 22
      OnClick = KeyActionShow
    end
    object PanelHyphen: TPanel
      Tag = 45
      Left = 293
      Top = 40
      Width = 25
      Height = 25
      Caption = '-'
      TabOrder = 23
      OnClick = KeyActionShow
    end
    object PanelEqual: TPanel
      Tag = 61
      Left = 320
      Top = 40
      Width = 25
      Height = 25
      Caption = '='
      TabOrder = 24
      OnClick = KeyActionShow
    end
    object Panel31: TPanel
      Left = 346
      Top = 40
      Width = 31
      Height = 25
      BevelInner = bvLowered
      BevelOuter = bvNone
      Caption = '<-'
      TabOrder = 25
    end
    object Panel32: TPanel
      Left = 8
      Top = 66
      Width = 40
      Height = 25
      Caption = 'TAB'
      TabOrder = 26
    end
    object PanelQ: TPanel
      Tag = 81
      Left = 48
      Top = 66
      Width = 25
      Height = 25
      Caption = 'Q'
      TabOrder = 27
      OnClick = KeyActionShow
    end
    object PanelW: TPanel
      Tag = 87
      Left = 73
      Top = 66
      Width = 25
      Height = 25
      Caption = 'W'
      TabOrder = 28
      OnClick = KeyActionShow
    end
    object PanelE: TPanel
      Tag = 69
      Left = 99
      Top = 66
      Width = 25
      Height = 25
      Caption = 'E'
      TabOrder = 29
      OnClick = KeyActionShow
    end
    object PanelR: TPanel
      Tag = 82
      Left = 124
      Top = 66
      Width = 25
      Height = 25
      Caption = 'R'
      TabOrder = 30
      OnClick = KeyActionShow
    end
    object PanelT: TPanel
      Tag = 84
      Left = 149
      Top = 66
      Width = 25
      Height = 25
      Caption = 'T'
      TabOrder = 31
      OnClick = KeyActionShow
    end
    object PanelY: TPanel
      Tag = 89
      Left = 174
      Top = 66
      Width = 25
      Height = 25
      Caption = 'Y'
      TabOrder = 32
      OnClick = KeyActionShow
    end
    object PanelU: TPanel
      Tag = 85
      Left = 200
      Top = 66
      Width = 25
      Height = 25
      Caption = 'U'
      TabOrder = 33
      OnClick = KeyActionShow
    end
    object PanelI: TPanel
      Tag = 73
      Left = 225
      Top = 66
      Width = 25
      Height = 25
      Caption = 'I'
      TabOrder = 34
      OnClick = KeyActionShow
    end
    object PanelO: TPanel
      Tag = 79
      Left = 250
      Top = 66
      Width = 25
      Height = 25
      Caption = 'O'
      TabOrder = 35
      OnClick = KeyActionShow
    end
    object PanelP: TPanel
      Tag = 80
      Left = 275
      Top = 66
      Width = 25
      Height = 25
      Caption = 'P'
      TabOrder = 36
      OnClick = KeyActionShow
    end
    object PanelLeftBraket: TPanel
      Tag = 91
      Left = 301
      Top = 66
      Width = 25
      Height = 25
      Caption = '['
      TabOrder = 37
      OnClick = KeyActionShow
    end
    object PanelRightBraket: TPanel
      Tag = 93
      Left = 326
      Top = 66
      Width = 25
      Height = 25
      Caption = ']'
      TabOrder = 38
      OnClick = KeyActionShow
    end
    object PanelBackSlash: TPanel
      Tag = 92
      Left = 352
      Top = 66
      Width = 25
      Height = 25
      Caption = '\'
      TabOrder = 39
      OnClick = KeyActionShow
    end
    object PanelA: TPanel
      Tag = 65
      Left = 53
      Top = 91
      Width = 25
      Height = 25
      Caption = 'A'
      TabOrder = 40
      OnClick = KeyActionShow
    end
    object PanelS: TPanel
      Tag = 83
      Left = 78
      Top = 91
      Width = 25
      Height = 25
      Caption = 'S'
      TabOrder = 41
      OnClick = KeyActionShow
    end
    object PanelD: TPanel
      Tag = 68
      Left = 104
      Top = 91
      Width = 25
      Height = 25
      Caption = 'D'
      TabOrder = 42
      OnClick = KeyActionShow
    end
    object PanelF: TPanel
      Tag = 70
      Left = 129
      Top = 91
      Width = 25
      Height = 25
      Caption = 'F'
      TabOrder = 43
      OnClick = KeyActionShow
    end
    object PanelG: TPanel
      Tag = 71
      Left = 154
      Top = 91
      Width = 25
      Height = 25
      Caption = 'G'
      TabOrder = 44
      OnClick = KeyActionShow
    end
    object PanelH: TPanel
      Tag = 72
      Left = 179
      Top = 91
      Width = 25
      Height = 25
      Caption = 'H'
      TabOrder = 45
      OnClick = KeyActionShow
    end
    object PanelJ: TPanel
      Tag = 74
      Left = 205
      Top = 91
      Width = 25
      Height = 25
      Caption = 'J'
      TabOrder = 46
      OnClick = KeyActionShow
    end
    object PanelK: TPanel
      Tag = 75
      Left = 230
      Top = 91
      Width = 25
      Height = 25
      Caption = 'K'
      TabOrder = 47
      OnClick = KeyActionShow
    end
    object PanelL: TPanel
      Tag = 76
      Left = 255
      Top = 91
      Width = 25
      Height = 25
      Caption = 'L'
      TabOrder = 48
      OnClick = KeyActionShow
    end
    object PanelSemicolon: TPanel
      Tag = 59
      Left = 280
      Top = 91
      Width = 25
      Height = 25
      Caption = ';'
      TabOrder = 49
      OnClick = KeyActionShow
    end
    object PanelAposterophe: TPanel
      Tag = 39
      Left = 306
      Top = 91
      Width = 25
      Height = 25
      Caption = #39
      TabOrder = 50
      OnClick = KeyActionShow
    end
    object Panel57: TPanel
      Left = 333
      Top = 91
      Width = 44
      Height = 25
      BevelInner = bvLowered
      BevelOuter = bvNone
      Caption = 'Enter'
      TabOrder = 51
    end
    object PanelZ: TPanel
      Tag = 90
      Left = 64
      Top = 117
      Width = 25
      Height = 25
      Caption = 'Z'
      TabOrder = 52
      OnClick = KeyActionShow
    end
    object PanelX: TPanel
      Tag = 88
      Left = 89
      Top = 117
      Width = 25
      Height = 25
      Caption = 'X'
      TabOrder = 53
      OnClick = KeyActionShow
    end
    object PanelC: TPanel
      Tag = 67
      Left = 115
      Top = 117
      Width = 25
      Height = 25
      Caption = 'C'
      TabOrder = 54
      OnClick = KeyActionShow
    end
    object PanelV: TPanel
      Tag = 86
      Left = 140
      Top = 117
      Width = 25
      Height = 25
      Caption = 'V'
      TabOrder = 55
      OnClick = KeyActionShow
    end
    object PanelB: TPanel
      Tag = 66
      Left = 165
      Top = 117
      Width = 25
      Height = 25
      Caption = 'B'
      TabOrder = 56
      OnClick = KeyActionShow
    end
    object PanelN: TPanel
      Tag = 78
      Left = 190
      Top = 117
      Width = 25
      Height = 25
      Caption = 'N'
      TabOrder = 57
      OnClick = KeyActionShow
    end
    object PanelM: TPanel
      Tag = 77
      Left = 216
      Top = 117
      Width = 25
      Height = 25
      Caption = 'M'
      TabOrder = 58
      OnClick = KeyActionShow
    end
    object PenelComma: TPanel
      Tag = 44
      Left = 241
      Top = 117
      Width = 25
      Height = 25
      Caption = ','
      TabOrder = 59
      OnClick = KeyActionShow
    end
    object PenelPeriod: TPanel
      Tag = 46
      Left = 266
      Top = 117
      Width = 25
      Height = 25
      Caption = '.'
      TabOrder = 60
      OnClick = KeyActionShow
    end
    object PenelSlash: TPanel
      Tag = 47
      Left = 291
      Top = 117
      Width = 25
      Height = 25
      Caption = '/'
      TabOrder = 61
      OnClick = KeyActionShow
    end
    object Panel69: TPanel
      Left = 317
      Top = 117
      Width = 60
      Height = 25
      Caption = 'Shift'
      TabOrder = 62
    end
    object Panel72: TPanel
      Left = 8
      Top = 91
      Width = 44
      Height = 25
      Caption = 'Cap'
      TabOrder = 63
    end
    object Panel73: TPanel
      Left = 8
      Top = 117
      Width = 54
      Height = 25
      Caption = 'Shift'
      TabOrder = 64
    end
    object Panel58: TPanel
      Left = 8
      Top = 143
      Width = 54
      Height = 25
      BevelInner = bvLowered
      BevelOuter = bvNone
      Caption = 'Ctrl'
      TabOrder = 65
    end
    object Panel70: TPanel
      Left = 65
      Top = 143
      Width = 54
      Height = 25
      BevelInner = bvLowered
      BevelOuter = bvNone
      Caption = 'Alt'
      TabOrder = 66
    end
    object Panel71: TPanel
      Left = 121
      Top = 143
      Width = 144
      Height = 25
      Caption = 'Space'
      TabOrder = 67
    end
    object Panel74: TPanel
      Left = 266
      Top = 143
      Width = 54
      Height = 25
      BevelInner = bvLowered
      BevelOuter = bvNone
      Caption = 'Alt'
      TabOrder = 68
    end
    object Panel75: TPanel
      Left = 323
      Top = 143
      Width = 54
      Height = 25
      BevelInner = bvLowered
      BevelOuter = bvNone
      Caption = 'Ctrl'
      TabOrder = 69
    end
  end
  object GridSymbolAQty: TStringGrid
    Left = 607
    Top = 49
    Width = 35
    Height = 108
    BorderStyle = bsNone
    ColCount = 1
    DefaultColWidth = 42
    DefaultRowHeight = 16
    FixedCols = 0
    RowCount = 6
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    ScrollBars = ssNone
    TabOrder = 1
  end
  object GridSymbolBQty: TStringGrid
    Left = 607
    Top = 225
    Width = 35
    Height = 108
    BorderStyle = bsNone
    ColCount = 1
    DefaultColWidth = 42
    DefaultRowHeight = 16
    FixedCols = 0
    RowCount = 6
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
    ScrollBars = ssNone
    TabOrder = 2
  end
  object ListUsing: TListView
    Left = 0
    Top = 311
    Width = 385
    Height = 85
    Color = clWhite
    Columns = <
      item
        Caption = 'S'
        Width = 19
      end
      item
        Caption = #54868#47732#47749
        Width = 80
      end
      item
        Caption = #54028#51068#51060#47492
        Width = 150
      end
      item
        Caption = #44228#51340
      end
      item
        Caption = #51333#47785'A'
      end
      item
        Caption = #51333#47785'B'
      end>
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548#52404
    Font.Style = []
    GridLines = True
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    StateImages = ImageList1
    TabOrder = 3
    ViewStyle = vsReport
    OnDrawItem = ListUsingDrawItem
    OnSelectItem = ListUsingSelectItem
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 401
    Width = 649
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 50
      end
      item
        Width = 50
      end>
  end
  object ListKey: TListView
    Left = 391
    Top = 2
    Width = 212
    Height = 397
    Columns = <
      item
        Caption = 'Key'
        Width = 35
      end
      item
        Caption = #51333#47785
      end
      item
        Caption = 'Action'
        Width = 100
      end>
    GridLines = True
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    SmallImages = ImageList1
    TabOrder = 5
    ViewStyle = vsReport
    OnColumnClick = ListKeyColumnClick
    OnDrawItem = ListKeyDrawItem
    OnKeyDown = ListKeyKeyDown
  end
  object EditOrg: TEdit
    Left = 64
    Top = 209
    Width = 313
    Height = 21
    Color = 16765136
    ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
    ReadOnly = True
    TabOrder = 6
  end
  object EditCtrl: TEdit
    Left = 64
    Top = 233
    Width = 313
    Height = 21
    Color = 16765136
    ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
    ReadOnly = True
    TabOrder = 7
  end
  object EditAlt: TEdit
    Left = 64
    Top = 257
    Width = 313
    Height = 21
    Color = 16765136
    ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
    ReadOnly = True
    TabOrder = 8
  end
  object BtnConfig: TBitBtn
    Left = 34
    Top = 1
    Width = 25
    Height = 23
    Hint = #53412#48372#46300' '#53412' '#49444#51221
    TabOrder = 9
    TabStop = False
    OnClick = BtnConfigClick
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      04000000000080000000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555777555
      5555555555000757755555575500005007555570058880000075570870088078
      007555787887087777755550880FF0800007708080888F7088077088F0708F78
      88077000F0778080005555508F0008800755557878FF88777075570870080088
      0755557075888070755555575500075555555555557775555555}
  end
  object BtnNew: TBitBtn
    Left = 5
    Top = 1
    Width = 25
    Height = 23
    TabOrder = 10
    TabStop = False
    OnClick = BtnNewClick
    Glyph.Data = {
      86050000424D8605000000000000360000002800000016000000140000000100
      18000000000050050000C40E0000C40E00000000000000000000C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      0000C0C0C0C0C0C0C0C0C0A8A8A86666663D3D3D3D3D3D3D3D3D3D3D3D3D3D3D
      3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3DA7A7A7C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C00000C0C0C0C0C0C0C0C0C066666655DFD43D3D3D55DFFF55DFFF55DF
      FF55DFFF55DFFF55DFD455DFFF55DFD455DFFF55C0D43D3D3DC0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C00000C0C0C0C0C0C0C0C0C066666600F2FF55DFD43D3D3DA9
      FFFF55DFFF55DFFF55DFFF55DFFF55DFFF55DFFF55DFD455DFFF55DFD43D3D3D
      C0C0C0C0C0C0C0C0C0C0C0C00000C0C0C0C0C0C0C0C0C073737354FFFF00F2FF
      55DFD43D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D3D
      3D3D3D3D3D3D3DC0C0C0C0C0C0C0C0C00000C0C0C0C0C0C0C0C0C073737354FF
      FF54FFFF00F2FF55DFD400F2FF55DFD499F8FF99F8FF99F8FF99F8FF99F8FF99
      F8FF99F8FFB4B4B4C0C0C0C0C0C0C0C0C0C0C0C00000C0C0C0C0C0C0C0C0C081
      8181A9FFFF54FFFF54FFFF00F2FFEFAD007F5B00EFAD00AAFFFF99F8FFAAFFFF
      99F8FFAAFFFF99F8FF767676C0C0C0C0C0C0C0C0C0C0C0C00000C0C0C0C0C0C0
      C0C0C081818154FFFFA9FFFF54FFFF54FFFF7F5B00D9A77D7F5B00FFFFFFAAFF
      FF99F8FFAAFFFF99F8FFAAFFFF767676C0C0C0C0C0C0C0C0C0C0C0C00000C0C0
      C0C0C0C0C0C0C09A9A9AA9FFFF54FFFFEFAD00A27600A27600D9A77DA377007F
      5B00EFAD00AAFFFF99F8FFAAFFFF99F8FF767676C0C0C0C0C0C0C0C0C0C0C0C0
      0000C0C0C0C0C0C0C0C0C09A9A9A54FFFFA9FFFFAA7F00FFFFCCD9A77DD9A77D
      D9A77DD9A77D7F5B00AAFFFFAAFFFF99F8FFAAFFFF818181C0C0C0C0C0C0C0C0
      C0C0C0C00000C0C0C0C0C0C0C0C0C0A7A7A7A7A7A755C0D4F7D06CE5B726E2B6
      29F6CF6DAA7F00AA7F00F7CF6CAAFFFF99F8FFAAFFFF99F8FF8E8E8EC0C0C0C0
      C0C0C0C0C0C0C0C00000C0C0C0C0C0C0C0C0C0C0C0C0A7A7A700F2FF00F2FF00
      F1FFF1BF2BFFFFCCAA7F00AAFFFFAAFFFFAAFFFF55DFFF55DFFF55C0D49A9A9A
      C0C0C0C0C0C0C0C0C0C0C0C00000C0C0C0C0C0C0C0C0C0C0C0C09B9B9B54FFFF
      67F4FF67F4FFF8D06DFDC831F7CF6CAAFFFFAAFFFFB4B4B4A0A0A08D8D8D8181
      81A7A7A7C0C0C0C0C0C0C0C0C0C0C0C00000C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C09B9B9B8D8D8D8D8D8DB4B4B4909090FFFFFFAAFFFFFFFFFFA1A1A1E6E6E6DA
      DADADADADAB4B4B4C0C0C0C0C0C0C0C0C0C0C0C00000C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0919191FFFFFFFFFFFFAAFFFFA7A7A7
      FFFFFFE7E7E7B4B4B4C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0919191FFFFFFFFFFFFFFFF
      FF8D8D8DFFFFFFB4B4B4C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0B4B4B49A9A9A9A
      9A9A8E8E8E818181C1C1C1C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      0000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C00000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C00000}
  end
  object ButtonRp: TBitBtn
    Left = 65
    Top = 1
    Width = 25
    Height = 23
    Hint = #48320#46041#49457' '#54872#44221' '#49444#51221
    TabOrder = 11
    TabStop = False
    OnClick = ButtonRpClick
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      04000000000080000000120B0000120B00001000000000000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555777555
      5555555555000757755555575500005007555570058880000075570870088078
      007555787887087777755550880FF0800007708080888F7088077088F0708F78
      88077000F0778080005555508F0008800755557878FF88777075570870080088
      0755557075888070755555575500075555555555557775555555}
  end
  object OpenDialog: TOpenDialog
    Filter = #53412#48372#46300#54872#44221#54028#51068' (*.one)|*.one'
    FilterIndex = 0
    Title = #53412#48372#46300' '#51452#47928#49444#51221' '#54028#51068#49440#53469
    Left = 352
    Top = 5
  end
  object ImageList1: TImageList
    Left = 360
    Top = 285
  end
end
