// Translation of pcgen.io.filters.OutputFilter

import '../../core/player_character.dart';

/// Filters output during character sheet export.
abstract interface class OutputFilter {
  bool accept(PlayerCharacter pc);
}
