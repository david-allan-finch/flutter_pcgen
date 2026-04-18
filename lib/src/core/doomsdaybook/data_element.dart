// Copyright (c) Andrew Wilson, 2008.
//
// Translation of pcgen.core.doomsdaybook.DataElement

/// Interface for elements in the doomsdaybook random name/text generation system.
abstract interface class DataElement {
  /// Returns a randomly-selected data value for this element.
  dynamic getData();

  /// Returns the identifier for this element.
  String getId();

  /// Returns the most recently selected data value.
  dynamic getLastData();

  /// Returns the display title of this element.
  String getTitle();

  /// Returns the weight of this element for random selection.
  int getWeight();
}
