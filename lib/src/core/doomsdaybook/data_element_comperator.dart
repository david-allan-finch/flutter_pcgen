// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.DataElementComperator
// (preserving original "Comperator" spelling)

import 'data_element.dart';

/// Comparator for DataElements, ordering by title (case-insensitive).
class DataElementComperator implements Comparator<DataElement> {
  const DataElementComperator();

  @override
  int compare(DataElement a, DataElement b) =>
      a.getTitle().toLowerCase().compareTo(b.getTitle().toLowerCase());
}
