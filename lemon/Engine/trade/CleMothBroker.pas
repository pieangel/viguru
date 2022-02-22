unit CleMothBroker;

interface
uses
  Classes, SysUtils,

    // lemon: common
  GleLib,Gletypes, GleConsts,
    // lemon: data
  CleFQN, CleSymbols, CleTradeCore, CleOrders,  CleQuoteChangeData,
    //
  SynThUtil, CleAccounts, Dialogs ;

type


  TMothBroker = class
  private
    FOnSendMoth : TSendMothEvent;
    function GetCheck( bFlag : boolean ) : char;
    function BullPacket( aData : TObject; iSeq: integer; cM : char ; stAccount : string; iTag : integer ) : string;
    function OManPacket( aData : TObject; iSeq: integer; cM : char ; stAccount : string; iTag : integer ) : string;
    function VolStopPacket( aData : TObject; iSeq: integer; cM : char ; stAccount : string; iTag : integer ) : string;
    function QuotingPacket( aData : TObject; iSeq: integer; cM : char ; stAccount : string; iTag : integer ) : string;
    function SCatchPacket( aData : TObject; iSeq: integer; cM : char ; stAccount : string; iTag : integer ) : string;
  public
    constructor Create;
    destructor Destroy; override;
    function Send( aData : TObject; aType : TMothType; iTag : integer;
                   aSymbol : TSymbol; aAccount : TAccount) : boolean;
    property OnSendMoth : TSendMothEvent read FOnSendMoth write FOnSendMoth;
  end;

implementation


uses
  BullForm, BullData, CleFORMConst, FSavePosition, CleFrontOrderIF,
  CJackPotOrder, FleFrontQuoting, CleFrontQuotingTrade,
  CleMothPacket, FCatchForm, FrameFrontQuoting, FrameBull, FrameSCatchOrder, FrameOrderManage;

{ TMothBroker }

constructor TMothBroker.Create;
begin

end;

destructor TMothBroker.Destroy;
begin

  inherited;
end;

function TMothBroker.Send(aData : TObject ; aType : TMothType; iTag : integer;
                      aSymbol : TSymbol; aAccount : TAccount ): boolean;
var
  stAccount, stPacket : string;
  cMarket : char;
var
  iSize : integer;
begin
  Result := false;
  if (aData = nil) or (aSymbol = nil) or (aAccount = nil) then exit;

  cMarket := aSymbol.Spec.GetMarketType;
  stAccount := Copy(aAccount.Code,10,3);

  case aType of
    mtBull: stPacket := BullPacket(aData, aSymbol.Seq, cMarket, stAccount, iTag);
    mtOMan : stPacket := OManPacket(aData, aSymbol.Seq, cMarket, stAccount, iTag);
    mtVolStop :
        stPacket := VolStopPacket( aData, aSymbol.Seq, cMarket, stAccount, iTag );
    mtFront : stPacket := QuotingPacket( aData, aSymbol.Seq, cMarket, stAccount, iTag );
    mtSCatch: stPacket := SCatchPacket( aData, aSymbol.Seq, cMarket, stAccount, iTag );
  end;
  iSize := Length(stPacket);
  if iSize = 0 then exit;

  if Assigned(FOnSendMoth) then
    Result := FOnSendMoth( iSize, stPacket );
end;

function TMothBroker.VolStopPacket(aData: TObject; iSeq: integer; cM: char;
  stAccount: string; iTag: integer): string;
  var
  pData : TVolumeStopOrder;
  Buffer : array of char;
  pStops : TJackPots;
  aItem: TJackPotItem;
  stTmp : string;
  iStart: integer;
begin
  Result := '';
  // header
  pStops := ( aData as TJackPots );
  MovePacket( Format('%.4d',[LenVSTPData - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( MothTypeName[mtVolStop], pData.HeadData.TrCode );
  // data
  MovePacket( Format('%d', [iTag]), pData.DataDiv );
  MovePacket( stAccount, pData.Account );
  pData.MarketType := cM;
  MovePacket( Format('%.3d', [iSeq]), pData.SymbolSeq );

  if iTag >= integer(vsoAllDel) then
  begin
    MovePacket( Format('%d', [ integer( pStops.PositionType ) ] ), pData.ls );

    FillChar( pData.Price, sizeof( pData.Price ), '0');
    stTmp := Format('%.2f', [ pStops.PartPrice ] );
    iStart := sizeof( pData.Price ) - Length( stTmp );
    Move( stTmp[1], pData.Price[iStart], Length( stTmp ));

    FillChar( pData.Qty, 22, ' ' );
    //MovePacket( Format('%22.22', [' '] ), p );
  end
  else begin
    aItem := pStops.LastItem;
    if aItem.Side = 2 then
      pData.ls := '0'
    else
      pData.ls := '1';

    FillChar( pData.Price, sizeof( pData.Price ), '0');
    stTmp := Format('%.2f', [ aItem.Price ] );
    iStart := sizeof( pData.Price ) - Length( stTmp );
    Move( stTmp[1], pData.Price[iStart], Length( stTmp ));

    MovePacket( Format('%5.5d',[ aItem.OrdQty] ), pData.Qty );
    MovePacket( Format('%5.5d',[ aItem.Volume] ), pData.Vol );
    MovePacket( Format('%5.5d',[ aItem.AclFilVol]), pData.AccVol );

    if aItem.UseOrCond then
      pData.UseOr := '1'
    else
      pData.UseOr := '0';

    pData.Condiv := aItem.Condition;
    MovePacket( Format('%5.5d',[ pStops.AccumulCmpSec ]), pData.AccCmpSec );
  end;

  SetLength(Buffer, LenBullData );
  Move(pData, Buffer[0], LenVSTPData);
  SetString( Result, PChar(@Buffer[0]), LenVSTPData );

end;

function TMothBroker.BullPacket( aData : TObject; iSeq: integer; cM : char ; stAccount : string; iTag : integer ): string;
var
  aCon : TBullConfig;
  pData : TBullData;
  Buffer : array of char;
begin
  Result := '';
  if aData is TBullSystemForm then
    aCon := (aData as TBullSystemForm).Config
  else
    aCon := (aData as TFraBull).Config;
  MovePacket( Format('%.4d',[LenBullData - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( MothTypeName[mtBull], pData.HeadData.TrCode );
  MovePacket( Format('%d', [aCon.StartStop]), pData.StartStop );
  MovePacket( Format('%d', [iTag]), pData.ScreenNum );
  MovePacket( stAccount, pData.AccountCode );
  pData.MarketType := cM;
  MovePacket( Format('%.3d', [iSeq]), pData.SymbolSeq );

  pData.L := GetCheck(aCon.EntryLong_Checked);
  pData.S := GetCheck(aCon.EntryShort_Checked);
  pData.TimeCx := GetCheck(aCon.EntryTimeCancel_Checked);
  MovePacket( Format( '%5.5d', [ Round( aCon.EntryCancelTime*10 )]), pData.TimeCx_Value );

  pData.E1 := GetCheck(aCon.E1_Checked);
  MovePacket( Format( '%4.4d', [ Round( aCon.E1_P1*10 )]), pData.E1_Value1 );
  MovePacket( Format( '%4.4d', [ Round( aCon.E1_P2*10 )]), pData.E1_Value2 );
  MovePacket( Format( '%4.4d', [ Round( aCon.E1_P3*10 )]), pData.E1_Value3 );
  MovePacket( Format( '%4.4d', [ Round( aCon.E1_P4*10 )]), pData.E1_Value4 );
  MovePacket( Format( '%4.4d', [ Round( aCon.E1_P5*10 )]), pData.E1_Value5 );
  MovePacket( Format( '%4.4d', [ Round( aCon.E1_P6*10 )]), pData.E1_Value6 );

  pData.E2 := GetCheck(aCon.E2_Checked);
  MovePacket( Format( '%5.5d', [ aCon.E2_P1]), pData.E2_Value1 );
  MovePacket( Format( '%6.6d', [ aCon.NewOrderQty ]), pData.NewOrder );
  MovePacket( Format( '%6.6d', [ aCon.MaxPosition ]), pData.MaxPostion );
  MovePacket( Format( '%6.6d', [ aCon.MaxQuoteQty ]), pData.MaxQuoteQty );

  pData.X1 := GetCheck(aCon.X1_Checked);
  MovePacket( Format( '%4.4d', [ Round( aCon.X1_P1*10 )]), pData.X1_Value1 );
  MovePacket( Format( '%4.4d', [ Round( aCon.X1_P2*10 )]), pData.X1_Value2 );

  pData.X2 := GetCheck(aCon.X2_Checked);
  MovePacket( Format( '%4.4d', [ Round( aCon.X2_P1*10 )]), pData.X2_Value1 );
  MovePacket( Format( '%4.4d', [ Round( aCon.X2_P2*10 )]), pData.X2_Value2 );

  pData.X3 := GetCheck(aCon.X3_Checked);

  MovePacket( Format( '%d', [ aCon.CButton]), pData.Buttons );

  SetLength(Buffer, LenBullData );
  Move(pData, Buffer[0], LenBullData);
  SetString( Result, PChar(@Buffer[0]), LenBullData );
end;

function TMothBroker.OManPacket(aData: TObject; iSeq: integer; cM : char ; stAccount: string;
  iTag: integer): string;
var
  aCon : TFORMParam;
  pData : TOManData;
  Buffer : array of char;
  aIF : TFrontOrderIF;
  cDiv : char;
begin
  Result := '';
  if aData = nil then exit;

  if aData is TFrmOrderMngr then
    aCon := (aData as TFrmOrderMngr).Param
  else
    aCon := (aData as TFraORderManage).Param;

  MovePacket( Format('%.4d',[LenOManData - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( MothTypeName[mtOMan], pData.HeadData.TrCode );

  case aCon.DataType of
    dtOrdCancel: cDiv := '0';
    dtOrdPosCancel: cDiv := '1';
    dtTotalCancel: cDiv := '2';
  end;

  pData.DataDiv := cDiv;
  MovePacket( Format('%d', [aCon.StartStop]), pData.StartStop );
  MovePacket( Format('%d', [iTag]), pData.ScreenNum );
  MovePacket( stAccount, pData.AccountCode );
  pData.MarketType := cM;
  MovePacket( Format('%.3d', [iSeq]), pData.SymbolSeq );

  MovePacket( Format('%d', [aCon.Asks]), pData.Ask );
  MovePacket( Format('%d', [aCon.Bids]), pData.Bid );
  MovePacket( Format('%.6d', [aCon.AskPos]), pData.AskPosQty );
  MovePacket( Format('%.6d', [aCon.BidPos]), pData.BidPosQty );

  MovePacket( Format('%.5d', [aCon.Cnt]), pData.Cnt );
  MovePacket( Format('%.5d', [aCon.Interval]), pData.Interval);
  MovePacket( Format('%d', [aCon.VolStop]), pData.VolStop );

  SetLength(Buffer, LenOManData );
  Move(pData, Buffer[0], LenOManData);
  SetString( Result, PChar(@Buffer[0]), LenOManData );
end;


function TMothBroker.SCatchPacket(aData: TObject; iSeq: integer; cM: char;
  stAccount: string; iTag: integer): string;
  var
    aCon    : TCatchConfig;
    pData   : TSimpleCatch;
    Buffer : array of char;
begin
  if aData = nil then exit;

  if aData is TCatchForm then
    aCon  := (aData as TCatchForm).Config
  else
    aCon := (aData as TFraSCatchOrder).Config;

  MovePacket( Format('%.4d',[LenSCatch - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( MothTypeName[mtSCatch], pData.HeadData.TrCode );

  pData.StartStop := aCon.StartStop;
  MovePacket( Format('%d', [iTag]), pData.ScreenNum );
  MovePacket( stAccount, pData.AccountCode );
  pData.MarketType := cM;
  MovePacket( Format('%.3d', [iSeq]), pData.SymbolSeq );

  MovePacket( Format('%.6d', [ aCon.Nms ]), pData.Nms );
  MovePacket( Format('%.6d', [ aCon.FillSum ]), pData.FillSum );
  MovePacket( Format('%.6d', [ aCon.FillCnt]), pData.FillCount );
  MovePacket( Format('%.6d', [ aCon.OrderQty ]), pData.OrderQty );
  MovePacket( Format('%.6d', [ aCon.MaxQuoteQty ]), pData.MaxQuoteQty );
  if aData is TCatchForm then
    pData.UseRmvVol := GetCheck( (aData as TCatchForm).cbUseVol.Checked )
  else
    pData.UseRmvVol := GetCheck( (aData as TFraSCatchOrder).cbUseVol.Checked );
  SetLength(Buffer, LenSCatch );
  Move(pData, Buffer[0], LenSCatch);
  SetString( Result, PChar(@Buffer[0]), LenSCatch );

end;

function TMothBroker.QuotingPacket(aData: TObject; iSeq: integer; cM: char;
  stAccount: string; iTag: integer): string;
var
  aCon : TQuoteOderSets;
  pData : TFrontData;
  Buffer : array of char;
  cDiv : char;
  iOrdCnt : integer;
begin
  Result := '';
  if aData = nil then exit;
  if aData is TFrontQuotingForm then
    aCon := (aData as TFrontQuotingForm).FQuoteSet
  else
    aCon := (aData as TFraFrontQuoting).FQuoteSet;

  MovePacket( Format('%.4d',[LenFrontData - Length(pData.HeadData.Size)]), pData.HeadData.Size );
  MovePacket( MothTypeName[mtFront], pData.HeadData.TrCode );

  case aCon.DataType of
    dtBid :
    begin
      cDiv := '0';
      iOrdCnt := aCon.iOrdBidCnt;
    end;
    dtAsk :
    begin
      cDiv := '1';
      iOrdCnt := aCon.iOrdAskCnt;
    end;
  end;

  pData.DataDiv := cDiv;
  pData.StartStop := GetCheck(aCon.bRun);
  MovePacket( Format('%d', [iTag]), pData.ScreenNum );
  MovePacket( stAccount, pData.AccountCode );
  pData.MarketType := cM;
  MovePacket( Format('%.3d', [iSeq]), pData.SymbolSeq );
  MovePacket( Format('%d', [aCon.iGrade]), pData.Hoga );
  MovePacket( Format('%.6d', [aCon.iHoga]), pData.HogaVol );
  MovePacket( Format('%.6d', [iOrdCnt]), pData.OrdCnt );

  MovePacket( Format('%.6d', [aCon.iOrdQty]), pData.OrdQty );
  pData.UseFront := GetCheck(aCon.bFront);
  pData.UseOrdFull := GetCheck(aCon.bOrdFull);
  pData.UseTime := GetCheck(aCon.bTimeUse);
  MovePacket( aCon.stStartTime, pData.Time);

  SetLength(Buffer, LenFrontData );
  Move(pData, Buffer[0], LenFrontData);
  SetString( Result, PChar(@Buffer[0]), LenFrontData );
end;

function TMothBroker.GetCheck(bFlag: boolean): char;
begin
  if bFlag then
    Result := '1'
  else
    Result := '0';
end;


end.
