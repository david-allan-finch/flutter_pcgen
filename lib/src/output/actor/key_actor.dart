// Translation of pcgen.output.actor.KeyActor

import '../base/output_actor.dart';

/// OutputActor that returns the key name of an object.
class KeyActor implements OutputActor<dynamic> {
  const KeyActor();

  @override
  dynamic process(String charId, dynamic obj) => obj?.getKeyName() ?? '';
}
