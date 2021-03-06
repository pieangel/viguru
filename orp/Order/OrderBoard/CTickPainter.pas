unit CTickPainter;

interface

uses
  Windows, Classes, Graphics, Controls, SysUtils, ExtCtrls, Dialogs, Math,
    // lemon: data
  GleLib, CleSymbols, CleQuoteBroker;

{$INCLUDE define.txt}

const
  MAX_TP_COLUMNS = 3;


type
  TTickPainter = class
  private
      // assigned objects
    FQuote: TQuote;
    FPaintBox: TPaintBox;

      // created objects
    FBitmap: TBitmap;

      // fitler
    FUseVolumeFilter: Boolean;
    FVolumeThreshold: Integer;

      // drawing factors
    FRowCount: Integer;
    FRowHeight: Integer;
    FRowSpan: Integer;
    FColCount: Integer;
    FColSpan: Integer;

    FColWidths: array[0..MAX_TP_COLUMNS-1] of Integer;
    FLefts: array[0..MAX_TP_COLUMNS-1] of Integer;
    FRights: array[0..MAX_TP_COLUMNS-1] of Integer;
    FTopPosition: integer;
    FSelectedIndex: integer;
    FTns: TTimeNSale;


      //
    FVolume : integer;
    FAccumulVolume  : integer;
    FDepth: TMarketDepth;
    FShowFillBar: Boolean;

    FLastData : TTimeNSale;
    FWhite    : boolean;
    FLine     : integer;
    FLastCount: integer;
    
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
    procedure SetTopPosition(const Value: integer);
    function GetFillRect: TRect;
    procedure SetShowFillBar(const Value: Boolean);
  public
    constructor Create;
    destructor Destroy; override;

    procedure Update;
    procedure Update2;
    procedure Resize;
    //procedure
    procedure TickClick( X, Y : integer );
    procedure SetTns( iRow : integer );

    property Quote: TQuote read FQuote write SetQuote;
    property Tns  : TTimeNSale read FTns;
    property Depth  : TMarketDepth read FDepth;
    property PaintBox: TPaintBox read FPaintBox write SetPaintBox;
    property RowCount: Integer read FRowCount write SetRowCount;
    property TopPosition : integer read FTopPosition write SetTopPosition;
    property SelectedIndex : integer read FSelectedIndex;
    property ShowFillBar  : Boolean read FShowFillBar write SetShowFillBar;
    property LastCount  : integer read FLastCount write FLastCount;

    property UseVolumeFilter: Boolean read FUseVolumeFilter write FUseVolumeFilter;
    property VolumeThreshold: Integer read FVolumeThreshold write FVolumeThreshold;
  end;

implementation

uses GAppEnv, CleFQN, GleConsts;


//--------------------< Create/Destroy >----------------------//

constructor TTickPainter.Create;
begin
  FBitmap := TBitmap.Create;

  FDepth := TMarketDepth.Create( nil );
  FTns   := nil;

  FRowHeight := 17;
  FRowCount := 10;
  FColCount := 3;
  FLastCount:= 0;
  FColWidths[0] := 60;
  FColWidths[1] := 70;
  FColWidths[2] := 30;

  FSelectedIndex  := -1;

  FVolume := 0;
  FAccumulVolume  := 0;

  FLastData := nil;
  SetDimension;

  FWhite := false;
  FLine  := 1;

end;

destructor TTickPainter.Destroy;
begin
  FBitmap.Free;
  FDepth.Free;
  inherited;
end;

procedure TTickPainter.SetDimension;
begin

  if FPaintBox = nil then Exit;


  FRowSpan :=  FPaintBox.Parent.Width - 2;//FPaintBox.Width - 2;

  FColWidths[0] := FRowSpan div 3 + 3;
  FColWidths[2] := FRowSpan div 4;
  FColWidths[1] := FRowSpan - (FColWidths[0] + FColWidths[2] + 3);


  FColSpan := (FRowCount+1) * FRowHeight; // + colume header line

  FLefts[0] := 0;
  FRights[0] := FColWidths[0];
  FLefts[1] := FRights[0];
  FRights[1] := FRights[0] + FColWidths[1];
  FLefts[2] := FRights[1];
  FRights[2] := FRights[1] + FColWidths[2];
end;
//-------------------------< Set Routines >-------------------//

procedure TTickPainter.SetPaintBox(aBox : TPaintBox);
begin
  if aBox = nil then Exit;

  FPaintBox := aBox;
  FPaintBox.OnPaint := PaintProc;

  Resize;
end;

procedure TTickPainter.SetQuote(const Value: TQuote);
var
  aTmp : TQuote;
begin
  FQuote := Value;
  FLastCount := -1;
  FLastData  := nil;

  SetDimension;

  DrawBackground;
  DrawTicks;

  ApplyDrawing;
end;

const
  MAX_ROWCOUNT = 50;
  MIN_ROWCOUNT = 5;


procedure TTickPainter.SetRowCount(iRowCount : Integer);
begin
   {
  iRowCount := Max(Min(iRowCount, MAX_ROWCOUNT), MIN_ROWCOUNT);

  FRowCount := iRowCount;

  SetDimension;

  if FPaintBox <> nil then
    FPaintBox.Height := FColSpan + 1;
}

  iRowCount := Max(Min(iRowCount, MAX_ROWCOUNT), MIN_ROWCOUNT);

  FRowCount := iRowCount;

  SetDimension;

  if FPaintBox <> nil then
    FPaintBox.Height := FColSpan + 1;

end;

procedure TTickPainter.SetShowFillBar(const Value: Boolean);
begin
  FShowFillBar := Value;
  if Value then begin
    if FTopPosition = 0 then
      FTopPosition  := 100;
  end
  else begin
    FTopPosition  := 0;
  end;
end;

procedure TTickPainter.SetTopPosition(const Value: integer);
begin
  if (Value < 0) or (Value > FColSpan) then
    Exit;

  FTopPosition := Value;
end;

procedure TTickPainter.TickClick(X, Y: integer);
var
  iPos : integer;
begin
  if (X < Flefts[0]) or (X > FRights[2]) or
     (Y < FTopPosition ) or (Y > (FColSpan + FTopPosition)) then
     Exit;

  iPos := (Y - FTopPosition) div FRowHeight;

  if (iPos = 0) or ( iPos > FRowCount)  then
    Exit;

  SetTns( iPos );
end;

//-----------------------< Drawing control Routines >-------------------------//

procedure TTickPainter.Resize;
begin
  if FPaintBox = nil then Exit;

  try
    FBitmap.Width := FPaintBox.Width;
    FBitmap.Height := FPaintBox.Height;
    FBitmap.Canvas.Font.Name := FPaintBox.Font.Name;
    FBitmap.Canvas.Font.Size := FPaintBox.Font.Size;

    //RowCount  := FBitMap.Height div FRowHeight;
    //
  except
    //FBitmap.ha
  end;
end;

procedure TTickPainter.PaintProc(Sender : TObject);
begin
  Resize;

  DrawBackground;
  DrawTicks;

  ApplyDrawing;
end;


procedure TTickPainter.Update;
begin
  DrawTicks;

  ApplyDrawing;
end;

procedure TTickPainter.Update2;
begin
  if not FShowFillBar then Exit;
  
  ApplyDrawing;
end;

//-----------------------< Actual Drawing Routines >-------------------------//

procedure TTickPainter.SetTns(iRow: integer);
var
  iCount : integer;
  stLog  : string;
begin
  if FQuote = nil then
    Exit;

  FSelectedIndex := iRow-1;


  if FSelectedIndex < 0 then Exit;

  FTns  := FQuote.Sales[FSelectedIndex];
  if FTns = nil then Exit;

  FDepth.Price  := FQuote.Asks[0].Price;
  FDepth.Volume := FQuote.Asks[0].Volume;

  FVolume := 0;
  FAccumulVolume  := 0;
  {
  stLog := Format( '%d[%d] - %.*n , %d ', [FQuote.Sales.Count, FSelectedIndex,
      FQuote.Symbol.Spec.Precision, FTns.Price, FTns.Volume ]);
  gEnv.OnLog( self, stLog );
  }

  FPaintBox.Repaint;

end;


function TTickPainter.GetFillRect: TRect;
var
  iEnd, iCur, iRight : integer;
  dTmp : double;
  stLog : string;
begin
  iRight := FLefts[0]+1;
  Result := Rect( FLefts[0]+1, 5 * FRowHeight+1, iRight, 6 * FRowHeight );

  if (FTns = nil) or (FDepth = nil)then Exit;

  if FDepth.Price <> FQuote.Asks[0].Price then
  begin
    FDepth.Price  := FQuote.Asks[0].Price;
    FDepth.Volume := FQuote.Asks[0].Volume;
    FVolume := 0;
    Exit;
  end;

  iCur  := FDepth.Volume - FQuote.Asks[0].Volume;
  if iCur = 0 then Exit;
  if iCur < 0 then begin
    FDepth.Volume := FQuote.Asks[0].Volume;
    Exit;
  end;

  if FDepth.Volume = 0 then begin
    Exit;
  end
  else begin
    dTmp  := FRights[2] / FDepth.Volume;
    iRight  := Round( dTmp * iCur );
  end;
  Result := Rect( FLefts[0], 5 * FRowHeight+1, iRight, 6 * FRowHeight );
  {stLog := Format('%.*n, %d(%d), %d(%d)', [ FQuote.Symbol.Spec.Precision,
    FDepth.Price, FDepth.Volume,  FQuote.Asks[0].Volume, FRights[2], iRight ]);
  gEnv.OnLog( self, stLog );
  }
end;


procedure TTickPainter.DrawBackground;
const
  COL_TITLES : array[0..2] of String = ('????','??????','????');
var
  i, iTop : Integer;
begin
  if FPaintBox = nil then Exit;

  with FBitmap.Canvas do
  begin
    Brush.Color := clWhite;
    Pen.Color := clWhite;

    // background
    FillRect(FPaintBox.ClientRect);

    // grid line horizontal
    Pen.Color := clLtGray;

    for i:=0 to FRowCount+2 do
    begin
      iTop := i * FRowHeight + FTopPosition;
      MoveTo(0, iTop);
      LineTo(FRowSpan, iTop);
    end;

    // grid line vertical
    MoveTo(FLefts[0], FTopPosition );
    LineTO(FLefts[0], FColSpan+FTopPosition);

    for i:=0 to FColCount-1 do
    begin
      MoveTo(FRights[i], FTopPosition);
      LineTo(FRights[i], FColSpan+FTopPosition);
    end;

    // titles
    for i:=0 to 2 do
    begin
      DrawRect(FBitmap.Canvas, Rect(FLefts[i]+1, FTopPosition+1 , FRights[i], FRowHeight+FTopPosition),
               COL_TITLES[i], clBtnFace, clBlack, taCenter);
      Pen.Color := clBlack;
      PolyLine([Point(FLefts[i]+1,  FRowHeight+FTopPosition),
                       Point(FRights[i], FRowHeight+FTopPosition),
                       Point(FRights[i], FTopPosition+1)]);
      Pen.Color := clWhite;
      PolyLine([Point(FLefts[i]+1,  FRowHeight+FTopPosition),
                       Point(FLefts[i]+1,  FRowHeight+FTopPosition+1),
                       Point(FRights[i], FRowHeight+FTopPosition+1)]);               
    end;
  end;
end;

procedure TTickPainter.DrawTicks;
var
  iPos, i, iTop, iBot, iCount : Integer;
  aSale: TTimeNSale;
  aBack , aColor: TColor;
  stTmp : string;

begin
  if (FQuote = nil) or (FQuote.Symbol = nil)
     or (FQuote.Symbol.Spec = nil) then Exit;

  if FQuote.Sales.Count < 1 then Exit;

  if FLastData = nil then
    iCount  := 1
  else iCount := FQuote.Sales.Count - FLastCount;

  FLine := 1;

  for I := 0 to  FQuote.Sales.Count-1 do
  begin

    aSale := FQuote.Sales[i];

    //if aSale = FLastData then Exit;
    FLastData := aSale;

    if (FLine -1 ) >= RowCount then
    begin
      FLine := 1;
      FWhite := not FWhite;
    end;

    if ( FLine mod 2 ) <> 0 then
      aBack := clWhite
    else
      aBack := GRID_REVER_COLOR;

    iTop := (FLine) * FRowHeight + FTopPosition ;
    iBot := iTop + FRowHeight ;


    DrawRect(FBitmap.Canvas, Rect(FLefts[0]+1, iTop+1, FRights[0], iBot),
             FormatDateTime('hh:nn:ss', aSale.Time ),
             aBack, clBlack, taCenter);

    stTmp :=  Format('%.*n', [FQuote.Symbol.Spec.Precision, aSale.Price]);

    DrawRect(FBitmap.Canvas, Rect(FLefts[1]+1, iTop+1, FRights[1], iBot),
             stTmp,  aBack, clBlack, taRightJustify);
    if aSale.Side > 0 then
      DrawRect(FBitmap.Canvas, Rect(FLefts[2]+1, iTop+1, FRights[2], iBot),
               Format('%.0n', [aSale.Volume*1.0]),
               aBack, clRed, taRightJustify)
    else
      DrawRect(FBitmap.Canvas, Rect(FLefts[2]+1, iTop+1, FRights[2], iBot),
               Format('%.0n', [aSale.Volume*1.0]),
               aBack, clBlue, taRightJustify);

    inc( FLine );

    if FRowCount < FLine then break;
    
  end;

  FLastCount  := FQuote.Sales.Count ;

end;



procedure TTickPainter.ApplyDrawing;
begin
  if FPaintBox = nil then Exit;

  BitBlt( FPaintBox.Canvas.Handle,
    FLefts[0]+1, 1, FBitmap.Width, FBitmap.Height,
    FBitmap.Canvas.Handle,
    FLefts[0]+1, 1 , SRCCOPY);

 // FPaintBox.Canvas.Draw(0,0, FBitmap);
end;

end.
