//
// Copyright 2008 (C) Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.reference.Qualifier
import 'package:flutter_pcgen/src/cdom/base/loadable.dart';
import 'cdom_single_ref.dart';

// Identifies a specific Loadable instance to bypass prerequisites or establish
// other relationships (e.g. QUALIFY token).
class Qualifier {
  final CDOMSingleRef<Loadable> _qualRef;

  Qualifier(CDOMSingleRef<Loadable> ref) : _qualRef = ref;

  CDOMSingleRef<Loadable> getQualifiedReference() => _qualRef;

  @override
  int get hashCode => _qualRef.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is Qualifier) {
      return _qualRef == other._qualRef;
    }
    return false;
  }
}
