unit ChartCentralBase;

interface

uses
  Windows, Classes, Graphics, Forms, Controls, Math, StdCtrls, SysUtils,
  Dialogs,


  Charters, ChartZones, Stickers;

const
  MIN_BAR_WIDTH = 1;
  MAX_BAR_WIDTH = 21;

type
  TRangeSetMode = (rmResize, rmRefresh, rmAdd);

  //--- should be deleted later
  TChartMode = (cmNormal, cmResizing{Zone크기 변경}, cmMoving{그래프 위치변경},
                cmTLinePrep{추세선준비} , cmTLine{추세선그리기},
                cmTLineMoving{추세선이동}, cmTLineStretching{추세선늘임},
                cmRLine{지지/저항선 그리기}, cmRLineMoving{지지/저항선 이동},
                cmVCursor{수직선커서},
                cmFormMoving{폼이동}, cmFormResizing{폼크기변경});
  //--- until here

  TChartCentralBase = class
  protected
    FMainCharter : TSeriesCharter;
    FMainCharterProtected : Boolean;
    
    FInitialized : Boolean;
    FIsMini : Boolean;
    FChartForm : TForm;

    FSelected : TCharter;
    FChartZones : TChartZones;

    FStickers : TList;

    // Fixed Drawing Factors
    FBitmap : TBitmap;
    //
    FNoDraw : Boolean;
    FScrollBar : TScrollBar;
    FCanvas : TCanvas;
    FClientRect : TRect;
    FDrawRect : TRect;
    FBarWidth : Integer;
    FBarCount : Integer;
    FBackgroundColor : TColor;   // 배경색
    FAxisColor : TColor;         // 축 색
    FFontName : TFontName;       // 글 종류
    FFontSize : Integer;        // 글 크기
    FFontColor : TColor;         // 글 색
    FHLine, FVLine : Boolean;    // Grid Lines
    FGridColor : TColor;         // Grid 색
    FLeftYScale, FRightYScale : Boolean;
    FYCharWidth : Integer;
    // variable Drawing Factors
    FStartIndex, FEndIndex : Integer;

    // events
    FOnRefresh : TNotifyEvent;
    FOnBarWidth : TNotifyEvent;

    FRightMargin : Integer;
    FBarSpace : Integer;
    FDrawSeparator : Boolean;
    FMoving : Boolean;

    // hint
    FHintShowed : Boolean;
    FHintRect : TRect;
    FHints : TStringList;

    FLockMoved : Boolean;

    procedure InitFactors; virtual;
    function GetDataCount : Integer; virtual;

      // set dimension
    procedure SetDrawRect;
    procedure SetBarCount;
    function SetDrawRange(aMode : TRangeSetMode) : Boolean;

      // scroll
    procedure ScrollChangeProc(Sender : TObject);
    procedure ScrollScrollProc(Sender: TObject; ScrollCode: TScrollCode;
                var ScrollPos: Integer);
      // draw
    function GetMovingColor : TColor;
    procedure DrawXScale(aCanvas : TCanvas); virtual;
    procedure Draw(aCanvas : TCanvas; bPrint : Boolean = False);
    procedure DrawHint(X, Y : Integer);

      // manage stickers
    procedure ClearStickers;
  public
    constructor Create(aForm : TForm; aCanvas : TCanvas; aRect : TRect;
                   aScroll : TScrollBar); virtual;
    destructor Destroy; override;

      // default persistence for screen configuration
    procedure SetScreenPersistence(aBitStream : TMemoryStream);
    procedure GetScreenPersistence(aBitStream : TMemoryStream);

      // move & delete charter
    procedure Move(aCharter : TCharter; iFrom, iTo : Integer; bNewZone : Boolean); virtual;
    procedure Delete(aCharter : TCharter); virtual;
    procedure DetachStickers(aCharter :TCharter);

      // config
    function ConfigScreen : Boolean;
    function Config(aCharter : TCharter) : Boolean;

      // redemension
    procedure Resize(aRect : TRect);
    procedure ResizeZone(const iZone, iNewY : Integer);
    function Zoom(iDir : Integer) : Integer;

      // process key input
    procedure DoKey(iKey : Integer);

      // get status
    function IndexOfZone(iX, iY : Integer) : Integer;
    function IndexOfBoundary(iX, iY : Integer) : Integer;
    procedure Hit(iX, iY : Integer);
    function HitIndex(iX : Integer) : Integer;
    function HitPrice(iZone, iY : Integer) : Double; virtual;
    function SpotData(iX, iY : Integer) : String; virtual;
    function GetDateTimeDesc(iBar : Integer) : String;

      // add stickers
    procedure InsertTLine(iZone, iSX, iSY, iEX, iEY: Integer); virtual;
    procedure InsertRLine(iZone, iY : Integer); virtual;
    procedure InsertVLine(iZone, iX : Integer); virtual;

      // move stickers
    procedure MovingHLine(iY: Integer);
    procedure MovingTLine(iSX, iSY, iEX, iEY: Integer);
    procedure MovingVLine(iX: Integer);

      // redraw
    procedure Refresh;

      // misc
    procedure Print(stTitle : String; iWidth, iHeight : Integer);

      // hint
    procedure ShowHint(iZone, X, Y : Integer; bitFlag : Byte);
    procedure HideHint;

      // attributes
    property Initialized : Boolean read FInitialized;
    property IsMini : Boolean read FIsMini write FIsMini;
    property Selected : TCharter read FSelected write FSelected;
    property NoDraw : Boolean read FNoDraw write FNoDraw;
    property LockMoved : Boolean read FLockMoved write FLockMoved;

    //sms
    property BarWidth : Integer read FBarWidth;
      // events
    property OnRefresh : TNotifyEvent read FOnRefresh write FOnRefresh;
    property OnBarWidthChanged : TNotifyEvent read FOnBarWidth write FOnBarWidth;
  end;

const
  HINT_DATA   = $08;
  HINT_KEY    = $04;
  HINT_SHOW_Y = $02;
  HINT_SHOW_X = $01;

implementation

uses DChartCfg, ClePrinter;

const
  SCALE_LEN = 5;
  BOTTOM_MARGIN = 20; // space for x-axis scale
  MOVING_LINE_COLOR = clBlack;

constructor TChartCentralBase.Create(aForm : TForm; aCanvas : TCanvas; aRect : TRect;
     aScroll : TScrollBar);
begin
  FChartForm := aForm;
  FCanvas := aCanvas;

  FClientRect := aRect;
  FScrollBar := aScroll;
  if FScrollBar <> nil then
  begin
    FScrollBar.OnScroll := ScrollScrollProc;
    FScrollBar.OnChange := ScrollChangeProc;
  end;
  //
  InitFactors;
  //
  // LoadFactors
  //
  FBitmap := TBitmap.Create;
  //


  SetDrawRect;
  SetBarCount;
  //
  FChartZones := TChartZones.Create(FDrawRect);
  //
  FStickers := TList.Create;
  //
  FHints := TStringList.Create;
end;

destructor TChartCentralBase.Destroy;
begin
  FHints.Free;
  //
  ClearStickers;
  //
  FStickers.Free;
  FChartZones.Free;
  //
  FBitmap.Free;

  inherited;
end;


procedure TChartCentralBase.ClearStickers;
var
  i : Integer;
  aSticker : TSticker;
begin
  for i:=0 to FStickers.Count-1 do
  begin
    aSticker := TSticker(FStickers.Items[i]);
    FChartZones.DeleteCharter(aSticker);
    aSticker.Free;
  end;
  //
  FStickers.Clear;
end;

//======================< Default Persistence >==========================//

procedure TChartCentralBase.SetScreenPersistence(aBitStream : TMemoryStream);
var
  szBuf : array[0..101] of Char;
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
  aBitStream.Read(FMoving , SizeOf(Boolean));
  aBitStream.Read(FRightMargin , SizeOf(Integer));
  aBitStream.Read(FDrawSeparator , SizeOf(Boolean));

  if Assigned(FOnBarWidth) then FOnBarWidth(Self);
end;

procedure TChartCentralBase.GetScreenPersistence(aBitStream : TMemoryStream);
var
  szBuf : array[0..101] of Char;
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
  aBitStream.Write(FMoving , SizeOf(Boolean));
  aBitStream.Write(FRightMargin , SizeOf(Integer));
  aBitStream.Write(FDrawSeparator , SizeOf(Boolean));
end;

//======================< Virtual Methods >==========================//

procedure TChartCentralBase.Move(aCharter : TCharter; iFrom, iTo : Integer;
  bNewZone : Boolean);
begin
  if FLockMoved then Exit;
  // protect main charter?
  if FMainCharterProtected and (aCharter = FMainCharter) then Exit;
  //
  if (aCharter = nil) or (not bNewZone and (iFrom = iTo)) then Exit;
  //
  if (iFrom < 0) or (iTo < 0) then Exit;

  DetachStickers(aCharter);
  FChartZones.MoveCharter(aCharter, iFrom, iTo, bNewZone);
end;

procedure TChartCentralBase.Delete(aCharter : TCharter);
begin
  // should be overrided by children
end;

procedure TChartCentralBase.DetachStickers(aCharter :TCharter);
var
  i : Integer;
  aSticker : TSticker;
begin
  for i:=FStickers.Count-1 downto 0 do
  begin
    aSticker := TSticker(FStickers.Items[i]);
    if aSticker.SeriesCharter = aCharter then
      Delete(aSticker); // recursive call
  end;
end;

//========================< Get Status >============================//

function TChartCentralBase.HitPrice(iZone, iY : Integer) : Double;
var
  aRect : TRect;
  aCharter : TSeriesCharter;
begin
  Result := 0.0;
  //
  if (iZone < 0) or (iZone > FChartZones.Count-1) or
     (FChartZones[iZone].Count = 0) or
     (not (FChartZones[iZone].Charters[0] is TSeriesCharter)) then Exit;

  aCharter := FChartZones[iZone].Charters[0] as TSeriesCharter;
  //
  aRect := FChartZones[iZone].DrawRect;
  //
  if aRect.Bottom > aRect.Top then
    Result :=
      (aRect.Bottom-iY) * (aCharter.MaxValue - aCharter.MinValue) /
                (aRect.Bottom - aRect.Top) + aCharter.MinValue;
end;

function TChartCentralBase.SpotData(iX, iY : Integer) : String;
var
  iZone, iBar : Integer;
begin
  iZone := IndexOfZone(iX, iY);

  if iZone >= 0 then
  begin
    iBar := HitIndex(iX);
    if FMainCharter <> nil then
      Result := '[' + FMainCharter.GetDateTimeDesc(iBar) + ']'
    else
      Result := '';
    Result := Result + ' ' + FChartZones[iZone].SpotData(iBar);
  end else
    Result := '';
end;

function TChartCentralBase.GetDateTimeDesc(iBar : Integer) : String;
begin
  if FMainCharter <> nil then
    Result := FMainCharter.GetDateTimeDesc(iBar)
  else
    Result := '';
end;

function TChartCentralBase.GetDataCount : Integer;
begin
  if FMainCharter = nil then
    Result := 0
  else
    Result := FMainCharter.GetDataCount;
end;


//-------------------< Private Methods : Draing factors >---------------//

// 초기값
procedure TChartCentralBase.InitFactors;
begin
  FBarWidth := 9;
  FBackgroundColor := clWhite;
  FAxisColor := clGray;
  FFontName := '굴림';
  FFontSize := 10;
  FFontColor := clBlack;
  FHLine := True;
  FVLine := True;
  FGridColor := clLtGray;
  FLeftYScale := False;
  FRightYScale := True;
  FYCharWidth := 8;
  //
  FStartIndex := -1;
  FEndIndex := -1;

  //New Details
  FDrawSeparator := False;
  FRightMargin := 0;
  FMoving := True;
  FLockMoved := False;
end;

// 그래프 그릴 위치 계산
procedure TChartCentralBase.SetDrawRect;
var
  iWidth : Integer;
begin
  //-- bitmap
  FBitmap.Width := FClientRect.Right - FClientRect.Left;
  FBitmap.Height := FClientRect.Bottom - FClientRect.Top;
  //
  iWidth := FCanvas.TextWidth('8') * FYCharWidth + SCALE_LEN;
  //-- Left
  if FLeftYScale and not FIsMini then
    FDrawRect.Left := FClientRect.Left + iWidth
  else
    FDrawRect.Left := FClientRect.Left;
  //-- Right
  if FRightYScale then
    FDrawRect.Right := FClientRect.Right - iWidth
  else
    FDrawRect.Right := FClientRect.Right;
  //-- Top
  FDrawRect.Top := FClientRect.Top;
  //-- Bottom
  if FIsMini then
    FDrawRect.Bottom := FClientRect.Bottom
  else
    FDrawRect.Bottom := FClientRect.Bottom - BOTTOM_MARGIN;
end;

// 한 화면에 들어갈 자료수 계산
procedure TChartCentralBase.SetBarCount;
begin
  if FBarWidth = 0 then
    FBarWidth := 1;

  FBarCount := (FDrawRect.Right - FDrawRect.Left - 1) div FBarWidth;
  //
  if Assigned(FScrollBar) then
    FScrollBar.LargeChange := FBarCount div 2;
end;

// 그릴 자료 영역
function TChartCentralBase.SetDrawRange(aMode : TRangeSetMode) : Boolean;
var
  iStart, iEnd : Integer;
  iDataCount : Integer;

begin
  //--0. get data count
  iDataCount := GetDataCount;

  //--1. check drawing index boundary
  if iDataCount = 0 then // no data
  begin
    iStart := -1;
    iEnd := -1;

    if Assigned(FScrollBar) then
    begin
      FScrollBar.PageSize := 1;
      FScrollBar.SetParams(1, 1, 1);
    end;
  end else
  if (FStartIndex < 0) or (FEndIndex < 0) // first time
      or (aMode = rmRefresh) then         // revamp
  begin

    if FMoving then
    begin
      iEnd := iDataCount - 1;
      iStart := Max(0, iEnd - FBarCount +1);
    end else
    begin
      iEnd := iDataCount - 1;
      iStart := Max(0 , iEnd - FBarCount + FRightMargin + 1);
    end;

    {
    iEnd := iDataCount - 1;
    iStart := Max(0, iEnd - FBarCount +1);
    }


  end else
  case aMode of
    rmResize :
      begin
        iEnd := FEndIndex;

        if FMoving then
        begin
          iStart := Max(0, iEnd - FBarCount +1);
          iEnd := Min(iDataCount-1, iStart + FBarCount - 1);
        end else
        begin
          iStart := Max(0, iEnd - FBarCount +FRightMargin+1);
          iEnd := Min(iDataCount-1, iStart + FBarCount -FRightMargin - 1);
        end;

        {
        iStart := Max(0, iEnd - FBarCount +1);
        iEnd := Min(iDataCount-1, iStart + FBarCount - 1);
        }


      end;
    rmAdd :

      if FMoving then
      begin
        if (FEndIndex + 1 = iDataCount-1) and
         (FEndIndex = FStartIndex + FBarCount - 1) then  // autoscroll condition
        begin
          iEnd := FEndIndex + 1;
          //iStart := FStartIndex + 1;
          iStart := FStartIndex + FBARCOUNT div 5;
        end else
        begin
          iStart := FStartIndex;
          iEnd := Min(iDataCount-1, FStartIndex + FBarCount - 1);
        end;
      end else
      begin
        if (FEndIndex + 1 = iDataCount-1) then  //스크롤바에 맨 끝에 있다면
        begin
          if (FEndIndex >= FStartIndex + FBarCount - FRightMargin - 1) then
          begin //Auto Scroll 을 해야 하는 상태이면
            iEnd := FEndIndex + 1;
            iStart := iEnd + 1 - FBarCount + FRightMargin{+1};

          end else
          begin
            iStart := FStartIndex;
            iEnd := Min(iDataCount-1, FStartIndex + FBarCount - 1);
          end;
        end else
        begin
          iStart := FStartIndex;
          iEnd := Min(iDataCount-1 , FStartIndex + FBarCount -1);
        end;
      end;
      {
      if (FEndIndex + 1 = iDataCount-1) and
         (FEndIndex = FStartIndex + FBarCount - 1) then  // autoscroll condition
      begin
        iEnd := FEndIndex + 1;
        //iStart := FStartIndex + 1;
        iStart := FStartIndex + FBARCOUNT div 5;
      end else
      begin
        iStart := FStartIndex;
        iEnd := Min(iDataCount-1, FStartIndex + FBarCount - 1);
      end;
      }
  end;
  //--2. applies the calculated boundary
  Result := (iStart <> FStartIndex) or (iEnd <> FEndIndex);  // no move?
  if Result then
  begin
    FStartIndex := iStart;
    FEndIndex := iEnd;
  end;

  //--3. set scroll bar in accordance with index boundary
  if Assigned(FScrollBar) then
  begin
    FScrollBar.PageSize := 1;

    if (FStartIndex < 0) or (FEndIndex < 0) then
      FScrollBar.SetParams(1, 1, FBarCount)
    else
      FScrollBar.SetParams(FStartIndex+1, 1,
                  iDataCount + FBarCount  - (FEndIndex - FStartIndex + 1));

    FScrollBar.PageSize := FBarCount;



{$ifdef DEBUG}
{
  gLog.Add(lkDebug, 'barcount', '', IntToStr(FBarCount));
  gLog.Add(lkDebug, 'Range',
        Format('index[%d]:%d-%d',[iDataCount, FStartIndex, FEndIndex]),
        Format('scroll:%d/(%d-%d):%d',
                [FScrollBar.Position, FScrollBar.Min, FScrollBar.Max,
                 FScrollBar.PageSize]));
}
{$endif}
  end;
end;

// process key input
procedure TChartCentralBase.DoKey(iKey : Integer);
begin
  if iKey = VK_DELETE then // 선택항목 삭제
  begin
   if FSelected <> nil then
   begin
     Delete(FSelected);
     //-- added by sms
     FSelected := nil;
   end;

  end else
  if Assigned(FScrollBar) then
  case iKey of
    VK_LEFT :
      FScrollBar.Position := Max(1, FScrollBar.Position-1);
    VK_RIGHT :
      FScrollBar.Position := Min(FScrollBar.Max-FBarCount+1, FScrollBar.Position+1);
    VK_HOME :
      FScrollBar.Position := 1;
    VK_END :
      FScrolLBar.Position := FScrollBar.Max - FBarCount + 1;
    VK_PRIOR :
      FScrollBar.Position := Max(1,FScrollBar.Position - FScrollBar.LargeChange);
    VK_NEXT :
      FScrollBar.Position := Min(FScrollBar.Max - FBarCount + 1,
                                 FScrollBar.Position + FScrollBar.LargeChange);
  end;
end;

//============================< Scroll >===============================//

procedure TChartCentralBase.ScrollScrollProc(Sender: TObject; ScrollCode: TScrollCode;
                var ScrollPos: Integer);
begin
  ScrollPos := Max(1, ScrollPos);
  ScrollPos := Min(FScrollBar.Max - FBarCount + 1, ScrollPos);
  //스크롤한 지점이 화면에 변화를 주느냐 아니냐를 결정한다.
end;

// scrolled
procedure TChartCentralBase.ScrollChangeProc(Sender : TObject);
var
  iDataCount : Integer;
begin
  iDataCount := GetDataCount;
  if iDataCount = 0 then Exit;

  FStartIndex := FScrollBar.Position - 1;
  FEndIndex := Min(FStartIndex + FBarCount - 1,
                   GetDataCount - 1);
  Refresh;

{$ifdef DEBUG}
{
  gLog.Add(lkDebug, 'ScrollProc',
        Format('index[%d]:%d-%d',[FMainCharter.XTerms.Count, FStartIndex, FEndIndex]),
        Format('scroll:%d/(%d-%d):%d',
                [FScrollBar.Position, FScrollBar.Min, FScrollBar.Max,
                 FScrollBar.PageSize]));
}
{$endif}
end;

//==========================< Redimension >===========================//

// 챠트영역 일부 크기변경
procedure TChartCentralBase.ResizeZone(const iZone, iNewY : Integer);
begin
  FChartZones.ResizeZone(iZone, iNewY);
end;

// 화면 크기 변경
procedure TChartCentralBase.Resize(aRect : TRect);
begin
  FClientRect := aRect;
  //
  SetDrawRect;
  FChartZones.Resize(FDrawRect);
  //
  SetBarCount;
  //
  SetDrawRange(rmResize);
  //
  Refresh;
end;

// Change Bar Width
function TChartCentralBase.Zoom(iDir : Integer): Integer;
const
  BAR_STEP = 1;
begin
  if ((iDir > 0) and (FBarWidth < MAX_BAR_WIDTH)) or
     ((iDir < 0) and (FBarWidth > MIN_BAR_WIDTH)) then
  begin
    FBarWidth := FBarWidth + iDir * BAR_STEP;
    if Assigned(FOnBarWidth) then FOnBarWidth(Self);
    // How many bars?
    SetBarCount;
    //
    SetDrawRange(rmResize);
    //
    Refresh;
  end;
  Result := FBarWidth;
end;

//===========================< Hint >==================================//


procedure TChartCentralBase.ShowHint(iZone, X,Y : Integer; bitFlag : Byte);
var
  dValue : Double;
  iIndex : Integer;
  bUseKey, bShowX, bShowY, bShowData : Boolean;
begin
  bUseKey   := HINT_KEY    and bitFlag > 0;
  bShowX    := HINT_SHOW_X and bitFlag > 0;
  bShowY    := HINT_SHOW_Y and bitFlag > 0;
  bShowData := HINT_DATA and bitFlag > 0;

  FHints.Clear;

    // get hint values
  iIndex := HitIndex(X);
  dValue := HitPrice(iZone,Y);

    // get hint string
  if bShowX then
    if bUseKey then
      FHints.Add('X='+ GetDateTimeDesc(iIndex))
    else
      FHints.Add(GetDateTimeDesc(iIndex));

  if bShowY then
    if bUseKey then
      FHints.Add(Format('Y=%.2f', [dValue]))
    else
      FHints.Add(Format('%.2f', [dValue]));

  if bShowData and (iZone >= 0) then
  begin
    FHints.Add('-');
    FChartZones[iZone].HintData(iIndex, FHints);
  end;

     // show
  DrawHint(X, Y);
end;

procedure TChartCentralBase.DrawHint(X, Y : Integer);
const
  MARGIN = 2;
var
  aBrushColor, aPenColor, aFontColor : TColor;
  iFontSize : Integer;

  aSize : TSize;
  i, iTop, iWidth, iHeight, iRight, iBottom : Integer;
begin
  if FHints.Count = 0 then Exit;

    // recover the place where the old hint has been placed
  if FHintShowed then
    FCanvas.CopyRect(FHintRect, FBitmap.Canvas, FHintRect);

    // copy GDI properties
  aBrushColor := FCanvas.Brush.Color;
  aPenColor := FCanvas.Pen.Color;
  aFontColor := FCanvas.Font.Color;
  iFontSize := FCanvas.Font.Size;

    // set font
  FCanvas.Font.Color := clBlack;
  FCanvas.Font.Size := 8;
  FCanvas.Font.Style := [];

    // get width & height of texts
  iWidth := 0; iHeight := 0;
  for i:=0 to FHints.Count-1 do
  begin
    aSize := FCanvas.TextExtent(FHints[i]);
    if aSize.cx > iWidth then
      iWidth := aSize.cx;
    iHeight := iHeight + aSize.cy;
  end;

    // get rect
  iRight := X + 5 + 2*MARGIN + iWidth;
  iBottom := Y + 5 + 2*MARGIN + iHeight;

  if iRight > FDrawRect.Right then
    FHintRect.Left := X - 5 - 2*MARGIN - iWidth
  else
    FHintRect.Left := X + 5;
  if iBottom > FDrawRect.Bottom then
    FHintRect.Top := Y - 5 - 2*MARGIN - iHeight
  else
    FHintRect.Top := Y + 5;
  FHintRect.Right := FHintRect.Left + 2*MARGIN + iWidth;
  FHintRect.Bottom := FHintRect.Top + 2*MARGIN + iHeight;

    // background
  FCanvas.Brush.Color := clWhite;
  FCanvas.Pen.Color := clWhite;
  FCanvas.Rectangle(FHintRect);

    // text
  iTop := FHintRect.Top + MARGIN;
  for i:= 0 to FHints.Count-1 do
  begin
    FCanvas.TextOut(FHintRect.Left + MARGIN, iTop, FHints[i]);
    iTop := iTop + aSize.cy;
  end;

    // recover GDI properties
  FCanvas.Brush.Color := aBrushColor;
  FCanvas.Pen.Color := aPenColor;
  FCanvas.Font.Color := aFontColor;
  FCanvas.Font.Size := iFontSize;

    //
  FHintShowed := True;
end;

procedure TChartCentralBase.HideHint;
begin
  if FHintShowed then
    FCanvas.CopyRect(FHintRect, FBitmap.Canvas, FHintRect);

  FHintShowed := False;
end;

//===========================< Draw >==================================//

procedure TChartCentralBase.DrawXScale(aCanvas : TCanvas);
begin
  if FMainCharter <> nil then
    FMainCharter.DrawXScale(
           aCanvas, FDrawRect, FStartIndex, FEndIndex, FBarWidth,
           FVLine, FGridColor);
end;

procedure TChartCentralBase.Draw(aCanvas : TCanvas; bPrint : Boolean);
begin
  with aCanvas do
  begin
    //-- background
    Brush.Color := FBackgroundColor;
    if bPrint then
    begin
      if FBackgroundColor = clBlack then
        Brush.Color := $AAAAAA;
    end;
    if not bPrint then
    begin
      FillRect(FClientRect);
    end else
    begin
      Pen.Color := clBlack;
      Rectangle(FClientRect);
    end;
    // colors
    Pen.Color := FAxisColor;
    Pen.Width := 1;
    Font.Name := FFontName;
    Font.Size := FFontSize;
    Font.Color := FFontColor;

    //-- y-axis
    if FLeftYScale then
    begin
      MoveTo(FDrawRect.Left, FDrawRect.Bottom);
      LineTo(FDrawRect.Left, FDrawRect.Top);
      FChartZones.DrawSeparators(aCanvas, FClientRect.Left, FDrawRect.Left);
    end;
    if FRightYScale then
    begin
      MoveTo(FDrawRect.Right, FDrawRect.Bottom);
      LineTo(FDrawRect.Right, FDrawRect.Top);
      FChartZones.DrawSeparators(aCanvas, FDrawRect.Right, FClientRect.Right);
    end;
    //-- x-axis
    MoveTo(FClientRect.Left, FDrawRect.Bottom);
    LineTo(FClientRect.Right, FDrawRect.Bottom);
    //--
    if (FStartIndex >= 0) and (FEndIndex >= 0) then
    begin
      // xscale
      DrawXScale(aCanvas);
      // graph
      FChartZones.Draw(aCanvas, FStartIndex, FEndIndex, FBarWidth,
                       FLeftYScale, FRightYScale, FHLine, FGridColor, FSelected , FDrawSeparator);
    end else
    begin
      TextOut(FDrawRect.Left+5, FDrawRect.Bottom - 20, 'No Data');
      // at least, draw titles
      FChartZones.DrawTitles(aCanvas, nil);
    end;
  end;
end;

procedure TChartCentralBase.Refresh;
begin
  if FNoDraw then Exit;
  //
  Draw(FBitmap.Canvas);

  if FIsMini then
  begin
    FBitmap.Canvas.Brush.Color := clBlue;
    FBitmap.Canvas.FrameRect(FClientRect);
  end;
  //
  FCanvas.Draw(0,0,FBitmap);
  //
  if Assigned(FOnRefresh) then
    FOnRefresh(Self);
end;


//=============================< Config >==========================//

// 화면설정
function TChartCentralBase.ConfigScreen : Boolean;
var
  aDlg : TChartConfig;
begin
  Result := False;
  
  aDlg := TChartConfig.Create(FChartForm);
  try
    aDlg.BkColor     := FBackgroundColor;
    aDlg.AxisColor   := FAxisColor;
    aDlg.FontName    := FFontName;
    aDlg.FontSize    := FFontSize;
    aDlg.FontColor   := FFontColor;
    aDlg.HLine       := FHLine;
    aDlg.VLine       := FVLine;
    aDlg.GridColor   := FGridColor;
    aDlg.LeftYScale  := FLeftYScale;
    aDlg.RightYScale := FRightYScale;
    aDlg.CharCount   := FYCharWidth;


    aDlg.RightMargin := FRightMargin;
    aDlg.MovingMode := FMoving;
    aDlg.InsertSeparator := FDrawSeparator;
    aDlg.BarWidth := FBarWidth;

    if aDlg.ShowModal = mrOK then
    begin
      FBackgroundColor :=  aDlg.BkColor;
      FFontName        :=  aDlg.FontName;
      FFontSize        :=  aDlg.FontSize;
      FFontColor       :=  aDlg.FontColor;
      FHLine           :=  aDlg.HLine;
      FVLine           :=  aDlg.VLine;
      FGridColor       :=  aDlg.GridColor;
      FLeftYScale      :=  aDlg.LeftYScale;
      FRightYScale     :=  aDlg.RightYScale;
      FYCharWidth      :=  aDlg.CharCount;
      FAxisColor       :=  aDlg.AxisColor;

      Zoom(aDlg.BarWidth - FBarWidth);
      //FBarWidth := aDlg.BarWidth;

      FRightMargin := aDlg.RightMargin;
      FMoving := aDlg.MovingMode;
      FDrawSeparator := aDlg.InsertSeparator;

      //
      Resize(FClientRect);
      //
      Result := True;
    end;
  finally
    aDlg.Free;
  end;
end;

function TChartCentralBase.Config(aCharter : TCharter) : Boolean;
begin
  Result := False;

  if aCharter = nil then Exit;
  //
  if aCharter.Config(FChartForm) then
  begin
    Refresh;
    
    Result := True;
  end;
end;

//=========================< Check Point >============================//

function TChartCentralBase.IndexOfZone(iX, iY : Integer) : Integer;
begin
  Result := FChartZones.IndexOfZone(iX, iY);
end;

function TChartCentralBase.IndexOfBoundary(iX, iY : Integer) : Integer;
begin
  Result := FChartZones.IndexOfBoundary(iX, iY);
end;

procedure TChartCentralBase.Hit(iX, iY : Integer);
var
  iBarIndex : Integer;
  iZone : Integer;
begin
  FSelected := nil;
  //
  iBarIndex := FStartIndex + (iX - FDrawRect.Left-1) div FBarWidth;
  iZone := IndexOfZone(iX, iY);
  //
  if iZone >= 0 then
    FSelected := FChartZones[iZone].Hit(iX, iY, FStartIndex, iBarIndex, FBarWidth);
  //
  Refresh;
end;

function TChartCentralBase.HitIndex(iX : Integer) : Integer;
var
  aRect : TRect;
begin
  Result := -1;
  //
  if GetDataCount = 0 then Exit;
  //
  aRect := FChartZones[0].DrawRect;
  //
  Result := (iX - aRect.Left-1) div FBarWidth + FStartIndex;
end;

//=========================< Insert Stickers >========================//

procedure TChartCentralBase.InsertTLine(iZone, iSX, iSY, iEX, iEY : Integer);
var
  iSIndex, iEIndex : Integer;
  dSPrice, dEPrice : Double;
  aTLine : TTrendLine;
begin
  if (FChartZones.Count-1 < iZone) or (FChartZones[iZone].Count = 0) or
     (not (FChartZones[iZone].Charters[0] is TSeriesCharter)) then Exit;
  //
  iSIndex := HitIndex(iSX);
  iEIndex := HitIndex(iEX);
  dSPrice := HitPrice(iZone, iSY);
  dEPrice := HitPrice(iZone, iEY);
  //
  aTLine := TTrendLine.Create(FChartZones[iZone].Charters[0] as TSeriesCharter);
  aTLine.SIndex := iSIndex;
  aTLine.EIndex := iEIndex;
  aTLine.SValue := dSPrice;
  aTLine.EValue := dEPrice;
  //
  FChartZones[iZone].Add(aTLine);
  FStickers.Add(aTLine);
end;

// 지지/저항선
procedure TChartCentralBase.InsertRLine(iZone, iY : Integer);
var
  dPrice : Double;
  aRLine : THorizLine;
  iZoneIndex : Integer;
begin
  if (FChartZones.Count-1 < iZone) or (FChartZones[iZone].Count = 0) or
     (not (FChartZones[iZone].Charters[0] is TSeriesCharter)) then Exit;
  //
  dPrice := HitPrice(iZone, iY);
  //
  aRLine := THorizLine.Create(FChartZones[iZone].Charters[0] as TSeriesCharter);
  aRLine.Value := dPrice;
  //
  FChartZones[iZone].Add(aRLine);
  FStickers.Add(aRLine);
end;

// 수직선
procedure TChartCentralBase.InsertVLine(iZone, iX : Integer);
var
  aVLine : TVertLine;
  iZoneIndex : Integer;
  iBarIndex : Integer;
begin
  if (FChartZones.Count-1 < iZone) or (FChartZones[iZone].Count = 0) or
     (not (FChartZones[iZone].Charters[0] is TSeriesCharter)) then Exit;
  //
  iBarIndex := HitIndex(iX);
  //
  aVLine := TVertLine.Create(FChartZones[iZone].Charters[0] as TSeriesCharter);
  aVLine.BarIndex := iBarIndex;
  //
  FChartZones[iZone].Add(aVLine);
  FStickers.Add(aVLine);
end;

//========================< Move Stickers >=========================//

function TChartCentralBase.GetMovingColor : TColor;
begin
  if FBackgroundColor = MOVING_LINE_COLOR then
    Result := clWhite
  else
    Result := MOVING_LINE_COLOR;
end;

procedure TChartCentralBase.MovingHLine(iY : Integer);
var
  aPenMode : TPenMode;
  aPenColor : TColor;
  aMovingColor : TColor;
begin
  aPenMode := FCanvas.Pen.Mode;
  aPenColor := FCanvas.Pen.Color;
  //
  with FCanvas do
  begin
    Pen.Mode := pmXOR;
    Pen.Color := GetMovingColor xor FBackgroundColor;
    //
    MoveTo(FDrawRect.Left+1, iY);
    LineTo(FDrawRect.Right, iY);
  end;
  //
  FCanvas.Pen.Mode := aPenMode;
  FCanvas.Pen.Color := aPenColor;
end;

procedure TChartCentralBase.MovingVLine(iX : Integer);
var
  aPenMode : TPenMode;
  aPenColor : TColor;
begin
  aPenMode := FCanvas.Pen.Mode;
  aPenColor := FCanvas.Pen.Color;
  //
  with FCanvas do
  begin
    Pen.Mode := pmXOR;
    Pen.Color := GetMovingColor xor FBackgroundColor;
    //
    MoveTo(iX, FDrawRect.Top+1);
    LineTo(iX, FDrawRect.Bottom);
  end;
  //
  FCanvas.Pen.Mode := aPenMode;
  FCanvas.Pen.Color := aPenColor;
end;

procedure TChartCentralBase.MovingTLine(iSX, iSY, iEX, iEY : Integer);
var
  aPenMode : TPenMode;
  aPenColor : TColor;
begin
  aPenMode := FCanvas.Pen.Mode;
  aPenColor := FCanvas.Pen.Color;
  //
  with FCanvas do
  begin
    Pen.Mode := pmXOR;
    Pen.Color := GetMovingColor xor FBackgroundColor;
    //
    MoveTo(iSX, iSY);
    LineTo(iEX, iEY);
    //
  end;
  //
  FCanvas.Pen.Mode := aPenMode;
  FCanvas.Pen.Color := aPenColor;
end;

//=====================< Misc >==============================//

procedure TChartCentralBase.Print(stTitle : String; iWidth, iHeight : Integer);
var

  aPrinter : TPrinterLe;

begin
  if FNoDraw then Exit;

  try
    aPrinter := PrinterLE;
    if not aPrinter.CanPrint then
    begin
      ShowMessage('프린터가 설치되지 않았습니다.');
      Exit;
    end;

    aPrinter.Mode := pmSetup;
    aPrinter.Title := stTitle;
    aPrinter.SetDimension(iWidth, iHeight);

    aPrinter.BeginDoc;
    Draw(aPrinter.Canvas, True);
    aPrinter.EndDoc;
  except
    ShowMessage('출력을 할 수가 없습니다. 프린터를 확인하십시오');
  end;

end;

end.
