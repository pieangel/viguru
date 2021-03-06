unit FSavePosition;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleQuoteBroker, CleOrders, CleSymbols, CleAccounts,  CleStorage, CleDistributor,

  GleConsts, GleTypes, GleLib, CleOrderManager, CleFORMOrderItems,

  CleFORMConst, CleFormManager, CleFrontOrderIF, StdCtrls, Buttons, ExtCtrls,
  ComCtrls
  ;

type
  TFrmOrderMngr = class(TForm)
    Panel2: TPanel;
    BtnCohesionSymbol: TSpeedButton;
    cbSymbol: TComboBox;
    ComboAccount: TComboBox;
    gbPos: TGroupBox;
    chSavePosRun: TCheckBox;
    edtAsk: TEdit;
    edtBid: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtAskPos: TEdit;
    stBar: TStatusBar;
    Button1: TButton;
    gbOrder: TGroupBox;
    cbRun: TCheckBox;
    edtAsk2: TEdit;
    edtBid2: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Button2: TButton;
    Panel1: TPanel;
    Panel3: TPanel;
    Label6: TLabel;
    edtBidPos: TEdit;
    udAsk: TUpDown;
    udBid: TUpDown;
    udAskPos: TUpDown;
    udBidPos: TUpDown;
    udAsk2: TUpDown;
    udBid2: TUpDown;
    GroupBox1: TGroupBox;
    Label7: TLabel;
    edtAllCnlQty: TEdit;
    Label8: TLabel;
    edtAllCnlInterval: TEdit;
    CnlTimer: TTimer;
    Button3: TButton;
    Button4: TButton;
    procedure ComboAccountChange(Sender: TObject);
    procedure cbSymbolChange(Sender: TObject);
    procedure BtnCohesionSymbolClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure edtAskChange(Sender: TObject);
    procedure edtAskKeyPress(Sender: TObject; var Key: Char);
    procedure chSavePosRunClick(Sender: TObject);
    procedure edtBidKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure edtAsk2Change(Sender: TObject);
    procedure cbRunClick(Sender: TObject);

    procedure edtAllCnlQtyKeyPress(Sender: TObject; var Key: Char);
    procedure CnlTimerTimer(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure cbUseMothClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    FStorage  : TStorage;
    FAccount  : TAccount;
    FSymbol   : TSymbol;

    FOrderItem : TOrderItem;
    FCnt : integer;
    FJangJungIF : TFrontOrderIF;
    FOrderManIF : TFrontOrderIF;

  public
    { Public declarations }

    FormManager :  TFrontManager;
    Param  : TFORMParam;
    IfList : TList;
    FDataDiv : integer;

    procedure ShowState(index: integer; value: string);
    procedure ParamChange(aIF : TFrontOrderIF);
    procedure Notify(Sender: TObject; value: boolean);

    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
    procedure SetDefaultParam;
    procedure DoLog(Sender: TObject; Value: String);
  end;

var
  FrmOrderMngr: TFrmOrderMngr;

implementation

uses
  GAppEnv, CleFQN, CleQuoteTimers, CleJangJungManager;

{$R *.dfm}

procedure TFrmOrderMngr.BtnCohesionSymbolClick(Sender: TObject);
begin
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
        // add to the cache
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);
        //
      AddSymbolCombo(gSymbol.Selected, cbSymbol);
        // apply
      cbSymbolChange(cbSymbol);
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmOrderMngr.Button1Click(Sender: TObject);
var
  stName : string;
  iTag : integer;
begin
  // ???? ????
  iTag := TButton( Sender ).Tag;
  case iTag of
    0 :   stName := Format( '%s/%s.log', [ WIN_JJUNG,
        FormatDateTime( 'yyyymmdd', GetQuoteDate)
        ]);
    1 :   stName := Format( '%s/%s.log', [ WIN_JPOS,
        FormatDateTime( 'yyyymmdd', GetQuoteDate)
        ]);
    2 :  stName := Format( '%s/%s.log', [ WIN_LOSS,
        FormatDateTime( 'yyyymmdd', GetQuoteDate)
        ]);

  end;

  ShowNotePad( Handle, stName );
end;

procedure TFrmOrderMngr.Button3Click(Sender: TObject);

var
  bOK : boolean;
  stLog : string;
  i : integer;
begin
  if ( FAccount = nil ) or ( FSymbol = nil ) then
  begin
    ShowMessage( '???? or ?????????? ??????????' );
    Exit;
  end;

  FOrderItem := FormManager.OrderItems.Find( FAccount, FSymbol );
  if FOrderItem = nil then
  begin
    ShowMessage( '?????? ?????? ????' );
    Exit;
  end;

  if ( edtAllCnlQty.Text  = '' )  or
    ( edtAllCnlInterval.Text = '' ) then
  begin
    ShowMessage( '???? ?????? ????????' );
    Exit;
  end;

  GroupBox1.Color := clRed;
  ShowState(0, '???? ???? ??');

  stLog := Format('???????? ???? : %s(%s) : %s, %s',
    [
      FAccount.Code,
      FSymbol.ShortCode,
      edtAllCnlQty.Text ,
      edtAllCnlInterval.Text
    ]
    );
  gEnv.EnvLog( WIN_LOSS, stLog );

  FCnt  := StrToInt( edtAllCnlQty.Text ) ;
  bOK := FormManager.DoCancels( FOrderItem, 0, FCnt   );

  CnlTimer.Interval := StrToIntDef( edtAllCnlInterval.Text , 1000 );
  CnlTimer.Enabled  := bOK;
  Button3.Enabled := not bOK ;

  if not bOK then
  begin
    ShowState(0, '???? ???? ????');
    GroupBox1.Color := clBtnFace;
    Button3.Enabled := true;
    stLog := '???? ???? ????';
    gEnv.EnvLog( WIN_LOSS, stLog );
  end;

  Param.DataType := dtTotalCancel;
  Param.Cnt := StrToIntDef(edtAllCnlQty.Text, 10);
  Param.Interval := StrToIntDef(edtAllCnlInterval.Text, 300);
end;

procedure TFrmOrderMngr.cbRunClick(Sender: TObject);
var
  bCheck : boolean;
begin

  bCheck  := cbRun.Checked;
  if FJangJungIF = nil then Exit;
  ParamChange( FJangJungIF );

  if bCheck then
  begin
    bCheck  := TOrderManager(FJangJungIF).Start;
    if bCheck then begin
      ShowState(0, '??????????');
      gbOrder.Color := $00C8C8FF ;
    end
    else
      cbRun.Checked := false;
  end
  else begin
    TOrderManager(FJangJungIF).Stop;
    gbOrder.Color := clBtnFace;
    ShowState(0, '');
  end;

end;

procedure TFrmOrderMngr.chSavePosRunClick(Sender: TObject);
var
  bCheck : boolean;
begin

  bCheck  := chSavePosRun.Checked;
  //aIf := FormManager.Find(ottOrdManager );
  if FOrderManIF = nil then Exit;
  ParamChange( FOrderManIF );


  if bCheck then
  begin
    bCheck  := TOrderManager(FOrderManIF).Start;
    if bCheck then begin
      ShowState(1, '????????????');
      gbPos.Color := $0000FF80;
    end
    else
      chSavePosRun.Checked := false;

  end
  else begin
    TOrderManager(FOrderManIF).Stop;
    gbPos.Color := clBtnFace;
    ShowState(1, '');
  end;



end;

procedure TFrmOrderMngr.cbSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
  bRet : boolean;
  stLog : string;
begin
  if cbSymbol.ItemIndex = -1 then Exit;

  aSymbol := cbSymbol.Items.Objects[cbSymbol.ItemIndex] as TSymbol;
  if (aSymbol = nil) then Exit;
  if FSymbol = aSymbol then exit;

  bRet := gEnv.Engine.FormBroker.RedundancyChecks.RedundancyCheck(aSymbol, FSymbol, FAccount, FAccount, self, rdtOrderMan);

  if not bRet then
  begin
    cbSymbol.ItemIndex := -1;
    gEnv.Engine.FormBroker.RedundancyChecks.AlramBox(aSymbol, FAccount, rdtOrderMan);
    aSymbol := nil;
  end;

  FJangJungIF.Symbol := aSymbol;
  FOrderManIF.Symbol := aSymbol;
  FSymbol := aSymbol;
  edtAsk2Change( nil );
  edtAskChange( nil );
end;



procedure TFrmOrderMngr.cbUseMothClick(Sender: TObject);
begin

  Param.StartStop := 0;

  if cbRun.Checked then
  begin
    Param.DataType := dtOrdCancel;
  end;

  if chSavePosRun.Checked then
  begin
    Param.DataType := dtOrdPosCancel;
  end;
end;

procedure TFrmOrderMngr.CnlTimerTimer(Sender: TObject);
var
  bOK : boolean;

begin
  if FOrderItem = nil then
  begin
    CnlTimer.Enabled := false;
    Exit;
  end;

  bOK := FormManager.DoCancels( FOrderItem, 0, FCnt   );

  if not bOK then
  begin
    CnlTimer.Enabled := false;
    ShowState(0, '???? ???? ????');
    GroupBox1.Color := clBtnFace;
    Button3.Enabled := true;
    gEnv.EnvLog( WIN_LOSS, '???? ???? ????');
  end;
end;

procedure TFrmOrderMngr.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
  bRet : boolean;
  stLog : string;
begin
  aAccount  := GetComboObject( ComboAccount ) as TAccount;

  if FAccount = aAccount then exit;

  if FSymbol <> nil then
  begin
    bRet := gEnv.Engine.FormBroker.RedundancyChecks.RedundancyCheck(FSymbol, FSymbol, aAccount, FAccount, self, rdtOrderMan);

    if not bRet then
    begin
      ComboAccount.ItemIndex := -1;
      gEnv.Engine.FormBroker.RedundancyChecks.AlramBox(FSymbol, aAccount, rdtOrderMan);
      aAccount := nil;
    end;
  end;

  
  FJangJungIF.Account := aAccount;
  FOrderManIF.Account := aAccount;

  FAccount := aAccount;
  edtAsk2Change( nil );
  edtAskChange( nil );
end;

procedure TFrmOrderMngr.DoLog(Sender: TObject; Value: String);
begin
  case TFrontOrderIF( Sender ).ManagerType of
    ottOrdManager : gEnv.EnvLog( WIN_JPOS, Value);
    ottJangJung   : gEnv.EnvLog( WIN_JJUNG, Value);
  end;
end;

procedure TFrmOrderMngr.edtAllCnlQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#13, #8]) then
    Key := #0;
end;

procedure TFrmOrderMngr.edtAsk2Change(Sender: TObject);
begin
  cbRun.Checked := false;
  ShowState( 0 , '??????????');
end;

procedure TFrmOrderMngr.edtAskChange(Sender: TObject);
begin
  chSavePosRun.Checked := false;
  ShowState( 1 , '??????????');
  Param.DataType := dtOrdPosCancel;

end;

procedure TFrmOrderMngr.edtAskKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#13, #8]) then
    Key := #0;
end;

procedure TFrmOrderMngr.edtBidKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['1'..'9',#13, #8]) then
    Key := #0;
end;

procedure TFrmOrderMngr.FormActivate(Sender: TObject);
begin
  if (Tag <=0 ) or ( 100 <= Tag ) then
    Exit
  else
    Caption := Format('%dth ????????', [ Tag ] );
end;

procedure TFrmOrderMngr.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmOrderMngr.FormCreate(Sender: TObject);
var
  aMarkets : TMarketTypes;
begin

  FAccount  := nil;
  FSymbol   := nil;

  FormManager :=  gEnv.Engine.FormManager;
  FStorage  := TStorage.Create;

  FOrderManIF :=  FormManager.New(ottOrdManager);
  FOrderManIF.OnLog := DoLog;
  FOrderManIF.OnEvent:= Notify;

  FJangJungIF := FormManager.New(ottJangJung);
  FJangJungIF.OnLog := DoLog;
  FJangJungIF.OnEvent:= Notify;
  gEnv.Engine.TradeCore.Accounts.GetList( ComboAccount.Items );

  aMarkets := [ mtFutures, mtOption ];
  gEnv.Engine.SymbolCore.SymbolCache.GetLists2( cbSymbol.Items, aMarkets );

  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex  := 0;
    ComboAccountChange( nil );
  end;

  gbPos.Color := clBtnFace;
  gbOrder.Color := clBtnFace;

end;

procedure TFrmOrderMngr.FormDestroy(Sender: TObject);
begin

  FStorage.Free;

  gEnv.Engine.FormManager.Del( FJangJungIF );
  Param.StartStop := 0;
  Param.DataType := dtOrdCancel;

  gEnv.Engine.FormManager.Del( FOrderManIF );
  Param.DataType := dtOrdPosCancel;

  gEnv.Engine.FormBroker.RedundancyChecks.Del(FSymbol, FAccount,self, rdtOrderMan);

end;

procedure TFrmOrderMngr.LoadEnv(aStorage: TStorage);
var
  code : string;
  aSymbol : TSymbol;
begin
  if aStorage = nil then Exit;

  udAsk2.Position := aStorage.FieldByName('edtAsk2' ).AsInteger ;
  udBid2.Position := aStorage.FieldByName('edtBid2' ).AsInteger ;

  udAsk.Position :=   aStorage.FieldByName('edtAsk' ).AsInteger ;
  udBid.Position :=   aStorage.FieldByName('edtBid' ).AsInteger ;

  udAskPos.Position  := aStorage.FieldByName('edtAskPos').AsInteger;
  udBidPos.Position  := aStorage.FieldByName('edtBidPos').AsInteger;

  edtAllCnlQty.Text :=  aStorage.FieldByName('edtAllCnlQty').AsString;
  edtAllCnlInterval.Text  := aStorage.FieldByName('edtAllCnlInterval').AsString;

  code  := aStorage.FieldByName('code' ).AsString;

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( Code );
  if aSymbol <> nil then
  begin
    gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(aSymbol);
    AddSymbolCombo(aSymbol, cbSymbol);
    cbSymbolChange(cbSymbol);
  end;

end;

procedure TFrmOrderMngr.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  if FOrderManIF <> nil then
    if FOrderManIF.Symbol <> nil then
      aStorage.FieldByName('code' ).AsString := FOrderManIF.Symbol.Code
    else
      aStorage.FieldByName('code' ).AsString := '';


  aStorage.FieldByName('edtAsk2' ).AsString := edtAsk2.Text;
  aStorage.FieldByName('edtBid2' ).AsString := edtBid2.Text;

  aStorage.FieldByName('edtAsk' ).AsString := edtAsk.Text;
  aStorage.FieldByName('edtBid' ).AsString := edtBid.Text;

  aStorage.FieldByName('edtAskPos').AsString  := edtAskPos.Text;
  aStorage.FieldByName('edtBidPos').AsString  := edtBidPos.Text;

  aStorage.FieldByName('edtAllCnlQty').AsString := edtAllCnlQty.Text;
  aStorage.FieldByName('edtAllCnlInterval').AsString  := edtAllCnlInterval.Text;
end;

procedure TFrmOrderMngr.Notify(Sender: TObject; value: boolean);
begin
  if Sender = nil then Exit;

  case TFrontOrderIF( Sender ).ManagerType of
    ottOrdManager   : chSavePosRun.Checked := Value;
    ottJangJung   : cbRun.Checked := Value;
  end;
end;

procedure TFrmOrderMngr.ParamChange(aIF : TFrontOrderIF);
begin

  if aIF = nil then Exit;

  case aIF.ManagerType of
    ottJangBefore: ;
    ottJangStart: ;
    otSimulEndJust: ;
    ottJangJung:
      begin
        Param.Asks  := StrToIntDef( edtAsk2.Text, 3 );
        Param.Bids  := StrToIntDef( edtBid2.Text, 3 );
        Param.OldVer     := false;
        Param.DataType := dtOrdCancel;
        Param.Cnt := StrToIntDef( edtAllCnlQty.Text, 10 );
        Param.Interval := StrToIntDef( edtAllCnlInterval.Text, 1000 );
        if cbRun.Checked then
          Param.StartStop := 1
        else
          Param.StartStop := 0;
      end;
    ottOrdManager:
      begin
        Param.Asks  := StrToIntDef( edtAsk.Text, 3 );
        Param.Bids  := StrToIntDef( edtBid.Text, 3 );
        Param.AskPos:= StrToIntDef( edtAskPos.Text, 30 );
        Param.BidPos:= StrToIntDef( edtBidPos.Text, 30 );
        Param.DataType := dtOrdPosCancel;
        Param.Cnt := StrToIntDef( edtAllCnlQty.Text, 10 );
        Param.Interval := StrToIntDef( edtAllCnlInterval.Text, 1000 );
        if chSavePosRun.Checked then
          Param.StartStop := 1
        else
          Param.StartStop := 0;
      end ;
  end;

  aIF.Param := Param;
end;

procedure TFrmOrderMngr.SetDefaultParam;
begin
{
  Param.Asks  := StrToIntDef( edtAsk.Text, 3 );
  Param.Bids  := StrToIntDef( edtBid.Text, 3 );
  Param.PosQty:= StrToIntDef( edtPosition.Text, 30 );
  }
end;

procedure TFrmOrderMngr.ShowState(index: integer; value: string);
begin
  if not chSavePosRun.Checked then
    stBar.Panels[1].Text  := '';
  if not cbRun.Checked then
    stBar.Panels[0].Text  := '';
  stBar.Panels[index].Text  := value
end;

end.
