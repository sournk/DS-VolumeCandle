# DS-VolumeCandle
The expert adviser for MetaTrader 5 to trade by Volume Candle Pattern

The main idea for EA is [here](https://www.litefinance.org/blog/for-beginners/volume-candlestick-strategy/).

## Pattern Detection Rule

- [ ] Volume candlestick can be used only in the daily timeframe (D1);
- [ ] Volume candlestick should be fully formed, i.e. a new candle should appear after it;
- [ ] The body of the volume candlestick should be at least 10 times smaller than the entire full length of the candle;
- [ ] Each of the shadows (wicks) of the candle should be at least 400 points.
- [ ] Volume candlestick can only be used on major or cross instruments.
- [ ] A new candle, or even several, should appear after the one under consideration. But the price must not go beyond the high and low of our candlestick;

## Trade Entry

![Trade Entry](img/UM001.%20Trade%20Entry.png)
- [ ] Volume candlestick trading is done only with pending orders, such as Buy Stop and Sell Stop;
- [ ] At the low level of the candle (sell level), set the Sell Stop order. Set Take Profit to our pending order at the level of the lower horizontal line (profit level sell), and Stop Loss at the level of the candle high (stop level sell);
- [ ] At the candlestick high level (buy level), set a Buy Stop order. Set Take Profit to our pending order at the level of the upper horizontal line (profit level buy), and Stop Loss at the low level of the candle (stop level buy);
