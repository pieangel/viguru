unit FSimulationMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IniFiles,

  CleSimulationConst, StdCtrls
  ;

type
  TSimulationMain = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure initControls;
    procedure initConfig;
    { Private declarations }
  public
    { Public declarations }
    procedure OnBtnClick( Sender : TObject );
  end;

var
  SimulationMain: TSimulationMain;

implementation

uses
  GAppEnv, GAppForms, GleTypes;



{$R *.dfm}

procedure TSimulationMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TSimulationMain.FormCreate(Sender: TObject);
begin
  initControls;

  // simulation 환경 설정
  gSimulEnv.QuoteOp.Back := false;
end;

procedure TSimulationMain.initConfig;
var
  ini : TIniFile;
  stDir : string;
  i, iCount : integer;
begin

  stDir := ExtractFilePath( paramstr(0) )+'Simulation\';

  try
    ini := TIniFile.Create( stDir + SimulIni );

    iCount := ini.ReadInteger('Simulation', 'Count', 0 );

    if iCount > 0 then
      SetLength( gSimulEnv.SimulWins, iCount );

    gSimulEnv.TotCount  := iCount;

    gLog.Add(lkDebug, 'TSimulationMain', 'initConfig', 'TotCount : ' + IntToStr( iCount ) );

    with gSimulEnv do
      for i := 0 to iCount - 1 do
      begin
        stDir := 'Simul'+IntToStr(i+1);
        SimulWins[i].Name := ini.ReadString('Simulation', stDir, '');
        SimulWins[i].Index:= i;
        SimulWins[i].InitFile := SimulWins[i].Name + '.ini';

        gLog.Add(lkDebug, 'TSimulationMain', 'initConfig', 'TotCount : ' + IntToStr( iCount ) );
      end;
  finally
    ini.Free;
  end;

end;

procedure TSimulationMain.initControls;
var
  iLeft, iTop, i, j, iCol : integer;
  pBtn  : TButton;
begin
  initConfig;

  iTop := 8;  iLeft := 8; iCol := 1;  j := 0;

  with gSimulEnv do
    for i := 0 to TotCount - 1 do
    begin    

      if i >= (BtnCount * iCol )then
      begin
        iLeft := (BtnWidth * iCol ) + 20;
        inc( iCol );
        iTop  := 8;
        j := 0;
      end;

      pBtn  := TButton.Create( self );
      pBtn.Parent := Self;
      pBtn.Caption  := SimulWins[i].Name;
      pBtn.Tag      := SimulWins[i].Index;
      pBtn.Width    := BtnWidth;
      pBtn.Height   := BtnHeight;
      pBtn.Top      := iTop + ( j * (BtnHeight + 8) );
      pBtn.Left     := iLeft;

      pBtn.OnClick  := OnBtnClick;

      inc( j );
    end;

end;

procedure TSimulationMain.OnBtnClick(Sender: TObject);
var
  iTag : integer;
  aFC : TFormClass;
  aF  : TForm;

begin

  iTag  := TButton( Sender ).Tag;

  aFC := TFormClass( GetClass( 'T'+gSimulEnv.SimulWins[iTag].Name ));

  try
    if aFC <> nil then
    begin
      aF := aFC.Create( self );
      aF.Show;
    end;
  except
  end;

end;

end.
