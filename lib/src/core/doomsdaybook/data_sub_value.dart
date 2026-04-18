// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.DataSubValue

/// A linked-list node holding a key/value pair for sub-values within a DataValue.
class DataSubValue {
  final String key;
  final String value;
  final DataSubValue? next;

  const DataSubValue(this.key, this.value, [this.next]);
}
