// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.LanguageChooserFacade

abstract interface class LanguageChooserFacade {
  List<dynamic> getAvailableList();
  List<dynamic> getSelectedList();
  void addSelected(dynamic language);
  void removeSelected(dynamic language);
  void commit();
  void rollback();
  String getName();
}
