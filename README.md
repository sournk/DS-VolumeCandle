# DS-VolumeCandle
The expert adviser for MetaTrader 5 to trade by Volume Candle Pattern

The main idea for EA is [here](https://www.litefinance.org/blog/for-beginners/volume-candlestick-strategy/).


## Настройки

### 1. ENTRY TRADE
- `1.MM.T`: Money Management - тип расчета лота для позиции.
- `1.MM.L`: Money Management Volume - значение для расчета лота позиции.
- `1.SLP`: Max Slippage, point - максимально допустимое проскальзывание торговых операций в пунктах.
- `1.SL.ES`: Stoploss Extra Shift, points - дополнительный сдвиг стоплосса в пунктах.
- `1.TP.ES`: Takeprofit Extra Shift, points - дополнительный сдвиг тейкпрофита в пунктах.


### 2. VOLUME PATTERN SETTINGS
- `2.VP.WS`: Min Wick Size of volume candle, point - минимально допустимая длина фитиля свечи в пунктах
- `2.VP.BS`: Min body size ratio of full candle size - Во сколько минимально раз длина тела свечи должна быть меньше полного размера свечи.

### 10. MISC
- `10.LL`: Log Level - уровень логирования.
- `10.MGC`: Magic - Мэджик


## Spec I. Pattern Detection Rule

- [x] Volume candlestick can be used only in the daily timeframe (D1);
- [x] Volume candlestick should be fully formed, i.e. a new candle should appear after it;
- [x] The body of the volume candlestick should be at least 10 times smaller than the entire full length of the candle;
- [x] Each of the shadows (wicks) of the candle should be at least 400 points.
- [x] Volume candlestick can only be used on major or cross instruments.
- [x] A new candle, or even several, should appear after the one under consideration. But the price must not go beyond the high and low of our candlestick;

## Spec II. Trade Entry

![Trade Entry](img/UM001.%20Trade%20Entry.png)
- [x] Volume candlestick trading is done only with pending orders, such as Buy Stop and Sell Stop;
- [x] At the low level of the candle (sell level), set the Sell Stop order. Set Take Profit to our pending order at the level of the lower horizontal line (profit level sell), and Stop Loss at the level of the candle high (stop level sell);
- [x] At the candlestick high level (buy level), set a Buy Stop order. Set Take Profit to our pending order at the level of the upper horizontal line (profit level buy), and Stop Loss at the low level of the candle (stop level buy);
