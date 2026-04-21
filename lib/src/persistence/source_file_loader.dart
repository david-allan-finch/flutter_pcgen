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
// Translation of pcgen.persistence.SourceFileLoader

import 'package:flutter_pcgen/src/core/campaign.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/game_mode.dart';
import 'package:flutter_pcgen/src/core/globals.dart';
import 'package:flutter_pcgen/src/core/system_collections.dart';
import 'package:flutter_pcgen/src/facade/core/ui_delegate.dart';
import 'package:flutter_pcgen/src/system/p_c_gen_task.dart';
import 'package:flutter_pcgen/src/system/language_bundle.dart';
import 'persistence_layer_exception.dart';
import 'lst/campaign_loader.dart';
import 'lst/campaign_source_entry.dart';

/// Loads source data files for a selected set of campaigns into the game data
/// context. Orchestrates all the type-specific loaders (class, race, deity,
/// spell, skill, ability, equipment, etc.) in the correct dependency order.
class SourceFileLoader extends PCGenTask {
  // Loaders for each data type (stubs — full implementations are in lst/)
  final dynamic _classLoader = _Stub('PCClassLoader');
  final dynamic _languageLoader = _Stub('LanguageLoader');
  final dynamic _abilityCategoryLoader = _Stub('AbilityCategoryLoader');
  final dynamic _companionModLoader = _Stub('CompanionModLoader');
  final dynamic _kitLoader = _Stub('KitLoader');
  final dynamic _bioLoader = _Stub('BioSetLoader');
  final dynamic _abilityLoader = _Stub('AbilityLoader');
  final dynamic _featLoader = _Stub('FeatLoader');
  final dynamic _templateLoader = _Stub('TemplateLoader');
  final dynamic _equipmentLoader = _Stub('EquipmentLoader');
  final dynamic _eqModLoader = _Stub('EqModLoader');
  final dynamic _raceLoader = _Stub('RaceLoader');
  final dynamic _skillLoader = _Stub('SkillLoader');
  final dynamic _wProfLoader = _Stub('WeaponProfLoader');
  final dynamic _aProfLoader = _Stub('ArmorProfLoader');
  final dynamic _sProfLoader = _Stub('ShieldProfLoader');
  final dynamic _deityLoader = _Stub('DeityLoader');
  final dynamic _domainLoader = _Stub('DomainLoader');
  final dynamic _savesLoader = _Stub('SavesLoader');
  final dynamic _alignmentLoader = _Stub('AlignmentLoader');
  final dynamic _statLoader = _Stub('StatLoader');
  final dynamic _spellLoader = _Stub('SpellLoader');
  final dynamic _dataControlLoader = _Stub('CDOMControlLoader');
  final dynamic _variableLoader = _Stub('VariableLoader');
  final dynamic _tableLoader = _Stub('TableLoader');
  final dynamic _globalModifierLoader = _Stub('GlobalModifierLoader');
  final dynamic _dynamicLoader = _Stub('DynamicLoader');

  // Per-filetype lists of source entries (ListKey → [CampaignSourceEntry])
  final Map<String, List<dynamic>> _fileLists = {};

  // License / OGL text accumulation
  final StringBuffer _sec15 = StringBuffer();
  final StringBuffer _licensesToDisplay = StringBuffer();
  final StringBuffer _matureCampaigns = StringBuffer();
  final List<dynamic> _licenseFiles = [];

  bool _showLicensed = true;
  bool _showMature = false;
  bool _showOGL = false;

  final List<Campaign> _selectedCampaigns;
  final GameMode _selectedGame;
  DataSet? _dataset;

  final UIDelegate _uiDelegate;

  SourceFileLoader(UIDelegate delegate, Iterable<Campaign> campaigns, String gameModeNamed)
      : _uiDelegate = delegate,
        _selectedCampaigns = campaigns.toList(),
        _selectedGame = SystemCollections.getGameModeNamed(gameModeNamed) ?? GameMode(gameModeNamed);

  @override
  String getMessage() => LanguageBundle.getString('in_taskLoadSources');

  @override
  Future<void> run() async {
    Globals.emptyLists();
    try {
      await _loadCampaigns();
    } on PersistenceLayerException catch (e) {
      _uiDelegate.showErrorMessage('PCGen', 'Failed to load sources: $e');
    }
  }

  Future<void> _loadCampaigns() async {
    // 1. Collect all file entries from selected campaigns (incl. dependencies)
    _collectFileEntries();

    // 2. Count total files for progress reporting
    final total = _fileLists.values.fold(0, (sum, list) => sum + list.length);
    setMaximum(total);

    // 3. Load data control / variable definitions first
    await _loadFileType('FILE_DATACONTROL', _dataControlLoader);
    await _loadFileType('FILE_VARIABLE', _variableLoader);
    await _loadFileType('FILE_DYNAMIC', _dynamicLoader);
    await _loadFileType('FILE_GLOBALMODIFIER', _globalModifierLoader);
    await _loadFileType('FILE_TABLE', _tableLoader);

    // 4. Game primitives
    await _loadFileType('FILE_STAT', _statLoader);
    await _loadFileType('FILE_SAVE', _savesLoader);
    await _loadFileType('FILE_ALIGNMENT', _alignmentLoader);
    await _loadFileType('FILE_BIO_SET', _bioLoader);
    await _loadFileType('FILE_SIZE', _Stub('SizeLoader'));

    // 5. Core game objects
    await _loadFileType('FILE_RACE', _raceLoader);
    await _loadFileType('FILE_CLASS', _classLoader);
    await _loadFileType('FILE_COMPANION_MOD', _companionModLoader);
    await _loadFileType('FILE_SKILL', _skillLoader);
    await _loadFileType('FILE_ABILITYCATEGORY', _abilityCategoryLoader);
    await _loadFileType('FILE_ABILITY', _abilityLoader);
    await _loadFileType('FILE_FEAT', _featLoader);
    await _loadFileType('FILE_TEMPLATE', _templateLoader);
    await _loadFileType('FILE_DEITY', _deityLoader);
    await _loadFileType('FILE_DOMAIN', _domainLoader);
    await _loadFileType('FILE_SPELL', _spellLoader);
    await _loadFileType('FILE_LANGUAGE', _languageLoader);
    await _loadFileType('FILE_WEAPONPROF', _wProfLoader);
    await _loadFileType('FILE_ARMORPROF', _aProfLoader);
    await _loadFileType('FILE_SHIELDPROF', _sProfLoader);
    await _loadFileType('FILE_EQUIPMENT', _equipmentLoader);
    await _loadFileType('FILE_EQMODIFIER', _eqModLoader);
    await _loadFileType('FILE_KIT', _kitLoader);

    // 6. Build the DataSet facade
    _dataset = DataSet(_selectedGame, _selectedCampaigns);
  }

  /// Traverses the campaign dependency tree and collects file entries by type.
  void _collectFileEntries() {
    final visited = <String>{};
    final queue = List<Campaign>.from(_selectedCampaigns);
    while (queue.isNotEmpty) {
      final campaign = queue.removeAt(0);
      final key = campaign.getKeyName();
      if (visited.contains(key)) continue;
      visited.add(key);

      // Add the campaign's file entries to our lists
      // TODO: iterate campaign.getSafeListFor(ListKey.FILE_*) for each type

      // Enqueue any SUB-CAMPAIGN dependencies
      // TODO: for (final sub in campaign.getSubCampaigns()) { queue.add(sub); }
    }
  }

  Future<void> _loadFileType(String listKeyName, dynamic loader) async {
    final entries = _fileLists[listKeyName] ?? [];
    for (final entry in entries) {
      try {
        // TODO: loader.loadLstFile(context, entry.getUri(), entry.getCampaign())
      } on PersistenceLayerException catch (e) {
        print('Error loading $listKeyName entry: $e');
      }
      setProgress(getProgress() + 1);
    }
  }

  // ---------------------------------------------------------------------------
  // Public accessors
  // ---------------------------------------------------------------------------

  String getOGL() => _sec15.toString();
  String getLicenses() => _licensesToDisplay.toString();
  String getMatureInfo() => _matureCampaigns.toString();

  /// Returns the DataSet containing all loaded game data.
  DataSet? getDataSetFacade() => _dataset;

  List<Campaign> getCampaigns() => List.unmodifiable(_selectedCampaigns);
}

// ---------------------------------------------------------------------------
// Internal stub — placeholder for loaders not yet fully ported
// ---------------------------------------------------------------------------

class _Stub {
  final String name;
  _Stub(this.name);

  void loadLstFile(dynamic context, Uri uri, String source) {
    // TODO: implement $name.loadLstFile
  }
}
