//
// Copyright (c) 2010 Tom Parker <thpr@users.sourceforge.net>
// Copyright 2006 (C) Aaron Divinsky <boomer70@yahoo.com>
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
// Translation of pcgen.core.AbilityCategory
import 'package:flutter_pcgen/src/core/ability.dart';

// Stores and manages information about Ability categories (e.g., FEAT, SPECIAL_ABILITY).
class AbilityCategory {
  static final AbilityCategory feat = AbilityCategory._('FEAT', 'Feat', 'Feats');
  static final AbilityCategory specialAbility = AbilityCategory._('SPECIAL_ABILITY', 'Special Ability', 'Special Abilities');
  static final AbilityCategory trait = AbilityCategory._('TRAIT', 'Trait', 'Traits');
  static final AbilityCategory internalVirtualCategory = AbilityCategory._('INTERNAL_VIRTUAL', 'Internal Virtual', 'Internal Virtual');

  static final Map<String, AbilityCategory> _registry = {};

  static AbilityCategory? get(String key) => _registry[key.toUpperCase()];

  static AbilityCategory getConstant(String key) {
    return _registry[key.toUpperCase()] ??
        (throw ArgumentError('Unknown ability category: $key'));
  }

  final String _keyName;
  String _displayName;
  String _pluralName;
  String? _sourceURI;

  bool _editable = false;
  bool _editPool = false;
  bool _fractionalPool = false;
  bool _visible = true;

  // Types that restrict what abilities belong to this category
  final Set<String> _types = {};

  // The abilities that belong to this category
  final List<Ability> _abilities = [];

  AbilityCategory._(this._keyName, this._displayName, this._pluralName) {
    _registry[_keyName.toUpperCase()] = this;
  }

  factory AbilityCategory(String keyName, {String? displayName, String? pluralName}) {
    final existing = _registry[keyName.toUpperCase()];
    if (existing != null) return existing;
    return AbilityCategory._(keyName, displayName ?? keyName, pluralName ?? '$keyName s');
  }

  String getKeyName() => _keyName;
  String getDisplayName() => _displayName;
  void setDisplayName(String name) { _displayName = name; }

  String getPluralName() => _pluralName;
  void setPluralName(String name) { _pluralName = name; }

  String? getSourceURI() => _sourceURI;
  void setSourceURI(String? uri) { _sourceURI = uri; }

  bool isEditable() => _editable;
  void setEditable(bool editable) { _editable = editable; }

  bool isEditPool() => _editPool;
  void setEditPool(bool editPool) { _editPool = editPool; }

  bool isFractionalPool() => _fractionalPool;
  void setFractionalPool(bool fractional) { _fractionalPool = fractional; }

  bool isVisible() => _visible;
  void setVisible(bool visible) { _visible = visible; }

  void addAbilityType(String type) { _types.add(type.toUpperCase()); }
  Set<String> getTypes() => Set.unmodifiable(_types);

  List<Ability> getAbilities() => List.unmodifiable(_abilities);
  void addAbility(Ability ability) { _abilities.add(ability); }
  void removeAbility(Ability ability) { _abilities.remove(ability); }

  @override
  String toString() => _displayName;

  @override
  bool operator ==(Object other) =>
      other is AbilityCategory &&
      _keyName.toLowerCase() == other._keyName.toLowerCase();

  @override
  int get hashCode => _keyName.toLowerCase().hashCode;
}
