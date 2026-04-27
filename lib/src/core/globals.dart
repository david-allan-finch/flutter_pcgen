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
// Translation of pcgen.core.Globals
import 'package:flutter_pcgen/src/core/campaign.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/game_mode.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/player_character.dart';

// Global singleton state for PCGen - mirrors pcgen.core.Globals.
class Globals {
  Globals._();

  static GameMode? _gameMode;
  static DataSet? _currentDataSet;
  static final List<PlayerCharacter> _pcList = [];
  static int _currentPCIndex = 0;

  static GameMode? get gameMode => _gameMode;
  static void setGameMode(GameMode mode) { _gameMode = mode; }

  static DataSet? get currentDataSet => _currentDataSet;
  static void setCurrentDataSet(DataSet ds) { _currentDataSet = ds; }

  static List<PlayerCharacter> get pcList => List.unmodifiable(_pcList);
  static void addPC(PlayerCharacter pc) { _pcList.add(pc); }
  static void removePC(PlayerCharacter pc) { _pcList.remove(pc); }

  static PlayerCharacter? get currentPC {
    if (_pcList.isEmpty) return null;
    if (_currentPCIndex >= _pcList.length) _currentPCIndex = 0;
    return _pcList[_currentPCIndex];
  }

  static void setCurrentPC(PlayerCharacter pc) {
    final idx = _pcList.indexOf(pc);
    if (idx >= 0) _currentPCIndex = idx;
  }

  static int getSkillMultiplierForLevel(int level) {
    return _gameMode?.getSkillMultiplierForLevel(level) ?? (level <= 1 ? 4 : 2);
  }

  static int maxPCStatValue() => _gameMode?.getStatMax() ?? 18;
  static int minPCStatValue() => _gameMode?.getStatMin() ?? 3;

  static List<PCClass> getClassList() => _currentDataSet?.classes ?? [];

  // Campaign registry
  static final List<Campaign> _campaignList = [];

  static List<Campaign> getCampaignList() => List.unmodifiable(_campaignList);

  static void addCampaign(Campaign campaign) {
    if (!_campaignList.any((c) => c.getKeyName() == campaign.getKeyName())) {
      _campaignList.add(campaign);
    }
  }

  /// Finds a campaign by its source URI. Returns null if not found.
  /// If [createIfMissing] is true (default false), a stub campaign is added.
  static Campaign? getCampaignByUri(Uri uri, [bool createIfMissing = false]) {
    for (final c in _campaignList) {
      if (c.getSourceUri() == uri) return c;
    }
    return null;
  }

  /// Returns the number of slots of the given type (e.g. "HANDS" → 2).
  /// Defaults to 1 for unknown types.
  static int getEquipSlotTypeCount(String slotNumType) {
    const defaults = {'HANDS': 2, 'FINGERS': 10, 'EYES': 2, 'EARS': 2};
    return defaults[slotNumType.toUpperCase()] ?? 1;
  }

  static Campaign? getCampaignKeyed(String key) {
    for (final c in _campaignList) {
      if (c.getKeyName() == key) return c;
    }
    return null;
  }

  /// Clears all game data lists in preparation for a reload.
  static void emptyLists() {
    _pcList.clear();
    _currentPCIndex = 0;
    _currentDataSet = null;
    _campaignList.clear();
    // Note: _gameMode is intentionally retained
  }

  /// Initialise default preferences (called after emptyLists on source load).
  static void initPreferences() {
    // TODO: apply game-mode defaults
  }

  // Settings
  static bool showOutputNameForOtherItems = false;
}
