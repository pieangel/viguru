unit ChartCentral;

interface

uses
  Windows, Classes, Graphics, Forms, Controls, Math, StdCtrls, SysUtils,
  Dialogs,
  //
  CleAccounts, GleTypes, CleSymbols, CleOrders,  CleQuoteBroker, ClePositions,
  ChartData, XTerms, CleQuoteTimers, CleStorage,
  ChartZones, Shows,
  Charters, Symbolers, Indicator, Stickers, CleFills,
  DIndicator, DSymbolers, TyIndicator, TyIndicators,
  ChartCentralBase

  ;

type
  //

  TChartCentral = class(TChartCentralBase)
  private
    // Data
    FAccount : TAccount;
    //FMainCharter : TSymboler;

    // storages of charters
    FSymbolers : TList;
    FIndicators : TList;

    // storages of other used objects
    FImageFills : TImageList;
    FUsedSymbols : TList;

    //Symboler Sync
    FSymbolSynchronized : Boolean;

    FUpdateCount : Integer;
    FTimer : TQuoteTimer ;

    FShowMe: TShowMes;


    procedure SetAccount(aAccount : TAccount);
    // Derivative Drawing Factors
    procedure InitFactors; override;
    //

    procedure BeatorProc(aSender : TObject);

    procedure DataAddProc(Sender : TObject);
    procedure DataUpdateProc(Sender : TObject);
    procedure DataRefreshProc(Sender : TObject);
    //
    procedure CharterDelete(Sender : TObject);
    procedure CharterMove(Sender : TObject);

    procedure CharterAsyncAdd(Sender : TObject);
    procedure CharterAsyncUpdate(Sender : TObject);
    procedure CharterAsyncRefresh(Sender : TObject);
    //
    procedure ClearIndicators;

    //
    function GetMainCharter : TSymboler;
    function GetCanInsertSymbol : Boolean;
    procedure InsertShowMe;

  public


    constructor Create(aForm : TForm; aCanvas : TCanvas; aRect : TRect;
                   aScroll : TScrollBar); override;
    destructor Destroy; override;
    //
    procedure SetPersistence(aBitStream : TMemoryStream);
    procedure GetPersistence(aBitStream : TMemoryStream);
    procedure SetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
    procedure GetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
    // process fill
    procedure DoFill(aFill : TFill );
    // config
    function ConfigSymbols : Boolean;
    function ConfigIndicators : Boolean;
    function ConfigShowMe : Boolean;
    // insert
    function InsertSymbol : Boolean;
    // symboler sync
    //procedure SyncSymbol(bSync : Boolean);

    //multi
    function InsertSymbolIndicator : Boolean;

    function InsertIndicator : Boolean;
    function CreateIndicator( aClass : TIndicatorClass ) : Boolean; overload;
    function CreateIndicator( aPos : TPosition; aClass : TIndicatorClass ) : Boolean; overload;


    // managing
    procedure Delete(aCharter : TCharter); override;
   //
    //
    property Account : TAccount read FAccount write SetAccount;
    property ImageFills : TImageList read FImageFills write FImageFills;

    property MainCharter : TSymboler read GetMainCharter;

    property SymbolSynchronized : Boolean read FSymbolSynchronized write FSymbolSynchronized;
    property CanInsertSymbol : Boolean read GetCanInsertSymbol;

    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

    // show me
    function CreateShowMe( aItem : TShowMeItem ) : Boolean;
    property ShowMe : TShowMes read FShowMe write FShowMe;
  end;


implementation

uses DCharters, ChartIF, GAppEnv, DShowMe, DShowmeParamCfg;

{ TChartCentral }

function TChartCentral.GetMainCharter : TSymboler;
begin
  Result := FMainCharter as TSymboler;
end;

procedure TChartCentral.GetPersistence(aBitStream: TMemoryStream);
begin

end;

//=====================================================================//
//                        Init / Final                                 //
//=====================================================================//

constructor TChartCentral.Create(aForm : TForm; aCanvas : TCanvas; aRect : TRect;
     aScroll : TScrollBar);
begin
  inherited Create(aForm, aCanvas, aRect, aScroll);

  FMainCharterProtected := True;
  FShowMe:= TShowMes.Create;

  // showme add
  InsertShowMe;

  FUsedSymbols := TList.Create;
  //
  FSymbolers := TList.Create;
  FIndicators := TList.Create;

  FSymbolSynchronized := False;

  FUpdateCount := 0;
  FTimer := gEnv.Engine.QuoteBroker.Timers.New;

  with FTimer do
  begin
    Enabled := True;
    Interval := 1000  ;
    OnTimer := BeatorProc;
  end;
end;



destructor TChartCentral.Destroy;
var
  i : Integer;
begin
  //
  FTimer.Enabled := false;
  FTimer.Free;

  ClearIndicators;
  FIndicators.Free;
  //
  FUsedSymbols.Free;
  FShowMe.Free;
  //
  for i:=0 to FSymbolers.Count-1 do
    TSymboler(FSymbolers.Items[i]).Free;
  FSymbolers.Free;
  //

  inherited;
end;

procedure TChartCentral.BeatorProc(aSender : TObject);
begin
  if FUpdateCount <> 0 then
  begin
    Refresh;
    FUpdateCount := 0;
  end;

end;

//----------------------< Template >-------------------------------//

procedure TChartCentral.SetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
var
  i, iCnt, iIndex, iCount : Integer;
  szBuf : array[0..101] of Char;
  stIndicator : String;
  aClass : TIndicatorClass;
  aIndicator : TIndicator;
begin
  if FIndicators.Count > 0 then
  begin
    case MessageDlg('기존에 있던 지표를 삭제할까요?', mtConfirmation,
                        [mbYes, mbNo, mbCancel], 0) of
      mrYes : for i := FIndicators.Count-1 downto 0 do
              try
                Delete(TCharter(FIndicators.Items[i]));
              except
                //
              end;
      mrNo : ;
      mrCancel : Exit;
    end;
  end;

  // chart zones
  FChartZones.SetTemplate(iVersion, stKey, Stream);

  // indicator
  Stream.Read(iCnt, SizeOf(Integer));
  for i:=0 to iCnt-1 do
  begin
    Stream.Read(iIndex, SizeOf(Integer));
    Stream.Read(szBuf, 91);
    stIndicator := szBuf;
    aClass := FindIndicator(Trim(stIndicator));

    if aClass = nil then Exit; // fatal condition

    aIndicator := aClass.Create(MainCharter);
    aIndicator.SetTemplate(iVersion, stKey, Stream);
    if (FChartZones.Count > iIndex) and (iIndex >= 0) then
      FChartZones.Zones[iIndex].Add(aIndicator);

    aIndicator.OnAsyncUpdate := CharterAsyncUpdate;
    aIndicator.OnAsyncRefresh := CharterAsyncRefresh;
    aIndicator.OnMove := CharterMove;
    aIndicator.OnDelete := CharterDelete;

    FIndicators.Add(aIndicator);

    aIndicator.Refresh(irmHot);
  end;

  // check if any empty zone
  FChartZones.RegulateZones;
  
  Refresh;
end;

procedure TChartCentral.GetTemplate(iVersion : Integer; stKey : String; Stream : TMemoryStream);
var
  szBuf : array[0..101] of Char;
  stAccount, stDesc : String;
  i, iIndex, iCount : Integer;
  aIndicator : TIndicator;
  aSymboler : TSymboler;
begin
  // chart zones
  FChartZones.GetTemplate(iVersion, stKey, Stream);

  // indicators
  Stream.Write(FIndicators.Count, SizeOf(Integer));
  for i:=0 to FIndicators.Count-1 do
  begin
    iIndex := FChartZones.IndexOfCharter(FIndicators.Items[i]);
    Stream.Write(iIndex, SizeOf(Integer));
    aIndicator := TIndicator(FIndicators.Items[i]);
    stDesc := Format('%-90s', [aIndicator.ClassName]);
    StrPCopy(szBuf, stDesc);
    Stream.Write(szBuf, Length(stDesc)+1);
    aIndicator.GetTemplate(iVersion, stKey, Stream);
  end;
end;

//----------------------<>---------------------------------------//
procedure TChartCentral.ClearIndicators;
var
  i : Integer;
  aIndicator : TIndicator;
begin
  for i:=0 to FIndicators.Count - 1 do
  begin
    aIndicator := TIndicator(FIndicators.Items[i]);
    FChartZones.DeleteCharter(aIndicator);
    aIndicator.Free;
  end;
  //
  FIndicators.Clear;
end;


procedure TChartCentral.InsertShowMe;
var
  aItem : TShowMeItem;
begin
  aItem := FShowMe.New('계좌체결');
  aItem.EnAbled := false;
  aItem.Param   := '';
  aItem.AskColor:= clBlue;
  aItem.BidColor:= clWhite;
  aItem.OffSet  := 1;
end;

//=====================================================================//
//                        Process Fill                                 //
//=====================================================================//

//--------------------< Process fill >----------------------------------//

procedure TChartCentral.SaveEnv(aStorage: TStorage);
var
  bCharter : Boolean;
  stAccount, stDesc : String;
  i, iIndex, iCount : Integer;
  aIndicator : TIndicator;
  aSymboler : TSymboler;
  bSub : boolean;
begin

  aStorage.FieldByName('BackgroundColor').AsInteger := Integer( FBackgroundColor );
  aStorage.FieldByName('AxisColor').AsInteger   := Integer( FAxisColor );
  aStorage.FieldByName('FontName').AsString     := FFontName;
  aStorage.FieldByName('FontColor').AsInteger    := Integer( FFontColor );

  aStorage.FieldByName('HLine').AsBoolean     := FHLine;
  aStorage.FieldByName('VLIne').AsBoolean     := FVLine;

  aStorage.FieldByName('GridColor').AsInteger     := Integer( FGridColor );;
  aStorage.FieldByName('LeftYScale').AsBoolean     := FLeftYScale;
  aStorage.FieldByName('RightYScale').AsBoolean     := FRightYScale;
  aStorage.FieldByName('YCharWidth').AsInteger     := FYCharWidth;

  bCharter := (FMainCharter <> nil);
  aStorage.FieldByName('bCharter').AsBoolean     := bCharter;


  if MainCharter <> nil then
    MainCharter.SaveEnv( aStorage, true );

  if FAccount = nil then
    stAccount := Format('%-14s', [''])
  else
    stAccount := Format('%-14s', [FAccount.Code]);
  aStorage.FieldByName('Account').AsString     := stAccount;


  for i := 0 to ShowMe.Count - 1 do
    ShowMe.ShowMe[i].SaveEnv( aStorage );


  aStorage.FieldByName('BarWidth').AsInteger   := FBarWidth;
    // chart zones
  FChartZones.SaveEnv( aStorage );
  aStorage.FieldByName('FIndicators.Count').AsInteger     := FIndicators.Count;

  for i := 0 to FIndicators.Count - 1 do
  begin
    iIndex := FChartZones.IndexOfCharter(FIndicators.Items[i]);
    aStorage.FieldByName('iIndex'+IntTostr(i)).AsInteger     := iIndex;
    aIndicator := TIndicator(FIndicators.Items[i]);
    aStorage.FieldByName('aIndicator.ClassName'+IntTostr(i)).AsString     := aIndicator.ClassName;
    aIndicator.SaveEnv( aStorage, i );
  end;

  aStorage.FieldByName('Moving').AsBoolean     := FMoving;
  aStorage.FieldByName('RightMargin').AsInteger     := FRightMargin;
  aStorage.FieldByName('DrawSeparator').AsBoolean     := FDrawSeparator;

  iCount := FSymbolers.Count-1;
  aStorage.FieldByName('iCount').AsInteger     := iCount;
  for i := 0 to iCount do
    if TSymboler(FSymbolers.Items[i]).SymbolerMode = smSub then
    begin
      bSub := true;
      aStorage.FieldByName('SymbolerSub'+IntToStr(i)).AsBoolean := bSub;
      iIndex := FChartZones.IndexOfCharter(FSymbolers.Items[i]);
      aStorage.FieldByName('Symboler'+IntToStr(i)).AsInteger  := iIndex;
      TSymboler(FSymbolers.Items[i]).SaveEnv( aStorage, false, i );
      bSub := false;
    end;

end;

procedure TChartCentral.LoadEnv(aStorage: TStorage);
var
  i, iCnt, iIndex, iCount : Integer;

  bCharter : Boolean;
  stAccount, stIndicator : String;
  aClass : TIndicatorClass;
  aIndicator : TIndicator;
  aAccount : TAccount;
  aSymboler : TSymboler;
  bSub : boolean;
  aZone : TChartZone;
begin

  FBackgroundColor  := TColor( aStorage.FieldByName('BackgroundColor').AsInteger);
  FAxisColor  := TColor( aStorage.FieldByName('AxisColor').AsInteger);
  FFontName := aStorage.FieldByName('FontName').AsString;
  FFontColor  := TColor( aStorage.FieldByName('FontColor').AsInteger);

  FHLine  := aStorage.FieldByName('HLine').AsBoolean;
  FVLine  := aStorage.FieldByName('VLIne').AsBoolean;

  FGridColor  := TColor( aStorage.FieldByName('GridColor').AsInteger );
  FLeftYScale := aStorage.FieldByName('LeftYScale').AsBoolean;
  FRightYScale  := aStorage.FieldByName('RightYScale').AsBoolean;
  FYCharWidth := aStorage.FieldByName('YCharWidth').AsInteger;

  bCharter  := aStorage.FieldByName('bCharter').AsBoolean;

  if bCharter then
  begin
    FMainCharter := TSymboler.Create(MainCharter);
    FSymbolers.Add(FMainCharter);

    MainCharter.Images := FImageFills;

    MainCharter.OnSyncAdd := DataAddProc;
    MainCharter.OnSyncUpdate := DataUpdateProc;
    MainCharter.OnSyncRefresh := DataRefreshProc;

    //
    FChartZones.AddCharter(MainCharter);
    //
    MainCharter.LoadEnv( aStorage );
    {
    if MainCharter.XTerms.Base = cbQuote then begin
      aZone := FChartZones.AddCharter(MainCharter);
      aZone.Use2Variable  := true;
      FChartZones.UpdateZone;
      FChartZones.InTheQuote  := true;
    end;
    }
    //
    FInitialized := True;
  end;

  {
  stAccount := aStorage.FieldByName('Account').AsString;
  aAccount := gEnv.Engine.TradeCore.Accounts.Find( Trim(stAccount));
  if aAccount <> nil then
    SetAccount( aAccount );
  }

  for i := 0 to ShowMe.Count - 1 do
  begin
    ShowMe.ShowMe[i].LoadEnv( aStorage );

    if ShowMe.ShowMe[i].SType = snFill then
    begin
      aAccount := gEnv.Engine.TradeCore.Accounts.Find( Trim(ShowMe.ShowMe[i].Param));
      SetAccount( aAccount );

      if MainCharter <> nil then
        MainCharter.ShowMeItem  :=  ShowMe.ShowMe[i];
    end
    else begin

    end;

  end;
  FBarWidth := aStorage.FieldByName('BarWidth').AsInteger;
  if Assigned(FOnBarWidth) then FOnBarWidth(Self);
    // chart zones
  FChartZones.LoadEnv( aStorage );
  iCount  := aStorage.FieldByName('FIndicators.Count').AsInteger;

  for i := 0 to iCount - 1 do
  begin
    iIndex  := aStorage.FieldByName('iIndex'+IntTostr(i)).AsInteger;
    stIndicator := aStorage.FieldByName('aIndicator.ClassName'+IntTostr(i)).AsString;
    if stIndicator = 'TProfitNLoss2' then continue;
    aClass := FindIndicator(Trim(stIndicator));
    if aClass = nil then Exit; // fatal condition
    aIndicator := aClass.Create(MainCharter);
    aIndicator.LoadEnv( aStorage, i);

    if (FChartZones.Count > iIndex) and (iIndex >= 0) then
      FChartZones.Zones[iIndex].Add(aIndicator);

    aIndicator.OnAsyncUpdate := CharterAsyncUpdate;
    aIndicator.OnAsyncRefresh := CharterAsyncRefresh;
    aIndicator.OnMove := CharterMove;
    aIndicator.OnDelete := CharterDelete;

    FIndicators.Add(aIndicator);
    aIndicator.Refresh(irmWarm);
  end;

  FMoving := aStorage.FieldByName('Moving').AsBoolean;
  FRightMargin  := aStorage.FieldByName('RightMargin').AsInteger;
  FDrawSeparator  := aStorage.FieldByName('DrawSeparator').AsBoolean;

  iCount := aStorage.FieldByName('iCount').AsInteger ;

  for i := 0 to iCount do
  begin
    bSub := aStorage.FieldByName('SymbolerSub'+IntToStr(i)).AsBoolean ;
    if not bsub then Continue;

    iIndex := aStorage.FieldByName('Symboler'+IntToStr(i)).AsInteger;
    aSymboler := TSymboler.Create(MainCharter);
    FSymbolers.Add(aSymboler);
    if (FChartZones.Count > iIndex) and (iIndex >= 0) then
      FChartZones.Zones[iIndex].Add(aSymboler);

    aSymboler.Images := FImageFills;
    aSymboler.OnMove := CharterMove;
    aSymboler.OnDelete := CharterDelete;

    aSymboler.OnAsyncAdd := CharterAsyncAdd;
    aSymboler.OnAsyncUpdate := CharterAsyncUpdate;
    aSymboler.OnAsyncRefresh := CharterAsyncRefresh;

    aSymboler.LoadEnv( aStorage,false, i );
  end;

  FChartZones.RegulateZones;

end;


procedure TChartCentral.SetAccount(aAccount : TAccount);
var
  i : Integer;
begin
  if FAccount = aAccount then Exit;
  //
  if MainCharter <> nil then
  begin
    MainCharter.XTerms.Account := aAccount;
    for i := 0 to FSymbolers.Count-1 do
      if TSymboler(FSymbolers.Items[i]).SymbolerMode = smSub then
        TSymboler(FSymbolers.Items[i]).GetFill;
  end;

  FAccount := aAccount;
end;

procedure TChartCentral.SetPersistence(aBitStream: TMemoryStream);
begin

end;

procedure TChartCentral.DoFill(aFill : TFill);
var
  i : Integer;
  aSymboler : TSymboler;
begin
  if (MainCharter <> nil) and (MainCharter.XTerms.Symbol <> nil) and
     (MainCharter.XTerms.Account <> nil) and
     (MainCharter.XTerms.Account = aFill.Account ) then
  begin
    for i := 0 to FSymbolers.Count-1 do
    begin
      aSymboler := TSymboler(FSymbolers.Items[i]);
      with aSymboler do
        if ShowFill and (XTerms.Symbol = aFill.Symbol) then
        begin
          XTerms.AddFill(aFill);
        end;
    end;
    //
    Refresh;
 //   FOnUpdate(Self);
  end;
end;

//-------------------< Private Methods : Draing factors >---------------//

// 초기값
procedure TChartCentral.InitFactors;
begin
  inherited;

  FBackgroundColor := clBlack;
  FAxisColor := clRed;
  FFontColor := clWhite;
  FHLine := False;
  FVLine := False;
end;



//-------------------< Private Methods : Draing factors >---------------//


// data added
procedure TChartCentral.DataAddProc(Sender : TObject);
var
  i : Integer;
begin
  //
  for i:=0 to FIndicators.Count-1 do
    TIndicator(FIndicators.Items[i]).Add;
  //
  SetDrawRange(rmAdd);

  for i := 0 to FSymbolers.Count-1 do
    if TSymboler(FSymbolers.Items[i]).SymbolerMode = smSub then
      TSymboler(FSymbolers.Items[i]).AddData;

  Refresh;
end;

// last data updated
procedure TChartCentral.DataUpdateProc(Sender : TObject);
var
  i : Integer;
begin
  //
  for i:=0 to FIndicators.Count-1 do
    TIndicator(FIndicators.Items[i]).Update;
  //
  //Refresh(True);

  //per second refresh
  //Refresh;
  Inc(FUpdateCount);
end;

// data revamped
procedure TChartCentral.DataRefreshProc(Sender : TObject);
var
  i : Integer;
begin
  SetDrawRange(rmRefresh);
  //
  ClearStickers;
  //
  for i:=0 to FSymbolers.Count-1 do
    if TSymboler(FSymbolers.Items[i]).SymbolerMode = smSub then
      TSymboler(FSymbolers.Items[i]).RefreshData;

  for i:=0 to FIndicators.Count-1 do
    TIndicator(FIndicators.Items[i]).Refresh(irmHot);
  //
  Refresh;
  //Refresh(True);
end;

procedure TChartCentral.CharterAsyncRefresh(Sender: TObject);
begin
  Refresh;
end;

procedure TChartCentral.CharterAsyncUpdate(Sender: TObject);
var
  aIndicator : TIndicator;
begin
  if Sender = nil then Exit;

  if Sender is TIndicator then
  begin
    aIndicator := Sender as TIndicator;
    aIndicator.Update;
  end;

  //per second refresh
  //Refresh;
  Inc(FUpdateCount);
end;

procedure TChartCentral.CharterAsyncAdd(Sender : TObject);
begin
  Refresh;
end;


// delete charter
procedure TChartCentral.Delete(aCharter : TCharter);
var
  i : Integer;
  aSticker : TSticker;
begin
  if aCharter = nil then Exit;
  //
  if aCharter = FMainCharter then
  begin
    ShowMessage('기본 종목은 삭제할 수 없습니다.');
    Exit;
  end;
  //
  FChartZones.DeleteCharter(aCharter);

  if aCharter is TIndicator then
  begin
    FIndicators.Remove(aCharter);
    // remove connected stickers also
    DetachStickers(aCharter);
  end else
  if aCharter is TSticker then
    FStickers.Remove(aCharter)
  else
  if aCharter is TSymboler then
  begin
    FSymbolers.Remove(aCharter);
    DetachStickers(aCharter);
  end;

  aCharter.Free;
  //
  Refresh;
end;

// charter delete
procedure TChartCentral.CharterDelete(Sender : TObject);
begin
  FChartZones.DeleteCharter(Sender as TCharter);
  FSymbolers.Remove(Sender);
  FIndicators.Remove(Sender);
  //
  Refresh;
end;

// charter move
procedure TChartCentral.CharterMove(Sender : TObject);
var
  aCharter : TCharter;
begin
  aCharter := Sender as TCharter;
  //
  FChartZones.DeleteCharter(aCharter);
  case aCharter.Position of
    cpMainGraph : FChartZones[0].Add(aCharter);
    cpSubGraph : FChartZones.AddCharter(aCharter);
  end;
  //
  Refresh;
end;

//--------------< Public Methods : Config >----------------------//

// 지표설정(목록)
function TChartCentral.ConfigIndicators : Boolean;
var
  i , j : Integer;
  aDlg : TCharterDialog;
  aIndicator : TIndicator;

begin
  Result := False;


  if FIndicators.Count = 0 then Exit;
  //
  {
  if FIndicators.Count = 1 then
    Result := Config(TCharter(FIndicators.Items[0]))
  else
  begin
  }
    aDlg := TCharterDialog.Create(FChartForm);
    try
      for i:=0 to FIndicators.Count-1 do
        aDlg.AddIndicator(FIndicators.Items[i]);


        //aDlg.Indicates.A0dd(FIndicators.Items[i]);
        //aDlg.ListCharters.Items.AddObject(Title, FIndicators.Items[i]);
      //

      aDlg.RefreshList;
      if aDlg.ShowModal = mrOK then
      begin

        aDlg.CopyList( FIndicators );
        for i := 0 to FIndicators.Count - 1 do
          FChartZones.SetZone( i+1, TCharter(FIndicators.Items[i]) );

        Refresh;
        Result := True;
      end else

        for i := 0 to aDlg.DelCharters.Count - 1 do
        begin
          Delete(aDlg.DelCharters.Items[i]);
          //gWin.ModifyWorkspace;
        end;

        aDlg.CopyList( FIndicators );

        j:=0;
        {
        if FChartZones.InTheQuote then
          inc(j);
        }
        for i := 0 to FIndicators.Count - 1 do
        begin
          j := FChartZones.IndexOfCharter( TCharter(FIndicators.Items[i]) );
          if j>=0 then
            FChartZones.SetZone( j, TCharter(FIndicators.Items[i]) );
        end;
        Refresh;

    finally
      aDlg.Free;
    end;
  {
  end;
  }
end;

function TChartCentral.InsertSymbolIndicator: Boolean;
begin
//


end;


function TChartCentral.CreateIndicator(aClass: TIndicatorClass): Boolean;
var
  I: Integer;
  aIndicator : TIndicator;
begin
  Result := false;

  if (aClass = nil) or (FMainCharter = nil) then Exit;

  if (aClass.ClassName = 'TProfitNLoss2') or (aClass.ClassName = 'TProfitNLoss') then
  else
    for I := 0 to FIndicators.Count - 1 do
    begin
      aIndicator := TIndicator( FIndicators.Items[i] );
      if aClass = aIndicator.ClassType then
        Exit;
    end;

  aIndicator := aClass.Create(MainCharter);

  if aIndicator.Config(FChartForm) then
  begin

    if aIndicator.Position = cpMainGraph then
      FChartZones[0].Add(aIndicator)
    else
      FChartZones.AddCharter(aIndicator);
    FIndicators.Add(aIndicator);
    //
    aIndicator.OnAsyncUpdate := CharterAsyncUpdate;
    aIndicator.OnAsyncRefresh := CharterAsyncRefresh;
    aIndicator.OnMove := CharterMove;
    aIndicator.OnDelete := CharterDelete;
    //
    Refresh; // redraw

    Result := True;

  end else
    aIndicator.Free;

  Result := true;


end;


function TChartCentral.CreateIndicator(aPos: TPosition;
  aClass: TIndicatorClass): Boolean;
var
  I: Integer;
  aIndicator : TIndicator;

  FParams : TCollection;
  aParam : TParamItem;
  aPlot : TPlotItem;
begin
  Result := false;

  if (aClass = nil) or (FMainCharter = nil) then Exit;

  try

    aIndicator := aClass.Create(MainCharter);

    FParams := TCollection.Create(TParamItem);
    aIndicator.CloneParams(FParams);

    for i:=0 to FParams.Count-1 do
    begin
      aParam := FParams.Items[i] as TParamItem;
      case aParam.ParamType of
        ptAccount: aParam.AsAccount := aPos.Account.Code;
        ptSymbol:  aParam.AsSymbol  := aPos.Symbol.Code;
      end;
    end;

    aIndicator.AssignParams(FParams);

    if aIndicator.BAccount then
      aIndicator.SetObject;

    aIndicator.Position   := cpSubGraph;
    aIndicator.ScaleType  := stScreen;
    aIndicator.Refresh(irmWarm);

    FChartZones.AddCharter(aIndicator);
    FIndicators.Add(aIndicator);
    //
    aIndicator.OnAsyncUpdate := CharterAsyncUpdate;
    aIndicator.OnAsyncRefresh := CharterAsyncRefresh;
    aIndicator.OnMove := CharterMove;
    aIndicator.OnDelete := CharterDelete;
    //
    Refresh; // redraw

    Result := True;
  finally
    FParams.Free;
  end;

end;



function TChartCentral.CreateShowMe(aItem : TShowMeItem): Boolean;
var
  aAcnt : TAccount;
  i :integer;
  aDlg : TShowMeParamCfg;
begin
  if aItem = nil then Exit;

  aDlg := TShowMeParamCfg.Create( FChartForm );

  try
    if aDlg.Open( aItem ) then
    begin
      aItem := aDlg.ShowMeItem;
      aItem.EnAbled := true;
    end;

  finally
    aDlg.Free;
  end;

  if aItem.SType = snFill then
  begin
    aAcnt := gEnv.Engine.TradeCore.Accounts.Find( aItem.Param );
    Account  := aAcnt;

    if MainCharter <> nil then
    begin
      MainCharter.ShowMeItem  := aItem;
    end;
  end;

  Refresh;
end;

// 지표설정(개별)
function TChartCentral.InsertIndicator : Boolean;
var
  aDlg : TIndicatorDialog;
  aClass : TIndicatorClass;
  aIndicator : TIndicator;
begin
  Result := False;

  aDlg := TIndicatorDialog.Create(FChartForm);
  try

    if aDlg.ShowModal= mrOk then
    begin
      aClass := aDlg.Selected;
      if (aClass = nil) or (FMainCharter = nil) then Exit;
      //
      aIndicator := aClass.Create(MainCharter);

      //-- set default config
      //gWin.LoadClassDefault('Indicators', aIndicator.Title, aIndicator.SetDefault);


      //-- config
      if aIndicator.Config(FChartForm) then
      begin
        //-- save default config
        //gWin.SaveClassDefault('Indicators', aIndicator.Title, aIndicator.GetDefault);

        //
        if aIndicator.Position = cpMainGraph then
          FChartZones[0].Add(aIndicator)
        else
          FChartZones.AddCharter(aIndicator);
        FIndicators.Add(aIndicator);
        //
        aIndicator.OnAsyncUpdate := CharterAsyncUpdate;
        aIndicator.OnAsyncRefresh := CharterAsyncRefresh;
        aIndicator.OnMove := CharterMove;
        aIndicator.OnDelete := CharterDelete;
        //
        Refresh; // redraw

        Result := True;
      end else
        aIndicator.Free;
    end;
  finally
    aDlg.Free;
  end;
end;


// 자료설정(목록)
function TChartCentral.ConfigShowMe: Boolean;
var
  aDlg : TShowMeCfg;
  i : integer;
begin
  Result := false;

  try
    aDlg := TShowMeCfg.Create(FChartForm);
    aDlg.ShowMe := FShowMe;
    aDlg.RefreshList;

    if aDlg.ShowModal = mrOK then
      Result := True;

    for i := 0 to FShowMe.Count - 1 do
      if FShowMe.ShowMe[i].SType = snFill then
      begin
        Account := gEnv.Engine.TradeCore.Accounts.Find( FShowMe.ShowMe[i].Param );
      end;

    Refresh;

  finally
    aDlg.free;
  end;

end;

function TChartCentral.ConfigSymbols : Boolean;
var
  i : Integer;
  aDlg : TCharterDialog;
  aIndicator : TIndicator;
  aPreSymbol : TSymbol;
  aSymbolersDlg : TSymbolersDlg;
begin
  Result := False;

  if FSymbolers.Count = 0 then Exit;
  //
  aPreSymbol := MainCharter.XTerms.Symbol;

  if FSymbolers.Count = 1 then //config single symbol
    Result := Config(TCharter(FSymbolers.Items[0]))
  else
  begin                        //config multi-symbol
    try
      aSymbolersDlg := TSymbolersDlg.Create(FChartForm);
      for i := 0 to FSymbolers.Count-1 do
        aSymbolersDlg.AddSymboler(TSymboler(FSymbolers.Items[i]));

      Result := aSymbolersDlg.Execute;

      for i := 0 to aSymbolersDlg.Deleteds.Count-1 do
        Delete(aSymbolersDlg.Deleteds.Items[i]);
      Refresh;
    finally
      aSymbolersDlg.Free;
    end;
  end;

  //if FSymbolers.Count > 1 then
  //begin
  FChartZones.YRateType := TSymboler(FSymbolers.Items[0]).YRateType;
  FChartZones.ResizeZone;
  Refresh;
  //end;
  //notify to other forms
  {
  if Result and FSymbolSynchronized and
      (aPreSymbol <> MainCharter.XTerms.Symbol) then
    gWin.Synchronize(FChartForm, [MainCharter.XTerms.Symbol]);
  }
end;



// 종목추가(개별)
function TChartCentral.InsertSymbol : Boolean;
var
  i : Integer;
  aSymboler : TSymboler;
  aZone : TChartZone;
begin
  Result := False;
  //
  aSymboler := TSymboler.Create(MainCharter);

  //-- set default config
  // y축 비율만 맞춰준다 
   aSymboler.YRateType  :=   FChartZones.YRateType;
  //-- config
  if aSymboler.Config(FChartForm) then
  begin
    //-- save default config
    //gWin.SaveClassDefault('Symboler', 'Symboler', aSymboler.GetDefault);

    //
    FSymbolers.Add(aSymboler);
    if FSymbolers.Count > 0 then
    begin
      if FSymbolers.Count = 1 then
      begin
        FMainCharter := aSymboler;
        //connect symboler ~ chartcentral
        aSymboler.OnSyncAdd := DataAddProc;
        aSymboler.OnSyncUpdate := DataUpdateProc;
        aSymboler.OnSyncRefresh := DataRefreshProc;
      end else if FSymbolers.Count > 1 then
      begin
        aSymboler.OnMove := CharterMove;
        aSymboler.OnDelete := CharterDelete;
        aSymboler.OnAsyncAdd := CharterAsyncAdd;
        aSymboler.OnAsyncUpdate := CharterAsyncUpdate;
        aSymboler.OnAsyncRefresh := CharterAsyncRefresh;
      end;
      aSymboler.Images := FImageFills;
    end;


    if (aSymboler.SymbolerMode = smSub) and (aSymboler.Position = cpMainGraph) then
      FChartZones[0].Add(aSymboler)
    else begin
      FChartZones.AddCharter(aSymboler);
      {
      if aSymboler.XTerms.Base = cbQuote then
      begin
        aZone := FChartZones.AddCharter(aSymboler);
        aZone.Use2Variable  := true;
        FChartZones.UpdateZone;
        FChartZones.InTheQuote  := true;
      end;
      }
    end;

    FInitialized := True;
    Result := True;
    //
    //-- redraw
    Refresh;
  end else
    aSymboler.Free;
end;

function TChartCentral.GetCanInsertSymbol : Boolean;
begin
  if MainCharter.XTerms.Base = cbTick then
    Result := False
  else
    Result := True;
end;

//-----------------< Public Methods : Mouse Actions >----------------//
        

end.
