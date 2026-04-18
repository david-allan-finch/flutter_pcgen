import '../cdom/enumeration/string_key.dart';
import 'pcobject.dart';

// Represents a saving throw or other check (e.g., Fort, Ref, Will).
final class PCCheck extends PObject {
  String? getLocalScopeName() => 'PC.SAVE';

  String? getSortKey() => get(StringKey.sortKey);
}
