import '../../core/spell.dart';
import '../base/concrete_prereq_object.dart';

// Represents a spell-like ability with cast times, caster level, DC, and book info.
class SpellLikeAbility extends ConcretePrereqObject {
  final Spell spell;
  final String castTimes; // formula string
  final String castTimeUnit;
  final String fixedCasterLevel;
  final String dc;
  final String book;
  final String qualifiedKey;

  SpellLikeAbility(this.spell, this.castTimes, this.castTimeUnit,
      this.book, this.fixedCasterLevel, this.dc, this.qualifiedKey);

  Spell getSpell() => spell;
  String getCastTimes() => castTimes;
  String getCastTimeUnit() => castTimeUnit;
  String getFixedCasterLevel() => fixedCasterLevel;
  String getDC() => dc;
  String getSpellBook() => book;
  String getQualifiedKey() => qualifiedKey;
}
