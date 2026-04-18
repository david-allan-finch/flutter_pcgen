import 'package:pcgen2/src/cdom/enumeration/list_key.dart';
import 'package:pcgen2/src/cdom/identifier/spell_school.dart';
import 'package:pcgen2/src/core/spell/spell.dart';

enum ProhibitedSpellType {
  alignment('Alignment'),
  descriptor('Descriptor'),
  school('School'),
  subSchool('SubSchool'),
  spell('Spell');

  final String text;

  const ProhibitedSpellType(this.text);

  @override
  String toString() => text;

  List<String> getCheckList(Spell s) {
    return switch (this) {
      ProhibitedSpellType.alignment ||
      ProhibitedSpellType.descriptor =>
        List<String>.of(
            s.getSafeListFor(ListKey.getConstant<String>('SPELL_DESCRIPTOR'))),
      ProhibitedSpellType.school => s
          .getSafeListFor(ListKey.getConstant<SpellSchool>('SPELL_SCHOOL'))
          .map((ss) => ss.toString())
          .toList(),
      ProhibitedSpellType.subSchool => List<String>.of(
          s.getSafeListFor(ListKey.getConstant<String>('SPELL_SUBSCHOOL'))),
      ProhibitedSpellType.spell => [s.getKeyName()],
    };
  }

  int getRequiredCount(List<String> l) {
    return switch (this) {
      ProhibitedSpellType.spell => 1,
      _ => l.length,
    };
  }
}
