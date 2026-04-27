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
// Translation of pcgen.gui2.facade.TempBonusFacadeImpl

import 'package:flutter/foundation.dart';
import 'package:flutter_pcgen/src/facade/core/temp_bonus_facade.dart';
import 'package:flutter_pcgen/src/facade/util/list_facade.dart';
import 'package:flutter_pcgen/src/gui2/facade/temp_bonus_helper.dart';

/// Implementation of TempBonusFacade managing temporary bonuses on a character.
class TempBonusFacadeImpl extends ChangeNotifier implements TempBonusFacade {
  final dynamic _character;
  final List<Map<String, dynamic>> _availableBonuses;
  final List<Map<String, dynamic>> _activeBonuses = [];

  TempBonusFacadeImpl(this._character, this._availableBonuses);

  @override
  ListFacade<Object> getAvailableTempBonuses() =>
      _SimpleListFacade(_availableBonuses);

  @override
  ListFacade<Object> getActiveTempBonuses() =>
      _SimpleListFacade(_activeBonuses);

  @override
  void applyBonus(Object bonus) {
    final b = bonus as Map<String, dynamic>;
    if (!_activeBonuses.contains(b)) {
      _activeBonuses.add(b);
      notifyListeners();
    }
  }

  @override
  void removeBonus(Object bonus) {
    if (_activeBonuses.remove(bonus)) {
      notifyListeners();
    }
  }

  @override
  bool isBonusActive(Object bonus) => _activeBonuses.contains(bonus);

  @override
  String getBonusName(Object bonus) =>
      TempBonusHelper.getBonusName(bonus as Map<String, dynamic>);

  @override
  String getBonusExpression(Object bonus) =>
      TempBonusHelper.getBonusExpression(bonus as Map<String, dynamic>);

  @override
  bool requiresTarget(Object bonus) =>
      TempBonusHelper.requiresTarget(bonus as Map<String, dynamic>);

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _SimpleListFacade<T> implements ListFacade<Object> {
  final List<T> _list;
  _SimpleListFacade(this._list);

  @override
  Object getElementAt(int index) => _list[index] as Object;

  @override
  int getSize() => _list.length;

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
