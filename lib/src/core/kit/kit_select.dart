//
// Copyright 2005 (C) Aaron Divinsky <boomer70@yahoo.com>
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
// Translation of pcgen.core.kit.KitSelect
import 'package:flutter_pcgen/src/core/kit.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'base_kit.dart';

final class KitSelect extends BaseKit {
  String? _formula; // formula string

  String? getFormula() => _formula;
  void setFormula(String formula) { _formula = formula; }

  @override
  bool testApply(Kit aKit, PlayerCharacter aPC, List<String> warnings) {
    if (_formula != null) {
      aKit.setSelectValue(aPC.getVariableValue(_formula!, '').toInt());
    }
    return true;
  }

  @override
  void apply(PlayerCharacter aPC) {} // nothing to do

  @override
  String getObjectName() => 'Select';

  @override
  String toString() => _formula ?? '';
}
