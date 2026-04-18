// Translation of pcgen.output.channel.compat.AlignmentCompat

import 'abstract_adapter.dart';

/// AlignmentCompat provides a writeable reference for the character's alignment channel.
class AlignmentCompat extends AbstractAdapter<dynamic> {
  AlignmentCompat(String charId, String variableName)
      : super(charId, variableName);

  @override
  dynamic get() {
    // TODO: read alignment from channel
    return null;
  }

  @override
  void set(dynamic value) {
    // TODO: write alignment to channel
  }
}
