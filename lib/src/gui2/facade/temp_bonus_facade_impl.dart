// Translation of pcgen.gui2.facade.TempBonusFacadeImpl

import 'package:flutter/foundation.dart';
import '../../facade/core/temp_bonus_facade.dart';
import '../../facade/util/list_facade.dart';
import 'temp_bonus_helper.dart';

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
}

class _SimpleListFacade<T> implements ListFacade<Object> {
  final List<T> _list;
  _SimpleListFacade(this._list);

  @override
  Object getElementAt(int index) => _list[index] as Object;

  @override
  int getSize() => _list.length;
}
