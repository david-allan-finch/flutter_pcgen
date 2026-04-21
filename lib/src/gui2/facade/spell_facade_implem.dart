// Translation of pcgen.gui2.facade.SpellFacadeImplem

import '../../facade/core/spell_facade.dart';

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
