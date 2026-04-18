import '../../core/player_character.dart';

// Converts a SpecialAbility to its parsed text string for a PlayerCharacter.
class SAtoStringProcessor {
  final PlayerCharacter _pc;

  SAtoStringProcessor(PlayerCharacter pc) : _pc = pc;

  String act(dynamic sa, Object source) =>
      sa.getParsedText(_pc, _pc, source);
}
