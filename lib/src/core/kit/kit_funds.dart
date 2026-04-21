//
// Copyright 2005 (C) Greg Bingleman <byngl@hotmail.com>
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
// Translation of pcgen.core.kit.KitFunds
import 'package:flutter_pcgen/src/core/kit.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'base_kit.dart';

class KitFunds extends BaseKit {
  String _name = '';
  String? _quantityFormula; // formula string
  double _theQty = 0.0;

  @override
  void setName(String value) { _name = value; }
  String getName() => _name;

  void setQuantity(String formula) { _quantityFormula = formula; }
  String? getQuantity() => _quantityFormula;

  @override
  bool testApply(Kit? aKit, PlayerCharacter aPC, List<String>? warnings) {
    if (_quantityFormula == null) return false;
    _theQty = aPC.getVariableValue(_quantityFormula!, '').toDouble();
    return true;
  }

  @override
  void apply(PlayerCharacter aPC) {
    aPC.adjustFunds(_theQty);
  }

  @override
  String getObjectName() => 'Funds';

  @override
  String toString() => '${_quantityFormula ?? ''} $_name';
}
