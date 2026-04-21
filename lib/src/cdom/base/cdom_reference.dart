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
// Translation of pcgen.cdom.base.CDOMReference
import '../enumeration/grouping_state.dart';

// Stub interfaces for types not yet translated
abstract interface class ObjectContainer<T> {
  List<T> getContainedObjects();
}

abstract interface class Converter<T, R> {
  List<R> convert(ObjectContainer<T> container);
}

abstract interface class PrimitiveCollection<T> {
  GroupingState getGroupingState();
  String getLSTformat(bool useAny);
  Type getReferenceClass();
  List getCollection(dynamic pc, Converter c);
}

/// A CDOMReference stores references to Objects. Often these are CDOMObjects,
/// but that is not strictly required.
///
/// The intent is for a CDOMReference to be created in order to identify that a
/// reference was made to an object. The CDOMReference can later be resolved to
/// identify the exact Objects to which the CDOMReference refers.
abstract class CDOMReference<T>
    implements ObjectContainer<T>, PrimitiveCollection<T> {
  /// The name of this CDOMReference.
  final String _name;

  /// Whether this CDOMReference requires a target.
  bool _requiresTarget = false;

  /// Constructs a new CDOMReference with the given name.
  CDOMReference(String refName) : _name = refName;

  /// Returns the name of this CDOMReference.
  String getName() => _name;

  /// Adds an object to be included in the Collection of objects to which this
  /// CDOMReference refers.
  void addResolution(T item);

  /// Returns the count of the number of objects included in the Collection of
  /// Objects to which this CDOMReference refers.
  int getObjectCount();

  /// Returns a Collection containing the Objects to which this CDOMReference
  /// refers.
  @override
  List<T> getContainedObjects();

  /// Returns a description of the contents of this CDOMReference.
  String getReferenceDescription();

  @override
  List<R> getCollection<R>(dynamic pc, Converter<T, R> c) {
    return c.convert(this) as List<R>;
  }

  /// Returns the specific choice (association) for the Ability this
  /// CDOMReference contains.
  String? getChoice();

  /// Returns true if this CDOMReference requires a target.
  bool requiresTarget() => _requiresTarget;

  /// Sets whether this CDOMReference requires that it contains a target.
  void setRequiresTarget(bool required) {
    _requiresTarget = required;
  }

  /// Returns the persistent version of the ClassIdentity of the type of object
  /// that this CDOMReference contains.
  String getPersistentFormat();

  /// Returns true if the given item is contained within this CDOMReference.
  bool contains(T item);

  @override
  String toString() {
    return '${runtimeType} ${getReferenceClass()} ${getName()}';
  }
}
