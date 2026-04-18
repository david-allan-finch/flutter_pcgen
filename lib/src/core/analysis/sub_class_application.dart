import '../../pc_class.dart';
import '../../player_character.dart';

// Handles subclass selection UI and application during class level-up.
final class SubClassApplication {
  SubClassApplication._();

  /// Prompts the user to select a subclass for [cl] on [aPC], if applicable.
  static void checkForSubClass(PlayerCharacter aPC, PCClass cl) {
    // Full implementation requires GUI chooser (CDOMChooserFacadeImpl,
    // ChooserFactory, LanguageBundle). Stubbed for Dart port.
    // Logic: build list of qualifying SubClass entries, show chooser,
    // call setSubClassKey with the selection, then apply prohibited schools.
  }

  static void setSubClassKey(
      PlayerCharacter pc, PCClass cl, String aKey) {
    if (cl == null) return;
    pc.setSubClassName(cl, aKey);
    if (aKey != cl.getKeyName()) {
      final a = cl.getSubClassKeyed(aKey);
      if (a != null) {
        cl.inheritAttributesFrom(a);
        pc.reInheritClassLevels(cl);
      }
    }
  }
}
