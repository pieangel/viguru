unit FLogIn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,

  GleTypes, IdHTTP, IdAntiFreezeBase, IdAntiFreeze, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase,
  IdFTP,

  CleParsers
  ;
type
  TFrmLogin = class(TForm)
    Ftp: TIdFTP;
    Timer: TTimer;
    IdAntiFreeze1: TIdAntiFreeze;
    idh: TIdHTTP;
    gb0Lee: TGroupBox;
    lbTitle: TLabel;
    edt0LeeID: TLabeledEdit;
    edt0LeePW: TLabeledEdit;
    Button1: TButton;
    stResult: TStaticText;
    gbLogin: TGroupBox;
    edtID: TLabeledEdit;
    edtPW: TLabeledEdit;
    edtCert: TLabeledEdit;
    btnCon: TButton;
    btnExit: TButton;
    cbSaveInput: TCheckBox;
    cbMock: TCheckBox;
    procedure Button2Click(Sender: TObject);
    procedure cbMockClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure edtIDKeyPress(Sender: TObject; var Key: Char);
    procedure btnConClick(Sender: TObject);
  private
    procedure initControls;
    procedure DoLogin;


    { Private declarations }
  public
    { Public declarations }
    AutoLogin : boolean;
    procedure DoAutoLogin;
    procedure InitLogin;
    procedure SaveLoginData;
  end;

var
  FrmLogin: TFrmLogin;

implementation

uses
  GAppEnv  , Math
  ;

{$R *.dfm}

procedure TFrmLogin.btnConClick(Sender: TObject);
var
  iMode : integer;
  function CheckEmpty( aEdt : TLabeledEdit ) : boolean;
  begin
    if aEdt.Text = '' then begin
      Result := false;
      aEdt.SetFocus;
    end else Result := true;
  end;
begin

  if not CheckEmpty( edtID ) then Exit;
  if not CheckEmpty( edtPW ) then Exit;

  DoLogin;
end;

procedure TFrmLogin.DoAutoLogin;
var
  iMode : integer;
begin

  InitLogin;
  DoLogin;
end;

procedure TFrmLogin.DoLogin;
var
  iRes, iMode : integer;
begin

  if (( edtID.Text  = '150201' ) and ( edtPW.Text  = 'kr1219' ))  then
    gEnv.UserType := utStaff
  else begin
    gEnv.UserType := utNormal;
  end;

  iMode := ifThen( cbMock.Checked , 2, 0 );
  iRes := gEnv.Engine.Api.DoLogIn( edtID.Text, edtPW.Text, edtCert.Text, iMode );
  if iRes <> 0 then
  begin
    //ShowMessage( gEnv.Engine.Api.GetErrorMessage( iRes));
    gEnv.EnvLog( WIN_ERR, gEnv.Engine.Api.GetErrorMessage( iRes) );
  end;

end;

procedure TFrmLogin.SaveLoginData;
begin
    gEnv.ConConfig.Save0LeeID := edt0LeeID.Text;
    gEnv.ConConfig.Save0LeePW := edt0LeePW.Text;

    gEnv.ConConfig.SaveInput:= cbSaveInPut.Checked;
    gEnv.ConConfig.RealMode := not cbMock.Checked;
    if gEnv.ConConfig.RealMode then
    begin
      gEnv.ConConfig.SaveID[0]  := edtID.Text;
      gEnv.ConConfig.SavePW[0]  := edtPW.Text;
      gEnv.ConConfig.SaveCert[0]:= edtCert.Text;
    end
    else begin
      gEnv.ConConfig.SaveID[1]  := edtID.Text;
      gEnv.ConConfig.SavePW[1]  := edtPW.Text;
      gEnv.ConConfig.SaveCert[1]:= edtCert.Text;
    end;
end;

procedure TFrmLogin.btnExitClick(Sender: TObject);
begin
  ModalResult := IDCANCEL;
end;

procedure TFrmLogin.Button1Click(Sender: TObject);
var
  strs : TStringList;
  aParser : TParser;
  stID, s : string;
  iCnt, iCode : integer;
begin
  try
    btnCon.Enabled  := false;
    Button1.Enabled := false;
    strs := TStringList.Create;

    stResult.Caption  := '???????? ???? ???????? ????????.';

    strs.Values['code'] := 'SOL_000067';
    strs.Values['user_id'] := edt0LeeID.Text;
    strs.Values['user_pw'] := edt0LeePW.Text;
    s := idh.Post('http://service.ylrms.com/auth', strs);

    aParser := TParser.Create([',']);
    iCnt := aparser.Parse( s );

    if iCnt <= 0 then
    begin
      stResult.Caption  := ('?????? ???? ???? ???? ????????????' ) ;
      Exit;
    end;
    iCode := StrToInt(trim( aParser[0] ));

    case iCode of
      0 :
        begin
          stResult.Caption  := Format('???? ???? , %s ???? ????????', [ aParser[1] ]) ;
          stID  := trim( aParser[2] );

          gEnv.ConConfig.Save0LeeID  := edt0LeeID.Text;
          gEnv.ConConfig.Save0LeePW  := edt0LeePW.Text;

          if cbMock.Checked then
          begin
            if stID = gEnv.ConConfig.SaveID[1] then
            begin
              edtID.Text  := gEnv.ConConfig.SaveID[1];
              edtPW.Text    := gEnv.ConConfig.SavePW[1];
              edtCert.Text  := gEnv.ConConfig.SaveCert[1];
            end
            else edtID.text  := stID;
          end
          else begin
            if stID = gEnv.ConConfig.SaveID[0] then
            begin
              edtID.Text  := gEnv.ConConfig.SaveID[0];
              edtPW.Text  := gEnv.ConConfig.SavePW[0];
              edtCert.Text  := gEnv.ConConfig.SaveCert[0];
            end else edtID.text  := stID;
          end;

          btnCon.Enabled := true;
          btnExit.Enabled:= true;

        end;

      1 : stResult.Caption  := '?????? ???? ????';
      2 : stResult.Caption  := '?????? ????';
      3 : stResult.Caption  := '???????? ????';
      4 : stResult.Caption  := Format('???????? ????, % ???? ????????', [ aParser[1] ]) ;
      5 : stResult.Caption  := '???? ????';
    end;

  finally
    Button1.Enabled := true;
    aParser.Free;
    strs.Free;
  end;


end;

procedure TFrmLogin.Button2Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFrmLogin.cbMockClick(Sender: TObject);
begin
  if cbSaveInput.Checked then
    if cbMock.Checked then
    begin
      edtID.Text  := gEnv.ConConfig.SaveID[1];
      edtPW.Text  := gEnv.ConConfig.SavePW[1];
      edtCert.Text  := gEnv.ConConfig.SaveCert[1];
    end
    else begin
      edtID.Text  := gEnv.ConConfig.SaveID[0];
      edtPW.Text  := gEnv.ConConfig.SavePW[0];
      edtCert.Text  := gEnv.ConConfig.SaveCert[0];
    end;
end;



procedure TFrmLogin.edtIDKeyPress(Sender: TObject; var Key: Char);
var
  iLen : integer;
begin
  iLen  := Length( (Sender as TLabeledEdit ).Text );
  if (iLen > 7 ) and ( key <> #8 )  then
    Key := #0;

end;

procedure TFrmLogin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

procedure TFrmLogin.FormCreate(Sender: TObject);
begin
    initControls;
end;

procedure TFrmLogin.initControls;
begin

  if gEnv.YoungLee then
  begin

    gb0Lee.Visible := true;
    stResult.Visible := true;
    Height  := gb0Lee.Height +
    stResult.Height + gbLogin.Height  ;
    //
    cbMock.Visible  := false;
  end
  else begin

    gb0Lee.Visible := false;
    gbLogin.Left    := 1;
    gbLogin.Top     := 4;
    stResult.Visible := false;
    Height  :=  gbLogin.Height;

    if gEnv.Beta then
      cbMock.Visible  := true;

  end;

  InitLogin;
end;

procedure TFrmLogin.InitLogin;
begin

  cbSaveInput.Checked := gEnv.ConConfig.SaveInput;

  if (gEnv.YoungLee) or ( gEnv.Beta ) then
    cbMock.Checked  := false
  else                             
    cbMock.Checked  := not gEnv.ConConfig.RealMode;

  if gEnv.YoungLee then
  begin

    if cbSaveInput.Checked then
    begin
      edt0LeeID.Text  := gEnv.ConConfig.Save0LeeID;
      edt0LeePW.Text  := gEnv.ConConfig.Save0LeePW;
    end;

  end
  else begin

    if cbSaveInput.Checked then
      if cbMock.Checked then
      begin
        edtID.Text  := gEnv.ConConfig.SaveID[1];
        edtPW.Text  := gEnv.ConConfig.SavePW[1];
        edtCert.Text  := gEnv.ConConfig.SaveCert[1];
      end
      else begin
        edtID.Text  := gEnv.ConConfig.SaveID[0];
        edtPW.Text  := gEnv.ConConfig.SavePW[0];
        edtCert.Text  := gEnv.ConConfig.SaveCert[0];
      end;
  end;

  if AutoLogin then
  begin

    // ???????????? ??????...???????? ?????? ?????? ????????.
    cbSaveInput.Checked := gEnv.ConConfig.tUseSave;
    // ???? ?? ???????? ?? false

    if (gEnv.YoungLee) or ( gEnv.Beta ) then
      cbMock.Checked  := false
    else
      cbMock.Checked  := gEnv.ConConfig.tUseMock;

    edt0LeeID.Text  := gEnv.ConConfig.t0LeeID;
    edt0LeePW.Text  := gEnv.ConConfig.t0LeePW;

    edtID.Text    := gEnv.ConConfig.tUserID;
    edtPW.Text    := gEnv.ConConfig.tPassword;
    edtCert.Text  := gEnv.ConConfig.tCertPass;
  end;
  
end;

procedure TFrmLogin.FormDestroy(Sender: TObject);
begin
  gLogIn  := nil;
end;

end.
