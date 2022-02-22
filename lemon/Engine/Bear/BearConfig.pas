unit BearConfig ;

interface

uses
  CleAccounts, CleSymbols;

type

  // ��ü
  TBearSystemConfig = record
    // -- ����, ����
    Account : TAccount ;        // ����
    CohesionSymbol : TSymbol ;  // ��������
    OrderSymbol : TSymbol ;     // �ֹ�����

    // -- �ֹ� ����
    OrderCollectionPeriod : Double ;  // �����ð�
    OrderQuoteLevel : Integer ;       // ȣ������
    OrderFilter : Integer ;           //  ��������
    
    OrderQuoteTimeUsed : Boolean ;  // �ֹ� �������ϴ� ���
    OrderQuoteTime : Double ;       // �ֹ� ȣ�� ���ð�

    QuoteJamSkipUsed : Boolean ;    // ������ �ڵ� Skip ��뿩��
    QuoteJamSkipTime : Double ;     // �ڵ� Skip�Ǵ� ������ �ð�

    // -- ���� ����
    SaveOrdered : Boolean ;     // ���� ���� ��õ ������ ����
    SaveCohesioned : Boolean ; // ���� ���� ���� ������ ����
    SaveCollectioned : Boolean ; // �ֹ� ���� ������ ����
  end;

  // ����â ���� �Ѱ��� 
  TBearConfig = record

    // -- �ֹ� ���� 
    LongOrdered : Boolean ;   // �ż��ֹ�?
    ShortOrdered : Boolean ;  // �ŵ��ֹ�?
    CancelOrdered : Boolean;  // �ڵ����?
    CancelTime : Double ;     // ��ҽð�
    OrderQty : Integer ;      // �ֹ�����
    MaxPosition : Integer ;   // �ֹ��ѵ� ( ������ )
    MaxQuoteQty : Integer ;   // �ִ�ȣ���ܷ� 

    // -- ���� ����
    CohesionFilter : Integer ;      // ��������
    CohesionPeriod : Double ;       // ���ӽð�
    CohesionTotQty : Integer ;      // �Ѽ���
    CohesionCnt : Integer ;         // �Ǽ�
    CohesionQuoteLevel : Integer ;  // ȣ�� ����
    CohesionAvgPrice  : Double ;    // ������ ( ��մܰ� )

  end;
  
implementation

end.
