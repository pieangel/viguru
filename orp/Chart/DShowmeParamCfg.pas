unit DShowmeParamCfg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, StdCtrls, ChartCentral, Shows;

type
  TShowMeParamCfg = class(TForm)
    ButtonOK: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    edtPos: TEdit;
    Label3: TLabel;
    Label2: TLabel;
    Label1: TLabel;
    AskColor: TShape;
    BidColor: TShape;
    SpeedButton1: TSpeedButton;
    ButtonColor: TSpeedButton;
    Label4: TLabel;
    edtParam: TEdit;
    SpeedButton2: TSpeedButton;
    ColorDialog: TColorDialog;
    procedure ButtonColorClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
    FShowMeItem : TShowMeItem;
  public
    { Public declarations }

    function Open( aItem : TShowMeItem ) : boolean;
    property ShowMeItem : TShowMeItem read FShowMeItem write FShowMeItem;
  end;

var
  ShowMeParamCfg: TShowMeParamCfg;

implementation

uses DParamCfg;

{$R *.dfm}

procedure TShowMeParamCfg.ButtonColorClick(Sender: TObject);
begin
  if ColorDialog.Execute then
  begin
    AskColor.Brush.Color := ColorDialog.Color;
  end;
end;

procedure TShowMeParamCfg.ButtonOKClick(Sender: TObject);
begin
  if FShowMeItem = nil then Exit;

  FShowMeItem.AskColor  := AskColor.Brush.Color;
  FShowMeItem.BidColor  := BidColor.Brush.Color;
  FShowMeItem.OffSet    := StrToIntDef(edtPos.Text, 1);
  FShowMeItem.Param     := edtParam.Text;

  ModalResult := mrOK;
end;

function TShowMeParamCfg.Open(aItem: TShowMeItem): boolean;
begin
  Result := false;
  if aItem = nil then Exit;
  FShowMeItem := aItem;

  AskColor.Brush.Color  := aItem.AskColor;
  BidColor.Brush.Color  := aItem.BidColor;
  edtPos.Text := IntToStr( aItem.OffSet );
  edtParam.Text := aItem.Param;

  Result := ShowModal = mrOK;
end;

procedure TShowMeParamCfg.SpeedButton1Click(Sender: TObject);
begin
  if ColorDialog.Execute then
  begin
    BidColor.Brush.Color := ColorDialog.Color;
  end;
end;

procedure TShowMeParamCfg.SpeedButton2Click(Sender: TObject);
begin
  ShowMeQuery( self, 'ShowMe', '∞Ë¡¬√º∞·', FShowMeItem.Param );
  edtParam.Text := FShowMeItem.Param;
end;

end.
