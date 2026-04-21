//
// Copyright 2007, 2008 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.base.MasterListInterface
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
