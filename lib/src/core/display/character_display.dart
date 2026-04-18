// Copyright (c) Tom Parker, 2012.
//
// Translation of pcgen.core.display.CharacterDisplay
//
// Read-only view of a PlayerCharacter's data, routed through facets keyed on
// CharID. Each method delegates to the appropriate facet singleton.

import '../../enumeration/char_id.dart';

/// A read-only facade for a character's data. Prerequisite tests and display
/// utilities use this class instead of directly accessing PlayerCharacter.
class CharacterDisplay {
  final CharID id;

  // Facet singletons — populated by the facet library at startup.
  // Declared `late` to match the Java FacetLibrary.getFacet() pattern.
  late dynamic factFacet;
  late dynamic levelFacet;
  late dynamic raceTypeFacet;
  late dynamic regionFacet;
  late dynamic spellBookFacet;
  late dynamic chronicleEntryFacet;
  late dynamic ageSetFacet;
  late dynamic activeSpellsFacet;
  late dynamic templateFacet;
  late dynamic visionFacet;
  late dynamic formulaResolvingFacet;
  late dynamic armorClassFacet;
  late dynamic moveResultFacet;
  late dynamic raceFacet;
  late dynamic classFacet;
  late dynamic subClassFacet;
  late dynamic favClassFacet;
  late dynamic hasAnyFavoredFacet;
  late dynamic startingLangFacet;
  late dynamic bioSetFacet;
  late dynamic baseMovementFacet;
  late dynamic legsFacet;
  late dynamic statValueFacet;
  late dynamic substitutionClassFacet;
  late dynamic equippedFacet;
  late dynamic armorProfFacet;
  late dynamic spellListFacet;
  late dynamic hitPointFacet;
  late dynamic followerFacet;
  late dynamic loadFacet;
  late dynamic statFacet;
  late dynamic totalWeightFacet;
  late dynamic multiClassFacet;
  late dynamic levelTableFacet;
  late dynamic drFacet;
  late dynamic unarmedDamageFacet;
  late dynamic statBonusFacet;
  late dynamic nonAbilityFacet;
  late dynamic levelInfoFacet;
  late dynamic kitFacet;
  late dynamic autoLangGrantedFacet;
  late dynamic autoLangUnconditionalFacet;
  late dynamic xpTableFacet;
  late dynamic weightFacet;
  late dynamic noteItemFacet;
  late dynamic subRaceFacet;
  late dynamic userSpecialAbilityFacet;
  late dynamic skillRankFacet;
  late dynamic shieldProfFacet;
  late dynamic specialAbilityFacet;
  late dynamic secondaryWeaponFacet;
  late dynamic primaryWeaponFacet;
  late dynamic nonppFacet;
  late dynamic masterFacet;
  late dynamic foFacet;
  late dynamic statCalcFacet;
  late dynamic equipmentFacet;
  late dynamic equipSetFacet;
  late dynamic skillFacet;
  late dynamic domainFacet;
  late dynamic crFacet;
  late dynamic prohibitedSchoolFacet;
  late dynamic subTypesFacet;
  late dynamic weaponProfFacet;
  late dynamic languageFacet;
  late dynamic initiativeFacet;
  late dynamic portraitThumbnailRectFacet;
  late dynamic previewSheetFacet;
  late dynamic skillFilterFacet;
  late dynamic resultFacet;

  CharacterDisplay(this.id);

  // ── String fields ──────────────────────────────────────────────────────────

  String getSafeStringFor(dynamic key) =>
      factFacet.get(id, key) as String? ?? '';

  String getBio() => getSafeStringFor('BIO');
  String getCatchPhrase() => getSafeStringFor('CATCHPHRASE');
  String getHanded() => getSafeStringFor('HANDED');
  String getInterests() => getSafeStringFor('INTERESTS');
  String getLocation() => getSafeStringFor('LOCATION');
  String getSpeechTendency() => getSafeStringFor('SPEECHTENDENCY');
  String getTabName() => getSafeStringFor('TABNAME');
  String getTrait1() => getSafeStringFor('TRAIT1');
  String getTrait2() => getSafeStringFor('TRAIT2');
  String getName() => getSafeStringFor('NAME');
  String getFileName() => getSafeStringFor('FILENAME');
  String getPlayersName() => getSafeStringFor('PLAYERSNAME');
  String getPortraitPath() => getSafeStringFor('PORTRAIT_PATH');
  String getPreviewSheet() =>
      previewSheetFacet.get(id) as String? ?? '';
  String getSpellBookNameToAutoAddKnown() =>
      spellBookFacet.getSpellBookNameToAutoAddKnown(id) as String? ?? '';
  String getSubRace() => subRaceFacet.get(id) as String? ?? '';
  String getSubClassName(dynamic cls) =>
      subClassFacet.get(id, cls) as String? ?? '';
  String getSubstitutionClassName(dynamic lvl) =>
      substitutionClassFacet.get(id, lvl) as String? ?? '';
  String getXPTableName() => xpTableFacet.get(id)?.getName() as String? ?? '';
  String getCurrentEquipSetName() =>
      equipSetFacet.getActiveEquipSetName(id) as String? ?? '';
  String getRegionString() => regionFacet.getRegion(id) as String? ?? '';
  String getFullRegion() => regionFacet.getFullRegion(id) as String? ?? '';
  String getDisplayName() => getName();
  String getDisplayClassName(dynamic pcClass) =>
      classFacet.getDisplayClassName(id, pcClass) as String? ?? '';

  // ── Numeric fields ─────────────────────────────────────────────────────────

  int getTotalLevels() => levelFacet.getTotalLevels(id) as int? ?? 0;
  int getLevel(dynamic pcClass) =>
      classFacet.getLevel(id, pcClass) as int? ?? 0;
  int totalHitDice() => levelFacet.getMonsterLevelCount(id) as int? ?? 0;
  int totalNonMonsterLevels() =>
      levelFacet.getNonMonsterLevelCount(id) as int? ?? 0;
  int getECL() => levelFacet.getECL(id) as int? ?? 0;
  int getClassCount() => classFacet.getCount(id) as int? ?? 0;
  int getStatCount() => statFacet.getCount(id) as int? ?? 0;
  int getDomainCount() => domainFacet.getCount(id) as int? ?? 0;
  int getRacialSubTypeCount() => subTypesFacet.getCount(id) as int? ?? 0;
  int getVisionCount() => visionFacet.getCount(id) as int? ?? 0;
  int getLanguageCount() => languageFacet.getCount(id) as int? ?? 0;
  int getFollowerCount() => followerFacet.getCount(id) as int? ?? 0;
  int getNotesCount() => noteItemFacet.getCount(id) as int? ?? 0;
  int getNonProficiencyPenalty() => nonppFacet.get(id) as int? ?? 0;
  int getSpellBookCount() => spellBookFacet.getCount(id) as int? ?? 0;
  int getLevelInfoSize() => levelInfoFacet.getCount(id) as int? ?? 0;
  int getStat(dynamic stat) => statValueFacet.get(id, stat) as int? ?? 0;
  int getTotalStatFor(dynamic stat) =>
      statCalcFacet.getTotalStat(id, stat) as int? ?? 0;
  int getStatModFor(dynamic stat) =>
      statCalcFacet.getStatMod(id, stat) as int? ?? 0;
  int getBaseStatFor(dynamic stat) =>
      statValueFacet.getBaseStatFor(id, stat) as int? ?? 0;
  int getWeight() => weightFacet.getWeight(id) as int? ?? 0;
  int processOldInitiativeMod() =>
      initiativeFacet.getInitiative(id) as int? ?? 0;
  int getRacialHDSize() => levelFacet.getRacialHDSize(id) as int? ?? 0;
  int getPreFormulaLegs() => legsFacet.get(id) as int? ?? 0;
  int getBaseMovement() => moveResultFacet.getBaseMovement(id) as int? ?? 0;
  int getAgeSetIndex() => ageSetFacet.getAgeSetIndex(id) as int? ?? 0;
  int getFavoredClassLevel() =>
      favClassFacet.getFavoredClassLevel(id) as int? ?? 0;
  int minXPForNextECL() =>
      levelTableFacet.minXPForNextECL(id) as int? ?? 0;
  int getXPAward() => crFacet.getXPAward(id) as int? ?? 0;
  int getTemplateSR(dynamic pct, int level, int hitdice) =>
      templateFacet.getTemplateSR(id, pct, level, hitdice) as int? ?? 0;
  int? getDR(String key) => drFacet.getDR(id, key) as int?;

  double getStatBonusTo(String aType, String aName) =>
      statBonusFacet.getStatBonusTo(id, aType, aName) as double? ?? 0.0;
  double multiclassXPMultiplier() =>
      multiClassFacet.getMultiClassXPMultiplier(id) as double? ?? 1.0;
  double getMovementOfType(dynamic moveType) =>
      moveResultFacet.getMovementOfType(id, moveType) as double? ?? 0.0;
  double movementOfType(dynamic moveType) => getMovementOfType(moveType);
  double getLoadToken(String type) =>
      loadFacet.getLoadToken(id, type) as double? ?? 0.0;

  double? getBaseHD() => crFacet.getBaseHD(id) as double?;
  int? calcCR() => crFacet.calcCR(id) as int?;
  int? calcBaseCR() => crFacet.calcBaseCR(id) as int?;
  int? calcACOfType(String type) =>
      armorClassFacet.calcACOfType(id, type) as int?;

  double? getMaxLoad([double mult = 1.0]) =>
      loadFacet.getMaxLoad(id, mult) as double?;
  dynamic getLoadType() => loadFacet.getLoadType(id);

  int getNumberOfMovements() =>
      moveResultFacet.getNumberOfMovements(id) as int? ?? 0;
  int getBaseMovementForType(dynamic moveType, dynamic load) =>
      baseMovementFacet.getMovement(id, moveType, load) as int? ?? 0;
  bool hasMovement([dynamic moveType]) =>
      moveType == null
          ? moveResultFacet.hasMovement(id) as bool? ?? false
          : moveResultFacet.hasMovement(id, moveType) as bool? ?? false;

  dynamic getPortraitThumbnailRect() =>
      portraitThumbnailRectFacet.get(id);
  dynamic getSkillFilter() => skillFilterFacet.get(id);
  dynamic getAgeSet() => ageSetFacet.get(id);
  dynamic getBioSet() => bioSetFacet.get(id);
  dynamic getMaster() => masterFacet.get(id);
  dynamic getRace() => raceFacet.get(id);
  dynamic getPCAlignment() => factFacet.get(id, 'ALIGNMENT');
  dynamic getGlobal(String varName) => resultFacet.get(id, varName);

  dynamic getHP(dynamic pcl) => hitPointFacet.get(id, pcl);
  dynamic getActiveClassLevel(dynamic pcc, int lvl) =>
      classFacet.getActiveClassLevel(id, pcc, lvl);
  dynamic getLevelHitDie(dynamic pcClass, int classLevel) =>
      levelTableFacet.getLevelHitDie(id, pcClass, classLevel);
  dynamic getVision(dynamic type) => visionFacet.getVision(id, type);

  int? getInteger(dynamic key) => factFacet.get(id, key) as int?;

  // ── Boolean fields ─────────────────────────────────────────────────────────

  bool hasAnyFavoredClass() =>
      hasAnyFavoredFacet.get(id) as bool? ?? false;
  bool hasWeaponProf(dynamic wp) =>
      weaponProfFacet.containsProf(id, wp) as bool? ?? false;
  bool isNonAbility(dynamic stat) =>
      nonAbilityFacet.isNonAbility(id, stat) as bool? ?? false;
  bool isSecondaryWeapon(dynamic eq) =>
      secondaryWeaponFacet.contains(id, eq) as bool? ?? false;
  bool isPrimaryWeapon(dynamic eq) =>
      primaryWeaponFacet.contains(id, eq) as bool? ?? false;
  bool hasPrimaryWeapons() =>
      primaryWeaponFacet.hasWeapons(id) as bool? ?? false;
  bool hasSecondaryWeapons() =>
      secondaryWeaponFacet.hasWeapons(id) as bool? ?? false;
  bool hasDomain(dynamic domain) =>
      domainFacet.contains(id, domain) as bool? ?? false;
  bool hasDomains() => domainFacet.hasItems(id) as bool? ?? false;
  bool hasEquipSet() => equipSetFacet.hasItems(id) as bool? ?? false;
  bool hasEquipment() => equipmentFacet.hasItems(id) as bool? ?? false;
  bool hasFollowers() => followerFacet.hasItems(id) as bool? ?? false;
  bool hasKit(dynamic kit) => kitFacet.contains(id, kit) as bool? ?? false;
  bool hasLanguage(dynamic lang) =>
      languageFacet.contains(id, lang) as bool? ?? false;
  bool hasSkill(dynamic skill) =>
      skillFacet.contains(id, skill) as bool? ?? false;
  bool hasTemplate(dynamic template) =>
      templateFacet.contains(id, template) as bool? ?? false;
  bool hasTemplates() => templateFacet.hasItems(id) as bool? ?? false;
  bool containsRacialSubType(dynamic st) =>
      subTypesFacet.contains(id, st) as bool? ?? false;
  bool isProficientWithArmor(dynamic eq) =>
      armorProfFacet.isProficientWithArmor(id, eq) as bool? ?? false;

  // ── Collection fields ──────────────────────────────────────────────────────

  String getRaceType() => raceTypeFacet.get(id) as String? ?? '';
  dynamic getRegion() => regionFacet.getRegionObject(id);
  dynamic getSubRegion() => regionFacet.getSubRegion(id);

  List<dynamic> getMovementValues() =>
      moveResultFacet.getMovementValues(id) as List<dynamic>? ?? [];
  List<dynamic> getSpellBookNames() =>
      spellBookFacet.getSpellBookNames(id) as List<dynamic>? ?? [];
  List<dynamic> getOutputVisibleTemplateList() =>
      templateFacet.getOutputVisibleTemplateList(id) as List<dynamic>? ?? [];
  List<dynamic> getDisplayVisibleTemplateList() =>
      templateFacet.getDisplayVisibleTemplateList(id) as List<dynamic>? ?? [];
  List<dynamic> getLevelInfo() =>
      levelInfoFacet.getSet(id) as List<dynamic>? ?? [];
  dynamic getLevelInfoAt(int index) => levelInfoFacet.get(id, index);
  String getLevelInfoClassKeyName(int idx) =>
      levelInfoFacet.getClassKeyName(id, idx) as String? ?? '';
  int getLevelInfoClassLevel(int idx) =>
      levelInfoFacet.getClassLevel(id, idx) as int? ?? 0;
  List<dynamic> getClassList() =>
      classFacet.getClassList(id) as List<dynamic>? ?? [];
  List<dynamic> getPartialSkillList(dynamic view) =>
      skillFacet.getPartialSkillList(id, view) as List<dynamic>? ?? [];
  List<dynamic> getResolvedSpecialAbilities(dynamic cdo) =>
      specialAbilityFacet.getResolved(id, cdo) as List<dynamic>? ?? [];
  List<dynamic> getResolvedUserSpecialAbilities(dynamic cdo) =>
      userSpecialAbilityFacet.getResolved(id, cdo) as List<dynamic>? ?? [];
  List<dynamic> getUserSpecialAbilityList(dynamic source) =>
      userSpecialAbilityFacet.getForSource(id, source) as List<dynamic>? ?? [];
  List<dynamic> getSpellLists(dynamic cdo) =>
      spellListFacet.getSpellLists(id, cdo) as List<dynamic>? ?? [];
  List<dynamic> getChronicleEntries() =>
      chronicleEntryFacet.getSet(id) as List<dynamic>? ?? [];
  List<dynamic> getCharacterSpells(dynamic cdo) =>
      activeSpellsFacet.getCharacterSpells(id, cdo) as List<dynamic>? ?? [];
  List<dynamic> getArmorProfList() =>
      armorProfFacet.getSet(id) as List<dynamic>? ?? [];
  List<dynamic> getShieldProfList() =>
      shieldProfFacet.getSet(id) as List<dynamic>? ?? [];
  List<dynamic> getNotesList() =>
      noteItemFacet.getSet(id) as List<dynamic>? ?? [];

  dynamic getSpellBookByName(String name) =>
      spellBookFacet.getSpellBookByName(id, name);
  dynamic getEquipSetByIdPath(String path) =>
      equipSetFacet.getByIdPath(id, path);

  Iterable<dynamic> getVisionList() => visionFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getFollowerList() =>
      followerFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getKitInfo() => kitFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getTemplateSet() =>
      templateFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getProhibitedSchools(dynamic source) =>
      prohibitedSchoolFacet.getSet(id, source) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getSpellBooks() =>
      spellBookFacet.getSpellBooks(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getEquipSet() =>
      equipSetFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getEquipmentSet() =>
      equipmentFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getEquippedEquipmentSet() =>
      equippedFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getPrimaryWeapons() =>
      primaryWeaponFacet.getWeapons(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getSecondaryWeapons() =>
      secondaryWeaponFacet.getWeapons(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getSkillSet() =>
      skillFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getDomainSet() =>
      domainFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getSortedDomainSet() =>
      domainFacet.getSortedSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getClassSet() =>
      classFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getFavoredClasses() =>
      favClassFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getStatSet() =>
      statFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getAutoLanguages() =>
      autoLangGrantedFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getLanguageSet() =>
      languageFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getSortedLanguageSet() =>
      languageFacet.getSortedSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getWeaponProfSet() =>
      weaponProfFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getSortedWeaponProfs() =>
      weaponProfFacet.getSortedSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getRacialSubTypes() =>
      subTypesFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getUnarmedDamage() =>
      unarmedDamageFacet.getSet(id) as Iterable<dynamic>? ?? const [];
  Iterable<dynamic> getLanguageBonusSelectionList() =>
      autoLangGrantedFacet.getBonusSelectionList(id) as Iterable<dynamic>? ??
          const [];

  String getUDamForRace() => unarmedDamageFacet.getUDamForRace(id) as String? ?? '';
  String calcDR() => drFacet.calcDR(id) as String? ?? '';
  dynamic getAvailableFollowers(String aType, dynamic comp) =>
      foFacet.getAvailableFollowers(id, aType, comp);

  double? getRank(dynamic sk) => skillRankFacet.get(id, sk) as double?;
  double? getTotalWeight() => totalWeightFacet.getTotalWeight(id) as double?;

  CharID getCharID() => id;
}
