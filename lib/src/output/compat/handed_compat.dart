// Translation of pcgen.output.channel.compat.HandedCompat

import 'package:flutter_pcgen/src/output/compat/abstract_adapter.dart';

/// HandedCompat provides a writeable reference for the character's handedness channel.
class HandedCompat extends AbstractAdapter<dynamic> {
  HandedCompat(String charId, String variableName)
      : super(charId, variableName);

  @override
  dynamic get() => null; // TODO: read from channel

  @override
  void set(dynamic value) {} // TODO: write to channel
}
