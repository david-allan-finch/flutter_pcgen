// Global constants for PCGen.
class Constants {
  Constants._();

  // Equipment location strings
  static const String equipLocationBoth = 'Both Hands';
  static const String equipLocationCarried = 'Carried';
  static const String equipLocationDouble = 'Double Weapon';
  static const String equipLocationEquipped = 'Equipped';
  static const String equipLocationNaturalPrimary = 'Natural-Primary';
  static const String equipLocationNaturalSecondary = 'Natural-Secondary';
  static const String equipLocationNotcarried = 'Not Carried';
  static const String equipLocationPrimary = 'Primary Hand';
  static const String equipLocationSecondary = 'Secondary Hand';
  static const String equipLocationShield = 'Shield';
  static const String equipLocationTwoweapons = 'Two Weapons';
  static const String equipLocationUnarmed = 'Unarmed';

  // Game mode constants
  static const String wrappedNoneSelected = '<html>none selected</html>';
  static const String applicationName = 'PCGen';
  static const String autoResizePrefix = 'AUTOSIZE';

  // Output sheet related
  static const String characterTemplatePrefix = 'csheet';
  static const String partyTemplatePrefix = 'psheet';
  static const String typeCustom = 'Custom';
  static const String kDefault = 'Default';
  static const String genericItem = 'GENERIC ITEM';
  static const String internalEqmodArmor = 'PCGENi_ARMOR';
  static const String internalEqmodWeapon = 'PCGENi_WEAPON';
  static const String internalWeaponProf = 'PCGENi_WEAPON_PROFICIENCY';
  static final String lineSeparator = '\n';
  static const String none = 'None';
  static const String extensionCampaignFile = '.pcc';
  static const String extensionCharacterFile = '.pcg';
  static const String extensionListFile = '.lst';
  static const String extensionPartyFile = '.pcp';
  static const String temporaryFileName = 'currentPC';
  static const String typeSpellbook = 'SPELLBOOK';

  // Units of measurement
  static const String standardUnitsetName = 'Imperial';
  static const String standardUnitsetHeightUnit = 'ftin';
  static const double standardUnitsetHeightFactor = 1.0;
  static const String standardUnitsetHeightDisplayPattern = '#.#';
  static const String standardUnitsetDistanceUnit = "~'";
  static const double standardUnitsetDistanceFactor = 1.0;
  static const String standardUnitsetDistanceDisplayPattern = '#';
  static const String standardUnitsetWeightUnit = 'lbs.';
  static const double standardUnitsetWeightFactor = 1.0;
  static const String standardUnitsetWeightDisplayPattern = '#.###';

  // Character stat generation methods
  static const int characterStatMethodUser = 0;
  static const int characterStatMethodAllTheSame = 1;
  static const int characterStatMethodPurchase = 2;
  static const int characterStatMethodRolled = 3;

  // Chooser single choice methods
  static const int chooserSingleChoiceMethodNone = 0;
  static const int chooserSingleChoiceMethodSelectExit = 2;

  // How to roll hitpoints
  static const int hpStandard = 0;
  static const int hpAutoMax = 1;
  static const int hpAverage = 2;
  static const int hpPercentage = 3;
  static const int hpUserRolled = 4;
  static const int hpAverageRoundedUp = 5;

  static const int maxMaxdex = 100;
  static const int maxSpellLevel = 25;

  // Merge of like equipment constants
  static const int mergeAll = 0;
  static const int mergeNone = 1;
  static const int mergeLocation = 2;

  static const String featCategory = 'FEAT';
  static const String emptyString = '';

  // Parsing token constants
  static const String colon = ':';
  static const String comma = ',';
  static const String semicolon = ';';
  static const String dot = '.';
  static const String equals = '=';
  static const String percent = '%';
  static const String pipe = '|';
  static const String tab = '\t';
  static const String charAsterisk = '*';

  // LST parsing constants
  static const String lstDotClear = '.CLEAR';
  static const String lstDotClearAll = '.CLEARALL';
  static const String lstDotClearDot = '.CLEAR.';
  static const String lstSemiLevelDot = ';LEVEL.';
  static const String lstSemiLevelEqual = ';LEVEL=';
  static const String lstClassDot = 'CLASS.';
  static const String lstClassEqual = 'CLASS=';
  static const String lstTypeDot = 'TYPE.';
  static const String lstTypeEqual = 'TYPE=';
  static const String lstNotTypeDot = '!TYPE.';
  static const String lstNotTypeEqual = '!TYPE=';
  static const String lstPercentChoice = '%CHOICE';
  static const String lstPercentList = '%LIST';
  static const String lstChooseColon = 'CHOOSE:';
  static const String lstAll = 'ALL';
  static const String lstAny = 'ANY';
  static const String lstCrossClass = 'CROSSCLASSSKILLS';
  static const String lstClass = 'CLASS';
  static const String lstExclusive = 'EXCLUSIVE';
  static const String lstList = 'LIST';
  static const String lstNone = 'NONE';
  static const String lstNonexclusive = 'NONEXCLUSIVE';
  static const String lstTrained = 'TRAINED';
  static const String lstUntrained = 'UNTRAINED';
  static const String highestLevelClass = 'HIGHESTLEVELCLASS';

  static const int handsSizeDependent = -1;
  static const int noLevelLimit = -1;

  static const int defaultMaxPotionSpellLevel = 3;
  static const int defaultMaxWandSpellLevel = 4;
  static const int defaultHpPercent = 100;
  static const int defaultGearTabSellRate = 50;
  static const int defaultGearTabBuyRate = 100;
  static const int numberOfAgesetKitSelections = 10;
  static const int idPathLengthForNonContained = 3;
  static const int arbitraryEndSkillIndex = 999;
  static const int substringLengthFive = 5;
  static const int substringLengthSix = 6;
  static const int substringLengthSeven = 7;
  static const bool defaultPrintoutWeaponprof = true;
  static const String equipSetRootId = '0';
  static const String equipSetPathSeparator = '.';
  static const String innateSpellBookName = 'Innate';
  static const int thumbnailSize = 100;
  static const String eqmodTypeBasematerial = 'BaseMaterial';
}
