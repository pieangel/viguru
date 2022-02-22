unit CInfoPainter;

interface

uses
  Windows, Classes, Graphics, Controls, SysUtils, ExtCtrls, Dialogs, Math,
    // lemon: data
  GleLib, CleSymbols, CleQuoteBroker;

const
  MAX_TP_COLUMNS = 6;

type
  TInfoPainter = class
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
    FWidth: integer;
    FHeight: integer;
    
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
  public
    constructor Create( iH, iW :integer); overload;
    destructor Destroy; override;

    procedure Update;
    procedure Resize;
    procedure UpdateSize;

    property Quote: TQuote read FQuote write SetQuote;
    property PaintBox: TPaintBox read FPaintBox write SetPaintBox;
    property RowCount: Integer read FRowCount write SetRowCount;
    property Height : integer read FHeight write FHeight;
    property Width  : integer read FWidth write FWidth;

  end;

implementation

uses CleDistConst, GAppEnv;

//--------------------< Create/Destroy >----------------------//

constructor TInfoPainter.Create( iH, iW :integer);
begin
  FBitmap := TBitmap.Create;

  FHeight := iH;
  FWidth  := iW;

  FRowHeight := 15;
  FRowCount := 3;
  FColCount := 6;
  FColWidths[0] := 80;

  FColWidths[2] := 50;
  FColWidths[3] := 60;
  FColWidths[4] := 50;
  FColWidths[5] := 60;

  FColWidths[1] := FWidth - FColWidths[0] - FColWidths[2] - FColWidths[3] - FColWidths[4] - FColWidths[5];

  SetDimension;
end;

destructor TInfoPainter.Destroy;
begin
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
  FLefts[2] := FRights[1];
  FRights[2] := FRights[1] + FColWidths[2];
  //
  FLefts[3] := FRights[2];
  FRights[3] := FRights[2] + FColWidths[3];

  FLefts[4] := FRights[3];
  FRights[4] := FRights[3] + FColWidths[4];

  FLefts[5] := FRights[4];
  FRights[5] := FRights[4] + FColWidths[5];
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

procedure TInfoPainter.SetQuote(const Value: TQuote);
begin
  FQuote := Value;

  if FQuote = nil then Exit;

  DrawBackground;
  DrawTicks;

  ApplyDrawing;
end;

const
  MAX_ROWCOUNT = 3;
  MIN_ROWCOUNT = 3;

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


procedure TInfoPainter.Update;
begin
  if FQuote = nil then Exit;
  DrawTicks;
  ApplyDrawing;
end;

procedure TInfoPainter.UpdateSize;
begin
  FColWidths[0] := 80;

  FColWidths[2] := 50;
  FColWidths[3] := 60;
  FColWidths[4] := 50;
  FColWidths[5] := 60;

  FColWidths[1] := FWidth - FColWidths[0] - FColWidths[2] - FColWidths[3] - FColWidths[4] - FColWidths[5];
  Resize;
  SetDimension;
end;

//-----------------------< Actual Drawing Routines >-------------------------//

procedure TInfoPainter.DrawBackground;
var
  i, iTop : Integer;
  aRect, oRect : TRect;
  stTmp : string;
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

    // titles
    DrawRect(FBitmap.Canvas, Rect(FLefts[0]+2, 2, FRights[0]+1, FRowHeight+1),
              '현재가', INFO_TITLE_COLOR, clBlack, taCenter);
    DrawRect(FBitmap.Canvas, Rect(FLefts[2]+2, 2, FRights[2]+1, FRowHeight+1),
              '시가', INFO_TITLE_COLOR, clBlack, taCenter);
    DrawRect(FBitmap.Canvas, Rect(FLefts[4]+2, 2, FRights[4]+1, FRowHeight+1),
              '전일', INFO_TITLE_COLOR, clBlack, taCenter);

    DrawRect(FBitmap.Canvas, Rect(FLefts[0]+2, 1+ ( FRowHeight * 2),FRights[0]+1, FRowHeight *3 +1 ),
              '미결약정', INFO_TITLE_COLOR, clBlack, taCenter);
    DrawRect(FBitmap.Canvas, Rect(FLefts[2]+2, 1+ ( FRowHeight * 2), FRights[2]+1, FRowHeight *3 +1),
              '저가', INFO_TITLE_COLOR, clBlack, taCenter);
    DrawRect(FBitmap.Canvas, Rect(FLefts[4]+2, 1+ ( FRowHeight * 2), FRights[4]+1, FRowHeight *3 +1),
              '합성선물', INFO_TITLE_COLOR, clBlack, taCenter);

    DrawRect(FBitmap.Canvas, Rect(FLefts[0]+2, 1 +( FRowHeight * 1),FRights[0]+1, FRowHeight *2 +1 ),
              '거래량', INFO_TITLE_COLOR, clBlack, taCenter);
    DrawRect(FBitmap.Canvas, Rect(FLefts[2]+2, 1+ ( FRowHeight * 1), FRights[2]+1, FRowHeight *2 +1),
              '고가', INFO_TITLE_COLOR, clBlack, taCenter);
    DrawRect(FBitmap.Canvas, Rect(FLefts[4]+2, 1+ ( FRowHeight * 1), FRights[4]+1, FRowHeight *2 +1),
              '대비', INFO_TITLE_COLOR, clBlack, taCenter);

  end;
end;

procedure TInfoPainter.DrawTicks;
var
  aColor: TColor;
  stTxt, stTmp : string;
  dTmp, dTmp2 : double;
  iPrec : integer;
begin
  if (FQuote = nil) or (FQuote.Symbol = nil)
     or (FQuote.Symbol.Spec = nil) then Exit;
  // data
  dTmp := FQuote.Last - FQuote.Symbol.PrevClose  ;

  aColor := clBlue;  stTxt := '▼';
  if dTmp > 0 then begin
    aColor := clRed;
    stTxt  := '▲';
  end;

  dTmp2 := ( abs( dTmp ) / FQuote.Symbol.PrevClose ) * 100;

  iPrec := FQuote.Symbol.Spec.Precision;
  stTmp := Format( '%.*n    %s %.*n   (%.*n%%)', [ iPrec , FQuote.Symbol.Last,
           stTxt, iPrec, dTmp,  iPrec, dTmp2 ]);
  DrawRect(FBitmap.Canvas, Rect(FLefts[1]+2, 2, FRights[1]+1, FRowHeight+1),
            stTmp, clWhite, aColor, taCenter);

  stTmp := Format( '%.*n', [ iPrec, FQuote.Symbol.DayOpen ]);
  DrawRect(FBitmap.Canvas, Rect(FLefts[3]+2, 2, FRights[3]+1, FRowHeight+1),
            stTmp, clWhite, clBlack, taRightJustify);

  stTmp := Format( '%.*n', [ iPrec, FQuote.Symbol.PrevClose ]);
  DrawRect(FBitmap.Canvas, Rect(FLefts[5]+2, 2, FRights[5]-2, FRowHeight+1),
            stTmp, clWhite, clBlack, taRightJustify);

  ////
  stTmp := FormatFloat( '#,##0',  FQuote.DailyVolume  );
  DrawRect(FBitmap.Canvas, Rect(FLefts[1]+2, 1 +( FRowHeight * 1), FRights[1]+1, FRowHeight *2+1),
            stTmp, clWhite, clRed, taCenter);
  stTmp := Format( '%.*n', [ iPrec, FQuote.Symbol.DayHigh ]);
  DrawRect(FBitmap.Canvas, Rect(FLefts[3]+2, 1 +( FRowHeight * 1), FRights[3]+1, FRowHeight *2+1),
            stTmp, clWhite, clBlack, taRightJustify);

  stTmp := Format( '%.*n', [ iPrec, dTmp ]);
  DrawRect(FBitmap.Canvas, Rect(FLefts[5]+2, 1 +( FRowHeight * 1), FRights[5]-2, FRowHeight *2+1),
            stTmp, clWhite, aColor, taRightJustify);

  ///
  stTmp := '';//Format( '%.2f   %.2f (%.2f%%)', [ 197.60, 2.90, 1.49 ]);
  DrawRect(FBitmap.Canvas, Rect(FLefts[1]+2, 1 +( FRowHeight * 2), FRights[1]+1, FRowHeight *3+1),
            stTmp, clWhite, clBlack, taCenter);
  stTmp := Format( '%.*n', [ iPrec, FQuote.Symbol.DayLow ]);
  DrawRect(FBitmap.Canvas, Rect(FLefts[3]+2, 1 +( FRowHeight * 2), FRights[3]+1, FRowHeight *3+1),
            stTmp, clWhite, clBlack, taRightJustify);

  stTmp := Format( '%.2f', [ gEnv.Engine.SyncFuture.FSynFutures.Last ]);
  DrawRect(FBitmap.Canvas, Rect(FLefts[5]+2, 1 +( FRowHeight * 2), FRights[5]-2, FRowHeight *3+1),
            stTmp, clWhite, clBlack, taRightJustify);



end;

procedure TInfoPainter.ApplyDrawing;
begin
  if FPaintBox = nil then Exit;

  FPaintBox.Canvas.Draw(0,0, FBitmap);
end;

end.
