// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.DescriptionFacade

abstract interface class DescriptionFacade {
  void removeChronicleEntry(dynamic chronicleEntry);
  List<dynamic> getChronicleEntries();
  dynamic createChronicleEntry();
  List<dynamic> getNotes();
  void renameNote(dynamic note, String newName);
  void deleteNote(dynamic note);
  void addNewNote();
  void setNote(dynamic note, String text);
  dynamic getBiographyField(dynamic field);
  void setBiographyField(dynamic field, dynamic attribute, String newValue);
}
