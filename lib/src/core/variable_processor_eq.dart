import 'equipment.dart';
import 'player_character.dart';
import 'variable_processor.dart';

// Variable processor for equipment-scoped variables.
class VariableProcessorEq extends VariableProcessor {
  final Equipment eq;
  final bool primaryHead;

  VariableProcessorEq(this.eq, PlayerCharacter pc, this.primaryHead)
      : super(pc);

  @override
  double? getInternalVariable(dynamic aSpell, String valString, String src) {
    // stub — EvaluatorFactory.EQ not yet available
    return null;
  }
}
