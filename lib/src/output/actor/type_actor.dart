// Translation of pcgen.output.actor.TypeActor

import '../base/output_actor.dart';

/// OutputActor that returns the type list of an object as a dot-separated string.
class TypeActor implements OutputActor<dynamic> {
  const TypeActor();

  @override
  dynamic process(String charId, dynamic obj) {
    final types = obj?.getTypeList(true) ?? [];
    return types.map((t) => t.toString()).join('.');
  }
}
