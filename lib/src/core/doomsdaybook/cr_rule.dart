// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.CRRule

import 'data_element.dart';
import 'data_value.dart';

/// A DataElement that always returns a carriage-return/newline character.
class CRRule implements DataElement {
  static final DataValue _value = DataValue('\n');

  const CRRule();

  @override
  DataValue getData() => _value;

  @override
  String getId() => 'CR';

  @override
  DataValue getLastData() => _value;

  @override
  String getTitle() => 'CR';

  @override
  int getWeight() => 1;
}
