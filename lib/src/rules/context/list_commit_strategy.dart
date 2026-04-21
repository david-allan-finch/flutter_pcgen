//
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.rules.context.ListCommitStrategy
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
