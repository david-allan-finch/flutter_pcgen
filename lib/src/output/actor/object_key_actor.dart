// Translation of pcgen.output.actor.ObjectKeyActor

import '../base/output_actor.dart';

/// OutputActor that reads an ObjectKey value from an object.
class ObjectKeyActor<T> implements OutputActor<dynamic> {
  final dynamic _objectKey;

  ObjectKeyActor(this._objectKey);

  @override
  dynamic process(String charId, dynamic obj) => obj?.get(_objectKey);
}
