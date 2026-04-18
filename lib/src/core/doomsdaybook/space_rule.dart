// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.SpaceRule

import 'data_element.dart';
import 'data_value.dart';

/// A DataElement that always returns a space character.
class SpaceRule implements DataElement {
  static final DataValue _value = DataValue(' ');

  const SpaceRule();

  @override
  DataValue getData() => _value;

  @override
  String getId() => 'SPACE';

  @override
  DataValue getLastData() => _value;

  @override
  String getTitle() => 'Space';

  @override
  int getWeight() => 1;
}
