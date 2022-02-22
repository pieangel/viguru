unit DStandByVolumes;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ComCtrls, ExtCtrls;

Const
  AUTO_CNT = 3;

type


  TAutoStopOrderParams = record
    ProfitCount : integer;
    ProfitTick  : array [0..AUTO_CNT-1] of integer;
    UseProfitOneTime : boolean;
    UseProfitFixQty  : boolean;
    ProfitDivQty , ProfitFixQty : integer;

    LossCutCount: integer;
    LossCutTick : array [0..AUTO_CNT-1] of integer;
    UseLossCutOneTime : boolean;
    UseLossCutFixQty  : boolean;
    LossCutDivQty , LossCutFixQty : integer;
  end;

  TStandByVolumes = class(TForm)
    ButtonOK: TButton;
    GroupBox1: TGroupBox;
    edtProfitCount: TLabeledEdit;
    udProfitCount: TUpDown;
    edtProfit1th: TEdit;
    edtProfit2th: TEdit;
    edtProfit3th: TLabeledEdit;
    GroupBox2: TGroupBox;
    rdProfitDiv: TRadioButton;
    edtProfitDivQty: TLabeledEdit;
    udProfitDivQty: TUpDown;
    rdProfitFix: TRadioButton;
    edtProfitFixQty: TEdit;
    udProfitFixQty: TUpDown;
    GroupBox3: TGroupBox;
    edtLossCutCount: TLabeledEdit;
    edtLossCut1th: TEdit;
    edtLossCut2th: TEdit;
    edtLossCut3th: TLabeledEdit;
    GroupBox4: TGroupBox;
    rdLossCutDiv: TRadioButton;
    edtLossCutDivQty: TLabeledEdit;
    udLossCutDivQty: TUpDown;
    rdLossCutFix: TRadioButton;
    edtLossCutFixQty: TEdit;
    udLossCutFixQty: TUpDown;
    udLossCutCount: TUpDown;
    Label1: TLabel;
    cbUseOneTimeProfit: TCheckBox;
    cbUseOneTimeLossCut: TCheckBox;
    procedure ButtonOKClick(Sender: TObject);

    procedure FormCreate(Sender: TObject);
    procedure edtProfitFixQtyKeyPress(Sender: TObject; var Key: Char);
  private
    procedure SaveQtyItem;
    function GetParams: TAutoStopOrderParams;
    procedure SetParams(const Value: TAutoStopOrderParams);
    { Private declarations }
  public
    { Public declarations }
    FillMode  : boolean;
    procedure SetMode( bFill : boolean );

     property Params: TAutoStopOrderParams read GetParams write SetParams;
  end;

var
  StandByVolumes: TStandByVolumes;

implementation

{$R *.dfm}

procedure TStandByVolumes.ButtonOKClick(Sender: TObject);
begin
  //SaveQtyItem;
  ModalResult := mrOK;
end;

procedure TStandByVolumes.edtProfitFixQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#13]) then
    Key := #0;
end;

procedure TStandByVolumes.FormCreate(Sender: TObject);
begin
  FillMode  := false;
end;



procedure TStandByVolumes.SaveQtyItem;
begin

end;


procedure TStandByVolumes.SetMode(bFill: boolean);
begin
  FillMode  := bFill;

end;

function TStandByVolumes.GetParams: TAutoStopOrderParams;
begin
  with Result do
  begin
    ProfitCount := udProfitCount.Position;

    ProfitTick[0] := StrToIntDef(edtProfit1th.Text, 0 );
    ProfitTick[1] := StrToIntDef(edtProfit2th.Text, 0 );
    ProfitTick[2] := StrToIntDef(edtProfit3th.Text, 0 );

    UseProfitOneTime  := cbUseOneTimeProfit.Checked ;
    UseProfitFixQty   := rdProfitFix.Checked ;

    ProfitDivQty      := udProfitDivQty.Position ;
    ProfitFixQty      := udProfitFixQty.Position ;

    LossCutCount      := udLossCutCount.Position ;

    LossCutTick[0]    := StrToIntDef( edtLossCut1th.Text , 0 );
    LossCutTick[1]    := StrToIntDef( edtLossCut2th.Text , 0 );
    LossCutTick[2]    := StrToIntDef( edtLossCut3th.Text , 0 );
    UseLossCutOneTime := cbUseOneTimeLossCut.Checked ;

    UseLossCutFixQty  := rdLossCutFix.Checked ;

    LossCutDivQty     := udLossCutDivQty.Position ;
    LossCutFixQty     := udLossCutFixQty.Position ;

  end;
end;

procedure TStandByVolumes.SetParams(const Value: TAutoStopOrderParams);
begin

  with Value do
  begin
    udProfitCount.Position  := ProfitCount;
    edtProfit1th.Text       := IntToStr( ProfitTick[0] );
    edtProfit2th.Text       := IntToStr( ProfitTick[1] );
    edtProfit3th.Text       := IntToStr( ProfitTick[2] );
    cbUseOneTimeProfit.Checked  := UseProfitOneTime;

    rdProfitFix.Checked := UseProfitFixQty;
    rdProfitDiv.Checked := not UseProfitFixQty;

    udProfitDivQty.Position     := ProfitDivQty;
    udProfitFixQty.Position   := ProfitFixQty;

    udLossCutCount.Position  := LossCutCount;
    edtLossCut1th.Text       := IntToStr( LossCutTick[0] );
    edtLossCut2th.Text       := IntToStr( LossCutTick[1] );
    edtLossCut3th.Text       := IntToStr( LossCutTick[2] );
    cbUseOneTimeLossCut.Checked  := UseLossCutOneTime;

    rdLossCutFix.Checked := UseLossCutFixQty;
    rdLossCutDiv.Checked := not UseLossCutFixQty;

    udLossCutDivQty.Position     := LossCutDivQty;
    udLossCutFixQty.Position   := LossCutFixQty;

  end;

end;

end.
