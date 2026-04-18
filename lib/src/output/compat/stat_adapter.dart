// Translation of pcgen.output.channel.compat.StatAdapter

import 'abstract_adapter.dart';

/// StatAdapter provides a writeable reference for a specific stat channel.
class StatAdapter extends AbstractAdapter<int> {
  final dynamic _stat;

  StatAdapter(String charId, String variableName, this._stat)
      : super(charId, variableName);

  @override
  int? get() => null; // TODO: read stat value from channel

  @override
  void set(int value) {} // TODO: write stat value to channel
}
