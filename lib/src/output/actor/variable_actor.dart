// Translation of pcgen.output.actor.VariableActor

import '../base/output_actor.dart';

/// OutputActor that evaluates a variable expression on an object.
class VariableActor implements OutputActor<dynamic> {
  final String _varName;

  VariableActor(this._varName);

  @override
  dynamic process(String charId, dynamic obj) {
    // TODO: evaluate variable via PC variable system
    return obj?.getVariableValue(_varName, '') ?? 0.0;
  }
}
