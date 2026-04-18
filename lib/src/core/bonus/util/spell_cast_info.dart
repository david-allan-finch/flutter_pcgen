// Holds parsed spell-cast bonus information (class, level, type).
class SpellCastInfo {
  String _classString = '';
  final String _level;
  String? _type;

  SpellCastInfo(String argType, String argLevel) : _level = argLevel {
    if (argType.startsWith('TYPE')) {
      _type = argType.substring(5);
    } else if (argType.startsWith('CLASS')) {
      _classString = argType.substring(6);
    }
  }

  String getLevel() => _level;
  String getPcClassName() => _classString;
  String? getType() => _type;
}
