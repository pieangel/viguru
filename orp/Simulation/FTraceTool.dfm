object FrmSwitch: TFrmSwitch
  Left = 265
  Top = 0
  Caption = 'FrmSwitch'
  ClientHeight = 483
  ClientWidth = 820
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 820
    Height = 25
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 614
    object Button1: TButton
      Left = 200
      Top = 1
      Width = 75
      Height = 25
      Caption = 'Reset'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object Panel2: TPanel
    Left = 167
    Top = 25
    Width = 209
    Height = 458
    Align = alLeft
    TabOrder = 1
    ExplicitLeft = 0
    ExplicitWidth = 201
    ExplicitHeight = 361
  end
  object Panel3: TPanel
    Left = 376
    Top = 25
    Width = 444
    Height = 458
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 352
    object sgResult: TStringGrid
      Left = 1
      Top = 1
      Width = 442
      Height = 456
      Align = alClient
      FixedRows = 0
      TabOrder = 0
      ExplicitWidth = 411
      ExplicitHeight = 359
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 25
    Width = 167
    Height = 458
    Align = alLeft
    TabOrder = 3
    ExplicitLeft = 8
    ExplicitTop = 31
    object GroupBox1: TGroupBox
      Left = 9
      Top = 6
      Width = 147
      Height = 211
      Caption = #54788#47932
      TabOrder = 0
      object CheckBox1: TCheckBox
        Left = 16
        Top = 20
        Width = 97
        Height = 17
        Caption = '18001'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = CheckBox1Click
      end
      object CheckBox3: TCheckBox
        Tag = 2
        Left = 16
        Top = 66
        Width = 97
        Height = 17
        Caption = '18003'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = CheckBox1Click
      end
      object CheckBox4: TCheckBox
        Tag = 3
        Left = 16
        Top = 89
        Width = 97
        Height = 17
        Caption = '18005'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = CheckBox1Click
      end
      object CheckBox5: TCheckBox
        Tag = 4
        Left = 16
        Top = 112
        Width = 97
        Height = 17
        Caption = '18006'
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = CheckBox1Click
      end
      object CheckBox6: TCheckBox
        Tag = 5
        Left = 16
        Top = 135
        Width = 97
        Height = 17
        Caption = '18015'
        Checked = True
        State = cbChecked
        TabOrder = 4
        OnClick = CheckBox1Click
      end
      object CheckBox7: TCheckBox
        Tag = 6
        Left = 16
        Top = 158
        Width = 97
        Height = 17
        Caption = '18018'
        Checked = True
        State = cbChecked
        TabOrder = 5
        OnClick = CheckBox1Click
      end
      object CheckBox8: TCheckBox
        Tag = 7
        Left = 16
        Top = 181
        Width = 97
        Height = 17
        Caption = '18016'
        Checked = True
        State = cbChecked
        TabOrder = 6
        OnClick = CheckBox1Click
      end
    end
    object GroupBox2: TGroupBox
      Left = 9
      Top = 223
      Width = 147
      Height = 105
      Caption = #49440#50741
      TabOrder = 1
      object CheckBox9: TCheckBox
        Tag = 8
        Left = 16
        Top = 16
        Width = 97
        Height = 17
        Caption = '5592'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = CheckBox1Click
      end
      object CheckBox10: TCheckBox
        Tag = 9
        Left = 16
        Top = 39
        Width = 97
        Height = 17
        Caption = '5572'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = CheckBox1Click
      end
      object CheckBox11: TCheckBox
        Tag = 10
        Left = 16
        Top = 62
        Width = 97
        Height = 17
        Caption = '5515'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = CheckBox1Click
      end
      object CheckBox12: TCheckBox
        Tag = 11
        Left = 16
        Top = 85
        Width = 97
        Height = 17
        Caption = '5516'
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = CheckBox1Click
      end
    end
    object CheckBox13: TCheckBox
      Left = 25
      Top = 349
      Width = 97
      Height = 17
      Caption = #54633#49457#49440#47932' Timer'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = CheckBox13Click
    end
    object CheckBox14: TCheckBox
      Tag = 1
      Left = 25
      Top = 372
      Width = 97
      Height = 20
      Caption = #54001#48708#50984' Thread'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = CheckBox13Click
    end
    object CheckBox15: TCheckBox
      Tag = 2
      Left = 25
      Top = 398
      Width = 97
      Height = 17
      Caption = #47196#44536#50416#47112#46300
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = CheckBox13Click
    end
  end
  object CheckBox2: TCheckBox
    Tag = 1
    Left = 25
    Top = 74
    Width = 97
    Height = 17
    Caption = '18002'
    Checked = True
    State = cbChecked
    TabOrder = 4
    OnClick = CheckBox1Click
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 472
    Top = 320
  end
end
