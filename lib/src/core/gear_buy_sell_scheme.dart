//
// Copyright James Dempsey, 2012
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.GearBuySellScheme
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
