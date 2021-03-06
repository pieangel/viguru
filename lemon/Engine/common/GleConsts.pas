unit GleConsts;

interface

{$INCLUDE 'define.txt'}

const
  //-- color constants
  NODATA_COLOR    = $FFDDDD;
  FIXED_COLOR     = $DDDDDD;
  HIGHLIGHT_COLOR = $80FFFF;
  HIGHLIGHT_FONT_COLOR = $000000;
  SELECTED_COLOR  = $00F2BEB9;
  SELECTED_FONT_COLOR = $000000;

  GRID_SELECT_COLOR = $F0F0F0;
  GRID_REVER_COLOR  = $00EEEEEE;
  FUND_FORM_COLOR   = $00D8E5EE;

  DISABLED_COLOR  = $BBBBBB;
  ERROR_COLOR     = $008080FF;
  ODD_COLOR       = $FFFFFF;
  EVEN_COLOR      = $EEEEEE;

  LONG_COLOR = $E4E2FC;
  SHORT_COLOR = $F5E2DA;

  SELECTED_COLOR2 = $00F2BEB9; // added by CHJ on 2003.6.26
  FUND_BOARD_COLOR  = $00D8E5EE;
    // time constant
  ONE_SECOND = 1.0 / 24.0 / 3600.0;
    // float constant
  PRICE_EPSILON = 0.001;
  EPSILON    = 0.00000001;
  DOUBLE_EPSILON : Double = 0.00000001;

    // country codes
  KOREA         = 0;
  UNITED_STATES = 1;
  CHINA         = 2;
  TAIWAN        = 3;
  JAPAN         = 4;
  
    // language codes
  SOUTH_KOREAN      = 0;
  AMERICAN_ENGLISH  = 1;
  MANDARIN_CHINESE  = 2;
  KANTONESE_CHINESE = 3;
  JAPANESE          = 4;

  LANGUAGE_CODES : array[0..4] of String = ('KR','EN','MCH','KCH','JP');

  OPTION_CSIZE    = 8;
  IFHEADERSIZE    = 40;   //증전 I/F HEADER (40byte)
  FEPHEADLENGTH   = 5;    // FEP 전문 헤더 길이
  HEADLENGTH      = 80;
  MSG_HEADERLEN   = 23;

  // LP 화면 색상 정의
  LP_DEFAULT = $C8D0D4;
  LP_LONG    = $99ccff;
  LP_SHORT   = $FFFFCC;
  LP_SQ      = $FFCC00;
  LP_OPEN    = $99FFFF;

    // data ID
  TRD_DATA = 100;
  QTE_DATA = 200;
  CHART_DATA = 210;
  FPOS_DATA = 300;   // fund _ pos
  ACNT_DATA = 400;
  FUND_DATA = 500;

    // order events
  ORDER_NEW           = 111;
  ORDER_ACCEPTED      = 101;
  ORDER_REJECTED      = 102;
  ORDER_CONFIRMED     = 103;
  ORDER_CONFIRMFAILED = 104;
  ORDER_CANCELED      = 105;
  ORDER_CHANGED       = 106;
  ORDER_FILLED        = 107;
    // fill events
  FILL_NEW            = 108;
    // position events
  POSITION_NEW        = 109;
  POSITION_UPDATE     = 110;
  POSITION_ABLEQTY    = 120;


    // api
  ACCOUNT_NEW        = 201;
  ACCOUNT_DELETED    = 202;
  ACCOUNT_UPDATED    = 203;
  ACCOUNT_DEPOSIT    = 204;
  ACCOUNT_PWD        = 205;

  // 펀드
  FUND_NEW         = 240;
  FUND_DELETED     = 241;
  FUND_UPDATED     = 242;   // 펀드 이름 변경
  FUND_ACNT_UPDATE    = 243;   // 펀드에 계좌 변경

  FPOSITION_NEW        = 230;
  FPOSITION_UPDATE     = 231;

  CHART_60 = 60;
  CHART_5 = 5;
  CHART_1 = 1;

  //-------------
  SEND_SOCK = 0;
  RECV_SOCK = 1;
  QURY_SOCK = 2;
  FILL_SOCK = 2;
  MAST_SOCK = 3;

  PACKET_HEADER_SIZE = 80;
  DATA_HEADER_SIZE = 70;

  TYPE_CON  = '91';
  TYPE_LINK = '92';
  TYPE_DATA = '01';


  HEADLENGTH2      = 72;

  MAX_REFCNT = 1;

{$IFDEF NH_FUT}
  INVEST_PERSON = '8000';
  INVEST_FINANCE = '1000';
  INVEST_GONG = '6000';
  INVEST_FORIN = '9000';
{$ELSE}
  INVEST_PERSON   = '09';
  INVEST_FINANCE  = '01';
  INVEST_GONG     = '07';
  INVEST_FORIN    = '10';
 {$ENDIF}

  MAX_FUT_QTY = 10;
  MAX_OPT_QTY = 50;

type
  TManageParam = record
    UseShift  : boolean;
    BidShift  : double;
    AskShift  : double;
    BidHoga   : integer;
    AskHoga   : integer;
  end;

var
    // variable-like constants
  LONG_TEXT_COLOR   : Integer;
  SHORT_TEXT_COLOR  : Integer;
  LONG_BG_COLOR     : Integer;
  SHORT_BG_COLOR    : Integer;

  PROFIT_COLOR : Integer;
  LOSS_COLOR   : Integer;

    // procedures
procedure SetUniversalConstants(iCountryCode : Integer);

implementation

procedure SetUniversalConstants(iCountryCode : Integer);
begin
  case iCountryCode of
    UNITED_STATES :
      begin
        LONG_TEXT_COLOR  := $FF0000;
        SHORT_TEXT_COLOR := $0000FF;
        LONG_BG_COLOR    := $E4E2FC;
        SHORT_BG_COLOR   := $F5E2DA;
        PROFIT_COLOR     := $FF0000;
        LOSS_COLOR       := $0000FF;
      end;
    KOREA :
      begin
        LONG_TEXT_COLOR  := $0000FF;
        SHORT_TEXT_COLOR := $FF0000;
        LONG_BG_COLOR    := $F5E2DA;
        SHORT_BG_COLOR   := $E4E2FC;
        PROFIT_COLOR     := $0000FF;
        LOSS_COLOR       := $FF0000;
      end;
    else
      begin
        LONG_TEXT_COLOR  := $0000FF;
        SHORT_TEXT_COLOR := $FF0000;
        LONG_BG_COLOR    := $F5E2DA;
        SHORT_BG_COLOR   := $E4E2FC;
        PROFIT_COLOR     := $0000FF;
        LOSS_COLOR       := $FF0000;
      end;
  end;
end;

initialization
  SetUniversalConstants(KOREA);

end.
