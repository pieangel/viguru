// ���� Ÿ�̸�
unit FQryTimer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TFrmQryTimer = class(TForm)
    pBar: TProgressBar;
    Label1: TLabel;
    lbtot: TLabel;
    Timer1: TTimer;
    lbNow: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    stTitle : string;
  public
    { Public declarations }
    procedure SetTitle(aTitle: string);
    function Open( iMode : integer = 0 ): Boolean;
    function Open2( stTitle: string; iMode : integer = 0 ): Boolean;
  end;

var
  FrmQryTimer: TFrmQryTimer;

implementation

uses
  GAppEnv, math
  ;

{$R *.dfm}

procedure TFrmQryTimer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmQryTimer.FormCreate(Sender: TObject);
begin
  stTitle := '���� ���簡 ��û ��...';
end;

procedure TFrmQryTimer.FormDestroy(Sender: TObject);
begin
  //
end;

procedure TFrmQryTimer.SetTitle(aTitle: string);
begin
  stTitle := aTitle;
  Label1.Caption  := stTitle;
end;

function TFrmQryTimer.Open( iMode : integer ): Boolean;
begin

  if iMode = 1 then
  begin
    Label1.Caption  := stTitle; //'���� ���簡 ��û ��...';
  end;

  pBar.Position := 0;
  pBar.Max      := gEnv.Engine.Api.ViReqList.Count;
  lbTot.Caption := inttostr( pBar.Max );
  Timer1.Enabled := true;
  Result := (ShowModal = mrOK);
end;

function TFrmQryTimer.Open2( stTitle: string; iMode : integer ): Boolean;
begin

  if iMode = 1 then
  begin
    Label1.Caption  := stTitle; //'���� ���簡 ��û ��...';
  end;

  pBar.Position := 0;
  pBar.Max      := gEnv.Engine.Api.ViReqList.Count;
  lbTot.Caption := inttostr( pBar.Max );
  Timer1.Enabled := true;
  Result := (ShowModal = mrOK);
end;

// ������� Ÿ�̸� ��ƾ�� ������ ������ ���� ��ȭ�� �ݿ��Ͽ� ���α׷����ٸ� �����Ų��.
procedure TFrmQryTimer.Timer1Timer(Sender: TObject);
begin
  //
  if pBar.Max = 0 then begin
    Timer1.Enabled := false;
    ModalResult := mrCancel   ;
  end;

  pBar.Position := Max( 0, pBar.Max - gEnv.Engine.Api.ViReqList.Count );
  lbNow.Caption := IntToStr( pBar.Position );
  if gEnv.Engine.Api.ViReqList.Count = 0 then begin
    Timer1.Enabled := false;
    ModalResult := mrOK   ;
  end;

end;

end.