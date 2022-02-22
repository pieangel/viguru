unit Symbolers;

interface

uses Classes, Windows, Graphics, Math, SysUtils, Forms, Controls,
     //
     //LogCentral, PriceCentral, WinCentral,      //central
     //
     GleTypes, GleConsts,  CleQuoteBroker,  CleFills, CleStorage,
     CleOrders, CleSymbols, CleAccounts, GleLib,  Shows,
     Charters, XTerms, ChartIF;

type
  { Symbol Chart }
  TSymbolerMode = (smMain, smSub);
  TSymbolChartStyle = (ssOHLC, ssCandle, ssLine);


  TSymboler = class(TSeriesCharter)
  private
    FSymbolerMode : TSymbolerMode;
    FShowFill : Boolean;
    FChartStyle : TSymbolChartStyle;

    FMainSymboler : TSymboler;

    // events
    FOnSyncUpdate : TNotifyEvent;
    FOnSyncRefresh : TNotifyEvent;
    FOnSyncAdd : TNotifyEvent;

    //for save/load workspace
    FWorkspaceSymbol : TSymbol;
    FShowMeItem: TShowMeItem;
    FYRateType: TYRateType;
    FRlLowLineColor: TColor;
    FLowLineColor: TColor;
    FRlHighLineColor: TColor;
    FHighLineColor: TColor;
    FCustomLIneColor : TColor;

    FUseLowLine: boolean;
    FUseRlHighLine: boolean;
    FUseHighLine: boolean;
    FUseRlLowLine: boolean;
    FUseCustomLine : boolean;
    FCustomLineValue: double;

    procedure UpdateLastPrice;
    procedure SetZero;
    procedure CheckMinMax(var dMin, dMax: double);

  protected
    // drawing factors
    FScaleType: TScaleType;
    FChartColor : TColor;
    FBkColor : TColor;
    FImages : TImageList;

    // created object
    FXTerms : TXTerms;
    FDataTerms : TXTerms;
    //
    FUsedSymbols : TList;

    //
    function GetTitle : String; override;
    procedure RegulateYScale(var dStep : Double); override;

    // DataXTerms event handler 
    procedure DataAddProc(Sender : TObject);
    procedure DataRefreshProc(Sender : TObject);
    procedure DataUpdateProc(Sender : TObject);
  public
    constructor Create(aMainSymbol : TSymboler);
    destructor Destroy; override;

    // persistence
    procedure SetPersistence(aBitStream : TMemoryStream);
    procedure GetPersistence(aBitStream : TMemoryStream);

    // default config
    procedure SetDefault(iVersion : Integer; stKey : String; Stream : TMemoryStream);
    procedure GetDefault(iVersion : Integer; stKey : String; Stream : TMemoryStream);

    // set
    function Config(aForm : TForm) : Boolean; override;
    procedure SetSymbol(aSymbol : TSymbol);

    // get status
    function GetDataCount : Integer; override;
    procedure GetMinMax(iStart, iEnd : Integer); override;
    procedure GetMinMax2(iStart, iEnd : Integer); override;

    procedure GetMinMaxEx(iStart, iEnd : Integer; var dMin, dMax : Double); override;
    procedure GetMinMaxEx2(iStart, iEnd : Integer; var dMin, dMax : Double); override;

    // check position
    function GetDateTimeDesc(iBarIndex : Integer) : String; override;
    function SpotData(iBarIndex : Integer) : String; override;
    procedure HintData(iBarIndex : Integer; stHints : TStringList); override;
    function Hit(const iHitX, iHitY : Integer; const aRect : TRect;
      const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean; override;

    // drawing routines
    procedure Draw(const aCanvas : TCanvas; const aRect : TRect;
                   const iStart, iEnd, iBarWidth : Integer;
                   const bSelected : Boolean  ); override;
    procedure Draw2(const aCanvas : TCanvas; const aRect : TRect;
                   const iStart, iEnd, iBarWidth : Integer;
                   const bSelected : Boolean  ); override;
    procedure DrawTitle(const aCanvas : TCanvas; const aRect : TRect;
                        var iLeft : Integer; bSelected : Boolean); override;
    procedure DrawXScale(const aCanvas : TCanvas; const aRect : TRect;
                         const iStart, iEnd, iBarWidth : Integer;
                         const bLine : Boolean; const aLineColor : TColor); override;


    // handles data in sub mode
    procedure RefreshData;
    procedure AddData;

    // handle fill data
    procedure GetFill;
    procedure ClearFill;

    procedure LoadEnv(aStorage: TStorage; bMain : boolean = true; index : integer = 0);
    procedure SaveEnv(aStorage: TStorage; bMain : boolean = true; index : integer = 0);

    // status
    property SymbolerMode : TSymbolerMode read FSymbolerMode; 
    property ShowFill : Boolean read FShowFill write FShowFill;

    // drawing attributes
    property ScaleType : TScaleType read FScaleType write FScaleType;
    property ChartStyle : TSymbolChartStyle read FChartStyle write FChartStyle;
    property YRateType : TYRateType read FYRateType write FYRateType;
    property ChartColor : TColor read FChartColor write FChartColor;
    property BkColor : TColor read FBkColor write FBkColor;
    property Images : TImageList read FImages write FImages;
      // add sttributes
    property HighLineColor  : TColor read FHighLineColor write FHighLineColor;
    property LowLineColor   : TColor read FLowLineColor write FLowLineColor;
    property RlHighLineColor: TColor read FRlHighLineColor write FRlHighLineColor;
    property RlLowLineColor : TColor read FRlLowLineColor write FRlLowLineColor;
    property CustomLIneColor : TColor read FCustomLIneColor write FCustomLIneColor;

    property UseHighLine  : boolean read FUseHighLine write FUseHighLine;
    property UseLowLine   : boolean read FUseLowLine  write FUseLowLine;
    property UseRlHighLine: boolean read FUseRlHighLine write FUseRlHighLine;
    property UseRlLowLine : boolean read FUseRlLowLine  write FUseRlLowLine;
    property UseCustomLine: boolean read FUseCustomLine write FUseCustomLine;
    property CustomLineValue : double read FCustomLineValue write FCustomLineValue;

    // created objects
    property XTerms : TXTerms read FXTerms;
    property DataXTerms : TXTerms read FDataTerms;
    property UsedSymbols : TList read FUsedSymbols;
    property ShowMeItem : TShowMeItem read FShowMeItem write FShowMeItem;

    // assigned objects
    property MainSymboler : TSymboler read FMainSymboler; // assigned in create()

    // events
    property OnSyncUpdate : TNotifyEvent read FOnSyncUpdate write FOnSyncUpdate;
    property OnSyncRefresh : TNotifyEvent read FOnSyncRefresh write FOnSyncRefresh;
    property OnSyncAdd : TNotifyEvent read FOnSyncAdd write FOnSyncAdd;

  end;


implementation

uses DSymbolerCfg, GAppEnv, CleFQN, ChartCentral;

{ TSymboler }

//===========================< Create / Destroy >========================//

constructor TSymboler.Create(aMainSymbol : TSymboler);
begin
  if aMainSymbol = nil then
  begin
    FMainSymboler := Self;
    FSymbolerMode := smMain;
    FPosition := cpMainGraph;
  end else
  begin
    FMainSymboler := aMainSymbol;
    FSymbolerMode := smSub;
    FPosition := cpSubGraph;
  end;
  FShowFill := (FSymbolerMode = smMain);

  //create main&sub XTerms
  FXTerms := TXTerms.Create;

  if FSymbolerMode = smMain then
    FDataTerms := FXTerms
  else
    FDataTerms := TXTerms.Create;

  //connect
  FDataTerms.OnAdd := DataAddProc;
  FDataTerms.OnUpdate := DataUpdateProc;
  FDataTerms.OnRefresh := DataRefreshProc;

  FUsedSymbols := TList.Create;

  //-- initial setting
  FWorkspaceSymbol := nil;
  FChartStyle := ssOHLC;
  FScaleType := stScreen;
  FChartColor := clAqua;
  CrosChart   := false;
  YRateType   := yrDefault;

  FRlHighLineColor  := clRed;
  FRlLowLineColor   := clBlue;

  FCustomLineValue := 0;

end;

destructor TSymboler.Destroy;
begin
  FUsedSymbols.Free;

  FXTerms.Free;

  if FSymbolerMode = smSub then
    FDataTerms.Free;

  inherited;
end;

//=============================< Persistency >===========================//

procedure TSymboler.SetPersistence(aBitStream : TMemoryStream);
var
  szBuf : array[0..20] of Char;
  stSymbol : String;
  aSymbol : TSymbol;
begin
  aBitStream.Read(FChartStyle, SizeOf(TSymboLChartStyle));
  aBitStream.Read(FChartColor, SizeOf(TColor));
  aBitStream.Read(FBkColor, SizeOf(TColor));

  //if gWin.LoadingWorkspaceVersion >= 21 then
  //begin
    aBitStream.Read(FPosition, SizeOf(TCharterPosition));
    aBitStream.Read(FScaleType, SizeOf(TScaleType));
    aBitStream.Read(FShowFill, SizeOf(Boolean));
  //end;

  if FSymbolerMode = smMain then
    FXTerms.SetPersistence(aBitStream)
  else
  begin
    //get saved symbol
    aBitStream.Read(szBuf, 20);
    stSymbol := szBuf;
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stSymbol );

    FWorkspaceSymbol := aSymbol;
  end;

end;

procedure TSymboler.GetPersistence(aBitStream : TMemoryStream);
var
  szBuf : array[0..20] of Char;
begin
  aBitStream.Write(FChartStyle, SizeOf(TSymboLChartStyle));
  aBitStream.Write(FChartColor, SizeOf(TColor));
  aBitStream.Write(FBkColor, SizeOf(TColor));

  //new
  aBitStream.Write(FPosition, SizeOf(TCharterPosition));
  aBitStream.Write(FScaleType, SizeOf(TScaleType));
  aBitStream.Write(FShowFill, SizeOf(Boolean));

  if FSymbolerMode = smMain then
    FXTerms.GetPersistence(aBitStream)
  else
  begin
    if FDataTerms.Symbol = nil then
      StrPCopy(szBuf, #0)
    else
      StrPCopy(szBuf, FDataTerms.Symbol.Code);

    aBitStream.Write(szBuf, 20);
  end;

end;

//===========================< Default Config >==============================//

procedure TSymboler.SaveEnv(aStorage: TStorage; bMain : boolean; index : integer);
var
  stPre : string;
begin
  stPre := ifThenStr( bMain , 'Main', 'Sub' );
  if bMain then
    index := 100;

  aStorage.FieldByName(stPre+'ChartStyle'+IntTostr(index)).AsInteger := Integer( FChartStyle );
  aStorage.FieldByName(stPre+'ChartColor'+IntTostr(index)).AsInteger := TColor( FChartColor );
  aStorage.FieldByName(stPre+'BkColor'+IntTostr(index)).AsInteger := TColor( FBkColor );
  aStorage.FieldByName(stPre+'YRateType'+IntToStr(index)).AsInteger := integer(FYRateType);

  aStorage.FieldByName(stPre+'Position'+IntTostr(index)).AsInteger := Integer(FPosition);
  aStorage.FieldByName(stPre+'ScaleType'+IntTostr(index)).AsInteger := Integer(FScaleType);
  aStorage.FieldByName(stPre+'ShowFill'+IntTostr(index)).AsBoolean := FShowFill;

  aStorage.FieldByName(stPre+'UseRlHighLine'+IntTostr(index)).AsBoolean := FUseRlHighLine;
  aStorage.FieldByName(stPre+'UseRlLowLine'+IntTostr(index)).AsBoolean := FUseRlLowLine;
  aStorage.FieldByName(stPre+'UseCustomLine'+IntTostr(index)).AsBoolean := FUseCustomLine;

  aStorage.FieldByName(stPre+'RlHighLineColor'+IntTostr(index)).AsInteger := TColor(FRlHighLineColor);
  aStorage.FieldByName(stPre+'RlLowLineColor'+IntTostr(index)).AsInteger := TColor(FRlLowLineColor);
  aStorage.FieldByName(stPre+'CustomLineColor'+IntTostr(index)).AsInteger := TColor(FCustomLineColor);

  aStorage.FieldByName(stPre+'CustomLineValue'+IntToStr(index)).AsFloat   := FCustomLineValue;

  if FSymbolerMode = smMain then
    FXTerms.SaveEnv( aStorage, bMain )
  else begin
    if FdataTerms.Symbol <> nil then
      aStorage.FieldByName(stPre+'dataTerms.Symbol'+IntTostr(index)).AsString := FdataTerms.Symbol.Code;
  end;
end;

procedure TSymboler.LoadEnv(aStorage: TStorage; bMain : boolean; index : integer);
var
  stPre, stSymbol : string;
  aSymbol : TSymbol;
begin
  stPre := ifThenStr( bMain , 'Main', 'Sub' );
  if bMain then
    index := 100;

  FYRateType  := TYRateType(aStorage.FieldByName(stPre+'YRateType'+IntToStr(index)).AsInteger);
  FChartStyle := TSymboLChartStyle( aStorage.FieldByName(stPre+'ChartStyle'+IntTostr(index)).AsInteger);
  FChartColor := TColor( aStorage.FieldByName(stPre+'ChartColor'+IntTostr(index)).AsInteger);
  FBkColor  := TColor( aStorage.FieldByName(stPre+'BkColor'+IntTostr(index)).AsInteger);

  FPosition := TCharterPosition( aStorage.FieldByName(stPre+'Position'+IntTostr(index)).AsInteger );
  FScaleType  := TScaleType( aStorage.FieldByName(stPre+'ScaleType'+IntTostr(index)).AsInteger);
  FShowFill := aStorage.FieldByName(stPre+'ShowFill'+IntTostr(index)).AsBoolean;

  FUseRlHighLine  := aStorage.FieldByName(stPre+'UseRlHighLine'+IntTostr(index)).AsBoolean ;
  FUseRlLowLine   := aStorage.FieldByName(stPre+'UseRlLowLine'+IntTostr(index)).AsBoolean;
  FUseCustomLine  := aStorage.FieldByName(stPre+'UseCustomLine'+IntTostr(index)).AsBoolean;

  FRlHighLineColor  := TColor(aStorage.FieldByName(stPre+'RlHighLineColor'+IntTostr(index)).AsInteger);
  FRlLowLineColor   := TColor(aStorage.FieldByName(stPre+'RlLowLineColor'+IntTostr(index)).AsInteger);
  FCustomLineColor  := TColor(aStorage.FieldByName(stPre+'CustomLineColor'+IntTostr(index)).AsInteger);

  FCustomLineValue  := aStorage.FieldByName(stPre+'CustomLineValue'+IntToStr(index)).AsFloat ;

  if FSymbolerMode = smMain then
    FXTerms.LoadEnv( aStorage, bMain )
  else begin
    stSymbol := aStorage.FieldByName(stPre+'dataTerms.Symbol'+IntTostr(index)).AsString;
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stSymbol );

    if aSymbol <> nil then
    begin
    FWorkspaceSymbol := aSymbol;
    DataXTerms.Define( aSymbol,
      MainSymboler.XTerms.Base,
      MainSymboler.XTerms.Period,
      MainSymboler.XTerms.Count);

    XTerms.Symbol := aSymbol;
    XTerms.Base := MainSymboler.XTerms.Base;
    XTerms.Period := MainSymboler.XTerms.Period;
    Precision := aSymbol.Spec.Precision;
    end;
  end;
end;

procedure TSymboler.SetDefault(iVersion : Integer; stKey : String; Stream : TMemoryStream);
begin
  Stream.Read(FChartStyle, SizeOf(TSymbolChartStyle));
  Stream.Read(FChartColor, SizeOf(TColor));
  Stream.Read(FBkColor, SizeOf(TColor));
  Stream.Read(FPosition, SizeOf(TCharterPosition));
  Stream.Read(FScaleType, SizeOf(TScaleType));
  // Stream.Read(FShowFill, SizeOf(Boolean));
end;

procedure TSymboler.GetDefault(iVersion : Integer; stKey : String; Stream : TMemoryStream);
begin
  Stream.Write(FChartStyle, SizeOf(TSymbolChartStyle));
  Stream.Write(FChartColor, SizeOf(TColor));
  Stream.Write(FBkColor, SizeOf(TColor));
  Stream.Write(FPosition, SizeOf(TCharterPosition));
  Stream.Write(FScaleType, SizeOf(TScaleType));
  // Stream.Write(FShowFill, SizeOf(Boolean));
end;

//===========================< Config >==============================//

function TSymboler.Config(aForm : TForm) : Boolean;
var
  i : Integer;
  aDlg : TSymbolerConfig;
  aPosition : TCharterPosition;
  bShowFill : Boolean;
begin
  Result := False;
  //
  aDlg := TSymbolerConfig.Create(aForm);
  try
    aPosition := Position;
    bShowFill := FShowFill;

    for i:=0 to FUsedSymbols.Count-1 do
      aDlg.AddUsedSymbol(TSymbol(FUsedSymbols.Items[i]));
    //
    Result := aDlg.Execute(Self);

    //-- set default config
    {
    if Result then
      gWin.SaveClassDefault('Symboler', 'Symboler', GetDefault);
    }
    if Result and (FUsedSymbols.IndexOf(FXTerms.Symbol) < 0) then
      FUsedSymbols.Insert(0, FXTerms.Symbol);

    if Result and (Position <> aPosition) and Assigned(FOnMove) then
      FOnMove(Self);

    if Result and (FSymbolerMode = smSub) and (FShowFill <> bShowFill) then
    begin
      if FShowFill then
        GetFill
      else
        ClearFill;
    end;
  finally
    aDlg.Free;
  end;
end;

//===========================< Get Status >============================//

function TSymboler.GetTitle : String;
begin
  if FXTerms.Symbol <> nil then
  begin
    Result := Trim(FXTerms.Symbol.ShortCode) + '-' + IntToStr(FXTerms.Period);
    case FXTerms.Base of
      cbTick    : Result := Result + '틱';
      cbMin     : Result := Result + '분';
      cbQuote   : Result := Result + '쿼트';
      cbDaily   : Result := Result + '일';
      cbWeekly  : Result := Result + '주';
      cbMonthly : Result := Result + '월';
    end;
  end else
    Result := '종목챠트';
end;

function TSymboler.GetDataCount : Integer;
begin
  Result := FXTerms.Count;
end;

procedure TSymboler.CheckMinMax( var dMin, dMax : double );
var
  aOpt : TOption;
begin
  if not (FXTerms.Symbol is TOption) then Exit
  else aOpt := FXTerms.Symbol as TOption;

  if FUseRlHighLine then
  begin
    if (aOpt.RelativeHigh - 0.001) > dMax then
      dMax  := aOpt.RelativeHigh
    else if (aOpt.RelativeHigh + 0.001) < dmin then
      dMin  := aOpt.RelativeHigh;
  end;

  if FUseRlLowLine then
  begin
    if (aOpt.RelativeLow + 0.001) < dMin then
      dMin  := aOpt.RelativeLow
    else if ( aOpt.RelativeLow - 0.001) > dMax then
      dMax  := aOpt.RelativeLow;
  end;

  if FUseCustomLine then
  begin
    if (FCustomLineValue + 0.001) < dMin then
      dMin  := FCustomLineValue
    else if ( FCustomLineValue - 0.001) > dMax then
      dMax  := FCustomLineValue;
  end;

end;

procedure TSymboler.GetMinMax(iStart, iEnd : Integer);
var
  dMin, dMax, dMargin : Double;
begin
  //-- get min/max
  if FScaleType = stScreen then
    FXTerms.GetMinMax(iStart, iEnd, dMin, dMax)
  else
  if FScaleType = stEntire then
    FXTerms.GetMinMax(0, FXTerms.Count-1, dMin, dMax)
  else
    Exit;
  //--
  CheckMinMax(dMin, dMax );
  dMargin := (dMax - dMin) * 0.05;
  if Abs(dMargin) < EPSILON then Exit;
  dMax := dMax + dMargin;
  dMin := dMin - dMargin;
  //-- save
  FMin := dMin;
  FMax := dMax;
end;

procedure TSymboler.GetMinMax2(iStart, iEnd: Integer);
var
  dMin, dMax, dMargin : Double;
begin
  //-- get min/max
  if FScaleType = stScreen then
    FXTerms.GetMinMax2(iStart, iEnd, dMin, dMax)
  else
  if FScaleType = stEntire then
    FXTerms.GetMinMax2(0, FXTerms.Count-1, dMin, dMax)
  else
    Exit;
  //--
  dMargin := (dMax - dMin) * 0.05;
  if Abs(dMargin) < EPSILON then Exit;
  dMax := dMax + dMargin;
  dMin := dMin - dMargin;
  //-- save
  FMin2 := dMin;
  FMax2 := dMax;

end;

procedure TSymboler.GetMinMaxEx(iStart, iEnd: Integer; var dMin, dMax: Double);
var
  dMargin : Double;
begin
  //-- get min/max
  if FScaleType = stScreen then
    FXTerms.GetMinMax(iStart, iEnd, dMin, dMax)
  else
  if FScaleType = stEntire then
    FXTerms.GetMinMax(0, FXTerms.Count-1, dMin, dMax)
  else
    Exit;
  //--
  dMargin := (dMax - dMin) * 0.05;
  if Abs(dMargin) < EPSILON then Exit;
  dMax := dMax + dMargin;
  dMin := dMin - dMargin;
end;

procedure TSymboler.GetMinMaxEx2(iStart, iEnd: Integer; var dMin, dMax: Double);
var
  dMargin : Double;
begin
  //-- get min/max
  if FScaleType = stScreen then
    FXTerms.GetMinMax2(iStart, iEnd, dMin, dMax)
  else
  if FScaleType = stEntire then
    FXTerms.GetMinMax2(0, FXTerms.Count-1, dMin, dMax)
  else
    Exit;
  //--
  dMargin := (dMax - dMin) * 0.05;
  if Abs(dMargin) < EPSILON then Exit;
  dMax := dMax + dMargin;
  dMin := dMin - dMargin;
end;

//=========================< Drawing Routines >=========================//

procedure TSymboler.DrawXScale(const aCanvas : TCanvas; const aRect : TRect;
                           const iStart, iEnd, iBarWidth : Integer;
                           const bLine : Boolean; const aLineColor : TColor);
var
  i, iLeft, iX, iY, iStep, iBase, iWidth : Integer;
  aSize : TSize;
  stText : String;
  aXTerm : TXTermItem;
  aStyle : TPenStyle;
  aAxisColor : TCOlor;
  wYY, wMM, wDD, wHH, wNN, wSS, wCC,
  wYYOld, wMMOld, wDDOld, wHHOld : Word;
  cbValue : TChartBase;
  bSeparator : Boolean;
begin
  //
  aStyle := aCanvas.Pen.Style;
  aAxisColor := aCanvas.Pen.Color;
  //
  iY := aRect.Bottom+5;
  iStep := 50 div iBarWidth;
  //
  iLeft := aRect.Left;
  iWidth := 0;
  iBase := iStart;
  wMMOld := 0;
  wDDOld := 0;
  //
  cbValue := FXTerms.Base;
  //
  for i:=iStart to iEnd do
  begin
    if FXTerms[i] = nil then Continue;
    DecodeDate(FXTerms[i].StartTime, wYY, wMM, wDD);
    DecodeTime(FXTerms[i].StartTime, wHH, wNN, wSS, wCC);
    //-- Date Seperator?
    case cbValue of
      cbTick, cbQuote: bSeparator := (wHH <> wHHOld);
      cbMin : bSeparator := (wYY <> wYYOld) or (wMM <> wMMOld) or (wDD <> wDDOld);
      cbDaily : bSeparator := (wYY <> wYYOld) or (wMM <> wMMOld);
      cbWeekly,
      cbMonthly : bSeparator := (wYY <> wYYOld);
    end;

    if bSeparator then
    begin
      // Date Separator
      aCanvas.Pen.Style := psDot;
      aCanvas.Pen.Color := aAxisColor;
      aCanvas.Pen.Width := 1;
      //
      case cbValue of
        cbTick, cbQuote :    stText := IntToStr(wHH)+ 'i';
        cbMin :     stText := IntToStr(wMM) + '/' + IntToStr(wDD);
        cbDaily :   stText := IntToStr(wYY) + '/' + IntToStr(wMM);
        cbWeekly,
        cbMonthly : stText := IntToStr(wYY);
      end;

      aSize := aCanvas.TextExtent(stText);
      //
      iX := aRect.Left + (i-iStart) * iBarWidth;
      //-- delete a scale preceded
      if (iLeft + iWidth) >= iX then
        aCanvas.FillRect(Rect(iLeft, iY, iLeft+iWidth, iY + aSize.cy));
      //-- date line
      if wDDOld <> 0 then
      begin
        aCanvas.MoveTo(iX, aRect.Top);
        aCanvas.LineTo(iX, aRect.Bottom);
        iBase := i;
      end;
      //-- put date text
      aCanvas.TextOut(iX, iY, stText);
      iLeft := iX;
      iWidth := aSize.cx;
      //
      wYYOld := wYY;
      wMMOld := wMM;
      wDDOld := wDD;
      wHHOld := wHH;
    end;
    //
    if (i <> iBase) and ((i-iBase) mod iStep = 0) then
    begin
      iX := aRect.Left + (i-iStart)*iBarWidth;
      //
      case cbValue of
        cbTick, cbQuote :    stText := FormatDateTime('nn:ss', FXTerms[i].StartTime);
        cbMin :     stText := FormatDateTime('hh:nn', FXTerms[i].StartTime);
        cbDaily :   stText := IntToStr(wDD);
        cbWeekly :  stText := IntToStr(wMM)+'/'+IntToStr(wDD);
        cbMonthly : stText := IntToStr(wMM);
      end;

      aSize := aCanvas.TextExtent(stText);
      //
      aCanvas.Pen.Style := psSolid;
      aCanvas.Pen.Color := aAxisColor;
      aCanvas.Pen.Width := 1;
      //
      aCanvas.MoveTo(iX, aRect.Bottom);
      aCanvas.LineTo(iX, iY);
      //
      if bLine then
      begin
        aCanvas.Pen.Style := psDot;
        aCanvas.Pen.Color := aLineColor;
        aCanvas.Pen.Width := 1;
        //
        aCanvas.MoveTo(iX, aRect.Top);
        aCanvas.LineTo(iX, aRect.Bottom);
      end;
      //
      aCanvas.TextOut(iX, iY, stText);
      //
      iLeft := iX;
      iWidth := aSize.cx;
    end;
  end;
  //
  aCanvas.Pen.Style := aStyle;
  aCanvas.Pen.Color := aAxisColor;
end;

procedure TSymboler.RegulateYScale(var dStep : Double);
var
  dUnit : Double;
begin
  if FXTerms.Symbol = nil then Exit;

  case FXterms.Symbol.UnderlyingType of
    utKospi200, utKosdaq50 :
            case FXTerms.Symbol.Spec.Market of
              mtIndex : dUnit := 0.01;
              mtFutures : dUnit := 0.05;
              mtOption : dUnit := 0.01;
              else dUnit := 0.01;
            end;
    utStock :
            dUnit := FXTerms.Symbol.Spec.TickValue;
    else
            dUnit := 0.01;
  end;

  dStep := Max(dUnit, dStep);
end;


procedure TSymboler.DrawTitle(const aCanvas : TCanvas; const aRect : TRect;
                                   var iLeft : Integer; bSelected : Boolean);
var
  stTitle : String;
  aSize : TSize;
  aFontColor : TColor;
  aFontStyle : TFontStyles;
  aQuote  : TQuote;
begin
  if XTerms.Symbol = nil then Exit;
  //
  aQuote := XTerms.Symbol.Quote as TQuote;
  if aQuote = nil then Exit;


  aFontColor := aCanvas.Font.Color;
  aFontStyle := aCanvas.Font.Style;


  if XTerms.Base = cbQuote then
  begin

    stTitle := GetTitle + Format(' C=%.*f(%.*f) O=%.*f H=%.*f L=%.*f Ask=%.*f Bid=%.*f V=%.0n',
                         [XTerms.Symbol.Spec.Precision, aQuote.Last,
                          XTerms.Symbol.Spec.Precision, aQuote.Change,
                          XTerms.Symbol.Spec.Precision, aQuote.Open,
                          XTerms.Symbol.Spec.Precision, aQuote.High,
                          XTerms.Symbol.Spec.Precision, aQuote.Low,
                          XTerms.Symbol.Spec.Precision, aQuote.Asks[0].Price,
                          XTerms.Symbol.Spec.Precision, aQuote.Bids[0].Price,
                          aQuote.DailyVolume * 1.0])

  end
  else

  //
  stTitle := GetTitle + Format(' C=%.*f(%.*f) O=%.*f H=%.*f L=%.*f V=%.0n',
                           [XTerms.Symbol.Spec.Precision, aQuote.Last,
                            XTerms.Symbol.Spec.Precision, aQuote.Change,
                            XTerms.Symbol.Spec.Precision, aQuote.Open,
                            XTerms.Symbol.Spec.Precision, aQuote.High,
                            XTerms.Symbol.Spec.Precision, aQuote.Low,
                            aQuote.DailyVolume * 1.0]);


//  stTitle := GetTitle + Format(' 종가=%.2f 전일대비=%.2f',
//                            [XTerms.Symbol.C, XTerms.Symbol.Change]);
  //
  aCanvas.Font.Color := FChartColor;
  if bSelected then
    aCanvas.Font.Style := aCanvas.Font.Style + [fsBold];
  //   
  aSize := aCanvas.TextExtent(stTitle);
  aCanvas.TextOut(iLeft+5, aRect.Top - aSize.cy, stTitle);
//  aCanvas.TextRect(Rect(aRect.Left,aRect.Top-aSize.cy, aRect.Right, aRect.Top),
//                   iLeft+5, aRect.Top - aSize.cy, stTitle);
  //
  iLeft := iLeft + 5 + aSize.cx;
  //
  aCanvas.Font.Color := aFontColor;
  aCanvas.Font.Style := aFontStyle;
end;

procedure TSymboler.Draw(const aCanvas : TCanvas; const aRect : TRect;
          const iStart, iEnd, iBarWidth : Integer; const bSelected : Boolean );
const
  SEL_WIDTH = 3;
  WING_WIDTHS : array[1..14] of Integer = (1,1,1,1,1,1,2,2,2,3,3,4,4,5);
var
  lAvgPrc, sAvgPrc, dRY : Double;
  i, j,
  iStep, iCnt, // for drawing selected
  sVol, lVol,
  iX, iY, iCenter, iWingWidth,
  iYO, iYC, iYL, iYH : Integer;
  stText : String;
  aSize : TSize;
  iLCount, iSCount : Integer;
  aBrushColor, aFontColor, aPenColor : TColor;
  aPenMode : TPenMode;
  aFill : TFill;
  aPoint : TPoint;
  aItem : TShowMeItem;
  aOpt : TOption;

  procedure DrawFill(iOffset : Integer; ttValue : TPositionType; iQty : Integer;
    dPrice : Double);
  const
    IMG_INDICES : array[TPositionType] of Integer = (0,2{,1,3});
  var
    iYTxt, iYImg, iYPrice, iXImg, iYOffset : Integer;
    aColor, aColor2 : TColor;
    stText : String;
    aSize : TSize;
  begin
    stText := IntToStr(iQty);
    aSize := aCanvas.TextExtent(stText);
    iYOffset := aSize.cy + FImages.Height + 2;
    // position
    iXImg := iCenter - FImages.Width div 2;
    case ttValue of
      ptLong:
        begin
          iYImg := iYL + 1 + (aItem.OffSet-1)*iYOffset;
          iYTxt := iYImg + 1 + FImages.Height;
        end;
      ptShort :
        begin
          iYImg := iYH - 1 - FImages.Height - (aItem.OffSet-1)*iYOffset;
          iYTxt := iYImg - 1 - aSize.cy;
        end;
    end;
    // color
    case ttValue of
      ptLong : aColor := aItem.BidColor;
      ptShort : aColor :=aItem.AskColor;
    end;
    // fill price
    iYPrice := aRect.Bottom - Round((dPrice-FMin)*dRY);
    case ttValue of
      ptLong : aColor2 := aItem.BidColor;
      ptShort : aColor2 := aItem.AskColor;
    end;
    aCanvas.Pen.Color := aColor2;
    aCanvas.Polygon([Point(iCenter, iYPrice),
                     Point(iCenter-2, iYPrice-2),
                     Point(iCenter-2, iYPrice+2)]);
    // fill symbol
    FImages.Draw(aCanvas, iXImg, iYImg, IMG_INDICES[ttValue]);
    // fill qty
    aCanvas.Brush.Color := aBrushColor;
    aCanvas.Font.Color := clWhite;
    aCanvas.TextOut(iCenter - aSize.cx div 2, iYTxt, stText);
  end;


  procedure DrawFills( aTerm : TXTermItem );
  var
    j : integer;
  begin
    aItem := FShowMeItem;
    if aItem = nil then Exit;
    if not aItem.EnAbled then Exit;

    with aTerm do
    begin
      iX := (i-iStart)*iBarWidth + aRect.Left+1;
      iCenter := iX + iWingWidth;
      // Open
      iYO := aRect.Bottom - Round((O - FMin)*dRY);
      iYH := aRect.Bottom - Round((H - FMin)*dRY);
      iYL := aRect.Bottom - Round((L - FMin)*dRY);
      iYC := aRect.Bottom - Round((C - FMin)*dRY);
      //
      iLCount := 0; iSCount := 0;
      lVol  := 0; sVol  := 0;
      sAvgPrc := 0; lAvgPrc := 0;
      //

      if Fills = nil then Exit;

      for j:=0 to Fills.Count-1 do
      begin
        aFill := TFill(Fills.Items[j]);

        if aFill.Volume > 0 then
        begin
          Inc(iLCount);
          inc( lVol, aFill.Volume );
          lAvgPrc := ( lAvgPrc * (lVol -  aFill.Volume ) +
                aFill.Price * aFill.Volume ) / lVol;
        end else
        if aFill.Volume < 0 then
        begin
          Inc(iSCount);
          inc( sVol, abs(aFill.Volume) );
          sAvgPrc := ( sAvgPrc * (sVol - abs( aFill.Volume ))  +
              aFill.Price * abs(aFill.Volume)) / sVol;
        end;
      end;

      LongFill  := lAvgPrc;
      ShortFill := sAvgPrc;

      if iLCount > 0 then
        DrawFill(1, ptLong, lVol, lAvgPrc);
      if iSCount > 0 then
        DrawFill(1, ptShort, sVol, sAvgPrc);
    end;
  end;

  procedure DrawHLine( dPrice : double; aColor : TColor; stName : string );
  var
    iTmp : integer;
  begin
    with aCanvas do
    begin
      iYC := aRect.Bottom - Round((dPrice - FMin)*dRY);
      if (iYC > aRect.Top) and (iYC < aRect.Bottom) then
      begin
        Pen.Color := aColor;
        MoveTo(aRect.Left+1, iYC);
        LineTo(aRect.Right, iYC);
      end;

      iTmp := Font.Size;
      Font.Color := clWhite;
      Font.Size  := 9;
      stText := Format('%s %.2f', [stName, dPrice]);
      aSize := TextExtent(stText);
      iX := aRect.Right - aSize.cx -5;
      iYC := iYC - aSize.cy - 1;
      TextOut(iX, iYC, stText);
      Font.Size := iTmp;
    end;
  end;

begin
  // unacceptable condition
  if (iStart > iEnd) or
     (iStart < 0) or (iStart >= FXTerms.Count) or
     (iEnd < 0) or (iEnd >= FXTerms.Count) then Exit;
  //-- Ratio
  if Abs(FMax-FMin) < ZERO then Exit;
  //
  dRY := (aRect.Bottom - aRect.Top)/(FMax - FMin);
  //--
  if (iBarWidth >=1) and (iBarWidth <= 14) then
    iWingWidth := WING_WIDTHS[iBarWidth]
  else
    iWingWidth := Round(iBarWidth / 2 * 0.67);
  {
  if iBarWidth <= 5 then
    iWingWidth := 1
  else
    iWingWidth := Round(iBarWidth / 2 * 0.67);
  }
  iStep := 50 div iBarWidth;
  iCnt := 0;
  //--
  aBrushColor := aCanvas.Brush.Color;
  aFontColor := aCanvas.Font.Color;
  aPenColor := aCanvas.Pen.Color;
  //-- bar
  case FChartStyle of
    ssLine :
      begin


          for i:=iStart to iEnd do
          with XTerms.Items[i] as TXTermItem do
          begin
            aCanvas.Pen.Color := FChartColor;
            aCanvas.Pen.Width := 1;
            iX := (i-iStart)*iBarWidth + aRect.Left+1;
            iYC := aRect.Bottom - Round((C - FMin)*dRY);
            if i > iStart then
            begin
              if Valid then
                aCanvas.LineTo(iX, iYC)
              else
              begin
                aPoint := aCanvas.PenPos;
                aCanvas.MoveTo(iX, aPoint.y);
              end;
            end else
              aCanvas.MoveTo(iX, iYC);

            // selected
            if bSelected then
            begin
              Inc(iCnt);
              if iCnt mod iStep = 0 then
              begin
                aPenMode := aCanvas.Pen.Mode;
                aCanvas.Brush.Color := clWhite;
                aCanvas.Pen.Mode := pmXOR;
                aCanvas.Pen.Color := clWhite;
                aCanvas.Rectangle(
                    Rect(iX-SEL_WIDTH, iYC-SEL_WIDTH, iX+SEL_WIDTH, iYC+SEL_WIDTH));
                aCanvas.Pen.Mode := aPenMode;
              end;
            end;

            if FImages <> nil then
              DrawFills( XTerms.Items[i] as TXTermITem );
          end;

        if FXTerms.Base = cbQuote then
          for i:=iStart to iEnd do
          with XTerms.Items[i] as TXTermItem do
          begin
            aCanvas.Pen.Color := clRed;
            aCanvas.Pen.Width := 1;
            iX := (i-iStart)*iBarWidth + aRect.Left+1;
            iYC := aRect.Bottom - Round((C2 - FMin)*dRY);
            if i > iStart then
            begin
              if Valid then
                aCanvas.LineTo(iX, iYC)
              else
              begin
                aPoint := aCanvas.PenPos;
                aCanvas.MoveTo(iX, aPoint.y);
              end;
            end else
              aCanvas.MoveTo(iX, iYC);

            // selected
            if bSelected then
            begin
              Inc(iCnt);
              if iCnt mod iStep = 0 then
              begin
                aPenMode := aCanvas.Pen.Mode;
                aCanvas.Brush.Color := clWhite;
                aCanvas.Pen.Mode := pmXOR;
                aCanvas.Pen.Color := clWhite;
                aCanvas.Rectangle(
                    Rect(iX-SEL_WIDTH, iYC-SEL_WIDTH, iX+SEL_WIDTH, iYC+SEL_WIDTH));
                aCanvas.Pen.Mode := aPenMode;
              end;
            end;

            if FImages <> nil then
              DrawFills( XTerms.Items[i] as TXTermITem );
          end;

      end;

    ssOHLC :
      for i:=iStart to iEnd do
      with XTerms.Items[i] as TXTermItem do
      begin
        if not Valid then Continue;

        aCanvas.Pen.Color := FChartColor;
        aCanvas.Pen.Width := 1;
        iX := (i-iStart)*iBarWidth + aRect.Left+1;
        iCenter := iX + iWingWidth;
        // Open
        iYO := aRect.Bottom - Round((O - FMin)*dRY);
        iYH := aRect.Bottom - Round((H - FMin)*dRY);
        iYL := aRect.Bottom - Round((L - FMin)*dRY);
        iYC := aRect.Bottom - Round((C - FMin)*dRY);
        //
        if iBarWidth = 1 then
        begin
          aCanvas.MoveTo(iX, iYH);
          aCanvas.LineTo(iX, iYL+1);
        end else
        begin
          aCanvas.MoveTo(iX, iYO);
          aCanvas.LineTo(iCenter, iYO);
          aCanvas.MoveTo(iCenter, iYH);
          aCanvas.LineTo(iCenter, iYL+1);
          aCanvas.MoveTo(iCenter, iYC);
          aCanvas.LineTo(iCenter+iWingWidth+1, iYC);
        end;
        // selected
        if bSelected then
        begin
          Inc(iCnt);
          if iCnt mod iStep = 0 then
          begin
            aPenMode := aCanvas.Pen.Mode;
            aCanvas.Brush.Color := clWhite;
            aCanvas.Pen.Mode := pmXOR;
            aCanvas.Pen.Color := clWhite;
            aCanvas.Rectangle(
                Rect(iCenter-SEL_WIDTH, iYC-SEL_WIDTH, iCenter+SEL_WIDTH, iYC+SEL_WIDTH));
            aCanvas.Pen.Mode := aPenMode;
          end;
        end;

        if FImages <> nil then
          DrawFills( XTerms.Items[i] as TXTermITem );
      end;
    ssCandle :
      for i:=iStart to iEnd do
      with XTerms.Items[i] as TXTermItem do
      begin
        if not Valid then Continue;

        aCanvas.Pen.Width := 1;

        iX := (i-iStart)*iBarWidth + aRect.Left+1;
        iCenter := iX + iWingWidth;
        // Open
        iYO := aRect.Bottom - Round((O - FMin)*dRY);
        iYH := aRect.Bottom - Round((H - FMin)*dRY);
        iYL := aRect.Bottom - Round((L - FMin)*dRY);
        iYC := aRect.Bottom - Round((C - FMin)*dRY);
        //
        if C > O then
          aCanvas.Pen.Color := clRed
        else if C < O then
          aCanvas.Pen.Color := FChartColor
        else
          aCanvas.Pen.Color := clGray;

        if CrosChart then
          aCanvas.Pen.Color := CrosChartColor;

        if iBarWidth = 1 then
        begin
          aCanvas.MoveTo(iX, iYH);
          aCanvas.LineTo(iX, iYL);
        end else
        begin
          aCanvas.MoveTo(iCenter, iYH);
          aCanvas.LineTo(iCenter, iYL);
          //
          if C > O then
            aCanvas.Brush.Color := clRed
          else
            aCanvas.Brush.Color := FChartColor;

          if CrosChart then
            aCanvas.Brush.Color := CrosChartColor;

          //
          if iYC = iYO then
          begin
            aCanvas.MoveTo(iX, iYO);
            aCanvas.LineTo(iCenter + iWingWidth + 1, iYO);
          end else
            if iYO > iYC then
              aCanvas.FillRect(Rect(iX, iYC, iCenter+iWingWidth+1, iYO+1))
            else
              aCanvas.FillRect(Rect(iX, iYO, iCenter+iWingWidth+1, iYC+1));
        end;
        // selected
        if bSelected then
        begin
          Inc(iCnt);
          if iCnt mod iStep = 0 then
          begin
            aPenMode := aCanvas.Pen.Mode;
            aCanvas.Brush.Color := clWhite;
            aCanvas.Pen.Color := clWhite;

            if CrosChart then begin
              aCanvas.Brush.Color := CrosChartColor;
              aCanvas.Pen.Color := CrosChartColor;
            end;

            aCanvas.Pen.Mode := pmXOR;
            aCanvas.Rectangle(
                Rect(iCenter-SEL_WIDTH, iYL-SEL_WIDTH, iCenter+SEL_WIDTH, iYL+SEL_WIDTH));
            aCanvas.Pen.Mode := aPenMode;
          end;
        end;

        if FImages <> nil then
          DrawFills( XTerms.Items[i] as TXTermITem );
      end;
  end;

   aCanvas.Brush.Color := aBrushColor;

  if XTerms.Symbol is TOption then
  begin
    if FUseRlHighLine then DrawHLine( (XTerms.Symbol as TOption).RelativeHigh , FRlHighLineColor,'월고' );
    if FUseRlLowLine then DrawHLine( (XTerms.Symbol as TOption).RelativeLow, FRlLowLineColor,'월저' );
  end;

  if FUseHighLine then DrawHLine( XTerms.Symbol.DayHigh, FHighLineColor,'고가' );
  if FUseLowLine then DrawHLine( XTerms.Symbol.DayLow, FLowLineColor,'저가' );
  if FUseCustomLine then DrawHLine( FCustomLineValue , FCustomLineColor,'지정');

  aCanvas.Font.Color := aFontColor;
  aCanvas.Pen.Color := aPenColor;

end;

procedure TSymboler.Draw2(const aCanvas: TCanvas; const aRect: TRect;
  const iStart, iEnd, iBarWidth: Integer; const bSelected: Boolean);
const
  SEL_WIDTH = 3;
  WING_WIDTHS : array[1..14] of Integer = (1,1,1,1,1,1,2,2,2,3,3,4,4,5);
var
  lAvgPrc, sAvgPrc, dRY : Double;
  i, j,
  iStep, iCnt, // for drawing selected
  sVol, lVol,
  iX, iCenter, iWingWidth,
  iYO, iYC, iYL, iYH : Integer;
  iLCount, iSCount : Integer;
  aBrushColor, aFontColor, aPenColor : TColor;
  aPenMode : TPenMode;
  aFill : TFill;
  aPoint : TPoint;
  aItem : TShowMeItem;

  procedure DrawFill(iOffset : Integer; ttValue : TPositionType; iQty : Integer;
    dPrice : Double);
  const
    IMG_INDICES : array[TPositionType] of Integer = (0,2{,1,3});
  var
    iYTxt, iYImg, iYPrice, iXImg, iYOffset : Integer;
    aColor, aColor2 : TColor;
    stText : String;
    aSize : TSize;
  begin
    stText := IntToStr(iQty);
    aSize := aCanvas.TextExtent(stText);
    iYOffset := aSize.cy + FImages.Height + 2;
    // position
    iXImg := iCenter - FImages.Width div 2;
    case ttValue of
      ptLong:
        begin
          iYImg := iYL + 1 + (aItem.OffSet-1)*iYOffset;
          iYTxt := iYImg + 1 + FImages.Height;
        end;
      ptShort :
        begin
          iYImg := iYH - 1 - FImages.Height - (aItem.OffSet-1)*iYOffset;
          iYTxt := iYImg - 1 - aSize.cy;
        end;
    end;
    // color
    case ttValue of
      ptLong : aColor := aItem.BidColor;
      ptShort : aColor :=aItem.AskColor;
    end;
    // fill price
    iYPrice := aRect.Bottom - Round((dPrice-FMin2)*dRY);
    case ttValue of
      ptLong : aColor2 := aItem.BidColor;
      ptShort : aColor2 := aItem.AskColor;
    end;
    aCanvas.Pen.Color := aColor2;
    aCanvas.Polygon([Point(iCenter, iYPrice),
                     Point(iCenter-2, iYPrice-2),
                     Point(iCenter-2, iYPrice+2)]);
    // fill symbol
    FImages.Draw(aCanvas, iXImg, iYImg, IMG_INDICES[ttValue]);
    // fill qty
    aCanvas.Brush.Color := aBrushColor;
    aCanvas.Font.Color := clWhite;
    aCanvas.TextOut(iCenter - aSize.cx div 2, iYTxt, stText);
  end;


  procedure DrawFills( aTerm : TXTermItem );
  var
    j : integer;
  begin
    aItem := FShowMeItem;
    if aItem = nil then Exit;
    if not aItem.EnAbled then Exit;

    with aTerm do
    begin
      iX := (i-iStart)*iBarWidth + aRect.Left+1;
      iCenter := iX + iWingWidth;
      // Open
      iYO := aRect.Bottom - Round((O2 - FMin2)*dRY);
      iYH := aRect.Bottom - Round((H2 - FMin2)*dRY);
      iYL := aRect.Bottom - Round((L2 - FMin2)*dRY);
      iYC := aRect.Bottom - Round((C2 - FMin2)*dRY);
      //
      iLCount := 0; iSCount := 0;
      lVol  := 0; sVol  := 0;
      sAvgPrc := 0; lAvgPrc := 0;
      //

      if Fills = nil then Exit;

      for j:=0 to Fills.Count-1 do
      begin
        aFill := TFill(Fills.Items[j]);

        if aFill.Volume > 0 then
        begin
          Inc(iLCount);
          inc( lVol, aFill.Volume );
          lAvgPrc := ( lAvgPrc * (lVol -  aFill.Volume ) +
                aFill.Price * aFill.Volume ) / lVol;
        end else
        if aFill.Volume < 0 then
        begin
          Inc(iSCount);
          inc( sVol, abs(aFill.Volume) );
          sAvgPrc := ( sAvgPrc * (sVol - abs( aFill.Volume ))  +
              aFill.Price * abs(aFill.Volume)) / sVol;
        end;
      end;

      LongFill  := lAvgPrc;
      ShortFill := sAvgPrc;

      if iLCount > 0 then
        DrawFill(1, ptLong, lVol, lAvgPrc);
      if iSCount > 0 then
        DrawFill(1, ptShort, sVol, sAvgPrc);
    end;
  end;
begin
  // unacceptable condition
  if (iStart > iEnd) or
     (iStart < 0) or (iStart >= FXTerms.Count) or
     (iEnd < 0) or (iEnd >= FXTerms.Count) then Exit;
  //-- Ratio
  if Abs(FMax2-FMin2) < ZERO then Exit;
  //
  dRY := (aRect.Bottom - aRect.Top)/(FMax2 - FMin2);
  //--
  if (iBarWidth >=1) and (iBarWidth <= 14) then
    iWingWidth := WING_WIDTHS[iBarWidth]
  else
    iWingWidth := Round(iBarWidth / 2 * 0.67);
  {
  if iBarWidth <= 5 then
    iWingWidth := 1
  else
    iWingWidth := Round(iBarWidth / 2 * 0.67);
  }
  iStep := 50 div iBarWidth;
  iCnt := 0;
  //--
  aBrushColor := aCanvas.Brush.Color;
  aFontColor := aCanvas.Font.Color;
  aPenColor := aCanvas.Pen.Color;
  //-- bar
  case FChartStyle of
    ssLine :
      for i:=iStart to iEnd do
      with XTerms.Items[i] as TXTermItem do
      begin
        aCanvas.Pen.Color := clRed;// FChartColor;
        aCanvas.Pen.Width := 1;
        iX := (i-iStart)*iBarWidth + aRect.Left+1;
        iYC := aRect.Bottom - Round((C2 - FMin2)*dRY);
        if i > iStart then
        begin
          if Valid then
            aCanvas.LineTo(iX, iYC)
          else
          begin
            aPoint := aCanvas.PenPos;
            aCanvas.MoveTo(iX, aPoint.y);
          end;
        end else
          aCanvas.MoveTo(iX, iYC);

        // selected
        if bSelected then
        begin
          Inc(iCnt);
          if iCnt mod iStep = 0 then
          begin
            aPenMode := aCanvas.Pen.Mode;
            aCanvas.Brush.Color := clWhite;
            aCanvas.Pen.Mode := pmXOR;
            aCanvas.Pen.Color := clWhite;
            aCanvas.Rectangle(
                Rect(iX-SEL_WIDTH, iYC-SEL_WIDTH, iX+SEL_WIDTH, iYC+SEL_WIDTH));
            aCanvas.Pen.Mode := aPenMode;
          end;
        end;

        if FImages <> nil then
          DrawFills( XTerms.Items[i] as TXTermITem );
      end;
    ssOHLC :
      for i:=iStart to iEnd do
      with XTerms.Items[i] as TXTermItem do
      begin
        if not Valid then Continue;

        aCanvas.Pen.Color := FChartColor;
        aCanvas.Pen.Width := 1;
        iX := (i-iStart)*iBarWidth + aRect.Left+1;
        iCenter := iX + iWingWidth;
        // Open
        iYO := aRect.Bottom - Round((O2 - FMin2)*dRY);
        iYH := aRect.Bottom - Round((H2 - FMin2)*dRY);
        iYL := aRect.Bottom - Round((L2 - FMin2)*dRY);
        iYC := aRect.Bottom - Round((C2 - FMin2)*dRY);
        //
        if iBarWidth = 1 then
        begin
          aCanvas.MoveTo(iX, iYH);
          aCanvas.LineTo(iX, iYL+1);
        end else
        begin
          aCanvas.MoveTo(iX, iYO);
          aCanvas.LineTo(iCenter, iYO);
          aCanvas.MoveTo(iCenter, iYH);
          aCanvas.LineTo(iCenter, iYL+1);
          aCanvas.MoveTo(iCenter, iYC);
          aCanvas.LineTo(iCenter+iWingWidth+1, iYC);
        end;
        // selected
        if bSelected then
        begin
          Inc(iCnt);
          if iCnt mod iStep = 0 then
          begin
            aPenMode := aCanvas.Pen.Mode;
            aCanvas.Brush.Color := clWhite;
            aCanvas.Pen.Mode := pmXOR;
            aCanvas.Pen.Color := clWhite;
            aCanvas.Rectangle(
                Rect(iCenter-SEL_WIDTH, iYC-SEL_WIDTH, iCenter+SEL_WIDTH, iYC+SEL_WIDTH));
            aCanvas.Pen.Mode := aPenMode;
          end;
        end;

        if FImages <> nil then
          DrawFills( XTerms.Items[i] as TXTermITem );
      end;
    ssCandle :
      for i:=iStart to iEnd do
      with XTerms.Items[i] as TXTermItem do
      begin
        if not Valid then Continue;

        aCanvas.Pen.Width := 1;

        iX := (i-iStart)*iBarWidth + aRect.Left+1;
        iCenter := iX + iWingWidth;
        // Open
        iYO := aRect.Bottom - Round((O2 - FMin2)*dRY);
        iYH := aRect.Bottom - Round((H2 - FMin2)*dRY);
        iYL := aRect.Bottom - Round((L2 - FMin2)*dRY);
        iYC := aRect.Bottom - Round((C2 - FMin2)*dRY);
        //
        if C > O then
          aCanvas.Pen.Color := clRed
        else if C < O then
          aCanvas.Pen.Color := FChartColor
        else
          aCanvas.Pen.Color := clGray;
        if iBarWidth = 1 then
        begin
          aCanvas.MoveTo(iX, iYH);
          aCanvas.LineTo(iX, iYL);
        end else
        begin
          aCanvas.MoveTo(iCenter, iYH);
          aCanvas.LineTo(iCenter, iYL);
          //
          if C > O then
            aCanvas.Brush.Color := clRed
          else
            aCanvas.Brush.Color := FChartColor;
          //
          if iYC = iYO then
          begin
            aCanvas.MoveTo(iX, iYO);
            aCanvas.LineTo(iCenter + iWingWidth + 1, iYO);
          end else
            if iYO > iYC then
              aCanvas.FillRect(Rect(iX, iYC, iCenter+iWingWidth+1, iYO+1))
            else
              aCanvas.FillRect(Rect(iX, iYO, iCenter+iWingWidth+1, iYC+1));
        end;
        // selected
        if bSelected then
        begin
          Inc(iCnt);
          if iCnt mod iStep = 0 then
          begin
            aPenMode := aCanvas.Pen.Mode;
            aCanvas.Brush.Color := clWhite;
            aCanvas.Pen.Color := clWhite;
            aCanvas.Pen.Mode := pmXOR;
            aCanvas.Rectangle(
                Rect(iCenter-SEL_WIDTH, iYL-SEL_WIDTH, iCenter+SEL_WIDTH, iYL+SEL_WIDTH));
            aCanvas.Pen.Mode := aPenMode;
          end;
        end;

        if FImages <> nil then
          DrawFills( XTerms.Items[i] as TXTermITem );
      end;
  end;

  aCanvas.Brush.Color := aBrushColor;
  aCanvas.Font.Color := aFontColor;
  aCanvas.Pen.Color := aPenColor;

end;

//============================< Check Positions >=======================//

function TSymboler.GetDateTimeDesc(iBarIndex : Integer) : String;
begin
  Result := FXTerms.DateTimeDesc(iBarIndex);
end;

function TSymboler.SpotData(iBarIndex : Integer) : String;
begin
  if (iBarIndex >=0) and (iBarIndex < FXTerms.Count) then
  with FXTerms[iBarIndex] do
    if Valid then begin
      if FXTerms.Base = cbQuote then
        Result := Format('''%s'' Ask:%.2f Bid:%.2f V:%.0n',
                  [GetTitle, C, C2, FillVol])
      else
        Result := Format('''%s'' O:%.2f H:%.2f L:%.2f C:%.2f V:%.0n',
                  [GetTitle, O, H, L, C, FillVol]);
    end
    else
      Result := 'N/A';
end;

procedure TSymboler.HintData(iBarIndex : Integer; stHints : TStringList);
begin
  if (iBarIndex >=0) and (iBarIndex < FXTerms.Count) and
     (stHints <> nil) then
  with FXTerms[iBarIndex] do
  begin
    stHints.Add('[' + GetTitle + ']');
    stHints.Add(Format('O=%.2f', [O]));
    stHints.Add(Format('H=%.2f', [H]));
    stHints.Add(Format('L=%.2f', [L]));
    stHints.Add(Format('C=%.2f', [C]));
  end;
end;


function TSymboler.Hit(const iHitX, iHitY : Integer; const aRect : TRect;
  const iStartIndex, iBarIndex, iBarWidth : Integer): Boolean;
const
  HIT_RANGE = 1;
var
  aXTerm : TXTermItem;
  iX, iY, iCenter, iYH, iYL, iYO, iYC : Integer;
  iX2, iYC2 : Integer;

  iWingWidth : Integer;
  dRY : Double;
begin
  Result := False;
  // over data range
  if (iBarIndex < 0) or (iBarIndex >= FXTerms.Count) then Exit;

  if Abs(FMax - FMin) < EPSILON  then Exit;
  //-- Ratio
  dRY := (aRect.Bottom - aRect.Top)/(FMax - FMin);
  //--
  if iBarWidth <= 5 then
    iWingWidth := 1
  else
    iWingWidth := Round(iBarWidth / 2 * 0.67);
  //--
  case FChartStyle of
  ssLine :
    begin
      aXTerm := XTerms.Items[iBarIndex] as TXTermItem;
      iX := (iBarIndex-iStartIndex)*iBarWidth + aRect.Left+1;
      iYC := aRect.Bottom - Round((aXTerm.C - FMin)*dRY);
      if iBarIndex < XTerms.Count-1 then
      begin
        aXTerm := XTerms.Items[iBarIndex+1] as TXTermItem;
        iX2 := (iBarIndex + 1 - iStartIndex) * iBarWidth + aRect.Left + 1;
        iYC2 := aRect.Bottom - Round((aXTerm.C - FMin)*dRY);
      end else
      begin
        iX2 := iX;
        iYC2 := iYC2;
      end;
      //
      if (iHitX >= iX) and (iHitX <= iX2) then
      begin
        if iX <> iX2 then
          iY := Round(iYC + (iHitX-iX)*(iYC2-iYC)/(iX2-iX))
        else
          iY := iYC;
        //
        if (iHitY <= iY + HIT_RANGE) and (iHitY >= iY - HIT_RANGE) then
          Result := True;
      end;
    end;
  ssOHLC :
    begin
      aXTerm := XTerms.Items[iBarIndex] as TXTermItem;
      iX := (iBarIndex-iStartIndex)*iBarWidth + aRect.Left+1;
      iCenter := iX + iWingWidth;
      // Open
      iYO := aRect.Bottom - Round((aXTerm.O - FMin)*dRY);
      iYH := aRect.Bottom - Round((aXTerm.H - FMin)*dRY);
      iYL := aRect.Bottom - Round((aXTerm.L - FMin)*dRY);
      iYC := aRect.Bottom - Round((aXTerm.C - FMin)*dRY);
      //
      if (iHitX >= iCenter - HIT_RANGE) and (iHitX <= iCenter + HIT_RANGE) and
         (iHitY >= iYH - HIT_RANGE) and (iHitY <= iYL + HIT_RANGE) then
        Result := True
      else
      if (iHitX < iCenter) and
         (iHitY >= iYO - HIT_RANGE) and (iHitY <= iYO + HIT_RANGE) then
        Result := True
      else
      if (iHitX > iCenter) and
         (iHitY >= iYC - HIT_RANGE) and (iHitY <= iYC + HIT_RANGE) then
        Result := True;
    end;
  ssCandle :
    begin
      aXTerm := XTerms.Items[iBarIndex] as TXTermItem;
      iX := (iBarIndex-iStartIndex)*iBarWidth + aRect.Left+1;
      iCenter := iX + iWingWidth;
      // Open
      iYO := aRect.Bottom - Round((aXTerm.O - FMin)*dRY);
      iYH := aRect.Bottom - Round((aXTerm.H - FMin)*dRY);
      iYL := aRect.Bottom - Round((aXTerm.L - FMin)*dRY);
      iYC := aRect.Bottom - Round((aXTerm.C - FMin)*dRY);
      //
      if (iHitX >= iCenter - HIT_RANGE) and (iHitX <= iCenter + HIT_RANGE) and
         (iHitY >= iYH - HIT_RANGE) and (iHitY <= iYL + HIT_RANGE) then
        Result := True
      else
      if (iHitX >= iCenter - iWingWidth) and (iHitX <= iCenter + iWingWidth) then
        if ((iYO >= iYC) and (iHitY >= iYC) and (iHitY <= iYO)) or
           ((iYO < iYC) and (iHitY >= iYO) and (iHitY <= iYC)) then
          Result := True;
    end;
  end; //.. case
end;



//===========================< Misc >=============================//

procedure TSymboler.SetSymbol(aSymbol: TSymbol);
begin
  if (aSymbol = nil) or (FSymbolerMode = smSub) then Exit;

  FXTerms.Define(aSymbol, FXTerms.Base, FXTerms.Period, FXTerms.Count);
end;

procedure TSymboler.DataAddProc(Sender : TObject);
var
  aMasterXTerm, aSecondXTerm : TXTermItem;
begin
  if FSymbolerMode = smMain then
  begin
    if Assigned(FOnSyncAdd) then
      FOnSyncAdd(Self);
    Exit;
  end else if FDataTerms.Base <> cbTick then
  begin
    aSecondXTerm := FDataTerms[FDataTerms.Count-1];
    aMasterXTerm :=
      XTerms.FindTerm(aSecondXTerm.StartTime, XTerms.Base);
    //sms
    //aMasterXTerm := FindXTermItem(XTerms, aSecondXTerm, XTerms.Base);

    if aMasterXTerm <> nil then
    begin
      aMasterXTerm.Valid := True;
      aMasterXTerm.Assign(aSecondXTerm);
    end;
  end;

  if Assigned(FOnAsyncAdd) then
    FOnAsyncAdd(Self);
end;

procedure TSymboler.DataRefreshProc(Sender : TObject);
  function IsEqualTime(aTime1, aTime2 : TDateTime) : Boolean;
  var
    wHH1, wMM1, wSS1, wMS1, wHH2, wMM2, wSS2, wMS2 : Word;
  begin
    Result := False;

    if Floor(aTime1) = Floor(aTime2) then
    begin
      DecodeTime(aTime1, wHH1, wMM1, wSS1, wMS1);
      DecodeTime(aTime2, wHH2, wMM2, wSS2, wMS2);

      if (wHH1 = wHH2) and (wMM1 = wMM2) then
        Result := True;
    end;
  end;

var
  i, iDataIndex : Integer;
  aOrgXTerm, aNextXTerm, aDataXTerm, aInsertXTerm : TXTermItem;
  bSearch, bFore : Boolean;
  aOrgLastTerm , aDataLastTerm : TXTermItem;
begin
  if FSymbolerMode = smMain then
  begin
    if Assigned(FOnSyncRefresh) then
      FOnSyncRefresh(Self);
    Exit;
  end else if FSymbolerMode = smSub then
  begin
    XTerms.Clear;
    iDataIndex := 0;

    case FDataTerms.Base of
      cbTick :
        SetZero;
      cbMin :
        for i := 0 to MainSymboler.XTerms.Count-1 do
        begin
          aOrgXTerm := MainSymboler.XTerms[i]; //get a main symboler`s XTerm

          if i = MainSymboler.XTerms.Count-1 then //get a next orgXTerm`s XTerm
            aNextXTerm := nil
          else
            aNextXTerm := MainSymboler.XTerms[i+1];

          if iDataIndex > FDataTerms.Count-1 then //get a data XTerm
            aDataXTerm := nil
          else
            aDataXTerm := FDataTerms[iDataIndex];

          aInsertXTerm := XTerms.Add as TXTermItem; //insert into a Master XTerms
          aInsertXTerm.StartTime := aOrgXTerm.StartTime;
          aInsertXTerm.LastTime := aOrgXTerm.LastTime;
          aInsertXTerm.MMIndex := aOrgXTerm.MMIndex;
          aInsertXTerm.Count := 1;

          //dataXTerm is out of range(higher then DataXTerms`s count)
          if aDataXTerm = nil then
          begin
            if XTerms.Count > 1 then
              aInsertXTerm.Assign(XTerms[XTerms.Count-2]);
            aInsertXTerm.StartTime := aOrgXTerm.StartTime;
            aInsertXTerm.LastTime := aOrgXTerm.LastTime;
            aInsertXTerm.MMIndex := aOrgXTerm.MMIndex;

            continue;
          end;

          //case1
          if IsEqualTime(aOrgXTerm.StartTime, aDataXTerm.StartTime) then
          begin
            aInsertXTerm.Assign(aDataXTerm);
            Inc(iDataIndex);
          //case2
          end else if aOrgXTerm.StartTime > aDataXTerm.StartTime then
          begin
            bSearch := False;

            while((aNextXTerm = nil) and (iDataIndex < FDataTerms.Count-1)) or
              ((aNextXTerm <> nil) and (aDataXTerm.StartTime < aNextXTerm.StartTime)) do
            begin
              if IsEqualTime(aOrgXTerm.StartTime, aDataXTerm.StartTime) then
              begin
                aInsertXTerm.Assign(aDataXTerm);
                bSearch := True;
                Inc(iDataIndex);
                break;
              end;
              Inc(iDataIndex);
              if iDataIndex > FDataTerms.Count-1 then
                break
              else
                aDataXTerm := FDataTerms[iDataIndex];
            end;

            if not(bSearch) then  //not found!
            begin
              if FDataTerms.Count > 1 then
                aInsertXTerm.Assign(FDataTerms[FDataTerms.Count-2]);
              aInsertXTerm.StartTime := aOrgXTerm.StartTime;
              aInsertXTerm.LastTime := aOrgXTerm.LastTime;
              aInsertXTerm.MMIndex := aOrgXTerm.MMIndex;
            end;
          end
          //case3
          else if aOrgXTerm.StartTime < aDataXTerm.StartTime then
          begin
            aInsertXTerm.Fills := nil;
            if i <> 0 then
            begin
              aInsertXTerm.AccVol := XTerms[i-1].AccVol;
              aInsertXTerm.O := XTerms[i-1].C;
              aInsertXTerm.H := XTerms[i-1].C;
              aInsertXTerm.L := XTerms[i-1].C;
              aInsertXTerm.C := XTerms[i-1].C;
            end;
          end;  //end-case3
        end;  //end cbMin

      else  //case-else
        begin
          for i := FMainSymboler.XTerms.Count-1 downto 0 do
          begin
            aOrgXTerm := FMainSymboler.XTerms[i];
            aInsertXTerm := TXTermItem(FXTerms.Insert(0));
            aInsertXTerm.Valid := False;
            aDataXTerm := nil;

            if (FDataTerms.Count-1 >= iDataIndex) and (iDataIndex >= 0 ) then
              aDataXTerm := FDataTerms[FDataTerms.Count-1-iDataIndex];

            if aDataXTerm <> nil then
            begin
              aInsertXTerm.Assign(aDataXTerm);
              aInsertXTerm.Valid := True;
            end;

            aInsertXTerm.StartTime := aOrgXTerm.StartTime;
            aInsertXTerm.LastTime := aOrgXTerm.LastTime;
            aInsertXTerm.Count := aOrgXTerm.Count;
            Inc(iDataIndex);
          end;

          {
          aOrgLastTerm := MainSymboler.XTerms[MainSymboler.XTerms.Count-1];
          aDataLastTerm := FDataTerms[FDataTerms.Count-1];

          if (aOrgLastTerm <> nil) and (aDataLastTerm <> nil) then
          begin
            if Floor(aOrgLastTerm.StartTime) <= Floor(aDataLastTerm.StartTime) then
              bFore := True
            else
              bFore := False;
          end;

          for i := 0 to MainSymboler.XTerms.Count-1 do
          begin
            aOrgXTerm := MainSymboler.XTerms[i];

            if bFore then
              aDataXTerm := FDataTerms.FindTerm(aOrgXTerm.LastTime, FDataTerms.Base)
            else
            begin
              if (FDataTerms.Base = cbDaily) or (i = 0) then
                aDataXTerm := FDataTerms.FindTerm(aOrgXTerm.StartTime, FDataTerms.Base)
              else
                aDataXTerm := FDataTerms.FindTerm(MainSymboler.XTerms[i-1].StartTime, FDataTerms.Base);
            end;

            aInsertXTerm := TXTermItem(FXTerms.Add);

            if aDataXTerm <> nil then
              aInsertXTerm.Assign(aDataXTerm)
            else
              aInsertXTerm.Valid := False;

            aInsertXTerm.StartTime := aOrgXTerm.StartTime;
            aInsertXTerm.LastTime := aOrgXTerm.LastTime;
          end;
          }
        end;
    end;

    if FDataTerms.Base <> cbTick then
    begin
      //-- 이전에 XTerms 가 Clear 됐기 때문에 이곳에서 다시 Refill 하기 위해.
      XTerms.Account := nil;
      GetFill;
    end;

    if Assigned(FOnAsyncRefresh) then
      FOnAsyncRefresh(Self);
  end;
end;

procedure TSymboler.DataUpdateProc(Sender : TObject);
var
  aMasterXTerm, aSecondXTerm : TXTermItem;

begin
  if FSymbolerMode = smMain then
  begin
    if Assigned(FOnSyncUpdate) then
      FOnSyncUpdate(Self);
    Exit;
  end else if FDataTerms.Base <> cbTick then
  begin
    aSecondXTerm := FDataTerms[FDataTerms.Count-1];

    if FDataTerms.Base = cbMin then
      aMasterXTerm :=
        XTerms.FindTerm(aSecondXTerm.StartTime, XTerms.Base)
    else
      aMasterXTerm := XTerms[XTerms.Count-1];

    //sms
    //aMasterXTerm := FindXTermItem(XTerms, aSecondXTerm, XTerms.Base);

    if (aMasterXTerm <> nil) then
    begin
      aMasterXTerm.Valid := True;
      aMasterXTerm.Assign(aSecondXTerm);
    end;
  end;

  if Assigned(FOnAsyncUpdate) then
    FOnAsyncUpdate(Self);
end;

procedure TSymboler.SetZero;
var
  i : Integer;
begin
  XTerms.Clear;

  for i := 0 to FMainSymboler.XTerms.Count-1 do
  with XTerms.Add as TXTermItem do
  begin
    StartTime := FMainSymboler.XTerms[i].StartTime;
    LastTime := FMainSymboler.XTerms[i].LastTime;
    Count := 1;
    MMIndex := FMainSymboler.XTerms[i].MMIndex;
    FillVol := 0;
    AccVol := 0;
  end;
end;

procedure TSymboler.RefreshData;
var
  i : Integer;
  aXTerm : TXTermItem;
begin
  if FWorkspaceSymbol = nil then  //main symboler change
  with FMainSymboler.XTerms do
  begin
    FDataTerms.Define(FDataTerms.Symbol, Base, Period, Count);
    Self.XTerms.Base := Base;
    Self.XTerms.Period := Period;
  end else  //loading subsymboler in workspace process
  with FMainSymboler.XTerms do
  begin
    FDataTerms.Define(FWorkspaceSymbol, Base, Period, Count);
    Self.XTerms.Symbol := FWorkspaceSymbol;
    Self.XTerms.Base := Base;
    Self.XTerms.Period := Period;

    FWorkspaceSymbol := nil;
  end;
end;

procedure TSymboler.AddData;
var
  aXTerm, aPreXTerm, aRefXTerm : TXTermItem;
  i : Integer;
  aInsertTerm, aDataXTerm, aMainXTerm : TXTermItem;
begin
  if (MainSymboler.XTerms.Count = 0) or (SymbolerMode = smMain) or
    not(FDataTerms.Ready) then Exit;

  aMainXTerm := MainSymboler.XTerms[MainSymboler.XTerms.Count-1];
  aDataXTerm :=
    FDataTerms.FindTerm(aMainXTerm.StartTime, MainSymboler.XTerms.Base);
  //sms
  //aDataXTerm := FindXTermItem(DataXTerms, aMainXTerm, MainSymbol.XTerms.Base);
  aInsertTerm := XTerms.Add as TXTermItem;

  if aDataXTerm = nil then
  begin
    aInsertTerm.Valid := False;
    aInsertTerm.StartTime := aMainXTerm.StartTime;
    aInsertTerm.LastTime := aMainXTerm.LastTime;
    aInsertTerm.MMIndex := aMainXTerm.MMIndex;
    aInsertTerm.Count := aMainXTerm.Count;
  end else
    aInsertTerm.Assign(aDataXTerm);
end;

procedure TSymboler.UpdateLastPrice;
var
  aDataXTerm, aXTerm : TXTermItem;
begin
  aDataXTerm := FDataTerms[FDataTerms.Count-1];
  aXTerm := XTerms[XTerms.Count-1];

  aXTerm.Count := aXTerm.Count + 1;
  aXTerm.C := aDataXTerm.C;

  if aXTerm.C > aXTerm.H then
    aXTerm.H := aXTerm.C;

  if aXTerm.C < aXTerm.L then
    aXTerm.L := aXTerm.C;

  //aXTerm.FillVol := aXTerm.FillVol + aDataXTerm.FillVol;
  aXTerm.FillVol := aDataXTerm.FillVol;
  aXTerm.AccVol := aDataXTerm.AccVol;
  aXTerm.SideVol:= aDataXTerm.SideVol;

  aXTerm.FutVol := aDataXTerm.FutVol;
  aXTerm.OptVol := aDataXTerm.OptVol;
  aXTerm.CallVol:= aDataXTerm.CallVol;
  aXTerm.PutVol := aDataXTerm.PutVol;

  aXTerm.FutVol2 := aDataXTerm.FutVol2;
  aXTerm.OptVol2 := aDataXTerm.OptVol2;
  aXTerm.CallVol2:= aDataXTerm.CallVol2;
  aXTerm.PutVol2 := aDataXTerm.PutVol2;
end;

procedure TSymboler.GetFill;
begin
  if FShowFill then
    XTerms.Account := MainSymboler.XTerms.Account;
end;

procedure TSymboler.ClearFill;
begin
  if not FShowFill then
    XTerms.Account := nil;
end;

end.
