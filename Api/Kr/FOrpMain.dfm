object OrpMainForm: TOrpMainForm
  Left = 0
  Top = 0
  Caption = 'KR '#44397#45236' '#49440#47932' Guru Api'
  ClientHeight = 76
  ClientWidth = 293
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  Menu = DataModule1.MainMenu1
  OldCreateOrder = False
  Position = poMainFormCenter
  Visible = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object MemoLog: TMemo
    Left = 0
    Top = 56
    Width = 337
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = []
    ImeName = 'Korean Input System (IME 2000)'
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 57
    Width = 293
    Height = 19
    Panels = <
      item
        Width = 50
      end
      item
        Width = 150
      end
      item
        BiDiMode = bdLeftToRight
        ParentBiDiMode = False
        Width = 50
      end>
    ExplicitTop = 15
    ExplicitWidth = 279
  end
  object plInfo: TPanel
    Left = 0
    Top = 0
    Width = 293
    Height = 57
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitWidth = 279
    ExplicitHeight = 15
    object pb: TPaintBox
      Left = 0
      Top = 0
      Width = 293
      Height = 57
      Align = alClient
      OnPaint = pbPaint
      ExplicitTop = -6
      ExplicitWidth = 254
      ExplicitHeight = 35
    end
    object ExpertCtrl: TESINApiExp
      Left = 320
      Top = 144
      Width = 100
      Height = 50
      TabOrder = 0
      ControlData = {00000100560A00002B05000000000000}
    end
  end
  object TrayIcon1: TTrayIcon
    Icon.Data = {
      0000010001002020000001001800A80C00001600000028000000200000004000
      00000100180000000000800C0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      8E42008E42008E42008E42008E42008E42008E42008E42008E42008E42000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000008E42008E4200
      8E4200AA4A00BA4A00C75200CF5200D35200C75200BE5200AE4A008E42008E42
      008E420000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000008E42008E4200A64A00CB5200
      E35200E75200E75200EB5A00E75A6BF39C39EB7B00EF5A00F35A00EF5A00D752
      00AE4A008E42008E420000000000000000000000000000000000000000000000
      00000000000000000000000000000000008E42009E4A00C34A08DF5218E36331
      E77339E77B42EB844AEB844AE384BDF3D68CEBAD4AEB8442EF8439EF8429F373
      08F36300CF5200A64A008E420000000000000000000000000000000000000000
      00000000000000000000008E42008E4200AE4A00CF5252E384B5F3CECEF3DED6
      F7E7DEF7E7DEF7E7DEF7EFE7F7EFF7FBF7EFFBF7E7F7EFDEFBE7DEFBE7D6F7E7
      C6F7D67BF3A510E76300BA4A008E42008E420000000000000000000000000000
      00000000000000000000008E4200AE4A08D75210D75218CB5A39CB6B63CF8C84
      D7A594DFAD9CDFB5A5E3B5A5DFBDDEF3E7C6EBD6A5E3BD9CE3B594E3B58CE3AD
      73DF9C4AE78429EF7310F36B00BE52008E420000000000000000000000000000
      00000000000000008E4200AA4A08D34A6BE3946BE39452DB847BE3A5A5EBBDAD
      EBC694D79C84CB8473C3736BBA5A84BE6B73BA6373BE6384CB7B8CD7949CE3AD
      A5F3C694F3B573F3A584F7AD31F37B00B652008E420000000000000000000000
      00000000008E42009E4208CB4A10CB526BDB94D6F7E794EBB5ADF3C68CD7946B
      BA634AA631429E18429E18429E18429E18429E18429E18429E1842A2215AB242
      73C76B94E39CADF7C6E7FBEF63EF9410EB6300A64A008E420000000000000000
      00000000008E4200B64A39D373BDEFCEE7F7E7FFFFFFE7F7EF94C3844A9E2942
      9E1842A21842A218429E18429E18429E18429E18429E18429E18429E1842A218
      42A2185AAA39A5CF94FFFFFFE7FBEF7BF3AD00CF52008E420000000000000000
      00008E42009E4210C75242CB737BD39CADDBBDD6EBDE73B25A429A18429E1842
      A21842A21842A218429E18429A18429618399618429618429A18429E1842A218
      42A61842A218429E21EFF7EF9CE3B552E38408EB5A00B24A008E420000000000
      00008E4208B64A21CB5A5AD38494DFADADE3C673B263399618429E1842A21842
      A21842A218429E185AAA4273BA6B9CCB948CC3846BB6635AAA42429E2142A218
      42A61842A218429E18CEEFD684E3AD31E37300EB5A00DB52008E42000000008E
      42008E4208C34A29CF637BE39CADEFC69CD7A5399218429A1842A21842A61842
      A21842A22184CB849CE3ADADEFC6E7F7EFCEF3DEB5EFC69CE3AD63B65242A218
      42A61842A61842A218B5EFCE8CEFAD31EF7300EF5A00F35A009A4A008E42008E
      42009E4210C35263DB8C84E3A5B5EFC65AA64A399618429E1842A21842A2184A
      A6298CD38CB5F3CEB5F3C6ADEFC6E7F7EFCEF3DEB5F3CEB5F7CE73C76B42A218
      42A62142A61842A218B5F3CE8CF7B531EF7300EF5A00EF5A00B24A008E42008E
      4200A64218BE52DEF3E78CE3ADA5DFB5398E18429A1842A21842A6184AA62173
      C36BB5F3CEB5F3CEB5F3CEADEFC6D6E3D6C6E3CEADEFBDADEBBD6BC36342A618
      42A62142A618429E18B5F3CE8CF7B531EF7300EB5A00EF5A00C752008E42008E
      4208AE4231BA63D6EFDEE7F7EFA5D3A5398E18429A1842A21842A61852AA31C6
      EFCED6F7DED6F7DEBDCFB57B61427B55317B6539639E4263B64A52AA3142A618
      42A61842A218429E18D6F7DEBDF7CE84EFAD63EF9439EB7B00CF52008E42008E
      4208AA4252C373BDE3CEFFFFFF94C38C398E18429A1842A21842A61863B242E7
      F7EFE7F7EFDEEBDE8C7D635A28005A2C0063280052591039AA2142A21842A218
      42A218429E18429A18E7F7EFCEF3DEADEBC69CE7B584EBA500CF52008E42008E
      4208AA4221B2525AB67BC6E3D68CBA7B398E18429A1842A21842A6186BB64AC6
      E7CEB5E3C6ADD3B57365425A28005A2C00632400524D0839A621429E18429E18
      429E18429A18429621B5EBC684DBA529C36329C36394E7B500C74A008E42008E
      4208AA4218BA525AC77B9CD7ADADCB9C398E18429A1842A21842A6185AAE39DE
      F3E7B5EBC6B5EBC694AA845A28005A24005A2C004A6910399E18429618429618
      42961839961863AE52ADEFC673E79C29D363CEF3DE31CF6B00C34A008E42008E
      4208A24210BA4A4ACB7394DBADA5CFA5398A18399618429E1842A21852AA29DE
      EFD6B5EBCEB5EFCEB5EBC69CBA94A59E8494B68484C77B84CB7B84CB848CCB84
      9CCB948CCF94A5EBBD94F3B552E78494EBB5A5E7BD00C74A00BA4A008E42008E
      42009A4210B64239C76B94DFADADDFBD428E21399218429A1842A21842A62173
      BE5ACEEFDEB5EFCEB5EFCEB5EBCEE7F3E7CEEFD6B5EFC6B5EFCEB5EFCEE7F7EF
      D6F3DEB5EFCEADF3C684EFA56BE394E7F7EF10BA5200D34A00AE4A008E42008E
      4200924208B64273D394CEEFD6DEF3E784B273398A18399618429E1842A2184A
      A62194CB84E7F7EFE7F7EFE7F7EFF7FBF7EFFBF7E7F7EFE7FBEFDEF3DEA5CF8C
      7BBA63ADD7A5DEFBE7D6F7DEF7FFFFB5E7C67BDBA508DB52009642008E420000
      00008E4210AA4A39B6639CD7B5C6E7CEC6DFCE398A21398E18399618429E1842
      A2184AA6216BB652A5D39CD6EBDEEFFBF7E7F3EFC6E7C68CC78452A6394AA221
      429A184A9E299CCB94EFF7EFCEEBDE6BC78C29C76300C74A008E420000000000
      00008E42089A4231B65A4AB67384CB9CADDFBD94C394428A2142922142962142
      9A18429E1842A2184AA6294AA62952AA3152A6314AA22942A221429E18429E18
      429A1839961884BE7BEFF7F75ABE8418B65200C74A00AA4A008E420000000000
      00000000008E4221AE5252C77373CF94A5E3BDBDE7CE9CCB9C4A96314A963142
      9A21429A18429A18429E18429E18429E18429E18429E18429E18429E18429A18
      429618399218A5CB9CADDFBD52CF8418D35A00BE4A008E42008E420000000000
      00000000008E42089A4239BE637BD79CA5E3B5BDEBCECEEBD6CEE3C684B2736B
      AA526BA64A63A64252A23952A2314A9E294A9E294A9E294A9E2952A231529E31
      529E31A5CB94D6EFDE94DFB542DB7B10D75200A24A008E420000000000000000
      00000000000000008E42109E4A52C773ADE7BDD6F3DEE7F7EFEFF7EFF7FBF7D6
      E7CEADCB9C94BE7B8CBA7B8CBA7384B66B84B66B7BB2637BB26384B66BA5CF9C
      DEEFD6F7FBF7CEEFDEA5E7BD31D76B00AE4A008E420000000000000000000000
      00000000000000008E42008E42089E424ABE6BBDE7CEEFF7EFF7FBF7F7FBFFFF
      FFFFF7FBF7F7FBF7F7F7EFE7EFDEE7EFE7E7EFDEDEEBDEEFF7EFF7FBF7F7FBF7
      FFFFFFDEF3E7BDE7CE6BDB9410AE52008E42008E420000000000000000000000
      00000000000000000000008E42008E42089A4229AE5294D3A5D6EBDEE7F3EFF7
      FBF7F7FBFFEFF7EFFFFBFFF7F7F7F7FBF7EFF7F7EFF7EFFFFFFFE7F3E7F7FBFF
      D6EBDEB5DFC673D79418AA52008E42008E420000000000000000000000000000
      00000000000000000000000000008E42008E4200924210A24242BA6B9CDBB5D6
      EFDEF7FBFFEFFBF7F7FBF7FFFFFFFFFBFFF7FBF7F7FBF7F7FBF7EFF7EFCEEBD6
      94D7A539BA6B009A42008A42008E420000000000000000000000000000000000
      00000000000000000000000000000000000000008E42008E42009A4208A64218
      A6424AB6738CD3A5A5DBB5C6E7CEC6E7D6BDE7CEADDFBD7BCF9452C37318AE52
      009A42008E42008E420000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000008E42008E4200
      8E42009242089E42089E42089E39089E42089E42009E42009642008A42008A42
      008A420000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      8E42008E42008E42008A42008A42008A42008A42008E42008E42008E42000000
      000000000000000000000000000000000000000000000000000000000000FFE0
      07FFFF8001FFFE00007FFC00003FF000000FF000000FE0000007C0000003C000
      0003800000018000000100000000000000000000000000000000000000000000
      0000000000000000000000000000000000008000000180000001C0000001C000
      0003E0000007E0000007F000000FF800001FFE00007FFF8001FFFFE007FF}
    PopupMenu = PopupMenu1
    Visible = True
    OnDblClick = TrayIcon1DblClick
    Left = 248
  end
  object PopupMenu1: TPopupMenu
    Left = 280
    object Show1: TMenuItem
      Caption = 'Show'
      OnClick = Show1Click
    end
    object N26: TMenuItem
      Caption = '-'
    end
    object Exit2: TMenuItem
      Caption = 'Exit'
      OnClick = Exit2Click
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 300
    OnTimer = Timer1Timer
    Left = 56
    Top = 16
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 200
    OnTimer = Timer2Timer
    Left = 88
    Top = 16
  end
  object Timer3: TTimer
    Enabled = False
    Interval = 300
    OnTimer = Timer3Timer
    Left = 120
    Top = 16
  end
end
