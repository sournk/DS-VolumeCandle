//+------------------------------------------------------------------+
//|                                                CDKSymbolInfo.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#property copyright "Denis Kislitsyn"
#property link      "https://kislitsyn.me"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>

#include "..\Logger\DKLogger.mqh"

class CDKTrade : public CTrade {
private:
  DKLogger          logger;
public:
  bool              CDKTrade::OrderOpenOrTrade(const string symbol, const ENUM_ORDER_TYPE order_type, const double volume,
                                                const double limit_price, const double price, const double sl, const double tp,
                                                ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC, const datetime expiration=0,
                                                const string comment="");
                                                
  ulong             CDKTrade::OrderOpen(const string          symbol,          // символ
                                        ENUM_ORDER_TYPE       order_type,      // тип ордера
                                        double                volume,          // объем ордера
                                        double                limit_price,     // цена стоплимита
                                        double                price,           // цена исполнения
                                        double                sl,              // цена stop loss
                                        double                tp,              // цена take profit
                                        ENUM_ORDER_TYPE_TIME  type_time,       // тип по истечению
                                        datetime              expiration,      // истечение
                                        const string          comment=""       // комментарий
                                       );
  bool              CDKTrade::OrderDelete(ulong  ticket);
  
  bool              CDKTrade::PositionClose(const ulong   ticket,                  // тикет позиции
                                            ulong         deviation=ULONG_MAX      // отклонение
                                            );
bool                CDKTrade::PositionModify(const ulong   ticket,     // тикет позиции
                                             double        sl,         // цена Stop Loss 
                                             double        tp          // цена Take Profit
                                            );                                            
  
                                        
  void              CDKTrade::CDKTrade(void);   
  void              CDKTrade::SetLogger(DKLogger& _logger);                                            

};

//+------------------------------------------------------------------+
//| If order_type in [ORDER_TYPE_BUY, ORDER_TYPE_SELL]
//| will execute CTrade::Buy() or CTrade::Sell()
//| overwise CTrade::OrderOpen()
//+------------------------------------------------------------------+
bool CDKTrade::OrderOpenOrTrade(const string symbol, const ENUM_ORDER_TYPE order_type, const double volume,
                                const double limit_price, const double price, const double sl, const double tp,
                                ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC, const datetime expiration=0,
                                const string comment="") {
  if (order_type==ORDER_TYPE_BUY)
    return CTrade::Buy(volume, symbol, price, sl, tp, comment);
    
  if (order_type==ORDER_TYPE_SELL) 
    return CTrade::Sell(volume, symbol, price, sl, tp, comment);
  
  return CTrade::OrderOpen(symbol, order_type, volume, limit_price, price, sl, tp, type_time, expiration, comment);
}

//+------------------------------------------------------------------+
//| CTrade::OrderOpen() with handling and logging
//+------------------------------------------------------------------+
ulong CDKTrade::OrderOpen(const string          symbol,          // символ
                          ENUM_ORDER_TYPE       order_type,      // тип ордера
                          double                volume,          // объем ордера
                          double                limit_price,     // цена стоплимита
                          double                price,           // цена исполнения
                          double                sl,              // цена stop loss
                          double                tp,              // цена take profit
                          ENUM_ORDER_TYPE_TIME  type_time,       // тип по истечению
                          datetime              expiration,      // истечение
                          const string          comment=""       // комментарий
                         ) {
  ResetLastError();
  ulong ticket = 0;
  uint ret_code = 0;  
  string ret_code_desc = "";
  if (CTrade::OrderOpen(symbol, order_type, volume, limit_price, price, sl, tp, type_time, expiration, comment)) {
    ticket        = CTrade::ResultOrder();
    ret_code      = CTrade::ResultRetcode();
    ret_code_desc = CTrade::ResultRetcodeDescription();
  }
  else 
    ret_code_desc = "CTrade::OrderOpen returns false";
  
  logger.Assert(ticket > 0,
                StringFormat("%s/%d: RET_CODE=%d; TICKET=%I64u; LOT=%f; LIM_PRICE=%f; PRICE=%f; SL=%f; TP=%f",
                             __FUNCTION__, __LINE__,
                             ret_code, ticket, volume, limit_price, price, sl, tp), INFO,
                StringFormat("%s/%d: RET_CODE=%d; LOT=%f; LIM_PRICE=%f; PRICE=%f; SL=%f; TP=%f; ERR=%s",
                             __FUNCTION__, __LINE__,
                             ret_code, volume, limit_price, price, sl, tp, ret_code_desc), ERROR);
  return ticket;  
}

//+------------------------------------------------------------------+
//| CTrade::OrderDelete() with error handling and logging
//+------------------------------------------------------------------+
bool CDKTrade::OrderDelete(ulong ticket) {
  ResetLastError();
  uint ret_code = 0;  
  string ret_code_desc = "";  
  if (CTrade::OrderDelete(ticket)) {
    ret_code      = CTrade::ResultRetcode();
    ret_code_desc = CTrade::ResultRetcodeDescription(); 
  }
  
  logger.Assert(ret_code == TRADE_RETCODE_DONE,
                StringFormat("%s/%d: RET_CODE=%d; TICKET=%I64u",
                             __FUNCTION__, __LINE__,
                             ret_code, ticket), INFO,
                StringFormat("%s/%d: RET_CODE=%d; TICKET=%I64u; ERR=%s",
                             __FUNCTION__, __LINE__,
                             ret_code, ticket, ret_code_desc), ERROR);

  return ret_code == TRADE_RETCODE_DONE;                               
}

//+------------------------------------------------------------------+
//| CTrade::PositionClose() with error handling and logging
//+------------------------------------------------------------------+
bool CDKTrade::PositionClose(const ulong   ticket,                  // тикет позиции
                             ulong         deviation=ULONG_MAX      // отклонение
                             ) {
  ResetLastError();
  uint ret_code = 0;  
  string ret_code_desc = "";  
  if (CTrade::PositionClose(ticket, deviation)) {
    ret_code      = CTrade::ResultRetcode();
    ret_code_desc = CTrade::ResultRetcodeDescription(); 
  }
  
  logger.Assert(ret_code == TRADE_RETCODE_DONE,
                StringFormat("%s/%d: RET_CODE=%d; TICKET=%I64u",
                             __FUNCTION__, __LINE__,
                             ret_code, ticket), INFO,
                StringFormat("%s/%d: RET_CODE=%d; TICKET=%I64u; ERR=%s",
                             __FUNCTION__, __LINE__,
                             ret_code, ticket, ret_code_desc), ERROR);

  return ret_code == TRADE_RETCODE_DONE;
}

//+------------------------------------------------------------------+
//| CTrade::PositionClose() with error handling and logging
//+------------------------------------------------------------------+
bool CDKTrade::PositionModify(const ulong   ticket,     // тикет позиции
                              double        sl,         // цена Stop Loss 
                              double        tp          // цена Take Profit
                             ) {
  ResetLastError();
  uint ret_code = 0;  
  string ret_code_desc = "";  
  if (CTrade::PositionModify(ticket, sl, tp)) {
    ret_code      = CTrade::ResultRetcode();
    ret_code_desc = CTrade::ResultRetcodeDescription(); 
  }
  
  logger.Assert(ret_code == TRADE_RETCODE_DONE,
                StringFormat("%s/%d: RET_CODE=%d; TICKET=%I64u",
                             __FUNCTION__, __LINE__,
                             ret_code, ticket), INFO,
                StringFormat("%s/%d: RET_CODE=%d; TICKET=%I64u; ERR=%s",
                             __FUNCTION__, __LINE__,
                             ret_code, ticket, ret_code_desc), ERROR);

  return ret_code == TRADE_RETCODE_DONE;
}

//+------------------------------------------------------------------+
//| Constructor                                                                  |
//+------------------------------------------------------------------+
void CDKTrade::CDKTrade(void) {
  logger.Name   = "CDKTrade";
  logger.Level  = NO;
  logger.Format = "%name%:[%level%] %message%";
}

//+------------------------------------------------------------------+
//| Constructor                                                                  |
//+------------------------------------------------------------------+
void CDKTrade::SetLogger(DKLogger& _logger) {
  logger = _logger;
}
