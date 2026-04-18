import '../enumeration/grouping_state.dart';

// A GroupDefinition is a factory that can produce named ObjectContainers
// (groups of objects). Used for dynamic groupings based on FACT/FACTSET data.
abstract interface class GroupDefinition<T> {
  GroupingState getGroupingState();
  Type getReferenceClass();
  dynamic getChoiceActor();
  String getLSTformat(dynamic context, dynamic obj);
  dynamic getPrimitive(dynamic context, String value);
}
