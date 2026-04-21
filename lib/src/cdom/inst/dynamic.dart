//
// Copyright (c) 2016-18 Tom Parker <thpr@users.sourceforge.net>
//
// This program is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA 02110-1301, USA
//
// Translation of pcgen.cdom.inst.Dynamic
import '../../formula/base/var_scoped.dart';
import '../base/categorized.dart';
import '../base/category.dart';
import '../base/loadable.dart';
import '../base/var_holder.dart';
import '../content/remote_modifier.dart';
import '../content/var_modifier.dart';

// A Dynamic is a data-driven object with no hard-coded behaviors.
// It behaves as defined by the game data, backed by a variable holder.
class Dynamic implements Loadable, VarHolder, Categorized<Dynamic> {
  String? _sourceURI;
  Category<Dynamic>? _category;
  String? _name;

  final List<VarModifier> _modifiers = [];
  final List<RemoteModifier> _remoteModifiers = [];
  final List<String> _grantedVariables = [];

  @override
  String? getSourceURI() => _sourceURI;

  @override
  void setSourceURI(String? source) { _sourceURI = source; }

  @override
  void setName(String name) { _name = name; }

  @override
  String? getDisplayName() => _name;

  @override
  String? getKeyName() => _name;

  @override
  bool isInternal() => false;

  @override
  bool isType(String type) => false;

  @override
  Category<Dynamic>? getCDOMCategory() => _category;

  @override
  void setCDOMCategory(Category<Dynamic>? cat) { _category = cat; }

  String? getLocalScopeName() =>
      _category != null ? 'PC.${_category!.getKeyName()}' : null;

  VarScoped? getVariableParent() => null;

  @override
  void addModifier(VarModifier vm) { _modifiers.add(vm); }

  @override
  List<VarModifier> getModifierArray() => List.unmodifiable(_modifiers);

  @override
  void addRemoteModifier(RemoteModifier vm) { _remoteModifiers.add(vm); }

  @override
  List<RemoteModifier> getRemoteModifierArray() => List.unmodifiable(_remoteModifiers);

  @override
  void addGrantedVariable(String variableName) { _grantedVariables.add(variableName); }

  @override
  List<String> getGrantedVariableArray() => List.unmodifiable(_grantedVariables);

  @override
  String toString() =>
      '${_category?.getDisplayName() ?? ''}:${_name ?? ''}';
}
