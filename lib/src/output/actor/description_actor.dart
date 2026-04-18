// Translation of pcgen.output.actor.DescriptionActor

import '../base/output_actor.dart';

/// OutputActor that extracts a list of descriptions from a PObject.
class DescriptionActor implements OutputActor<dynamic> {
  final dynamic _listKey;

  DescriptionActor(this._listKey);

  @override
  dynamic process(String charId, dynamic obj) {
    final descriptions = obj?.getSafeListFor(_listKey) ?? [];
    // TODO: resolve descriptions against PlayerCharacter (from charId)
    return descriptions
        .map((d) => d?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .join(', ');
  }
}
