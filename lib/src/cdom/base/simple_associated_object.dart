//
// Copyright 2007, 2008 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.base.SimpleAssociatedObject
import 'package:flutter_pcgen/src/cdom/enumeration/association_key.dart';
import 'package:flutter_pcgen/src/cdom/base/association_support.dart';
import 'package:flutter_pcgen/src/cdom/base/associated_prereq_object.dart';
import 'package:flutter_pcgen/src/cdom/base/concrete_prereq_object.dart';

// Minimal implementation of AssociatedPrereqObject combining prereqs and associations.
class SimpleAssociatedObject extends ConcretePrereqObject implements AssociatedPrereqObject {
  final AssociationSupport _assoc = AssociationSupport();

  @override
  void setAssociation<T>(AssociationKey<T> key, T value) => _assoc.setAssociation(key, value);

  @override
  T? getAssociation<T>(AssociationKey<T> key) => _assoc.getAssociation(key);

  @override
  List<AssociationKey<dynamic>> getAssociationKeys() => _assoc.getAssociationKeys();

  @override
  bool hasAssociations() => _assoc.hasAssociations();

  @override
  bool operator ==(Object other) {
    if (other is SimpleAssociatedObject) {
      return _assoc == other._assoc && equalsPrereqObject(other);
    }
    return false;
  }

  @override
  int get hashCode => _assoc.hashCode;
}
