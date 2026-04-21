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
// Translation of pcgen.cdom.reference.ManufacturableFactory
import 'package:flutter_pcgen/src/cdom/base/class_identity.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';
import 'package:flutter_pcgen/src/cdom/reference/reference_manufacturer.dart';
import 'package:flutter_pcgen/src/cdom/reference/selection_creator.dart';
import 'package:flutter_pcgen/src/cdom/reference/unconstructed_validator.dart';

// A ManufacturableFactory is a factory for Loadable objects, combining
// SelectionCreator capability with direct object construction.
abstract interface class ManufacturableFactory<T extends Loadable>
    implements SelectionCreator<T> {
  // Constructs a new instance of the object this factory creates.
  T newInstance();

  // Returns true if the given item could have been created by this factory.
  bool isMember(T item);

  // Resolves the given CDOMSingleRef with the named object from the given
  // manufacturer, consulting the validator for permissible errors.
  bool resolve(ReferenceManufacturer<T> rm, String name,
      CDOMSingleRef<T> reference, UnconstructedValidator validator);

  // Populates the given manufacturer with references from the parent
  // manufacturer (for hierarchical Category objects).
  bool populate(ReferenceManufacturer<T> parent, ReferenceManufacturer<T> rm,
      UnconstructedValidator validator);

  // Returns the parent ManufacturableFactory, or null if none.
  ManufacturableFactory<T>? getParent();

  // Returns the persistent format string for the objects created by this factory.
  String getPersistentFormat();

  // Returns the ClassIdentity for this factory.
  // WARNING: may not be valid until after load is complete.
  @override
  ClassIdentity<T> getReferenceIdentity();
}
