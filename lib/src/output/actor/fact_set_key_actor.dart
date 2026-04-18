// Translation of pcgen.output.actor.FactSetKeyActor

import '../base/output_actor.dart';

/// OutputActor that reads a FactSet key (list) value from an object.
class FactSetKeyActor<T> implements OutputActor<dynamic> {
  final dynamic _factSetKey;

  FactSetKeyActor(this._factSetKey);

  @override
  dynamic process(String charId, dynamic obj) =>
      obj?.getSafeSetFor(_factSetKey) ?? const [];
}
