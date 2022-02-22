unit CInfoPainter;

interface

uses
  Windows, Classes, Graphics, Controls, SysUtils, ExtCtrls, Dialogs, Math,
    // lemon: data
  GleLib,

  CleSaveItems
  ;

const
  MAX_TP_COLUMNS = 2;

Const
  BACK_COLOR  = $EACAB3;
  ASK_BACK_COLOR  = $FFF7EF;
  ASK_TITLE_COLOR = $FFEBDE;

  BID_BACK_COLOR  = $EFEFFF;
  BID_TITLE_COLOR = $DEDBFF;

  INFO_TITLE_COLOR = $E3D5CD;

  LINE_COLOR  = $94715A;

  DIST_DATA = $E7E3E7;
  Dist_TITLE = $EFEFFF;


  COL_TITLES : array[0..3] of String = ('F','C','P','Avg');

type
  TInfoPainter = class
  private
      // assigned objects

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
    FWidth: integer;
    FHeight: integer;

    FSecX : array of integer;
    FSecVal: array of double;
    FSecUnit: integer;
    FMaxSec: double;
    FMinSec: double;

    iPrec, idiv : array [0..2] of integer;
    FPutColor: TColor;
    FCalColor: TColor;
    FFutColor: TColor;
    FQuoteDelayItem: TQuoteDelayItem;
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
  public

    FutGrdColor : array of TColor;
    PutGrdColor : array of TColor;
    CalGrdColor : array of TColor;

    constructor Create( iH, iW :integer); overload;
    destructor Destroy; override;

    procedure Update( aItem : TQuoteDelayItem );
    procedure Resize;
    procedure UpdateSize;

    property QuoteDelayItem : TQuoteDelayItem read FQuoteDelayItem write FQuoteDelayItem;

    property PaintBox: TPaintBox read FPaintBox write SetPaintBox;
    property RowCount: Integer read FRowCount write SetRowCount;
    property Height : integer read FHeight write FHeight;
    property Width  : integer read FWidth write FWidth;

    property SecUnit : integer read FSecUnit write FSecUnit;
    property MaxSec  : double read FMaxSec  write FMaxSec;
    property MinSec  : double read FMinSec  write FMinSec;

    property FutColor : TColor read FFutColor write FFutColor;
    property CalColor : TColor read FCalColor write FCalColor;
    property PutColor : TColor read FPutColor write FPutColor;

    procedure UpdateParam;

  end;

implementation

uses
  GAppEnv;

//--------------------< Create/Destroy >----------------------//

constructor TInfoPainter.Create( iH, iW :integer);
begin
  FBitmap := TBitmap.Create;

  FHeight := iH;
  FWidth  := iW;

  FRowHeight := 17;
  FRowCount := 4;
  FColCount := 2;
  FColWidths[0] := 40;
  FColWidths[1] := FWidth - FColWidths[0];
  FSecUnit  := 10;

  SetLength( FSecX, FsecUnit+1 );
  SetLength( FSecVal, FSecUnit);

  SetLength( FutGrdColor, FsecUnit );
  SetLength( PutGrdColor, FsecUnit );
  SetLength( CalGrdColor, FsecUnit );

  FMaxSec := gEnv.QuoteSpeed.MaxSec;
  FMinSec := gEnv.QuoteSpeed.MinSec;

  //FQuoteDelayItem := nil;
  FQuoteDelayItem:= TQuoteDelayItem.Create( nil );

  SetDimension;
end;

destructor TInfoPainter.Destroy;
begin
  FPaintBox.OnPaint := nil;
  FQuoteDelayItem.Free;
  FBitmap.Free;
  inherited;
end;

procedure TInfoPainter.SetDimension;
begin
  FRowSpan := FWidth;
  FColSpan := (FRowCount) * FRowHeight; // + colume header line

  FLefts[0] := 0;
  FRights[0] := FColWidths[0];
  FLefts[1] := FRights[0];
  FRights[1] := FRights[0] + FColWidths[1];

end;
//-------------------------< Set Routines >-------------------//

procedure TInfoPainter.SetPaintBox(aBox : TPaintBox);
begin
  if aBox = nil then Exit;

  FPaintBox := aBox;
  FPaintBox.OnPaint := PaintProc;

  Resize;

  FPaintBox.Font.Name := '굴림체';
  FPaintBox.Font.Size := 9;
  FBitmap.Canvas.Brush.Color := BACK_COLOR;

end;


const
  MAX_ROWCOUNT = 4;
  MIN_ROWCOUNT = 4;

procedure TInfoPainter.SetRowCount(iRowCount : Integer);
begin
  iRowCount := Max(Min(iRowCount, MAX_ROWCOUNT), MIN_ROWCOUNT);

  FRowCount := iRowCount;

  SetDimension;

  if FPaintBox <> nil then
    FPaintBox.Height := FColSpan + 1;
end;

//-----------------------< Drawing control Routines >-------------------------//

procedure TInfoPainter.Resize;
begin
  if FPaintBox = nil then Exit;

  FBitmap.Width := FWidth;//  FPaintBox.Width;
  FBitmap.Height := FHeight;// FPaintBox.Height;

  FBitmap.Canvas.Font.Name := FPaintBox.Font.Name;
  FBitmap.Canvas.Font.Size := FPaintBox.Font.Size;
end;

procedure TInfoPainter.PaintProc(Sender : TObject);
begin

  Resize;

  DrawBackground;
  DrawTicks;

  ApplyDrawing;
end;


procedure TInfoPainter.Update( aItem : TQuoteDelayItem );
begin
  if not gEnv.QuoteSpeed.Display then
    Exit;
  FQuoteDelayItem := aItem;
  DrawTicks;
  ApplyDrawing;
end;

procedure TInfoPainter.UpdateParam;
var
  i : integer;
begin
  FMaxSec := gEnv.QuoteSpeed.MaxSec;
  FMinSec := gEnv.QuoteSpeed.MinSec;

  FFutColor := TColor( gEnv.QuoteSpeed.FutColor );
  FCalColor := TColor( gEnv.QuoteSpeed.CalColor );
  FPutColor := TColor( gEnv.QuoteSpeed.PutColor );

  iDiv[0]  := 255 - ( FFutColor and $FF );
  iDiv[1]  := 255 - ( (FFutColor and $FF00)shr 8 );
  iDiv[2]  := 255 - ( (FFutColor and $FF0000)shr 16 );

  iPrec[0]  := iDiv[0] div FSecUnit;
  iPrec[1]  := iDiv[1] div FSecUnit;
  iPrec[2]  := iDiv[2] div FSecUnit;

  // 선물 그라데이션
  for i := 0 to FSecUnit - 1 do
    FutGrdColor[i]  :=  RGB(  255 - ( i*iPrec[0] ),
        255 - ( i * iPrec[1] ),
        255 - ( i * iPrec[2] ));

  iDiv[0]  := 255 - ( FCalColor and $FF );
  iDiv[1]  := 255 - ( (FCalColor and $FF00)shr 8 );
  iDiv[2]  := 255 - ( (FCalColor and $FF0000)shr 16 );

  iPrec[0]  := iDiv[0] div FSecUnit;
  iPrec[1]  := iDiv[1] div FSecUnit;
  iPrec[2]  := iDiv[2] div FSecUnit;

  // 콜 그라데이션
  for i := 0 to FSecUnit - 1 do
    CalGrdColor[i]  :=  RGB(  255 - ( i*iPrec[0] ),
        255 - ( i * iPrec[1] ),
        255 - ( i * iPrec[2] ));

  iDiv[0]  := 255 - ( FPutColor and $FF );
  iDiv[1]  := 255 - ( (FPutColor and $FF00)shr 8 );
  iDiv[2]  := 255 - ( (FPutColor and $FF0000)shr 16 );

  iPrec[0]  := iDiv[0] div FSecUnit;
  iPrec[1]  := iDiv[1] div FSecUnit;
  iPrec[2]  := iDiv[2] div FSecUnit;

  // 풋 그라데이션
  for i := 0 to FSecUnit - 1 do
    PutGrdColor[i]  :=  RGB(  255 - ( i*iPrec[0] ),
        255 - ( i * iPrec[1] ),
        255 - ( i * iPrec[2] ));

  PaintProc(nil);
end;

procedure TInfoPainter.UpdateSize;
begin
  FColWidths[0] := 40;

  FColWidths[1] := FWidth - FColWidths[0];
  Resize;
  SetDimension;
end;

//-----------------------< Actual Drawing Routines >-------------------------//

procedure TInfoPainter.DrawBackground;


var
  i, j, iTop , iX, iM, iGap: Integer;
  aRect, oRect : TRect;
  stTmp : string;
  iRowCount, iColSpan, iColSpan2  : Integer;
  dGap, dVal : double;
begin
  iRowCount := 4;
  iColSpan  := iRowCount * FRowHeight + 12;
  iColSpan2  := (iRowCount+2) * FRowHeight ;

  with FBitmap.Canvas do
  begin

    Brush.Color := clWhite;
    Pen.Color := clWhite;
    FillRect(FPaintBox.ClientRect);    

    Pen.Color := clLtGray;

    iGap := 4;
    for i:=0 to iRowCount  do
    begin
      iTop := i * FRowHeight + 12;
      MoveTo(0, iTop);
      LineTo(FRowSpan, iTop);
    end;

    MoveTo(FRights[0], 0 );
    LineTO(FRights[0], iColSpan);


    Font.Size := 8;
    iColSpan  := (iRowCount -1) * FRowHeight + 12;
    iX := FLefts[1];
    iM := FColWidths[1] div FSecUnit ;
    dVal := gEnv.QuoteSpeed.MinSec;
    dGap := (FMaxSec-FMinSec) / FSecUnit;
    for i := 0 to FSecUnit  do
    begin
      if (i Mod 2) = 0 then
        TextOut( iX -4, 0, Format('%.1f', [dVal])   );
      dVal := dVal + dGap;
      FSecX[i]  := iX;
      inc( iX, iM );

      if i <= (FSecUnit-1) then
        FSecVal[i]  := dVal;

      MoveTo(iX, 12 );
      LineTO(iX, iColSpan);
    end;

    Font.Size := 9;
    for i:=0 to 3 do
      DrawRect(FBitmap.Canvas, Rect(FLefts[0]+2, i * FRowHeight +12+1 , FRights[0],
           (i * FRowHeight)+FRowHeight+ 12),
               COL_TITLES[i], INFO_TITLE_COLOR, clBlack, taCenter);


  end;
end;

procedure TInfoPainter.DrawTicks;
var
  aColor: TColor;
  stTxt, stTmp : string;
  dTmp, dTmp2 : double;
  rRect : TRect;
  i : integer;


  function getRect( iT : integer ) : TRect;
  begin
    Result := Rect( FSecX[i]+1,  iT * FRowHeight +12+1,
      FSecX[i+1],  (iT +1)* FRowHeight +12 );
  end;

begin

  if FQuoteDelayItem = nil then Exit;  

  with FBitmap do
  begin

    if FSecUnit <= 0 then Exit;

    DrawRect(FBitmap.Canvas, Rect(FLefts[0]+2, 0 * FRowHeight +12+1 , FRights[0],
         (0 * FRowHeight)+FRowHeight+ 12),
             Format('%s(%.1f)', [  COL_TITLES[0] , FQuoteDelayItem.FutDelay ]),
             INFO_TITLE_COLOR, clBlack, taCenter);

    DrawRect(FBitmap.Canvas, Rect(FLefts[0]+2, 1 * FRowHeight +12+1 , FRights[0],
         (1 * FRowHeight)+FRowHeight+ 12),
             Format('%s(%.1f)', [  COL_TITLES[1] , FQuoteDelayItem.CalDelay ]),
             INFO_TITLE_COLOR, clBlack, taCenter);

    DrawRect(FBitmap.Canvas, Rect(FLefts[0]+2, 2 * FRowHeight +12+1 , FRights[0],
         (2 * FRowHeight)+FRowHeight+ 12),
             Format('%s(%.1f)', [  COL_TITLES[2] , FQuoteDelayItem.PutDelay  ]),
             INFO_TITLE_COLOR, clBlack, taCenter);

    stTmp := Format( 'N:%d(%d) X:%d(%d) C:%d(%d)',
      [
        gEnv.OrderSpeed.AvgAcptTime ,
        gEnv.OrderSpeed.OrderCount,
        gEnv.OrderSpeed.AvgCnlTime,
        gEnv.OrderSpeed.OrderCnlCnt,
        gEnv.OrderSpeed.AvgChgTime,
        gEnv.OrderSpeed.OrderChgCnt
      ]);
    DrawRect(FBitmap.Canvas, Rect(FLefts[1]+2, 3 * FRowHeight +12+1 , FRights[1],
         (3 * FRowHeight)+FRowHeight+ 12),
             stTmp, clWhite, clBlack, taLeftJustify);

    for i := 0 to FSecUnit-1 do
    begin
      if FSecVal[i]<= FQuoteDelayItem.FutDelay then
        Canvas.Brush.Color  := FutGrdColor[i]
      else
        Canvas.Brush.Color := clWhite;
      Canvas.FillRect( getRect(0) );

      if FSecVal[i]<= FQuoteDelayItem.CalDelay then
        Canvas.Brush.Color  := CalGrdColor[i]
      else
        Canvas.Brush.Color := clWhite;
      Canvas.FillRect( getRect(1) );

      if FSecVal[i]<= FQuoteDelayItem.PutDelay then
        Canvas.Brush.Color  := PutGrdColor[i]
      else
        Canvas.Brush.Color := clWhite;
      Canvas.FillRect( getRect(2) );
    end;
  end;


end;

procedure TInfoPainter.ApplyDrawing;
begin
  if FPaintBox = nil then Exit;

  FPaintBox.Canvas.Draw(0,0, FBitmap);
end;

end.
