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
// Translation of pcgen.cdom.reference.CDOMTransparentTypeRef
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_group_ref.dart';
import 'package:flutter_pcgen/src/cdom/reference/reference_manufacturer.dart';
import 'package:flutter_pcgen/src/cdom/reference/transparent_reference.dart';

// A CDOMGroupRef that contains objects matching specific types; resolved
// transparently from a ReferenceManufacturer and can be re-resolved across
// campaign loads.
class CDOMTransparentTypeRef<T extends Loadable> extends CDOMReference<T>
    implements CDOMGroupRef<T>, TransparentReference<T> {
  final Type _refClass;
  final String _formatRepresentation;
  final List<String> _types;
  CDOMGroupRef<T>? _subReference;

  CDOMTransparentTypeRef(
      String formatRepresentation, Type objClass, List<String> typeArray)
      : _refClass = objClass,
        _formatRepresentation = formatRepresentation,
        _types = List.unmodifiable(typeArray),
        super('${objClass} $typeArray');

  @override
  bool contains(T item) {
    if (_subReference == null) {
      throw StateError('Cannot ask for contains: ${getReferenceClass()} '
          'Reference ${getName()} has not been resolved');
    }
    return _subReference!.contains(item);
  }

  @override
  String getLSTformat([bool useAny = false]) => getName();

  @override
  void addResolution(T item) {
    throw StateError('Cannot resolve a Transparent Reference');
  }

  @override
  void resolve(ReferenceManufacturer<T> rm) {
    if (rm.getReferenceClass() == getReferenceClass()) {
      _subReference = rm.getTypeReference(_types);
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
  GroupingState getGroupingState() => GroupingState.any;

  @override
  String? getChoice() => _subReference?.getChoice();

  @override
  Type getReferenceClass() => _refClass;

  @override
  String getReferenceDescription() => _subReference == null
      ? '${_refClass} of TYPE=$_types'
      : _subReference!.getReferenceDescription();

  @override
  String getPersistentFormat() => _formatRepresentation;

  @override
  bool operator ==(Object other) {
    if (other is CDOMTransparentTypeRef<T>) {
      return getReferenceClass() == other.getReferenceClass() &&
          getName() == other.getName();
    }
    return false;
  }

  @override
  int get hashCode => getReferenceClass().hashCode ^ getName().hashCode;
}
