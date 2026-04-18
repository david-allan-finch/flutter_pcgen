// Defines a named set of buy/sell rates for gear (e.g. "Standard: Buy 100% Sell 50%").
class GearBuySellScheme {
  final String name;
  final double buyRate;
  final double sellRate;
  final double cashSellRate;

  const GearBuySellScheme(this.name, this.buyRate, this.sellRate, this.cashSellRate);

  @override
  String toString() => '$name - Buy ${buyRate.toStringAsFixed(0)}% Sell ${sellRate.toStringAsFixed(0)}%';
}
