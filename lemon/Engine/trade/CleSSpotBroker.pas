unit CleSSpotBroker;

interface

uses
  SysUtils,
  SynthUtil, CleSsoptData, GleConsts, GleTypes, CleSSpotPacket,
  CleDistributor;
type
  TSSoptBroker = class
  private
    FOnSend : TSendMothEvent;
    FDistributor: TDistributor;
    FSymbolState : TSymbolState;
    FTotalState : TTotalState;
    FLastState : TLastState;

    function GetCheck( bFlag : boolean ) : char;
    function AllClearChange(aParams: TSsoptParams) : string;
    function SymobolChange(aParams: TSsoptParams) : string;
    function QtyChange(aParams: TSsoptParams) : string;
    function SliceChange(aParams: TSsoptParams) : string;
    function StrictChange(aParams: TSsoptParams) : string;
    function HogacnlChange(aParams: TSsoptParams) : string;
    function AdjustChange(aParams: TSsoptParams) : string;
    function PreChange(aParams: TSsoptParams) : string;
    function DelayChange(aParams: TSsoptParams) : string;
    function OnOffChange(aParams: TSsoptParams) : string;
    function CloseChange(aParams: TSsoptParams) : string;
    function LastChange(aParams: TSsoptParams) : string;


  public
    constructor Create;
    destructor Destroy; override;
    procedure Send( aType : TSSoptType; aParams : TSsoptParams );

    procedure LiveWire;

    procedure SymbolState(stPacket : string);
    procedure TotalState(stPacket : string);
    procedure LastState(stPacket : string);


    procedure Subscribe(Sender: TObject; aHandler: TDistributorEvent);
    procedure Unsubscribe(Sender: TObject);
    property OnSend : TSendMothEvent read FOnSend write FOnSend;
  end;

implementation

uses
  GAppEnv;

{ TSSoptBroker }

function TSSoptBroker.AdjustChange(aParams: TSsoptParams): string;
var
  Buffer : array of char;
  pData : TSsoptAdjust;
begin
  MovePacket( Format('%.4d',[LenSsoptAdjust - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( SSOPT_ADJUST, pData.HeadData.TrCode );
  MovePacket(Format('%d',[aParams.Index]), pData.CodeIndex);
  pData.LS := aParams.AdjustLS;
  MovePacket(Format('%d',[aParams.AdjustIndex]), pData.Index);

  SetLength(Buffer, LenSsoptAdjust);
  Move(pData, Buffer[0], LenSsoptAdjust);
  SetString( Result, PChar(@Buffer[0]), LenSsoptAdjust);
end;

function TSSoptBroker.AllClearChange(aParams: TSsoptParams): string;
var
  Buffer : array of char;
  pData : TSsoptAllClear;
begin
  MovePacket( Format('%.4d',[LenSsoptAllClear - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( SSOPT_ALLCLEAR, pData.HeadData.TrCode );
  MovePacket(Format('%d',[aParams.Index]), pData.CodeIndex);
  pData.IsCheck := GetCheck(aParams.AllCancelClear);
  SetLength(Buffer, LenSsoptAllClear);
  Move(pData, Buffer[0], LenSsoptAllClear);
  SetString( Result, PChar(@Buffer[0]), LenSsoptAllClear);
end;

function TSSoptBroker.CloseChange(aParams: TSsoptParams): string;
var
  Buffer : array of char;
  pHead : THeadData;
begin
  MovePacket( Format('%.4d',[LenHeadData- Length(pHead.Size)]), pHead.Size );
  MovePacket( SSOPT_CLOSE, pHead.TrCode );

  SetLength(Buffer, LenHeadData );
  Move(pHead, Buffer[0], LenHeadData);
  SetString( Result, PChar(@Buffer[0]), LenHeadData );
end;

constructor TSSoptBroker.Create;
begin
  FDistributor:= TDistributor.Create;
  FSymbolState := TSymbolState.Create;
  FTotalState := TTotalState.Create;
  FLastState := TLastState.Create;
end;

function TSSoptBroker.DelayChange(aParams: TSsoptParams): string;
var
  Buffer : array of char;
  pData : TSsoptDelay;
begin
  MovePacket( Format('%.4d',[LenSsoptDelay - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( SSOPT_DELAY, pData.HeadData.TrCode );
  MovePacket(Format('%d',[aParams.Index]), pData.CodeIndex);

  MovePacket(Format('%.4d', [aParams.DelayAfford]), pData.DelayAfford);
  SetLength(Buffer, LenSsoptDelay );
  Move(pData, Buffer[0], LenSsoptDelay);
  SetString( Result, PChar(@Buffer[0]), LenSsoptDelay );
end;

destructor TSSoptBroker.Destroy;
begin
  FDistributor.Free;
  FSymbolState.Free;
  FTotalState.Free;
  FLastState.Free;
  inherited;
end;

function TSSoptBroker.GetCheck(bFlag: boolean): char;
begin
  if bFlag then
    Result := '1'
  else
    Result := '0';
end;

function TSSoptBroker.HogacnlChange(aParams: TSsoptParams): string;
var
  Buffer : array of char;
  pData : TSsopt1hogacnl;
begin
  MovePacket( Format('%.4d',[LenSsopt1hogacnl - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( SSOPT_1HOGA_CNL , pData.HeadData.TrCode );
  MovePacket(Format('%d',[aParams.Index]), pData.CodeIndex);
  pData.LS := aParams.CnlLS;
  SetLength(Buffer, LenSsopt1hogacnl );
  Move(pData, Buffer[0], LenSsopt1hogacnl);
  SetString( Result, PChar(@Buffer[0]), LenSsopt1hogacnl );
end;

function TSSoptBroker.LastChange(aParams: TSsoptParams): string;
var
  Buffer : array of char;
  pHead : THeadData;
begin
  MovePacket( Format('%.4d',[LenHeadData- Length(pHead.Size)]), pHead.Size );
  MovePacket( SSOPT_NS20_LAST_CONDITION , pHead.TrCode );

  SetLength(Buffer, LenHeadData );
  Move(pHead, Buffer[0], LenHeadData);
  SetString( Result, PChar(@Buffer[0]), LenHeadData );
end;

procedure TSSoptBroker.LiveWire;
var
  Buffer : array of char;
  pHead : THeadData;
  stPacket : string;
  iSize : integer;
  bRet : boolean;
begin
  MovePacket( Format('%.4d',[LenHeadData- Length(pHead.Size)]), pHead.Size );
  MovePacket( SSOPT_POLL , pHead.TrCode );

  SetLength(Buffer, LenHeadData );
  Move(pHead, Buffer[0], LenHeadData);
  SetString( stPacket, PChar(@Buffer[0]), LenHeadData );

  iSize := Length(stPacket);
  if iSize = 0 then exit;
  {
  if Assigned(FOnSend) then
     bRet := FOnSend( iSize, stPacket );
   khw }
end;

function TSSoptBroker.OnOffChange(aParams: TSsoptParams): string;
var
  Buffer : array of char;
  pData : TSsoptOnOff;
begin
  MovePacket( Format('%.4d',[LenSsoptOnOff - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( SSOPT_ONOFF , pData.HeadData.TrCode );
  MovePacket(Format('%d',[aParams.Index]), pData.CodeIndex);
  pData.OnOff := GetCheck(aParams.OnOff);
  SetLength(Buffer, LenSsoptOnOff );
  Move(pData, Buffer[0], LenSsoptOnOff);
  SetString( Result, PChar(@Buffer[0]), LenSsoptOnOff );
end;

function TSSoptBroker.PreChange(aParams: TSsoptParams): string;
var
  Buffer : array of char;
  pData : TSsoptPrequote;
  iQty : integer;
begin
  MovePacket( Format('%.4d',[LenSsoptPreQyote - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( SSOPT_PRE_QUOTE , pData.HeadData.TrCode );
  MovePacket(Format('%d',[aParams.Index]), pData.CodeIndex);

  pData.LS := aParams.PreLS;

  if pData.LS = 'L' then
    iQty := aParams.BidPre
  else
    iQty := aParams.AskPre;
  MovePacket( Format('%.3d',[iQty]), pData.Range);

  SetLength(Buffer, LenSsoptPreQyote );
  Move(pData, Buffer[0], LenSsoptPreQyote);
  SetString( Result, PChar(@Buffer[0]), LenSsoptPreQyote );
end;

function TSSoptBroker.QtyChange(aParams: TSsoptParams): string;
var
  Buffer : array of char;
  pData : TSsoptQty;
begin
  MovePacket( Format('%.4d',[LenSsoptQty - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( SSOPT_QYT, pData.HeadData.TrCode );
  MovePacket(Format('%d',[aParams.Index]), pData.CodeIndex);

  MovePacket( Format('%.5d',[aParams.OrderQty]), pData.Qty);
  SetLength(Buffer, LenSsoptQty );
  Move(pData, Buffer[0], LenSsoptQty);
  SetString( Result, PChar(@Buffer[0]), LenSsoptQty );
end;

procedure TSSoptBroker.Send(aType : TSSoptType; aParams: TSsoptParams);
var
  bRet : boolean;
  iSize : integer;
  stPacket : string;
begin
  case aType of
    sotClear: stPacket := AllClearChange(aParams);
    sotSymbol: stPacket := SymobolChange(aParams);
    sotQty: stPacket := QtyChange(aParams);
    sotSlice: stPacket := SliceChange(aParams);
    sotStrict: stPacket := StrictChange(aParams);
    sotHogacnl: stPacket := HogacnlChange(aParams);
    sotAdjust: stPacket := AdjustChange(aParams);
    sotPre: stPacket := PreChange(aParams);
    sotDelay: stPacket := DelayChange(aParams);
    sotOnoff: stPacket := OnOffChange(aParams);
    sotClose: stPacket := CloseChange(aParams);
    sotLast: stPacket := LastChange(aParams);
  end;


  iSize := Length(stPacket);

  gEnv.EnvLog(WIN_PACKET, stPacket);
  if iSize = 0 then exit;

  if Assigned(FOnSend) then
     bRet := FOnSend( iSize, stPacket );
end;

function TSSoptBroker.SliceChange(aParams: TSsoptParams): string;
var
  Buffer : array of char;
  pData : TSsoptSlice;
begin
  MovePacket( Format('%.4d',[LenSsoptSlice - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( SSOPT_SLICE , pData.HeadData.TrCode );
  MovePacket(Format('%d',[aParams.Index]), pData.CodeIndex);

  MovePacket( Format('%.2d',[aParams.Slice]), pData.Slice);
  SetLength(Buffer, LenSsoptSlice );
  Move(pData, Buffer[0], LenSsoptSlice);
  SetString( Result, PChar(@Buffer[0]), LenSsoptSlice );
end;

function TSSoptBroker.StrictChange(aParams: TSsoptParams): string;
var
  Buffer : array of char;
  pData : TSsoptRestrict;
begin
  MovePacket( Format('%.4d',[LenSsoptRestrict - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( SSOPT_RESTRICT, pData.HeadData.TrCode );

  MovePacket(Format('%d',[aParams.Index]), pData.CodeIndex);

  pData.LS := aParams.limitLS;
  MovePacket(Format('%d',[aParams.LimitIndex]), pData.Index);


  if pData.LS = 'L' then
    pData.IsCheck := GetCheck(aParams.Bidlimit[aParams.LimitIndex])
  else
    pData.IsCheck := GetCheck(aParams.Asklimit[aParams.LimitIndex]);

  SetLength(Buffer, LenSsoptRestrict );
  Move(pData, Buffer[0], LenSsoptRestrict);
  SetString( Result, PChar(@Buffer[0]), LenSsoptRestrict );

end;



function TSSoptBroker.SymobolChange(aParams: TSsoptParams): string;
var
  Buffer : array of char;
  pData : TSsoptSymbol;
begin
  MovePacket( Format('%.4d',[LenSsoptSymbol - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( SSOPT_SYMBOL , pData.HeadData.TrCode );
  MovePacket(Format('%d',[aParams.Index]), pData.CodeIndex);
  MovePacket(Format('%9s',[aParams.SymbolCode]),  pData.SymbolCode);
  SetLength(Buffer, LenSsoptSymbol );
  Move(pData, Buffer[0], LenSsoptSymbol);
  SetString( Result, PChar(@Buffer[0]), LenSsoptSymbol );
end;


procedure TSSoptBroker.SymbolState(stPacket: string);
var
  i : integer;
  vData : PSsopSymbolState;
begin
  vData := PSsopSymbolState( stPacket );
  for i := 0 to 3 do
  begin
    FSymbolState.Winrate1[i] := trim(string(vData.SymbolState[i].Winrate1));
    FSymbolState.Winrate2[i] := trim(string(vData.SymbolState[i].Winrate2));
    FSymbolState.SymbolState1[i] := trim(string(vData.SymbolState[i].SymbolState1));
    FSymbolState.SymbolState2[i] := trim(string(vData.SymbolState[i].SymbolState2));
  end;
  FDistributor.Distribute(Self, TRD_DATA, FSymbolState , SYMBOL_STATE);
end;

procedure TSSoptBroker.TotalState(stPacket: string);
var
  vData : PSsoptTotalState;
begin
  vData := PSsoptTotalState( stPacket );

  FTotalState.SsoptCon := trim(string(vData.SsoptCon));
  FTotalState.OrdSess := trim(string(vData.OrdSess));
  FTotalState.AcpSess := trim(string(vData.AcpSess));
  FTotalState.filSess := trim(string(vData.filSess));
  FTotalState.SymbolRev := trim(string(vData.SymbolRev));
  FTotalState.QuoteTime := trim(string(vData.QuoteTime));
  FTotalState.QuoteDelay := trim(string(vData.QuoteDelay));
  FDistributor.Distribute(Self, TRD_DATA, FTotalState, TOTAEL_STATE);
end;

procedure TSSoptBroker.LastState(stPacket: string);
var
  i : integer;
  vData : PSsoptLastState;
  bCheck : boolean;
begin
  vData := PSsoptLastState( stPacket );
  for i := 0 to 3 do
  begin
    if vData.LastState[i].IsAllClear = '0' then
      bCheck := false
    else
      bCheck := true;
    FLastState.IsAllClear[i]    := bCheck;
    FLastState.SymbolCode[i]    := trim(string(vData.LastState[i].SymbolCode));
    FLastState.OrderQty[i]      := trim(string(vData.LastState[i].OrderQty));
    FLastState.Slice[i]         := trim(string(vData.LastState[i].Slice));
    FLastState.IsAskHoga[i]     := trim(string(vData.LastState[i].AskHogaIndex));
    FLastState.IsBidHoga[i]     := trim(string(vData.LastState[i].BidHogaIndex));
    FLastState.AskPre[i]        := trim(string(vData.LastState[i].AskPre));
    FLastState.BidPre[i]        := trim(string(vData.LastState[i].BidPre));
    FLastState.DelayAfford[i]   := trim(string(vData.LastState[i].DelayAfford));
    FLastState.OnOff[i]         := StrToIntDef(string(vData.LastState[i].OnOff), 0);
  end;
  FDistributor.Distribute(Self, TRD_DATA, FLastState, LAST_STATE);
end;


procedure TSSoptBroker.Subscribe(Sender: TObject; aHandler: TDistributorEvent);
begin
  if Sender = nil then Exit;

  FDistributor.Subscribe(Sender, TRD_DATA, ANY_OBJECT, ANY_EVENT, aHandler);
end;

procedure TSSoptBroker.Unsubscribe(Sender: TObject);
begin
  FDistributor.Cancel(Sender);
end;

end.
