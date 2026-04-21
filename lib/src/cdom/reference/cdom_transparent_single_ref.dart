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
// Translation of pcgen.cdom.reference.CDOMTransparentSingleRef
import 'package:flutter_pcgen/src/cdom/base/cdom_reference.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/grouping_state.dart';
import 'cdom_single_ref.dart';
import 'reference_manufacturer.dart';
import 'transparent_reference.dart';

// A CDOMSingleRef that delegates to another CDOMSingleRef which is set at
// resolve time. Can be re-resolved, making it usable across different
// campaign loads under the same game mode.
class CDOMTransparentSingleRef<T extends Loadable> extends CDOMReference<T>
    implements CDOMSingleRef<T>, TransparentReference<T> {
  final Type _refClass;
  final String _formatRepresentation;
  CDOMSingleRef<T>? _subReference;

  CDOMTransparentSingleRef(
      String formatRepresentation, Type objClass, String key)
      : _refClass = objClass,
        _formatRepresentation = formatRepresentation,
        super(key);

  @override
  bool contains(T item) {
    if (_subReference == null) {
      throw StateError('Cannot ask for contains: ${getReferenceClass()} '
          'Reference ${getName()} has not been resolved');
    }
    return _subReference!.contains(item);
  }

  @override
  T get() {
    if (_subReference == null) {
      throw StateError('Cannot ask for resolution: Reference has not been resolved');
    }
    return _subReference!.get();
  }

  @override
  bool hasBeenResolved() =>
      _subReference != null && _subReference!.hasBeenResolved();

  @override
  String getLSTformat([bool useAny = false]) => getName();

  @override
  void addResolution(T item) {
    throw StateError('Cannot resolve a Transparent Reference');
  }

  @override
  void resolve(ReferenceManufacturer<T> rm) {
    if (rm.getReferenceClass() == getReferenceClass()) {
      _subReference = rm.getReference(getName());
    } else {
      throw ArgumentError('Cannot resolve a ${getReferenceClass()} '
          'Reference to a ${rm.getReferenceClass()}');
    }
  }

  @override
  List<T> getContainedObjects() => _subReference!.getContainedObjects();

  @override
  int getObjectCount() => _subReference != null ? 1 : 0;

  @override
  GroupingState getGroupingState() => GroupingState.allowsUnion;

  @override
  String? getChoice() => _subReference?.getChoice();

  @override
  void setChoice(String choice) {
    throw StateError('Cannot set Choice on a Transparent Reference');
  }

  @override
  Type getReferenceClass() => _refClass;

  @override
  String getReferenceDescription() => _subReference == null
      ? '${_refClass} ${getName()}'
      : _subReference!.getReferenceDescription();

  @override
  String getPersistentFormat() => _formatRepresentation;

  @override
  bool operator ==(Object other) {
    if (other is CDOMTransparentSingleRef<T>) {
      return getReferenceClass() == other.getReferenceClass() &&
          getName() == other.getName();
    }
    return false;
  }

  @override
  int get hashCode => getReferenceClass().hashCode ^ getName().hashCode;
}
