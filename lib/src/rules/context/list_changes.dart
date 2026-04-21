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
// Translation of pcgen.rules.context.ListChanges
import 'package:flutter_pcgen/src/base/util/map_to_list.dart';
import 'package:flutter_pcgen/src/base/util/hash_map_to_list.dart';
import 'package:flutter_pcgen/src/cdom/base/associated_prereq_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_list.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/association_key.dart';
import 'package:flutter_pcgen/src/rules/context/associated_changes.dart';

// TODO: ReferenceUtilities (REFERENCE_SORTER comparator) not yet translated.
// The sorted TreeSet behaviour from Java is approximated with a plain List here;
// once ReferenceUtilities is available the sort comparator can be applied.

class ListChanges<T extends CDOMObject>
    implements AssociatedChanges<CDOMReference<T>> {
  final String _tokenName;
  final CDOMObject? _positive;
  final CDOMObject? _negative;
  final CDOMReference<CDOMList<T>> _list;
  final bool _clear;

  ListChanges(
    String token,
    CDOMObject? added,
    CDOMObject? removed,
    CDOMReference<CDOMList<T>> listref,
    bool globallyCleared,
  )   : _tokenName = token,
        _positive = added,
        _negative = removed,
        _list = listref,
        _clear = globallyCleared;

  @override
  bool includesGlobalClear() => _clear;

  // TODO: This lies because it doesn't analyse _tokenName (same caveat as Java source).
  bool isEmpty() => !_clear && !hasAddedItems() && !hasRemovedItems();

  @override
  List<CDOMReference<T>>? getAdded() {
    if (_positive == null) return null;
    final List<CDOMReference<T>> result = [];
    // TODO: CDOMObject.getListMods / getListAssociations not yet translated.
    // Placeholder — returns empty list until those methods are available.
    return result;
  }

  // TODO: This lies because it doesn't analyse _tokenName (same caveat as Java source).
  bool hasAddedItems() {
    if (_positive == null) return false;
    // TODO: CDOMObject.getListMods not yet translated.
    return false;
  }

  @override
  List<CDOMReference<T>>? getRemoved() {
    final List<CDOMReference<T>> result = [];
    if (_negative == null) return result;
    // TODO: CDOMObject.getListMods / getListAssociations not yet translated.
    return result;
  }

  // TODO: This lies because it doesn't analyse _tokenName (same caveat as Java source).
  bool hasRemovedItems() {
    if (_negative == null) return false;
    // TODO: CDOMObject.getListMods not yet translated.
    return false;
  }

  @override
  MapToList<CDOMReference<T>, AssociatedPrereqObject>? getAddedAssociations() {
    if (_positive == null) return null;
    // TODO: CDOMObject.getListMods / getListAssociations not yet translated.
    // When available: iterate mods, filter by AssociationKey.token == _tokenName,
    // populate a HashMapToList sorted by ReferenceUtilities.REFERENCE_SORTER.
    final MapToList<CDOMReference<T>, AssociatedPrereqObject> owned =
        HashMapToList();
    if (owned.isEmpty()) return null;
    return owned;
  }

  @override
  MapToList<CDOMReference<T>, AssociatedPrereqObject>? getRemovedAssociations() {
    // TODO: CDOMObject.getListMods / getListAssociations not yet translated.
    final MapToList<CDOMReference<T>, AssociatedPrereqObject> owned =
        HashMapToList();
    if (_negative == null) return owned;
    // When available: iterate mods, filter by AssociationKey.token == _tokenName,
    // populate owned; return null if empty.
    if (owned.isEmpty()) return null;
    return owned;
  }
}
