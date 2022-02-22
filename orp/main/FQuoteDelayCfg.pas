unit FQuoteDelayCfg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TFrmQuoteDelayCfg = class(TForm)
    cbUse: TCheckBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    edtTimer: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    edtMaxSec: TEdit;
    Label4: TLabel;
    plFut: TPanel;
    Button1: TButton;
    plCall: TPanel;
    Button2: TButton;
    plPut: TPanel;
    Button3: TButton;
    dlgColor: TColorDialog;
    Button4: TButton;
    Button5: TButton;
    edtMinSec: TEdit;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    dlgOpen: TOpenDialog;
    GroupBox2: TGroupBox;
    edtFut: TEdit;
    btnFut: TButton;
    spFut: TButton;
    spCall: TButton;
    spPut: TButton;
    btnCall: TButton;
    btnPut: TButton;
    edtPut: TEdit;
    edtCall: TEdit;
    Label11: TLabel;
    edtShift: TEdit;
    Label12: TLabel;
    cbFut: TCheckBox;
    cbCall: TCheckBox;
    cbPut: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure cbUseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure btnFutClick(Sender: TObject);
    procedure spFutClick(Sender: TObject);
    procedure cbPutClick(Sender: TObject);
  private
    procedure UpdateQuoteDelay;
    procedure initControls;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmQuoteDelayCfg: TFrmQuoteDelayCfg;

implementation

uses
  GleLib, GAppEnv, FOrpMain;

{$R *.dfm}

procedure TFrmQuoteDelayCfg.btnFutClick(Sender: TObject);
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
    edtPut.Text := stname;

end;

procedure TFrmQuoteDelayCfg.Button1Click(Sender: TObject);
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
    end
  end;
end;

procedure TFrmQuoteDelayCfg.Button4Click(Sender: TObject);
begin
  UpdateQuoteDelay;
  close;
end;

procedure TFrmQuoteDelayCfg.Button5Click(Sender: TObject);
begin
  UpdateQuoteDelay;
end;

procedure TFrmQuoteDelayCfg.cbPutClick(Sender: TObject);
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
  end;
end;

procedure TFrmQuoteDelayCfg.cbUseClick(Sender: TObject);
begin
  //GroupBox1.Visible := cbUse.Checked;
end;

procedure TFrmQuoteDelayCfg.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmQuoteDelayCfg.FormCreate(Sender: TObject);
begin
  //
  initControls;
end;

procedure TFrmQuoteDelayCfg.initControls;
begin
  With gEnv do
  begin
    edtTimer.Text := IntToStr( QuoteSpeed.Interval );
    edtMaxSec.Text  := FloatTostr( QuoteSpeed.MaxSec );
    edtMinSec.Text  := FloatTostr( QuoteSpeed.MinSec );

    plFut.Color := TColor( QuoteSpeed.FutColor );
    plCall.Color  := TColor( QuoteSpeed.CalColor );
    plPut.Color := TColor( QuoteSpeed.PutColor );

    cbUse.Checked := QuoteSpeed.Display;

    cbFut.Checked := QuoteSpeed.FutUseSound;
    cbCall.Checked := QuoteSpeed.CallUseSound;
    cbPut.Checked := QuoteSpeed.PutUseSound;

    edtFut.Text   := QuoteSpeed.FutSound;
    edtCall.Text  := QuoteSpeed.CallSound;
    edtPut.Text   := QuoteSpeed.PutSound;

    edtShift.Text := FloatToStr( QuoteSpeed.ShiftVal );
    if not cbFut.Checked then
      cbPutClick(cbFut);
    if not cbCall.Checked then
      cbPutClick(cbCall);
    if not cbPut.Checked then
      cbPutClick(cbPut);
  end;
end;

procedure TFrmQuoteDelayCfg.spFutClick(Sender: TObject);
var
  iTag : integer;
begin
  iTag  := TButton( Sender ).Tag;

  case iTag of
    0 : FillSoundPlay( edtFut.Text );
    1 : FillSoundPlay( edtCall.Text );
    2 : FillSoundPlay( edtPut.Text );
  end;

end;

procedure TFrmQuoteDelayCfg.FormDestroy(Sender: TObject);
begin
  //
end;

procedure TFrmQuoteDelayCfg.UpdateQuoteDelay;
begin
  //
  With gEnv do
  begin
    QuoteSpeed.Interval := StrToIntDef( edtTimer.Text, 300);
    QuoteSpeed.MaxSec := StrToFloatDef( edtMaxSec.Text, 3);
    QuoteSpeed.MinSec := StrToFloatDef( edtMinSec.Text, 0.5);

    QuoteSpeed.FutColor := integer( plFut.Color );
    QuoteSpeed.CalColor := integer( plCall.Color );
    QuoteSpeed.PutColor := integer( plPut.Color );

    QuoteSpeed.Display  := cbUse.Checked;

    QuoteSpeed.FutUseSound  := cbFut.Checked;
    QuoteSpeed.CallUseSound  := cbCall.Checked;
    QuoteSpeed.PutUseSound  := cbPut.Checked;

    QuoteSpeed.FutSound := edtFut.Text;
    QuoteSpeed.CallSound:= edtCall.Text;
    QuoteSpeed.PutSound := edtPut.Text;

    QuoteSpeed.ShiftVal := StrToFloatDef( edtShift.Text, 0 );
  end;

  OrpMainForm.UpdateQuoteDelay;

end;


end.
