// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.CompanionSupportFacade

abstract interface class CompanionSupportFacade {
  void addCompanion(dynamic companion, String companionType);
  void removeCompanion(dynamic companion);
  List<dynamic> getAvailableCompanions();
  Map<String, int> getMaxCompanionsMap();
  List<dynamic> getCompanions();
}
