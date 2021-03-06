unit FleInvestStrangle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Grids,

  CleAccounts, CleFunds,

  CleStrangleConfig,  CleInvestStrangle,

  CleStorage
  ;

const
  CheckCol1 = 0;
  CheckCol2 = 2;

  CHKON = 100;
  CHKOFF = -100;

type
  TFrmInvestStrangle = class(TForm)
    plRun: TPanel;
    cbRun: TCheckBox;
    Button6: TButton;
    edtAccount: TEdit;
    stTxt: TStatusBar;
    cbInvest: TComboBox;
    sgInvest: TStringGrid;
    cbInvest2: TComboBox;
    sgInvest2: TStringGrid;
    cbUseCnt: TCheckBox;
    edtOrdQty: TLabeledEdit;
    edtEC: TLabeledEdit;
    dtStart: TDateTimePicker;
    Label2: TLabel;
    dtEnd: TDateTimePicker;
    edtLiskAmt: TLabeledEdit;
    cbUseLiq: TCheckBox;
    rgOrdMethod: TRadioGroup;
    Button2: TButton;
    cbUseInvest: TCheckBox;
    Timer1: TTimer;
    sg: TStringGrid;
    edtRvsAmt: TLabeledEdit;
    cbUseHedge: TCheckBox;
    procedure sgInvestDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure sgInvestMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure edtECKeyPress(Sender: TObject; var Key: Char);
    procedure Button6Click(Sender: TObject);
    procedure cbRunClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure sgInvestMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbUseCntClick(Sender: TObject);
  private
    { Private declarations }
    FUnRow  : array [0..1] of integer;
    FUnCol  : array [0..1] of integer;
    FAccount : TAccount;
    FFund    : TFund;
    FIsFund  : boolean;
    FParam: TInvestStrangleParam;
    FInvestSg: TInvestStrangle;
    procedure initControls;
    procedure GetParam;
    procedure OnTextNotifyEvent(Sender: TObject; Value: String);
  public
    { Public declarations }
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );

    procedure Start;
    procedure Stop;

    property Param : TInvestStrangleParam read FParam write FParam;
    property InvestSg : TInvestStrangle read FInvestSg;
  end;

var
  FrmInvestStrangle: TFrmInvestStrangle;

implementation

uses
  GAppEnv , GleLib , GleConsts
  ;

{$R *.dfm}

procedure TFrmInvestStrangle.Button2Click(Sender: TObject);
begin
  Getparam;
  if ( FInvestSg <> nil ) and ( cbRun.Checked ) then
    FInvestSg.Param := FParam;
  
end;

procedure TFrmInvestStrangle.Button6Click(Sender: TObject);
begin
  if cbRun.Checked then begin
    ShowMessage('?????????? ?????? ????');
    Exit;
  end;

  if gAccount = nil then
    gEnv.CreateAccountSelect;

  try
    gAccount.Left := GetMousePoint.X+10;
    gAccount.Top  := GetMousePoint.Y;

    if gAccount.Open then
    begin
      if ( gAccount.Selected <> nil ) then
        if gAccount.Selected is TFund then
        begin
          if FFund <> gAccount.Selected then
          begin
            FIsFund := true;
            FAccount:= nil;
            FFund   := TFund( gAccount.Selected );
            edtAccount.Text := FFund.Name;
          end;
        end else
        begin
            FIsFund := false;
            FFund   := nil;
            FAccount:= TAccount( gAccount.Selected );
            edtAccount.Text := FAccount.Name
        end;
    end;
  finally
    gAccount.Hide;
  end;
end;

procedure TFrmInvestStrangle.cbRunClick(Sender: TObject);
begin
  if cbRun.Checked then
    Start
  else
    Stop;
end;

procedure TFrmInvestStrangle.cbUseCntClick(Sender: TObject);
begin
  if ( cbRun.Checked ) and ( FInvestSg <> nil ) then
    FInvestSg.UpdateParam( ( Sender as TControl).Tag ,
      ( Sender as TCheckBox).Checked );
end;

procedure TFrmInvestStrangle.edtECKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8, #13]) then
    Key := #0;
end;

procedure TFrmInvestStrangle.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmInvestStrangle.FormCreate(Sender: TObject);
begin
  initControls;

  FAccount := nil;
  FFund    := nil;
  FIsFund  := false;

  FInvestSg := TInvestStrangle.Create;
  FinvestSg.OnNotify  := OnTextNotifyEvent;
end;

procedure TFrmInvestStrangle.FormDestroy(Sender: TObject);
begin
  //
  FinvestSg.OnNotify  := nil;
  FInvestSg.Free;
end;

procedure TFrmInvestStrangle.GetParam;
var
  I: integer;
begin
  with FParam do
  begin
    OrdQty    := StrToIntDef( edtOrdQty.Text, 1 );
    EntryCnt  := StrToIntDef( edtEC.Text, 5);
    //
    Endtime   := Frac( dtEnd.Time );
    StartTime := Frac( dtStart.Time );

    UseCnt    := cbUseCnt.Checked;
    UseInvest := cbUseInvest.Checked;
    UseLiq    := cbUseLiq.Checked;
    UseHedge  := cbUseHedge.Checked;

    LiskAmt   := StrToFloatDef( edtLiskAmt.Text, 10 );
    RvsAmt    := StrToFloatDef( edtRvsAmt.Text, 5 );

    OrderMethod := TOrderMethodType( rgOrdMethod.ItemIndex );

    case cbInvest.ItemIndex of
      0 : Ivt1Code :=  INVEST_FORIN;
      1 : Ivt1Code :=  INVEST_FINANCE;
    end;

    case cbInvest2.ItemIndex of
      0 : Ivt2Code := INVEST_FORIN;
      1 : Ivt2Code := INVEST_FINANCE;
      2 : Ivt2Code := INVEST_PERSON;
    end;

    for I := 1 to sgInvest.RowCount - 1 do
    begin
      if sgInvest.Objects[ CheckCol1, i] = nil then
        Ivt1Plue[i-1] := false
      else
        Ivt1Plue[i-1] := Integer( sgInvest.Objects[CheckCol1,i] ) = CHKON;

      Ivt1Value[i-1]  := StrToFloatDef( sgInvest.Cells[1,i], 0 );

      if sgInvest.Objects[ CheckCol2, i] = nil then
        Ivt1Minus[i-1] := false
      else
        Ivt1Minus[i-1] := Integer( sgInvest.Objects[CheckCol2,i] ) = CHKON;
    end;

    for I := 1 to sgInvest2.RowCount - 1 do
    begin
      if sgInvest2.Objects[ CheckCol1, i] = nil then
        Ivt2Plue[i-1] := false
      else
        Ivt2Plue[i-1] := Integer( sgInvest2.Objects[CheckCol1,i] ) = CHKON;

      Ivt2Value[i-1]  := StrToFloatDef( sgInvest2.Cells[1,i] , 0);

      if sgInvest2.Objects[ CheckCol2, i] = nil then
        Ivt2Minus[i-1] := false
      else
        Ivt2Minus[i-1] := Integer( sgInvest2.Objects[CheckCol2,i] ) = CHKON;
    end;
  end;
end;

procedure TFrmInvestStrangle.initControls;
var
  I: integer;
begin
  with sgInvest do
  begin
    Cells[0,0]  := '+';
    Cells[1,0]  := '????';
    Cells[2,0]  := '-';

    Cells[1,1]  := '10';
    Cells[1,2]  := '20';
    Cells[1,3]  := '30';
    Cells[1,4]  := '40';
    Cells[1,5]  := '50';

    for I := 1 to RowCount - 1 do
    begin
      Objects[CheckCol1, i] := Pointer(CHKON);
      Objects[CheckCol2, i] := Pointer(CHKON);
    end;
  end;

  with sgInvest2 do
  begin
    Cells[0,0]  := '+';
    Cells[1,0]  := '????';
    Cells[2,0]  := '-';

    Cells[1,1]  := '10';
    Cells[1,2]  := '20';
    Cells[1,3]  := '30';

    for I := 1 to RowCount - 1 do
    begin
      Objects[CheckCol1, i] := Pointer(CHKON);
      Objects[CheckCol2, i] := Pointer(CHKON);
    end;
  end;

  with sg do
  begin
    Cells[0,0]  := '????';
    Cells[1,0]  := '????';
  end;

  FUnRow[0] := -1;
  FUnRow[1] := -1;

  FUnCol[0] := -1;
  FUnCol[1] := -1;  
end;

procedure TFrmInvestStrangle.LoadEnv(aStorage: TStorage);
var
  I: integer;
  stCode : string;
  aFund  : TFund;
  aAcnt  : TAccount;
begin
  if aStorage = nil then Exit;

  with aStorage do
  begin
    FIsFund := aStorage.FieldByName('IsFund').AsBooleanDef(false);
    stCode := aStorage.FieldByName('AcntCode').AsString;

    if FIsFund  then
    begin
      aFund := gEnv.Engine.TradeCore.Funds.Find( stCode );
      if aFund <> nil then
      begin
        FIsFund  := true;
        FFund    := aFund;
        FAccount := nil;
        edtAccount.Text := FFund.Name;
      end;
    end else
    begin
      aAcnt := gEnv.Engine.TradeCore.Accounts.Find( stCode );
      if aAcnt <> nil then
      begin
        FIsFund   := false;
        FFund     := nil;
        FAccount  := aAcnt;
        edtAccount.Text := FAccount.Name;
      end;
    end;

    dtEnd.Time    := FieldByName('EndTime').AsTimeDef( dtEnd.Time );
    dtStart.Time  := FieldByName('StartTime').AsTimeDef( dtStart.Time );

    cbInvest.ItemIndex  := FieldByName('InvestType').AsIntegerDef( 0 );
    cbInvest2.ItemIndex := FieldByName('InvestType2').AsIntegerDef(1) ;

    for I := 1 to sgInvest.RowCount - 1 do
    begin
      sgInvest.Objects[CheckCol1, i] := Pointer( FieldByName( Format('invest_%d_%d', [ CheckCol1, i ])).AsIntegerDef( CHKON ));
      sgInvest.Cells[1, i] := FieldByName( Format('invest_%d_%d', [ 1, i ])).AsStringDef( Format('%d', [ i * 10  ]));
      sgInvest.Objects[CheckCol2, i] := Pointer( FieldByName( Format('invest_%d_%d', [ CheckCol2, i ])).AsIntegerDef( CHKON ));

    end;

    for I := 1 to sgInvest2.RowCount - 1 do
    begin
      sgInvest2.Objects[CheckCol1, i] := Pointer( FieldByName( Format('invest2_%d_%d', [ CheckCol1, i ])).AsIntegerDef( CHKON ));
      sgInvest2.Cells[1, i] := FieldByName( Format('invest2_%d_%d', [ 1, i ])).AsStringDef( Format('%d', [ i * 10  ]));
      sgInvest2.Objects[CheckCol2, i] := Pointer( FieldByName( Format('invest2_%d_%d', [ CheckCol2, i ])).AsIntegerDef( CHKON ));
    end;

    rgOrdMethod.ItemIndex := FieldByName('ordMethod').AsIntegerDef( 1 );

    edtEC.Text  := FieldByName('OrdEc').AsStringDef('5');
    edtOrdQty.Text  := FieldByName('OrdQty').AsStringDef('1');
    edtLiskAmt.Text := FieldByName('LiskAmt').AsStringDef('10');
    edtRvsAmt.Text  := FieldByName('RvsAmt').AsStringDef('5');

    cbUseHedge.Checked  := FieldByName('UseHedge').AsBoolean;
    cbUseCnt.Checked  := FieldByName('UseCnt').AsBooleanDef( true );
    cbUseLiq.Checked  := FieldByName('UseLiq').AsBooleanDef( true );
    cbUseInvest.Checked := FieldByName('UseInvest').AsBooleanDef( false );
  end;
end;

procedure TFrmInvestStrangle.OnTextNotifyEvent(Sender: TObject; Value: String);
begin
  if Sender <> FInvestSg then Exit;
  InsertLine( sg, 1 );
  sg.Cells[0,1] := FormatDateTime('hh:nn:ss.zz', now );
  sg.Cells[1,1] := Value;
end;

procedure TFrmInvestStrangle.SaveEnv(aStorage: TStorage);
var
  I: integer;
begin
  if aStorage = nil then Exit;

  with aStorage do
  begin
    FieldByName('IsFund').AsBoolean := FIsFund;
    if FIsFund then begin
    if FFund <> nil then
      FieldByName('AcntCode').AsString    := FFund.Name
    else
      FieldByName('AcntCode').AsString    := '';
    end
    else begin
      if FAccount <> nil then
        FieldByName('AcntCode').AsString    := FAccount.Code
      else
        FieldByName('AcntCode').AsString    := '';
    end;

    FieldByName('EndTime').AsFloat         := double( dtEnd.Time );
    FieldByName('StartTime').AsFloat       := double( dtStart.Time );

    FieldByName('InvestType').AsInteger    := cbInvest.ItemIndex;
    FieldByName('InvestType2').AsInteger   := cbInvest2.ItemIndex;

    for I := 1 to sgInvest.RowCount - 1 do
    begin
      FieldByName( Format('invest_%d_%d', [ CheckCol1, i ])).AsInteger  := integer(sgInvest.Objects[CheckCol1, i]);
      FieldByName( Format('invest_%d_%d', [         1, i ])).AsString   := sgInvest.Cells[1, i];
      FieldByName( Format('invest_%d_%d', [ CheckCol2, i ])).AsInteger  := integer(sgInvest.Objects[CheckCol2, i]);
    end;

    for I := 1 to sgInvest2.RowCount - 1 do
    begin
      FieldByName( Format('invest2_%d_%d', [ CheckCol1, i ])).AsInteger  := integer(sgInvest2.Objects[CheckCol1, i]);
      FieldByName( Format('invest2_%d_%d', [         1, i ])).AsString   := sgInvest2.Cells[1, i];
      FieldByName( Format('invest2_%d_%d', [ CheckCol2, i ])).AsInteger  := integer(sgInvest2.Objects[CheckCol2, i]);
    end;

    FieldByName('ordMethod').AsInteger  := rgOrdMethod.ItemIndex;

    FieldByName('OrdEc').AsString := edtEC.Text;
    FieldByName('OrdQty').AsString  := edtOrdQty.Text;
    FieldByName('LiskAmt').AsString := edtLiskAmt.Text;
    FieldByName('RvsAmt').AsString :=  edtRvsAmt.Text;

    FieldByName('UseHedge').AsBoolean := cbUseHedge.Checked;
    FieldByName('UseCnt').AsBoolean := cbUseCnt.Checked;
    FieldByName('UseLiq').AsBoolean := cbUseLiq.Checked;
    FieldByName('UseInvest').AsBoolean := cbUseInvest.Checked;
  end;
end;

procedure TFrmInvestStrangle.sgInvestDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  stTxt : string;
  aBack, aFont : TColor;
  dFormat : Word;
  aRect : TRect;

  procedure DrawCheck(DC:HDC;BBRect:TRect;bCheck:Boolean);
  begin
    if bCheck then
      DrawFrameControl(DC, BBRect, DFC_BUTTON, DFCS_BUTTONCHECK + DFCS_CHECKED)
    else
      DrawFrameControl(DC, BBRect, DFC_BUTTON, DFCS_BUTTONCHECK);
  end;
begin

  aFont   := clBlack;
  aBack   := clWhite;
  dFormat := DT_CENTER or DT_VCENTER;

  with (Sender as TStringGrid) do
  begin
    //
    stTxt := Cells[ ACol, ARow];
    aRect   := Rect;

    if ARow = 0 then
      aBack := clBtnFace;

    if ARow > 0 then
      case ACol of
        CheckCol1, CheckCol2 : if stTxt = '' then
                      aBack := clWhite
                    else
                      aBack := NODATA_COLOR;
      end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    aRect.Top := aRect.Top + 2;
    Canvas.Font.Name :='??????';
    Canvas.Font.Size := 9;

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );

    if (ARow > 0 ) then
      case ACol of
        CheckCol1, CheckCol2 :
          begin
            if ( Tag = 1 ) and ( ARow > 3 ) then Exit;

            arect := Rect;
            arect.Top := Rect.Top + 2;
            arect.Bottom := Rect.Bottom - 2;
            DrawCheck(Canvas.Handle, arect, integer(Objects[ACol,ARow]) = CHKON );
          end;

      end;
  end;
end;

procedure TFrmInvestStrangle.sgInvestMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    iTmp, iTag : integer;
begin

  iTag := ( Sender as TStringGrid ).Tag;
  ( Sender as TStringGrid).MouseToCell( X, Y, FUnCol[iTag], FUnRow[iTAg]);

  with ( Sender as TStringGrid) do
  begin
    EditorMode := false;
    Options    := Options - [ goEditing ];
  end ;

  if  ( FUnRow[iTag] = 0 ) or ( FUnCol[iTag] = 1 ) or
      (( iTag = 1 )  and ( FUnRow[iTag] > 3 )) then Exit;

  iTmp := integer(  ( Sender as TStringGrid ).Objects[ FUnCol[iTag], FUnRow[iTag]] ) ;

  if iTmp = CHKON then
    iTmp := CHKOFF
  else
    iTmp:= CHKON;

  ( Sender as TStringGrid ).Objects[ FUnCol[iTag], FUnRow[iTag]] := Pointer(iTmp );
  ( Sender as TStringGrid ).Invalidate;

end;

procedure TFrmInvestStrangle.sgInvestMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var
    aGrid : TStringGrid;
begin

  aGrid := (Sender as TStringGrid);

  with aGrid do begin
    MouseToCell( X, Y, FUnCol[aGrid.Tag], FUnRow[aGrid.Tag]);
    if ( FUnRow[aGrid.Tag] > 0 ) and ( FUnCol[aGrid.Tag] = 1 )  then
    begin
      Options     := Options + [ goEditing ];
      EditorMode  := true;
    end else begin
      EditorMode  := true;
      Options     := Options - [ goEditing ];
    end;
  end;

end;

procedure TFrmInvestStrangle.Start;
begin
  if FIsFund then
  begin
    if ( FFund = nil ) then
    begin
      ShowMessage(' ?????? ??????????');
      cbRun.Checked := false;
      Exit;
    end;
    GetParam;
    FInvestSg.Param := FParam;
    FInvestSg.init( FFund, Self );
  end else
  begin
    if ( FAccount = nil ) then
    begin
      ShowMessage('?????? ??????????');
      cbRun.Checked := false;
      Exit;
    end;
    GetParam;
    FInvestSg.Param := FParam;
    FInvestSg.init( FAccount, Self );
  end;

  if not FInvestSg.Start then
  begin
    ShowMessage('???????? ????..');
    cbRun.Checked := false;
    Exit;
  end;
  plRun.Color := clSkyblue;
end;

procedure TFrmInvestStrangle.Stop;
begin
  FInvestSg.Stop;
  plRun.Color := clBtnFace;
end;

procedure TFrmInvestStrangle.Timer1Timer(Sender: TObject);
var
  d1, d2, d3 : double;
  Ivt1Code, Ivt2Code : string;
  I: Integer;
  a1, a2 : TOrderCon;
begin
  i := 0;
  if ( cbRun.Checked ) and ( FInvestSg <> nil ) then
  begin
    FInvestSg.OnTimer;
    stTxt.Panels[1].Text  := Format('%.0f, %.0f, %.0f', [
      FInvestSg.NowPL, FInvestSg.MaxPL, FInvestSg.MinPL ]);

    with sgInvest do
    for I := 0 to FInvestSg.Ivt1Plus.Count - 1 do
    begin
      a1 := TOrderCon( FInvestSg.Ivt1Plus.Items[i] );
      a2 := TOrderCon( FInvestSg.Ivt1Minus.Items[i] );

      if a1.Ordered then
        Cells[CheckCol1, i+1] := '1'
      else
        Cells[CheckCol1, i+1] := '';

      if a2.Ordered then
        Cells[CheckCol2, i+1] := '1'
      else
        Cells[CheckCol2, i+1] := '';
    end;


    with sgInvest2 do
    for I := 0 to FInvestSg.Ivt2Plus.Count - 1 do
    begin
      a1 := TOrderCon( FInvestSg.Ivt2Plus.Items[i] );
      a2 := TOrderCon( FInvestSg.Ivt2Minus.Items[i] );

      if a1.Ordered then
        Cells[CheckCol1, i+1] := '1'
      else
        Cells[CheckCol1, i+1] := '';

      if a2.Ordered then
        Cells[CheckCol2, i+1] := '1'
      else
        Cells[CheckCol2, i+1] := '';
    end;

    i :=  FInvestSg.OrderCnt;
  end;

  case cbInvest.ItemIndex of
    0 : Ivt1Code :=  INVEST_FORIN;
    1 : Ivt1Code :=  INVEST_FINANCE;
  end;

  case cbInvest2.ItemIndex of
    0 : Ivt2Code := INVEST_FORIN;
    1 : Ivt2Code := INVEST_FINANCE;
    2 : Ivt2Code := INVEST_PERSON;
  end;

  d1 := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.GetTojaja( Ivt1Code );
  d2 := gEnv.Engine.SymbolCore.ConsumerIndex.InvestorDatas.GetToSinglejaja( Ivt2Code );
  d3 := gEnv.Engine.SymbolCore.Future.CntRatio;

  stTxt.Panels[0].Text  := Format('%dth %.0f, %.0f, %.2f',[ i, d1, d2, d3]);
  
end;

end.
