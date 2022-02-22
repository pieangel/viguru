unit FOrderExtracte;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls,

  CleQuoteResearch, CleQuoteBroker, CleSymbols, GleTypes, GleConsts,  ClePriceItems,
  GleLib, CleStorage, CleDistributor, Buttons
  ;
const
  EPSILON = 1.0e-10;
  DataIdx = 0;
  ContiIdx= 1;

  lColor  = $0000FF;
  sColor  = $993333;
  lxColor = $FFFF33;// $CC6600;
  SxColor = $0066FF;//$8080FF;


type
  TFrmOrderExtracte = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    cbSymbol: TComboBox;
    btnSymbol: TButton;
    edtQty: TEdit;
    edtCnt: TEdit;
    sgInfo: TStringGrid;
    edtClear: TButton;
    spEx: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure cbSymbolChange(Sender: TObject);
    procedure btnSymbolClick(Sender: TObject);
    procedure edtQtyKeyPress(Sender: TObject; var Key: Char);
    procedure edtQtyChange(Sender: TObject);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgInfoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtClearClick(Sender: TObject);
    procedure spExClick(Sender: TObject);
  private
    FFillter: TFillter;
    FSymbol: TSymbol;
    FQuote: TQuote;
    FLastData: TOrderData;
    FRow: integer;
    FRun: boolean;
    procedure initControls( bEx : boolean = false );
    procedure SetFillter;
    procedure Clear;
    procedure PutData(aData: TOrderData; iRow: integer);
    function CheckFillter(aData: TOrderData): boolean;
    function GetGridCol(stDiv: string): integer;
    { Private declarations }
  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    property Symbol : TSymbol read FSymbol write FSymbol;
    property Quote  : TQuote  read FQuote  write FQuote;
    property Run    : boolean read FRun    write FRun;

    property LastData : TOrderData read FLastData write FLastData;
    property Row  : integer read FRow write FRow;
  end;

var
  FrmOrderExtracte: TFrmOrderExtracte;

implementation

uses
  GAppEnv;

{$R *.dfm}

procedure TFrmOrderExtracte.btnSymbolClick(Sender: TObject);
begin
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
        // add to the cache
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);
        //
      AddSymbolCombo(gSymbol.Selected, cbSymbol);
        // apply
      cbSymbolChange(cbSymbol);
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmOrderExtracte.cbSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
  //
begin

  SetFillter;

  if cbSymbol.ItemIndex = -1 then Exit;

  aSymbol := cbSymbol.Items.Objects[cbSymbol.ItemIndex] as TSymbol;
  if (aSymbol = nil) then Exit;

  if FSymbol <> aSymbol then
  begin
    Clear;
    if FSymbol <> nil then
    begin
      gEnv.Engine.QuoteBroker.Cancel( Self, FSymbol );
    end;

    FSymbol := aSymbol;
    FQuote := gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuoteProc );
  end;

end;

procedure TFrmOrderExtracte.Clear;
var
  i : integer;
begin
  for i := 1 to sgInfo.RowCount - 1 do
    sgInfo.Rows[i].Clear;
  sgInfo.RowCount := 1;
end;

procedure TFrmOrderExtracte.edtClearClick(Sender: TObject);
begin
  FRun  := false;
  Clear;
  FRun  := true;
end;

procedure TFrmOrderExtracte.edtQtyChange(Sender: TObject);
begin
  SetFillter;
  //FQuoteResearch.SetFillter( FFillter );
end;

procedure TFrmOrderExtracte.edtQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8, #13]) then
    Key := #0;
end;

procedure TFrmOrderExtracte.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmOrderExtracte.FormCreate(Sender: TObject);
begin

  FSymbol := nil;
  FQuote  := nil;
  FLastData := nil;
  FRow  := -1;
  FRun  := true;

  gEnv.Engine.SymbolCore.SymbolCache.GetList( cbSymbol.Items );
  if cbSymbol.Items.Count > 0 then
  begin
    cbSymbol.ItemIndex  := 0;
    cbSymbolChange( cbSymbol );
  end;

  initControls;

  SetFillter;
end;

procedure TFrmOrderExtracte.initControls( bEx : boolean  );
var
  iCol : integer;
begin
  if not bEx then begin

  with sgInfo do
  begin
  //g = ('시각','LS','H','Pr','주문','체결') ;
    ColCount  := 8;

    Cells[0,0]  := '시각';
    Cells[1,0]  := 'LS';
    Cells[2,0]  := 'H';
    Cells[3,0]  := 'Pr';
    Cells[4,0]  := '주문';
    Cells[5,0]  := '체결';

    Cells[6,0]  := '매도';
    Cells[7,0]  := '매수';

    ColWidths[0] := 80;  // 시간
    ColWidths[1] := 30;
    ColWidths[2] := 35;  // 호가
    ColWidths[3] := 100;  // 가격
    ColWidths[4] := 35;  // 수량
    ColWidths[5] := 35;  // 수량

    ColWidths[6] := 80;
    ColWidths[7] := 80;

  end;

  end
  else begin


    with sgInfo do
    begin
    //g = ('시각','LS','H','Pr','주문','체결') ;
      ColCount  := 29;
      iCol := 0;

      Cells[0,0]  := '시각';

      Cells[1,0]  := 'LS';
      Cells[2,0]  := 'H';
      Cells[3,0]  := 'Pr';
      Cells[4,0]  := '주문';

      ColWidths[0] := 80;  // 시간
      ColWidths[1] := 30;
      ColWidths[2] := 35;  // 호가
      ColWidths[3] := 50;  // 가격
      ColWidths[4] := 35;  // 수량

      Cells[5,0]  := 'LS';
      Cells[6,0]  := 'H';
      Cells[7,0]  := 'Pr';
      Cells[8,0]  := '주문';

      ColWidths[5] := 30;
      ColWidths[6] := 35;  // 호가
      ColWidths[7] := 50;  // 가격
      ColWidths[8] := 35;  // 수량


      Cells[9,0]  := 'LS';
      Cells[10,0]  := 'H';
      Cells[11,0]  := 'Pr';
      Cells[12,0]  := '주문';

      ColWidths[9] := 30;
      ColWidths[10] := 35;  // 호가
      ColWidths[11] := 100;  // 가격
      ColWidths[12] := 35;  // 수량

      Cells[13,0]  := '체결';
      ColWidths[13] := 35;  // 수량


      ///////////////////////////////////

      Cells[14,0]  := '매도';
      Cells[15,0]  := '매수';

      ColWidths[14] := 80;
      ColWidths[15] := 80;

      ///////////////////////////////////////


      Cells[16,0]  := '체결';
      ColWidths[16] := 35;  // 수량

      Cells[17,0]  := 'LS';
      Cells[18,0]  := 'H';
      Cells[19,0]  := 'Pr';
      Cells[20,0]  := '주문';

      ColWidths[17] := 30;
      ColWidths[18] := 35;  // 호가
      ColWidths[19] := 50;  // 가격
      ColWidths[20] := 35;  // 수량

      Cells[21,0]  := 'LS';
      Cells[22,0]  := 'H';
      Cells[23,0]  := 'Pr';
      Cells[24,0]  := '주문';

      ColWidths[21] := 30;
      ColWidths[22] := 35;  // 호가
      ColWidths[23] := 50;  // 가격
      ColWidths[24] := 35;  // 수량

      Cells[25,0]  := 'LS';
      Cells[26,0]  := 'H';
      Cells[27,0]  := 'Pr';
      Cells[28,0]  := '주문';

      ColWidths[25] := 30;
      ColWidths[26] := 35;  // 호가
      ColWidths[27] := 100;  // 가격
      ColWidths[28] := 35;  // 수량


    end;


  end;
end;

procedure TFrmOrderExtracte.LoadEnv(aStorage: TStorage);
var
  aSymbol : TSymbol;
  Code  : string;
begin
  if aStorage = nil then Exit;

  Code  := aStorage.FieldByName('Symbol').AsString;

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( Code );

  if aSymbol <> nil then
  begin
    AddSymbolCombo( aSymbol, cbSymbol );
    cbSymbolChange( cbSymbol );
  end;

  edtQty.Text := aStorage.FieldByName('Qty').AsString;
  edtCnt.Text := aStorage.FieldByName('Cnt').AsString;

  SetFillter;

end;

function TFrmOrderExtracte.CheckFillter(aData: TOrderData): boolean;
var
  dPrice : double;
  bOk1, bOK2 : boolean;
  stTmp : string;
  iQty, iHoga, iH : integer;
begin
  result := false;

  if (aData = nil) or (FQuote = nil) then Exit;

  if abs( StrToIntdef(aData.Qty, 0) ) < FFillter.OrdQty then
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
        if aData.dPrice <= 0 then
          Exit;
        dPrice  := aData.dPrice;

        if (FQuote.Bids[FFillter.SisCnt ].Price > (dPrice + EPSILON )) or
           (FQuote.Asks[FFillter.SisCnt ].Price < (dPrice-EPSILON)) then
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

        if (FQuote.Bids[FFillter.SisCnt ].Price > (aData.dPrice + EPSILON)) or
           (FQuote.Asks[FFillter.SisCnt ].Price < (aData.dPrice- EPSILON)) then
           bOK1 := false;

        if (FQuote.Bids[FFillter.SisCnt ].Price > (aData.dPrice2+EPSILON)) or
           (FQuote.Asks[FFillter.SisCnt ].Price < (aData.dPrice2-EPSILON)) then
           bOK2 := false;

        if (not bOK1) and ( not bOK2) then
          Exit;

      end;
     FL: ;
  end;


  result := true;

end;

procedure TFrmOrderExtracte.QuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aQuote : TQuote;
begin

  if not FRun then Exit;
  
  if DataObj = nil then Exit;
  aQuote  := DataObj as TQuote;

  if aQuote.Symbol <> FSymbol then Exit;
  if aQuote.LastData = nil then Exit;
  
  if FLastData = aQuote.LastData then Exit;

  if aQuote.LastEvent = qtTimeNSale then
    PutData( aQuote.LastData, 1 );

  FLastData := aQuote.LastData;
end;

procedure TFrmOrderExtracte.PutData( aData : TOrderData; iRow : integer );
var
  iH, iCol, iHoga : integer;
  stTmp, stDiv : string;
  bOK : boolean;
  dLGap, dSGap : double;

begin
  iCol  := 0;

  InsertLine( sgInfo, iRow );
  if FRow > 0 then
    inc(FRow);

  with sgInfo do
  begin

    bOK := false;
    dSGap := abs( FQuote.PrevAsks[0].Price - FQuote.Asks[0].Price );
    dLGap := abs( FQuote.PrevBids[0].Price - FQuote.Bids[0].Price );

    if ((dSGap > PRICE_EPSILON) or ( dLGap > PRICE_EPSILON)) and
      (FQuote.LastData.FillQty <> '') then
      bOK := true;

    Objects[DataIdx, iRow] := aData;

    if bOK then    
      Objects[ContiIdx,iRow] := Pointer( 100 );

    Cells[iCol, iRow] := FormatDateTime( 'HH:MM:SS.zzz', aData.Time );
    // FQuote.QuoteTime
    inc( iCol );


    if spEx.Down = false then begin

    //--------------------------------------------------------------------------
    //  No Expansion

    Cells[iCol, iRow] := aData.GetOrderState;
    inc( iCol );

    if aData.QType in [ SN,SC,LN,LC,LPC,SPC] then
    begin
      iHoga := aData.No2;
      stTmp  := IntToStr( iHoga  );
    end
    else if aData.QType = FL then
    begin
      if aData.Name[1] = 'N' then
        stTmp := IntToStr( aData.No2  )
      else
        stTmp := Format('%d->%d', [ aData.No, aData.No2 ]);
    end
    else
      stTmp := Format('%d->%d', [ aData.No, aData.No2 ]);

    Cells[iCol, iRow] := stTmp;
    inc( iCol );

    Cells[iCol, iRow] := aData.Price;
    inc( iCol );

    stTmp := aData.Qty;
    if aData.QType in [SC, SPC, LC, LPC] then
      stTmp := '-'+aData.Qty;
    Cells[iCol, iRow] := stTmp;
    inc( iCol );

    Cells[iCol, iRow] := aData.FillQty;
    inc( iCol );

    // 추가 부분
    if FQuote <> nil then
    begin

      Cells[ iCol, iRow ] := Format('(%3.3s) %.2f', [ IntToStr(FQuote.Asks[0].Volume),
        FQuote.Asks[0].Price
         ]);
      inc(iCol);

      Cells[ iCol, iRow ] := Format('%.2f (%3.3s)', [ FQuote.Bids[0].Price,
        IntToStr(FQuote.Bids[0].Volume) ]);
      inc(iCol);
    end ;

    end
    //  No Expansion
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
    //   Expansion
    else begin

    iCol := GetGridCol( aData.GetOrderState );
    Cells[iCol, iRow] := aData.GetOrderState;
    inc(iCol);

    if aData.QType in [ SN,SC,LN,LC,LPC,SPC] then
    begin
      iHoga := aData.No2;
      stTmp  := IntToStr( iHoga  );
    end
    else if aData.QType = FL then
    begin
      if aData.Name[1] = 'N' then
        stTmp := IntToStr( aData.No2  )
      else
        stTmp := Format('%d->%d', [ aData.No, aData.No2 ]);
    end
    else
      stTmp := Format('%d->%d', [ aData.No, aData.No2 ]);

    Cells[iCol, iRow] := stTmp;
    inc( iCol );

    Cells[iCol, iRow] := aData.Price;
    inc( iCol );

    stTmp := aData.Qty;
    if aData.QType in [SC, SPC, LC, LPC] then
      stTmp := '-'+aData.Qty;
    Cells[iCol, iRow] := stTmp;
    inc( iCol );

    //  13 or 16
    if aData.Side[1] = 'L' then
      iCol := 16
    else
      iCol := 13;

    Cells[iCol, iRow] := aData.FillQty;
    inc( iCol );


    // 추가 부분
    if FQuote <> nil then
    begin

      Cells[ 14, iRow ] := Format('(%3.3s) %.2f', [ IntToStr(FQuote.Asks[0].Volume),
        FQuote.Asks[0].Price
         ]);
      inc(iCol);

      Cells[ 15, iRow ] := Format('%.2f (%3.3s)', [ FQuote.Bids[0].Price,
        IntToStr(FQuote.Bids[0].Volume) ]);
      inc(iCol);
    end ;

    end;
    //  Expansion
    //--------------------------------------------------------------------------

    if FixedRows <= 0 then
    begin
      if RowCount > 1 then
        FixedRows := 1;
    end;

  end;
end;

function TFrmOrderExtracte.GetGridCol( stDiv : string ) : integer;
begin
  if stDiv = 'S' then
    Result  := 1
  else if stDiv = 'Sx' then
    Result  := 5
  else if stDiv = 'Sc' then
    Result  := 9
  else if stDiv = 'L' then
    Result  := 17
  else if stDiv = 'Lx' then
    Result  := 21
  else if stDiv = 'Lc' then
    Result  := 25
  else
    Result  := -1;
end;

procedure TFrmOrderExtracte.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  if FSymbol <> nil then
    aStorage.FieldByName('Symbol').AsString := FSymbol.Code;

  aStorage.FieldByName('Qty').AsString := edtQty.Text;
  aStorage.FieldByName('Cnt').AsString := edtCnt.Text;

end;

procedure TFrmOrderExtracte.SetFillter;
var
  i :integer;
begin

  i :=  StrToIntDef( edtCnt.Text, 3) - 1;
  if i >= 4 then
    i := 4
  else if i < 0 then
    i := 0;

  FFillter.SisCnt  := i;
  FFillter.OrdQty  := StrToIntDef( edtQty.Text, 10 );
end;



procedure TFrmOrderExtracte.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    ftColor, bkColor : TColor;
    stTxt : string;
    iX, iY, iCol, iFill : integer;
    aSize : TSize;
    aData : TOrderData;

  function GetColor( stType : string ) : TColor;
  begin
    if stType = 'L' then
      Result := gBoardEnv.ColorInfo.Colorl
    else if stType = 'S' then
      Result := gBoardEnv.ColorInfo.Colors
    else if stType = 'Lx' then
      Result := gBoardEnv.ColorInfo.Colorlx
    else if stType = 'Sx' then
      Result := gBoardEnv.ColorInfo.ColorSx
    else if stType = 'Lc' then begin
      if aData.Side = 'L' then
        Result := gBoardEnv.ColorInfo.ColorL
      else
        Result := gBoardEnv.ColorInfo.ColorSx;
    end
    else if stType = 'Sc' then begin
      if aData.Side = 'S' then
        Result := gBoardEnv.ColorInfo.ColorS
      else
        Result := gBoardEnv.ColorInfo.Colorlx;
    end
    else
      Result := clBlack;
  end;

begin
  bkColor := clWhite;
  ftColor := clBlack;

  with sgInfo do
  begin

    if Integer( Objects[ContiIdx, ARow]) = 100 then
      Canvas.Font.Style :=  Canvas.Font.Style + [fsBold]
    else
      Canvas.Font.Style :=  Canvas.Font.Style - [fsBold];

    stTxt := Cells[ ACol, ARow ];
    aSize := Canvas.TextExtent(stTxt);

    iX := Rect.Left + (Rect.Right-Rect.Left-aSize.cx) div 2;
    iY := Rect.Top + (Rect.Bottom-Rect.Top-aSize.cy) div 2;

    if ARow = 0 then
      bkColor := clBtnFace
    else begin

      aData := TOrderData( Objects[DataIdx, ARow] );
      if aData = nil then Exit;

       if spEx.Down = false then begin
      //------------------------------------------------------------------------
      // No Expansion

      case ACol of
        1,2,3,4,5:
          begin
            if aData.QType in [ LPM, SPM, All, FL] then
              ftColor := GetColor( aData.GetOrderState2 )
            else
              ftColor := GetColor( aData.GetOrderState );
            iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
          end;
        6 :
          begin

            bkcolor := SHORT_COLOR;
            ftColor := clBlack;
            iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
          end;
        7 :
          begin
            bkcolor := LONG_COLOR ;
            ftColor := clBlack;
            iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
          end;
      end;

       end
      // No Expansion
      //------------------------------------------------------------------------
      // Expansion
      else begin

      iCol  := GetGridCol( aData.GetOrderState );

      if aData.Side[1] = 'L' then
        iFill := 16
      else
        iFill := 13;

      if (iCol = ACol ) or ( iCol+1 = ACol) or (iCol+2 = ACol ) or (iCol+3 = ACol)
        or ( iFill = ACol ) then
      begin
        if aData.QType in [ LPM, SPM, All, FL] then
          ftColor := GetColor( aData.GetOrderState2 )
        else
          ftColor := GetColor( aData.GetOrderState );
        iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
      end;

      case ACol of
        14 :
          begin

            bkcolor := SHORT_COLOR;
            ftColor := clBlack;
            iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
          end;
        15 :
          begin
            bkcolor := LONG_COLOR ;
            ftColor := clBlack;
            iX := Rect.Left + Rect.Right-Rect.Left-aSize.cx - 2 ;
          end;
      end;

      end;
      // Expansion
      //------------------------------------------------------------------------

      if ARow = FRow then
        bkColor := $00F2BEB9;

    end;

    Canvas.Brush.Color  := bkColor;
    Canvas.Font.Color   := ftColor;

    Canvas.Font.Name    := '굴림체';
    Canvas.Font.Size    := 9;

    Canvas.FillRect( Rect );

    Canvas.TextRect(Rect, iX, iY, stTxt);
  end;
end;

procedure TFrmOrderExtracte.sgInfoMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    aRow, aCol : integer;
begin
  aRow := FRow;
  sgInfo.MouseToCell( x, y, aCol, FRow );

  InvalidateRow( sgInfo, FRow );
  InvalidateRow( sgInfo, aRow );

end;

procedure TFrmOrderExtracte.spExClick(Sender: TObject);
var
  i,iWid : integer;
begin
//
  edtClearClick( nil );
  initControls( spEx.Down );
  iWid := 0;
  for i := 0 to sgInfo.ColCount - 1 do
    iWid := iWid + sgInfo.ColWidths[i];

  Self.Width := iWid + sgInfo.ColCount + 10;
end;

procedure TFrmOrderExtracte.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.QuoteBroker.Cancel( Self );
end;

end.
