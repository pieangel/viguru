unit CleQuotingArb;

interface
uses Classes, SysUtils, Windows,
     GleTypes, CleMothPacket, CleSymbols, CleAccounts;

type
  TQuotingArbFill = class(TCollectionItem)
  private
    FFillTime : TDateTime;
    FOrderNo : integer;
    FFillNo : integer;
    FFillPrice : double;
    FFillQty : integer;
    FLS : string;
  public
    property FillTime : TDateTime read FFillTime;
    property OrderNo : integer read FOrderNo;
    property FillNo : integer read FFillNo;
    property FillPrice : double read FFillPrice;
    property FillQty : integer read FFillQty;
    property LS : string read FLS;
  end;

  TQuotingArbData = class
  private
    FSymbol : TSymbol;
    FLS : string;
    FFillQty : integer;
    FAvgPrice : double;
    FTotAmt : double;
    FDetail : boolean;
    FPairData : TQuotingArbData;
    FLastFillTime : TDateTime;
    FFillDatas : TCollection;

  public
    constructor Create;
    destructor Destroy; override;
    procedure AddFill(dtTime : TDateTime; iOrderno, iFillNo, iFillQty : integer; dPrice : double; stLS : string);
    function GetFill(iIndex : integer) : TQuotingArbFill;
    property Symbol : TSymbol read FSymbol;
    property LS : string read FLS;
    property FillQty : integer read FFillQty;
    property AvgPrice : double read FAvgPrice;
    property TotAmt : double read FTotAmt;
    property Detail : boolean read FDetail write FDetail;
    property PairData : TQuotingArbData read FPairData;
    property LastFillTime : TDateTime read FLastFillTime;
    property FillDatas : TCollection read FFillDatas;

  end;

  TQuotingArbGroup = class(TCollectionItem)
  private
    FBasketID : integer;
    FArbType : TArbType;
    FPixedPL : double;
    FQty : integer;
    FSuccess : boolean;
    FLS : string;
    FDataCnt : integer;
    FAccount : TAccount;
    FBasketEnd : boolean;
    FStartFillTime : TDateTime;
    procedure FindPair();
    procedure CalPixedPL();
    function GetIndex(aSymbol : TSymbol) : integer;
    function AddData( stCode, stLS, stPacket : string ) : TQuotingArbData;
  public
    FQuotingArbDatas : array of TQuotingArbData;                  // FCP : 0=C, 1=P, 2=F , BOX : 0=C, 1=C, 2=P, 3=P
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;
    function Find( stCode, stLS : string ): TQuotingArbData;
    function GetResult() : string;
    property BasketID : integer read FBasketID;
    property ArbType : TArbType read FArbType;
    property PixedPL : double read FPixedPL;
    property Qty : integer read FQty;
    property Success : boolean read FSuccess;
    property LS : string read FLS;
    property DataCnt : integer read FDataCnt;
    property Account : TAccount read FAccount;
    property BasketEnd : boolean read FBasketEnd;
    property StartFillTime : TDateTime read FStartFillTime;
  end;

  TQuotingArbGroups = class(TCollection)
  private
    FTotPL : double;
    FSuccessCnt : integer;
    FOnArbEnd : TArbEndEvent;
    FArbLastSeq : integer;
    procedure FileLog( stPacket : string);
    procedure TotCalPL( aGroup : TQuotingArbGroup);

    function AddGroup( iBasket : integer; atType : TArbType; stAcnt : string ) : TQuotingArbGroup;
    
  public
    constructor Create;
    destructor Destroy; override;
    procedure ReceiveData( stPacket : string; bLog : boolean = true);
    procedure ArbFileLoad;
    function Find( iGroup : integer ): TQuotingArbGroup;

    property TotPL : double read FTotPL;
    property SuccessCnt : integer read FSuccessCnt;
    property OnArbEnd : TArbEndEvent read FOnArbEnd write FOnArbEnd;
    property ArbLastSeq : integer read FArbLastSeq write  FArbLastSeq;
  end;
implementation
uses
  GAppEnv, CleFQN, StreamIO;
{ TQuotingArbData }

procedure TQuotingArbData.AddFill(dtTime: TDateTime; iOrderno, iFillNo,
  iFillQty: integer; dPrice: double; stLS : string);
var
  aFill, aFillLast : TQuotingArbFill;
  i : integer;
begin
  aFill := nil;
  if FFillDatas.Count = 0 then
    aFill := FFillDatas.Add as TQuotingArbFill
  else
  begin
    for i := FFillDatas.Count - 1 downto 0 do
    begin
      aFill := FFillDatas.Items[i] as TQuotingArbFill;
      if aFill.FillTime <= dtTime then
      begin
        aFill := FFillDatas.Insert(i+1) as TQuotingArbFill;
        break;
      end;
      if i = 0 then
         aFill := FFillDatas.Insert(0) as TQuotingArbFill;
    end;
  end;
  if aFill = nil then exit;
  
  aFill.FFillTime := dtTime;
  aFill.FOrderNo := iOrderNo;
  aFill.FFillNo := iFillNo;
  aFill.FFillQty := iFillQty;
  aFill.FFillPrice := dPrice;
  aFill.FLS := stLS;

  aFillLast := FFillDatas.Items[FFillDatas.Count-1] as TQuotingArbFill;
  FLastFillTime := aFillLast.FFillTime;
end;

constructor TQuotingArbData.Create;
begin
  FFillDatas := TCollection.Create(TQuotingArbFill);
  FSymbol := nil;
  FLS := 'L'; 
  FFillQty := 0; 
  FAvgPrice := 0;
  FTotAmt := 0;
  FDetail := false;
  FPairData := nil;
  FLastFillTime := 0;
end;

destructor TQuotingArbData.Destroy;
begin
  FFillDatas.Free;
  inherited;
end;

function TQuotingArbData.GetFill(iIndex: integer): TQuotingArbFill;
begin
  if (iIndex >= 0) and (iIndex <= FFillDatas.Count-1) then
    Result := FFillDatas.Items[iIndex] as TQuotingArbFill
  else
    Result := nil;
end;

{ TQuotingArbGroup }
procedure TQuotingArbGroup.CalPixedPL;
var
  i, iTot, iQty, iAvg : integer;
  aData : TQuotingArbData;
  dTotS, dTotL, dTot, dStrike : double;

  aFut, aCall, aCall1, aPut, aPut1 : TQuotingArbData;
  aFill1, aFill2 : TQuotingArbFill;
begin
  dTotS := 0;
  dTotL := 0;
  dTot := 0;
  FPixedPL := 0;

  case FArbType of
    atFCLR:
    begin

      if(FQuotingArbDatas[0] = nil) or (FQuotingArbDatas[1] = nil) then
      begin
        gEnv.EnvLog(WIN_ERR, 'CalPixedPL FCLR Error' );
        exit;
      end;

      FPixedPL := (FQuotingArbDatas[1].FTotAmt - FQuotingArbDatas[0].FTotAmt) * 500000;
      FQty := FQuotingArbDatas[0].FFillQty;

      aFill1 := FQuotingArbDatas[0].GetFill(0);
      aFill2 := FQuotingArbDatas[1].GetFill(0);

      if (aFill1 = nil) or (aFill2 = nil) then exit;
      
      if aFill1.FFillTime <= aFill2.FillTime then
        FLS := aFill1.FLS
      else
        FLS := aFill2.FLS;
    end;
    atFCP:
    begin
      aCall := FQuotingArbDatas[0];
      aPut := aCall.PairData;
      aFut := FQuotingArbDatas[2];

      if(aCall = nil) or (aPut = nil) or (aFut = nil) then
      begin
        gEnv.EnvLog(WIN_ERR, 'CalPixedPL FCP Error' );
        exit;
      end;


      FQty := aFut.FFillQty;
      if aFut.LS = 'L' then
        dTot := ((aCall.Symbol as TOption).StrikePrice * aCall.FFillQty + aCall.FTotAmt - aPut.FTotAmt) - aFut.FTotAmt
      else
        dTot := aFut.FTotAmt - ((aCall.Symbol as TOption).StrikePrice * aCall.FFillQty + aCall.FTotAmt - aPut.FTotAmt);
      FPixedPL := dTot * 500000;
      FLS := aFut.LS;
    end;
    atBox:
    begin
      aCall := FQuotingArbDatas[0];
      aPut := aCall.PairData;
      aCall1 := FQuotingArbDatas[1];
      aPut1 := aCall1.PairData;
      FQty := aCall.FFillQty;

      if(aCall = nil) or (aPut = nil) or (aCall1 = nil) or (aPut1 = nil) then
      begin
        gEnv.EnvLog(WIN_ERR, 'CalPixedPL BOX Error' );
        exit;
      end;


      //LS 선택
      if (aCall.Symbol as TOption).StrikePrice > (aCall1.Symbol as TOption).StrikePrice then
        FLS := aCall1.FLS
      else
        FLS := aCall.FLS;

      if aCall.FLS = 'L' then
      begin
        dStrike := (aCall.Symbol as TOption).StrikePrice;
        dTotL := dStrike * aCall.FFillQty + aCall.FTotAmt - aPut.FTotAmt;

        dStrike := (aCall1.Symbol as TOption).StrikePrice;
        dTotS := dStrike * aCall1.FFillQty + aCall1.FTotAmt - aPut1.FTotAmt;

      end else
      begin
        dStrike := (aCall.Symbol as TOption).StrikePrice;
        dTotS := dStrike * aCall.FFillQty + aCall.FTotAmt - aPut.FTotAmt;

        dStrike := (aCall1.Symbol as TOption).StrikePrice;
        dTotL := dStrike * aCall1.FFillQty + aCall1.FTotAmt - aPut1.FTotAmt;
      end;
      FPixedPL := (dTotS - dTotL) * 500000;
    end;
  end;


  if FPixedPL - 0.01 > 0 then
    FSuccess := true;
end;

constructor TQuotingArbGroup.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  FBasketID := 0;
  FArbType := atBox;
  FPixedPL := 0.0;
  FQty := 0;
  FSuccess := false;
  FAccount := nil;
  FBasketEnd := false;
  FStartFillTime := 100000;
end;

destructor TQuotingArbGroup.Destroy;
var
  i : integer;
begin
  for i := 0 to FDataCnt - 1 do
    FQuotingArbDatas[i].Free;
  inherited;
end;

function TQuotingArbGroup.Find(stCode, stLS: string): TQuotingArbData;
var
  i : integer;
  aItem : TQuotingArbData;
begin
  Result := nil;

  for i := 0 to FDataCnt - 1 do
  begin
    aItem := FQuotingArbDatas[i];
    if aItem = nil then continue;
    if aItem.Symbol = nil then continue;

    if FArbType = atFCLR then
    begin
      if (aItem.Symbol.Code = stCode) and (aItem.LS = stLS) then
      begin
        Result := aItem;
        break;
      end;
    end else
    begin
      if aItem.Symbol.Code = stCode then
      begin
        Result := aItem;
        break;
      end;
    end;
  end;
end;


procedure TQuotingArbGroup.FindPair;
var
  i, j : integer;
  aCall, aPut : TQuotingArbData;
begin
  
  if FArbType = atFCLR then exit;

  if FArbType = atFCP then
  begin
    aCall := FQuotingArbDatas[0];

    if aCall = nil then
    begin
      gEnv.EnvLog(WIN_ERR, 'FindPair FCP ERROR');
      exit;
    end;

    aCall.FPairData := FQuotingArbDatas[1];
  end else if FArbType = atBox then
  begin
    for i := 0 to 1 do                                              //Box 일때 Call(0,1) Put(2,3)
    begin
      aCall := FQuotingArbDatas[i];

      if aCall = nil then
      begin
        gEnv.EnvLog(WIN_ERR, 'FindPair BOX Call ERROR');
        exit;
      end;

      for j := 2 to 3 do
      begin
        if aPut = nil then
        begin
          gEnv.EnvLog(WIN_ERR, 'FindPair FCP Put ERROR');
          exit;
        end;

        aPut := FQuotingArbDatas[j];
        if ((aCall.FSymbol as TOption).StrikePrice = (aPut.FSymbol as TOption).StrikePrice)  then
        begin
          aCall.FPairData := aPut;
          break;
        end;
      end;
    end;
  end;

end;

function TQuotingArbGroup.GetIndex(aSymbol: TSymbol): integer;
var
  iIndex : integer;
begin
  // FCP : 0=C, 1=P, 2=F , BOX : 0=C, 1=C, 2=P, 3=P
  case FArbType of
    atFCLR :
    begin
      if FLS = 'L' then
        iIndex := 0
      else
        iIndex := 1;
    end;
    atFCP :
    begin
      if aSymbol.Spec.Market = mtFutures then
        iIndex := 2
      else
      begin
        if(aSymbol as TOption).CallPut = 'C' then
          iIndex := 0
        else
          iIndex := 1;
      end;  
    end;
    atBox : 
    begin
      if(aSymbol as TOption).CallPut = 'C' then
        iIndex := 0;
      if(aSymbol as TOption).CallPut = 'P' then
        iIndex := 2;
      if FQuotingArbDatas[iIndex] <> nil then
        iIndex := iIndex + 1;
    end;
  end;
  Result := iIndex;
end;

function TQuotingArbGroup.GetResult: string;
begin
  if FSuccess then
    Result := '성공'
  else
    Result := '실패';
end;

function TQuotingArbGroup.AddData(stCode, stLS, stPacket: string): TQuotingArbData;
var
  aData : TQuotingArbData;
  iSide, iFillQty, iOrderNo, iFillNo, iIndex : integer;
  dPrice, dTotAmt : double;
  stTime, stLog : string;
  dtTime : TDateTime;

  vData : PArbData;
  aSymbol : TSymbol;
begin
  aData := Find(stCode, stLS);
  vData := PArbData( stPacket );
  stTime := string(vData.FillTime);
  stLog := string(vData.LogTime);
  iOrderNo := StrToInt(string(vData.OrderNo));
  iFillNo := StrToInt(string(vData.FillNo));

  iFillQty := StrToInt(string(vData.FillQty));
  dPrice := StrToFloat(string(vData.FillPrice));


  dTotAmt := dPrice * abs(iFillQty);

  if aData = nil then
  begin
    FLS := stLS;
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stCode);
    if aSymbol = nil then exit;
    iIndex := GetIndex(aSymbol);
    FQuotingArbDatas[iIndex] := TQuotingArbData.Create;
    FQuotingArbDatas[iIndex].FSymbol := aSymbol;
    FQuotingArbDatas[iIndex].FLS := stLS;
    FQuotingArbDatas[iIndex].FFillQty := iFillQty;
    FQuotingArbDatas[iIndex].FAvgPrice := dPrice;
    FQuotingArbDatas[iIndex].FTotAmt := dTotAmt;
    FQuotingArbDatas[iIndex].FDetail := false;

    aData := FQuotingArbDatas[iIndex];
  end else
  begin
    // 체결수량 업데이트
    aData.FFillQty := aData.FFillQty + iFillQty;
    aData.FTotAmt := aData.FTotAmt + dTotAmt;
    aData.FAvgPrice := aData.FTotAmt / aData.FFillQty;
  end;


  dtTime := EncodeTime(StrToIntDef(Copy(stTime,1,2),0),
                                StrToIntDef(Copy(stTime,3,2),0),
                                StrToIntDef(Copy(stTime,5,2),0),
                                StrToIntDef(Copy(stTime,7,3),0));

  aData.AddFill(dtTime, iOrderNo, iFillNo, iFillQty, dPrice, stLS);

  if FStartFillTime > dtTime then
    FStartFillTime := dtTime;

  if string(vData.BasketEnd) = '1' then
    FBasketEnd := true;
  Result := aData;
end;

{ TQuotingArbGroups }

procedure TQuotingArbGroups.ArbFileLoad;
var
  stData, stFile: String;
  F: TextFile;
  S: TFileStream;
begin
  stFile := Format('%s\Arb\%s.log',[gEnv.LogDir, FormatDateTime('yyyymmdd',gEnv.AppDate)]);
  if not FileExists(stFile) then exit;


  S := TFileStream.Create(stFile, fmOpenRead);
  AssignStream(F, S);
  Reset(F);
  while not EOF(F) do
  begin
    // readln
    Readln(F, stData);
    if stData = '' then continue;
    stData := Copy(stData, 15, Length(stData));
    ReceiveData(stData, false);
  end;
  CloseFile(F);
  S.Free;
end;

procedure TQuotingArbGroups.TotCalPL(aGroup: TQuotingArbGroup);
begin
  FTotPL := FTotPL + aGroup.FPixedPL;   //전체손익

  if aGroup.Success then                //성공
    inc(FSuccessCnt);
end;

constructor TQuotingArbGroups.Create;
begin
  inherited Create(TQuotingArbGroup);
  FTotPL := 0;
  FSuccessCnt := 0;
  FOnArbEnd := nil;
end;

destructor TQuotingArbGroups.Destroy;
begin

  inherited;
end;



procedure TQuotingArbGroups.FileLog(stPacket: string);
begin
  gEnv.EnvLog(WIN_ARB, stPacket); //파일 로그
end;

function TQuotingArbGroups.Find(iGroup: integer): TQuotingArbGroup;
var
  i : integer;
  aItem : TQuotingArbGroup;
begin
  Result := nil;
  for i := Count - 1 downto 0 do
  begin
    aItem := Items[i] as TQuotingArbGroup;
    if aItem.FBasketID = iGroup then
    begin
      Result := aItem;
      break;
    end;
  end;
end;

function TQuotingArbGroups.AddGroup(iBasket: integer; atType : TArbType; stAcnt : string): TQuotingArbGroup;
var
  i : integer;
  aItem : TQuotingArbGroup;
begin
  aItem := Find(iBasket);
  if aItem = nil then
  begin
    aItem := Add as TQuotingArbGroup;
    aItem.FBasketID := iBasket;
    aItem.FArbType := atType;
    aItem.FDataCnt := 0;
    case atType of
      atFCLR: aItem.FDataCnt := 2;
      atFCP: aItem.FDataCnt := 3;
      atBox: aItem.FDataCnt := 4;
    end;
    SetLength(aItem.FQuotingArbDatas, aItem.FDataCnt);
    aItem.FAccount := gEnv.Engine.TradeCore.Accounts.Find(stAcnt);

    for i := 0 to aItem.FDataCnt - 1 do
      aItem.FQuotingArbDatas[i] := nil;
  end;
  Result := aItem;
end;

procedure TQuotingArbGroups.ReceiveData(stPacket: string; bLog : boolean);
var
  iBasket, iLast : integer;
  stCode, stAcnt, stLS : string;
  vData : PArbData;
  atType :  TArbType;
  aGroup : TQuotingArbGroup;
begin
  if stPacket = '' then exit;
  vData := PArbData( stPacket );
  FArbLastSeq := StrToInt(string(vData.Seq));
  iLast := StrToint(string(vData.BasketEnd));
  iBasket := StrToInt(string(vData.BasketID));
  stCode := string(vData.SymbolCode);
  stAcnt := string(vData.AccountNo);
  stLS := string(vData.LS);

  if(vData.ArbType = '0') then
    atType := atFCLR
  else if(vData.ArbType = '1') then
      atType := atFCP
  else if(vData.ArbType = '2') then
      atType := atBOX;

  aGroup := AddGroup(iBasket, atType, stAcnt);          //그룹추가
  aGroup.AddData(stCode, stLS, stPacket);               //종목추가 및 FillData 추가

  if aGroup.BasketEnd then
  begin
     aGroup.FindPair;
     aGroup.CalPixedPL;
     TotCalPL(aGroup);
     if(Assigned(FOnArbEnd)) then
       FOnArbEnd(aGroup);
  end;

  if bLog then
    FileLog(stPacket);
end;

end.
