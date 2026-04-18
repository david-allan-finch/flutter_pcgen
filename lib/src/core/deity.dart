import 'pcobject.dart';

// Represents a deity that a character can worship.
final class Deity extends PObject {
  @override
  String toString() => getDisplayName();
}
