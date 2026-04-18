import 'player_character.dart';
import 'term/evaluator_factory.dart';
import 'variable_processor.dart';

// Variable processor for player-character-scoped variables.
class VariableProcessorPC extends VariableProcessor {
  VariableProcessorPC(PlayerCharacter pc) : super(pc);

  @override
  double? getInternalVariable(dynamic aSpell, String valString, String src) {
    final evaluator = EvaluatorFactory.pc.getTermEvaluator(valString, src);
    if (evaluator == null) return null;
    return evaluator.resolve(pc, aSpell);
  }
}
