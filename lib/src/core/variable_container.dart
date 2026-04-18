import 'player_character.dart';

// Functional interface for objects that expose named variable values.
abstract interface class VariableContainer {
  double getVariableValue(
      String varName, String src, PlayerCharacter aPC);
}
