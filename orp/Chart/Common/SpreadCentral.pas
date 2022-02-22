unit SpreadCentral;

interface

uses
  Windows, Classes, Graphics, Forms, Controls, Math, StdCtrls, SysUtils,
  Dialogs,
  //
  CleDistributor, CleSymbols,

  ChartData, XTerms,
  ChartZones,
  Charters, SpreadCharter, Indicator, Stickers,
  DIndicator, SpreadData,
  ChartCentralBase;

type

  TSpreadChartCentral = class(TChartCentralBase)
  protected
    FSpreadCharters : TList;
  private
      // events
    FOnChartDelete : TNotifyEvent;

    procedure InitFactors; override;
  public
    constructor Create(aForm : TForm; aCanvas : TCanvas; aRect : TRect;
                   aScroll : TScrollBar); override;
    destructor Destroy; override;

      // persistency
    procedure SetPersistence(aBitStream : TMemoryStream);
    procedure GetPersistence(aBitStream : TMemoryStream);

      // find
    function FindSeries(aSeries : TSpreadSeries) : TSpreadCharter;

      // insert series
    function InsertSeries(aSeries : TSpreadSeries; aColor : TColor;
         iWidth, iZoneID : Integer; zmValue : TChartZoneMode = zmIndependent;
         bRefresh : Boolean = True) : TSpreadCharter; overload;
    function InsertSeries(aSeries : TSpreadSeries; aColor : TColor;
         iWidth, iZoneID : Integer; aCharterClass : TSpreadCharterClass;
         zmValue : TChartZoneMode = zmIndependent;
         bRefresh : Boolean = True) : TSpreadCharter; overload;

      // insert series from workspace
    function InsertPersistenceSeries(iZone : Integer;
         aSeries : TSpreadSeries; aColor : TColor;
         iWidth : Integer) : TSpreadCharter; overload;
    function InsertPersistenceSeries(iZone : Integer;
         aSeries : TSpreadSeries; aColor : TColor; iWidth : Integer;
         aCharterClass : TSpreadCharterClass) : TSpreadCharter; overload;

      // update & delete series
    function UpdateSeries(aSeries : TSpreadSeries; aColor : TColor;
         iWidth : Integer) : TSpreadCharter;
    function DeleteSeries(aSeries : TSpreadSeries) : Boolean;

      // misc
    function GetZoneIndex(aSeries : TSpreadSeries) : Integer;
    procedure ChangeScale(aScale : TScaleType);

      // delete charter
    procedure Delete(aCharter : TCharter); override;

      // refresh
    procedure RefreshOnData(aMode : TRangeSetMode);

      // events
    property OnChartDelete : TNotifyEvent read FOnChartDelete write FOnChartDelete;
  end;

implementation

uses DChartCfg, DCharters;

{ TSpreadChartCentral }

//=====================================================================//
//                        Init / Final                                 //
//=====================================================================//

constructor TSpreadChartCentral.Create(aForm : TForm; aCanvas : TCanvas; aRect : TRect;
     aScroll : TScrollBar);
begin
  inherited Create(aForm, aCanvas, aRect, aScroll);

  FMainCharterProtected := False;
  FChartZones.Mode := rmIsotropic;
  //
  FSpreadCharters := TList.Create;
end;

destructor TSpreadChartCentral.Destroy;
var
  i : Integer;
begin
  //
  for i:=0 to FSpreadCharters.Count-1 do
    TSpreadCharter(FSpreadCharters.Items[i]).Free;
  FSpreadCharters.Free;
  //
  inherited;
end;

procedure TSpreadChartCentral.InitFactors;
begin
  inherited;

  FBarWidth := 4;
end;

procedure TSpreadChartCentral.SetPersistence(aBitStream : TMemoryStream);
var
  //i, iCnt, iIndex : Integer;
  szBuf : array[0..101] of Char;
  bCharter : Boolean;
  aClass : TIndicatorClass;
  aIndicator : TIndicator;
 begin
  // screen config
  aBitStream.Read(FBackgroundColor, SizeOf(TColor));
  aBitStream.Read(FAxisColor, SizeOf(TColor));
  aBitStream.Read(szBuf, 50);
  FFontName := szBuf;
  aBitStream.Read(FFontSize, SizeOf(Integer));
  aBitStream.Read(FFontColor, SizeOf(FFontColor));
  aBitStream.Read(FHLine, SizeOf(FHLine));
  aBitStream.Read(FVLine, SizeOf(FVLine));
  aBitStream.Read(FGridColor, SizeOf(TColor));
  aBitStream.Read(FLeftYScale, SizeOf(Boolean));
  aBitStream.Read(FRightYScale, SizeOf(Boolean));
  aBitStream.Read(FYCharWidth, SizeOf(Integer));
  aBitStream.Read(FBarWidth, SizeOf(FBarWidth));
  // chart zones
  FChartZones.SetPersistence(aBitStream);

 // if gWin.LoadingWorkspaceVersion >= 9 then
 // begin
    //New Added WorkSpace Details after WorkSpace Version 9
    aBitStream.Read(FMoving , SizeOf(Boolean));
    aBitStream.Read(FRightMargin , SizeOf(Integer));
    aBitStream.Read(FDrawSeparator , SizeOf(Boolean));
 // end;

  if Assigned(FOnBarWidth) then FOnBarWidth(Self);
end;

procedure TSpreadChartCentral.GetPersistence(aBitStream : TMemoryStream);
var
  szBuf : array[0..101] of Char;
  bCharter : Boolean;
  stAccount, stDesc : String;
  i, iIndex : Integer;
  aIndicator : TIndicator;
begin
  // screen config
  aBitStream.Write(FBackgroundColor, SizeOf(TColor));
  aBitStream.Write(FAxisColor, SizeOf(TColor));
  StrPCopy(szBuf, FFontName);
  aBitStream.Write(szBuf, 50);
  aBitStream.Write(FFontSize, SizeOf(Integer));
  aBitStream.Write(FFontColor, SizeOf(FFontColor));
  aBitStream.Write(FHLine, SizeOf(FHLine));
  aBitStream.Write(FVLine, SizeOf(FVLine));
  aBitStream.Write(FGridColor, SizeOf(TColor));
  aBitStream.Write(FLeftYScale, SizeOf(Boolean));
  aBitStream.Write(FRightYScale, SizeOf(Boolean));
  aBitStream.Write(FYCharWidth, SizeOf(Integer));
  aBitStream.Write(FBarWidth, SizeOf(FBarWidth));
  // chart zones
  FChartZones.GetPersistence(aBitStream);

  //New Added WorkSpace Details after WorkSpace Version 9
  aBitStream.Write(FMoving , SizeOf(Boolean));
  aBitStream.Write(FRightMargin , SizeOf(Integer));
  aBitStream.Write(FDrawSeparator , SizeOf(Boolean));
end;


//-------------------< Private Methods : Draing factors >---------------//

procedure TSpreadChartCentral.RefreshOnData(aMode : TRangeSetMode);
begin
  case aMode of
    rmAdd :  SetDrawRange(rmAdd);
    rmRefresh : begin
                  SetDrawRange(rmRefresh);
                  ClearStickers;
                end;
  end;
  
  Refresh;
end;


// delete charter
procedure TSpreadChartCentral.Delete(aCharter : TCharter);
var
  aSticker : TSticker;
begin
  if aCharter = nil then Exit;
  //
  //-- remove from Chart Zones
  FChartZones.DeleteCharter(aCharter);
  //-- remove from list
  if aCharter is TSpreadCharter then
  begin
    FSpreadCharters.Remove(aCharter);
    // remove connected stickers also
    DetachStickers(aCharter);
  end else
  if aCharter is TSticker then
    FStickers.Remove(aCharter);
  //-- check main charter
  if aCharter = FMainCharter then
  begin
    if FSpreadCharters.Count = 0 then
    begin
      FMainCharter := nil;
      SetDrawRange(rmRefresh);
    end else
      FMainCharter := FSpreadCharters.Items[0];
  end else
    if FSpreadCharters.Count = 0 then
      SetDrawRange(rmRefresh);

  //-- notify
  if Assigned(FOnChartDelete) then
    FOnChartDelete(aCharter);

  //-- release the object
  aCharter.Free;

  //-- redraw
  Refresh;
end;


//--------------------------------------------------------------//
//              Handling Spread Charter                         //
//--------------------------------------------------------------//

function TSpreadChartCentral.GetZoneIndex(aSeries : TSpreadSeries) : Integer;
var
  aCharter : TCharter;
begin
  aCharter := FindSeries(aSeries);
  if aCharter <> nil then
    Result := FChartZones.IndexOfCharter(aCharter)
  else
    Result := -1;
end;

function TSpreadChartCentral.FindSeries(aSeries : TSpreadSeries) : TSpreadCharter;
var
  i : Integer;
  aCharter : TSpreadCharter;
begin
  Result := nil;

  for i:=0 to FSpreadCharters.Count-1 do
  begin
    aCharter := TSpreadCharter(FSpreadCharters.Items[i]);
    if aCharter.Series = aSeries then
    begin
      Result := aCharter;
      Exit;
    end;
  end;
end;

function TSpreadChartCentral.InsertPersistenceSeries(iZone : Integer;
  aSeries : TSpreadSeries; aColor : TColor; iWidth : Integer) : TSpreadCharter;
begin
  InsertPersistenceSeries(iZone, aSeries, aColor, iWidth, TSpreadCharter);
end;

function TSpreadChartCentral.InsertPersistenceSeries(iZone : Integer;
  aSeries : TSpreadSeries; aColor : TColor; iWidth : Integer;
  aCharterClass : TSpreadCharterClass) : TSpreadCharter;
var
  aZone : TChartZone;
  aCharter : TSpreadCharter;
begin
  // check duplicate
  Result := FindSeries(aSeries);
  if Result <> nil then Exit;
  if (iZone < 0) and (iZone > FChartZones.Count-1) then
    Exit;

  // make new
  aCharter := aCharterClass.Create;
  aCharter.Series := aSeries;
  aCharter.ChartColor := aColor;
  aCharter.LineWidth := iWidth;

  // assign to main charter
  if FMainCharter = nil then
    FMainCharter := aCharter;

  FChartZones[iZone].Add(aCharter);

  // add to the list
  FSpreadCharters.Add(aCharter);
  //
  Result := aCharter;
end;

function TSpreadChartCentral.InsertSeries(aSeries : TSpreadSeries; aColor : TColor;
     iWidth, iZoneID : Integer; zmValue : TChartZoneMode; bRefresh : Boolean) : TSpreadCharter;
begin
  InsertSeries(aSeries, aColor, iWidth, iZoneID, TSpreadCharter, zmValue, bRefresh);
end;

function TSpreadChartCentral.InsertSeries(aSeries : TSpreadSeries; aColor : TColor;
     iWidth, iZoneID : Integer; aCharterClass : TSpreadCharterClass;
     zmValue : TChartZoneMode; bRefresh : Boolean) : TSpreadCharter;
var
  i : Integer;
  aZone : TChartZone;
  aCharter : TSpreadCharter;
begin
  if aCharterClass = nil then Exit;

  // check duplicate
  Result := FindSeries(aSeries);
  if Result <> nil then Exit;

  // make new
  aCharter := aCharterClass.Create;
  aCharter.Series := aSeries;
  aCharter.ChartColor := aColor;
  aCharter.LineWidth := iWidth;

  // assign to main charter
  if FMainCharter = nil then
    FMainCharter := aCharter;

  // assign to a chart zone
  aZone := nil;
  if FChartZones.Count = 0 then
    aZone := FChartZones.AddCharter(aCharter)
  else
  for i:=0 to FChartZones.Count-1 do
    if FChartZones[i].CustomID = iZoneID then
    begin
      FChartZones[i].Add(aCharter);
      Break;
    end else
    if FChartZones[i].CustomID > iZoneID then
    begin
      aZone := FChartZones.InsertCharter(i-1, aCharter);
      Break;
    end else
    if i = FChartZones.Count-1 then
      aZone := FChartZones.AddCharter(aCharter);

  if aZone <> nil then
  begin
   if aZone.CustomID <> iZoneID then
     aZone.CustomID := iZoneID;
   if aZone.Mode <> zmValue then
     aZone.Mode := zmValue;
  end;

  // add to the list
  FSpreadCharters.Add(aCharter);
  // if first time
  if FSpreadCharters.Count = 1 then
    SetDrawRange(rmRefresh);
  //
  Result := aCharter;

  // redraw
  if bRefresh then Refresh;
end;

function TSpreadChartCentral.UpdateSeries(aSeries : TSpreadSeries; aColor : TColor;
     iWidth : Integer) : TSpreadCharter;
begin
  Result := FindSeries(aSeries);
  if Result <> nil then
  begin
    Result.ChartColor := aColor;
    Result.LineWidth := iWidth;

    Refresh;
  end;
end;

function TSpreadChartCentral.DeleteSeries(aSeries : TSpreadSeries) : Boolean;
var
  aCharter : TSpreadCharter;
begin
  aCharter := FindSeries(aSeries);
  if aCharter <> nil then
  begin
    Delete(aCharter);
    Result := True;
  end else
    Result := False;
end;

procedure TSpreadChartCentral.ChangeScale(aScale : TScaleType);
var
  i : Integer;
begin
  for i:=0 to FSpreadCharters.Count-1 do
  with TSeriesCharter(FSpreadCharters.Items[i]) do
    ScaleType := aScale;
end;


end.
