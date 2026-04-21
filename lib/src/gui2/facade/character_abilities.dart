// Translation of pcgen.gui2.facade.CharacterAbilities

import 'package:flutter/foundation.dart';
import '../../facade/util/list_facade.dart';

/// Manages ability score data for a character — the facade layer for
/// reading and writing ability scores (STR, DEX, CON, INT, WIS, CHA).
class CharacterAbilities extends ChangeNotifier {
  static const List<String> statNames = [
    'STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA',
  ];

  final dynamic _character;
  final Map<String, int> _baseScores = {};
  final Map<String, int> _racialBonuses = {};
  final Map<String, int> _miscBonuses = {};

  CharacterAbilities(this._character) {
    _loadFromCharacter();
  }

  void _loadFromCharacter() {
    if (_character == null) return;
    if (_character is Map) {
      final stats = _character['stats'];
      if (stats is Map) {
        for (final name in statNames) {
          final stat = stats[name];
          if (stat is Map) {
            _baseScores[name] = (stat['base'] as num?)?.toInt() ?? 10;
            _racialBonuses[name] = (stat['racial'] as num?)?.toInt() ?? 0;
            _miscBonuses[name] = (stat['misc'] as num?)?.toInt() ?? 0;
          } else {
            _baseScores[name] = 10;
            _racialBonuses[name] = 0;
            _miscBonuses[name] = 0;
          }
        }
      }
    }
  }

  int getBase(String stat) => _baseScores[stat] ?? 10;
  int getRacial(String stat) => _racialBonuses[stat] ?? 0;
  int getMisc(String stat) => _miscBonuses[stat] ?? 0;
  int getTotal(String stat) => getBase(stat) + getRacial(stat) + getMisc(stat);
  int getMod(String stat) => (getTotal(stat) - 10) ~/ 2;

  void setBase(String stat, int value) {
    _baseScores[stat] = value;
    _persistToCharacter();
    notifyListeners();
  }

  bool canUpStat(String stat) {
    if (_character == null) return false;
    return true; // simplified
  }

  bool canDownStat(String stat) {
    if (_character == null) return false;
    return getBase(stat) > 3;
  }

  void upStat(String stat) {
    if (canUpStat(stat)) {
      _baseScores[stat] = getBase(stat) + 1;
      _persistToCharacter();
      notifyListeners();
    }
  }

  void downStat(String stat) {
    if (canDownStat(stat)) {
      _baseScores[stat] = getBase(stat) - 1;
      _persistToCharacter();
      notifyListeners();
    }
  }

  /// Purchase points spent (for point-buy method).
  int getPurchasePoints() {
    if (_character is Map) {
      return (_character['purchasePoints'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  void _persistToCharacter() {
    if (_character == null || _character is! Map) return;
    final stats = _character.putIfAbsent('stats', () => <String, dynamic>{});
    for (final name in statNames) {
      stats[name] = <String, dynamic>{
        'base': _baseScores[name] ?? 10,
        'racial': _racialBonuses[name] ?? 0,
        'misc': _miscBonuses[name] ?? 0,
      };
    }
  }

  void reload() {
    _loadFromCharacter();
    notifyListeners();
  }
}
