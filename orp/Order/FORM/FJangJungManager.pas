unit FJangJungManager;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleQuoteBroker, CleOrders, CleSymbols, CleAccounts,  CleStorage, CleDistributor,

  GleConsts, GleTypes, GleLib,

  CleFORMConst, CleFormManager, CleFrontOrderIF, CleJangJungManager,

  StdCtrls, Buttons, ExtCtrls, ComCtrls

  ;

type
  TFrmJangJungManager = class(TForm)
    stBar: TStatusBar;
    CheckBox3: TCheckBox;
    edtBidShift: TEdit;
    edtAskShift: TEdit;
    Label12: TLabel;
    Label11: TLabel;
    Panel2: TPanel;
    BtnCohesionSymbol: TSpeedButton;
    cbSymbol: TComboBox;
    ComboAccount: TComboBox;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure cbSymbolChange(Sender: TObject);
    procedure edtBidShiftChange(Sender: TObject);
    procedure edtBidShiftKeyPress(Sender: TObject; var Key: Char);
    procedure BtnCohesionSymbolClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);

  private
    { Private declarations }
    FormManager :  TFrontManager;
    FParam  : TFORMParam;
    FRow  : integer;
    FSymbol : TSymbol;
    FAccount: TAccount;
    FQuote  : TQuote;
    FOrderIF: TFrontOrderIF;
    FVolStopsList : TList;
    procedure ShowState(index: integer; value: string);
    procedure ParamChange(aIF: TFrontOrderIF);
    procedure Notify(Sender: TObject; value: boolean);
  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
    procedure SetDefaultParam;
    procedure DoLog(Sender: TObject; Value: String);
    procedure OrderProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);


  end;

var
  FrmJangJungManager: TFrmJangJungManager;

implementation

uses
  GAppEnv, CleFQN, CleQuoteTimers;

{$R *.dfm}

procedure TFrmJangJungManager.BtnCohesionSymbolClick(Sender: TObject);
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

procedure TFrmJangJungManager.Button1Click(Sender: TObject);
var
  stName : string;
begin
  // 로그 보기
  stName := Format( '%s/%s.log', [ WIN_JJUNG2,
    FormatDateTime( 'yyyymmdd', GetQuoteDate)
    ]);
  ShowNotePad( Handle, stName );

end;

procedure TFrmJangJungManager.Button2Click(Sender: TObject);
begin
  close;
end;

procedure TFrmJangJungManager.cbSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  if cbSymbol.ItemIndex = -1 then Exit;
  aSymbol := cbSymbol.Items.Objects[cbSymbol.ItemIndex] as TSymbol;
  if (aSymbol = nil) then Exit;
  FOrderIF.Symbol := aSymbol;

  FSymbol := aSymbol;
  edtBidShiftChange( nil );
  //edtBase.Text  := FloatToS
end;


procedure TFrmJangJungManager.CheckBox3Click(Sender: TObject);
var
  bCheck : boolean;
  aIF    : TFrontOrderIF;
begin

  bCheck  := CheckBox3.Checked;
  aIf := FormManager.Find(ottJangJung2 );
  if aIF = nil then Exit;
  ParamChange( aIF );

  if bCheck then
  begin
    bCheck  := TJangJungManager(aIf).Start;
    if bCheck then begin
      ShowState(0, '주문관리중');
      Color := $0000FF80;
    end
    else
      CheckBox3.Checked := false;
  end
  else begin
    TJangJungManager(aIf).Stop;
    Color := clBtnFace;
    ShowState(0, '');
  end;

end;

procedure TFrmJangJungManager.SetDefaultParam;
begin
  edtBidShift.Text  := '0.3';
  edtAskShift.Text  := '0.3';
  //FormManager.SetParam( FParam );
end;

procedure TFrmJangJungManager.ShowState(  index: integer; value : string );
begin
  stBar.Panels[0].Text  := '';
  stBar.Panels[1].Text  := '';
  if not CheckBox3.Checked then
    stBar.Panels[0].Text  := '';

  stBar.Panels[index].Text  := value
end;

procedure TFrmJangJungManager.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin

  aAccount  := GetComboObject( ComboAccount ) as TAccount;

  if aAccount <> nil then
  begin
    //FormManager.SetAccount( aAccount );
    FOrderIF.Account  := aAccount;
    FAccount  := aAccount;
  end;

  edtBidShiftChange( nil );
end;

procedure TFrmJangJungManager.DoLog(Sender: TObject; Value: String);
begin
  gEnv.EnvLog( WIN_JJUNG2, Value);
end;

procedure TFrmJangJungManager.edtBidShiftChange(Sender: TObject);
var
   aIF : TFrontOrderIF;
begin
  aIF := FormManager.Find(ottJangJung2);
  if aIF = nil then Exit;
  CheckBox3.Checked := false;

  ShowState( 0 , '조건설정중');
end;

procedure TFrmJangJungManager.edtBidShiftKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#13,'-', '.', #8]) then
    Key := #0;
end;

procedure TFrmJangJungManager.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmJangJungManager.FormCreate(Sender: TObject);
var
  aMarkets : TMarketTypes;
  aIF : TFrontOrderIF;
begin
  FormManager :=  gEnv.Engine.FormManager;

  aIF := FormManager.New(ottJangJung2);
  aIF.OnLog := DoLog;
  aIF.OnEvent:= Notify;
  FOrderIF  := aIF;

  FAccount  := nil;
  gEnv.Engine.TradeCore.Accounts.GetList( ComboAccount.Items );

  aMarkets := [ mtFutures, mtOption ];
  gEnv.Engine.SymbolCore.SymbolCache.GetLists2( cbSymbol.Items, aMarkets );


  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex  := 0;
    ComboAccountChange( nil );
  end;

  Label11.Color := LONG_COLOR;
  Label12.Color := SHORT_COLOR;

  SetDefaultParam;
  FVolStopsList := TList.Create;
  //gEnv.Engine.TradeBroker.Subscribe( Self, OrderProc );
end;

procedure TFrmJangJungManager.FormDestroy(Sender: TObject);
begin

  FOrderIF  := nil;
  if FSymbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );
  gEnv.Engine.FormManager.JangJungManager  := nil;
  gEnv.Engine.FormManager.Del( ottJangJung2 );

  //gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;


procedure TFrmJangJungManager.Notify(Sender: TObject; value: boolean);
begin
  if Sender = nil then Exit;

  case TFrontOrderIF( Sender ).ManagerType of
    ottJangJung2   : CheckBox3.Checked := Value;
  end;

end;

procedure TFrmJangJungManager.LoadEnv(aStorage: TStorage);
var
  i : integer;
  aIF : TFrontOrderIF;
begin
  if aStorage = nil then Exit;

  edtBidShift.Text :=   aStorage.FieldByName('BidShift' ).AsString ;
  edtAskShift.Text :=   aStorage.FieldByName('AskShift' ).AsString ;


  aIF := FormManager.Find( ottJangJung2 );
  if aIF <> nil then
    ParamChange( aIF );
end;

procedure TFrmJangJungManager.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;
  aStorage.FieldByName('BidShift' ).AsString := edtBidShift.Text;
  aStorage.FieldByName('AskShift' ).AsString := edtAskShift.Text;

end;

procedure TFrmJangJungManager.OrderProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;

  case Integer(EventID) of
      // order events
    ORDER_NEW,  
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CONFIRMED,
    ORDER_CHANGED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,
    ORDER_FILLED: FormManager.DoOrder(DataObj as TOrder);
  end;
end;

procedure TFrmJangJungManager.ParamChange(aIF: TFrontOrderIF);
begin
  FParam.BidShift   := StrToFloatDef( edtBidShift.Text, 0);
  FParam.AskShift   := StrToFloatDef( edtAskShift.Text, 0);
  FParam.OldVer     := true;
  aIF.Param := FParam;
end;

end.
