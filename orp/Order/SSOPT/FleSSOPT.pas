unit FleSSOPT;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, FraSSOPT, GleTypes,
  CleSymbols, CleDistributor, CleSsoptData;

type
  TFrmSsopt = class(TForm)
    Panel1: TPanel;
    ListView1: TListView;
    btnClose: TButton;
    Button1: TButton;
    Button2: TButton;
    ListView2: TListView;
    Panel2: TPanel;
    Panel3: TPanel;
    FraMain1: TFraMain;
    FraMain2: TFraMain;
    Panel4: TPanel;
    FraMain3: TFraMain;
    Panel5: TPanel;
    FraMain4: TFraMain;
    plOrder: TPanel;
    plAcpt: TPanel;
    plFill: TPanel;
    plMaster: TPanel;
    plQuoteTime: TPanel;
    plDelay: TPanel;
    btnLast: TButton;
    panel20: TPanel;
    plConn: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnLastClick(Sender: TObject);
  private
    { Private declarations }
    FFrames : array[0..3] of TFraMain;
    procedure InitFrame;
    function SymbolCheck(Value : TObject ) : boolean;
    procedure SymbolState( aState : TSymbolState );
    procedure TotalState( aState : TTotalState );
    procedure LastState( aState : TLastState );

  public
    { Public declarations }
    procedure SSoptEventHandler(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

  end;

var
  FrmSsopt: TFrmSsopt;

implementation

uses
  GAppEnv, GleConsts;
{$R *.dfm}

procedure TFrmSsopt.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmSsopt.btnLastClick(Sender: TObject);
begin
  FFrames[0].SendPacket(sotLast);
end;

procedure TFrmSsopt.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmSsopt.FormCreate(Sender: TObject);
begin
  FFrames[0] := FraMain1;
  FFrames[1] := FraMain2;
  FFrames[2] := FraMain3;
  FFrames[3] := FraMain4;
  InitFrame;
  gEnv.Engine.SsoptBroker.Subscribe(self, SSoptEventHandler);
end;

procedure TFrmSsopt.FormDestroy(Sender: TObject);
begin
  FFrames[0].SendPacket(sotClose);
  gEnv.Engine.SsoptBroker.Unsubscribe(self);
end;

procedure TFrmSsopt.InitFrame;
var
  i : integer;
begin
  for i := 0 to MAX_INDEX-1 do
  begin
    FFrames[i].InitParams(i);
    FFrames[i].OnSymbolCheck := SymbolCheck;
  end;
end;

procedure TFrmSsopt.SSoptEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
var
  aSState : TSymbolState;
  aTState : TTotalState;
  aLState : TLastState;
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;
  if DataObj = nil then exit;

  case Integer(EventID) of
    SYMBOL_STATE :
    begin
      aSState := DataObj as TSymbolState;
      SymbolState(aSState);
    end;
    TOTAEL_STATE :
    begin
      aTState := DataObj as TTotalState;
      TotalState(aTState);
    end;
    LAST_STATE :
    begin
      aLState := DataObj as TLastState;
      LastState(aLState);
    end;
  end;


end;

function TFrmSsopt.SymbolCheck(Value: TObject) : boolean;
var
  i : integer;
  aSymbol : TSymbol;
begin
  Result := false;
  aSymbol := Value as TSymbol;
  for i := 0 to MAX_INDEX-1 do
  begin
    if FFrames[i].Symbol = aSymbol then
    begin
      Result := true;
      break;
    end;  
  end;

end;

procedure TFrmSsopt.SymbolState(aState: TSymbolState);
var
  i : integer;
begin
  for i := 0 to MAX_INDEX-1 do
    FFrames[i].SymbolState(aState);
end;

procedure TFrmSsopt.TotalState(aState: TTotalState);
begin
  plConn.Caption := aState.SsoptCon;
  plOrder.Caption := aState.OrdSess;
  plAcpt.Caption := aState.AcpSess;
  plFill.Caption := aState.filSess;
  plMaster.Caption := astate.SymbolRev;
  plQuoteTime.Caption := aState.QuoteTime;
  plDelay.Caption := aState.QuoteDelay;
end;

procedure TFrmSsopt.LastState(aState: TLastState);
var
  i : integer;
begin
  for i := 0 to MAX_INDEX-1 do
    FFrames[i].LastState(aState);

end;


end.
