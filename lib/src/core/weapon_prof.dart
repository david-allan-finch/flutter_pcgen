import 'pcobject.dart';

/// Represents weapon proficiency (e.g., Simple, Martial, Exotic weapons).
///
/// Translated from pcgen.core.WeaponProf. Equality and comparison are based
/// on the key name, case-insensitively.
final class WeaponProf extends PObject implements Comparable<Object> {
  /// Compares keyName only, case-insensitively.
  @override
  int compareTo(Object o1) {
    if (o1 is WeaponProf) {
      return getKeyName().toLowerCase().compareTo(o1.getKeyName().toLowerCase());
    }
    return getKeyName().toLowerCase().compareTo(o1.toString().toLowerCase());
  }

  /// Equality based on keyName only, case-insensitively.
  @override
  bool operator ==(Object obj) {
    return obj is WeaponProf &&
        getKeyName().toLowerCase() == obj.getKeyName().toLowerCase();
  }

  @override
  int get hashCode => getKeyName().toLowerCase().hashCode;

  @override
  String toString() => getDisplayName();
}
