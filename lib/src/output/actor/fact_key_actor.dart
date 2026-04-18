// Translation of pcgen.output.actor.FactKeyActor

import '../base/output_actor.dart';

/// OutputActor that reads a Fact key value from an object.
class FactKeyActor<T> implements OutputActor<dynamic> {
  final dynamic _factKey;

  FactKeyActor(this._factKey);

  @override
  dynamic process(String charId, dynamic obj) => obj?.get(_factKey);
}
