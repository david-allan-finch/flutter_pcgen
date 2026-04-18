// Translation of pcgen.output.actor.ListKeyActor

import '../base/output_actor.dart';

/// OutputActor that reads a ListKey value (list) from an object.
class ListKeyActor<T> implements OutputActor<dynamic> {
  final dynamic _listKey;

  ListKeyActor(this._listKey);

  @override
  dynamic process(String charId, dynamic obj) =>
      obj?.getSafeListFor(_listKey) ?? const [];
}
