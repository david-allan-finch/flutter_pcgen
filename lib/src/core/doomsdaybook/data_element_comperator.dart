// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.DataElementComperator
// (preserving original "Comperator" spelling)

import 'package:flutter_pcgen/src/core/doomsdaybook/data_element.dart';

/// Comparator for DataElements, ordering by title (case-insensitive).
class DataElementComperator implements Comparator<DataElement> {
  const DataElementComperator();

  @override
  int compare(DataElement a, DataElement b) =>
      a.getTitle().toLowerCase().compareTo(b.getTitle().toLowerCase());
}
