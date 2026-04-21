// Translation of pcgen.gui2.facade.CharacterLevelsFacadeImpl

import 'package:flutter/foundation.dart';
import '../../facade/core/character_levels_facade.dart';
import '../../facade/core/character_level_facade.dart';
import '../../facade/util/list_facade.dart';
import 'character_level_facade_impl.dart';

/// Implementation of CharacterLevelsFacade managing the character's level progression.
class CharacterLevelsFacadeImpl extends ChangeNotifier
    implements CharacterLevelsFacade {
  final dynamic _character;
  final List<CharacterLevelFacadeImpl> _levels = [];

  CharacterLevelsFacadeImpl(this._character) {
    _loadLevels();
  }

  void _loadLevels() {
    _levels.clear();
    if (_character == null) return;
    if (_character is Map) {
      final classLevels = _character['classLevels'];
      if (classLevels is List) {
        for (final lvl in classLevels) {
          _levels.add(CharacterLevelFacadeImpl(lvl));
        }
      }
    }
    notifyListeners();
  }

  @override
  ListFacade<CharacterLevelFacade> getLevels() => _LevelListFacade(_levels);

  @override
  int getSize() => _levels.length;

  @override
  CharacterLevelFacade? getElementAt(int index) {
    if (index < 0 || index >= _levels.length) return null;
    return _levels[index];
  }

  @override
  int getTotalHitDice() {
    if (_character is Map) {
      return (_character['totalHD'] as num?)?.toInt() ?? _levels.length;
    }
    return _levels.length;
  }

  @override
  int getHPRolled(int index) {
    if (index < 0 || index >= _levels.length) return 0;
    return (_levels[index]._level?['hpRolled'] as num?)?.toInt() ?? 0;
  }

  @override
  void setHPRolled(int index, int hp) {
    if (index < 0 || index >= _levels.length) return;
    final lvl = _levels[index]._level;
    if (lvl is Map) lvl['hpRolled'] = hp;
    notifyListeners();
  }

  @override
  int getSkillPointsRemaining(int index) {
    if (index < 0 || index >= _levels.length) return 0;
    return (_levels[index]._level?['skillPointsRemaining'] as num?)?.toInt() ?? 0;
  }

  @override
  int getSkillPointsGained(int index) {
    if (index < 0 || index >= _levels.length) return 0;
    return (_levels[index]._level?['skillPointsGained'] as num?)?.toInt() ?? 0;
  }

  void reload() => _loadLevels();
}

class _LevelListFacade implements ListFacade<CharacterLevelFacade> {
  final List<CharacterLevelFacadeImpl> _list;
  _LevelListFacade(this._list);

  @override
  CharacterLevelFacade getElementAt(int index) => _list[index];

  @override
  int getSize() => _list.length;
}
