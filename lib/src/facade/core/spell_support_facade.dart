// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.SpellSupportFacade

abstract interface class SpellSupportFacade {
  List<dynamic> getAvailableSpellNodes();
  List<dynamic> getAllKnownSpellNodes();
  List<dynamic> getKnownSpellNodes();
  List<dynamic> getPreparedSpellNodes();
  List<dynamic> getBookSpellNodes();
  void addKnownSpell(dynamic spell);
  void removeKnownSpell(dynamic spell);
  void addPreparedSpell(dynamic spell, String spellList, bool useMetamagic);
  void removePreparedSpell(dynamic spell, String spellList);
  void addSpellList(String spellList);
  void removeSpellList(String spellList);
  void addToSpellBook(dynamic node, String spellBook);
  void removeFromSpellBook(dynamic node, String spellBook);
  String getClassInfo(dynamic spellcaster);
  void refreshAvailableKnownSpells();
  bool isAutoSpells();
  void setAutoSpells(bool autoSpells);
  bool isUseHigherKnownSlots();
  void setUseHigherKnownSlots(bool useHigher);
}
