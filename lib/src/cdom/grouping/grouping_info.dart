// Holds hierarchical grouping information for the formula system's MODIFYOTHER token.
class GroupingInfo<T> {
  String? objectType;
  String? characteristic;
  String? value;
  GroupingInfo? child;
  dynamic scope; // PCGenScope

  GroupingInfo(); // package-level construction via GroupingInfoFactory

  String? getObjectType() => objectType;
  String? getCharacteristic() => characteristic;
  String? getValue() => value;
  GroupingInfo? getChild() => child;
  dynamic getScope() => scope;
}
