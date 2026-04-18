import '../../core/player_character.dart';

// Functional interface: an object that can be qualified against a PC.
abstract interface class QualifyingObject {
  bool qualifies(PlayerCharacter pc, Object? owner);
}
