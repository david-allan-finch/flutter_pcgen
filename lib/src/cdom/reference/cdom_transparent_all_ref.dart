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
// Translation of pcgen.cdom.reference.CDOMTransparentAllRef
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';
import 'cdom_group_ref.dart';
import 'reference_manufacturer.dart';
import 'transparent_reference.dart';

// A CDOMGroupRef representing ALL objects of a type; resolved transparently
// from a ReferenceManufacturer and can be re-resolved across campaign loads.
class CDOMTransparentAllRef<T extends Loadable> extends CDOMReference<T>
    implements CDOMGroupRef<T>, TransparentReference<T> {
  final Type _refClass;
  final String _formatRepresentation;
  CDOMGroupRef<T>? _subReference;

  CDOMTransparentAllRef(String formatRepresentation, Type objClass)
      : _refClass = objClass,
        _formatRepresentation = formatRepresentation,
        super('ALL');

  @override
  bool contains(T item) {
    if (_subReference == null) {
      throw StateError('Cannot ask for contains: ${getReferenceClass()} '
          'Reference ${getName()} has not been resolved');
    }
    return _subReference!.contains(item);
  }

  @override
  String getLSTformat([bool useAny = false]) =>
      _subReference?.getLSTformat(joinWith) ?? 'ALL';

  @override
  void addResolution(T item) {
    throw StateError('Cannot resolve a Transparent Reference');
  }

  @override
  void resolve(ReferenceManufacturer<T> rm) {
    if (rm.getReferenceClass() == getReferenceClass()) {
      _subReference = rm.getAllReference();
    } else {
      throw ArgumentError('Cannot resolve a ${getReferenceClass()} '
          'Reference to a ${rm.getReferenceClass()}');
    }
  }

  @override
  List<T> getContainedObjects() => _subReference!.getContainedObjects();

  @override
  int getObjectCount() => _subReference?.getObjectCount() ?? 0;

  @override
  GroupingState getGroupingState() => GroupingState.allowsNone;

  @override
  String? getChoice() => _subReference?.getChoice();

  @override
  Type getReferenceClass() => _refClass;

  @override
  String getReferenceDescription() => _subReference == null
      ? 'ALL ${_refClass}'
      : _subReference!.getReferenceDescription();

  @override
  String getPersistentFormat() => _formatRepresentation;

  @override
  bool operator ==(Object other) {
    if (other is CDOMTransparentAllRef<T>) {
      return getReferenceClass() == other.getReferenceClass() &&
          getName() == other.getName();
    }
    return false;
  }

  @override
  int get hashCode => getReferenceClass().hashCode ^ getName().hashCode;
}
