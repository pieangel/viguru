unit FLogIn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,

  GleTypes, IdHTTP, IdAntiFreezeBase, IdAntiFreeze, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdExplicitTLSClientServerBase,
  IdFTP, Registry,

  CleParsers
  ;
type

{$INCLUDE define.txt}

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
    function FindDRCM(stName: string): HWND;
    procedure GetDRCMInfo(var stRoot, stExe, stWinName: string); overload;
    procedure GetDRCMInfo; overload;
    function ShellExecuteDRCM(szWinName, szFileName, szUserName,
      szRoot: string): HWND;


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
  GleLib, GAppEnv  , Math    ,  ShellAPI,
  uCpuUsage
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

  edtID.Text  := 'eungjun';
  edtPW.Text  := 'june76';
  edtCert.Text  :=  'ylrms5759';

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
  iMode, iRes : integer;
begin

  if not gEnv.Engine.Api.Init( edtID.Text ) then
  begin
    ShowMessage('???? DRCM ???????? ????????????.');
    Application.Terminate;
    Exit;
  end;

  // ???????????? ??????  ?????????? 0
  iMode := 0;

  GetDRCMInfo;
  {
  gEnv.AnyHandle :=  FindDRCM( edtID.Text );
  if gEnv.AnyHandle <= 0 then
  begin
    ShowMessage('???? DRCM ?? ?????? ????????.');
    Application.Terminate;
    Exit;
  end;
  }

  if not gEnv.Engine.Api.DoLogIn( edtID.Text, edtPW.Text, edtCert.Text, iMode ) then
  begin
    gEnv.EnvLog( WIN_ERR, Format('?????? ???? %s %s', [ edtID.Text, edtPW.Text ]) );
    ShowMessage('??????????');
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

procedure TFrmLogin.GetDRCMInfo;
var
  Reg: TRegistry;
  stOpenKey, stToDay : string;

begin
  Reg := TRegistry.Create;
  with Reg do
  try
    stOpenKey := '\Software\Dongbu Securities\DongbuDRCM\PATH\';
    RootKey := HKEY_CURRENT_USER;
    if OpenKey( stOpenKey, True) then begin
      gEnv.ApiRootDir := ReadString('Root');
    end;
  finally
    Free;
  end;

end;


procedure TFrmLogin.GetDRCMInfo( var stRoot, stExe, stWinName : string );
var
  Reg: TRegistry;
  stOpenKey, stToDay : string;

begin
  Reg := TRegistry.Create;
  with Reg do
  try
    stRoot :=''; stExe := ''; stWinName := '';
    stOpenKey := '\Software\Dongbu Securities\DongbuDRCM\PATH\';
    RootKey := HKEY_CURRENT_USER;

    if OpenKey( stOpenKey, True) then begin

      stRoot    := ReadString('Root');
      stExe     := ReadString('Exe');
      stWinName := ReadString('WinName');

      gEnv.ApiRootDir := stRoot;

    end;
  finally
    Free;
  end;
end;

function TFrmLogin.ShellExecuteDRCM( szWinName, szFileName, szUserName, szRoot : string) : HWND;
var
  hDrcmHandle : HWND;
	hSyncEvent  : THandle;
  dwWait : DWORD;
begin

	hDrcmHandle := 0;
	hSyncEvent  := 0;

	ShellExecute(0, 'open', PChar(szFileName), PChar(szUserName), PChar(szRoot), SW_SHOWNORMAL);

	while (true) do
	begin
		WaitForSingleObject(hSyncEvent, INFINITE);
		dwWait := 0;
		repeat
			dwWait := WaitForSingleObject(hSyncEvent, 5000);
		until (dwWait = WAIT_OBJECT_0)  ;

		hDrcmHandle := FindWindow(nil, PChar(szWinName));
		if  hDrcmHandle > 0 then
			break;
	end;
	Result :=  hDrcmHandle ;
end;

function TFrmLogin.FindDRCM( stName : string ) : HWND;
var
  stRoot, stExe, stWinName, stTmpWinName, stMsg : string;
  hSyncEvent : THandle;
  hDrcmHandle: HWND;
  iRet : integer;
begin
  Result  := 0;
  GetDRCMInfo( stRoot, stExe, stWinName );

  gEnv.EnvLog( WIN_TEST, Format('???? DRCM : %s[%s,%s,%s]', [ stName, stRoot, stExe, stWinName]) );

  stTmpWinName  := Format('%s[%s]', [ stWinName, stName ]);

  stRoot := stRoot + '\Bin';
	hSyncEvent  := 0;
	hDrcmHandle := FindWindow( '', PChar( stTmpWinName) );

  if hDrcmHandle > 0 then
  begin

		stMsg := '????ID ???????? ???? API?? ?????????? ????????.' + #13+#10;
		stMsg := stMsg + '???? ???????? ????API ?????????? ?????????????????????' ;

		if ( MessageDlgLE( nil, stMsg, mtConfirmation, [mbOK, mbCancel]) = 1 ) then
    begin
			KillPrecess( stExe ) ;
			hDrcmHandle := ShellExecuteDRCM(stWinName, stExe, stName, stRoot);
    end else
    begin
			stMsg := '???? ?????? ???? ???????? ????API?? ??????????! ' ;
			ShowMessageLE (nil,  stMsg );
      Exit;
    end;
  end
  else
    hDrcmHandle := ShellExecuteDRCM(stWinName, stExe, stName, stRoot);

  if hDrcmHandle = INVALID_HANDLE_VALUE then
    ShowMessageLE (nil,  '???? API?? ???? ?? ????????' );

  Result :=  hDrcmHandle;
  
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
      cbMock.Visible  := false;

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
