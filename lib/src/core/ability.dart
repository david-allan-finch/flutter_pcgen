//
// Ability.java Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
//
// This library is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
// PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with this
// library; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite
// 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.Ability
import 'package:flutter_pcgen/src/cdom/base/categorized.dart';
import 'package:flutter_pcgen/src/cdom/base/category.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/integer_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/core/ability_category.dart';
import 'package:flutter_pcgen/src/core/pcobject.dart';

/// Definition and game rules for an Ability (feat, special ability, etc).
final class Ability extends PObject implements Categorized<Ability> {
  Category<Ability>? _category;

  String getCategory() => _category?.getKeyName() ?? '';

  @override
  Category<Ability>? getCDOMCategory() => _category;
  @override
  void setCDOMCategory(Category<Ability> cat) { _category = cat; }

  void clearCDOMCategory() { _category = null; }

  /// Returns true if this ability can be taken multiple times.
  bool isMult() =>
      getSafeObject(ObjectKey.getConstant<bool>('MULT', defaultValue: false)) as bool? ?? false;

  /// Returns true if multiple copies of this ability stack.
  bool isStackable() =>
      getSafeObject(ObjectKey.getConstant<bool>('STACK', defaultValue: false)) as bool? ?? false;

  /// Returns the cost of this ability in pool points.
  double getCost() =>
      (getSafeObject(ObjectKey.getConstant<dynamic>('COST')) as num?)?.toDouble() ?? 1.0;

  /// Returns all description keys used by this ability.
  List<dynamic> getDescriptionKey() =>
      getSafeListFor<dynamic>(ListKey.getConstant<dynamic>('DESCRIPTION'));

  /// Returns all type strings.
  List<String> getTypes() =>
      getSafeListFor<String>(ListKey.getConstant<String>('TYPE'));

  int compareTo(Object other) {
    if (other is Ability) return getKeyName().compareTo(other.getKeyName());
    return -1;
  }

  @override
  bool operator ==(Object other) =>
      other is Ability && getKeyName().toLowerCase() == other.getKeyName().toLowerCase();

  @override
  int get hashCode => getKeyName().toLowerCase().hashCode;

  @override
  Ability clone() {
    final copy = Ability();
    copy.setDisplayName(getDisplayName());
    copy.setKeyName(getKeyName());
    copy._category = _category;
    return copy;
  }

  String getPCCText() => getKeyName();
}
