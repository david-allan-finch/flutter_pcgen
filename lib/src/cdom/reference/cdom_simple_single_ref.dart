//
// Copyright (c) 2007-18 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under
// the terms of the GNU Lesser General Public License as published by the Free
// Software Foundation; either version 2.1 of the License, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
// details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.reference.CDOMSimpleSingleRef
import 'package:flutter_pcgen/src/cdom/base/class_identity.dart';
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';
import 'cdom_single_ref.dart';

// A CDOMSingleRef for non-categorized objects, resolved by key name.
class CDOMSimpleSingleRef<T> extends CDOMReference<T>
    implements CDOMSingleRef<T> {
  final ClassIdentity<T> _identity;
  T? _referencedObject;
  String? _choice;

  CDOMSimpleSingleRef(ClassIdentity<T> identity, String key)
      : _identity = identity,
        super(key);

  @override
  bool contains(T item) {
    if (_referencedObject == null) {
      throw StateError('Cannot ask for contains: ${getReferenceClass()} '
          'Reference ${getName()} has not been resolved');
    }
    return _referencedObject == item;
  }

  @override
  T get() {
    if (_referencedObject == null) {
      throw StateError(
          'Cannot ask for resolution: Reference ${getName()} has not been resolved');
    }
    return _referencedObject!;
  }

  @override
  bool hasBeenResolved() => _referencedObject != null;

  @override
  String getLSTformat([bool useAny = false]) => getName();

  @override
  void addResolution(T item) {
    if (_referencedObject != null) {
      throw StateError('Cannot resolve a Single Reference twice');
    }
    _referencedObject = item;
  }

  @override
  List<T> getContainedObjects() {
    if (_referencedObject == null) {
      throw StateError('Cannot ask for contained objects: '
          '${getReferenceClass()} Reference ${getName()} has not been resolved');
    }
    return [_referencedObject!];
  }

  @override
  int getObjectCount() => _referencedObject != null ? 1 : 0;

  @override
  GroupingState getGroupingState() => GroupingState.allowsUnion;

  @override
  void setChoice(String choice) => _choice = choice;

  @override
  String? getChoice() => _choice;

  @override
  Type getReferenceClass() => _identity.getReferenceClass();

  @override
  String getReferenceDescription() =>
      '${_identity.getReferenceDescription()} ${getName()}';

  @override
  String getPersistentFormat() => _identity.getPersistentFormat();

  @override
  bool operator ==(Object other) {
    if (other is CDOMSimpleSingleRef<T>) {
      return getReferenceClass() == other.getReferenceClass() &&
          getName() == other.getName();
    }
    return false;
  }

  @override
  int get hashCode => getReferenceClass().hashCode ^ getName().hashCode;
}
