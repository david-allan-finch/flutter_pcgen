import 'associated_prereq_object.dart';
import 'cdom_list.dart';
import 'cdom_object.dart';
import 'cdom_reference.dart';

// MasterListInterface stores dataset-global associations between CDOMLists and
// CDOMObjects (e.g. class spell lists from the CLASSES: token).
abstract interface class MasterListInterface {
  /// Returns all active CDOMList references in the dataset.
  Set<CDOMReference<CDOMList>> getActiveLists();

  /// Returns associations for the given list reference and object.
  List<AssociatedPrereqObject> getAssociationsByRef<T extends CDOMObject>(
      CDOMReference<CDOMList<T>> key1, T key2);

  /// Returns associations for the given concrete list and object.
  List<AssociatedPrereqObject> getAssociationsByList<T extends CDOMObject>(
      CDOMList<T> key1, T key2);

  /// Returns all objects associated with the given CDOMList reference.
  List<T> getObjects<T extends CDOMObject>(CDOMReference<CDOMList<T>> ref);
}
