import '../../base/util/map_to_list.dart';
import '../../cdom/base/associated_prereq_object.dart';

abstract interface class AssociatedChanges<T> {
  bool includesGlobalClear();

  List<T>? getAdded();

  List<T>? getRemoved();

  MapToList<T, AssociatedPrereqObject>? getAddedAssociations();

  MapToList<T, AssociatedPrereqObject>? getRemovedAssociations();
}
