unit FleMiniPositionList;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, StdCtrls, ExtCtrls,

  CleAccounts, CleSymbols, ClePositions, CleQuotebroker, CleDistributor,

  CleStorage, Menus
  ;

const
  Title_1 : array [0..3] of string = ('평가손익','실현손익','수수료','순손익');
  Title_2 : array [0..2] of string = ('종목코드','잔 고','평균가');

  Symbol_Col = 0;
  Color_Col  = 2;

type

  TFrmMiniPosList = class(TForm)
    p1: TPanel;
    cbAccount: TComboBox;
    sgTop: TStringGrid;
    Panel1: TPanel;
    sgBottom: TStringGrid;
    RefreshTimer: TTimer;
    Show0Net: TCheckBox;
    ShowUnit: TCheckBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure sgTopDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure sgBottomDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure RefreshTimerTimer(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure Show0NetClick(Sender: TObject);
    procedure ShowUnitClick(Sender: TObject);

  private
    { Private declarations }
    FAccount  : TAccount;
    FIndex    : boolean;
    procedure initControls;
    procedure RefreshPosition;
    procedure RefreshBottom;
    procedure RefreshTop;

    procedure TradePrc( Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure UpdatePosition(aPosition: TPosition; bAdd: boolean);
    procedure UpdateRow(iRow: Integer; aPos: TPosition; bAdd : boolean);
    procedure Clear(aGrid: TStringGrid);
    procedure OnAccount(aInvest: TInvestor; EventID: TDistributorID);
  public
    { Public declarations }

    procedure SaveEnv(aStorage: TStorage);
    procedure LoadEnv(aStorage: TStorage);
  end;

var
  FrmMiniPosList: TFrmMiniPosList;

implementation

uses
  GAppEnv , GleLib , GleConsts,
  Math
  ;

{$R *.dfm}

procedure TFrmMiniPosList.cbAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin

  aAccount := TAccount( cbAccount.Items.Objects[ cbAccount.ItemIndex ] );
  if (aAccount <> nil ) and (FAccount <> aAccount) then
  begin
    FAccount := aAccount;
    FIndex   := FAccount is TInvestor;//  cbAccount.ItemIndex;
    Clear( sgBottom );
    RefreshPosition;
  end;

end;

procedure TFrmMiniPosList.Clear( aGrid : TStringGrid );
var
  I: Integer;
begin
  for I := 1 to aGrid.RowCount - 1 do
    aGrid.Rows[i].Clear;
  aGrid.RowCount  := 2;
end;

procedure TFrmMiniPosList.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

procedure TFrmMiniPosList.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  //
  initControls;

  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
    cbAccount.AddItem( gEnv.Engine.TradeCore.Investors.Investor[i].Code,
       gEnv.Engine.TradeCore.Investors.Investor[i] );

  gEnv.Engine.TradeCore.Accounts.GetList2( cbAccount.Items );

  FAccount  := nil;
  FIndex    := false;

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( cbAccount );
  end;

end;

procedure TFrmMiniPosList.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;

procedure TFrmMiniPosList.initControls;
var
  i : integer;
begin
  with sgTop do
  begin
    for I := 0 to RowCount - 1 do
      Cells[0, i]  := Title_1[i];

    ColWidths[1]  := Width - DefaultColWidth - 3;

  end;

  with sgBottom do
  begin
    for I := 0 to ColCount - 1 do
      Cells[i,0]  := Title_2[i];

    ColWidths[0] := 77;
    ColWidths[1] := 40;
    ColWidths[2] := 70;
  end;
end;

procedure TFrmMiniPosList.LoadEnv(aStorage: TStorage);
begin
  //
  if aStorage = nil then Exit;

  Show0Net.Checked  := aStorage.FieldByName('Show0Net').AsBoolean ;
  ShowUnit.Checked  := aStorage.FieldByName('ShowUnit').AsBoolean ;
end;


procedure TFrmMiniPosList.RefreshTimerTimer(Sender: TObject);
begin
  RefreshPosition;
end;

procedure TFrmMiniPosList.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('Show0Net').AsBoolean  := Show0Net.Checked;
  aStorage.FieldByName('ShowUnit').AsBoolean  := ShowUnit.Checked;
end;

procedure TFrmMiniPosList.sgBottomDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    stTxt : string;
    bgClr, ftClr : TColor;
    wFmt : word;
    rRect : TRect;
begin

  wFmt  := DT_CENTER or DT_VCENTER;
  rRect := Rect;
  bgClr := clWhite;
  ftClr := clBlack;

  with sgBottom do
  begin

    stTxt := Cells[ ACol, ARow ];

    if ARow = 0 then
    begin
      bgClr := clBtnFace;
    end
    else begin
      if ACol <> 0 then
        wFmt  := DT_RIGHT or DT_VCENTER;

      if ACol = 1 then
        ftClr := TColor( integer( Objects[Color_Col, ARow] ));

      if ( ARow mod 2 ) = 0 then
        bgClr := $00EEEEEE;

      if ARow = RowCount-1 then
        bgClr := clWhite;
    end;

    Canvas.Font.Color   := ftClr;
    Canvas.Brush.Color  := bgClr;

    Canvas.FillRect(Rect);
    rRect.Top := rRect.Top + 2;
    DrawText( Canvas.Handle,  PChar( stTxt ), Length( stTxt ), rRect, wFmt );
  end;

end;

procedure TFrmMiniPosList.sgTopDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    stTxt : string;
    bgClr, ftClr : TColor;
    wFmt : word;
    rRect : TRect;
begin

  wFmt  := DT_CENTER or DT_VCENTER;
  rRect := Rect;
  bgClr := clWhite;
  ftClr := clBlack;

  with sgTop do
  begin

    stTxt := Cells[ ACol, ARow ];

    if ACol = 0 then
    begin
      bgClr := clBtnFace;
    end
    else begin
      wFmt  := DT_RIGHT or DT_VCENTER;
      ftClr := TColor( integer( Objects[ACol, ARow] ));
    end;

    Canvas.Font.Color   := ftClr;
    Canvas.Brush.Color  := bgClr;

    Canvas.FillRect(Rect);
    rRect.Top := rRect.Top + 2;
    DrawText( Canvas.Handle,  PChar( stTxt ), Length( stTxt ), rRect, wFmt );
  end;
end;

procedure TFrmMiniPosList.Show0NetClick(Sender: TObject);
begin
  RefreshPosition;
end;

procedure TFrmMiniPosList.ShowUnitClick(Sender: TObject);
begin
  RefreshPosition;
end;

procedure TFrmMiniPosList.TradePrc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;


  case Integer(EventID) of

    ACCOUNT_NEW     ,
    ACCOUNT_DELETED ,
    ACCOUNT_UPDATED : OnAccount( DataObj as Tinvestor, EventID );
  end

end;

procedure TFrmMiniPosList.OnAccount(aInvest: TInvestor;
  EventID: TDistributorID);
begin
  cbAccount.Items.Clear;
  gEnv.Engine.TradeCore.Accounts.GetList3( cbAccount.Items );

  case integer( EventID ) of

    ACCOUNT_NEW , ACCOUNT_UPDATED  :
      begin
        if FAccount <> nil then
          SetComboIndex( cbAccount, FAccount )
        else
          if cbAccount.Items.Count > 0 then
          begin
            cbAccount.ItemIndex  := 0;
            cbAccountChange( nil );
          end;
      end;
    ACCOUNT_DELETED :
      if cbAccount.Items.Count > 0 then
      begin
        cbAccount.ItemIndex  := 0;
        cbAccountChange( nil );
      end
  end;

end;

procedure TFrmMiniPosList.UpdatePosition( aPosition : TPosition; bAdd : boolean );
begin

end;

procedure TFrmMiniPosList.RefreshPosition;
begin
  if FAccount = nil then Exit;

  RefreshTop;
  RefreshBottom;
end;

procedure TFrmMiniPosList.RefreshTop;
var
  aInvestor : TInvestor;
  I: Integer;
  aAccount  : TAccount;
  aPos  : TPosition;
  dEntry, dPL, dFee, dTotPL : double;
  iDiv : integer;
begin

  dEntry  := 0;
  dPL  := 0;
  dFee := 0;
  dTotPL  := 0;

  iDiv := ifThen( ShowUnit.Checked, 1000, 1 );

  if FIndex then
  begin
    for I := 0 to gEnv.Engine.TradeCore.InvestorPositions.Count - 1 do
    begin
      aPos  := gEnv.Engine.TradeCore.InvestorPositions.Positions[i];
      if aPos.Account.Code = FAccount.Code then
      begin
        dEntry:= dEntry + aPos.EntryOTE;
        dPL   := dPL    + aPos.EntryPL;
        dTotPL:= dPL + dEntry;
      end;
    end;

    for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
    begin
      aAccount  := gEnv.Engine.TradeCore.Investors.Investor[i];
      if aAccount = FAccount then
        dFee  := dFee + aAccount.GetFee;
    end;
  end
  else begin
    gEnv.Engine.TradeCore.Positions.GetMarketTotPl( FAccount, dTotPL, dEntry, dPL );
    dFee  := FAccount.GetFee;
  end;

  dPL := dPL + FAccount.FixedPL;
  dTotPL  := dTotPL + FAccount.FixedPL;
  //dFee:= dFee+ FAccount.GetFee;

  with sgTop do
  begin
    Cells[1, 0] := Formatfloat('#,##0.###', dEntry / iDiv  );
    Cells[1, 1] := Formatfloat('#,##0.###', dPL  / iDiv  );
    Cells[1, 2] := Formatfloat('#,##0.###', dFee  / iDiv );
    Cells[1, 3] := Formatfloat('#,##0.###', (dTotPL - dFee) / iDiv  );

    if (dEntry / iDiv )= 0 then
      Objects[ Color_Col -1 , 0] := Pointer( clBlack )
    else if (dEntry / iDiv )> 0 then
      Objects[ Color_Col -1, 0] := Pointer( clRed )
    else
      Objects[ Color_Col -1 , 0] := Pointer( clBlue );

    if (dPL  / iDiv )= 0 then
      Objects[ Color_Col -1 , 1] := Pointer( clBlack )
    else if (dPL  / iDiv )> 0 then
      Objects[ Color_Col -1, 1] := Pointer( clRed )
    else
      Objects[ Color_Col -1 , 1] := Pointer( clBlue );

    if ((dTotPL - dFee)  / iDiv )= 0 then
      Objects[ Color_Col -1 , 3] := Pointer( clBlack )
    else if ((dTotPL - dFee)  / iDiv )> 0 then
      Objects[ Color_Col -1, 3] := Pointer( clRed )
    else
      Objects[ Color_Col -1 , 3] := Pointer( clBlue );
  end;

end;

procedure TFrmMiniPosList.RefreshBottom;
var
  iRow, i : integer;
  aPos : TPosition;
  aAccount : TAccount;

  function InsertRow( aSymbol : TSymbol ) : integer;
  var
    pSymbol : TSymbol;
  begin
    case aSymbol.ShortCode[1] of
      '1' : Result := 1;
      '2' : if sgBottom.RowCount > 2 then
            begin
              pSymbol := TSymbol( sgBottom.Objects[Symbol_Col, 1] );
              if pSymbol <> nil then begin
                if pSymbol.ShortCode[1] <> '1' then
                  Result := 1
                else
                  Result := 2;
              end
              else Result := 1;
            end
            else
              Result := 1;
      '3' : Result := sgBottom.RowCount-1;
    end;
  end;

begin

  if FIndex then
  begin
    for I := 0 to gEnv.Engine.TradeCore.InvestorPositions.Count - 1 do
    begin
      aPos  := gEnv.Engine.TradeCore.InvestorPositions.Positions[i];

      if aPos.Account.Code = FAccount.Code then
      begin
        iRow  := sgBottom.Cols[Symbol_Col].IndexOfObject( aPos.Symbol );
        if iRow < 0 then begin
          if (aPos.Volume = 0) and ( not Show0Net.Checked ) then
            Continue;
          iRow := 1;//InsertRow( aPos.Symbol );
          InsertLine( sgBottom, iRow );
        end else
        begin
          if (aPos.Volume = 0) and ( not Show0Net.Checked ) then begin
            DeleteLine( sgBottom, iRow );
            Continue;
          end;
        end;
        UpdateRow( iRow, aPos, true );
      end;

    end;
  end
  else begin
    for I := 0 to gEnv.Engine.TradeCore.Positions.Count - 1 do
    begin
      aPos  := gEnv.Engine.TradeCore.Positions.Positions[i];
      if aPos.Account = FAccount then
      begin
        iRow  := sgBottom.Cols[0].IndexOfObject( aPos.Symbol );

        if iRow < 0 then begin
          if (aPos.Volume = 0) and ( not Show0Net.Checked ) then
            Continue;
          iRow := 1;//InsertRow( aPos.Symbol );
          InsertLine( sgBottom, iRow );
        end else
        begin
          if (aPos.Volume = 0) and ( not Show0Net.Checked ) then begin
            DeleteLine( sgBottom, iRow );
            Continue;
          end;
        end;

        UpdateRow( iRow, aPos, true );
      end;
    end;

  end;
end;

procedure TFrmMiniPosList.UpdateRow( iRow : Integer; aPos : TPosition; bAdd : boolean );
var
  iVol : integer;
  dPrice : double;
begin
  with sgBottom do
  begin

    iVol   := aPos.Volume;
    dPrice := aPos.AvgPrice;

    Objects[ Symbol_Col, iRow ] := aPos.Symbol;

    Cells[0, iRow] := aPos.Symbol.ShortCode;
    Cells[1, iRow] := IntToStr( iVol );

    if iVol = 0 then
      Objects[ Color_Col, iRow] := Pointer( clBlack )
    else if aPos.Volume > 0 then
      Objects[ Color_Col, iRow] := Pointer( clRed )
    else
      Objects[ Color_Col, iRow] := Pointer( clBlue );

    Cells[2, iRow] := Format('%.*n', [ aPos.Symbol.Spec.Precision, dPrice ] );
  end;
end;



end.
