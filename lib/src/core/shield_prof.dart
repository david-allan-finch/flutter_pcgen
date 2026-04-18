import '../cdom/base/ungranted.dart';
import 'pcobject.dart';

// Represents a shield proficiency that a character may possess.
final class ShieldProf extends PCObject
    implements Comparable<Object>, Ungranted {
  @override
  int compareTo(Object o1) =>
      getKeyName().toLowerCase().compareTo((o1 as ShieldProf).getKeyName().toLowerCase());

  @override
  bool operator ==(Object obj) =>
      obj is ShieldProf &&
      getKeyName().toLowerCase() == obj.getKeyName().toLowerCase();

  @override
  int get hashCode => getKeyName().toLowerCase().hashCode;
}
