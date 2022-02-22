unit FEntryPrice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ExtCtrls,

  CleOtherData, CleSymbols,

  GleLib , GleConsts, StdCtrls

  ;

Const
  DataIdx = 0;
  Selected = 1;


type
  TFrmEntryPrice = class(TForm)
    sgInfo: TStringGrid;
    flashTimer: TTimer;
    UpdateTimer: TTimer;
    Panel1: TPanel;
    Button1: TButton;
    cbAll: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure flashTimerTimer(Sender: TObject);
    procedure sgInfoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure Button1Click(Sender: TObject);
  private
    procedure Add( aData : TOtherDataIF );
    procedure Update;
    procedure init;
    { Private declarations }
  public
    { Public declarations }
    ReadCnt : integer;
    FRow : integer;
  end;

var
  FrmEntryPrice: TFrmEntryPrice;

implementation

uses
  GAppEnv;


{$R *.dfm}

procedure TFrmEntryPrice.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmEntryPrice.FormCreate(Sender: TObject);
var
  aData : TOtherData;
begin

  ReadCnt := 0;

  FlashTimer.Enabled  := true;
  UpdateTimer.Enabled := false;

  init;

  //gEnv.Engine.QuoteBroker.Entry. pdateEvent := Add;
  aData := gEnv.Engine.QuoteBroker.Entry.Find( odtEntry );
  if aData <> nil then
    aData.UpdateEvent := Add;


end;

procedure TFrmEntryPrice.FormDestroy(Sender: TObject);
var
  aData : TOtherData;
begin
  aData := gEnv.Engine.QuoteBroker.Entry.Find( odtEntry );
  if aData <> nil then
    aData.UpdateEvent := nil;
end;


procedure TFrmEntryPrice.init;
var
  iCol : integer;
begin
  iCol := 0;
  with sgInfo do
  begin
    Cells[ iCol, 0 ] := '시각';
    ColWidths[iCol]  := 80;
    inc( iCol );

    Cells[ iCol, 0 ] := '타입';
    ColWidths[iCol]  := 25;
    inc( iCol );

    Cells[ iCol, 0 ] := '구분';
    ColWidths[iCol]  := 25;
    inc( iCol );

    Cells[ iCol, 0 ] := 'LS ';
    ColWidths[iCol]  := 25;
    inc( iCol );

    Cells[ iCol, 0 ] := 'S잔량';
    ColWidths[iCol]  := 40;
    inc( iCol );

    Cells[ iCol, 0 ] := '매도가';
    ColWidths[iCol]  := 50;
    inc( iCol );

    Cells[ iCol, 0 ] := '매수가';
    ColWidths[iCol]  := 50;
    inc( iCol );

    Cells[ iCol, 0 ] := 'L잔량';
    ColWidths[iCol]  := 40;
    inc( iCol );
  end;

end;


procedure TFrmEntryPrice.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    stTxt : string;
    ftColor , bkColor : TColor;
    iX, iY : integer;
    aSize : TSize;
    aData : TEntryPrice;
    bLight: boolean;
begin

  bkColor := clWhite;
  ftColor := clBlack;

  with sgInfo do
  begin

    stTxt := Cells[ ACol, ARow ];
    aSize := Canvas.TextExtent(stTxt);

    iX := Rect.Left + (Rect.Right-Rect.Left-aSize.cx) div 2;
    iY := Rect.Top + (Rect.Bottom-Rect.Top-aSize.cy) div 2;

    if ARow = 0 then
    begin
      bkColor := clBtnFace;
    end
    else begin
      aData := TEntryPrice( Objects[DataIdx, ARow] );
      if aData = nil then Exit;

      bLight  := aData.Flash;

      case ACol of
        4, 5,6,7 :
          begin
            iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
            if ACol in [4,5] then
              bkColor := SHORT_COLOR
            else //if ACol = 5 then
              bkColor := LONG_COLOR;
          end;
      end;

      case ACol of
       1,2,3 :
        begin
          if aData.Side = 'L' then
            ftColor := clRed
          else
            ftColor := clBlue;
        end;
      end;
                   {
      case ACol of
       3,6 :
        begin


          iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
        end;
      end;   }
    end;

    if Integer(Objects[Selected,ARow]) = 100 then
    begin
      bkColor := clSilver;
      FRow    := ARow;
    end;

    if bLight then
      bkColor := clYellow;


    Canvas.Brush.Color  := bkColor;
    Canvas.Font.Color   := ftColor;

    Canvas.Font.Name    := '굴림체';
    Canvas.Font.Size    := 9;

    Canvas.FillRect( Rect );

    Canvas.TextRect(Rect, iX, iY, stTxt);
  end;

end;

procedure TFrmEntryPrice.sgInfoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    aRow, aCol : integer;
begin
  aRow := FRow;
  sgInfo.MouseToCell( X, Y, aCol, FRow );

  if FRow < 1 then
  begin
    FRow := aRow;
    Exit;
  end;

  sgInfo.Objects[Selected,FRow] := Pointer( 100 );

  if (aRow > 0) and ( aRow <> FRow) then
    sgInfo.Objects[Selected,aRow] := Pointer( 1 );

  InvalidateRow( sgInfo, aRow );
  InvalidateRow( sgInfo, FRow );

end;

procedure TFrmEntryPrice.Add( aData : TOtherDataIF );
var
  iRow,iCol : integer;
  aEntry : TEntryPrice;
begin

  if aData = nil then Exit;
  
  iCol  := 0;
  iRow  := 1;

  aEntry := aData as TEntryPrice;

  if not cbAll.Checked then
    if aEntry.DataType = '00' then
      Exit;

  InsertLine( sgInfo, iRow );

  With sgInfo do
  begin
    Objects[ iCol, iRow]  := aEntry;
    Cells[ iCol, iRow ] := FormatDateTime( 'hh:nn:ss.zzz', aEntry.EntryTime);
    inc( iCol );

    Cells[ iCol, iRow]  := aEntry.DataType;
    inc( iCol );

    Cells[ iCol, iRow]  := aEntry.Sign;
    inc( iCol );

    Cells[ iCol, iRow]  := aEntry.Side;
    inc( iCol );

    Cells[ iCol, iRow]  := IntToStr( aEntry.ASkVol );
    inc( iCol );

    Cells[ iCol, iRow]  := Format('%.2f', [ aEntry.AskPrice ]);
    inc( iCol );

    Cells[ iCol, iRow]  := Format('%.2f', [ aEntry.BidPrice ]);
    inc( iCol );

    Cells[ iCol, iRow]  := IntToStr( aEntry.BidVol );
    inc( iCol );
  end;

end;

procedure TFrmEntryPrice.Button1Click(Sender: TObject);
var
  stName : string;
begin
  stName := Format( '%s/%s.log', [ WIN_ENTRY,
        FormatDateTime( 'yyyymmdd', now)
        ]);
  ShowNotePad( Handle, stName );
end;

procedure TFrmEntryPrice.flashTimerTimer(Sender: TObject);
var
  aData : TEntryPrice;
  i : integer;
begin
 for i :=1 to sgInfo.RowCount-1 do
  begin
    aData := TEntryPrice( sgInfo.Objects[DataIdx, i]);
    if aData <> nil then
    begin
      if aData.Flash then
      begin
        aData.Flash := false;
        InvalidateRow( sgInfo, i );
      end
      else
        Break;
    end;
  end;

  //FlashTimer.Enabled := false;
end;

procedure TFrmEntryPrice.Update;
begin


end;

end.
