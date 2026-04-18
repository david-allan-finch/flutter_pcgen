// Translation of pcgen.output.actor.InfoActor

import '../base/output_actor.dart';

/// OutputActor that reads an INFO value from an object.
class InfoActor implements OutputActor<dynamic> {
  final String _infoKey;

  InfoActor(this._infoKey);

  @override
  dynamic process(String charId, dynamic obj) {
    // TODO: look up INFO value from object
    return obj?.getInfo(_infoKey) ?? '';
  }
}
