//
// Copyright 2010 (C) Tom Parker <thpr@sourceforge.net>
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
// Translation of pcgen.cdom.reference.FilteredReference
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';
import 'cdom_group_ref.dart';
import 'cdom_single_ref.dart';

// A CDOMGroupRef that returns all objects from a base group reference except
// those matched by any of the prohibited single refs.
class FilteredReference<T> extends CDOMReference<T>
    implements CDOMGroupRef<T> {
  final Set<CDOMSingleRef<T>> _filterSet = {};
  final CDOMGroupRef<T> _baseSet;

  FilteredReference(CDOMGroupRef<T> allRef)
      : _baseSet = allRef,
        super('Filtered Reference');

  void addProhibitedItem(CDOMSingleRef<T> prohibitedRef) {
    _filterSet.add(prohibitedRef);
  }

  @override
  bool contains(T item) => getContainedObjects().contains(item);

  @override
  void addResolution(T item) {
    throw StateError('FilteredReference cannot be given a resolution');
  }

  @override
  List<T> getContainedObjects() {
    final choices = Set<T>.from(_baseSet.getContainedObjects());
    choices.removeWhere(
        (choice) => _filterSet.any((ref) => ref.contains(choice)));
    return choices.toList();
  }

  @override
  int getObjectCount() =>
      _baseSet.getContainedObjects().length - _filterSet.length;

  @override
  GroupingState getGroupingState() {
    var state = GroupingState.empty;
    for (final ref in _filterSet) {
      state = ref.getGroupingState().add(state);
    }
    return _filterSet.length == 1
        ? state
        : state.compound(GroupingState.allowsUnion);
  }

  @override
  String getLSTformat([String? joinWith]) {
    final sorted = _filterSet.map((r) => r.getLSTformat()).toList()..sort();
    return 'ALL|!${sorted.join('|!')}';
  }

  @override
  String? getChoice() => null;

  @override
  Type getReferenceClass() => _baseSet.getReferenceClass();

  @override
  String getReferenceDescription() {
    final excepts = _filterSet
        .map((r) => r.getReferenceDescription())
        .join(', ');
    return '${_baseSet.getReferenceDescription()} except: [$excepts]';
  }

  @override
  String getPersistentFormat() => _baseSet.getPersistentFormat();

  @override
  bool operator ==(Object other) {
    if (other is FilteredReference<T>) {
      return _baseSet == other._baseSet && _filterSet == other._filterSet;
    }
    return false;
  }

  @override
  int get hashCode => _baseSet.hashCode + _filterSet.length;
}
