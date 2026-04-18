// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.HyphenRule

import 'data_element.dart';
import 'data_value.dart';

/// A DataElement that always returns a hyphen character.
class HyphenRule implements DataElement {
  static final DataValue _value = DataValue('-');

  const HyphenRule();

  @override
  DataValue getData() => _value;

  @override
  String getId() => 'HYPHEN';

  @override
  DataValue getLastData() => _value;

  @override
  String getTitle() => 'Hyphen';

  @override
  int getWeight() => 1;
}
