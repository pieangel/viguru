// 쿼리 타이머
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
  stTitle := '종목 현재가 요청 중...';
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
    Label1.Caption  := stTitle; //'종목 현재가 요청 중...';
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
    Label1.Caption  := stTitle; //'종목 현재가 요청 중...';
  end;

  pBar.Position := 0;
  pBar.Max      := gEnv.Engine.Api.QryList.Count;
  lbTot.Caption := inttostr( pBar.Max );
  Timer1.Enabled := true;
  Result := (ShowModal = mrOK);
end;

// 나름대로 타이머 루틴을 가지고 엔진의 값의 변화를 반영하여 프로그레스바를 진행시킨다.
procedure TFrmQryTimer.Timer1Timer(Sender: TObject);
begin
  //
  if pBar.Max = 0 then begin
    Timer1.Enabled := false;
    ModalResult := mrCancel   ;
  end;

  pBar.Position := Max( 0, pBar.Max - gEnv.Engine.Api.ViReqList.Count );
  lbNow.Caption := IntToStr( pBar.Position );
  if gEnv.Engine.Api.QryList.Count = 0 then begin
    Timer1.Enabled := false;
    ModalResult := mrOK   ;
  end;

end;

end.
