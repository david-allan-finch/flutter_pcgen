// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.PartyFacade

abstract interface class PartyFacade {
  dynamic getFileRef();
  void setFile(dynamic file);
  void export(dynamic theHandler, dynamic buf);
  List<dynamic> getCharacters();
}
