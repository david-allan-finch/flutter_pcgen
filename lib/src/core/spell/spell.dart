import '../pcobject.dart';

/// Represents a magic spell from the game rules.
///
/// Translated from pcgen.core.spell.Spell. Spells are Ungranted (cannot be
/// directly granted to PCs) and are identified by their key name.
final class Spell extends PObject {
  /// Generate LST format text for this spell.
  String getPCCText() {
    final txt = <String>[getDisplayName()];
    // Additional fields (school, range, duration, etc.) would be serialized here
    // in the full implementation using the LoadContext unparse infrastructure.
    return txt.join('\t');
  }

  @override
  bool operator ==(Object other) =>
      other is Spell &&
      getKeyName().toLowerCase() == other.getKeyName().toLowerCase();

  /// Hashcode based on key name (case-insensitive collisions are acceptable).
  @override
  int get hashCode => getKeyName().toLowerCase().hashCode;

  @override
  String toString() => getDisplayName();
}
