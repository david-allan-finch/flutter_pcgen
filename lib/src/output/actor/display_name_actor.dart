// Translation of pcgen.output.actor.DisplayNameActor

import '../base/output_actor.dart';

/// OutputActor that returns the display name of an object.
class DisplayNameActor implements OutputActor<dynamic> {
  const DisplayNameActor();

  @override
  dynamic process(String charId, dynamic obj) => obj?.getDisplayName() ?? '';
}
