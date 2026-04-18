// Translation of pcgen.output.channel.compat.HairColorCompat

import 'abstract_adapter.dart';

/// HairColorCompat provides a writeable reference for the character's hair color channel.
class HairColorCompat extends AbstractAdapter<String> {
  HairColorCompat(String charId, String variableName)
      : super(charId, variableName);

  @override
  String? get() => null; // TODO: read from channel

  @override
  void set(String value) {} // TODO: write to channel
}
