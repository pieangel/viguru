unit CleAnalPainter;

interface

uses
  Windows, Classes, Graphics, Controls, SysUtils, ExtCtrls, Dialogs, Math,
    // lemon: data
  GleLib, CleSymbols, CleQuoteBroker, ClePriceItems

  ;

const
  MAX_TP_COLUMNS = 5;

type
  TAnalPainter = class
  private
      // assigned objects
    FQuote: TQuote;
    FPaintBox: TPaintBox;

      // created objects
    FBitmap: TBitmap;
      // drawing factors
    FRowCount: Integer;
    FRowHeight: Integer;
    FRowSpan: Integer;
    FColCount: Integer;
    FColSpan: Integer;

    FColWidths: array[0..MAX_TP_COLUMNS-1] of Integer;
    FLefts: array[0..MAX_TP_COLUMNS-1] of Integer;
    FRights: array[0..MAX_TP_COLUMNS-1] of Integer;
    FPrice : array of double;
    FWidth: integer;
    FHeight: integer;
    FFilter: integer;
    FSelected: integer;
    FBPrice: boolean;
    FSelectPrice: double;
    FSelectHoga: integer;

    procedure SetQuote(const Value: TQuote);

      // set routines
    procedure SetPaintBox(aBox : TPaintBox);
    procedure SetRowCount(iRowCount : Integer);

      // drawing routines
    procedure DrawBackground;
    procedure DrawTicks;

      // misc.
    procedure SetDimension;
    procedure ApplyDrawing;
    procedure PaintProc(Sender : TObject);
    procedure SetFilter(const Value: integer);
  public
    aRect : TRect;

    constructor Create( iH, iW :integer); overload;
    destructor Destroy; override;

    procedure Update;
    procedure Resize;
    procedure UpdateSize;
    procedure DrawAnal( dPrice : double; iCol, iRow : integer; bDraw : boolean = true );
    function GetFontColor( dPrice, dPrev : double ) : TColor;
    function GetPrice( X, Y : integer ) : double;
    function GetHoga( X, Y : integer; var cLS : char ) : integer;
    function GetSelectedPrice( iH : integer; dPrice : double ) : string;

    property Quote: TQuote read FQuote write SetQuote;
    property PaintBox: TPaintBox read FPaintBox write SetPaintBox;
    property RowCount: Integer read FRowCount write SetRowCount;
    property Height : integer read FHeight write FHeight;
    property Width  : integer read FWidth write FWidth;
    property Filter : integer read FFilter Write SetFilter;

    ///
    property SelectHoga : integer read FSelectHoga;
    property SelectPrice: double read FSelectPrice;
    property BPrice : boolean read FBPrice write FBPrice;

  end;

implementation

uses CleDistConst, CleKrxSymbols, GAppEnv;

//--------------------< Create/Destroy >----------------------//

constructor TAnalPainter.Create( iH, iW :integer);
begin
  FBitmap := TBitmap.Create;

  FHeight := iH;
  FWidth  := iW;

  FRowHeight := 16;
  FRowCount := 19;
  FColCount := 5;
  FColWidths[0] := 50;
  FColWidths[1] := 50;
  FColWidths[2] := 50;
  FColWidths[3] := 45;
  FColWidths[4] := FWidth - FColWidths[0] - FColWidths[1] -FColWidths[2] - FColWidths[3];


  FSelectHoga := -1;
  FSelectPrice := -1;
  FBPrice := true;

  SetDimension;
end;

destructor TAnalPainter.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

procedure TAnalPainter.SetDimension;
begin
  FRowSpan := FWidth;
  FColSpan := (FRowCount) * FRowHeight; // + colume header line

  FLefts[0] := 0;
  FRights[0] := FColWidths[0];
  FLefts[1] := FRights[0];
  FRights[1] := FRights[0] + FColWidths[1];
  FLefts[2] := FRights[1];
  FRights[2] := FRights[1] + FColWidths[2];
  //
  FLefts[3] := FRights[2];
  FRights[3] := FRights[2] + FColWidths[3];

  FLefts[4] := FRights[3];
  FRights[4] := FRights[3] + FColWidths[4];

end;
procedure TAnalPainter.SetFilter(const Value: integer);
begin
  if Value < 0 then
    Exit;
  FFilter := Value;
end;

//-------------------------< Set Routines >-------------------//

procedure TAnalPainter.SetPaintBox(aBox : TPaintBox);
begin
  if aBox = nil then Exit;

  FPaintBox := aBox;


  FPaintBox.Font.Name := '굴림체';
  FPaintBox.Font.Size := 9;
  FBitmap.Canvas.Brush.Color := BACK_COLOR;

  Resize;

  FPaintBox.OnPaint := PaintProc;
end;

procedure TAnalPainter.SetQuote(const Value: TQuote);
begin
  FQuote := Value;

  if FQuote = nil then Exit;

  RowCount := ((FQuote.Asks.Size + 4) * 2) + 3;

  if FQuote.Asks.Size = 5 then
    SetLength( FPrice, 18 )
  else
    SetLength( FPrice, 28 );

  DrawBackground;
  DrawTicks;

  ApplyDrawing;
end;

const
  MAX_ROWCOUNT = 19;
  MIN_ROWCOUNT = 19;

procedure TAnalPainter.SetRowCount(iRowCount : Integer);
begin
  //iRowCount := Max(Min(iRowCount, MAX_ROWCOUNT), MIN_ROWCOUNT);

  FRowCount := iRowCount;

  SetDimension;

  if FPaintBox <> nil then
    FPaintBox.Height := FColSpan + 1;
end;

//-----------------------< Drawing control Routines >-------------------------//

procedure TAnalPainter.Resize;
begin
  if FPaintBox = nil then Exit;

  FBitmap.Width :=  FPaintBox.Width;
  FBitmap.Height := FPaintBox.Height;

  FBitmap.Canvas.Font.Name := FPaintBox.Font.Name;
  FBitmap.Canvas.Font.Size := FPaintBox.Font.Size;
end;

procedure TAnalPainter.PaintProc(Sender : TObject);
begin
  Resize;

  DrawBackground;
  DrawTicks;

  ApplyDrawing;
end;


procedure TAnalPainter.Update;
begin
  if FQuote = nil then Exit;
  DrawTicks;
  ApplyDrawing;
end;

procedure TAnalPainter.UpdateSize;
begin
  FColWidths[0] := 50;
  FColWidths[1] := 50;
  FColWidths[2] := 50;
  FColWidths[3] := 45;
  FColWidths[4] := FWidth - FColWidths[0] - FColWidths[1] -FColWidths[2] - FColWidths[3];
  Resize;
  SetDimension;

end;

//-----------------------< Actual Drawing Routines >-------------------------//



procedure TAnalPainter.DrawBackground;
const
  ColTitle : array [0..MAX_TP_COLUMNS-1] of string = ( '호가','잔량','건수','미분석', '세력분포도');
var
  i, iTop, iR, iH : Integer;
  oRect : TRect;
  stTmp : string;
  aColr : TColor;
begin
  if FPaintBox = nil then Exit;

  with FBitmap.Canvas do
  begin
    Brush.Color := BACK_COLOR;
    FillRect( FPaintBox.ClientRect);
    Brush.Color := LINE_COLOR;
    //n.Color := LINE_COLOR;
    // background
    oRect := FPaintBox.ClientRect;
    aRect.Left  := oRect.Left + 1;
    aRect.Top   := oRect.Top  + 1;
    aRect.Right := oRect.Right- 1;
    aRect.Bottom:= orect.Bottom-1;

    //ameRect(FPaintBox.ClientRect);
    FrameRect( aRect );
    // grid line horizontal
    Pen.Color := LINE_COLOR;

    for i:=0 to FColCount-2 do
    begin
      MoveTo(FRights[i]+1, aRect.Top );
      LineTo(FRights[i]+1, aRect.Bottom);
    end;

    MoveTo(aRect.Left , aRect.Top + FRowHeight );
    LineTo(aRect.Right, aRect.Top + FRowHeight );

    // titles

    for i := 0 to MAX_TP_COLUMNS - 1 do begin

      if i = (MAX_TP_COLUMNS-1) then
        iR := -2
      else iR := 1;


      DrawRect(FBitmap.Canvas, Rect(FLefts[i]+2, 2, FRights[i]+ iR, FRowHeight+1),
                ColTitle[i] , INFO_TITLE_COLOR, clBlack, taCenter);

    end;
  end;
end;

procedure TAnalPainter.DrawAnal(dPrice : double; iCol, iRow: integer; bDraw : boolean);
var
  aInfo : TPriceItem;
  stTmp : string;
  aDist : TForceDist;
  k, iDonNo : integer;
  bkColor : TColor;
begin

  if (iRow > ((FRowCount-1) div 2)) then begin
    bkColor := BID_BACK_COLOR ;
    if iRow = FRowCount-1 then
      bkColor := BID_TITLE_COLOR;
  end
  else begin
    bkColor := ASK_BACK_COLOR;
    if iRow = 1 then
      bkColor := ASK_TITLE_COLOR;
  end;

  if not bDraw then begin
    DrawRect(FBitmap.Canvas, Rect(FLefts[iCol]+2, 2+ ( FRowHeight * iRow),
              FRights[iCol]+ 1, FRowHeight* (iRow+1)+2),
              '' , bkColor, clBlack, taLeftJustify);

    DrawRect(FBitmap.Canvas, Rect(FLefts[iCol+1]+2, 2+ ( FRowHeight * iRow),
              FRights[iCol+1]-2, FRowHeight* (iRow+1)+2),
              '' , bkColor, clBlack, taRightJustify);
    Exit;
  end;

  aInfo := FQuote.PriceAxis.Find( dPrice );
  if aInfo = nil  then
    Exit;

  if aInfo.EventCount > 1 then
  begin
    aInfo.GetNumberOfCases;  
  end;

  stTmp := '  ';
  iDonNo := 0;

  for k := 0 to aInfo.ForceList.Count-1  do begin
    aDist := TForceDist( aInfo.ForceList.Items[k]);
    if (aDist.Qty >= FFilter) and (not aDist.DonNo)then
      stTmp := stTmp + Format('%d', [aDist.Qty] ) + '  '
    else if aDist.DonNo then
      inc(iDonNo, aDist.Qty );
  end;

  DrawRect(FBitmap.Canvas, Rect(FLefts[iCol]+2, 2+ ( FRowHeight * iRow),
            FRights[iCol]+ 1, FRowHeight* (iRow+1)+2),
            IntToStr(iDonNo) , bkColor, clFuchsia, taRightJustify);

  DrawRect(FBitmap.Canvas, Rect(FLefts[iCol+1]+2, 2+ ( FRowHeight * iRow),
            FRights[iCol+1] -2, FRowHeight* (iRow+1)+2),
            stTmp , bkColor, clBlack, taLeftJustify);

end;

procedure TAnalPainter.DrawTicks;
var
  aColor, bkColor: TColor;
  stTxt, stTmp, stLog : string;
  i, iPrec, iH, iR, index : integer;
  dHigh, dPrev : double;
begin

  if (FQuote = nil) or (FQuote.Symbol = nil)
     or (FQuote.Symbol.Spec = nil) then Exit;

  dPrev := FQuote.Symbol.PrevClose;
  iPrec := FQuote.Symbol.Spec.Precision;

  iR := 1;
  iH := 1;
  stTxt := Format('%.*n', [iPrec, FQuote.Last]);

  stTmp := Format( '%d', [FQuote.Asks.VolumeTotal ]);
  DrawRect(FBitmap.Canvas, Rect(FLefts[1]+2, 2+ ( FRowHeight * iH),
            FRights[1]+ iR, FRowHeight* (iH+1) +2),
            stTmp , ASK_TITLE_COLOR, clBlack, taRightJustify);

  stTmp := Format( '%d', [FQuote.Asks.CntTotal ]);
  DrawRect(FBitmap.Canvas, Rect(FLefts[2]+2, 2+ ( FRowHeight * iH),
            FRights[2]+ iR, FRowHeight* (iH+1) +2),
            stTmp , ASK_TITLE_COLOR, clBlack, taRightJustify);

  DrawAnal( dHigh, 3, iH, false );

  inc( iH );
  index := FQuote.Asks.Size-1;
  if index < 0 then
    exit;
  dHigh := TicksFromPrice(FQuote.Symbol, FQuote.Asks[index].Price,  4);
  for i := 0 to 3  do begin
    stTmp := GetSelectedPrice( iH, dHigh ) ;
    aColor := GetFontColor( dHigh, dPrev );

    FPrice[iH-2] := dHigh;
    DrawRect(FBitmap.Canvas, Rect(FLefts[0]+2, 2+ ( FRowHeight * iH),
              FRights[0]+ iR, FRowHeight* (iH+1) +2),
              stTmp , ASK_BACK_COLOR, aColor, taRightJustify);


    DrawRect(FBitmap.Canvas, Rect(FLefts[1]+2, 2+ ( FRowHeight * iH),
              FRights[1]+ iR, FRowHeight* (iH+1) +2),
              '' , ASK_BACK_COLOR, clBlack, taRightJustify);


    DrawRect(FBitmap.Canvas, Rect(FLefts[2]+2, 2+ ( FRowHeight * iH),
              FRights[2]+ iR, FRowHeight* (iH+1) +2),
              '' , ASK_BACK_COLOR, clBlack, taRightJustify);

    DrawAnal( dHigh, 3, iH, false );

    inc( iH );
    dHigh := TicksFromPrice(FQuote.Symbol, dHigh,  -1);
  end;


  for i := FQuote.Asks.Size - 1 downto 0 do
  begin

    bkColor := ASK_BACK_COLOR;
    stTmp := GetSelectedPrice( iH, FQuote.Asks[i].Price );
    if stTmp = stTxt  then
      bkColor := clYellow;

    aColor := GetFontColor( FQuote.Asks[i].Price, dPrev );

    FPrice[iH-2] := FQuote.Asks[i].Price;
    DrawRect(FBitmap.Canvas, Rect(FLefts[0]+2, 2+ ( FRowHeight * iH),
              FRights[0]+ iR, FRowHeight* (iH+1) +2),
              stTmp , bkColor, aColor, taRightJustify);

    stTmp := Format( '%d', [FQuote.Asks[i].Volume ]);
    DrawRect(FBitmap.Canvas, Rect(FLefts[1]+2, 2+ ( FRowHeight * iH),
              FRights[1]+ iR, FRowHeight* (iH+1) +2),
              stTmp , ASK_BACK_COLOR, clBlack, taRightJustify);


    stTmp := Format( '%d', [FQuote.Asks[i].Cnt ]);
    DrawRect(FBitmap.Canvas, Rect(FLefts[2]+2, 2+ ( FRowHeight * iH),
              FRights[2]+ iR, FRowHeight* (iH+1) +2),
              stTmp , ASK_BACK_COLOR, clBlack, taRightJustify);

    DrawAnal( FQuote.Asks[i].Price, 3, iH );

    inc( iH);
  end;

  //FBitmap.Canvas.Pen.Color := LINE_COLOR;
  FBitmap.Canvas.MoveTo(aRect.Left , aRect.Top + FRowHeight* iH );
  FBitmap.Canvas.LineTo(aRect.Right, aRect.Top + FRowHeight* iH );

  aColor := clBlue;
  for i := 0 to FQuote.Asks.Size - 1 do
  begin

   bkColor := BID_BACK_COLOR;
   stTmp := GetSelectedPrice( iH, FQuote.Bids[i].Price ) ;

   if stTmp = stTxt  then
      bkColor := clYellow;

    aColor := GetFontColor( FQuote.Bids[i].Price, dPrev );

    FPrice[iH-2] := FQuote.Bids[i].Price;
    DrawRect(FBitmap.Canvas, Rect(FLefts[0]+2, 2+ ( FRowHeight * iH),
              FRights[0]+ iR, FRowHeight* (iH+1) +2),
              stTmp , bkColor, aColor, taRightJustify);

    stTmp := Format( '%d', [FQuote.Bids[i].Volume ]);
    DrawRect(FBitmap.Canvas, Rect(FLefts[1]+2, 2+ ( FRowHeight * iH),
              FRights[1]+ iR, FRowHeight* (iH+1) +2),
              stTmp , BID_BACK_COLOR, clBlack, taRightJustify);


    stTmp := Format( '%d', [FQuote.Bids[i].Cnt ]);
    DrawRect(FBitmap.Canvas, Rect(FLefts[2]+2, 2+ ( FRowHeight * iH),
              FRights[2]+ iR, FRowHeight* (iH+1) +2),
              stTmp , BID_BACK_COLOR, clBlack, taRightJustify);

    DrawAnal( FQuote.Bids[i].Price, 3, iH );

    inc( iH);
  end;


  dHigh := TicksFromPrice(FQuote.Symbol, FQuote.Bids[ FQuote.Bids.Size-1].Price,  -1);

  for i := 0 to 3  do begin
    stTmp := GetSelectedPrice( iH, dHigh ) ;
    aColor := GetFontColor( dHigh, dPrev );

    FPrice[iH-2] := dHigh;

    DrawRect(FBitmap.Canvas, Rect(FLefts[0]+2, 2+ ( FRowHeight * iH),
              FRights[0]+ iR, FRowHeight* (iH+1) +2),
              stTmp , BID_BACK_COLOR, aColor, taRightJustify);


    DrawRect(FBitmap.Canvas, Rect(FLefts[1]+2, 2+ ( FRowHeight * iH),
              FRights[1]+ iR, FRowHeight* (iH+1) +2),
              '' , BID_BACK_COLOR, clBlack, taRightJustify);


    DrawRect(FBitmap.Canvas, Rect(FLefts[2]+2, 2+ ( FRowHeight * iH),
              FRights[2]+ iR, FRowHeight* (iH+1) +2),
              '' , BID_BACK_COLOR, clBlack, taRightJustify);

    DrawAnal( dHigh, 3, iH, false );

    inc( iH );
    dHigh := TicksFromPrice(FQuote.Symbol, dHigh,  -1);
  end;
 {
  for i := 0 to High( FPrice ) do
  begin
    stLog := format('%d :  %.2f ', [ i,  FPrice[i] ]);
    gEnv.DoLog(WIN_TEST, stLog);
  end;
  }

  //gEnv.DoLog(WIN_TEST, '');

  stTmp := Format( '%d', [FQuote.Bids.VolumeTotal ]);
  DrawRect(FBitmap.Canvas, Rect(FLefts[1]+2, 2+ ( FRowHeight * iH),
            FRights[1]+ iR, FRowHeight* (iH+1) +2),
            stTmp , BID_TITLE_COLOR, clBlack, taRightJustify);
  stTmp := Format( '%d', [FQuote.Bids.CntTotal ]);
  DrawRect(FBitmap.Canvas, Rect(FLefts[2]+2, 2+ ( FRowHeight * iH),
            FRights[2]+ iR, FRowHeight* (iH+1) +2),
            stTmp , BID_TITLE_COLOR, clBlack, taRightJustify);

  DrawAnal( dHigh, 3, iH, false );


end;

function TAnalPainter.GetFontColor(dPrice, dPrev: double): TColor;
begin
  if dPrice = dPrev then
    Result := clBlack
  else if dPrice >= dPrev then
    Result := clRed
  else
    Result := clBlue;

end;

function TAnalPainter.GetHoga(X, Y: integer; var cLS : char): integer;
var iDiv : integer;
begin
  Result := -1;
  if  X > FRights[2] then
    Exit;

  if (Y > (FRowHeight * (FRowCount+1))) or ( Y < (FRowHeight * 2) )then
    Exit;

  iDiv := Y div FRowHeight  ;
  if iDiv in [0, 1, FRowCount-1] then
    Exit;

  if iDiv in [6..10] then begin
    Result := abs( iDiv - 10 ) ;
    cLS := 'S';
    FSelectHoga := iDiv;
    FSelectPrice := -1;
    Update;
  end
  else if iDiv in [11..15] then begin
    Result :=  iDiv - 11;
    cLS := 'L';
    FSelectHoga := iDiv;
    FSelectPrice := -1;
    Update;
  end;


end;

function TAnalPainter.GetPrice(X, Y: integer): double;
var iDiv : integer;
begin
  Result := -1;
  if  X > FRights[2] then
    Exit;

  if (Y > (FRowHeight * (FRowCount+1))) and ( Y < (FRowHeight * 2) )then
    Exit;

  iDiv := Y div FRowHeight  ;
  // 타이틀, 건수 빼준다
  dec( iDiv , 2 );
  if (iDiv >=0) and (high(FPrice) >= iDiv )then begin
    FSelectPrice := FPrice[ iDiv ];
    Result := FSelectPrice;
    FSelectHoga := -1;
    Update;
  end;
end;

function TAnalPainter.GetSelectedPrice(iH: integer; dPrice: double): string;
var
  stTxt : string;
begin
  stTxt := '';
  if (FBPrice) and (FSelectPrice>0) then begin
    if FPrice[ iH-2 ] = FSelectPrice then
      stTxt := '▶';
  end
  else if ( not FBPrice) and ( FSelectHoga > 0) then begin
    if iH = FSelectHoga then
      stTxt := '▶';
  end;
  Result := Format('%s%.*n', [ stTxt, FQuote.Symbol.Spec.Precision, dPrice] );
end;

procedure TAnalPainter.ApplyDrawing;
begin

  if FPaintBox = nil then Exit;

  FPaintBox.Canvas.Draw(0,0, FBitmap);

end;

end.
