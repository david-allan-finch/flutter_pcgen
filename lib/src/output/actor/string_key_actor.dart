// Translation of pcgen.output.actor.StringKeyActor

import '../base/output_actor.dart';

/// OutputActor that reads a StringKey value from an object.
class StringKeyActor implements OutputActor<dynamic> {
  final dynamic _stringKey;

  StringKeyActor(this._stringKey);

  @override
  dynamic process(String charId, dynamic obj) => obj?.get(_stringKey) ?? '';
}
