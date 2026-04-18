// Copyright (c) Andrew Maitland, 2016.
//
// Translation of pcgen.core.chooser.ChooseController

/// Controls pool size and stacking behaviour for a chooser interaction.
class ChooseController<T> {
  int getPool() => 1;
  bool isMultYes() => false;
  bool isStackYes() => false;
  double getCost() => 1.0;
  int getTotalChoices() => 1;
  void adjustPool(List<T> selected) {}
}
