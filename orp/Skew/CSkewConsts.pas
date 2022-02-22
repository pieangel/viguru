unit CSkewConsts;

interface

uses
  Graphics;

const
  IDX_CALL = 0;
  IDX_PUT = 1;

  IDX_ASK = 0;
  IDX_BID = 1;
  IDX_FILL = 2;
  
  SKEW_EPSILON = 1.0e-8;
  MAX_IV = 0.6;

    // Skew Points X-Y range
  MIN_SKEW_RANGE = 0.9;
  MAX_SKEW_RANGE = 1.2;
  MIN_VOL_RANGE = 0.1;
  MAX_VOL_RANGE = 0.6;
    // Skew Point Interval
  SKEW_INTERVALS = 30;

  SKEW_COLORS: array[0..5] of TColor =
                    (clMaroon, clPurple, clRed, clSkyBlue, clTeal, clBlue);

(* GlobalVa.java:
	public final static double[] CallRangeForTrd = {0.95,1.1};
	public final static double[] PutRangeForTrd = {0.9,1.05};
	public static ArrayList<TradingDate> alExpDates = new ArrayList<TradingDate>();
	public static int remainedTrdDays = 7;
*)

implementation

end.
