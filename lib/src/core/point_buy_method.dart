//
// Copyright 2002 (C) Greg Bingleman <byngl@hotmail.com>
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
// Translation of pcgen.core.PointBuyMethod
import 'package:flutter_pcgen/src/cdom/base/bonus_container.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/core/bonus/bonus_obj.dart';

// Represents a point-buy method (e.g. "28-Point Buy") from the game mode.
final class PointBuyMethod implements BonusContainer, Loadable {
  String? _sourceUri;
  String _methodName = '';
  String _pointFormula = '0';
  final List<BonusObj> _bonusList = [];

  @override
  String? getSourceURI() => _sourceUri;

  @override
  void setSourceURI(String source) => _sourceUri = source;

  String getPointFormula() => _pointFormula;
  void setPointFormula(String formula) => _pointFormula = formula;

  String getDescription() {
    var desc = _methodName;
    if (_pointFormula != '0') desc += ' ($_pointFormula)';
    return desc;
  }

  void addBonus(BonusObj bon) => _bonusList.add(bon);
  List<BonusObj> getBonusList() => List.unmodifiable(_bonusList);

  @override
  List<BonusObj> getRawBonusList() => _bonusList;

  @override
  String getKeyName() => _methodName;

  @override
  void setName(String name) => _methodName = name;

  @override
  String getDisplayName() => _methodName;

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  @override
  String toString() => _methodName;
}
