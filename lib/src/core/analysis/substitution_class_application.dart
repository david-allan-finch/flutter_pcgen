import '../../pc_class.dart';
import '../../player_character.dart';
import 'substitution_level_support.dart';

// Handles substitution-class selection UI and application during level-up.
final class SubstitutionClassApplication {
  SubstitutionClassApplication._();

  static void checkForSubstitutionClass(
      PCClass cl, int aLevel, PlayerCharacter aPC) {
    // Full implementation requires GUI chooser (CDOMChooserFacadeImpl,
    // ChooserFactory, LanguageBundle). Stubbed for Dart port.
    // Logic: build sorted choice list of qualifying SubstitutionClass entries,
    // show chooser, then call SubstitutionLevelSupport.applyLevelArrayModsToLevel.
  }

  static void _buildSubstitutionClassChoiceList(PCClass cl,
      List<PCClass> choiceList, int level, PlayerCharacter aPC) {
    // stub — would populate choiceList with qualifying SubstitutionClass entries
  }
}
