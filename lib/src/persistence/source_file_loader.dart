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

import 'package:flutter_pcgen/src/core/ability.dart';
import 'package:flutter_pcgen/src/core/ability_category.dart';
import 'package:flutter_pcgen/src/core/armor_prof.dart';
import 'package:flutter_pcgen/src/core/campaign.dart';
import 'package:flutter_pcgen/src/core/data_set.dart';
import 'package:flutter_pcgen/src/core/deity.dart';
import 'package:flutter_pcgen/src/core/domain.dart';
import 'package:flutter_pcgen/src/core/equipment.dart';
import 'package:flutter_pcgen/src/core/game_mode.dart';
import 'package:flutter_pcgen/src/core/language.dart';
import 'package:flutter_pcgen/src/core/pc_class.dart';
import 'package:flutter_pcgen/src/core/pc_template.dart';
import 'package:flutter_pcgen/src/core/race.dart';
import 'package:flutter_pcgen/src/core/shield_prof.dart';
import 'package:flutter_pcgen/src/core/skill.dart';
import 'package:flutter_pcgen/src/core/spell/spell.dart';
import 'package:flutter_pcgen/src/core/system_collections.dart';
import 'package:flutter_pcgen/src/core/pc_stat.dart';
import 'package:flutter_pcgen/src/core/pc_alignment.dart';
import 'package:flutter_pcgen/src/core/weapon_prof.dart';
import 'package:flutter_pcgen/src/core/armor_prof.dart';
import 'package:flutter_pcgen/src/facade/core/ui_delegate.dart';
import 'package:flutter_pcgen/src/rules/context/load_context.dart' hide Campaign, CampaignSourceEntry;
import 'package:flutter_pcgen/src/system/p_c_gen_task.dart';
import 'package:flutter_pcgen/src/system/language_bundle.dart';
import 'package:flutter_pcgen/src/persistence/persistence_layer_exception.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/persistence/lst/ability_category_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/ability_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/campaign_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/campaign_source_entry.dart';
import 'package:flutter_pcgen/src/persistence/lst/companion_mod_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/feat_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/generic_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/global_modifier_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/kit_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/p_c_class_loader.dart';

/// Loads source data files for a selected set of campaigns into the game data
/// context. Orchestrates all the type-specific loaders in dependency order.
class SourceFileLoader extends PCGenTask {
  // Loaders keyed by their FILE_* list-key name.
  // Values may be LstObjectFileLoader or LstLineFileLoader — called via
  // duck-typed loadLstFiles(LoadContext, List<CampaignSourceEntry>).
  late final Map<String, dynamic> _loaders;

  // Per-filetype lists of source entries collected from selected campaigns.
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

  SourceFileLoader(UIDelegate delegate, Iterable<Campaign> campaigns,
      String gameModeNamed)
      : _uiDelegate = delegate,
        _selectedCampaigns = campaigns.toList(),
        _selectedGame = SystemCollections.getGameModeNamed(gameModeNamed) ??
            GameMode(gameModeNamed) {
    _loaders = {
      'FILE_CLASS':            PCClassLoader(),
      'FILE_ABILITY':          AbilityLoader(),
      'FILE_FEAT':             FeatLoader(),
      'FILE_KIT':              KitLoader(),
      'FILE_COMPANION_MOD':    CompanionModLoader(),
      'FILE_ABILITYCATEGORY':  AbilityCategoryLoader(),
      'FILE_ABILITY_CATEGORY': AbilityCategoryLoader(),
      'FILE_RACE':             GenericLoader<Race>(() => Race()),
      'FILE_SKILL':            GenericLoader<Skill>(() => Skill()),
      'FILE_DEITY':            GenericLoader<Deity>(() => Deity()),
      'FILE_DOMAIN':           GenericLoader<Domain>(() => Domain()),
      'FILE_SPELL':            GenericLoader<Spell>(() => Spell()),
      'FILE_LANGUAGE':         GenericLoader<Language>(() => Language()),
      'FILE_TEMPLATE':         GenericLoader<PCTemplate>(() => PCTemplate()),
      'FILE_EQUIP':            GenericLoader<Equipment>(() => Equipment()),
      'FILE_EQUIP_MOD':        GenericLoader<Equipment>(() => Equipment()),
      'FILE_WEAPON_PROF':      GenericLoader<WeaponProf>(() => WeaponProf()),
      'FILE_ARMOR_PROF':       GenericLoader<ArmorProf>(() => ArmorProf()),
      'FILE_SHIELD_PROF':      GenericLoader<ShieldProf>(() => ShieldProf()),
      'FILE_GLOBALMOD':        GlobalModifierLoader(),
    };
  }

  @override
  String getMessage() => LanguageBundle.getString('in_taskLoadSources');

  @override
  Future<void> run() async {
    try {
      await _loadCampaigns();
    } on PersistenceLayerException catch (e) {
      _uiDelegate.showErrorMessage('PCGen', 'Failed to load sources: $e');
    }
  }

  Future<void> _loadCampaigns() async {
    _collectFileEntries();

    final total = _fileLists.values.fold(0, (sum, list) => sum + list.length);
    setMaximum(total);

    LoadContext context;
    try {
      context = _selectedGame.getModeContext();
    } catch (_) {
      // modeContext not yet initialised — nothing can be loaded
      return;
    }

    // Load in dependency order matching Java SourceFileLoader
    await _loadFileType('FILE_DATACTRL', context);
    await _loadFileType('FILE_VARIABLE', context);
    await _loadFileType('FILE_DYNAMIC', context);
    await _loadFileType('FILE_GLOBALMOD', context);
    await _loadFileType('FILE_TABLE', context);

    await _loadFileType('FILE_STAT', context);
    await _loadFileType('FILE_SAVE', context);
    await _loadFileType('FILE_ALIGNMENT', context);
    await _loadFileType('FILE_BIO_SET', context);
    await _loadFileType('FILE_SIZE', context);

    await _loadFileType('FILE_RACE', context);
    await _loadFileType('FILE_CLASS', context);
    await _loadFileType('FILE_COMPANION_MOD', context);
    await _loadFileType('FILE_SKILL', context);
    await _loadFileType('FILE_ABILITY_CATEGORY', context);
    await _loadFileType('FILE_ABILITY', context);
    await _loadFileType('FILE_FEAT', context);
    await _loadFileType('FILE_TEMPLATE', context);
    await _loadFileType('FILE_DEITY', context);
    await _loadFileType('FILE_DOMAIN', context);
    await _loadFileType('FILE_SPELL', context);
    await _loadFileType('FILE_LANGUAGE', context);
    await _loadFileType('FILE_WEAPON_PROF', context);
    await _loadFileType('FILE_ARMOR_PROF', context);
    await _loadFileType('FILE_SHIELD_PROF', context);
    await _loadFileType('FILE_EQUIP', context);
    await _loadFileType('FILE_EQUIP_MOD', context);
    await _loadFileType('FILE_KIT', context);

    _dataset = DataSet()
      ..gameModeStr = _selectedGame.getName()
      ..campaigns.addAll(_selectedCampaigns);

    // Extract registered objects from the reference context into the DataSet.
    final ref = context.getReferenceContext();
    _dataset!.races   .addAll(ref.getAllConstructed<Race>(Race));
    _dataset!.classes .addAll(ref.getAllConstructed<PCClass>(PCClass));
    _dataset!.skills  .addAll(ref.getAllConstructed<Skill>(Skill));
    _dataset!.stats   .addAll(ref.getAllConstructed<PCStat>(PCStat));
    _dataset!.alignments.addAll(ref.getAllConstructed<PCAlignment>(PCAlignment));
    _dataset!.deities .addAll(ref.getAllConstructed<Deity>(Deity));
    _dataset!.domains .addAll(ref.getAllConstructed<Domain>(Domain));
    _dataset!.languages.addAll(ref.getAllConstructed<Language>(Language));
    _dataset!.templates.addAll(ref.getAllConstructed<PCTemplate>(PCTemplate));
    _dataset!.equipment.addAll(ref.getAllConstructed<Equipment>(Equipment));
    for (final ability in ref.getAllConstructed<Ability>(Ability)) {
      _dataset!.addAbilityFlat(ability);
    }

    final allAbilities = _dataset!.getAllAbilities();
    print('DataSet populated: ${_dataset!.races.length} races, '
        '${_dataset!.classes.length} classes, '
        '${_dataset!.skills.length} skills, '
        '${allAbilities.length} abilities/feats');
  }

  /// Collects all file-type entries from the selected campaigns.
  ///
  /// Sub-campaign file lists are already merged into parent campaigns by
  /// [CampaignLoader.initRecursivePccFiles], so a flat iteration suffices.
  void _collectFileEntries() {
    _fileLists.clear();
    final allKeys = [
      ...CampaignLoader.objectFileListKeys,
      ...CampaignLoader.otherFileListKeys,
    ];
    final seen = <String>{};
    for (final campaign in _selectedCampaigns) {
      final campaignKey = campaign.getKeyName();
      if (!seen.add(campaignKey)) continue;
      for (final lk in allKeys) {
        final entries =
            campaign.getSafeListFor<CampaignSourceEntry>(lk);
        if (entries.isNotEmpty) {
          _fileLists.putIfAbsent(lk.toString(), () => []).addAll(entries);
        }
      }
    }
  }

  Future<void> _loadFileType(String listKeyName, LoadContext context) async {
    final rawEntries = _fileLists[listKeyName];
    if (rawEntries == null || rawEntries.isEmpty) return;

    final entries = rawEntries.cast<CampaignSourceEntry>();
    final loader = _loaders[listKeyName];

    if (loader != null) {
      try {
        await loader.loadLstFiles(context, entries);
      } catch (e) {
        print('SourceFileLoader: error loading $listKeyName: $e');
      }
    }

    setProgress(getProgress() + entries.length);
  }

  // ---------------------------------------------------------------------------
  // Public accessors
  // ---------------------------------------------------------------------------

  String getOGL() => _sec15.toString();
  String getLicenses() => _licensesToDisplay.toString();
  String getMatureInfo() => _matureCampaigns.toString();

  DataSet? getDataSetFacade() => _dataset;

  List<Campaign> getCampaigns() => List.unmodifiable(_selectedCampaigns);
}
