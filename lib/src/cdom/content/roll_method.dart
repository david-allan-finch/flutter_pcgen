import '../base/loadable.dart';

// Defines a dice roll method for character creation (e.g., "4d6 drop lowest").
class RollMethod implements Loadable {
  String? _sourceURI;
  String? _methodName;
  String? _rollMethod;
  String? _sortKey;

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  void setName(String name) { _methodName = name; }

  @override
  String? getDisplayName() => _methodName;

  @override
  String? getKeyName() => _methodName;

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  void setMethodRoll(String method) { _rollMethod = method; }
  String? getMethodRoll() => _rollMethod;

  void setSortKey(String sortKey) { _sortKey = sortKey; }
  String? getSortKey() => _sortKey;
}
