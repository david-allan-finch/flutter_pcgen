//
// Copyright (c) 2007 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.reference.SelectionCreator
import 'package:flutter_pcgen/src/cdom/base/class_identity.dart';
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_group_ref.dart';
import 'package:flutter_pcgen/src/cdom/reference/cdom_single_ref.dart';

// A SelectionCreator can create various forms of CDOMReferences for a supported
// type of object (as identified by its ClassIdentity).
abstract interface class SelectionCreator<T extends Loadable> {
  // Returns a single-object reference for the given key.
  CDOMSingleRef<T> getReference(String key);

  // Returns a type-filtered group reference for the given types.
  CDOMGroupRef<T> getTypeReference(List<String> types);

  // Returns a reference to ALL objects of the represented type.
  CDOMGroupRef<T> getAllReference();

  // The runtime class of the represented type.
  Type getReferenceClass();

  // Human-readable description of the contents.
  String getReferenceDescription();

  // The ClassIdentity for this SelectionCreator.
  ClassIdentity<T> getReferenceIdentity();
}
