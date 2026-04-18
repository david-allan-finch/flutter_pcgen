// Translation of pcgen.output.actor.OutputNameActor

import '../base/output_actor.dart';

/// OutputActor that returns the output name of an object
/// (falls back to display name if no output name is set).
class OutputNameActor implements OutputActor<dynamic> {
  const OutputNameActor();

  @override
  dynamic process(String charId, dynamic obj) {
    final outputName = obj?.getOutputName();
    if (outputName != null && outputName.isNotEmpty) return outputName;
    return obj?.getDisplayName() ?? '';
  }
}
