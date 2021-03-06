unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, OleCtrls, ESApiExpLib_TLB;

type
  TForm1 = class(TForm)
    EsApi: TESApiExp;
    Memo: TMemo;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure EsApiESExpAcctList(ASender: TObject; nListCount: Smallint;
      const szAcctData: WideString);
    procedure EsApiESExpCodeList(ASender: TObject; nListCount: Smallint;
      const szCodeData: WideString);
    procedure EsApiESExpRecvData(ASender: TObject; nTrCode: Smallint;
      const szRecvData: WideString);
    procedure EsApiESExpServerConnect(Sender: TObject);
    procedure EsApiESExpServerDisConnect(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  iRes : ShortInt;
  szUserID, szPasswd, szCertPasswd: WideString;
begin

  if not EsApi.ESExpIsServerConnect then
  begin
    EsApi.ESExpApiFilePath('C:\KrApi\_EsBin');
    szUserID  := 'jslight7';
    szPasswd  := 'khc6931';
    szCertPasswd  := 'a';

    iRes := EsApi.ESExpConnectServer(szUserID, szPasswd, szCertPasswd, 2);
    memo.Lines.Add( IntToStr( iRes ) );
  end;

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  iRes : ShortInt;
begin
  if (EsApi.ESExpIsServerConnect) then
    EsApi.ESExpDisConnectServer;
end;

procedure TForm1.EsApiESExpAcctList(ASender: TObject; nListCount: Smallint;
  const szAcctData: WideString);
begin
  memo.Lines.Add(
    Format('AcctList:%d, %s', [ nListCount, szAcctData ])
    )
end;

procedure TForm1.EsApiESExpCodeList(ASender: TObject; nListCount: Smallint;
  const szCodeData: WideString);
begin
  memo.Lines.Add(
    Format('CodeList:%d, %s', [ nListCount, szCodeData ])
    )
end;

procedure TForm1.EsApiESExpRecvData(ASender: TObject; nTrCode: Smallint;
  const szRecvData: WideString);
begin
  memo.Lines.Add(
    Format('RecvData:%d, %s', [ nTrCode, szRecvData ])
    )
end;

procedure TForm1.EsApiESExpServerConnect(Sender: TObject);
begin
  memo.Lines.Add('????');
end;

procedure TForm1.EsApiESExpServerDisConnect(Sender: TObject);
begin
  memo.Lines.Add('????????');
end;

end.
