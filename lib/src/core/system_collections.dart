//
// Copyright 2001 (C) Bryan McRoberts <merton_monk@yahoo.com>
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
// Translation of pcgen.core.SystemCollections
// SystemCollections.dart
// Translated from pcgen/core/SystemCollections.java

import 'game_mode.dart';
import 'game_mode_display.dart';
import 'settings_handler.dart';
import 'character/equip_slot.dart';
import 'system/migration_rule.dart';

/// Contains lists of stuff loaded from system-wide lst files.
class SystemCollections {
  SystemCollections._();

  static final Map<String, List<String>> _birthplaceMap = {};
  static final Map<String, List<String>> _cityMap = {};
  static final List<GameMode> _gameModeList = [];
  static final List<GameModeDisplay> _gameModeDisplayList = [];
  static final Map<String, List<String>> _hairStyleMap = {};
  static final Map<String, List<String>> _interestsMap = {};
  static final Map<String, List<String>> _locationMap = {};
  static final Map<String, List<String>> _phobiaMap = {};
  static final Map<String, Set<String>> _phraseMap = {};
  static final Map<String, List<String>> _speechMap = {};
  static final Map<String, Set<String>> _traitMap = {};
  static final Map<String, List<String>> _bodyStructureMap = {};
  static final Map<String, List<EquipSlot>> _equipSlotMap = {};
  static final Map<String, List<MigrationRule>> _migrationRuleMap = {};

  // ---------------------------------------------------------------------------
  // GameMode lookup
  // ---------------------------------------------------------------------------

  static GameMode? getGameModeNamed(String aString) {
    for (final GameMode gm in _gameModeList) {
      if (gm.getName().toLowerCase() == aString.toLowerCase()) return gm;
    }
    return null;
  }

  static GameMode? getGameModeWithDisplayName(String aString) {
    for (final GameMode gm in _gameModeList) {
      if (gm.getDisplayName().toLowerCase() == aString.toLowerCase()) return gm;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Unmodifiable list getters (return unmodifiable views)
  // ---------------------------------------------------------------------------

  static List<String> getUnmodifiableBirthplaceList() {
    List<String>? list = _birthplaceMap[SettingsHandler.getGameAsProperty().getName()];
    list ??= _birthplaceMap['*'];
    list ??= [];
    return List.unmodifiable(list);
  }

  static List<String> getUnmodifiableCityList() {
    List<String>? list = _cityMap[SettingsHandler.getGameAsProperty().getName()];
    list ??= _cityMap['*'];
    list ??= [];
    return List.unmodifiable(list);
  }

  static List<EquipSlot> getUnmodifiableEquipSlotList() {
    List<EquipSlot>? list =
        _equipSlotMap[SettingsHandler.getGameAsProperty().getName()];
    list ??= _equipSlotMap['*'];
    list ??= [];
    return List.unmodifiable(list);
  }

  static List<String> getUnmodifiableBodyStructureList() {
    List<String>? list =
        _bodyStructureMap[SettingsHandler.getGameAsProperty().getName()];
    list ??= _bodyStructureMap['*'];
    list ??= [];
    return List.unmodifiable(list);
  }

  static List<MigrationRule> getUnmodifiableMigrationRuleList(String gameModeName) {
    List<MigrationRule>? list = _migrationRuleMap[gameModeName];
    list ??= _migrationRuleMap['*'];
    list ??= [];
    return List.unmodifiable(list);
  }

  static List<GameMode> getUnmodifiableGameModeList() =>
      List.unmodifiable(_gameModeList);

  static List<GameModeDisplay> getUnmodifiableGameModeDisplayList() =>
      List.unmodifiable(_gameModeDisplayList);

  static List<String> getUnmodifiableHairStyleList() {
    List<String>? list = _hairStyleMap[SettingsHandler.getGameAsProperty().getName()];
    list ??= _hairStyleMap['*'];
    list ??= [];
    return List.unmodifiable(list);
  }

  static List<String> getUnmodifiableInterestsList() {
    List<String>? list = _interestsMap[SettingsHandler.getGameAsProperty().getName()];
    list ??= _interestsMap['*'];
    list ??= [];
    return List.unmodifiable(list);
  }

  static List<String> getUnmodifiableLocationList() {
    List<String>? list = _locationMap[SettingsHandler.getGameAsProperty().getName()];
    list ??= _locationMap['*'];
    list ??= [];
    return List.unmodifiable(list);
  }

  static List<String> getUnmodifiablePhobiaList() {
    List<String>? list = _phobiaMap[SettingsHandler.getGameAsProperty().getName()];
    list ??= _phobiaMap['*'];
    list ??= [];
    return List.unmodifiable(list);
  }

  static List<String> getUnmodifiablePhraseList() {
    Set<String>? phraseSet = _phraseMap[SettingsHandler.getGameAsProperty().getName()];
    phraseSet ??= _phraseMap['*'];
    if (phraseSet == null) return const [];
    return List<String>.from(phraseSet);
  }

  static List<String> getUnmodifiableSpeechList() {
    List<String>? list = _speechMap[SettingsHandler.getGameAsProperty().getName()];
    list ??= _speechMap['*'];
    list ??= [];
    return List.unmodifiable(list);
  }

  static List<String> getUnmodifiableTraitList() {
    Set<String>? traitSet = _traitMap[SettingsHandler.getGameAsProperty().getName()];
    traitSet ??= _traitMap['*'];
    if (traitSet == null) return const [];
    return List<String>.from(traitSet);
  }

  // ---------------------------------------------------------------------------
  // Mutators – add items to the various lists
  // ---------------------------------------------------------------------------

  static void addToBirthplaceList(String birthplace, String gameMode) {
    _birthplaceMap.putIfAbsent(gameMode, () => []);
    if (!_birthplaceMap[gameMode]!.contains(birthplace)) {
      _birthplaceMap[gameMode]!.add(birthplace);
    }
  }

  static void addToCityList(String city, String gameMode) {
    _cityMap.putIfAbsent(gameMode, () => []);
    if (!_cityMap[gameMode]!.contains(city)) {
      _cityMap[gameMode]!.add(city);
    }
  }

  static void addToEquipSlotsList(EquipSlot equipmentSlot, String gameMode) {
    _equipSlotMap.putIfAbsent(gameMode, () => []);
    if (!_equipSlotMap[gameMode]!.contains(equipmentSlot)) {
      _equipSlotMap[gameMode]!.add(equipmentSlot);
    }
  }

  static void addToBodyStructureList(String bodyStructure, String gameMode) {
    _bodyStructureMap.putIfAbsent(gameMode, () => []);
    if (!_bodyStructureMap[gameMode]!.contains(bodyStructure)) {
      _bodyStructureMap[gameMode]!.add(bodyStructure);
    }
  }

  static void addToMigrationRulesList(MigrationRule migrationRule, String gameMode) {
    _migrationRuleMap.putIfAbsent(gameMode, () => []);
    if (!_migrationRuleMap[gameMode]!.contains(migrationRule)) {
      _migrationRuleMap[gameMode]!.add(migrationRule);
    }
  }

  static void addToGameModeList(GameMode mode) {
    _gameModeList.add(mode);
    _gameModeDisplayList.add(GameModeDisplay(mode));
  }

  static void addToHairStyleList(String hairStyle, String gameMode) {
    _hairStyleMap.putIfAbsent(gameMode, () => []);
    if (!_hairStyleMap[gameMode]!.contains(hairStyle)) {
      _hairStyleMap[gameMode]!.add(hairStyle);
    }
    // Note: Java source adds hairStyle a second time unconditionally – preserved.
    _hairStyleMap[gameMode]!.add(hairStyle);
  }

  static void addToInterestsList(String interest, String gameMode) {
    _interestsMap.putIfAbsent(gameMode, () => []);
    if (!_interestsMap[gameMode]!.contains(interest)) {
      _interestsMap[gameMode]!.add(interest);
    }
  }

  static void addToLocationList(String location, String gameMode) {
    _locationMap.putIfAbsent(gameMode, () => []);
    if (!_locationMap[gameMode]!.contains(location)) {
      _locationMap[gameMode]!.add(location);
    }
  }

  static void addToPhobiaList(String phobia, String gameMode) {
    _phobiaMap.putIfAbsent(gameMode, () => []);
    if (!_phobiaMap[gameMode]!.contains(phobia)) {
      _phobiaMap[gameMode]!.add(phobia);
    }
  }

  static void addToPhraseList(String phrase, String gameMode) {
    _phraseMap.putIfAbsent(gameMode, () => {});
    _phraseMap[gameMode]!.add(phrase);
  }

  static void addToSpeechList(String speech, String gameMode) {
    _speechMap.putIfAbsent(gameMode, () => []);
    if (!_speechMap[gameMode]!.contains(speech)) {
      _speechMap[gameMode]!.add(speech);
    }
  }

  static void addToTraitList(String trait, String gameMode) {
    _traitMap.putIfAbsent(gameMode, () => {});
    _traitMap[gameMode]!.add(trait);
  }

  // ---------------------------------------------------------------------------
  // Clear / sort
  // ---------------------------------------------------------------------------

  static void clearEquipSlotsMap() => _equipSlotMap.clear();
  static void clearMigrationRuleMap() => _migrationRuleMap.clear();

  static void clearGameModeList() {
    _gameModeList.clear();
    _gameModeDisplayList.clear();
  }

  static void sortGameModeList() {
    _gameModeList.sort();
    _gameModeDisplayList.sort();
  }
}
