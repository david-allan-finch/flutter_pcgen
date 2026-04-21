//
// Copyright 2002 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.    See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.PCStat
import 'package:flutter_pcgen/src/cdom/base/non_interactive.dart';
import 'package:flutter_pcgen/src/cdom/base/sort_key_required.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'pcobject.dart';

// Represents an ability score (STR, DEX, CON, etc.).
final class PCStat extends PObject
    implements NonInteractive, SortKeyRequired {
  @override
  String? getLocalScopeName() => 'PC.STAT';

  @override
  String toString() => getKeyName();

  @override
  String getSortKey() => getString(StringKey.sortKey) as String? ?? '';
}
