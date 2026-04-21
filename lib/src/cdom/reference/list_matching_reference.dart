//
// Copyright James Dempsey, 2011
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.reference.ListMatchingReference
import 'package:flutter_pcgen/src/cdom/base/cdom_object.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'cdom_group_ref.dart';

// A CDOMReference that contains objects whose ListKey includes an expected value.
class ListMatchingReference<T extends CDOMObject, V>
    extends CDOMReference<T> {
  final CDOMGroupRef<T> _all;
  final ListKey<V> _key;
  final V? _value;

  ListMatchingReference(
      String unparse, CDOMGroupRef<T> startingGroup, ListKey<V> targetKey,
      [V? expectedValue])
      : _all = startingGroup,
        _key = targetKey,
        _value = expectedValue,
        super(unparse);

  @override
  bool contains(T item) {
    if (!_all.contains(item)) return false;
    final actualList = item.getListFor(_key);
    if (actualList == null) return false;
    return actualList.any((actual) => _value != null && _value == actual);
  }

  @override
  void addResolution(T item) {
    throw StateError('Cannot add resolution to ListMatchingReference');
  }

  @override
  List<T> getContainedObjects() {
    final list = <T>[];
    for (final obj in _all.getContainedObjects()) {
      final actualList = obj.getListFor(_key);
      if (actualList != null &&
          actualList.any((actual) => _value != null && _value == actual)) {
        list.add(obj);
      }
    }
    return list;
  }

  @override
  int getObjectCount() {
    int count = 0;
    for (final obj in _all.getContainedObjects()) {
      final actualList = obj.getListFor(_key);
      if (actualList != null &&
          actualList.any((actual) => _value != null && _value == actual)) {
        count++;
      }
    }
    return count;
  }

  @override
  String getLSTformat([bool useAny = false]) => getName();

  @override
  GroupingState getGroupingState() => GroupingState.any;

  @override
  String? getChoice() => null;

  @override
  Type getReferenceClass() => _all.getReferenceClass();

  @override
  String getReferenceDescription() =>
      '${_all.getReferenceDescription()} (List $_key = $_value)';

  @override
  String getPersistentFormat() => _all.getPersistentFormat();

  @override
  bool operator ==(Object other) {
    if (other is ListMatchingReference<T, V>) {
      if (getReferenceClass() == other.getReferenceClass() &&
          _all == other._all &&
          _key == other._key) {
        return _value == null ? other._value == null : _value == other._value;
      }
    }
    return false;
  }

  @override
  int get hashCode =>
      getReferenceClass().hashCode ^
      _key.hashCode +
          (_value == null ? -1 : _value.hashCode);
}
