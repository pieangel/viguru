unit BearLog;

interface

uses Windows, Classes, Graphics, Controls, SysUtils, ExtCtrls, Dialogs, Math,
     //
     {
     AppTypes, SymbolStore,
     AppUtils, DrawUtils, QuoteTimer, LogCentral
     }
     GleLib,
     GleTypes, CleSymbols, CleQuoteBroker
     ;

const
  MAX_LP_COLUMNS = 2;
  MAX_LP_ROWCOUNT = 30;
  MIN_LP_ROWCOUNT = 5;
  
type
  
  TBearLogNotifyEvent =
    procedure( Sender: TObject ; 
      stTime:String ; stTitle:String ; stLog : String ) of Object;
  
  TLogPainter = class
  private 
    FPaintBox : TPaintBox;
    FCanvas : TCanvas;
    FBitmap : TBitmap;

    FRowCount : Integer;
    FRowHeight : Integer;
    FRowSpan : Integer;
    FColCount : Integer;
    FColSpan : Integer;
    FCurrentLine : Integer;
    FNextLine  : Integer;
    FColorIndex : Integer;
  
    FColWidths : array[0..MAX_LP_COLUMNS-1] of Integer;
    FLefts : array[0..MAX_LP_COLUMNS-1] of Integer;
    FRights : array[0..MAX_LP_COLUMNS-1] of Integer;
    
    FLogContents : Array of Array of String;
    // Data 구조 
    // FLogContents[0] : Time
    // FLogContents[1] : Title
    // FLogContents[2] : Contents 

    procedure SetRowCount(iRowCount : Integer);
    procedure SetPaintBox(aBox : TPaintBox);
    //
    procedure PaintProc(Sender : TObject);
    procedure SetDimension;
    procedure Resize;
    procedure ApplyDrawing;
    procedure Prev;
    procedure Next;
    // 
    procedure DrawBackground;
    procedure DrawLog ; 


  public
    constructor Create;
    destructor Destroy; override;
    //
    procedure addLog( stTime : String ; stTitle : String ; stContens : String );
    procedure Refresh ; 
    //
    property PaintBox : TPaintBox read FPaintBox write SetPaintBox;
    property RowCount : Integer read FRowCount write SetRowCount;
  end;

implementation

const
  BACK_COLORS : array[0..1] of Integer = (clWhite, clLtGray);
  
{ TLogPainter }

// ----- private ----- //

procedure TLogPainter.ApplyDrawing;
begin
  if FPaintBox = nil then Exit;
  FPaintBox.Canvas.Draw(0,0, FBitmap);
end;

procedure TLogPainter.DrawBackground;
const
  COL_TITLES : array[0..1] of String = ('Time', 'Contents');
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
    
    Pen.Color := clLtGray;

    // grid line horizontal
    for i:=0 to FRowCount + 1 do
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
    for i:=0 to 1 do
      DrawRect(FBitmap.Canvas, Rect(FLefts[i]+1, 1, FRights[i], FRowHeight),
               COL_TITLES[i], $00EEEEEE, clBlack, taCenter);
  end;

end;

procedure TLogPainter.Refresh;
var
  i : Integer ;
  iTop, iBot : Integer;
  aCopyRect : TRect;
  aTextColor : TColor;
  //
  stTitle, stTime, stContents : String;
begin

  for i := 0 to FCurrentLine do
  begin
      iTop :=  i * FRowHeight;
      iBot := iTop + FRowHeight;
      // 
      stTime := FLogContents[0][i];
      stTitle := FLogContents[1][i] ;
      stContents := FLogContents[2][i] ;
       //
      DrawRect(FBitmap.Canvas, Rect(FLefts[0]+1, iTop+1, FRights[0], iBot),
                Format('%s', [stTime]),
                BACK_COLORS[FColorIndex], aTextColor, taLeftJustify);
      DrawRect(FBitmap.Canvas, Rect(FLefts[1]+1, iTop+1, FRights[1], iBot),
                Format('%s', [stContents]),
                BACK_COLORS[FColorIndex], aTextColor, taLeftJustify);
  end;  

  aCopyRect := Rect(FLefts[0]+1,  FRowHeight , FRights[1], iBot);
  FPaintBox.Canvas.CopyRect(aCopyRect, FCanvas, aCopyRect);

end;

procedure TLogPainter.DrawLog;
var
  iTop, iBot : Integer;
  aCopyRect : TRect;
  aTextColor : TColor;
  //
  stTitle, stTime, stContents : String;
begin

  //
  iTop := (FCurrentLine) * FRowHeight;
  iBot := iTop + FRowHeight;

  //
  stTime := FLogContents[0][FCurrentLine-1];
  stTitle := FLogContents[1][FCurrentLine-1] ;
  stContents := FLogContents[2][FCurrentLine-1] ;


  {
  gLog.Add(lkError, 'BearSystem', 'BearLog',
    '[CurrentLine] ' +  IntToStr(FCurrentLine) +
    ' [time] ' + stTime +
    ' [FColorIndex] ' + IntToStr(FColorIndex) +
    ' [T] ' + IntTostr(iTop) + ' [B] ' + IntTostr(iBot) );
  }

  //
  aTextColor := clBlack ;
  // 
  DrawRect(FBitmap.Canvas, Rect(FLefts[0]+1, iTop+1, FRights[0], iBot),
                Format('%s', [stTime]),
                BACK_COLORS[FColorIndex], aTextColor, taLeftJustify);
  DrawRect(FBitmap.Canvas, Rect(FLefts[1]+1, iTop+1, FRights[1], iBot),
                Format('%s', [stContents]),
                BACK_COLORS[FColorIndex], aTextColor, taLeftJustify);
  aCopyRect := Rect(FLefts[0]+1, iTop+1, FRights[1], iBot);
  FPaintBox.Canvas.CopyRect(aCopyRect, FCanvas, aCopyRect);

end;

procedure TLogPainter.Prev;
begin
  FCurrentLine := FNextLine;
  if FCurrentLine = FRowCount then
    FColorIndex := (FColorIndex+1) mod 2;

  FNextLine := FNextLine - 1;
  if FNextLine = 0 then
    FNextLine := FRowCount;
end;

procedure TLogPainter.Next;
begin
  FCurrentLine := FNextLine;
  if FCurrentLine = 1 then
    FColorIndex := (FColorIndex+1) mod 2;
  // 
  FNextLine := FNextLine mod FRowCount + 1;
end;

procedure TLogPainter.PaintProc(Sender: TObject);
begin
  Resize;
  DrawBackground;
  DrawLog ; 
  ApplyDrawing; 
end;

procedure TLogPainter.Resize;
begin
  if FPaintBox = nil then Exit;

  FBitmap.Width := FPaintBox.Width;
  FBitmap.Height := FPaintBox.Height;
  FBitmap.Canvas.Font.Name := FPaintBox.Font.Name;
  FBitmap.Canvas.Font.Size := FPaintBox.Font.Size;  
end;

procedure TLogPainter.SetDimension;
begin
  FRowSpan := 270 ;
  FColSpan := (FRowCount+1) * FRowHeight; // + colume header line
  // 
  FLefts[0] := 0;
  FRights[0] := FColWidths[0];
  FLefts[1] := FRights[0];
  FRights[1] := FRights[0] + FColWidths[1];

end;


procedure TLogPainter.SetPaintBox(aBox: TPaintBox);
begin
  if aBox = nil then Exit;

  FPaintBox := aBox;
  FPaintBox.OnPaint := PaintProc;
  
  FBitmap.Width := FPaintBox.Width;
  FBitmap.Height := FPaintBox.Height;
  //
  FCanvas := FBitmap.Canvas;

  Resize; 
end;

procedure TLogPainter.SetRowCount(iRowCount: Integer);
var
  i, j : Integer ; 
begin

  iRowCount := Max(Min(iRowCount, MAX_LP_ROWCOUNT), MIN_LP_ROWCOUNT);
  FRowCount := iRowCount;
  
  SetLength(FLogContents, FColCount+1, FRowCount);

  {
  // Index 계산 
  SetLength(FLogContents, 2, 5);  
  for i := 0 to Length(FLogContents[0])-1 do
  begin
    showMessage('test' + IntToStr(i));    // 0 ~ 4 
  end;
  for i := 0 to Length(FLogContents[)-1 do
  begin
    showMessage('test' + IntToStr(i));    // 0 ~ 1
  end;
  }

  SetDimension;

  if FPaintBox <> nil then
  begin 
    FPaintBox.Width := FRowSpan  ;
    FPaintBox.Height := FColSpan + 1;
  end;
  
end;


// ----- public ----- //

constructor TLogPainter.Create;
begin
  FBitmap := TBitmap.Create;

  FRowHeight := 15;
  FRowCount := 10;
  FColCount := 2;
  FColWidths[0] := 60;
  FColWidths[1] := 195;
  //
  FCurrentLine := 1;
  FNextLine     := FCurrentLine;
  FColorIndex := 0 ;
  // 
  SetDimension;     
end;

destructor TLogPainter.Destroy;
begin
  if FBitmap <> nil then
    FBitmap.Free;
  //
  inherited;
end;

procedure TLogPainter.addLog(stTime, stTitle, stContens: String);
begin
  // Buy 0.44,1  [60,3,0.023] => Long - Buy , Short - Sell  

  //
  Next ;
  //
  FLogContents[0][FCurrentLine-1] := stTime ;
  FLogContents[1][FCurrentLine-1] := stTitle ;
  FLogContents[2][FCurrentLine-1] := stContens ;
  //
  if FPaintBox <> nil then
    DrawLog ;

end;


end.
