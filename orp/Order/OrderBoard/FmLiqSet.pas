unit FmLiqSet;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, UAlignedEdit, ComCtrls;

type
  TFrmLiqSet = class(TFrame)
    GroupBox3: TGroupBox;
    cbPrfLiquid: TCheckBox;
    cbLosLiquid: TCheckBox;
    udPrfTick: TUpDown;
    udLosTick: TUpDown;
    edtPrfTick: TAlignedEdit;
    edtLosTick: TAlignedEdit;
    GroupBox5: TGroupBox;
    rbMarket: TRadioButton;
    rbHoga: TRadioButton;
    udLiqTick: TUpDown;
    edtLiqTick: TAlignedEdit;
    Button5: TButton;
  private
    { Private declarations }
    FIsFund : boolean;
    procedure SetControls;
  public
    { Public declarations }
    procedure init( bFund : boolean = false );
  end;

implementation

uses
  GleConsts
  ;

{$R *.dfm}

{ TFrmLiqSet }

procedure TFrmLiqSet.init(bFund: boolean);
begin
  FIsFund := bFund;
  SetControls;
end;

procedure TFrmLiqSet.SetControls;
begin

  if FIsFund then
    Color  := FUND_FORM_COLOR
  else
    Color  := clBtnFace;
end;

end.
