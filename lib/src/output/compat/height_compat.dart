// Translation of pcgen.output.channel.compat.HeightCompat

import 'abstract_adapter.dart';

/// HeightCompat provides a writeable reference for the character's height channel.
class HeightCompat extends AbstractAdapter<int> {
  HeightCompat(String charId, String variableName)
      : super(charId, variableName);

  @override
  int? get() => null; // TODO: read from channel

  @override
  void set(int value) {} // TODO: write to channel
}
