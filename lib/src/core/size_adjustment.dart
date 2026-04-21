//
// Copyright 2001 (C) Greg Bingleman <byngl@hotmail.com>
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
// Translation of pcgen.core.SizeAdjustment
import '../cdom/enumeration/string_key.dart';
import 'pcobject.dart';

/// Represents a size category (Fine, Diminutive, Tiny, Small, Medium, Large, etc).
///
/// Translated from pcgen.core.SizeAdjustment. Provides size-based bonus
/// activation and scoping under "PC.SIZE".
final class SizeAdjustment extends PObject {
  String? getSortKey() => get(StringKey.sortKey);

  /// Returns the local scope name for variable resolution.
  String getLocalScopeName() => 'PC.SIZE';

  /// Activates bonuses and returns all active BonusObj list.
  /// [aPC] is a dynamic reference to PlayerCharacter.
  List<dynamic> getActiveBonuses(dynamic aPC) {
    // BonusActivation.activateBonuses(this, aPC) would run here in full impl
    return [];
  }

  @override
  String toString() => getDisplayName();
}
