unit CHogaPainter;

interface

uses
  Windows, Classes, Graphics, Controls, SysUtils, ExtCtrls, Dialogs, Math,
    // lemon: data
  GleLib, CleSymbols, CleQuoteBroker, ClePriceItems;

const
  MAX_TP_COLUMNS = 6;
  EPSILON = 1.0e-10;
type
  THogaPainter = class
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
    FFillterOrderHoga: integer;
    FFillterOrderQty: integer;

    FLastData : TOrderData;
    FWhite    : boolean;
    FLine     : integer;
    FCount    : integer;

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
    procedure SetFillterOrderHoga(const Value: integer);


  public
    ColorL,
    ColorLx,
    ColorLc,
    ColorS,
    ColorSx,
    ColorSc : TColor;

    constructor Create;
    destructor Destroy; override;

    procedure Update;
    procedure Resize;

    function CheckFillter( aData : TOrderData ) : boolean;

    property Quote: TQuote read FQuote write SetQuote;
    property PaintBox: TPaintBox read FPaintBox write SetPaintBox;
    property RowCount: Integer read FRowCount write SetRowCount;

    property UseVolumeFilter: Boolean read FUseVolumeFilter write FUseVolumeFilter;
    property VolumeThreshold: Integer read FVolumeThreshold write FVolumeThreshold;

    // fillter
    property FillterOrderQty  : integer read FFillterOrderQty write FFillterOrderQty;
    property FillterOrderHoga  : integer read FFillterOrderHoga write SetFillterOrderHoga;
  end;

implementation

uses GAppEnv, GleTypes;

//--------------------< Create/Destroy >----------------------//



constructor THogaPainter.Create;
begin
  FBitmap := TBitmap.Create;

  FRowHeight := 15;
  FRowCount := 10;
  FColCount := MAX_TP_COLUMNS;
  FColWidths[0] := 30;  // 시간
  FColWidths[1] := 25;
  FColWidths[2] := 15;  // 호가
  FColWidths[3] := 30;  // 가격
  FColWidths[4] := 35;  // 수량
  FColWidths[5] := 35;  // 수량
  // + 35

  FLastData := nil;

  SetDimension;

  FWhite := false;
  FLine  := 1;
  FCount := 0;
end;

destructor THogaPainter.Destroy;
begin
  FBitmap.Free;
  inherited;
end;

procedure THogaPainter.SetDimension;
begin
  FRowSpan := 175;
  FColSpan := (FRowCount+1) * FRowHeight; // + colume header line

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
procedure THogaPainter.SetFillterOrderHoga(const Value: integer);
var
  iV : integer;
begin
  iV := Value - 1;

  if iV <=0 then
    FFillterOrderHoga := 0
  else if iV >= 4 then
    FFillterOrderHoga := 4
  else
    FFillterOrderHoga := iv;
end;

//-------------------------< Set Routines >-------------------//

procedure THogaPainter.SetPaintBox(aBox : TPaintBox);
begin
  if aBox = nil then Exit;

  FPaintBox := aBox;
  FPaintBox.OnPaint := PaintProc;

  Resize;
end;

procedure THogaPainter.SetQuote(const Value: TQuote);
begin
  FQuote := Value;

  DrawBackground;
  DrawTicks;

  ApplyDrawing;
end;

const
  MAX_ROWCOUNT = 50;
  MIN_ROWCOUNT = 5;

procedure THogaPainter.SetRowCount(iRowCount : Integer);
begin
  iRowCount := Max(Min(iRowCount, MAX_ROWCOUNT), MIN_ROWCOUNT);

  FRowCount := iRowCount;

  SetDimension;

  if FPaintBox <> nil then
    FPaintBox.Height := FColSpan + 1;
end;

//-----------------------< Drawing control Routines >-------------------------//

procedure THogaPainter.Resize;
begin
  if FPaintBox = nil then Exit;

  FBitmap.Width := FPaintBox.Width;
  FBitmap.Height := FPaintBox.Height;
  FBitmap.Canvas.Font.Name := FPaintBox.Font.Name;
  FBitmap.Canvas.Font.Size := FPaintBox.Font.Size;
end;

procedure THogaPainter.PaintProc(Sender : TObject);
begin
  Resize;

  DrawBackground;
  DrawTicks;

  ApplyDrawing;
end;


procedure THogaPainter.Update;
begin
  if FQuote = nil then Exit;

  DrawTicks;
  ApplyDrawing;
end;

//-----------------------< Actual Drawing Routines >-------------------------//

procedure THogaPainter.DrawBackground;
const
  COL_TITLES : array[0..MAX_TP_COLUMNS-1] of String = ('시각','LS','H','Pr','주문','체결') ;
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
      iTop := i * FRowHeight;
      MoveTo(0, iTop);
      LineTo(FRowSpan, iTop);
    end;

    // grid line vertical
    MoveTo(FLefts[0], 0);
    LineTO(FLefts[0], FColSpan);

    for i:=0 to FColCount-1 do
    begin
      MoveTo(FRights[i], 0);
      LineTo(FRights[i], FColSpan);
    end;

    // titles
    for i:=0 to MAX_TP_COLUMNS-1 do
      DrawRect(FBitmap.Canvas, Rect(FLefts[i]+1, 1, FRights[i], FRowHeight),
               COL_TITLES[i], $00EEEEEE, clBlack, taCenter);
  end;
end;

function THogaPainter.CheckFillter(aData: TOrderData): boolean;
var
  dPrice : double;
  bOk1, bOK2 : boolean;
  stTmp : string;
  iH : integer;
begin
  result := false;

  if aData = nil then Exit;

  if abs( StrToIntdef(aData.Qty, 0) ) < FFillterOrderQty then
    Exit;


  if ( aData.QType in [ SPM, LPM, All, FL] ) then
    iH := aData.No2
  else
    iH := aData.No;

  case aData.QType of
    SN,
    SC,
    LN,
    LC,
    SPC,
    LPC:
      begin
        // aData.dPrice2 는 0
        if aData.dPrice <= 0 then
          Exit;
        dPrice  := aData.dPrice;

        if (FQuote.Bids[FFillterOrderHoga].Price > (dPrice + EPSILON )) or
           (FQuote.Asks[FFillterOrderHoga].Price < (dPrice-EPSILON)) then
        begin
          Exit;
        end;

      end;
    SPM,
    LPM,
    All :
      begin
        if (aData.dPrice <= 0) and (aData.dPrice2 <= 0) then
          Exit;

        bOK1 := true;
        bOK2 := true;

        if (FQuote.Bids[FFillterOrderHoga].Price > (aData.dPrice + EPSILON)) or
           (FQuote.Asks[FFillterOrderHoga].Price < (aData.dPrice- EPSILON)) then
           bOK1 := false;

        if (FQuote.Bids[FFillterOrderHoga].Price > (aData.dPrice2+EPSILON)) or
           (FQuote.Asks[FFillterOrderHoga].Price < (aData.dPrice2-EPSILON)) then
           bOK2 := false;

        if (not bOK1) and ( not bOK2) then
          Exit;

      end;
     FL: ;
  end;


  result := true;

end;



procedure THogaPainter.DrawTicks;
var
  i, j, iTop, iBot, iHoga: Integer;
  aData: TOrderData;
  aBack,aColor: TColor;
  bRes : boolean;
  stTmp, st : string;
  dPrice : double;


  function GetColor( stType : string ) : TColor;
  begin
    if stType = 'L' then
      Result := ColorL
    else if stType = 'S' then
      Result := ColorS
    else if stType = 'Lx' then
      Result := ColorLx
    else if stType = 'Sx' then
      Result := ColorSx
    else if stType = 'Lc' then  begin
      if aData.Side = 'L' then
        Result := ColorL
      else
        Result := ColorSx;
    end
    else if stType = 'Sc' then begin
      if aData.Side = 'S' then
        Result := ColorS
      else
        Result := ColorLx;
    end
    else
      Result := clBlack;
  end;

begin
  if (FQuote = nil) or (FQuote.Symbol = nil)
     or (FQuote.Symbol.Spec = nil) then Exit;

  if FQuote.PriceAxis.OrderList.Count < 1 then Exit;

  aData := TOrderData(FQuote.PriceAxis.OrderList.Items[0]);

  if aData = FLastData then
    Exit;

  bRes  := CheckFillter( aData );
  if not bRes then Exit;

  FLastData := aData;

  if (FLine -1 ) >= RowCount then
  begin
    FLine := 1;
    FWhite := not FWhite;
  end;

  if FWhite then
    aBack := clWhite
  else
    aBack := $AAAAAA;//$C2B2A6;


  iTop := (FLine) * FRowHeight;
  iBot := iTop + FRowHeight;

  st  := aData.GetOrderState;

  if aData.QType in [ LPM, SPM, All, FL] then
  begin
    aColor := GetColor( aData.GetOrderState2 );
    dPrice := aData.dPrice2;
  end
  else begin
    aColor := GetColor( aData.GetOrderState );
    dPrice := aData.dPrice;
  end;

  iHoga := aData.No2;

  DrawRect(FBitmap.Canvas, Rect(FLefts[0]+1, iTop+1, FRights[0], iBot),
           GetSecNOneMilli( aData.Time),
           aBack, clBlack, taRightJustify);

    //주문방향
  DrawRect(FBitmap.Canvas, Rect(FLefts[1]+1, iTop+1, FRights[1], iBot),
           st,
           aBack, aColor, taRightJustify);

    // 호가
  DrawRect(FBitmap.Canvas, Rect(FLefts[2]+1, iTop+1, FRights[2], iBot),
         IntToStr( iHoga ),
         aBack, aColor, taRightJustify) ;

    // 주문가격
  DrawRect(FBitmap.Canvas, Rect(FLefts[3]+1, iTop+1, FRights[3], iBot),
           aData.GetOrderPrice,
           aBack, aColor, taRightJustify);


  stTmp := aData.Qty;
  if aData.QType in [SC, SPC, LC, LPC] then
    stTmp := '-'+aData.Qty;
    // 주문수량
  DrawRect(FBitmap.Canvas, Rect(FLefts[4]+1, iTop+1, FRights[4], iBot),
         stTmp,
         aBack, aColor, taRightJustify) ;

    // 체결수량
  DrawRect(FBitmap.Canvas, Rect(FLefts[5]+1, iTop+1, FRights[5], iBot),
       aData.FillQty,
       aBack, aColor, taRightJustify)     ;

  inc( FLine );

end;

procedure THogaPainter.ApplyDrawing;
begin
  if FPaintBox = nil then Exit;

  BitBlt( FPaintBox.Canvas.Handle,
    FLefts[0]+1, 1, FBitmap.Width, FBitmap.Height,
    FBitmap.Canvas.Handle,
    FLefts[0]+1, 1 , SRCCOPY);

  //FPaintBox.Canvas.Draw(0,0, FBitmap);
end;

end.
