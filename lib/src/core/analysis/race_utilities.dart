import '../globals.dart';
import '../race.dart';

abstract final class RaceUtilities {
  // Get the unselected Race (the placeholder race used before selection).
  static Race? getUnselectedRace() {
    for (final race in Globals.context.getReferenceContext().getConstructedCDOMObjects<Race>()) {
      if (race.isUnselected()) return race;
    }
    return null;
  }
}
