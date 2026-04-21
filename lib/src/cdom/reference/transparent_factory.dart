//
// Copyright 2010 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.reference.TransparentFactory
import '../base/class_identity.dart';
import '../base/loadable.dart';
import 'cdom_group_ref.dart';
import 'cdom_single_ref.dart';
import 'cdom_transparent_all_ref.dart';
import 'cdom_transparent_single_ref.dart';
import 'cdom_transparent_type_ref.dart';
import 'manufacturable_factory.dart';
import 'reference_manufacturer.dart';
import 'unconstructed_validator.dart';

// A ManufacturableFactory that produces Transparent CDOMReferences (i.e.,
// references that will be re-resolved per campaign load, not directly resolved).
class TransparentFactory<T extends Loadable> implements ManufacturableFactory<T> {
  final Type _refClass;
  final String _formatRepresentation;

  TransparentFactory(String formatRepresentation, Type objClass)
      : _refClass = objClass,
        _formatRepresentation = formatRepresentation;

  @override
  CDOMGroupRef<T> getAllReference() =>
      CDOMTransparentAllRef<T>(_formatRepresentation, _refClass);

  @override
  CDOMGroupRef<T> getTypeReference(List<String> types) =>
      CDOMTransparentTypeRef<T>(_formatRepresentation, _refClass, types);

  @override
  CDOMSingleRef<T> getReference(String key) =>
      CDOMTransparentSingleRef<T>(_formatRepresentation, _refClass, key);

  @override
  T newInstance() {
    throw UnsupportedError('newInstance should not be called on TransparentFactory');
  }

  @override
  bool isMember(T item) => _refClass == item.runtimeType;

  @override
  Type getReferenceClass() => _refClass;

  @override
  String getReferenceDescription() => _refClass.toString();

  @override
  bool resolve(ReferenceManufacturer<T> rm, String name,
      CDOMSingleRef<T> reference, UnconstructedValidator validator) {
    throw UnsupportedError('Resolution should not occur on Transparent object');
  }

  @override
  bool populate(ReferenceManufacturer<T> parent, ReferenceManufacturer<T> rm,
      UnconstructedValidator validator) {
    return true;
  }

  @override
  ManufacturableFactory<T>? getParent() {
    throw UnsupportedError('Resolution of Parent should not occur on Transparent object');
  }

  @override
  ClassIdentity<T> getReferenceIdentity() {
    throw UnsupportedError('Resolution to Identity should not occur on Transparent object');
  }

  @override
  String getPersistentFormat() => _formatRepresentation;
}
