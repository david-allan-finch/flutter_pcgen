// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.WeightedDataValue

import 'package:flutter_pcgen/src/core/doomsdaybook/data_sub_value.dart';
import 'package:flutter_pcgen/src/core/doomsdaybook/data_value.dart';

/// A DataValue with an associated weight for random selection.
class WeightedDataValue extends DataValue {
  final int weight;

  WeightedDataValue(super.value, this.weight, [super.subValue]);

  WeightedDataValue.withSubValue(String value, int weight, DataSubValue subValue)
      : this(value, weight, subValue);

  int getWeight() => weight;
}
