unit FAccountPassWord;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleAccounts, StdCtrls, Grids;

const
  CK_COL = 0;
  ACNT_COL = 1;
  EDT_COL  = 3;

type
  TFrmAccountPassWord = class(TForm)
    Button1: TButton;
    Button2: TButton;
    sgAcnt: TStringGrid;
    cbAll: TCheckBox;

    procedure sgAcntDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure FormCreate(Sender: TObject);

    procedure sgAcntMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgAcntMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure cbAllClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure sgAcntGetEditText(Sender: TObject; ACol, ARow: Integer;
      var Value: string);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    FCol, FRow : integer;
    FModal  : boolean;
  public
    { Public declarations }
    function Open : Boolean;
  end;

var
  FrmAccountPassWord: TFrmAccountPassWord;

implementation

uses
  GAppEnv, GleLib, GleConsts, GleTypes
  ;

{$R *.dfm}

procedure TFrmAccountPassWord.Button1Click(Sender: TObject);
var
  I, iCnt: Integer;
  aInvest : TInvestor;
  aEdt    : TEdit;
  stLog : string;
begin

  iCnt := 0;
  stLog := '';
  for I := 1 to sgAcnt.RowCount - 1 do
    if TCheckBox( sgAcnt.Objects[CK_COL, i]).Checked then
    begin
      aEdt    := TEdit( sgAcnt.Objects[EDT_COL, i]);
      aInvest := TInvestor( sgAcnt.Objects[ACNT_COL,i]);
      if (aInvest <> nil) and ( aEdt.Text <> '') then
      begin
        aInvest.PassWord  := aEdt.Text;
        gEnv.Engine.TradeBroker.AccountEvent( aInvest, ACCOUNT_PWD );
        inc( iCnt );
        stLog := stLog + aInvest.Code + ' ';
      end;
    end;

  if iCnt = 0 then
  begin
    ShowMessage('?????? ?????? ????????.');
    Exit;
  end;

  gLog.Add( lkApplication, 'TFrmAccountPassWord', 'Button1Click', '???? ???? ???? : ' + stLog );

  if FModal then
    ModalResult := mrOK
  else
    Close;
end;

procedure TFrmAccountPassWord.Button2Click(Sender: TObject);
begin
  if FModal then
    ModalResult := mrCancel
  else
    Close;
end;

procedure TFrmAccountPassWord.cbAllClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 1 to sgAcnt.RowCount - 1 do
    TCheckBox( sgAcnt.Objects[CK_COL, i]).Checked := cbAll.Checked;
end;

procedure TFrmAccountPassWord.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := caFree;
end;

procedure TFrmAccountPassWord.FormCreate(Sender: TObject);
var
  I, iTop: Integer;
  aCK : TCheckBox;
  aEdt: TEdit;
  aInvest : TInvestor;
begin
  //
  with sgAcnt do
  begin
    Cells[1,0]  := '??????';
    Cells[2,0]  := '????????';
    Cells[3,0]  := '????';
  end;

  FCol := -1;
  FRow := -1;
  FModal  := false;

  sgAcnt.RowCount := gEnv.Engine.TradeCore.Investors.Count+1;

  iTop := 22;

  with sgAcnt do

  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
  begin
    aInvest := gEnv.Engine.TradeCore.Investors.Investor[i];
    Cells[ 1, i+1]  := aInvest.Name;
    Cells[ 2, i+1]  := aInvest.Code;
    //Cells[ 3, i+1]  := aInvest.PassWord ;

    aCK := TCheckBox.Create( Self );
    with aCk do
    begin
      Left  := cbAll.Left;
      Top   := cbAll.Top + (DefaultRowHeight * (i+1))+(i+1);
      Width := cbAll.Width;
      Height:= cbAll.Height;
      Color := clWhite;
      Parent  :=  cbAll.Parent;
    end;

    aEdt    := TEdit.Create( Self );
    with aEdt do
    begin
      Left  := 260;
      Top   := iTop + (DefaultRowHeight * i) + ( i* 1);
      BorderStyle  := bsNone;
      PasswordChar := '*';
      Width := 40;
      Height:= 17;
      Text  := aInvest.PassWord;
      Parent:= cbAll.Parent;
      TabOrder  := i;
    end;

    if aInvest.PassWord = '' then
      aCK.Checked := true;

    Objects[ CK_COL, i+1] := aCK;
    Objects[ACNT_COL,i+1] := aInvest;
    Objects[EDT_COL ,i+1] := aEdt;
  end;

end;

procedure TFrmAccountPassWord.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    Button1Click( Button1 );

end;

function TFrmAccountPassWord.Open: Boolean;
begin
  FModal := true;
  Result := (ShowModal = mrOK);
end;

procedure TFrmAccountPassWord.sgAcntDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
  var
    aGrid : TStringGrid;
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aRect : TRect;
    aPos : TPosition;
begin
  aGrid := Sender as TStringGrid;

  aFont   := clBlack;
  aBack   := clWhite;
  dFormat := DT_CENTER or DT_VCENTER;
  aRect   := Rect;

  with aGrid do
  begin
    stTxt := Cells[ ACol, ARow];

    if ARow = 0 then
      aBack := clBtnFace;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    aRect.Top := aRect.Top + 1;

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );

    if ARow = 0 then begin
      Canvas.Pen.Color := clBlack;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Right, Rect.Bottom),
                       Point(Rect.Right, Rect.Top)]);
      Canvas.Pen.Color := clWhite;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Left,  Rect.Top),
                       Point(Rect.Right, Rect.Top)]);
    end;
  end;

end;




procedure TFrmAccountPassWord.sgAcntGetEditText(Sender: TObject; ACol,
  ARow: Integer; var Value: string);
  var
    aInvest : Tinvestor;
begin {
  aInvest := TInvestor( sgAcnt.Objects[ACNT_COL, ARow] );
  if aInvest.PassWord <> '' then
    Value := aInvest.PassWord;
    }
end;

procedure TFrmAccountPassWord.sgAcntMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {
  sgAcnt.EditorMode := false;
  sgAcnt.Options    := sgAcnt.Options - [ goEditing ];
  }
end;

procedure TFrmAccountPassWord.sgAcntMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  {
  sgAcnt.MouseToCell( X, Y, FCol, FRow);

  with sgAcnt do
    if ( FCol = 3 ) and ( FRow > 0 ) and
       ( Objects[CK_COL, FRow] <> nil ) and ( Objects[ACNT_COL, FRow] <> nil ) then
    begin
      if TCheckBox(Objects[CK_COL,FRow]).Checked then begin
        Options     := Options + [ goEditing ];
        EditorMode  := true;
      end;
    end else begin
      EditorMode  := true;
      Options     := Options - [ goEditing ];
    end;
  }
end;

end.
