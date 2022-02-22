object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 101
  ClientWidth = 230
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
    Width = 230
    Height = 52
    Align = alTop
    BevelOuter = bvLowered
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      230
      52)
    object cbStart: TCheckBox
      Left = 176
      Top = 4
      Width = 46
      Height = 18
      Anchors = [akRight, akBottom]
      Caption = 'Start'
      TabOrder = 0
      OnClick = cbStartClick
    end
    object edtAccount: TEdit
      Left = 3
      Top = 4
      Width = 100
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 1
    end
    object Button6: TButton
      Left = 104
      Top = 4
      Width = 34
      Height = 21
      Caption = 'Tgt'
      TabOrder = 2
      OnClick = Button6Click
    end
    object edtMine: TEdit
      Left = 3
      Top = 28
      Width = 100
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 3
    end
    object Button1: TButton
      Tag = 1
      Left = 104
      Top = 28
      Width = 34
      Height = 21
      Caption = 'Mine'
      TabOrder = 4
      OnClick = Button6Click
    end
    object Button2: TButton
      Left = 206
      Top = 29
      Width = 20
      Height = 21
      Caption = #51333
      TabOrder = 5
      OnClick = Button2Click
    end
    object edtSymbol: TLabeledEdit
      Left = 144
      Top = 29
      Width = 58
      Height = 21
      EditLabel.Width = 3
      EditLabel.Height = 13
      EditLabel.Caption = ' '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 6
    end
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 82
    Width = 230
    Height = 19
    Hint = #51092#44256', '#49440#47932#51652#51077#44032' ,  ('#49345#49849','#54616#46973') '#54788#51116' , '#52572#44256', '#52572#51200' '#49552#51061' '
    Panels = <
      item
        Style = psOwnerDraw
        Width = 30
      end
      item
        Width = 70
      end
      item
        Width = 60
      end>
    ParentShowHint = False
    ShowHint = True
    ExplicitLeft = -23
    ExplicitTop = 118
    ExplicitWidth = 253
  end
  object edtMultiple: TLabeledEdit
    Left = 32
    Top = 55
    Width = 36
    Height = 21
    EditLabel.Width = 24
    EditLabel.Height = 13
    EditLabel.Caption = #49849#49688
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 2
    Text = '10'
  end
  object ed: TLabeledEdit
    Left = 103
    Top = 55
    Width = 38
    Height = 21
    EditLabel.Width = 24
    EditLabel.Height = 13
    EditLabel.Caption = #48372#51221
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 3
    Text = '1'
  end
  object cbIgnore: TCheckBox
    Left = 157
    Top = 58
    Width = 66
    Height = 17
    Caption = #51333#47785#47924#49884
    TabOrder = 4
  end
end
