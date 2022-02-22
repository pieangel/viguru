unit BullData;

interface

 
type
  TBullConfig = record
    EntryLong_Checked : Boolean;
    EntryShort_Checked : Boolean;
    EntryTimeCancel_Checked : Boolean;
    EntryCancelTime : Double;

    E1_Checked : Boolean;
      E1_P1 : Double;           // 적정가 시간변수
      E1_P2 : Double;           // 선물 이동평균 시간변수
      E1_P3 : Double;
      E1_P4 : Double;
      E1_P5 : Double;
      E1_P6 : Double;
    E2_Checked : Boolean;
      E2_P1 : Integer;
    X1_Checked : Boolean;
      X1_P1 : Double;
      X1_P2 : Double;
    X2_Checked : Boolean;
      X2_P1 : Double;
      X2_P2 : Double;
    X3_Checked : Boolean;

    NewOrderQty : Integer;
    MaxPosition : Integer;
    MaxQuoteQty : Integer;

    StartStop : integer;
    ClearButton : integer;
    CButton : integer;
  end;
  
implementation

end.
 