// Translation of pcgen.output.channel.compat.GenderCompat

import 'package:flutter_pcgen/src/output/compat/abstract_adapter.dart';

/// GenderCompat provides a writeable reference for the character's gender channel.
class GenderCompat extends AbstractAdapter<dynamic> {
  GenderCompat(String charId, String variableName)
      : super(charId, variableName);

  @override
  dynamic get() => null; // TODO: read gender from channel

  @override
  void set(dynamic value) {} // TODO: write gender to channel
}
