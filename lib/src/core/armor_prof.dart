import 'pcobject.dart';

/// Represents armor (and shield) proficiency.
///
/// Translated from pcgen.core.ArmorProf. Equality and comparison are based
/// on the key name, case-insensitively.
final class ArmorProf extends PObject implements Comparable<Object> {
  /// Compares keyName only, case-insensitively.
  @override
  int compareTo(Object o1) {
    if (o1 is ArmorProf) {
      return getKeyName().toLowerCase().compareTo(o1.getKeyName().toLowerCase());
    }
    return getKeyName().toLowerCase().compareTo(o1.toString().toLowerCase());
  }

  /// Equality based on keyName only, case-insensitively.
  @override
  bool operator ==(Object obj) {
    return obj is ArmorProf &&
        getKeyName().toLowerCase() == obj.getKeyName().toLowerCase();
  }

  @override
  int get hashCode => getKeyName().toLowerCase().hashCode;

  @override
  String toString() => getDisplayName();
}
