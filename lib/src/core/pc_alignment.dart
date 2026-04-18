import '../cdom/enumeration/string_key.dart';
import 'pcobject.dart';

// Represents an Alignment (LG, NG, CG, LN, TN, CN, LE, NE, CE).
final class PCAlignment extends PObject {
  String? getSortKey() => get(StringKey.sortKey);
}
