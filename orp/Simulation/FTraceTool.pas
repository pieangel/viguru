unit FTraceTool;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleSwitching, ExtCtrls, StdCtrls, Grids

  ;

type
  TFrmSwitch = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    sgResult: TStringGrid;
    Timer1: TTimer;
    Button1: TButton;
    Panel4: TPanel;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox13Click(Sender: TObject);
  private
    { Private declarations }
    FSwitching  : TSwitchgMngr;
    FCount      : integer;
    procedure initControls;
    procedure OnCheckBoxClick(Sender: TObject);
    procedure OnResultData;

  public
    { Public declarations }
    CheckNode   : array of TCheckBox;
    lbDesc      : array of TLabel;
  end;

var
  FrmSwitch: TFrmSwitch;

implementation

uses GAppEnv, FOrpMain;

{$R *.dfm}

procedure TFrmSwitch.Button1Click(Sender: TObject);
var
  iRow, i , j : integer;
  aNode : TSwitchgNode;
  aStep : TSwitchgItem;
begin

  Timer1.Enabled := false;

  iRow := 0;

  for i := 0 to FCount - 1 do
  begin
    aNode := FSwitching.QuoteNodes.Nodes(i);
    for j := 0 to aNode.SwitchgItems.Count -1 do
    begin
      aStep := aNode.SwitchgItems.Steps(j);
      aStep.DelayTime := 0;
      aStep.MaxTerm   := -1;
      aStep.MinTerm   := 200;
      inc( iRow );
    end;
  end;

  OnResultData;

  Timer1.Enabled := true;

end;

procedure TFrmSwitch.CheckBox13Click(Sender: TObject);
var
  iTag : integer;
  bCheck : boolean;
begin
  iTag  := TCheckBox( Sender).Tag;
  bCheck  := TCheckBox( Sender).Checked;

  case iTag of
    0 :
      begin
        if bCheck then
          gEnv.Engine.SyncFuture.FTimer.Enabled := true
        else
          gEnv.Engine.SyncFuture.FTimer.Enabled := false;
      end;
    1 :
      begin
        if bCheck then
          gEnv.Engine.GiManager.Start
        else
          gEnv.Engine.GiManager.Stop;
      end;
    2 :
      begin
        if bCheck then
          gEnv.Log.Resume
        else
          gEnv.Log.Suspend;
      end;
  end;

end;

procedure TFrmSwitch.CheckBox1Click(Sender: TObject);
var
  iTag : integer;
  bCheck : boolean;
begin
  iTag  := TCheckBox( Sender).Tag;
  bCheck  := TCheckBox( Sender).Checked;

  if bCheck then
    OrpMainForm.FQuoteReceiver.startudpThread( iTag )
  else
    OrpMainForm.FQuoteReceiver.stopudpThread( iTag );


end;

procedure TFrmSwitch.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  gEnv.Switch := nil;
  FSwitching.Free;
  CheckNode := nil;
  lbDesc    := nil;
  Action  := caFree;
end;

procedure TFrmSwitch.FormCreate(Sender: TObject);
begin
  FSwitching  := TSwitchgMngr.Create;
  gEnv.Switch := FSwitching;
  FCount  := FSwitching.QuoteNodeSetting;
  initControls;
end;

procedure TFrmSwitch.initControls;
var
  i : integer;
  iPos, iH, iMod, iW, iTop, iLeft : integer;
  stTxt : string;
  txt : array of string;
begin
  SetLength( CheckNode, FCount );
  SetLength( lbDesc, FCount );
  SetLength( txt, FCount );

  txt[0]  := 'UDP소켓 Read Event';
  txt[1]  := '소켓 버퍼 rev 하기 전';
  txt[2]  := '큐에서 pop 한후';
  txt[3]  := '시세 마켓별 분기하기전';
  txt[4]  := '마켓, 틱, 호가별 파싱';
  txt[5]  := '메모리 업뎃전';


  iH  := panel2.Height;
  iMod  := iH div FCount;

  for I := 0 to FCount - 1 do
  begin
    CheckNode[i] := TCheckBox.Create( self );
    lbDesc[i]    := TLabel.Create( self );
    CheckNode[i].Tag := i;
    CheckNode[i].Parent := Panel2;
    lbDesc[i].Parent    := panel2;
    CheckNode[i].OnClick  := OnCheckBoxClick;
    CheckNode[i].Width    := panel2.Width - 100;
    lbDesc[i].Width := CheckNode[i].Width;
    iTop  := panel2.Top  + ( i * iMod ) + 5;
    iLeft := panel2.Left;// + 10;
    CheckNode[i].Top  := iTop;
    CheckNode[i].Left := 5;

    lbDesc[i].Top   := iTop + CheckNode[i].Height + 2;
    lbDesc[i].Left  := 5;
    lbDesc[i].Caption := txt[i];
    stTxt  := FSwitching.QuoteNodes.Nodes(i).SwitchgItems.PrcName;
    iPos  := Pos( '.', stTxt );
    CheckNode[i].Caption := Copy( stTxt, iPos, Length( stTxt ));
  end;

  sgResult.ColWidths[0] := 250;

end;

procedure TFrmSwitch.OnCheckBoxClick( Sender : TObject );
var
  iTag  : integer;
  bCheck: boolean;
begin
  iTag  := TCheckBox( Sender ).Tag;
  bCheck:= not TCheckBox( Sender ).Checked;

  if iTag = 4 then
    FSwitching.QuoteNodes.TurnOnOff( iTag, 3, bCheck );
  FSwitching.QuoteNodes.TurnOnOff( iTag, 0, bCheck );
end;

procedure TFrmSwitch.Timer1Timer(Sender: TObject);
begin
  if FSwitching = nil then
    Exit;
  OnResultData;
end;

procedure TFrmSwitch.OnResultData;
var
  iRow, i , j : integer;
  aNode : TSwitchgNode;
  aStep : TSwitchgItem;
begin

  iRow := 0;

  with sgResult do
  begin

  for i := 0 to FCount - 1 do
  begin
    aNode := FSwitching.QuoteNodes.Nodes(i);

    Cells[ 0, iRow] := aNode.SwitchgItems.PrcName;

    for j := 0 to aNode.SwitchgItems.Count -1 do
    begin
      aStep := aNode.SwitchgItems.Steps(j);

      Cells[ 1, iRow ]  := IntToStr( aStep.MaxTerm );
      Cells[ 2, iRow ]  := IntToStr( aStep.MinTerm );
      Cells[ 3, iRow ]  := aStep.DataType;
      Cells[ 4, iRow ]  := aStep.PrcDesc;
      inc( iRow );

    end;
  end;

  end; // with

  sgResult.RowCount := iRow;

end;

end.
