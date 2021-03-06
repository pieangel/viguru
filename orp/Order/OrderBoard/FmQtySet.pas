unit FmQtySet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, UAlignedEdit, StdCtrls, Grids, ComCtrls, Buttons,

  ClePositions, DBoardParams,
  CleSymbols, ExtCtrls
  ;

Const
  TitleCnt2 = 6;
  PosCol    = 0;
  G_W       = 402;
  Title3 : array [0..TitleCnt2-1] of string = ('종목','구분','잔고','평균가','현재가','평가손익');

type
  TFrmQtySet = class(TFrame)
    SpeedButtonPrefs: TSpeedButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    btnClearQty: TSpeedButton;
    btnBuyAbleQty: TSpeedButton;
    btnSellAbleQty: TSpeedButton;
    Label1: TLabel;
    edtOrderQty: TEdit;
    UpDown1: TUpDown;
    sgSymbolPL: TStringGrid;
    edtTmpQty: TEdit;
    cbSymbol: TComboBox;
    Button1: TButton;
    Edit1: TEdit;
    plQtySet: TPanel;
    cbHogaFix: TCheckBox;
    edtStopTick: TAlignedEdit;
    udStopTick: TUpDown;
    Label8: TLabel;
    btnAbleNet: TSpeedButton;
    procedure SpeedButton1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtTmpQtyExit(Sender: TObject);
    procedure edtTmpQtyKeyPress(Sender: TObject; var Key: Char);

  private
    { Private declarations }
    FIsFund : boolean;
    procedure SetControls;
  public
    { Public declarations }

    LastButton : TSpeedButton;
    DefColWidth: array [0..TitleCnt2-1] of integer;
    procedure init( bFund : boolean = false );
    procedure SetSymbol( aSymbol : TSymbol );
    procedure ReArrangeControls( aParam : TOrderBoardParams );
    procedure ResetPos;

  end;

implementation

uses
  GAppEnv  , GleLib, GleConsts
  ;

{$R *.dfm}

procedure TFrmQtySet.Button1Click(Sender: TObject);
begin
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    //gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
        // add to the cache
      AddSymbolCombo(gSymbol.Selected, cbSymbol );
        // apply
      if Assigned(cbSymbol.OnChange) then
        cbSymbol.OnChange( cbSymbol );
      //RecvSymbol(  gSymbol.Selected );
    end;
  finally
    gSymbol.Hide
  end;
end;

procedure TFrmQtySet.edtTmpQtyExit(Sender: TObject);
begin
  if LastButton <> nil then
  begin
    LastButton.Caption  := edtTmpQty.Text;
  end;
  edtTmpQty.Hide;
  Lastbutton := nil;
end;

procedure TFrmQtySet.edtTmpQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0
end;

procedure TFrmQtySet.init( bFund : boolean );
var
  i : integer;
begin
  Lastbutton  := nil;

  for I := 0 to TitleCnt2 - 1 do
  begin
    sgSymbolPL.Cells[i,0] := Title3[i];
    DefColWidth[i]  := sgSymbolPL.ColWidths[i];
  end;

  FIsFund := bFund;
  SetControls;

end;

procedure TFrmQtySet.SetControls;
begin
  btnAbleNet.Visible := FIsFund;
  btnBuyAbleQty.Visible := not FIsFund;
  btnSellAbleQty.Visible:= not FIsFund;
  btnClearQty.Visible   := not FIsFund;

  if FIsFund then
    Color  := FUND_FORM_COLOR
  else
    Color  := clBtnFace;
   
end;

procedure TFrmQtySet.ReArrangeControls(aParam: TOrderBoardParams);
var
  iCnt , iLen: integer;
  bL : boolean;
begin
  iCnt := 0;
  if not FIsFund then
  begin
    btnBuyAbleQty.Visible   := true;
    btnSellAbleQty.Visible  := true;
  end;
  sgSymbolPL.ColWidths[0] := DefColWidth[0];
  sgSymbolPL.ColWidths[1] := DefColWidth[1];
  sgSymbolPL.ColWidths[3] := DefColWidth[3];
  sgSymbolPL.ColWidths[4] := DefColWidth[4];
  sgSymbolPL.Width  := G_W;

  if ( not aParam.ShowOrderColumn ) then inc(iCnt);
  if ( not aParam.ShowStopColumn ) then inc(iCnt);
  if ( not aParam.ShowCountColumn ) then inc(iCnt);

  if aParam.ShowTNS then dec( iCnt );

  bL  := false;

  if iCnt = 1 then
  begin
    btnBuyAbleQty.Visible := false;
    if not aParam.ShowOrderColumn then
    begin
      sgSymbolPL.ColWidths[0] := -1;
      sgSymbolPL.ColWidths[1] := -1;
      sgSymbolPL.Width  := G_W - DefColWidth[0] - DefColWidth[1] - 2;
    end else
    begin
      sgSymbolPL.ColWidths[0] := -1;
      sgSymbolPL.Width  := G_W - DefColWidth[0]-1;
    end;
    
  end else
  if iCnt = 2 then
  begin
    btnBuyAbleQty.Visible   := false;
    btnSellAbleQty.Visible  := false;
    sgSymbolPL.ColWidths[0] := -1;
    sgSymbolPL.ColWidths[1] := -1;
    sgSymbolPL.ColWidths[3] := -1;
    //sgSymbolPL.ColWidths[4] := -1;
    sgSymbolPL.Width  := G_W - DefColWidth[0] - DefColWidth[1] - DefColWidth[3] {- DefColWidth[4]} - 3;
  end else
  if iCnt = 3 then
  begin
    btnBuyAbleQty.Visible   := false;
    btnSellAbleQty.Visible  := false;
    sgSymbolPL.ColWidths[0] := -1;
    sgSymbolPL.ColWidths[1] := -1;
    sgSymbolPL.ColWidths[3] := -1;
    sgSymbolPL.ColWidths[4] := -1;
    sgSymbolPL.Width  := G_W - DefColWidth[0] - DefColWidth[1] - DefColWidth[3] - DefColWidth[4] - 4;
  end ;

  iLen  := 3+ sgSymbolPL.Width +5;
  cbHogaFix.Left  := iLen;
  Label8.Left     := iLen;
  edtStopTick.Left:= iLen+28;
  udStopTick.Left := iLen+51;
end;

procedure TFrmQtySet.ResetPos;
begin
  sgSymbolPL.Rows[1].Clear;
end;

procedure TFrmQtySet.SetSymbol(aSymbol: TSymbol);
begin
  if aSymbol = nil  then Exit;  
  AddSymbolCombo(aSymbol, cbSymbol );
  Edit1.Text  := aSymbol.Name;
end;

procedure TFrmQtySet.SpeedButton1Click(Sender: TObject);
var
  iQTy : integer;
begin
  if edtTmpQty.Visible then
    edtTmpQty.Hide;
  edtorderQty.Text  :=  (Sender as TSpeedButton).Caption;
end;

procedure TFrmQtySet.SpeedButton1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
  begin
    if edtTmpQty.Visible then
      edtTmpQty.Hide;
    with Sender as TSpeedButton do
    begin
      edtTmpQty.Left := Left + 1;
      edtTmpQty.Top  := Top  + 1;
      edtTmpQty.Width:= Width - 2;
      edtTmpQty.Height:= Height -2;
      edtTmpQty.Text  := Caption;
      edtTmpQty.Show;
      LastButton  := Sender as TSpeedButton;
      edtTmpQty.SetFocus;
      edtTmpQty.SelectAll;
    end;
  end;
end;

end.
