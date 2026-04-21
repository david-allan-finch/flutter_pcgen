//
// Copyright 2001 (C) Bryan McRoberts (merton_monk@yahoo.com)
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.Deity

import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/core/domain.dart';
import 'package:flutter_pcgen/src/core/pcobject.dart';

/// Represents a deity that a character can worship.
///
/// The deity's domains are stored in the DOMAINLIST list key.
/// Other properties (alignment, favoured weapons, worshippers) are held
/// via the standard CDOMObject key/value store inherited from PObject.
final class Deity extends PObject {
  static final ListKey<Domain> domainListKey =
      ListKey.getConstant<Domain>('DOMAIN_LIST');

  /// Returns the list of domains offered by this deity.
  List<Domain> getDomainList() =>
      getSafeListFor<Domain>(domainListKey);

  /// Returns the deity's favoured weapon key, if set.
  String? getFavWeaponKeyName() {
    final ref = getSafeObject(ObjectKey.getConstant<dynamic>('FAVORED_WEAPON'));
    return (ref as dynamic)?.get()?.getKeyName();
  }

  /// Returns a list of alignment strings this deity allows worshippers of.
  List<String> getAllowedAlignments() =>
      getSafeListFor<String>(ListKey.getConstant<String>('ALIGN'));

  @override
  String toString() => getDisplayName();
}
