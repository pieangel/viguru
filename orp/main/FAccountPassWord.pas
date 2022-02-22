unit FAccountPassWord;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleAccounts, StdCtrls, Grids, ExtCtrls,

  EnvFile
  ;

const
  CK_COL = 0;
  ACNT_COL = 1;
  EDT_COL  = 3;

  BEGIN_OF_ACNT = 'begin_of_acnt';
  END_OF_ACNT =   'end_of_acnt';

type
  TFrmAccountPassWord = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Panel2: TPanel;
    sgAcnt: TStringGrid;
    cbAll: TCheckBox;
    CheckBox1: TCheckBox;

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
    procedure sgAcntTopLeftChanged(Sender: TObject);
    procedure Panel2Resize(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    { Private declarations }
    FCol, FRow : integer;
    FModal  : boolean;
    procedure reArrangeControls;
    procedure SaveAccountPassword;
    procedure LoadAccountPassword;
    function FindNextUserBlock(aEnvFile: TEnvFile; var iP,
      iEndP: Integer): Boolean;
    function SaveAccount(aEnvFile: TEnvFile; aInvest: TInvestor): Boolean;
    function LoadAccount(aEnvFile: TEnvFile; var iP: Integer): Boolean;
  public
    { Public declarations }
    function Open : Boolean;
  end;

var
  FrmAccountPassWord: TFrmAccountPassWord;

implementation

uses
  GAppEnv, GleLib, GleConsts, GleTypes, GAppConsts


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
      ShowMessage('저장할 계좌가 없습니다.');
      Exit;
    end;

    gLog.Add( lkApplication, 'TFrmAccountPassWord', 'Button1Click', '비번 저장 계좌 : ' + stLog );
    // 2016.11.01 added  비번 저장
    SaveAccountPassword;

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

procedure TFrmAccountPassWord.CheckBox1Click(Sender: TObject);
var
  stpass : string;

  procedure SetChar( c : char );
  var
    I: Integer;
    aEdt : TEdit;
  begin
    for I := 1 to sgAcnt.RowCount - 1 do
    begin
      aEdt  := TEdit( sgAcnt.Objects[ EDT_COL, i]);
      aEdt.PasswordChar := c;
    end;
  end;
begin

  if CheckBox1.Checked then
  begin
    ///if InputQuery('계좌비번보기', '접속비번은? : ', stpass) then
    if InputPass('계좌비번보기', '접속비번은? : ', stpass) then
    begin
      if stpass = '' then
      begin
        ShowMessage('접속비번을 입력하세요.');
        CheckBox1.Checked := false;
      end else
      begin
        if stpass = gEnv.ConConfig.Password then
        begin
          SetChar( #0)
        end
        else begin
          ShowMessage('접속비번이 틀립니다.');
          CheckBox1.Checked := false;
        end;
      end;
    end else CheckBox1.Checked := false;
  end else SetChar('*');
end;

procedure TFrmAccountPassWord.FormActivate(Sender: TObject);
var
  aEdt : TEdit;
begin
  aEdt := TEdit( sgAcnt.Objects[EDT_COL, 1]);
  if aEdt <> nil then
    aEdt.SetFocus;
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
  aRect : TRect;
begin
  //
  with sgAcnt do
  begin
    Cells[1,0]  := '계좌명';
    Cells[2,0]  := '계좌번호';
    Cells[3,0]  := '비번';
  end;

  FCol := -1;
  FRow := -1;
  FModal  := false;

  sgAcnt.RowCount := gEnv.Engine.TradeCore.Investors.Count+1;

  iTop := 22;

  LoadAccountPassword;

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
      Parent  := cbAll.Parent;
    end;

    aRect := sgAcnt.CellRect( EDT_COL, i+1);
    aEdt  := TEdit.Create( Self );
    with aEdt do
    begin
      SetBounds( aRect.Left+1, aRect.Top+1, aRect.Right- aRect.Left-1, 16  );
      BorderStyle  := bsNone;
      PasswordChar := '*';
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

procedure TFrmAccountPassWord.Panel2Resize(Sender: TObject);
begin
  reArrangeControls;
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

    aEdt    : TEdit;
    aCk     : TCheckBox;
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

procedure TFrmAccountPassWord.reArrangeControls;
var
  I: Integer;
  aCK : TCheckBox;
  aEdt: TEdit;
  aRect: TRect;
begin
  for I := 1 to sgAcnt.RowCount - 1 do
  begin
    aCK := TCheckBox( sgAcnt.Objects[CK_COL, i]);
    aEdt:= TEdit( sgAcnt.Objects[EDT_COL, i]);

    aRect := sgAcnt.CellRect( CK_COL, i);
    if aCK <> nil then
      aCk.SetBounds( cbAll.Left, aRect.Top+2, aCK.Width, aCK.Height  );

    aRect := sgAcnt.CellRect( EDT_COL, i);
    if aEdt <> nil then
      aEdt.SetBounds( aRect.Left+1, aRect.Top+1, aRect.Right- aRect.Left-1, 16  );
  end;
end;


function TFrmAccountPassWord.FindNextUserBlock(aEnvFile: TEnvFile; var iP, iEndP: Integer) : Boolean;
var
  i : Integer;
  bStart, bEnd : Boolean;
begin
  i := iP;
  bStart := False;
  bEnd := False;
  Result := False;

  while i <= aEnvFile.Lines.Count-1 do
  begin
    if CompareStr(aEnvFile.Lines[i], BEGIN_OF_ACNT) = 0 then
    begin
      iP := i;
      bStart := True;
    end else
    if CompareStr(aEnvFile.Lines[i], END_OF_ACNT) = 0 then
    begin
      iEndP := i;
      bEnd := True;
    end;

    Inc(i);

    if bStart and bEnd and (iEndP > iP) then
      Break;
  end;

  Result := (bStart and bEnd and (iEndP > iP));
end;


function TFrmAccountPassWord.SaveAccount(aEnvFile: TEnvFile; aInvest: TInvestor): Boolean;
var
  i : Integer;
begin
  Result := False;

  if (aEnvFile = nil) or (aInvest = nil) then Exit;

  aEnvFile.Lines.Add(aInvest.Code);
  aEnvFile.Lines.Add(aInvest.PassWord );

  Result := True;
end;

procedure TFrmAccountPassWord.SaveAccountPassword;
var
  i, j, iP, iEndP, iUserCnt, iGroupCnt, iUserSaveCount : Integer;
  iLong : Integer;
  iVersion : Word;
  stFileName, stUserID : String;
  aEnvOld, aEnvNew : TEnvFile;
begin

  if gEnv.Engine.TradeCore.Investors.Count <= 0 then Exit;

  stFileName  := '\'+ DIR_ENV + '\' + FILE_ACNT_INFO;

  aEnvOld := TEnvFile.Create;
  aEnvNew := TEnvFile.Create;

  try
    // load group information to a string list
    if aEnvOld.Exists(stFileName) then
      aEnvOld.LoadLines(stFileName);

    iP := 0;
      // get version & user count
    if aEnvOld.Lines.Count = 0 then
    begin
      iVersion := 0;
      iUserCnt := 0;
    end else
    begin
      iLong := StrToInt(aEnvOld.Lines[iP]); Inc(iP); // version(2) + Count(2)
      iVersion := HiWord(iLong);
      iUserCnt := LoWord(iLong);    // the number of saved HTS IDs
    end;

      // copy the old information except the one under the current ID
    iUserSaveCount := 0;
    
    if (iVersion = GURU_VERSION) and (iUserCnt > 0) then
    begin
      for i:=0 to iUserCnt-1 do
      begin
          // find user block
        if not FindNextUserBlock(aEnvOld, iP, iEndP) then Break;
          // get ID for the user block
        stUserID := aEnvOld.Lines[iP+1];
          // save if the ID is not the current HTS ID
        if CompareStr(stUserID, gEnv.ConConfig.UserID) <> 0 then
        begin
            // copy a USER block
          while iP <= iEndP do
          begin
            aEnvNew.Lines.Add(aEnvOld.Lines[iP]);
            Inc(iP);
          end;
            // increase user count
          Inc(iUserSaveCount);
        end;
          // next
        iP := iEndP + 1;
      end;
    end;

      // save groups under the current HTS ID
    aEnvNew.Lines.Add(BEGIN_OF_ACNT);
    aEnvNew.Lines.Add(gEnv.ConConfig.UserID);
    aEnvNew.Lines.Add(IntToStr(gEnv.Engine.TradeCore.Investors.Count));
    for i:=0 to gEnv.Engine.TradeCore.Investors.Count-1 do
      SaveAccount(aEnvNew, gEnv.Engine.TradeCore.Investors.Investor[i]);
    aEnvNew.Lines.Add(END_OF_ACNT);

    Inc(iUserSaveCount);

      // insert version & count
    iLong := MakeLong(iUserSaveCount, GURU_VERSION);
    aEnvNew.Lines.Insert(0, IntToStr(iLong));

      // save to file
    aEnvNew.SaveLines( stFileName);
  finally
    aEnvOld.Free;
    aEnvNew.Free;
  end;


end;

function TFrmAccountPassWord.LoadAccount(aEnvFile: TEnvFile; var iP: Integer): Boolean;
var
  i, iAccCnt: Integer;
  iMultiple : integer;
  stAccount : String;

  aInvest : TInvestor;
begin
  Result := False;

  try
    aInvest := gEnv.Engine.TradeCore.Investors.Find( aEnvFile.Lines[iP]) ;
    Inc(iP);          //--1. 계좌
    if aInvest <> nil then
      aInvest.PassWord  := aEnvFile.Lines[iP];
    Inc(iP);          //--3. 비번
    Result := True;
  except
  end;
end;

procedure TFrmAccountPassWord.LoadAccountPassword;
var
  i, j, iP, iEndP, iUserCnt, iGroupCnt : Integer;
  iLong : Integer;
  iVersion : Word;
  stFileName, stUserID : String;
  aEnvFile : TEnvFile;
begin

  stFileName  := '\' + DIR_ENV + '\' + FILE_ACNT_INFO;

  aEnvFile := TEnvFile.Create;
  try
    if (not aEnvFile.Exists(stFileName)) or
       (not aEnvFile.LoadLines(stFileName)) or
       (aEnvFile.Lines.Count = 0)
    then
      Exit;

    iP := 0;

      // version + count
    iLong := StrToInt(aEnvFile.Lines[iP]); Inc(iP);
      // get version
    iVersion := HiWord(iLong);

      // load by version
    if iVersion = 0 then
    begin // conversion from the old version
      iGroupCnt := LoWord(iLong);

      for i:=0 to iGroupCnt - 1 do
        if not LoadAccount(aEnvFile, iP) then
          Break;

        // make sure version change
      SaveAccountPassword;
    end else
      // new version
    if iVersion = GURU_VERSION then
    begin
      iUserCnt := LoWord(iLong);    // User ID Number

      for i:=0 to iUserCnt-1 do
      begin
        if not FindNextUserBlock(aEnvFile, iP, iEndP) then Break;

        Inc(iP);
        stUserID := aEnvFile.Lines[iP];
        Inc(iP);

          // 저장된 ID가 현재 로그인한 ID 와 같을 경우
        if CompareStr(stUserID, gEnv.ConConfig.UserID ) = 0 then
        begin
          iGroupCnt := StrToInt(aEnvFile.Lines[iP]); Inc(iP);
          for j:=0 to iGroupCnt - 1 do
            if not LoadAccount(aEnvFile, iP) then
              Break;

          Break;
        end;

        iP := iEndP + 1;
      end;  //... for i
    end;  //... if iVersion = 0 then
  finally
    aEnvFile.Free;
  end;

end;

procedure TFrmAccountPassWord.sgAcntTopLeftChanged(Sender: TObject);
begin
  reArrangeControls;
end;

end.
