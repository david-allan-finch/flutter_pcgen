// Translation of pcgen.gui2.facade.CharacterLevelFacadeImpl

import '../../facade/core/character_level_facade.dart';

/// Concrete implementation of CharacterLevelFacade wrapping a PCGen character level.
class CharacterLevelFacadeImpl implements CharacterLevelFacade {
  final dynamic _level;

  CharacterLevelFacadeImpl(this._level);

  @override
  dynamic getCharClass() => _level?.charClass;

  @override
  int getLevel() => (_level?.level as int?) ?? 0;

  @override
  String toString() {
    final cls = getCharClass();
    return '${cls?.toString() ?? 'Unknown'} ${getLevel()}';
  }
}
