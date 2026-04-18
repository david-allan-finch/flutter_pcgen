import '../enumeration/grouping_state.dart';

// A named collection of selectable objects for the CHOOSE system.
abstract interface class SelectableSet<T> {
  String getLSTformat();
  Type getChoiceClass();
  String getName();
  GroupingState getGroupingState();
  String getTitle();
  void setTitle(String title);
  List<T> getSet(dynamic pc);
}
