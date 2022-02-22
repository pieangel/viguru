unit FleSynthesizeOrder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FrameBull, StdCtrls, Buttons, ExtCtrls, FrameFrontQuoting,
  FrameSCatchOrder, FrameOrderManage, FrameProtectedOrder, CleStorage,
  FleSynConfig, CleSynthesizeConfig, CleAccounts, CleSymbols, GleTypes;

const
  W_LEFT = 370;


type
  TFrmSyncthesize = class(TForm)
    plSymbolAcnt: TPanel;
    ComboAccount: TComboBox;
    ComboSymbol: TComboBox;
    ButtonSymbol: TSpeedButton;
    btnConfig: TButton;
    plProtectedOrder: TPanel;
    plSCatch: TPanel;
    plFrontQuoting: TPanel;
    plOrderManager: TPanel;
    plBull: TPanel;
    FraBull: TFraBull;
    FraSCatchOrder: TFraSCatchOrder;
    FraProtectedOrder: TFraProtectedOrder;
    FraOrderManage: TFraOrderManage;
    FraFrontQuoting: TFraFrontQuoting;
    procedure btnConfigClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboAccountChange(Sender: TObject);
    procedure ComboSymbolChange(Sender: TObject);
    procedure FraBullbtnExpandClick(Sender: TObject);
    procedure ButtonSymbolClick(Sender: TObject);
    procedure FraProtectedOrderbtnShowClick(Sender: TObject);
  private
    { Private declarations }
    FAccountGroup : TAccountGroup;
    FAccount : TAccount;
    FSymbol : TSymbol;
    procedure ApplyConfig;
    procedure InitData;
    procedure InitFormSize;
    function GetFrame(iType : integer) : TFrame;
    function RedundancyCheck( aSymbol : TSymbol; aAcnt : TAccount) : boolean;
    procedure RedundancyConfig;
    procedure FrameClose( bAll : boolean = false);
    procedure SetHeight;

  public
    { Public declarations }
    FrameConfigs : TFrameConfigs;
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

    procedure BullMessage( var Msg : TMessage ) ;  message WM_BULLMESSAGE;

  end;

var
  FrmSyncthesize: TFrmSyncthesize;

implementation

uses
  GleLib, CleFQN, GAppEnv;
{$R *.dfm}

procedure TFrmSyncthesize.ApplyConfig;
var
  i : integer;
  aItem : TFrameConfig;
begin
  plBull.Height := 0;
  plOrderManager.Height := 0;
  plFrontQuoting.Height := 0;
  plSCatch.Height := 0;
  plProtectedOrder.Height := 0;
  for i := 0 to FrameConfigs.Count - 1 do
  begin
    aItem := FrameConfigs.Items[i] as TFrameConfig;

    if aItem.FrameType = ftBull then
    begin
      if aItem.ShowHide then
      begin
        if FraBull.btnExpand.Down then
          plBull.Height := H_BULL_TOP + 5
        else
          plBull.Height := H_BULL_TOP + H_BULL_CLIENT + 5;
       end else
        plBull.Height := 0;
    end;

    if aItem.FrameType = ftOrder then
    begin
      if aItem.ShowHide then
        plOrderManager.Height := H_ORDER_TOP+ 5
      else
        plOrderManager.Height := 0;
    end;

    if aItem.FrameType = ftFront then
    begin
      if aItem.ShowHide then
      begin
        if FraFrontQuoting.btnExpand.Down then
          plFrontQuoting.Height := H_FRONT_TOP +7
        else
         plFrontQuoting.Height := H_FRONT_TOP + H_FRONT_CLIENT + 7;
      end else
        plFrontQuoting.Height := 0;
    end;

    if aItem.FrameType = ftSCatch then
    begin
      if aItem.ShowHide then
      begin
        if FraSCatchOrder.btnExpand.Down then
          plSCatch.Height := H_SCATCH_TOP + 5
        else
          plSCatch.Height := H_SCATCH_TOP + H_SCATCH_CLIENT + 5;
      end else
        plSCatch.Height := 0;
    end;

    if aItem.FrameType = ftProtected then
    begin
      if aItem.ShowHide then
      begin
        if (FraProtectedOrder.btnExpand.Down) and (FraProtectedOrder.btnShow.Down) then
          plProtectedOrder.Height := H_PROTECTED_TOP - H_PROTECTED_CENTER + 5
        else if (FraProtectedOrder.btnExpand.Down) and (not FraProtectedOrder.btnShow.Down) then
          plProtectedOrder.Height := H_PROTECTED_TOP + H_PROTECTED_CENTER + 5
        else if (not FraProtectedOrder.btnExpand.Down) and (FraProtectedOrder.btnShow.Down) then
          plProtectedOrder.Height := H_PROTECTED_TOP - H_PROTECTED_CENTER + 5
        else
          plProtectedOrder.Height := H_PROTECTED_TOP + H_PROTECTED_CLIENT + 5;
      end else
        plProtectedOrder.Height := 0;
    end;

  end;
  SetHeight;
end;

procedure TFrmSyncthesize.btnConfigClick(Sender: TObject);
var
  aDlg : TFrmSynConfig;
  aSymbol : TSymbol;
  bRet : boolean;
begin
  aDlg := TFrmSynConfig.Create(self);
  try
    aDlg.Left := Self.Left + self.Width;
    aDlg.Top := Self.Top;
    aDlg.FrameConfigs := FrameConfigs;
    if aDlg.ShowModal = mrOK then
    begin
      FrameConfigs := aDlg.GetConfigs;
      ApplyConfig;
      FrameClose;
      RedundancyConfig;
    end;
  finally
    aDlg.Free;
  end;
end;

procedure TFrmSyncthesize.BullMessage(var Msg: TMessage);
var
  aItem : TFrameConfig;
begin
  aItem := FrameConfigs.Find(ftBull);
  if aItem = nil then exit;
  if aItem.ShowHide then
    FraBull.BullMessage(Msg);
end;

procedure TFrmSyncthesize.ButtonSymbolClick(Sender: TObject);
begin
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);
      AddSymbolCombo(gSymbol.Selected, ComboSymbol);
      ComboSymbolChange(ComboSymbol);
    end;
  finally
    gSymbol.Hide
  end;
end;

procedure TFrmSyncthesize.ComboAccountChange(Sender: TObject);
var
  aGroup  : TAccountGroup;
  aAccount : TAccount;
  bRet : boolean;
begin
  aGroup  := GetComboObject( ComboAccount ) as TAccountGroup;
  if aGroup = nil then Exit;

  if aGroup = FAccountGroup then
    Exit;
  FAccountGroup := aGroup;
  if FAccountGroup = nil then Exit;
  aAccount  := FAccountGroup.Accounts.GetMarketAccount( atFO );

  if FAccount = aAccount then exit;

  if FSymbol <> nil then
  begin
    bRet := RedundancyCheck(nil, aAccount);
    if not bRet then
      aAccount := nil;
  end;

  FAccount := aAccount;
  FrameConfigs.AccountChange(FAccount);
end;

procedure TFrmSyncthesize.ComboSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
  bRet : boolean;
begin
  if ComboSymbol.ItemIndex = -1 then Exit;

  aSymbol := ComboSymbol.Items.Objects[ComboSymbol.ItemIndex] as TSymbol;
  if aSymbol = nil then exit;
  if FSymbol = aSymbol then exit;
  bRet := RedundancyCheck( aSymbol, nil);
  if not bRet then
    aSymbol := nil;
  FSymbol := aSymbol;
  FrameConfigs.SymbolChange(FSymbol);
end;

procedure TFrmSyncthesize.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := cafree;
end;

procedure TFrmSyncthesize.FormCreate(Sender: TObject);
var
  aMarkets : TMarketTypes;
begin
  InitFormSize;
  FrameConfigs := TFrameConfigs.Create;
  InitData;

  FAccountGroup := nil;
  gEnv.Engine.TradeCore.AccountGroups.GetList( ComboAccount.Items );

  aMarkets := [ mtFutures, mtOption ];
  gEnv.Engine.SymbolCore.SymbolCache.GetLists2( ComboSymbol.Items, aMarkets );
  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex  := 0;
    ComboAccountChange( nil );
  end;
end;

procedure TFrmSyncthesize.FormDestroy(Sender: TObject);
begin
  FrameClose(true);
  FrameConfigs.Free;
end;

procedure TFrmSyncthesize.FraBullbtnExpandClick(Sender: TObject);
var
  iTag : integer;
begin
  iTag := (Sender as TSpeedButton).Tag;
  case iTag of
    0:
    begin
      if FraBull.btnExpand.Down then
        plBull.Height := H_BULL_TOP + 5
      else
        plBull.Height := H_BULL_TOP + H_BULL_CLIENT + 5;
      FraBull.btnExpandClick(nil);
    end; //Bull
    1:
    begin
      if FraFrontQuoting.btnExpand.Down then
        plFrontQuoting.Height := H_FRONT_TOP +7
      else
         plFrontQuoting.Height := H_FRONT_TOP + H_FRONT_CLIENT + 7;
      FraFrontQuoting.btnExpandClick(nil);
    end; //Front
    2:
    begin
      {
      if FraOrderManage.btnExpand.Down then
        plOrderManager.Height := H_ORDER_TOP+ 5
      else
        plOrderManager.Height := H_ORDER_TOP + H_ORDER_CLIENT + 5;
      FraOrderManage.btnExpandClick(nil); //Order
      }
    end;
    3:
    begin
      if FraProtectedOrder.btnExpand.Down then
        plProtectedOrder.Height := H_PROTECTED_TOP + 5
      else
        plProtectedOrder.Height := H_PROTECTED_TOP + H_PROTECTED_CLIENT + 5;
      FraProtectedOrder.btnExpandClick(nil); 
    end; //Protected
    4:
    begin
      if FraSCatchOrder.btnExpand.Down then
        plSCatch.Height := H_SCATCH_TOP + 5
      else
        plSCatch.Height := H_SCATCH_TOP + H_SCATCH_CLIENT + 5;
      FraSCatchOrder.btnExpandClick(nil); //SCatch
    end;
  end;
  SetHeight;
end;

procedure TFrmSyncthesize.FrameClose(bAll : boolean);
var
  i : integer;
  aItem : TFrameConfig;
begin
  if bAll then
  begin
    for i := 0 to FrameConfigs.Count - 1 do
    begin
      aItem := FrameConfigs.Items[i] as TFrameConfig;
      if Assigned(aItem.OnFrameClose) then
        aItem.OnFrameClose;
    end;
  end else
  begin
    for i := 0 to FrameConfigs.Count - 1 do
    begin
      aItem := FrameConfigs.Items[i] as TFrameConfig;
      if Assigned(aItem.OnFrameClose) then
        aItem.OnFrameClose(true);
    end;
  end;
end;

procedure TFrmSyncthesize.FraProtectedOrderbtnShowClick(Sender: TObject);
begin
  if FraProtectedOrder.btnExpand.Down then
  begin
    if FraProtectedOrder.btnShow.Down then
      plProtectedOrder.Height := plProtectedOrder.Height - H_PROTECTED_CENTER
    else
      plProtectedOrder.Height := plProtectedOrder.Height + H_PROTECTED_CENTER;
  end else
  begin
    if FraProtectedOrder.btnShow.Down then
      plProtectedOrder.Height := plProtectedOrder.Height - H_PROTECTED_CENTER - H_PROTECTED_CLIENT
    else
      plProtectedOrder.Height := plProtectedOrder.Height + H_PROTECTED_CENTER + H_PROTECTED_CLIENT;
  end;
  SetHeight;
  FraProtectedOrder.btnShowClick(nil);
end;

function TFrmSyncthesize.GetFrame(iType: integer): TFrame;
begin
  Result := nil;
  case iType of
    0 : Result := FraBull;
    1 : Result := FraOrderManage;
    2 : Result := FraFrontQuoting;
    3 : Result := FraSCatchOrder;
    4 : Result := FraProtectedOrder;
  end;
end;


procedure TFrmSyncthesize.InitData;
var
  i : integer;
begin
  for i := 0 to FRAME_CNT - 1 do
    FrameConfigs.New(GetFrame(i), i, true);
end;

procedure TFrmSyncthesize.InitFormSize;
begin
  plBull.Height := H_BULL_TOP + H_BULL_CLIENT + 5;
  plOrderManager.Height := H_ORDER_TOP;
  plFrontQuoting.Height := H_FRONT_TOP + H_FRONT_CLIENT;
  plSCatch.Height := H_SCATCH_TOP + H_SCATCH_CLIENT;
  plProtectedOrder.Height := H_PROTECTED_TOP + H_PROTECTED_CLIENT;

  width := W_LEFT +10;
  SetHeight;
end;

procedure TFrmSyncthesize.LoadEnv(aStorage: TStorage);
var
  i, iType : integer;
  stField : string;
  bShow : boolean;
begin
  if aStorage = nil then Exit;
  for i := 0 to FRAME_CNT - 1 do
  begin
    stField := 'FRAME' + IntToStr(i);
    iType := aStorage.FieldByName(stField).AsInteger;
    stField := 'FRAMESHOW' + IntToStr(i);
    bShow := aStorage.FieldByName(stField).AsBoolean;
    FrameConfigs.Exchange(i, TFrameType(iType), bShow);
  end;
  FraFrontQuoting.LoadEnv(aStorage);
  FraSCatchOrder.LoadEnv(aStorage);
  FraProtectedOrder.LoadEnv(aStorage);
  FraOrderManage.LoadEnv(aStorage);
  FraBull.LoadEnv(aStorage);
  ApplyConfig;
end;

function TFrmSyncthesize.RedundancyCheck(aSymbol: TSymbol;
  aAcnt: TAccount): boolean;
var
  aConfig : TFrameConfig;
  bRet : boolean;
  i : integer;
  aType : TRedundancyType;
begin
  Result := true;

  for i := 0 to FrameConfigs.Count - 1 do
  begin
    aConfig := FrameConfigs.Items[i] as TFrameConfig;

    if (aConfig.FrameType <> ftOrder) and (aConfig.FrameType <> ftProtected) then continue;

    if aConfig.FrameType = ftOrder then
      aType := rdtOrderMan;
    if aConfig.FrameType = ftProtected then
      aType := rdtProtected;

    if not aConfig.ShowHide then continue;
    if (aAcnt = nil) and (FAccount <> nil) then   // 종목변경시
    begin
      bRet := gEnv.Engine.FormBroker.RedundancyChecks.RedundancyCheck(aSymbol, FSymbol, FAccount, FAccount, self, aType);
      if not bRet then
      begin
        ComboSymbol.ItemIndex := -1;
        gEnv.Engine.FormBroker.RedundancyChecks.AlramBox(aSymbol, FAccount, aType);
        break;
      end;
    end else if (aSymbol = nil) and (FSymbol <> nil) then   // 계좌변경시
    begin
      bRet := gEnv.Engine.FormBroker.RedundancyChecks.RedundancyCheck(FSymbol, FSymbol, aAcnt, FAccount, self, aType);
      if not bRet then
      begin
        ComboAccount.ItemIndex := -1;
        gEnv.Engine.FormBroker.RedundancyChecks.AlramBox(FSymbol, aAcnt, aType);
        break;
      end;
    end;
  end;

  if not bRet then gEnv.Engine.FormBroker.RedundancyChecks.Del(self);
  
  Result := bRet;
end;

procedure TFrmSyncthesize.RedundancyConfig;
begin
  if (FSymbol = nil) or (FAccount = nil) then exit;
  gEnv.Engine.FormBroker.RedundancyChecks.Del(FSymbol, FAccount, self, rdtOrderMan);
  gEnv.Engine.FormBroker.RedundancyChecks.Del(FSymbol, FAccount, self, rdtProtected);
  ComboSymbol.ItemIndex := -1;
  FSymbol := nil;
end;

procedure TFrmSyncthesize.SaveEnv(aStorage: TStorage);
var
  i : integer;
  stField : string;
  aItem : TFrameConfig;
begin
  if aStorage = nil then Exit;
  for i := 0 to FrameConfigs.Count - 1 do
  begin
    aItem := FrameConfigs.Items[i] as TFrameConfig;
    stField := 'FRAME' + IntToStr(i);
    aStorage.FieldByName(stField).AsInteger := Integer(aItem.FrameType);
    stField := 'FRAMESHOW' + IntToStr(i);
    aStorage.FieldByName(stField).AsBoolean := aItem.ShowHide;
  end;

  FraFrontQuoting.SaveEnv(aStorage);
  FraSCatchOrder.SaveEnv(aStorage);
  FraProtectedOrder.SaveEnv(aStorage);
  FraOrderManage.SaveEnv(aStorage);
  FraBull.SaveEnv(aStorage);

end;

procedure TFrmSyncthesize.SetHeight;
begin
  Height := plSymbolAcnt.Height + plBull.Height + plOrderManager.Height
            + plFrontQuoting.Height + plSCatch.Height + plProtectedOrder.Height + 30;
end;

end.
