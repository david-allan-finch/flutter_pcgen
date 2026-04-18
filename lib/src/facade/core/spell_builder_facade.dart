// Copyright (c) Tom Parker, 2016.
//
// Translation of pcgen.facade.core.SpellBuilderFacade

abstract interface class SpellBuilderFacade {
  void setClass(dynamic classFacade);
  dynamic getClassRef();
  List<dynamic> getClasses();
  void setSpellLevel(int? spellLevel);
  dynamic getSpellLevelRef();
  List<int> getLevels();
  void setSpell(dynamic spell);
  dynamic getSpellRef();
  List<dynamic> getSpells();
  void setVariant(String variant);
  dynamic getVariantRef();
  List<String> getVariants();
  void setCasterLevel(int? casterLevel);
  dynamic getCasterLevelRef();
  List<int> getCasterLevels();
  void setSpellType(String spellType);
  dynamic getSpellTypeRef();
  List<String> getSpellTypes();
  List<dynamic> getSelectedMetamagicFeats();
  List<dynamic> getMetamagicFeats();
}
