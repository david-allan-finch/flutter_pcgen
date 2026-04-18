import '../base/loadable.dart';

// Defines how many bonus spells a caster gets per spell level based on stat score.
class BonusSpellInfo implements Loadable {
  String? _sourceURI;
  int _statRange = 0;
  int _spellLevel = 0;
  int _statScore = 0;

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  void setName(String name) {
    final intValue = int.tryParse(name);
    if (intValue == null || intValue < 1) {
      throw ArgumentError('Name must be an integer >= 1, found: $name');
    }
    _spellLevel = intValue;
  }

  @override
  String? getDisplayName() => _spellLevel.toString();

  @override
  String? getKeyName() => getDisplayName();

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  void setStatRange(int range) { _statRange = range; }
  void setStatScore(int score) { _statScore = score; }

  bool isValid() => _spellLevel > 0 && _statRange > 0 && _statScore > 0;
  int getStatScore() => _statScore;
  int getStatRange() => _statRange;
  int getSpellLevel() => _spellLevel;
}
