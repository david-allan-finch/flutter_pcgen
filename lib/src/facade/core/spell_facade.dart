import '../../core/character/character_spell.dart';
import '../../core/character/spell_info.dart';
import 'info_facade.dart';

// Facade interface for Spells visible in the UI.
abstract interface class SpellFacade implements InfoFacade {
  String getSchool();
  String getSubschool();
  List<String> getDescriptors();
  String getComponents();
  String getRange();
  String getDuration();
  String getCastTime();
  CharacterSpell? getCharSpell();
  SpellInfo? getSpellInfo();
}
