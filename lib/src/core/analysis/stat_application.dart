import '../../player_character.dart';

// Handles stat-increase selection UI during level-up.
final class StatApplication {
  StatApplication._();

  // Asks the user to choose stats to increment at level-up.
  // Returns the number of stat choices still unassigned.
  static int askForStatIncrease(
      PlayerCharacter aPC, int statsToChoose, bool isPre) {
    // Stub: GUI chooser not yet implemented in Dart port.
    // Full implementation requires CDOMChooserFacadeImpl, ChooserFactory,
    // SettingsHandler, and LanguageBundle integrations.
    return statsToChoose;
  }
}
