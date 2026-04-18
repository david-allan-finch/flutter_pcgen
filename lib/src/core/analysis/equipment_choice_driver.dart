import '../../../cdom/enumeration/string_key.dart';
import '../../player_character.dart';

// Drives the equipment-modifier choice UI for adding/removing EquipmentModifiers.
final class EquipmentChoiceDriver {
  EquipmentChoiceDriver._();

  /// Shows a choice dialog for [eqMod] on [parent].
  /// Returns true if a valid choice was made (or none was needed).
  static bool getChoice(int pool, dynamic parent, dynamic eqMod, bool bAdd,
      PlayerCharacter pc) {
    final choiceString = eqMod.getSafe(StringKey.choiceString) as String;
    if (choiceString.isEmpty) return true;

    final forEqBuilder = choiceString.startsWith('EQBUILDER.');
    if (bAdd && forEqBuilder) return true;

    // Full implementation requires EquipmentChoice, CDOMChooserFacadeImpl,
    // ChooserFactory, LanguageBundle, and SignedInteger. Stubbed for Dart port.
    return true;
  }
}
