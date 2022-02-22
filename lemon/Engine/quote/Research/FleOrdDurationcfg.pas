unit FleOrdDurationcfg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  FleOrderDuration;

type
  TFrmOrdDuarCfg = class(TForm)
    btnClose: TButton;
    btnApply: TButton;
    dlgColor: TColorDialog;
    dlgOpen: TOpenDialog;
    GroupBox1: TGroupBox;
    cbFut: TCheckBox;
    cbCall: TCheckBox;
    cbPut: TCheckBox;
    edtPut: TEdit;
    edtCall: TEdit;
    edtFut: TEdit;
    btnFut: TButton;
    btnCall: TButton;
    btnPut: TButton;
    spPut: TButton;
    spCall: TButton;
    spFut: TButton;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    plPut: TPanel;
    plCall: TPanel;
    plFut: TPanel;
    btnFColor: TButton;
    btnCColor: TButton;
    btnPColor: TButton;
    GroupBox3: TGroupBox;
    btnIColor: TButton;
    plIssue: TPanel;
    edtIssue: TEdit;
    cbIssue: TCheckBox;
    btnIssue: TButton;
    spIssue: TButton;
    cbCode: TComboBox;
    GroupBox4: TGroupBox;
    edtOneS: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtOneE: TEdit;
    Label4: TLabel;
    edtTwoS: TEdit;
    Label8: TLabel;
    edtTwoE: TEdit;
    Label9: TLabel;
    edtThreeS: TEdit;
    Label10: TLabel;
    edtThreeE: TEdit;
    procedure btnApplyClick(Sender: TObject);
    procedure btnFutClick(Sender: TObject);
    procedure spFutClick(Sender: TObject);
    procedure btnFColorClick(Sender: TObject);
    procedure cbFutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbCodeChange(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure edtOneSKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    FDuraConfig : TDuraConfig;
  public
    { Public declarations }
    procedure SetDuraConfig( aConfig : TDuraConfig );
  end;

var
  FrmOrdDuarCfg: TFrmOrdDuarCfg;

implementation

uses
  GleLib, CleSymbols;

{$R *.dfm}

procedure TFrmOrdDuarCfg.btnApplyClick(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  if FDuraConfig = nil then exit;
  
  with FDuraConfig do
  begin
    FColor[0] := plfut.Color;
    FColor[1] := plCall.Color;
    FColor[2] := plPut.Color;

    FSoundDir[0] := edtfut.Text;
    FSoundDir[1] := edtCall.Text;
    FSoundDir[2] := edtPut.Text;

    FSoundCheck[0] := cbfut.Checked;
    FSoundCheck[1] := cbCall.Checked;
    FSoundCheck[2] := cbPut.Checked;

    FOneGrade[0] := edtOneS.Text;
    FOneGrade[1] := edtOneE.Text;
    FTwoGrade[0] := edtTwoS.Text;
    FTwoGrade[1] := edtTwoE.Text;
    FThreeGrade[0] := edtThreeS.Text;
    FThreeGrade[1] := edtThreeE.Text;

    if cbCode.ItemIndex = -1 then exit;
    aSymbol := cbCode.Items.Objects[cbCode.ItemIndex] as TSymbol;
    if aSymbol = nil then exit;

    aSymbol.OrdDurationDatas.SoundDir := edtIssue.Text;
    aSymbol.OrdDurationDatas.SoundCheck := cbIssue.Checked;
    aSymbol.OrdDurationDatas.DuraColor := plIssue.Color;
  end;

end;

procedure TFrmOrdDuarCfg.btnCloseClick(Sender: TObject);
begin
  close;
end;

procedure TFrmOrdDuarCfg.btnFColorClick(Sender: TObject);
var
  iTag : integer;
begin
  iTag  := TButton( Sender ).Tag;
  if dlgColor.Execute then
  begin
    case iTag of
    0  : plFut.Color  := dlgColor.Color;
    10 : plCall.Color := dlgColor.Color;
    20 : plPut.Color := dlgColor.Color;
    30 : plIssue.Color := dlgColor.Color;
    end
  end;
end;

procedure TFrmOrdDuarCfg.btnFutClick(Sender: TObject);
var
  i, iTag : Integer;
  stname : string;
begin
  iTag := TButton( Sender ).Tag;
  if( dlgOpen.Execute ) then
    with dlgOpen.Files do begin
      for i := 0 to Count - 1 do
      begin
        stname := Strings[i];
      end;
    end;

  if iTag = 0 then
    edtFut.Text := stname
  else if iTag = 1 then
    edtCall.Text := stname
  else if iTag = 2 then
    edtPut.Text := stname
  else if iTag = 3 then
    edtIssue.Text := stname
end;

procedure TFrmOrdDuarCfg.cbCodeChange(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  if FDuraConfig = nil then exit;
  if cbCode.ItemIndex = -1 then Exit;

  aSymbol := cbCode.Items.Objects[cbCode.ItemIndex] as TSymbol;

  if aSymbol = nil then exit;

  edtIssue.Text := aSymbol.OrdDurationDatas.SoundDir;
  cbIssue.Checked := aSymbol.OrdDurationDatas.SoundCheck;
  plIssue.Color := aSymbol.OrdDurationDatas.DuraColor;
end;

procedure TFrmOrdDuarCfg.cbFutClick(Sender: TObject);
var
  bUse : boolean;
  iTag : integer;
begin
  iTag := TCheckBox( Sender ).Tag;
  bUse := TCheckBox( Sender ).Checked;

  case iTag of
    0 :
      begin
        edtFut.Enabled  := bUse;
        btnFut.Enabled  := bUse;
        spFut.Enabled   := bUse;
      end;
    1 :
      begin
        edtCall.Enabled := bUse;
        btnCall.Enabled := bUse;
        spCall.Enabled  := bUse;
      end;
    2 :
      begin
        edtPut.Enabled  := bUse;
        btnPut.Enabled  := bUse;
        spPut.Enabled   := bUse;
      end;
    3 :
      begin
        edtIssue.Enabled  := bUse;
        btnIssue.Enabled  := bUse;
        spIssue.Enabled   := bUse;
      end;
  end;
end;

procedure TFrmOrdDuarCfg.edtOneSKeyPress(Sender: TObject; var Key: Char);
begin
 if not (Key in ['0'..'9','.', #13, #8]) then
     Key := #0;
end;

procedure TFrmOrdDuarCfg.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmOrdDuarCfg.FormCreate(Sender: TObject);
begin
  FDuraConfig := nil;
end;

procedure TFrmOrdDuarCfg.FormDestroy(Sender: TObject);
begin
  FDuraConfig := nil;
end;

procedure TFrmOrdDuarCfg.SetDuraConfig(aConfig: TDuraConfig);
var
  i : integer;
  aSymbol : TSymbol;
begin
  FDuraConfig := aConfig;
  with aConfig do
  begin
    plfut.Color := FColor[0];
    plCall.Color := FColor[1];
    plPut.Color := FColor[2];

    edtfut.Text := FSoundDir[0];
    edtCall.Text := FSoundDir[1];
    edtPut.Text := FSoundDir[2];

    cbfut.Checked := FSoundCheck[0];
    cbCall.Checked := FSoundCheck[1];
    cbPut.Checked := FSoundCheck[2];

    edtOneS.Text := FOneGrade[0];
    edtOneE.Text := FOneGrade[1];
    edtTwoS.Text := FTwoGrade[0];
    edtTwoE.Text := FTwoGrade[1];
    edtThreeS.Text := FThreeGrade[0];
    edtThreeE.Text := FThreeGrade[1];

    for i := 0 to FSymbolList.Count - 1 do
    begin
      aSymbol := FSymbolList.Items[i];
      if aSymbol = nil then continue;
      cbCode.AddItem(aSymbol.Code, aSymbol);

      if i = 0 then
      begin
        edtIssue.Text := aSymbol.OrdDurationDatas.SoundDir;
        cbIssue.Checked := aSymbol.OrdDurationDatas.SoundCheck;
        plIssue.Color := aSymbol.OrdDurationDatas.DuraColor;
      end;
    end;
    cbCode.ItemIndex := 0;
  end;
end;

procedure TFrmOrdDuarCfg.spFutClick(Sender: TObject);
var
  iTag : integer;
begin
  iTag  := TButton( Sender ).Tag;

  case iTag of
    0 : FillSoundPlay( edtFut.Text );
    1 : FillSoundPlay( edtCall.Text );
    2 : FillSoundPlay( edtPut.Text );
    3 : FillSoundPlay( edtIssue.Text );
  end;
end;

end.
