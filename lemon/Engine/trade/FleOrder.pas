unit FleOrder;

//
//  simple order window(for sample purposea)
//

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons,

    // lemon: common
  GleConsts, GleLib, LemonEngine,
    // lemon: symbol
  CleSymbols, DleSymbolSelect,
    // lemon: trade
  CleAccounts, CleOrders, ClePositions, CleTradeBroker, SignalTargets,
    // lemon: order
  DleOrderConfirm;

type
  TOrderForm = class(TForm)
    TabOrderType: TTabControl;
    ComboAccount: TComboBox;
    Label1: TLabel;
    StatusMsg: TStatusBar;
    Label2: TLabel;
    ComboSymbol: TComboBox;
    ButtonSymbol: TSpeedButton;
    Label3: TLabel;
    EditVolume: TEdit;
    LabelPrice: TLabel;
    LabelPriceType: TLabel;
    LabelFillType: TLabel;
    ButtonSend: TButton;
    ButtonCancel: TButton;
    EditPrice: TEdit;
    ComboPriceControl: TComboBox;
    ComboTimeToMarket: TComboBox;
    LabelOrgOrder: TLabel;
    ComboTargetOrder: TComboBox;
    LabelPriceRange: TLabel;
    LabelFillTypeDesc: TLabel;
    ButtonUpdate: TSpeedButton;
    SpeedReset: TSpeedButton;
    ButtonHelp: TSpeedButton;
    procedure TabOrderTypeChanging(Sender: TObject; var AllowChange: Boolean);
    procedure TabOrderTypeChange(Sender: TObject);
    procedure ButtonSymbolClick(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure ComboSymbolChange(Sender: TObject);
    procedure ComboTargetOrderChange(Sender: TObject);
    procedure ComboPriceControlChange(Sender: TObject);
    procedure ButtonSendClick(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonUpdateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
      // assigned
    FEngine: TLemonEngine;
      // selection
    FAccount : TAccount;
    FSymbol : TSymbol;
    FOrderType : TOrderType;
    FSide: Integer;
    FTarget: TSignalTargetItem;

      // set
    procedure SetEngine(Value: TLemonEngine);
      //
    procedure Clear;
    procedure ShowStatus(stMsg : String);
  public
      // drive from outside
    procedure Preset(otValue: TOrderType; aAccount: TAccount; aSymbol: TSymbol;
                 iSide, iVolume: Integer; dPrice: Double; pcValue: TPriceControl;
                 tmValue: TTimeToMarket; aTarget: TOrder);
      // assign engine
    property Engine: TLemonEngine read FEngine write SetEngine;
    property Target : TSignalTargetItem read FTarget write FTarget;
  end;

implementation

uses GAppEnv;

{$R *.DFM}

const
  TAB_BUY = 0;
  TAB_SELL = 1;
  TAB_CHANGE = 2;
  TAB_CANCEL = 3;

//--------------------------------------------------------------< form events >

procedure TOrderForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TOrderForm.FormCreate(Sender: TObject);
begin

end;

//---------------------------------------------------------------< set engine >

// assign engine object
procedure TOrderForm.SetEngine(Value: TLemonEngine);
begin
  if Value = nil then Exit;

  FEngine := Value;

    // get account & symbol list
  FEngine.TradeCore.Accounts.GetList(ComboAccount.Items);
  FEngine.SymbolCore.SymbolCache.GetList(ComboSymbol.Items);

    // initialize
  FAccount := nil;
  FSymbol := nil;

    // set default order type
  TabOrderTypeChange(TabOrderType);

    // set default accout selected
  SetComboIndex(ComboAccount, 0);
  ComboAccountChange(ComboAccount);

  if FTarget = nil then exit;                             //SystemOrder 에서 종목 선택시
  FSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(FTarget.Symbol.Code);
  if FSymbol = nil then exit;
  FEngine.SymbolCore.SymbolCache.AddSymbol(FSymbol);
  ComboSymbol.Items.Clear;
  FEngine.SymbolCore.SymbolCache.GetList(ComboSymbol.Items);
  SetComboIndex(ComboSymbol, FSymbol);
  EditPrice.Text := Format('%.*f',[FSymbol.Spec.Precision, FSymbol.Last]);
  if FTarget.Position = nil then exit;
  EditVolume.Text := Format('%d',[abs(FTarget.Position.Volume)]);
end;

//------------------------------------------------------------< external call >

procedure TOrderForm.Preset(otValue: TOrderType; aAccount: TAccount; aSymbol: TSymbol;
             iSide, iVolume: Integer; dPrice: Double; pcValue: TPriceControl;
             tmValue: TTimeToMarket; aTarget: TOrder);
begin
  if FEngine = nil then Exit;

    // set order type
  case otValue of
    otNormal:
      if iSide = 1 then
        TabOrderType.TabIndex := TAB_BUY
      else if iSide = -1 then
        TabOrderType.TabIndex := TAB_SELL;
    otChange: TabOrderType.TabIndex := TAB_CHANGE;
    otCancel: TabOrderType.TabIndex := TAB_CANCEL;
  end;
  TabOrderTypeChange(TabOrderType);

    // set account
  if aAccount <> nil then
  begin
    SetComboIndex(ComboAccount, aAccount);
    ComboAccountChange(ComboAccount);
  end;

    // set symbol
  if aSymbol <> nil then
  begin
    FEngine.SymbolCore.SymbolCache.AddSymbol(aSymbol);
      //
    ComboSymbol.Items.Clear;
    FEngine.SymbolCore.SymbolCache.GetList(ComboSymbol.Items);
    SetComboIndex(ComboSymbol, aSymbol);
      //
    ComboSymbolChange(ComboSymbol);
  end;

    // target order
  if (FAccount <> nil) and (FSymbol <> nil) then
  begin
    ButtonUpdateClick(ButtonUpdate);
      //
    if ComboTargetOrder.Visible then
    begin
      SetComboIndex(ComboTargetOrder, aTarget);
      ComboTargetOrderChange(ComboTargetOrder);
    end;
  end;

    // volume
  EditVolume.Text := IntToStr(iVolume);

    // price
  EditPrice.Text := Format('%.2f' , [dPrice]);

    // price control
  case pcValue of
    pcLimit        : ComboPriceControl.ItemIndex := 0;
    pcMarket       : ComboPriceControl.ItemIndex := 1;
    pcLimitToMarket: ComboPriceControl.ItemIndex := 2;
    pcBestLimit    : ComboPriceControl.ItemIndex := 3;
  end;
    //
  ComboPriceControlChange(ComboPriceControl);

    // time to market
  case tmValue of
    tmGTC: ComboTimeToMarket.ItemIndex := 0;
    tmFOK: ComboTimeToMarket.ItemIndex := 1;
    tmIOC: ComboTimeToMarket.ItemIndex := 2;
    tmFAS: ComboTimeToMarket.ItemIndex := 3;
  end;
end;

//----------------------------------------------------------------< selection >

// order type
procedure TOrderForm.TabOrderTypeChange(Sender: TObject);
begin
    // set 'locked' button
  SpeedReset.Visible := (TabOrderType.TabIndex in [TAB_BUY, TAB_SELL]);

  //-- order type & window color
  case TabOrderType.TabIndex of
    TAB_BUY:
      begin
        FOrderType := otNormal;
        FSide := 1;
        Color := LONG_BG_COLOR;
      end;
    TAB_SELL:
      begin
        FOrderType := otNormal;
        FSide := -1;
        Color := SHORT_BG_COLOR;
      end;
    TAB_CHANGE:
      begin
        FOrderType := otChange;
        Color := clBtnFace;
      end;
    TAB_CANCEL:
      begin
        FOrderType := otCancel;
        Color := clBtnFace;
      end;
    else
      Exit;
  end;

    //
  ComboTargetOrder.Visible := (FOrderType in [otChange, otCancel]);
  LabelOrgOrder.Visible := ComboTargetOrder.Visible;
  ButtonUpdate.Visible := ComboTargetOrder.Visible;
    //
  EditPrice.Visible := (FOrderType <> otCancel);
  LabelPrice.Visible := EditPrice.Visible;
  LabelPriceRange.Visible := EditPrice.Visible;
    //
  ComboPriceControl.Visible := not ComboTargetOrder.Visible;
  LabelPriceType.Visible := ComboPriceControl.Visible;
    //
  ComboTimeToMarket.Enabled := ComboPriceControl.Enabled;
  LabelFillType.Enabled := ComboTimeToMarket.Enabled;
  LabelFillTypeDesc.Enabled := ComboTimeToMarket.Enabled;

    //
  Clear;

    //-- if an account and an symbol was selected, then do
  if (ComboAccount.ItemIndex >= 0) and (ComboSymbol.ItemIndex >= 0) then
    ComboSymbolChange(ComboSymbol);

    //
  if FOrderType in [otChange, otCancel] then
    ComboTargetOrderChange(ComboTargetOrder);

    //-- focus control
  if FAccount = nil then
  begin
    if ComboAccount.CanFocus then
      ComboAccount.SetFocus;
  end else
  if FSymbol = nil then
  begin
    if ComboSymbol.CanFocus then
      ComboSymbol.SetFocus;
  end else
  if FOrderType in [otChange, otCancel] then
  begin
    if ComboTargetOrder.CanFocus then
      ComboTargetOrder.SetFocus;
  end else
  begin
    if EditVolume.CanFocus then
      EditVolume.SetFocus
    else
    if EditPrice.CanFocus then
      EditPrice.SetFocus;
  end;
end;

procedure TOrderForm.TabOrderTypeChanging(Sender: TObject;
  var AllowChange: Boolean);
begin

end;

// select account
procedure TOrderForm.ComboAccountChange(Sender: TObject);
begin
  FAccount := GetComboObject(ComboAccount) as TAccount;
  if FAccount = nil then Exit;
    //
  ComboSymbolChange(ComboSymbol);
end;

// select symbol
procedure TOrderForm.ComboSymbolChange(Sender: TObject);
begin
  if FEngine = nil then Exit;

    // get symbol
  FSymbol := GetComboObject(ComboSymbol) as TSymbol;
  if FSymbol = nil then Exit;


  FEngine.SymbolCore.SymbolCache.AddSymbol(FSymbol);
  ComboSymbol.Items.Clear;
  FEngine.SymbolCore.SymbolCache.GetList(ComboSymbol.Items);
  SetComboIndex(ComboSymbol, FSymbol);

    // update target order list
  if FOrderType in [otChange, otCancel] then  
    ButtonUpdateClick(ButtonUpdate);

    //
  if not(SpeedReset.Down) then
    EditPrice.Text := '0';

    // price range
  LabelPriceRange.Caption :=
             Format('%.2f ~ %.2f',[FSymbol.LimitLow, FSymbol.LimitHigh]);

    // time to market
  ComboTimeToMarket.Enabled := True;
  LabelFillType.Enabled := ComboTimeToMarket.Enabled;
  LabelFillTypeDesc.Enabled := ComboTimeToMarket.Enabled;

    //
  if EditVolume.CanFocus then
    EditVolume.SetFocus;
end;

//-------------------------------------------------------------------< status >

procedure TOrderForm.ShowStatus(stMsg : String);
begin
  StatusMsg.SimpleText := stMsg;
end;

//-------------------------------------------------------------------< action >

// send order
procedure TOrderForm.ButtonSendClick(Sender: TObject);
var
  aTarget: TOrder;
  iTargetNo, iVolume: Integer;
  dPrice: Double;
  pcValue: TPriceControl;
  tmValue: TTimeToMarket;
  aTicket: TOrderTicket;
begin
  if FEngine = nil then Exit;

    // check account selection
  if FAccount = nil then
   begin
    ShowMessage('Select an account!');
    if ComboAccount.CanFocus then
      ComboAccount.SetFocus;
    Exit;
  end;

    // check symbol selection
  if FSymbol = nil then
  begin
    ShowMessage('Select a symbol!');
    if ComboSymbol.CanFocus then
      ComboSymbol.SetFocus;
    Exit;
  end;

    // check target order
  if FOrderType in [otChange, otCancel] then
    if ComboTargetOrder.ItemIndex = -1 then
    begin
      ShowMessage('Select a target order!');
      if ComboTargetOrder.CanFocus then
        ComboTargetOrder.SetFocus;
      Exit;
    end else
    begin
      aTarget := GetComboObject(ComboTargetOrder) as TOrder;
      if aTarget <> nil then
        iTargetNo := aTarget.OrderNo
      else
      begin
        ShowMessage('The target order is invalid!');
        if ComboTargetOrder.CanFocus then
          ComboTargetOrder.SetFocus;
        Exit;
      end;
    end
  else
    iTargetNo := -1;

    // check volumee
  iVolume := StrToIntDef(EditVolume.Text,0);

  if iVolume = 0 then
  begin
    ShowMessage('The volume can not be zero!');
    if EditVolume.CanFocus then
      EditVolume.SetFocus;
    Exit;
  end;

    // price control
  case ComboPriceControl.ItemIndex of
    0: pcValue := pcLimit;
    1: pcValue := pcMarket;
    2: pcValue := pcLimitToMarket;
    3: pcValue := pcBestLimit;
    else
    begin
      ShowMessage('Select price control!');
      if ComboPriceControl.CanFocus then
        ComboPriceControl.SetFocus;
      Exit;
    end;
  end;

    // price
  dPrice := StrToFloatDef(EditPrice.Text, 0.0);

    // time to market
  case ComboTimeToMarket.ItemIndex of
    0: tmValue := tmGTC;
    1: tmValue := tmFOK;
    2: tmValue := tmIOC;
    4: tmValue := tmFAS;
    else
    begin
      ShowMessage('Select time-to-market!');
      if ComboTimeToMarket.CanFocus then
        ComboTimeToMarket.SetFocus;
      Exit;
    end;
  end;
        {
    // confirm
  if not ConfirmOrder(Self, FOrderType, FAccount, FSymbol, FSide,
                  iVolume, pcValue, dPrice, tmValue, iTargetNo) then
    Exit;
      }
    // get a ticket
  aTicket := FEngine.TradeCore.OrderTickets.New(Self);

    //
  case FOrderType of
    otNormal:
      FEngine.TradeCore.Orders.NewNormalOrder(gEnv.ConConfig.UserID, FAccount, FSymbol,
         FSide * iVolume, pcValue, dPrice, tmValue, aTicket);
    otChange:
      FEngine.TradeCore.Orders.NewChangeOrder(aTarget, iVolume, pcValue,
         dPrice, tmValue, aTicket);
    otCancel:
      FEngine.TradeCore.Orders.NewCancelOrder(aTarget, iVolume, aTicket);
  end;

    //
  if FEngine.TradeBroker.Send(aTicket) > 0 then
    ShowStatus('The order has been sent')
  else
    ShowMessage('Failed to send the order!');
end;

// cancel
procedure TOrderForm.ButtonCancelClick(Sender: TObject);
begin
  Close;
end;

//-----------------------------------------------------------------< dialogs >

// select symbol
procedure TOrderForm.ButtonSymbolClick(Sender: TObject);
var
  aSymbol : TSymbol;
  //aDlg: TSymbolDialog;
begin
  if FEngine = nil then Exit;

  if gSymbol = nil then
  begin
    gSymbol := TSymbolDialog.Create(Self);
    gSymbol.SymbolCore  := FEngine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
        // add to the cache
      FEngine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);
        //
      ComboSymbol.Items.Clear;
      FEngine.SymbolCore.SymbolCache.GetList(ComboSymbol.Items);
      SetComboIndex(ComboSymbol, gSymbol.Selected);
        // apply
      ComboSymbolChange(ComboSymbol);
    end;
  finally
    gSymbol.Hide;
  end;
    //
end;

//---------------------------------------------------------------------< misc >

procedure TOrderForm.Clear;
begin
  if ComboTargetOrder.ItemIndex <> -1 then
    ComboTargetOrder.ItemIndex := -1;
  EditVolume.Text := '0';
  EditPrice.Text := '0.0';
  LabelPriceRange.Caption := '...';
  ComboPriceControl.ItemIndex := 0; // limit
  ComboTimeToMarket.ItemIndex := 0; // GTC (good-till-canceled
end;
 
// update active orders
procedure TOrderForm.ButtonUpdateClick(Sender: TObject);
begin
  if FEngine = nil then Exit;

  ComboTargetOrder.Items.Clear;
  FEngine.TradeCore.Orders.ActiveOrders.GetFilteredList(ComboTargetOrder.Items,
     otNormal, FAccount, FSymbol);
    //
  if ComboTargetOrder.Items.Count > 0 then
  begin
    SetComboIndex(ComboTargetOrder, 0);
    ComboTargetOrderChange(ComboTargetOrder);
  end;
end;

// select target order
procedure TOrderForm.ComboTargetOrderChange(Sender: TObject);
var
  aOrder : TOrder;
begin
    // redundant
  if FOrderType = otNormal then Exit;

    // get the selected target order
  aOrder := GetComboObject(ComboTargetOrder) as TOrder;
  if aOrder = nil then Exit;

    // set default volume
  EditVolume.Text := IntToStr(aOrder.ActiveQty);

    // set input focus on the volume input
  if EditVolume.CanFocus then
    EditVolume.SetFocus;
end;

// price control change
procedure TOrderForm.ComboPriceControlChange(Sender: TObject);
begin
    // set visiblity of the price input
  EditPrice.Visible := (ComboPriceControl.ItemIndex in [0,2]);
  LabelPrice.Visible := EditPrice.Visible;
  LabelPriceRange.Visible := EditPrice.Visible;
    // reset value
  EditPrice.Text := '0';
end;

end.
