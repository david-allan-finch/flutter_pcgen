import 'pcobject.dart';

// Represents a language that a character can speak/read/write.
final class Language extends PObject implements Comparable<Language> {
  @override
  int compareTo(Object other) {
    if (other is Language) {
      return getKeyName().toLowerCase().compareTo(other.getKeyName().toLowerCase());
    }
    return 1;
  }

  @override
  String toString() => getDisplayName();
}
