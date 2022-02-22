unit ClePrinterTypes;

interface

type
  TPrinterConfig = record
    FitInPage : Boolean;

    TitleMargin : Double;

    LeftMargin : Double; // in cm
    TopMargin : Double;
    RightMargin : Double;
    BottomMargin : Double;
    UseColor : Boolean;
  end;

implementation

end.
