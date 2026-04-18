// Translation of pcgen.output.actor.EqTypeActor

import '../base/output_actor.dart';

/// OutputActor that returns the type(s) of an equipment object.
class EqTypeActor implements OutputActor<dynamic> {
  const EqTypeActor();

  @override
  dynamic process(String charId, dynamic obj) {
    final types = obj?.getTypeList(true) ?? [];
    return types.map((t) => t.toString()).join('.');
  }
}
