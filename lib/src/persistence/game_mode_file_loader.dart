//
// Copyright 2010 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.persistence.GameModeFileLoader

import 'dart:io';

import 'package:flutter_pcgen/src/core/game_mode.dart';
import 'package:flutter_pcgen/src/core/system_collections.dart';
import 'package:flutter_pcgen/src/system/p_c_gen_task.dart';
import 'package:flutter_pcgen/src/system/configuration_settings.dart';
import 'package:flutter_pcgen/src/system/language_bundle.dart';
import 'package:flutter_pcgen/src/persistence/persistence_layer_exception.dart';
import 'package:flutter_pcgen/src/persistence/lst/game_mode_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/stats_and_checks_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/level_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/size_adjustment_loader.dart';
import 'package:flutter_pcgen/src/core/bio_set.dart';
import 'package:flutter_pcgen/src/persistence/lst/bio_set_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/load_info_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/point_buy_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/trait_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/location_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/equip_slot_loader.dart';

/// Loads game mode data files (miscinfo.lst, statsandchecks.lst, level.lst,
/// sizeAdjustment.lst, etc.) from the system/gameModes directory tree.
///
/// A valid game mode directory must contain both miscinfo.lst and
/// statsandchecks.lst to be recognised.
class GameModeFileLoader extends PCGenTask {
  @override
  String getMessage() =>
      LanguageBundle.getString('in_taskLoadGameModes');

  @override
  Future<void> run() async {
    final gameFiles = _getGameFilesList();
    if (gameFiles.isEmpty) return;
    setMaximum(gameFiles.length + 1);
    await _loadGameModes(gameFiles);
  }

  /// Returns a list of subdirectory names inside system/gameModes/ that
  /// contain both miscinfo.lst and statsandchecks.lst.
  static List<String> _getGameFilesList() {
    final gameModeDir = Directory(
        '${ConfigurationSettings.getSystemsDir()}${Platform.pathSeparator}gameModes');
    if (!gameModeDir.existsSync()) return [];

    final List<String> result = [];
    for (final entry in gameModeDir.listSync()) {
      if (entry is! Directory) continue;
      final hasStats = File('${entry.path}${Platform.pathSeparator}statsandchecks.lst').existsSync();
      final hasMisc = File('${entry.path}${Platform.pathSeparator}miscinfo.lst').existsSync();
      if (hasStats && hasMisc) {
        result.add(entry.uri.pathSegments
            .where((s) => s.isNotEmpty)
            .last);
      }
    }
    return result;
  }

  Future<void> _loadGameModes(List<String> gameFiles) async {
    SystemCollections.clearGameModeList();
    final gameModeDir = Directory(
        '${ConfigurationSettings.getSystemsDir()}${Platform.pathSeparator}gameModes');
    int progress = 0;

    for (final gameFile in gameFiles) {
      final specDir = Directory('${gameModeDir.path}${Platform.pathSeparator}$gameFile');
      final miscInfoFile = File('${specDir.path}${Platform.pathSeparator}miscinfo.lst');

      final gameMode = await _loadGameModeMiscInfo(gameFile, miscInfoFile.uri);
      if (gameMode != null) {
        await _loadGameModeFiles(gameMode, specDir, gameFile, gameModeDir);
        SystemCollections.addToGameModeList(gameMode);
      } else {
        print('Warning: no data for game mode: $gameFile');
      }

      setProgress(++progress);
    }

    SystemCollections.sortGameModeList();
  }

  /// Reads miscinfo.lst and constructs a GameMode object from it.
  Future<GameMode?> _loadGameModeMiscInfo(String name, Uri uri) async {
    try {
      final file = File.fromUri(uri);
      if (!file.existsSync()) return null;
      final lines = file.readAsLinesSync();
      final gameMode = GameMode(name);
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty || line.startsWith('#')) continue;
        GameModeLoader.parseMiscGameInfoLine(gameMode, line, uri, i + 1);
      }
      _addDefaultUnitSet(gameMode);
      _addDefaultTabInfo(gameMode);
      return gameMode;
    } on PersistenceLayerException catch (e) {
      print('Error loading game mode misc info for $name: $e');
      return null;
    }
  }

  /// Loads all the supporting LST files for a game mode.
  Future<void> _loadGameModeFiles(
      GameMode gameMode, Directory specDir, String gameFile, Directory gameModeDir) async {
    final gmName = gameMode.getName();

    // level.lst / rules.lst (custom line-by-line format)
    _loadInfoFile(gameMode, File('${specDir.path}/level.lst').uri, 'level');
    _loadInfoFile(gameMode, File('${specDir.path}/rules.lst').uri, 'rules');

    // Standard LST files
    _loadModeLstFile(gameMode, specDir, gameModeDir, 'statsandchecks.lst', StatsAndChecksLoader(gameMode.getModeContext()));
    _loadModeLstFile(gameMode, specDir, gameModeDir, 'sizeAdjustment.lst', SizeAdjustmentLoader(), required: false);
    _loadModeLstFile(gameMode, specDir, gameModeDir, 'load.lst', LoadInfoLoader());
    _loadModeLstFile(gameMode, specDir, gameModeDir, 'bio/biosettings.lst', BioSetLoader(BioSet()));

    // Point buy
    _loadPointBuyFile(gameMode, specDir, gameModeDir, gameFile);

    // Traits, locations, equipment slots
    await _loadTraitsFile(gameMode, specDir, gameModeDir);
    await _loadLocationsFile(gameMode, specDir, gameModeDir);
    await _loadEquipSlotsFile(gameMode, specDir, gameModeDir);
  }

  void _loadInfoFile(GameMode gameMode, Uri uri, String type) {
    final file = File.fromUri(uri);
    if (!file.existsSync()) return;
    final lines = file.readAsLinesSync();
    String xpTable = '';
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      if (type == 'level') {
        xpTable = LevelLoader.parseLine(gameMode, line, i + 1, uri, xpTable);
      }
      // rules lines are handled by ruleCheckLoader (TODO)
    }
  }

  void _loadModeLstFile(
      GameMode gameMode, Directory specDir, Directory gameModeDir, String lstFileName,
      dynamic loader, {bool required = true}) {
    // Try game-mode-specific file first, then 'default' game mode
    final candidates = [
      File('${specDir.path}/$lstFileName'),
      File('${gameModeDir.path}/default/$lstFileName'),
    ];
    for (final file in candidates) {
      if (file.existsSync()) {
        try {
          loader.loadLstFile(gameMode.getModeContext(), file.uri, gameMode.getName());
          return;
        } on PersistenceLayerException {
          // Try next candidate
        }
      }
    }
    if (required) {
      print('Warning: game mode ${gameMode.getName()} is missing file $lstFileName');
    }
  }

  void _loadPointBuyFile(
      GameMode gameMode, Directory specDir, Directory gameModeDir, String gameFile) {
    final loader = PointBuyLoader();
    // TODO: check CustomData.customPurchaseModeFilePath first
    _loadModeLstFile(gameMode, specDir, gameModeDir, 'pointbuymethods.lst', loader, required: false);
  }

  Future<void> _loadTraitsFile(
      GameMode gameMode, Directory specDir, Directory gameModeDir) async {
    final loader = TraitLoader();
    loader.setGameMode(gameMode.getName());
    await _loadLineModeLstFile(loader, specDir, gameModeDir, 'bio/traits.lst');
  }

  Future<void> _loadLocationsFile(
      GameMode gameMode, Directory specDir, Directory gameModeDir) async {
    final loader = LocationLoader();
    loader.setGameMode(gameMode.getName());
    await _loadLineModeLstFile(loader, specDir, gameModeDir, 'bio/locations.lst');
  }

  Future<void> _loadEquipSlotsFile(
      GameMode gameMode, Directory specDir, Directory gameModeDir) async {
    final loader = EquipSlotLoader();
    loader.setGameMode(gameMode.getName());
    await _loadLineModeLstFile(loader, specDir, gameModeDir, 'equipmentslots.lst');
  }

  /// Loads a single-file LST resource using a loader that accepts a bare URI
  /// (i.e. LstLineFileLoader subclasses such as TraitLoader, LocationLoader).
  ///
  /// Tries the game-mode-specific directory first, then falls back to 'default'.
  Future<void> _loadLineModeLstFile(
      dynamic loader, Directory specDir, Directory gameModeDir, String lstFileName) async {
    for (final dir in [specDir, Directory('${gameModeDir.path}/default')]) {
      final file = File('${dir.path}/$lstFileName');
      if (file.existsSync()) {
        await loader.loadLstFile(null, file.uri);
        return;
      }
    }
  }

  static void _addDefaultUnitSet(GameMode gameMode) {
    // TODO: add default UnitSet if none defined in miscinfo.lst
  }

  static void _addDefaultTabInfo(GameMode gameMode) {
    // TODO: add default TabInfo entries for each Tab value
  }
}
