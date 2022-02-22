unit FQuotingUpDown;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  CleOtherData, CleSymbols,

  GleLib , GleConsts, StdCtrls, ExtCtrls, Grids

  ;

Const
  DataIdx = 0;
  Selected = 1;

type
  TFrmUpDown = class(TForm)
    sgInfo: TStringGrid;
    Panel1: TPanel;
    Button1: TButton;
    flashTimer: TTimer;
    UpdateTimer: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure flashTimerTimer(Sender: TObject);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgInfoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
  private
    FRow : integer;
    procedure init;
    procedure Add(aData: TOtherDataIF);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmUpDown: TFrmUpDown;

implementation

uses
  GAppEnv;

{$R *.dfm}

procedure TFrmUpDown.Button1Click(Sender: TObject);
var
  stName : string;
begin
  stName := Format( '%s/%s.log', [ WIN_UPDOWN,
        FormatDateTime( 'yyyymmdd', now)
        ]);
  ShowNotePad( Handle, stName );

end;

procedure TFrmUpDown.flashTimerTimer(Sender: TObject);
var
  aData : TUpDownPrice;
  i : integer;
begin
 for i :=1 to sgInfo.RowCount-1 do
  begin
    aData := TUpDownPrice( sgInfo.Objects[DataIdx, i]);
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

end;

procedure TFrmUpDown.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmUpDown.FormCreate(Sender: TObject);
var
  aData : TOtherData;
begin

  FlashTimer.Enabled  := true;
  UpdateTimer.Enabled := false;

  FRow := -1;

  init;

  //gEnv.Engine.QuoteBroker.Entry. pdateEvent := Add;
  aData := gEnv.Engine.QuoteBroker.Entry.Find( odtUpDown );
  if aData <> nil then
    aData.UpdateEvent := Add;
end;

procedure TFrmUpDown.FormDestroy(Sender: TObject);
var
  aData : TOtherData;
begin
  aData := gEnv.Engine.QuoteBroker.Entry.Find( odtUpDown );
  if aData <> nil then
    aData.UpdateEvent := nil;

end;

procedure TFrmUpDown.init;
var
  iCol : integer;
begin
  iCol := 0;
  with sgInfo do
  begin
    Cells[ iCol, 0 ] := '시각';
    ColWidths[iCol]  := 80;
    inc( iCol );

    Cells[ iCol, 0 ] := '구분';
    ColWidths[iCol]  := 25;
    inc( iCol );

    Cells[ iCol, 0 ] := '매도가';
    ColWidths[iCol]  := 50;
    inc( iCol );

    Cells[ iCol, 0 ] := '매도잔량';
    ColWidths[iCol]  := 50;
    inc( iCol );

    Cells[ iCol, 0 ] := '매수잔량';
    ColWidths[iCol]  := 50;
    inc( iCol );

    Cells[ iCol, 0 ] := '매수가';
    ColWidths[iCol]  := 50;
    inc( iCol );
  end;

end;


procedure TFrmUpDown.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    stTxt : string;
    ftColor , bkColor : TColor;
    iX, iY : integer;
    aSize : TSize;
    aData : TUpDownPrice;
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
      aData := TUpDownPrice( Objects[DataIdx, ARow] );
      if aData = nil then Exit;

      bLight  := aData.Flash;

      case ACol of
        2, 3 :
          begin
            iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
            bkColor := SHORT_COLOR;
          end;
        4, 5 :
          begin
            iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
            bkColor := LONG_COLOR;
          end;
      end;

      case ACol of
       1 :
        begin
          if aData.Side = 'U' then
            ftColor := clRed
          else
            ftColor := clBlue;
        end;
      end;
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

procedure TFrmUpDown.sgInfoMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TFrmUpDown.Add( aData : TOtherDataIF );
var
  iRow,iCol : integer;
  aEntry : TUpDownPrice;
begin

  if aData = nil then Exit;
  
  iCol  := 0;
  iRow  := 1;

  aEntry := aData as TUpDownPrice;

  InsertLine( sgInfo, iRow );

  With sgInfo do
  begin
    Objects[ iCol, iRow]  := aEntry;
    Cells[ iCol, iRow ] := FormatDateTime( 'hh:nn:ss.zzz', aEntry.EntryTime);
    inc( iCol );

    Cells[ iCol, iRow]  := aEntry.Side;
    inc( iCol );

    Cells[ iCol, iRow]  := Format('%.2f', [ aEntry.AskPrice ]);
    inc( iCol );

    Cells[ iCol, iRow]  := IntToStr( aEntry.ASkVol );
    inc( iCol );
    Cells[ iCol, iRow]  := IntToStr( aEntry.BidVol );
    inc( iCol );


    Cells[ iCol, iRow]  := Format('%.2f', [ aEntry.BidPrice ]);
    inc( iCol );
  end;

end;

end.
