import '../../cdom/base/associated_prereq_object.dart';
import '../../cdom/base/cdom_list.dart';
import '../../cdom/base/cdom_object.dart';
import '../../cdom/base/cdom_reference.dart';
import 'associated_changes.dart';
import 'changes.dart';

abstract interface class ListCommitStrategy {
  /// Create a new AssociatedPrereqObject for the owner and link it to the
  /// list. The type of link is characterised by the token, which is normally
  /// the LSTToken that would define the link (e.g. CLASSES to define a
  /// spell's membership in a ClassSpellList).
  AssociatedPrereqObject addToMasterList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> list,
    CDOMObject allowed,
  );

  void removeFromMasterList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> list,
    CDOMObject allowed,
  );

  Changes<CDOMReference<dynamic>> getMasterListChanges(
    String tokenName,
    CDOMObject owner,
    Type cl,
  );

  bool hasMasterLists();

  AssociatedChanges<CDOMObject> getChangesInMasterList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> swl,
  );

  AssociatedPrereqObject addToList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> list,
    CDOMReference<CDOMObject> allowed,
  );

  List<CDOMReference<CDOMList<dynamic>>> getChangedLists(
    CDOMObject owner,
    Type cl,
  );

  void removeAllFromList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<dynamic>> swl,
  );

  AssociatedPrereqObject removeFromList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> swl,
    CDOMReference<CDOMObject> ref,
  );

  AssociatedChanges<CDOMReference<CDOMObject>> getChangesInList(
    String tokenName,
    CDOMObject owner,
    CDOMReference<CDOMList<CDOMObject>> swl,
  );

  void setSourceURI(String? sourceURI);

  void setExtractURI(String? extractURI);

  void clearAllMasterLists(String tokenName, CDOMObject owner);

  bool equalsTracking(ListCommitStrategy commit);
}
