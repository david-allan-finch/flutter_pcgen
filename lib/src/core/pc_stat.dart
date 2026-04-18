import '../cdom/base/non_interactive.dart';
import '../cdom/base/sort_key_required.dart';
import '../cdom/enumeration/string_key.dart';
import 'pcobject.dart';

// Represents an ability score (STR, DEX, CON, etc.).
final class PCStat extends PObject
    implements NonInteractive, SortKeyRequired {
  @override
  String? getLocalScopeName() => 'PC.STAT';

  @override
  String toString() => getKeyName();

  @override
  String getSortKey() => get(StringKey.sortKey) as String? ?? '';
}
