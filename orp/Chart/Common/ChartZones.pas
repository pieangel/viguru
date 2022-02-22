unit ChartZones;

interface

uses Windows, Classes, Graphics, Math, SysUtils,
     //
     Charters, CleStorage
     ;

type
  TChartZoneMode = (zmIndependent, zmIntegral);
  TRedistributionMode = (rmIsotropic, rmCentric);


  TChartZone = class(TCollectionItem)
  private
    FCharters : TList;
    FDrawRect : TRect; // zone area
    FYRate : Double;


    FMode : TChartZoneMode;
    FCustomID : Integer;

    //-- sms
    FDesc : String;
    FDescColor : TColor;
    FUse2Variable: boolean;

    procedure DrawTitles(aCanvas : TCanvas; aSelected : TCharter);
    procedure Draw(aCanvas : TCanvas; const iStart, iEnd, iBarWidth : Integer;
                   const bLeft, bRight, bHLine: Boolean; const aGridColor : TColor;
                   aSelected : TCharter);
    procedure SetRate(const Value: Double);
    function GetCharter(i:Integer) : TCharter;
    procedure DrawDesc(aCanvas : TCanvas; var iLeft : Integer);
  public
    constructor Create(aColl : TCollection); override;
    destructor Destroy; override;

    procedure Add(aCharter : TCharter);
    procedure Delete(aCharter : TCharter);
    function HasCharter(aCharter : TCharter) : Boolean;
    function Count : Integer;

    procedure CalcSize(var iTop: Integer; const iHeight,iLeft,iRight: Integer);
    function Hit(const iHitX, iHitY : Integer;
      const iStartIndex, iBarIndex, iBarWidth : Integer): TCharter;
    function SpotData(iBarIndex : Integer) : String;
    procedure HintData(iBarIndex : Integer; stHints : TStringList);

    property YRate : Double read FYRate write SetRate;
    property DrawRect : TRect read FDrawRect;

    property Mode : TChartZoneMode read FMode write FMode;
    //property YRateType : TYRateType read F
    property CustomID : Integer read FCustomID write FCustomID;
    property Charters[i:Integer] : TCharter read GetCharter;

    //-- sms
    property Desc : String read FDesc write FDesc;
    property DescColor : TColor read FDescColor write FDescColor;

    //--
    property Use2Variable : boolean read FUse2Variable write FUse2Variable;
  end;

  TChartZones = class(TCollection)
  private
    FDrawRect : TRect;
    FMode : TRedistributionMode;
    FinTheQuote: boolean;
    FYRateType: TYRateType;

    procedure Redistribute( bRecalc : boolean = false );
    procedure SetRects;
    function GetZone(i:Integer) : TChartZone;
    procedure Redistribute2;

  public
    constructor Create(aRect : TRect);

    procedure GetPersistence(aBitStream : TMemoryStream);
    procedure SetPersistence(aBitStream : TMemoryStream);
    procedure SetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
    procedure GetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);

    function InsertZone(iPrevZone : Integer) : TChartZone;
    function AddZone : TChartZone;
    procedure UpdateZone;
    procedure Resize(aRect : TRect);
    procedure ResizeZone(const iZone, iNewY : Integer); overload;
    procedure ResizeZone; overload;
    procedure RegulateZones;
    //
    function IndexOfZone(iX, iY : Integer) : Integer;
    function IndexOfBoundary(iX, iY : Integer) : Integer;
    //
    function AddCharter(aCharter : TCharter) : TChartZone;
    function InsertCharter(iPrevZone : Integer; aCharter : TCharter) : TChartZone;
    procedure DeleteCharter(aCharter : TCharter);
    procedure MoveCharter(aCharter : TCharter; iFrom, iTo : Integer;
                          bNewZone : Boolean);
    function IndexOfCharter(aCharter : TCharter) : Integer;
    // drawing routines
    procedure DrawTitles(aCanvas : TCanvas; aSelected : TCharter);
    procedure Draw(const aCanvas : TCanvas; const iStart, iEnd, iBarWidth : Integer;
                   const bLeft, bRight, bHLine : Boolean; const aGridColor : TColor;
                   aSelected : TCharter; bDrawSeparator : Boolean = False);
    procedure DrawSeparators(const aCanvas : TCanvas; iLeft, iRight : Integer);
    //
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
    //

    procedure SetZone( idx : integer; aCharter : TCharter );
    property Mode : TRedistributionMode read FMode write FMode;
    property Zones[i:Integer] : TChartZone read GetZone; default;
    property InTheQuote : boolean read FinTheQuote write FInTheQuote;
    property YRateType : TYRateType read FYRateType write FYRateType;
  end;

implementation

uses
  Symbolers, GAppEnv
  ;

//========================================================//
                         { TChartZone }
//========================================================//

constructor TChartZone.Create(aColl: TCollection);
begin
  inherited;

  FCharters := TList.Create;
  FMode := zmIndependent;
  //-- sms
  FDesc := '';
  FDescColor := clGray;

  FUse2Variable := false;
end;

destructor TChartZone.Destroy;
begin
  FCharters.Free;

  inherited;
end;

//------------------< Public methods >----------------------//

procedure TChartZone.Add(aCharter : TCharter);
begin
  FCharters.Add(aCharter);
end;

procedure TChartZone.Delete(aCharter : TCharter);
begin
  FCharters.Remove(aCharter);
  //
  if FCharters.Count= 0 then
    Free;
end;

function TChartZone.HasCharter(aCharter : TCharter) : Boolean;
var
  i : Integer;
begin
  Result := False;

  for i:=0 to FCharters.Count-1 do
    if aCharter = FCharters.Items[i] then
    begin
      Result := True;
      Break;
    end;
end;

function TChartZone.Count: Integer;
begin
  Result := FCharters.Count;
end;

procedure TChartZone.DrawTitles(aCanvas : TCanvas; aSelected : TCharter);
var
  i, iLeft : Integer;
  aCharter : TCharter;
begin
  iLeft := FDrawRect.Left;

  DrawDesc(aCanvas, iLeft);

  for i:=0 to FCharters.Count-1 do
  begin
    aCharter := TCharter(FCharters.Items[i]);
    // title
    aCharter.DrawTitle(aCanvas, FDrawRect, iLeft, (aCharter = aSelected));
  end;
end;

procedure TChartZone.DrawDesc(aCanvas: TCanvas; var iLeft: Integer);
var
//
  aSize : TSize;
  aFontColor : TColor;
  aFontStyle : TFontStyles;
begin
  if Length(FDesc) > 0 then
  begin
    aFontColor := aCanvas.Font.Color;
    aFontStyle := aCanvas.Font.Style;

    aCanvas.Font.Color := FDescColor;
    aCanvas.Font.Style := aCanvas.Font.Style + [fsBold];

    aSize := aCanvas.TextExtent(FDesc);
    aCanvas.TextOut(iLeft + 5, FDrawRect.Top - aSize.cy, FDesc);
    iLeft := iLeft + 5 + aSize.cx;

    aCanvas.Font.Color := aFontColor;
    aCanvas.Font.Style := aFontStyle;
  end;
end;


procedure TChartZone.Draw(aCanvas : TCanvas; const iStart, iEnd, iBarWidth : Integer;
               const bLeft, bRight, bHLine : Boolean; const aGridColor : TColor;
               aSelected : TCharter);
var
  i, iLeft : Integer;
  aCharter : TCharter;

  dMin, dMax : Double;
  iCount : Integer;
begin
  iLeft := FDrawRect.Left;
  //-- Total integral min/max
  if FMode = zmIntegral then
  begin
    iCount := 0;
    // get total min/max
    for i:=0 to FCharters.Count-1 do
    begin
      aCharter := TCharter(FCharters.Items[i]);
      if aCharter is TSeriesCharter then
        with aCharter as TSeriesCharter do
        begin
          GetMinMax(iStart, iEnd);
          if iCount > 0 then
          begin
            dMax := Max(dMax, MaxValue);
            dMin := Min(dMin, MinValue);
          end else
          begin
            dMax := MaxValue;
            dMin := MinValue;
          end;
          Inc(iCount);
        end;
    end;
    //
    if iCount > 0 then
    for i:=0 to FCharters.Count-1 do
    begin
      aCharter := TCharter(FCharters.Items[i]);
      if aCharter is TSeriesCharter then
        with aCharter as TSeriesCharter do
          SetMinMax(dMin, dMax);
    end;
  end;

  //-- draw Desc
  DrawDesc(aCanvas, iLeft);
  //-- draw
  for i:=0 to FCharters.Count-1 do
  begin
    aCharter := TCharter(FCharters.Items[i]);
    // title
    if not FUse2Variable then
      aCharter.DrawTitle(aCanvas, FDrawRect, iLeft, (aCharter = aSelected));
    // min/max
    if aCharter is TSeriesCharter then
    with aCharter as TSeriesCharter do
    begin
      if FMode = zmIndependent then
        if FUse2Variable then
          GetMinMax2( iStart, iEnd )
        else
          GetMinMax(iStart, iEnd);
      // y-scale
      if i = 0 then
        DrawYScale(aCanvas, FDrawRect, bLeft, bRight, bHLine, aGridColor);
    end;
    // data
    if FUse2Variable then
      aCharter.Draw2(aCanvas, FDrawRect, iStart, iEnd, iBarWidth,
                  (aCharter = aSelected))

    else
      aCharter.Draw(aCanvas, FDrawRect, iStart, iEnd, iBarWidth,
                  (aCharter = aSelected));
  end;
end;

function TChartZone.SpotData(iBarIndex : Integer) : String;
var
  i : Integer;
begin
  Result := '';
  //
  for i:=0 to FCharters.Count-1 do
    Result := Result + TCharter(FCharters.Items[i]).SpotData(iBarIndex) + '  ';
end;

procedure TChartZone.HintData(iBarIndex : Integer; stHints : TStringList);
var
  i : Integer;
begin
  for i:=0 to FCharters.Count-1 do
    TCharter(FCharters.Items[i]).HintData(iBarIndex, stHints);
end;


function TChartZone.Hit(const iHitX, iHitY : Integer;
  const iStartIndex, iBarIndex, iBarWidth : Integer): TCharter;
var
  i, iLeft : Integer;
  aCharter : TCharter;
begin
  Result := nil;
  //
  for i:=FCharters.Count-1 downto 0 do
  begin
    aCharter := TCharter(FCharters.Items[i]);
    if aCharter.Hit(iHitX, iHitY, FDrawRect, iStartIndex, iBarIndex, iBarWidth) then
    begin
      Result := aCharter;
      Break;
    end;
  end;
end;

procedure TChartZone.CalcSize(var iTop : Integer;
    const iHeight, iLeft, iRight : Integer);
begin
  if iHeight = 0 then Exit;
  //
  FDrawRect.Top := iTop + TITLE_WIDTH;
  FDrawRect.Left := iLeft;
  FDrawRect.Right := iRight;
  FDrawRect.Bottom := Min(iTop + Round(iHeight * FYRate)-1, iHeight-1);
  iTop := FDrawRect.Bottom+1;
end;

//------------------< Private Methods >----------------------//

procedure TChartZone.SetRate(const Value: Double);
begin
  FYRate := Value;
end;

function TChartZone.GetCharter(i:Integer) : TCharter;
begin
  if (i>=0) and (i<=FCharters.Count-1) then
    Result := TCharter(FCharters.Items[i])
  else
    Result := nil;
end;

//========================================================//
            { TChartZones }
//========================================================//

constructor TChartZones.Create(aRect : TRect);
begin
  inherited Create(TChartZone);
  //
  FDrawRect := aRect;
  FMode := rmCentric;
  FinTheQuote := false;
  FYRateType  := yrDefault;
end;


//------------------< Public methods >--------------------//

//-------------[templates]

procedure TChartZones.SetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
var
  i, iCnt : Integer;
  dRate : Double;
  aZone : TChartZone;
begin
  Stream.Read(iCnt, SizeOf(Integer));
  for i:=0 to iCnt-1 do
  begin
    // Y-rate
    Stream.Read(dRate, SizeOf(Double));
    if Count > i then
      aZone := Zones[i]
    else
      aZone := Add as TChartZone;
    aZone.FYRate := dRate;
    //
    // mode
    Stream.Read(aZone.FMode, SizeOf(TChartZoneMode));
    // custom ID
    Stream.Read(aZone.FCustomID, SizeOf(Integer));
  end;

  Redistribute;
  SetRects;
end;



procedure TChartZones.GetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
var
  i, iCount : Integer;
begin
  iCount := Count;
  Stream.Write(iCount, SizeOf(Integer));
  for i:=0 to Count-1 do
  begin
    Stream.Write(Zones[i].FYRate, SizeOf(Double));
    Stream.Write(Zones[i].FMode, SizeOf(TChartZoneMode));
    Stream.Write(Zones[i].FCustomID, SizeOf(Integer));
  end;
end;

//--------------[Persistence]

procedure TChartZones.GetPersistence(aBitStream : TMemoryStream);
var
  i, iCount : Integer;
begin
  with aBitStream do
  begin
    iCount := Count;
    Write(iCount, SizeOf(Integer));
    for i:=0 to Count-1 do
    begin
      Write(Zones[i].FYRate, SizeOf(Double));
      // after WORKSPACE_VERSION >= 5
      Write(Zones[i].FMode, SizeOf(TChartZoneMode));
      Write(Zones[i].FCustomID, SizeOf(Integer));
    end;
  end;
end;



procedure TChartZones.SetPersistence(aBitStream : TMemoryStream);
var
  i, iCnt : Integer;
  dRate : Double;
  aZone : TChartZone;
begin
  with aBitStream do
  begin
    Read(iCnt, SizeOf(Integer));
    for i:=0 to iCnt-1 do
    begin
      // Y-rate
      Read(dRate, SizeOf(Double));
      if Count > i then
        aZone := Zones[i]
      else
        aZone := Add as TChartZone;
      aZone.FYRate := dRate;
      //
      //if gWin.LoadingWorkspaceVersion >= 5 then
      //begin
        // mode
        Read(aZone.FMode, SizeOf(TChartZoneMode));
        // custom ID
        Read(aZone.FCustomID, SizeOf(Integer));
      //end;
    end;

    Redistribute;
    SetRects;
  end;
end;

function TChartZones.AddZone: TChartZone;
begin
  Result := Add as TChartZone;
  case FMode of
    rmCentric : // A main zone has double size of sub zones.
            Result.YRate := 1.0 / Count;
    rmIsotropic : // All zones has the same size
            if Count <= 1 then
              Result.YRate := 1.0
            else
              Result.YRate := 1.0 / (Count-1)
  end;
  //
  Redistribute;
  SetRects;
end;

procedure TChartZones.UpdateZone;
begin
  Redistribute2;
end;

procedure TChartZones.Redistribute2;
var
  dRateSum : Double;
  i : Integer;
  aItem : TChartZone;
begin
  dRateSum := 0.0;
  //-- get sum
  for i:=0 to Count-1 do
  begin
    aItem := Items[i] as TChartZone;
    aItem.YRate := 1.0 / Count;
    dRateSum := dRateSum + aItem.YRate;
  end;

  //-- recalculate
  for i:=0 to Count-1 do
  begin
    aITem := Items[i] as TChartZone;
    aItem.YRate := aItem.YRate / dRateSum;
  end;
end;

function TChartZones.InsertZone(iPrevZone : Integer) : TChartZone;
begin
  Result := Insert(iPrevZone+1) as TChartZone;
  case FMode of
    rmCentric : // A main zone has double size of sub zones.
            Result.YRate := 1.0 / Count;
    rmIsotropic : // All zones has the same size
            if Count <= 1 then
              Result.YRate := 1.0
            else
              Result.YRate := 1.0 / (Count-1)
  end;
  //
  Redistribute;
  SetRects;
end;


procedure TChartZones.SaveEnv(aStorage: TStorage);
var
  i, iCount : integer;
begin

  aStorage.FieldByName('ZonesCount').AsInteger := Count;
  aStorage.FieldByName('YRateType').AsInteger  := Integer( FYRateType );
  for i := 0 to Count - 1 do
  begin
    aStorage.FieldByName('ZonesYRate'+IntToStr(i)).AsFloat := Zones[i].FYRate;
    aStorage.FieldByName('ZonesMode'+IntToStr(i)).AsInteger := Integer(Zones[i].FMode);
    aStorage.FieldByName('ZonesID'+IntToStr(i)).AsInteger := Zones[i].FCustomID;
    aStorage.FieldByName('ZonesUse2'+IntToStr(i)).AsBoolean := Zones[i].FUse2Variable;
  end;

end;

procedure TChartZones.LoadEnv(aStorage: TStorage);
var
  i , iCount : integer;
  aZone : TChartZone;
begin
  iCount := aStorage.FieldByName('ZonesCount').AsInteger;
  for i := 0 to iCount - 1 do
  begin
    if Count > i then
      aZone := Zones[i]
    else
      aZone := Add as TChartZone;

    if aZone <> nil then
    begin
      aZone.FYRate  := aStorage.FieldByName('ZonesYRate'+IntToStr(i)).AsFloat;
      aZone.FMode  := TChartZoneMode(aStorage.FieldByName('ZonesMode'+IntToStr(i)).AsInteger);
      aZone.FCustomID  := aStorage.FieldByName('ZonesID'+IntToStr(i)).AsInteger;
      aZone.FUse2Variable  := aStorage.FieldByName('ZonesUse2'+IntToStr(i)).AsBoolean;
    end;
  end;

  FYRateType  := TYRateType( aStorage.FieldByName('YRateType').AsInteger );

  Redistribute;
  SetRects;

end;

function TChartZones.AddCharter(aCharter : TCharter) : TChartZone;
begin
  Result := AddZone;
  Result.Add(aCharter);
  //AddZone.Add(aCharter);
end;

function TChartZones.InsertCharter(iPrevZone : Integer; aCharter : TCharter) : TChartZone;
begin
  Result := InsertZone(iPrevZone);
  Result.Add(aCharter);
  //InsertZone(iPrevZone).Add(aCharter);
end;

procedure TChartZones.DeleteCharter(aCharter : TCharter);
var
  i : Integer;
begin
  for i:=Count-1 downto 0 do
  with Items[i] as TChartZone do
    Delete(aCharter);
  //
  Redistribute;
  SetRects;
end;

//---------// check if any empty zone

procedure TChartZones.RegulateZones;
var
  aZone : TChartZone;
  i, iDeleted : Integer;
begin
  iDeleted := 0;

  for i:=Count-1 downto 0 do
  begin
    aZone := Items[i] as TChartZone;
    if aZone.Count = 0 then
    begin
      aZone.Free;
      Inc(iDeleted);
    end;
  end;

  if iDeleted > 0 then
  begin
    Redistribute;
    SetRects;
  end;
end;

procedure TChartZones.Redistribute( bRecalc : boolean );
var
  dTmp, dRateSum : Double;

  i : Integer;
  aItem : TChartZone;
  j: Integer;
begin
  dRateSum := 0.0;

  if FYRateType = yrDefault then
  begin
  //-- get sum
    if bRecalc then
      for j := 0 to Count - 1 do
      begin
        dRateSum := 0.0;
        for i := 0 to j do
        begin
          aItem := Items[i] as TChartZone;
          if i=j then
            aItem.YRate := 1 / (j+1);
          dRateSum := dRateSum + aItem.YRate;
        end;

        for i:=0 to j do
        begin
          aITem := Items[i] as TChartZone;
          aItem.YRate := aItem.YRate / dRateSum;
        end;
      end;
    if bRecalc then exit;

    dRateSum := 0.0;
    for i:=0 to Count-1 do
    begin
      aItem := Items[i] as TChartZone;
      dRateSum := dRateSum + aItem.YRate;
    end;
  end
  else
  // 같은 크기 수정  20130403
    dRateSum  := 1 / Count;
  //-- recalculate
  for i:=0 to Count-1 do
  begin
    aITem := Items[i] as TChartZone;
    dTmp := aItem.YRate;
    case FYRateType of
      yrDefault: aItem.YRate := aItem.YRate / dRateSum;
      yrSame:    aItem.YRate := dRateSum;
    end;
  end;
end;

procedure TChartZones.ResizeZone(const iZone, iNewY : Integer);
var
  dRate : Double;
  iOldH, iNewH : Integer;
  aZone : TChartZone;
begin
  if (iZone < 0) or (iZone >= Count-1) then Exit;
  //
  if Zones[iZone+1].DrawRect.Bottom - iNewY < TITLE_WIDTH then Exit;
  //
  aZone := Zones[iZone];
  iOldH := aZone.DrawRect.Bottom - aZone.DrawRect.Top + TITLE_WIDTH;
  iNewH := iNewY - aZone.DrawRect.Top + TITLE_WIDTH;
  if iOldH <> 0 then
    aZone.YRate := aZone.YRate * (iNewH / iOldH);
  //
  aZone := Zones[iZone+1];
  iOldH := aZone.DrawRect.Bottom - aZone.DrawRect.Top + TITLE_WIDTH;
  iNewH := aZone.DrawRect.Bottom - iNewY;
  if iOldH <> 0 then
    aZone.YRate := aZone.YRate * (iNewH / iOldH);
  //
  Redistribute;
  SetRects;
end;

procedure TChartZones.MoveCharter(aCharter : TCharter; iFrom, iTo : Integer;
  bNewZone : Boolean);
var
  bMoved : Boolean;
  aZone : TChartZone;
begin
  //
  if iFrom < Count then
    aZone := Zones[iFrom]
  else
    aZone := nil;
  //
  if bNewZone then
  begin
    InsertCharter(iTo, aCharter);
    bMoved := True;
  end else
  if iTo < Count then
  begin
    Zones[iTo].Add(aCharter);
    bMoved := True;
  end else
    bMoved := False;
  //
  if bMoved and (aZone <> nil) then
  begin
    if iTo = 0 then
      aCharter.Position := cpMainGraph
    else
      aCharter.Position := cpSubGraph;

    aZone.Delete(aCharter);
    //
    Redistribute;
    SetRects;
  end;
end;


function TChartZones.IndexOfCharter(aCharter : TCharter) : Integer;
var
  i : Integer;
begin
  Result := -1;

  for i:=0 to Count-1 do
    if Zones[i].HasCharter(aCharter) then
    begin
      Result := i;
      Break;
    end;
end;

procedure TChartZones.Resize(aRect: TRect);
begin
  FDrawRect := aRect;
  SetRects;
end;

procedure TChartZones.ResizeZone;
begin
  Redistribute( true );
  SetRects; 
end;

procedure TChartZones.SetRects;
var
  i : Integer;
  iTop, iHeight : Integer;
  aZone : TChartZone;
begin
  iTop := 0;
  iHeight := FDrawRect.Bottom-FDrawRect.Top;
  //
  for i:=0 to Count-1 do
  begin
    aZone := Items[i] as TChartZone;
    aZone.CalcSize(iTop, iHeight, FDrawRect.Left, FDrawRect.Right);
  end;
end;

//
function TChartZones.IndexOfZone(iX, iY : Integer) : Integer;
var
  i : Integer;
  aZone : TChartZone;
begin
  Result := -1;
  //
  if (iX > FDrawRect.Left) and (iX < FDrawRect.Right) then
    for i:=0 to Count-1 do
    begin
      aZone := Items[i] as TChartZone;
      if (iY >= aZone.FDrawRect.Top-TITLE_WIDTH) and
         (iY <= aZone.FDrawRect.Bottom) then
      begin
        Result := i;
        Break;
      end;
    end;
end;

function TChartZones.IndexOfBoundary(iX, iY : Integer) : Integer;
const
  BOUND_HEIGHT = 3;
var
  i : Integer;
  aZone : TChartZone;
begin
  Result := -1;
  //
  if (iX > FDrawRect.Left) and (iX < FDrawRect.Right) then
    for i:=0 to Count-1 do
    begin
      aZone := Items[i] as TChartZone;
      if Abs(aZone.FDrawRect.Bottom - iY) <= BOUND_HEIGHT then
      begin
        Result := i;
        Break;
      end;
    end;
end;

function TChartZones.GetZone(i:Integer) : TChartZone;
begin
  if (i>=0) and (i<Count) then
    Result := Items[i] as TChartZone
  else
    Result := nil;
end;


procedure TChartZones.SetZone(idx: integer; aCharter: TCharter);
var
  aZone : TChartZone;
begin
  if (idx>=0) and (idx<Count) then
    aZone := Items[idx] as TChartZone
  else
    exit;

  if aZone.FCharters.Count > 0 then
    aZone.FCharters.Items[0] := aCharter;

end;

//---------------------< Drawing routines >-------------------------//

procedure TChartZones.DrawTitles(aCanvas : TCanvas; aSelected : TCharter);
var
  i : Integer;
begin
  for i:=0 to Count-1 do
  begin
    (Items[i] as TChartZone).DrawTitles(aCanvas, aSelected);
  end;
end;

procedure TChartZones.Draw(const aCanvas : TCanvas; const iStart, iEnd, iBarWidth : Integer;
           const bLeft, bRight, bHLine : Boolean; const aGridColor : TColor;
           aSelected : TCharter ; bDrawSeparator : Boolean = False);
var
  i : Integer;
  aColor : TColor;
  aChartZone : TChartZone;
begin
  for i:=0 to Count-1 do
  begin
   (Items[i] as TChartZone).Draw(aCanvas, iStart, iEnd, iBarWidth,
                                 bLeft, bRight, bHLine, aGridColor, aSelected);

   if bDrawSeparator then
   begin
    aChartZone := Items[i] as TChartZone;
    if (i <> Count-1) then
    begin
      aColor := aCanvas.Pen.Color;
      aCanvas.Pen.Color := clGrayText;
      aCanvas.MoveTo(aChartZone.FDrawRect.Left , aChartZone.FDrawRect.Bottom);
      aCanvas.LineTo(aChartZone.FDrawRect.Right , aChartZone.FDrawRect.Bottom);
      aCanvas.Pen.Color := aColor;
    end;
   end;

  end;
end;

procedure TChartZones.DrawSeparators(const aCanvas : TCanvas; iLeft, iRight : Integer);
var
  i : Integer;
  aZone : TChartZone;
begin
  for i:=0 to Count-2 do
  begin
    aZone := Items[i] as TChartZone;
    aCanvas.MoveTo(iLeft, aZone.DrawRect.Bottom);
    aCanvas.LineTo(iRight, aZone.DrawRect.Bottom);
  end;
end;



end.

