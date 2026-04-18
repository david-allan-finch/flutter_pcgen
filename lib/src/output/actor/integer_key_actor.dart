// Translation of pcgen.output.actor.IntegerKeyActor

import '../base/output_actor.dart';

/// OutputActor that reads an IntegerKey value from an object.
class IntegerKeyActor implements OutputActor<dynamic> {
  final dynamic _integerKey;

  IntegerKeyActor(this._integerKey);

  @override
  dynamic process(String charId, dynamic obj) => obj?.get(_integerKey) ?? 0;
}
