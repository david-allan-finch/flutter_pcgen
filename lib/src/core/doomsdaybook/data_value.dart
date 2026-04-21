// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.DataValue

import 'package:flutter_pcgen/src/core/doomsdaybook/data_sub_value.dart';

/// A value produced by a DataElement, optionally with a linked list of sub-values.
class DataValue {
  final String value;
  DataSubValue? subValue;

  DataValue(this.value, [this.subValue]);

  /// Returns the main string value.
  String getValue() => value;

  /// Returns the sub-value linked list, or null if none.
  DataSubValue? getSubValue() => subValue;

  /// Sets the sub-value linked list.
  void setSubValue(DataSubValue? sv) {
    subValue = sv;
  }

  @override
  String toString() => value;
}
