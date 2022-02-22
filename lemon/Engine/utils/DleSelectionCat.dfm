object CategoricalSelectionDialog: TCategoricalSelectionDialog
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Selection'
  ClientHeight = 269
  ClientWidth = 303
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object CategoryButtons: TCategoryButtons
    Left = 0
    Top = 0
    Width = 303
    Height = 233
    Align = alTop
    BevelOuter = bvRaised
    ButtonFlow = cbfVertical
    ButtonHeight = 27
    ButtonOptions = [boFullSize, boGradientFill, boShowCaptions, boVerticalCategoryCaptions, boBoldCaptions, boUsePlusMinus]
    Categories = <
      item
        Color = 16771818
        Collapsed = False
        Items = <
          item
            ImageIndex = -1
          end>
      end
      item
        Color = 15400959
        Collapsed = False
        Items = <>
      end
      item
        Color = 16777194
        Collapsed = False
        Items = <>
      end
      item
        Color = 15395839
        Collapsed = False
        Items = <>
      end
      item
        Color = 15466474
        Collapsed = False
        Items = <>
      end>
    RegularButtonColor = clWhite
    SelectedButtonColor = 12502986
    TabOrder = 0
  end
  object Button1: TButton
    Left = 112
    Top = 239
    Width = 75
    Height = 25
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
end
