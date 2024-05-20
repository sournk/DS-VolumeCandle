//+------------------------------------------------------------------+
//|                                         CVolumeCandlePattern.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
class CVolumeCandlePattern : public CObject {
public:
  string                  Sym;
  ENUM_TIMEFRAMES         Per;
  double                  O;
  double                  H;
  double                  C;
  double                  L;
  datetime                Time;
  
  double                  WickUp;
  double                  WickDown;
  double                  Body;
  double                  FullSize;
  
  ulong                   TicketBuy;
  ulong                   TicketSell;
  
  void                    CVolumeCandlePattern::Init(const string _sym, const ENUM_TIMEFRAMES _per, const int _shift);
  void                    CVolumeCandlePattern::Init(const string _sym, const ENUM_TIMEFRAMES _per, const datetime _dt);
  
  void                    CVolumeCandlePattern::CVolumeCandlePattern();
  void                    CVolumeCandlePattern::CVolumeCandlePattern(const string _sym, const ENUM_TIMEFRAMES _per, const int _shift);
  void                    CVolumeCandlePattern::CVolumeCandlePattern(const string _sym, const ENUM_TIMEFRAMES _per, const datetime _dt);
};

void CVolumeCandlePattern::Init(const string _sym, const ENUM_TIMEFRAMES _per, const int _shift){
  Sym = _sym;
  Per = _per;
  
  O    = iOpen(Sym, Per, _shift);
  H    = iHigh(Sym, Per, _shift);
  C    = iClose(Sym, Per, _shift);
  L    = iLow(Sym, Per, _shift);
  Time = iTime(Sym, Per, _shift);
  
  WickUp    = H-MathMax(O, C);
  WickDown  = MathMin(O, C)-L;
  Body      = MathAbs(O-C);
  FullSize  = H-L;  
}

void CVolumeCandlePattern::Init(const string _sym, const ENUM_TIMEFRAMES _per, const datetime _dt){
  Init(_sym, _per, iBarShift(_sym, _per, _dt));
}

void CVolumeCandlePattern::CVolumeCandlePattern() {
  Sym = "";
  Per = PERIOD_CURRENT;
  O = 0;
  H = 0;
  C = 0;
  L = 0;
  Time = 0;
  WickDown = 0;
  WickUp = 0;
  Body = 0;
  FullSize = 0;
  
  
  TicketBuy = 0;
  TicketSell = 0;
}

void CVolumeCandlePattern::CVolumeCandlePattern(const string _sym, const ENUM_TIMEFRAMES _per, const int _shift) {
  Init(_sym, _per, _shift);
}

void CVolumeCandlePattern::CVolumeCandlePattern(const string _sym, const ENUM_TIMEFRAMES _per, const datetime _dt) {
  Init(_sym, _per, _dt);
}