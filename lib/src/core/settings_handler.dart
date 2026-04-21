//
// Copyright 2001 (C) Jonas Karlsson
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//
// Translation of pcgen.core.SettingsHandler
// SettingsHandler.dart
// Translated from pcgen/core/SettingsHandler.java
// GUI/Swing/JavaFX fields are stubbed with comments.
// File I/O paths preserved as Strings.

import 'package:flutter_pcgen/src/core/game_mode.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';
import 'package:flutter_pcgen/src/core/system_collections.dart';

/// Holds application-wide settings previously backed by Java Properties files.
/// JavaFX BooleanProperty / IntegerProperty / ObjectProperty are replaced with
/// plain Dart fields and simple getter/setter pairs.
class SettingsHandler {
  SettingsHandler._();

  // For EqBuilder
  static int _maxPotionSpellLevel = 3; // Constants.DEFAULT_MAX_POTION_SPELL_LEVEL
  static int _maxWandSpellLevel = 4;   // Constants.DEFAULT_MAX_WAND_SPELL_LEVEL

  static bool _settingsNeedRestart = false;
  static final Map<String, String> _ruleCheckMap = {};

  // stub: FILTERSETTINGS (Properties) – omitted; load from external source when needed
  static GameMode _game = GameMode('default');

  static bool _loadURLs = false;
  static bool _hpMaxAtFirstLevel = true;
  static bool _hpMaxAtFirstClassLevel = true;
  static bool _hpMaxAtFirstPCClassLevelOnly = true;
  static int _hpRollMethod = 1; // Constants.HP_STANDARD
  static int _hpPercent = 100; // Constants.DEFAULT_HP_PERCENT
  static bool _ignoreMonsterHDCap = false;

  static bool _gearTabIgnoreCost = false;
  static bool _gearTabAllowDebt = false;
  static int _gearTabSellRate = 50;  // Constants.DEFAULT_GEAR_TAB_SELL_RATE
  static int _gearTabBuyRate = 100;  // Constants.DEFAULT_GEAR_TAB_BUY_RATE

  // stub: OPTIONS (SortedProperties) – stub as Map<String,String>
  static final Map<String, String> _options = {};
  // stub: FILEPATHS – omitted
  static String? _backupPcgPath;
  static bool _createPcgBackup = true;

  static String _gmgenPluginDir = '';
  static int _prereqQualifyColor = 0xFFFFFF; // SystemColor.text approx.
  static int _prereqFailColor = 0xFF0000;

  static bool _saveCustomInLst = false;
  static String _selectedCharacterHTMLOutputSheet = '';
  static String _selectedCharacterPDFOutputSheet = '';
  static bool _saveOutputSheetWithPC = false;
  static bool _printSpellsWithPC = true;
  static String _selectedPartyHTMLOutputSheet = '';
  static String _selectedPartyPDFOutputSheet = '';
  static String _selectedEqSetTemplate = '';
  static String _selectedSpellSheet = '';
  static bool _showHPDialogAtLevelUp = true;
  static bool _showStatDialogAtLevelUp = true;
  static bool _showWarningAtFirstLevelUp = true;
  static bool _alwaysOverwrite = false;
  static String _defaultOSType = '';
  static String _tmpPath = '';  // stub: System.getProperty("java.io.tmpdir")
  static bool _useHigherLevelSlotsDefault = false;
  static bool _weaponProfPrintout = true; // Constants.DEFAULT_PRINTOUT_WEAPONPROF
  static String _postExportCommandStandard = '';
  static String _postExportCommandPDF = '';
  static bool _hideMonsterClasses = false;
  static bool _guiUsesOutputNameEquipment = false;
  static bool _guiUsesOutputNameSpells = false;
  static int _lastTipShown = -1;
  static bool _showTipOfTheDay = true;
  static bool _outputDeprecationMessages = true;
  static bool _inputUnconstructedMessages = true;

  // ---------------------------------------------------------------------------
  // GameMode
  // ---------------------------------------------------------------------------

  /// Returns the current game mode.
  static GameMode getGameAsProperty() => _game;

  static void setGame(String key) {
    final GameMode? newMode = SystemCollections.getGameModeNamed(key);
    if (newMode != null) {
      _game = newMode;
    }
    // stub: unit set selection, feat template, chosen campaigns
  }

  // ---------------------------------------------------------------------------
  // Simple property accessors (pattern: get/set or is/set)
  // ---------------------------------------------------------------------------

  static void setAlwaysOverwrite(bool v) => _alwaysOverwrite = v;
  static bool getAlwaysOverwrite() => _alwaysOverwrite;

  static void setDefaultOSType(String? v) => _defaultOSType = v ?? '';
  static String getDefaultOSType() => _defaultOSType;

  static void setBackupPcgPath(String? path) => _backupPcgPath = path;
  static String? getBackupPcgPath() => _backupPcgPath;

  static void setCreatePcgBackup(bool v) => _createPcgBackup = v;
  static bool getCreatePcgBackup() => _createPcgBackup;

  /// stub: OS detection – returns 'user' always
  static String getFilePaths() => _options['pcgen.filepaths'] ?? 'user';

  static void setGMGenOption(String optionName, dynamic optionValue) {
    _options['gmgen.options.$optionName'] = optionValue.toString();
  }

  static bool getGMGenOptionBool(String optionName, bool defaultValue) {
    final String opt = _options['gmgen.options.$optionName'] ??
        (defaultValue ? 'true' : 'false');
    return opt.toLowerCase() == 'true';
  }

  static int getGMGenOptionInt(String optionName, int defaultValue) {
    final String? val = _options['gmgen.options.$optionName'];
    if (val == null) return defaultValue;
    return int.tryParse(val) ?? defaultValue;
  }

  static String getGMGenOptionStr(String optionName, String defaultValue) {
    return _options['gmgen.options.$optionName'] ?? defaultValue;
  }

  static void setGUIUsesOutputNameEquipment(bool v) => _guiUsesOutputNameEquipment = v;
  static void setGUIUsesOutputNameSpells(bool v) => _guiUsesOutputNameSpells = v;

  static void setGearTab_AllowDebt(bool v) => _gearTabAllowDebt = v;
  static bool getGearTab_AllowDebt() => _gearTabAllowDebt;

  static void setGearTab_BuyRate(int v) => _gearTabBuyRate = v;
  static int getGearTab_BuyRate() => _gearTabBuyRate;

  static void setGearTab_IgnoreCost(bool v) => _gearTabIgnoreCost = v;
  static bool getGearTab_IgnoreCost() => _gearTabIgnoreCost;

  static void setGearTab_SellRate(int v) => _gearTabSellRate = v;
  static int getGearTab_SellRate() => _gearTabSellRate;

  static void setGmgenPluginDir(String path) => _gmgenPluginDir = path;
  static String getGmgenPluginDir() => _gmgenPluginDir;

  static void setHPMaxAtFirstLevel(bool v) => _hpMaxAtFirstLevel = v;
  static bool isHPMaxAtFirstLevel() => _hpMaxAtFirstLevel;

  static void setHPMaxAtFirstClassLevel(bool v) => _hpMaxAtFirstClassLevel = v;
  static bool isHPMaxAtFirstClassLevel() => _hpMaxAtFirstClassLevel;

  static void setHPMaxAtFirstPCClassLevelOnly(bool v) => _hpMaxAtFirstPCClassLevelOnly = v;
  static bool isHPMaxAtFirstPCClassLevelOnly() => _hpMaxAtFirstPCClassLevelOnly;

  static void setHPPercent(int v) => _hpPercent = v;
  static int getHPPercent() => _hpPercent;

  static void setHPRollMethod(int v) => _hpRollMethod = v;
  static int getHPRollMethod() => _hpRollMethod;

  /// stub: returns empty string when no sheet selected
  static String getHTMLOutputSheetPath() {
    if (_selectedCharacterHTMLOutputSheet.isEmpty) {
      return ''; // stub: ConfigurationSettings.getOutputSheetsDir()
    }
    // stub: File(...).getParentFile().getAbsolutePath()
    final int sep = _selectedCharacterHTMLOutputSheet.lastIndexOf('/');
    return sep >= 0
        ? _selectedCharacterHTMLOutputSheet.substring(0, sep)
        : _selectedCharacterHTMLOutputSheet;
  }

  static void setHideMonsterClasses(bool v) => _hideMonsterClasses = v;
  static void setIgnoreMonsterHDCap(bool v) => _ignoreMonsterHDCap = v;
  static bool isIgnoreMonsterHDCap() => _ignoreMonsterHDCap;

  static void setLastTipShown(int v) => _lastTipShown = v;
  static int getLastTipShown() => _lastTipShown;

  static void setLoadURLs(bool v) => _loadURLs = v;
  static bool isLoadURLs() => _loadURLs;

  static int maxWandSpellLevel() => _maxWandSpellLevel;
  static void setMaxWandSpellLevel(int v) => _maxWandSpellLevel = v;

  static int maxPotionSpellLevel() => _maxPotionSpellLevel;
  static void setMaxPotionSpellLevel(int v) => _maxPotionSpellLevel = v;

  static bool settingsNeedRestart() => _settingsNeedRestart;
  static void setSettingsNeedRestart(bool v) => _settingsNeedRestart = v;

  static Map<String, String> getOptions() => _options;

  static void getOptionsFromProperties(PlayerCharacter? aPC) {
    int buyRate = getPCGenOptionInt('GearTab.buyRate', -1);
    int sellRate = getPCGenOptionInt('GearTab.sellRate', -1);

    if (buyRate < 0 || sellRate < 0) {
      if (getPCGenOptionBool('GearTab.ignoreCost', false)) {
        buyRate = 0;
        sellRate = 0;
      } else {
        buyRate = 100;
        sellRate = 50;
      }
    }

    _loadURLs = getPCGenOptionBool('loadURLs', false);

    setAlwaysOverwrite(getPCGenOptionBool('alwaysOverwrite', false));
    setCreatePcgBackup(getPCGenOptionBool('createPcgBackup', true));
    setDefaultOSType(getPCGenOptionStr('defaultOSType', ''));
    setGearTab_AllowDebt(getPCGenOptionBool('GearTab.allowDebt', false));
    setGearTab_BuyRate(buyRate);
    setGearTab_IgnoreCost(getPCGenOptionBool('GearTab.ignoreCost', false));
    setGearTab_SellRate(sellRate);
    setGUIUsesOutputNameEquipment(getPCGenOptionBool('GUIUsesOutputNameEquipment', false));
    setGUIUsesOutputNameSpells(getPCGenOptionBool('GUIUsesOutputNameSpells', false));
    setHideMonsterClasses(getPCGenOptionBool('hideMonsterClasses', false));
    setHPMaxAtFirstLevel(getPCGenOptionBool('hpMaxAtFirstLevel', true));
    setHPMaxAtFirstClassLevel(getPCGenOptionBool('hpMaxAtFirstClassLevel', false));
    setHPMaxAtFirstPCClassLevelOnly(getPCGenOptionBool('hpMaxAtFirstPCClassLevelOnly', false));
    setHPPercent(getPCGenOptionInt('hpPercent', 100));
    setHPRollMethod(getPCGenOptionInt('hpRollMethod', 1));
    setIgnoreMonsterHDCap(getPCGenOptionBool('ignoreMonsterHDCap', false));
    setLastTipShown(getPCGenOptionInt('lastTipOfTheDayTipShown', -1));
    setMaxWandSpellLevel(getPCGenOptionInt('maxWandSpellLevel', 4));
    setMaxPotionSpellLevel(getPCGenOptionInt('maxPotionSpellLevel', 3));
    setBackupPcgPath(_options['pcgen.files.characters.backup'] ?? '');
    setPostExportCommandStandard(getPCGenOptionStr('postExportCommandStandard', ''));
    setPostExportCommandPDF(getPCGenOptionStr('postExportCommandPDF', ''));
    setPrereqFailColor(getPCGenOptionInt('prereqFailColor', 0xFF0000));
    setPrereqQualifyColor(getPCGenOptionInt('prereqQualifyColor', 0xFFFFFF));
    setSaveCustomInLst(getPCGenOptionBool('saveCustomInLst', false));
    setSaveOutputSheetWithPC(getPCGenOptionBool('saveOutputSheetWithPC', false));
    setPrintSpellsWithPC(getPCGenOptionBool('printSpellsWithPC', true));
    setSelectedSpellSheet(_options['pcgen.files.selectedSpellOutputSheet'] ?? '');
    setSelectedCharacterHTMLOutputSheet(
        _options['pcgen.files.selectedCharacterHTMLOutputSheet'] ?? '', aPC);
    setSelectedCharacterPDFOutputSheet(
        _options['pcgen.files.selectedCharacterPDFOutputSheet'] ?? '', aPC);
    setSelectedEqSetTemplate(_options['pcgen.files.selectedEqSetTemplate'] ?? '');
    setSelectedPartyHTMLOutputSheet(_options['pcgen.files.selectedPartyHTMLOutputSheet'] ?? '');
    setSelectedPartyPDFOutputSheet(_options['pcgen.files.selectedPartyPDFOutputSheet'] ?? '');
    setShowHPDialogAtLevelUp(getPCGenOptionBool('showHPDialogAtLevelUp', true));
    setOutputDeprecationMessages(getPCGenOptionBool('outputDeprecationMessages', true));
    setInputUnconstructedMessages(getPCGenOptionBool('inputUnconstructedMessages', false));
    setShowStatDialogAtLevelUp(getPCGenOptionBool('showStatDialogAtLevelUp', true));
    setShowTipOfTheDay(getPCGenOptionBool('showTipOfTheDay', true));
    setShowWarningAtFirstLevelUp(getPCGenOptionBool('showWarningAtFirstLevelUp', true));
    setUseHigherLevelSlotsDefault(getPCGenOptionBool('useHigherLevelSlotsDefault', false));
    setWeaponProfPrintout(getPCGenOptionBool('weaponProfPrintout', true));
    _parseRuleChecksFromOptions(getPCGenOptionStr('ruleChecks', ''));
  }

  /// stub: URI conversion for chosen campaign source files
  static void setOptionsProperties(PlayerCharacter? aPC) {
    // stub: all getOptions().setProperty(...) calls are mirrored here into _options
    _options['pcgen.files.characters.backup'] = _backupPcgPath ?? '';
    _options['pcgen.files.selectedSpellOutputSheet'] = _selectedSpellSheet;
    _options['pcgen.files.selectedCharacterHTMLOutputSheet'] =
        _selectedCharacterHTMLOutputSheet;
    _options['pcgen.files.selectedCharacterPDFOutputSheet'] =
        _selectedCharacterPDFOutputSheet;
    _options['pcgen.files.selectedPartyHTMLOutputSheet'] =
        _selectedPartyHTMLOutputSheet;
    _options['pcgen.files.selectedPartyPDFOutputSheet'] =
        _selectedPartyPDFOutputSheet;
    _options['pcgen.files.selectedEqSetTemplate'] = _selectedEqSetTemplate;
    if (_game != null) {
      setPCGenOptionStr('game', _game.getName());
    }

    for (final GameMode gameMode in SystemCollections.getUnmodifiableGameModeList()) {
      final String key = gameMode.getName();
      setPCGenOptionStr('gameMode.$key.purchaseMethodName', gameMode.getPurchaseModeMethodName());
      setPCGenOptionInt('gameMode.$key.rollMethod', gameMode.getRollMethod());
      setPCGenOptionStr('gameMode.$key.xpTableName', gameMode.getDefaultXPTableName());
      setPCGenOptionStr('gameMode.$key.characterType', gameMode.getDefaultCharacterType());
    }

    _setRuleChecksInOptions('ruleChecks');

    setPCGenOptionBool('alwaysOverwrite', _alwaysOverwrite);
    setPCGenOptionBool('createPcgBackup', _createPcgBackup);
    setPCGenOptionStr('defaultOSType', _defaultOSType);
    setPCGenOptionBool('GearTab.allowDebt', _gearTabAllowDebt);
    setPCGenOptionInt('GearTab.buyRate', _gearTabBuyRate);
    setPCGenOptionBool('GearTab.ignoreCost', _gearTabIgnoreCost);
    setPCGenOptionInt('GearTab.sellRate', _gearTabSellRate);
    setPCGenOptionBool('GUIUsesOutputNameEquipment', _guiUsesOutputNameEquipment);
    setPCGenOptionBool('GUIUsesOutputNameSpells', _guiUsesOutputNameSpells);
    setPCGenOptionBool('hideMonsterClasses', _hideMonsterClasses);
    setPCGenOptionBool('hpMaxAtFirstLevel', _hpMaxAtFirstLevel);
    setPCGenOptionBool('hpMaxAtFirstClassLevel', _hpMaxAtFirstClassLevel);
    setPCGenOptionBool('hpMaxAtFirstPCClassLevelOnly', _hpMaxAtFirstPCClassLevelOnly);
    setPCGenOptionInt('hpPercent', _hpPercent);
    setPCGenOptionInt('hpRollMethod', _hpRollMethod);
    setPCGenOptionBool('ignoreMonsterHDCap', _ignoreMonsterHDCap);
    setPCGenOptionInt('lastTipOfTheDayTipShown', _lastTipShown);
    setPCGenOptionBool('loadURLs', _loadURLs);
    setPCGenOptionInt('maxPotionSpellLevel', _maxPotionSpellLevel);
    setPCGenOptionInt('maxWandSpellLevel', _maxWandSpellLevel);
    setPCGenOptionStr('postExportCommandStandard', _postExportCommandStandard);
    setPCGenOptionStr('postExportCommandPDF', _postExportCommandPDF);
    setPCGenOptionStr('prereqFailColor', '0x${_prereqFailColor.toRadixString(16)}');
    setPCGenOptionStr('prereqQualifyColor', '0x${_prereqQualifyColor.toRadixString(16)}');
    setPCGenOptionBool('saveCustomInLst', _saveCustomInLst);
    setPCGenOptionBool('saveOutputSheetWithPC', _saveOutputSheetWithPC);
    setPCGenOptionBool('printSpellsWithPC', _printSpellsWithPC);
    setPCGenOptionBool('showHPDialogAtLevelUp', _showHPDialogAtLevelUp);
    setPCGenOptionBool('showStatDialogAtLevelUp', _showStatDialogAtLevelUp);
    setPCGenOptionBool('showTipOfTheDay', _showTipOfTheDay);
    setPCGenOptionBool('showWarningAtFirstLevelUp', _showWarningAtFirstLevelUp);
    setPCGenOptionBool('useHigherLevelSlotsDefault', _useHigherLevelSlotsDefault);
    setPCGenOptionBool('weaponProfPrintout', _weaponProfPrintout);
    setPCGenOptionBool('outputDeprecationMessages', _outputDeprecationMessages);
    setPCGenOptionBool('inputUnconstructedMessages', _inputUnconstructedMessages);
  }

  static void setPCGenOptionStr(String optionName, String? optionValue) {
    if (optionValue == null) {
      _options.remove('pcgen.options.$optionName');
    } else {
      _options['pcgen.options.$optionName'] = optionValue;
    }
  }

  static void setPCGenOptionBool(String optionName, bool v) =>
      setPCGenOptionStr(optionName, v ? 'true' : 'false');

  static void setPCGenOptionInt(String optionName, int v) =>
      setPCGenOptionStr(optionName, v.toString());

  static bool getPCGenOptionBool(String optionName, bool defaultValue) {
    final String opt = getPCGenOptionStr(optionName, defaultValue ? 'true' : 'false');
    return opt.toLowerCase() == 'true';
  }

  static int getPCGenOptionInt(String optionName, int defaultValue) {
    final String s = getPCGenOptionStr(optionName, defaultValue.toString());
    return int.tryParse(s) ?? defaultValue;
  }

  static String getPCGenOptionStr(String optionName, String defaultValue) {
    return _options['pcgen.options.$optionName'] ?? defaultValue;
  }

  /// stub: PDF output sheet path
  static String getPDFOutputSheetPath() {
    if (_selectedCharacterPDFOutputSheet.isEmpty) {
      return ''; // stub: ConfigurationSettings.getOutputSheetsDir()
    }
    final int sep = _selectedCharacterPDFOutputSheet.lastIndexOf('/');
    return sep >= 0
        ? _selectedCharacterPDFOutputSheet.substring(0, sep)
        : _selectedCharacterPDFOutputSheet;
  }

  static void setPostExportCommandStandard(String v) => _postExportCommandStandard = v;
  static void setPostExportCommandPDF(String v) => _postExportCommandPDF = v;
  static String getPostExportCommandStandard() => _postExportCommandStandard;
  static String getPostExportCommandPDF() => _postExportCommandPDF;

  static void setPrereqFailColor(int newColor) =>
      _prereqFailColor = newColor & 0x00FFFFFF;
  static int getPrereqFailColor() => _prereqFailColor;

  static String getPrereqFailColorAsHtmlStart() {
    final StringBuffer sb = StringBuffer('<font color=');
    if (_prereqFailColor != 0) {
      sb.write('"#${_prereqFailColor.toRadixString(16)}"');
    } else {
      sb.write('red');
    }
    sb.write('>');
    return sb.toString();
  }

  static String getPrereqFailColorAsHtmlEnd() => '</font>';

  static void setPrereqQualifyColor(int newColor) =>
      _prereqQualifyColor = newColor & 0x00FFFFFF;
  static int getPrereqQualifyColor() => _prereqQualifyColor;

  static void setPrintSpellsWithPC(bool v) => _printSpellsWithPC = v;
  static bool getPrintSpellsWithPC() => _printSpellsWithPC;

  static void setRuleCheck(String aKey, bool aBool) {
    _ruleCheckMap[aKey] = aBool ? 'Y' : 'N';
  }

  static bool getRuleCheck(String aKey) {
    final String? val = _ruleCheckMap[aKey];
    return val == 'Y';
  }

  static void setSaveOutputSheetWithPC(bool v) => _saveOutputSheetWithPC = v;
  static bool getSaveOutputSheetWithPC() => _saveOutputSheetWithPC;

  static void setSelectedCharacterHTMLOutputSheet(String path, PlayerCharacter? aPC) {
    if (_saveOutputSheetWithPC && aPC != null) {
      aPC.setSelectedCharacterHTMLOutputSheet(path);
    }
    _selectedCharacterHTMLOutputSheet = path;
  }

  static String getSelectedCharacterHTMLOutputSheet(PlayerCharacter? aPC) {
    if (_saveOutputSheetWithPC && aPC != null) {
      final String s = aPC.getSelectedCharacterHTMLOutputSheet();
      if (s.isNotEmpty) return s;
    }
    return _selectedCharacterHTMLOutputSheet;
  }

  static void setSelectedCharacterPDFOutputSheet(String path, PlayerCharacter? aPC) {
    if (_saveOutputSheetWithPC && aPC != null) {
      aPC.setSelectedCharacterPDFOutputSheet(path);
    }
    _selectedCharacterPDFOutputSheet = path;
  }

  static String getSelectedCharacterPDFOutputSheet(PlayerCharacter? aPC) {
    if (_saveOutputSheetWithPC && aPC != null) {
      final String s = aPC.getSelectedCharacterPDFOutputSheet();
      if (s.isNotEmpty) return s;
    }
    return _selectedCharacterPDFOutputSheet;
  }

  static void setSelectedEqSetTemplate(String path) => _selectedEqSetTemplate = path;
  static String getSelectedEqSetTemplate() => _selectedEqSetTemplate;

  static void setSelectedPartyHTMLOutputSheet(String path) =>
      _selectedPartyHTMLOutputSheet = path;
  static String getSelectedPartyHTMLOutputSheet() => _selectedPartyHTMLOutputSheet;

  static void setSelectedPartyPDFOutputSheet(String path) =>
      _selectedPartyPDFOutputSheet = path;
  static String getSelectedPartyPDFOutputSheet() => _selectedPartyPDFOutputSheet;

  static void setSelectedSpellSheet(String path) => _selectedSpellSheet = path;
  static String getSelectedSpellSheet() => _selectedSpellSheet;

  static void setShowHPDialogAtLevelUp(bool v) => _showHPDialogAtLevelUp = v;
  static bool getShowHPDialogAtLevelUp() => _showHPDialogAtLevelUp;

  static void setShowStatDialogAtLevelUp(bool v) => _showStatDialogAtLevelUp = v;
  static bool getShowStatDialogAtLevelUp() => _showStatDialogAtLevelUp;

  static void setShowTipOfTheDay(bool v) => _showTipOfTheDay = v;
  static bool getShowTipOfTheDay() => _showTipOfTheDay;

  static void setShowWarningAtFirstLevelUp(bool v) => _showWarningAtFirstLevelUp = v;
  static bool isShowWarningAtFirstLevelUp() => _showWarningAtFirstLevelUp;

  /// Returns the path to the temporary output location.
  static String getTempPath() => _tmpPath;

  static bool isUseHigherLevelSlotsDefault() => _useHigherLevelSlotsDefault;
  static void setUseHigherLevelSlotsDefault(bool v) => _useHigherLevelSlotsDefault = v;

  static void setWeaponProfPrintout(bool v) => _weaponProfPrintout = v;
  static bool getWeaponProfPrintout() => _weaponProfPrintout;

  static bool guiUsesOutputNameEquipment() => _guiUsesOutputNameEquipment;
  static bool guiUsesOutputNameSpells() => _guiUsesOutputNameSpells;

  static bool hasRuleCheck(String aKey) => _ruleCheckMap.containsKey(aKey);
  static bool hideMonsterClasses() => _hideMonsterClasses;

  /// stub: reads options.ini – I/O stubs; caller must supply option map externally.
  static void readOptionsProperties() {
    // stub: readFilePaths(), readFilterSettings(), load options from file
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  static void _setRuleChecksInOptions(String optionName) {
    final StringBuffer value = StringBuffer();
    for (final entry in _ruleCheckMap.entries) {
      if (value.isEmpty) {
        value.write('${entry.key}|${entry.value}');
      } else {
        value.write(',${entry.key}|${entry.value}');
      }
    }
    _options['pcgen.options.$optionName'] = value.toString();
  }

  static void setSaveCustomInLst(bool v) => _saveCustomInLst = v;
  static bool isSaveCustomInLst() => _saveCustomInLst;

  static void _parseRuleChecksFromOptions(String aString) {
    if (aString.isEmpty) return;
    final List<String> entries = aString.split(',');
    for (final String bs in entries) {
      final List<String> parts = bs.split('|');
      if (parts.length == 2) {
        _ruleCheckMap[parts[0]] = parts[1];
      }
    }
  }

  static bool outputDeprecationMessages() => _outputDeprecationMessages;
  static void setOutputDeprecationMessages(bool v) => _outputDeprecationMessages = v;

  static bool inputUnconstructedMessages() => _inputUnconstructedMessages;
  static void setInputUnconstructedMessages(bool v) => _inputUnconstructedMessages = v;
}
