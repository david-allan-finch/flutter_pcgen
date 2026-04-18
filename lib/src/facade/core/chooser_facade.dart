// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.ChooserFacade

enum ChooserTreeViewType { typeName, nameOnly, prerequisiteTree }

abstract interface class ChooserFacade {
  List<dynamic> getAvailableList();
  List<dynamic> getSelectedList();
  void addSelected(dynamic item);
  void removeSelected(dynamic item);
  void commit();
  void rollback();
  String getName();
  String getAvailableTableTypeNameTitle();
  String getAvailableTableTitle();
  String getSelectedTableTitle();
  String getAddButtonName();
  String getRemoveButtonName();
  String getSelectionCountName();
  List<String> getBranchNames(dynamic item);
  bool isRequireCompleteSelection();
  bool isPreferRadioSelection();
  bool isUserInput();
  bool isInfoAvailable();
  dynamic getRemainingSelections();
  ChooserTreeViewType getDefaultView();
  dynamic getInfoFactory();
}
