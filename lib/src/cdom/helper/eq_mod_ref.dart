//
// Copyright (c) 2008 Tom Parker <thpr@users.sourceforge.net>
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
// Translation of pcgen.cdom.helper.EqModRef
import '../reference/cdom_single_ref.dart';
import '../../core/equipment_modifier.dart';

// A reference to a specific EquipmentModifier with optional choice associations.
class EqModRef {
  final CDOMSingleRef<EquipmentModifier> eqMod;
  List<String>? _choices;

  EqModRef(this.eqMod);

  void addChoice(String choice) {
    _choices ??= [];
    _choices!.add(choice);
  }

  CDOMSingleRef<EquipmentModifier> getRef() => eqMod;

  List<String> getChoices() => _choices == null ? const [] : List.of(_choices!);

  @override
  bool operator ==(Object obj) {
    if (obj is! EqModRef) return false;
    if (eqMod != obj.eqMod) return false;
    return _choices == obj._choices;
  }

  @override
  int get hashCode => 3 - eqMod.hashCode;
}
