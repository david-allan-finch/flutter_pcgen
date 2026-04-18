import '../../core/pc_class.dart';
import '../../rules/context/load_context.dart';

// Associates a spell level with a PCClass; used in spell level choices.
class SpellLevel implements Comparable<SpellLevel> {
  final PCClass _pcclass;
  final int _level;

  SpellLevel(this._pcclass, this._level);

  String encodeChoice() => 'CLASS.${_pcclass.getKeyName()};LEVEL.$_level';

  static SpellLevel? decodeChoice(LoadContext context, String persistentFormat) {
    final loc = persistentFormat.indexOf(';LEVEL.');
    String classString;
    String levelString;
    if (loc == -1) {
      final spaceLoc = persistentFormat.indexOf(' ');
      if (spaceLoc < 0) return null;
      classString = persistentFormat.substring(0, spaceLoc);
      levelString = persistentFormat.substring(spaceLoc + 1);
    } else {
      if (!persistentFormat.startsWith('CLASS.')) return null;
      classString = persistentFormat.substring(6, loc);
      levelString = persistentFormat.substring(loc + 7);
    }
    final pcc = context.getReferenceContext().silentlyGetConstructedCDOMObject(PCClass, classString) as PCClass?;
    final level = int.tryParse(levelString);
    if (level == null) return null;
    return SpellLevel(pcc!, level);
  }

  PCClass getPCClass() => _pcclass;
  int getLevel() => _level;

  @override
  String toString() => '$_pcclass $_level';

  @override
  bool operator ==(Object other) {
    if (other is SpellLevel) {
      return _level == other._level && _pcclass == other._pcclass;
    }
    return false;
  }

  @override
  int get hashCode => _level ^ _pcclass.hashCode;

  @override
  int compareTo(SpellLevel other) {
    final cmp = _pcclass.compareTo(other._pcclass);
    if (cmp != 0) return cmp;
    return _level.compareTo(other._level);
  }
}
