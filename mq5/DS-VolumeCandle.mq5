//+------------------------------------------------------------------+
//|                                              DS-VolumeCandle.mq5 |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include "Include\DKStdLib\License\DKLicense.mqh"
#include "CVolumeCandleBot.mqh"

#property script_show_inputs

input  group               "1. ENTRY TRADE"
       bool                InpTRBuy                          = true;                             // 1.TR.B: Buy enabled
       bool                InpTRSell                         = true;                             // 1.TR.S: Sell enabled
input  ENUM_MM_TYPE        InpMMT                            = ENUM_MM_TYPE_FIXED_LOT;           // 1.MM.T: Money Management
input  double              InpMMV                            = 0.01;                             // 1.MM.L: Money Management Volume
input  ulong               InpSLP                            = 2;                                // 1.SLP: Max Slippage, point
input  int                 InpETSLExtraShift                 = 0;                                // 1.SL.ES: Stoploss Extra Shift, points
input  int                 InpETTPExtraShift                 = 0;                                // 1.TP.ES: Takeprofit Extra Shift, points

input  group               "2. VOLUME PATTERN SETTINGS"
input  uint                InpVPWickSizePnt                  = 400;                              // 2.VP.WS: Min Wick Size of volume candle, point
input  double              InpVPBodySizeRatio                = 10.0;                             // 2.VP.BS: Min body size ratio of full candle size

input  group               "10. MISC"
sinput LogLevel            InpLL                             = LogLevel(DEBUG);                  // 10.LL: Log Level
sinput int                 InpMGC                            = 20240520;                         // 10.MGC: Magic
       int                 InpAUP                            = 0;                                // 10.AUP: Allowed usage period, sec
       string              InpGP                             = "DS.VC";                          // 10.GP: Global Prefix


DKLogger                   logger;
CDKTrade                   trade;
CVolumeCandleBot           bot;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  //Check dev/test allowed period
  if (CheckExpiredAndShowMessage(InpAUP)) return(INIT_FAILED);  

  // Logger init
  logger.Name   = InpGP;
  logger.Level  = InpLL;
  logger.Format = "%name%:[%level%] %message%";
  
  trade.SetExpertMagicNumber(InpMGC);
  trade.SetMarginMode();
  trade.SetTypeFillingBySymbol(Symbol());
  trade.SetDeviationInPoints(InpSLP);  
  trade.LogLevel(LOG_LEVEL_NO);
  trade.SetLogger(logger);
  
  bot.Sym = Symbol();
  bot.BuyEnabled = InpTRBuy;
  bot.SellEnabled = InpTRSell;
  bot.MMType = InpMMT;
  bot.MMValue = InpMMV;
  bot.WickSizePnt = InpVPWickSizePnt;
  bot.BodySizeRatio = InpVPBodySizeRatio;
  bot.SLExtraShift = InpETSLExtraShift;
  bot.TPExtraShift = InpETTPExtraShift;
  bot.Trade = trade;
  bot.Magic = InpMGC;
  bot.logger = GetPointer(logger);
  
  EventSetTimer(5);
  
  return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   EventKillTimer();
  }
  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()  {
  bot.OnTick();   
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()  {
   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+
