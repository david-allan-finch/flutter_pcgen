//
// Copyright 2018 (C) Tom Parker <thpr@users.sourceforge.net>
//
// This library is free software; you can redistribute it and/or modify it under the terms
// of the GNU Lesser General Public License as published by the Free Software Foundation;
// either version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License along with
// this library; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
// Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.cdom.helper.VarHolderSupport
// Standard implementation of VarHolder / VarContainer via delegation.
class VarHolderSupport {
  List<dynamic>? _modifierList; // List<VarModifier<?>>
  List<dynamic>? _remoteModifierList; // List<RemoteModifier<?>>
  List<String>? _grantedVars;

  void addModifier(dynamic vm) {
    _modifierList ??= [];
    _modifierList!.add(vm);
  }

  List<dynamic> getModifierArray() => _modifierList ?? const [];

  void addRemoteModifier(dynamic vm) {
    _remoteModifierList ??= [];
    _remoteModifierList!.add(vm);
  }

  List<dynamic> getRemoteModifierArray() => _remoteModifierList ?? const [];

  void addGrantedVariable(String variableName) {
    _grantedVars ??= [];
    _grantedVars!.add(variableName);
  }

  List<String> getGrantedVariableArray() => _grantedVars ?? const [];
}
