// *
// Copyright James Dempsey, 2011
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
// Translation of pcgen.gui2.facade.SpellFacadeImplem

import 'package:flutter_pcgen/src/facade/core/spell_facade.dart';

/// Concrete implementation of SpellFacade wrapping a PCGen spell object.
class SpellFacadeImplem implements SpellFacade {
  final Map<String, dynamic> _spell;
  final dynamic _info;

  SpellFacadeImplem(this._spell, [this._info]);

  @override
  String getDisplayName() => _str('name');

  @override
  String getSchool() => _str('school');

  @override
  String getSubschool() => _str('subschool');

  @override
  String getDescriptor() => _str('descriptor');

  @override
  String getComponents() => _str('components');

  @override
  String getCastingTime() => _str('castingTime');

  @override
  String getRange() => _str('range');

  @override
  String getTarget() => _str('target');

  @override
  String getDuration() => _str('duration');

  @override
  String getSavingThrow() => _str('save');

  @override
  String getSpellResistance() => _str('sr');

  @override
  String getDescription() => _str('description');

  @override
  String getSource() => _str('source');

  @override
  int getLevel() => (_spell['level'] as num?)?.toInt() ?? 0;

  @override
  String toString() => getDisplayName();

  String _str(String key) => (_spell[key] as String?) ?? '';
}
