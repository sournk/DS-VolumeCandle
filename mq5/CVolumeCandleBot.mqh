//+------------------------------------------------------------------+
//|                                             CVolumeCandleBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\Trade.mqh>
#include <Arrays\ArrayObj.mqh>

#include "Include\DKStdLib\Common\DKStdLib.mqh"
#include "Include\DKStdLib\Logger\DKLogger.mqh"
#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
#include "Include\DKStdLib\NewBarDetector\DKNewBarDetector.mqh"

#include "CVolumeCandlePattern.mqh"

enum ENUM_VOLUME_PATTERN_CONDITION {
  VP_CON_WICK_TOO_SHORT,
  VP_CON_BODY_TOO_LONG,
  VP_CON_PRICE_OUT_OF_CANDLE_BOUNDS,
  VP_CON_OK
};



class CVolumeCandleBot {
protected:
  DKNewBarDetector*        NewBarDetector;
public:
  // Must be set direclty
  CDKTrade                 Trade;
  int                      Magic;
  DKLogger*                logger;

  // Must be init. Have default values
  string                   Sym;
  ENUM_TIMEFRAMES          Per;
    
  bool                     BuyEnabled;
  bool                     SellEnabled;
  ENUM_MM_TYPE             MMType;
  double                   MMValue;
  
  uint                     WickSizePnt;
  double                   BodySizeRatio;
  
  int                      SLExtraShift;
  int                      TPExtraShift;
  
  CArrayObj                VolumeCandles;
  
  ENUM_VOLUME_PATTERN_CONDITION CVolumeCandleBot::CheckBarAndAddToList(const int _shift);
  int                      CVolumeCandleBot::CheckPriceOfPatternBounds(CVolumeCandlePattern* _pattern);
  bool                     CVolumeCandleBot::RemovePriceOutOfBoundsPatterns();
  
  bool                     CVolumeCandleBot::OpenOrderForPattern(CVolumeCandlePattern* _pattern);  
  void                     CVolumeCandleBot::OpenOrders();
  
  
  // Event Handlers
  void                     CVolumeCandleBot::OnTick(void);
  void                     CVolumeCandleBot::CVolumeCandleBot(void);
  void                     CVolumeCandleBot::~CVolumeCandleBot(void);
};

//+------------------------------------------------------------------+
//| Open orders for _pattern
//+------------------------------------------------------------------+
bool CVolumeCandleBot::OpenOrderForPattern(CVolumeCandlePattern* _pattern) {
  if (_pattern.TicketBuy > 0 || _pattern.TicketSell > 0) return false; // Orders already placed

  CDKSymbolInfo sym;
  if (!sym.Name(Sym)) return false;
  if (!sym.RefreshRates()) return false;
  if (sym.TickValue() <= 0) return false;
  if (sym.TickSize() <= 0) return false;

  double price_buy = _pattern.H;
  double price_sell = _pattern.L;  

  double sl_buy  = _pattern.L-PointsToPrice(Sym, SLExtraShift);
  double sl_sell = _pattern.H+PointsToPrice(Sym, SLExtraShift);
  double tp_buy  = _pattern.H+_pattern.WickUp+PointsToPrice(Sym, TPExtraShift);
  double tp_sell = _pattern.L-_pattern.WickDown-PointsToPrice(Sym, TPExtraShift);;
  
  double lot_buy = CalculateLotSuper(Sym, MMType, MMValue, price_buy, sl_buy);
  double lot_sell = CalculateLotSuper(Sym, MMType, MMValue, price_sell, sl_sell);
  

  string comment = StringFormat("%s|%s", logger.Name, TimeToString(_pattern.Time));
  
  if (price_buy > sym.Ask() && price_sell < sym.Bid()) {
    _pattern.TicketBuy  = Trade.OrderOpen(Sym, ORDER_TYPE_BUY_STOP, lot_buy, 0, price_buy, sl_buy, tp_buy, 0, 0, comment);  
    _pattern.TicketSell = Trade.OrderOpen(Sym, ORDER_TYPE_SELL_STOP, lot_sell, 0, price_sell, sl_sell, tp_sell, 0, 0, comment);  
  }
             
  logger.Assert(_pattern.TicketBuy && _pattern.TicketSell,
                StringFormat("%s/%d: Both orders opened",
                             __FUNCTION__, __LINE__), INFO,
                StringFormat("%s/%d: One or both orders open error",
                             __FUNCTION__, __LINE__), ERROR);

  return _pattern.TicketBuy && _pattern.TicketSell;
} 

//+------------------------------------------------------------------+
//| Open orders for all patterns
//+------------------------------------------------------------------+
void CVolumeCandleBot::OpenOrders() {
  for (int i=0; i<VolumeCandles.Total(); i++) {
    CVolumeCandlePattern* pattern = VolumeCandles.At(i);
    OpenOrderForPattern(pattern);
  }
}

//+------------------------------------------------------------------+
//| Check candle for Volume Candle Pattern and add it to list
//+------------------------------------------------------------------+
ENUM_VOLUME_PATTERN_CONDITION CVolumeCandleBot::CheckBarAndAddToList(const int _shift) {
  CVolumeCandlePattern* pattern = new CVolumeCandlePattern(Sym, Per, _shift);
  
  ENUM_VOLUME_PATTERN_CONDITION res = VP_CON_OK;
  double wick_min_size = PointsToPrice(Sym, WickSizePnt);
  if (pattern.WickUp < wick_min_size || pattern.WickDown < wick_min_size) res = VP_CON_WICK_TOO_SHORT;
  if (res == VP_CON_OK && pattern.Body*BodySizeRatio > pattern.FullSize)  res = VP_CON_BODY_TOO_LONG;
  
  logger.Debug(StringFormat("%s/%d: BAR=%s; RES=%s",
                            __FUNCTION__, __LINE__,
                            TimeToString(pattern.Time),
                            EnumToString(res)
                            ));
                          
  if (res == VP_CON_OK)
    VolumeCandles.Add(pattern);
  else
    delete pattern;
                           
  return res;
}

//+------------------------------------------------------------------+
//| Check Candle Pattern to price channel
//+------------------------------------------------------------------+
int CVolumeCandleBot::CheckPriceOfPatternBounds(CVolumeCandlePattern* _pattern) {
  CDKSymbolInfo sym;
  if (!sym.Name(Sym)) return -1;
  if (!sym.RefreshRates()) return -2;
  if (sym.Ask() <= 0 || sym.Bid() <= 0) return -3;
  if (sym.Ask() > _pattern.H || sym.Bid() < _pattern.L) return 1;
  
  return 0;
}

//+------------------------------------------------------------------+
//| Check Candle Pattern to price channel
//+------------------------------------------------------------------+
bool CVolumeCandleBot::RemovePriceOutOfBoundsPatterns() {
  int size = VolumeCandles.Total();
  int i=0;
  while (i<VolumeCandles.Total()) {
    CVolumeCandlePattern* pattern = VolumeCandles.At(i);
    if (pattern.TicketBuy <= 0 && pattern.TicketSell <= 0 && CheckPriceOfPatternBounds(pattern) > 0) {
      logger.Info(StringFormat("%s/%d: Pattern removed %s",
                               __FUNCTION__, __LINE__,
                               TimeToString(pattern.Time)
                               ));
      VolumeCandles.Delete(i);
      continue;
    }
    else if (pattern.TicketBuy > 0 && pattern.TicketSell > 0) {
      COrderInfo order;
      if (!order.Select(pattern.TicketBuy))
        if (order.Select(pattern.TicketSell)) {
          Trade.OrderDelete(pattern.TicketSell);
          VolumeCandles.Delete(i);
          continue;
        }
      if (!order.Select(pattern.TicketSell))
        if (order.Select(pattern.TicketBuy)) {
          Trade.OrderDelete(pattern.TicketBuy);      
          VolumeCandles.Delete(i);
          continue;
        }    
    }

    i++;
  }
      
  return size != VolumeCandles.Total();
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
void CVolumeCandleBot::OnTick(void) {
  RemovePriceOutOfBoundsPatterns(); // Remove patterns from list when price goes out of pattern bounds
  
  if (!NewBarDetector.CheckNewBarAvaliable(Per)) return;
  logger.Debug(StringFormat("New bar detected: %s", EnumToString(Per)));
  
  CheckBarAndAddToList(1); // Check prev bar to pattern and add to list
  RemovePriceOutOfBoundsPatterns(); // Remove patterns from list when price goes out of pattern bounds
  
  OpenOrders();
}

//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CVolumeCandleBot::CVolumeCandleBot(void) {
  Sym = Symbol();
  Per = Period();
  BuyEnabled = false;
  SellEnabled = false;
  MMType = ENUM_MM_TYPE_FIXED_LOT;
  MMValue = 0.01;
  WickSizePnt = 400;
  BodySizeRatio = 10.0;
  SLExtraShift = 0;
  TPExtraShift = 0;
  
  NewBarDetector = new DKNewBarDetector(Sym, Per);
}

//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CVolumeCandleBot::~CVolumeCandleBot(void) {
  delete NewBarDetector;
  VolumeCandles.Clear();
}