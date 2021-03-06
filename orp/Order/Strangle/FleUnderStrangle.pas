unit FleUnderStrangle;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Grids,

  CleAccounts, CleFunds,  CleSymbols,

  CleStrangleConfig,  CleUnderStrangle,

  CleStorage, Menus
  ;

const
  CheckCol1 = 0;
  CheckCol2 = 2;

  CHKON = 100;
  CHKOFF = -100;

type
  TFrmUnderStrangle = class(TForm)
    stTxt: TStatusBar;
    plRun: TPanel;
    cbRun: TCheckBox;
    Button6: TButton;
    edtAccount: TEdit;
    sgInput: TStringGrid;
    dtStart: TDateTimePicker;
    dtEnd: TDateTimePicker;
    edtOrdQty: TLabeledEdit;
    edtLiskAmt: TLabeledEdit;
    Label2: TLabel;
    cbUseLiq: TCheckBox;
    sgSymbol: TStringGrid;
    rbBuy: TRadioButton;
    rbSell: TRadioButton;
    Button2: TButton;
    edtEC: TLabeledEdit;
    Button1: TButton;
    Label1: TLabel;
    sg: TStringGrid;
    Timer1: TTimer;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    procedure sgInputDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure edtLiskAmtKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure sgInputMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgInputMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button6Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbRunClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure sgSymbolMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N2Click(Sender: TObject);
  private
    { Private declarations }
    FUnRow : array [0..1] of integer;
    FUnCol : array [0..1] of integer;
    FAccount : TAccount;
    FFund    : TFund;
    FIsFund  : boolean;
    FParam: TUnderStrangleParam;
    FUnderSg: TUnderStrangle;

    FCalls : TList;
    FPuts  : TList;

    procedure initControls;
    procedure GetParam;
    procedure OnTextNotifyEvent(Sender: TObject; Value: String);
    procedure SymbolGridClear;
  public
    { Public declarations }
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );

    procedure Start;
    procedure Stop;

    property Param : TUnderStrangleParam read FParam write FParam;
    property UnderSg : TUnderStrangle read FUnderSg;

  end;

var
  FrmUnderStrangle: TFrmUnderStrangle;

implementation

uses
  GAppEnv , GleLib , GleConsts ,
  CleFQN
  ;

{$R *.dfm}

procedure TFrmUnderStrangle.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmUnderStrangle.FormCreate(Sender: TObject);
begin
  initControls;

  FAccount := nil;
  FFund    := nil;
  FIsFund  := false;

  FUnderSg:= TUnderStrangle.Create;
  FUnderSg.OnNotify :=  OnTextNotifyEvent;

  FCalls := TList.Create;
  FPuts  := TList.Create;
end;

procedure TFrmUnderStrangle.FormDestroy(Sender: TObject);
begin
  //
  FPuts.Free;
  FCalls.Free;
  FUnderSg.OnNotify := nil;
  FUnderSg.Free;
end;

procedure TFrmUnderStrangle.GetParam;
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

    UseLiq    := cbUseLiq.Checked;
    LiskAmt   := StrToFloatDef( edtLiskAmt.Text, 20 );

    if rbBuy.Checked then    
      OrderMethod := omBuy
    else OrderMethod := omSell;

    for I := 1 to sgInput.RowCount - 1 do
    begin
      if sgInput.Objects[ CheckCol1, i] = nil then
        UndPlus[i-1] := false
      else
        UndPlus[i-1] := Integer( sgInput.Objects[CheckCol1,i] ) = CHKON;

      UndValue[i-1]  := StrToFloatDef( sgInput.Cells[1,i], 1 );

      if sgInput.Objects[ CheckCol2, i] = nil then
        UndMinus[i-1] := false
      else
        UndMinus[i-1] := Integer( sgInput.Objects[CheckCol2,i] ) = CHKON;
    end;
  end;

end;

procedure TFrmUnderStrangle.initControls;
var
  i : integer;
begin
  with sgInput do
  begin
    Cells[0,0]  := '+';
    Cells[1,0]  := 'Point';
    Cells[2,0]  := '-';

    Cells[1,1]  := '1';
    Cells[1,2]  := '1.5';
    Cells[1,3]  := '2';
    Cells[1,4]  := '2.5';
    Cells[1,5]  := '3';

    for I := 1 to RowCount - 1 do
    begin
      Objects[CheckCol1, i] := Pointer(CHKON);
      Objects[CheckCol2, i] := Pointer(CHKON);
    end;
  end;

  with sgSymbol do
  begin
    Cells[0,0]  := 'Call';
    Cells[1,0]  := 'Put';
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

procedure TFrmUnderStrangle.LoadEnv(aStorage: TStorage);
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

    for I := 1 to sgInput.RowCount - 1 do
    begin
      sgInput.Objects[CheckCol1, i] := Pointer( FieldByName( Format('under_%d_%d', [ CheckCol1, i ])).AsIntegerDef( CHKON ));
      sgInput.Cells[1, i] := FieldByName( Format('under_%d_%d', [ 1, i ])).AsStringDef( Format('%.2f', [ 1 + i * 0.5  ]));
      sgInput.Objects[CheckCol2, i] := Pointer( FieldByName( Format('under_%d_%d', [ CheckCol2, i ])).AsIntegerDef( CHKON ));

    end;

    rbBuy.Checked := FieldByName('UseBuy').AsBoolean;
    rbSell.Checked  := not rbBuy.Checked;

    edtEC.Text  := FieldByName('OrdEc').AsStringDef('5');
    edtOrdQty.Text  := FieldByName('OrdQty').AsStringDef('1');
    edtLiskAmt.Text := FieldByName('LiskAmt').AsStringDef('20');

    cbUseLiq.Checked  := FieldByName('UseLiq').AsBooleanDef( true );

  end;

end;

procedure TFrmUnderStrangle.N1Click(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  if (FUnCol[1] >=0) and  (FUnCol[1] <= 1 ) and
     (FunRow[1] >=1) and  (FUnRow[1] <= 2 ) then
  with sgSymbol do
    if Objects[FUnCol[1], FUnRow[1]] <> nil then
    begin
      aSymbol := TSymbol( Objects[FUnCol[1], FUnRow[1]] );
      Cells[FUnCol[1], FUnRow[1]] := '';
      Objects[FUnCol[1], FUnRow[1]] := nil;

      case FUnCol[1] of
        0 : FCalls.Remove( aSymbol );
        1 : FPuts.Remove( aSymbol);
      end;
    end;
end;

procedure TFrmUnderStrangle.N2Click(Sender: TObject);
var
  I: Integer;
  aSymbol : TSymbol;
begin

  if not ( cbRun.Checked ) then Exit;
  if FUnderSg = nil then Exit;

  FCalls.Clear;
  FPuts.Clear;

  for I := 1 to sgSymbol.RowCount - 1 do
  begin
    if sgSymbol.Objects[0,i] <> nil then
      FCalls.Add( sgSymbol.Objects[0,i] );
    if sgSymbol.Objects[1,i] <> nil then
      FPuts.Add( sgSymbol.Objects[1,i] );
  end;

  if ( FCalls.Count <= 0 ) or ( FPuts.Count <= 0 ) then
  begin
    ShowMessage('?????????? ??????');
    Exit;
  end;

  FUnderSg.UpdateSymbols( FCalls, FPuts);
  
end;

procedure TFrmUnderStrangle.OnTextNotifyEvent(Sender: TObject; Value: String);
begin
  if Sender <> FUnderSg then Exit;
  InsertLine( sg, 1 );
  sg.Cells[0,1] := FormatDateTime('hh:nn:ss.zz', now );
  sg.Cells[1,1] := Value;
end;

procedure TFrmUnderStrangle.SaveEnv(aStorage: TStorage);
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

    for I := 1 to sgInput.RowCount - 1 do
    begin
      FieldByName( Format('under_%d_%d', [ CheckCol1, i ])).AsInteger  := integer(sgInput.Objects[CheckCol1, i]);
      FieldByName( Format('under_%d_%d', [         1, i ])).AsString   := sgInput.Cells[1, i];
      FieldByName( Format('under_%d_%d', [ CheckCol2, i ])).AsInteger  := integer(sgInput.Objects[CheckCol2, i]);
    end;

    FieldByName('UseBuy').AsBoolean  :=  rbBuy.Checked;

    FieldByName('OrdEc').AsString := edtEC.Text;
    FieldByName('OrdQty').AsString  := edtOrdQty.Text;
    FieldByName('LiskAmt').AsString := edtLiskAmt.Text;

    FieldByName('UseLiq').AsBoolean := cbUseLiq.Checked;
  end;

end;

procedure TFrmUnderStrangle.Button1Click(Sender: TObject);
var
  iCallRow, iPutRow, i : integer;
  aSymbol : TSymbol;
begin


  if gSymbol = nil then
    gEnv.CreateSymbolSelect;

  try
    if gSymbol.Open( true ) then
    begin
      if gSymbol.ListSelected.Items.Count > 0 then
      begin
        SymbolGridClear;

        iCallRow := 1;
        iPutRow  := 1;

        for i:= 0 to gSymbol.ListSelected.Items.Count-1 do
        begin
          aSymbol := TSymbol( gSymbol.ListSelected.Items[i].Data );
          if aSymbol <> nil then
          begin

            case aSymbol.Spec.Market of
              mtOption:
                case ( aSymbol as TOption).CallPut of
                  'C' :
                    begin
                      if iCallRow >= 3 then Continue;                          
                      sgSymbol.Cells[0,iCallrow] := Format('%.1f', [ ( aSymbol as TOption).StrikePrice ]);
                      sgSymbol.Objects[0, iCallRow] := aSymbol;
                      inc( iCallRow );
                      FCalls.Add( aSymbol );
                    end;
                  'P' :
                    begin
                      if iPutRow >= 3 then Continue;
                      sgSymbol.Cells[1,iPutRow] :=Format('%.1f', [ ( aSymbol as TOption).StrikePrice ]);
                      sgSymbol.Objects[1, iPutRow] := aSymbol;
                      inc( iPutRow );
                      FPUts.Add( aSymbol );
                    end ;
                end;
            end;
          end;
        end;  // for
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmUnderStrangle.Button2Click(Sender: TObject);
begin
  Getparam;
  if ( FUnderSg <> nil ) and ( cbRun.Checked ) then
    FUnderSg.Param := FParam;
end;

procedure TFrmUnderStrangle.Button6Click(Sender: TObject);
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

procedure TFrmUnderStrangle.cbRunClick(Sender: TObject);
begin
 if cbRun.Checked then
    Start
  else
    Stop;
end;

procedure TFrmUnderStrangle.edtLiskAmtKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8, #13]) then
    Key := #0;
end;

procedure TFrmUnderStrangle.sgInputDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
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

    if (ARow > 0 ) and ( Tag = 0 ) then
      case ACol of
        CheckCol1, CheckCol2 :
          begin
            arect := Rect;
            arect.Top := Rect.Top + 2;
            arect.Bottom := Rect.Bottom - 2;
            DrawCheck(Canvas.Handle, arect, integer(Objects[ACol,ARow]) = CHKON );
          end;

      end;
  end;

end;

procedure TFrmUnderStrangle.sgInputMouseDown(Sender: TObject;
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

  if ( FUnRow[iTag] = 0 ) or ( iTag = 1 ) then Exit;

  iTmp := integer(  ( Sender as TStringGrid ).Objects[ FUnCol[iTag], FUnRow[iTag]] ) ;

  if iTmp = CHKON then
    iTmp := CHKOFF
  else
    iTmp:= CHKON;

  ( Sender as TStringGrid ).Objects[ FUnCol[iTag], FUnRow[iTag]] := Pointer(iTmp );
  ( Sender as TStringGrid ).Invalidate;
end;

procedure TFrmUnderStrangle.sgInputMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin

  sgInput.MouseToCell( X, Y, FUnCol[0], FUnRow[0]);

  with sgInput do
    if ( FUnRow[0] > 0 ) and ( FUnCol[0] = 1 )  then
    begin
      Options     := Options + [ goEditing ];
      EditorMode  := true;
    end else begin
      EditorMode  := true;
      Options     := Options - [ goEditing ];
    end;

end;

procedure TFrmUnderStrangle.sgSymbolMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  sgSymbol.MouseToCell( x, y, FUnCol[1], FUnRow[1]);
end;

procedure TFrmUnderStrangle.Start;
var
  I: Integer;
begin

  if ( FCalls.Count <= 0 ) or ( FPuts.Count <= 0 ) then
  begin
    ShowMessage('???????? ??????');
    cbRun.Checked := false;
    Exit;
  end;

  if FIsFund then
  begin
    if ( FFund = nil ) then
    begin
      ShowMessage(' ?????? ??????????');
      cbRun.Checked := false;
      Exit;
    end;
    GetParam;
    FUnderSg.Param := FParam;
    FUnderSg.init( FFund, Self );
  end else
  begin
    if ( FAccount = nil ) then
    begin
      ShowMessage('?????? ??????????');
      cbRun.Checked := false;
      Exit;
    end;
    GetParam;
    FUnderSg.Param := FParam;
    FUnderSg.init( FAccount, Self );
  end;

  FUnderSg.UpdateSymbols( FCalls, FPuts );

  if not FUnderSg.Start then
  begin
    ShowMessage('???????? ????..');
    cbRun.Checked := false;
    Exit;
  end;
  plRun.Color := clSkyblue;


end;

procedure TFrmUnderStrangle.Stop;
begin
  FUnderSg.Stop;
  plRun.Color := clBtnFace;
end;

procedure TFrmUnderStrangle.SymbolGridClear;
begin
  with sgSymbol do
  begin
    Rows[1].Clear;
    Rows[2].Clear;
  end;

  FCalls.Clear;
  FPuts.Clear;
end;

procedure TFrmUnderStrangle.Timer1Timer(Sender: TObject);
var
  i : integer;
  a1, a2 : TOrderCon;
begin
  if ( cbRun.Checked ) and ( FUnderSg <> nil ) then
  begin

    stTxt.Panels[1].Text  := Format('%.0f, %.0f, %.0f', [
      FUnderSg.NowPL, FUnderSg.MaxPL, FUnderSg.MinPL ]);

    with sgInput do
    for I := 0 to FUnderSg.UndPlus.Count - 1 do
    begin
      a1 := TOrderCon( FUnderSg.UndPlus.Items[i] );
      a2 := TOrderCon( FUnderSg.UndMinus.Items[i] );

      if a1.Ordered then
        Cells[CheckCol1, i+1] := '1'
      else
        Cells[CheckCol1, i+1] := '';

      if a2.Ordered then
        Cells[CheckCol2, i+1] := '1'
      else
        Cells[CheckCol2, i+1] := '';
    end;
  end;

  stTxt.Panels[0].Text := Format('%.2f [%.2f]', [
          gEnv.Engine.SymbolCore.Future.Last - gEnv.Engine.SymbolCore.Future.DayOpen,
          gEnv.Engine.SymbolCore.Future.CntRatio])
end;

end.
