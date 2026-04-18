import '../cdom/enumeration/list_key.dart';
import '../cdom/enumeration/string_key.dart';
import 'pcobject.dart';

// Represents a starting kit for character creation.
final class Kit extends PObject {
  int _region = 0;

  int getRegion() => _region;

  String getDescription() => getSafeString(StringKey.description);

  List<dynamic> getKitTasks() =>
      getSafeListFor<dynamic>(ListKey.getConstant<dynamic>('KIT_TASKS'));

  @override
  String toString() => getDisplayName();
}
