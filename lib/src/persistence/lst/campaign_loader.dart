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
// Translation of pcgen.persistence.lst.CampaignLoader

import 'package:flutter_pcgen/src/cdom/enumeration/integer_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/object_key.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/string_key.dart';
import 'package:flutter_pcgen/src/core/campaign.dart';
import 'package:flutter_pcgen/src/core/globals.dart';
import 'package:flutter_pcgen/src/persistence/lst/campaign_source_entry.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_file_loader.dart';
import 'package:flutter_pcgen/src/persistence/lst/lst_utils.dart';

/// Loads campaign (.pcc) files into the global campaign registry.
///
/// A .pcc file contains metadata (name, game mode, publisher, etc.) and lists
/// of LST data files for each object type (races, classes, feats, etc.).
class CampaignLoader {
  /// Token names that reference external .pcc sub-campaigns.
  static const String _pccToken = 'PCC';

  /// Maps PCC token names to their ListKey storage names.
  /// Values mirror the Java ListKey.FILE_* constants.
  static const Map<String, String> _fileTokenToListKey = {
    'RACE':            'FILE_RACE',
    'CLASS':           'FILE_CLASS',
    'FEAT':            'FILE_FEAT',
    'ABILITY':         'FILE_ABILITY',
    'ABILITYCATEGORY': 'FILE_ABILITY_CATEGORY',
    'SKILL':           'FILE_SKILL',
    'DEITY':           'FILE_DEITY',
    'DOMAIN':          'FILE_DOMAIN',
    'SPELL':           'FILE_SPELL',
    'TEMPLATE':        'FILE_TEMPLATE',
    'EQUIPMENT':       'FILE_EQUIP',
    'EQUIPMOD':        'FILE_EQUIP_MOD',
    'WEAPONPROF':      'FILE_WEAPON_PROF',
    'ARMORPROF':       'FILE_ARMOR_PROF',
    'SHIELDPROF':      'FILE_SHIELD_PROF',
    'LANGUAGE':        'FILE_LANGUAGE',
    'BIOSET':          'FILE_BIO_SET',
    'COMPANIONMOD':    'FILE_COMPANION_MOD',
    'KIT':             'FILE_KIT',
    'ALIGNMENT':       'FILE_ALIGNMENT',
    'STAT':            'FILE_STAT',
    'SAVE':            'FILE_SAVE',
    'SIZE':            'FILE_SIZE',
    'DATACONTROL':     'FILE_DATACTRL',
    'VARIABLE':        'FILE_VARIABLE',
    'DYNAMIC':         'FILE_DYNAMIC',
    'DATATABLE':       'FILE_DATATABLE',
    'GLOBALMOD':       'FILE_GLOBALMOD',
    'PCC':             'FILE_PCC',
    'LSTEXCLUDE':      'FILE_LST_EXCLUDE',
    'COVER':           'FILE_COVER',
  };

  /// All object-file list keys — used when merging sub-campaigns.
  static final List<ListKey<CampaignSourceEntry>> objectFileListKeys =
      const [
        'FILE_RACE', 'FILE_CLASS', 'FILE_COMPANION_MOD', 'FILE_SKILL',
        'FILE_ABILITY_CATEGORY', 'FILE_ABILITY', 'FILE_FEAT', 'FILE_DEITY',
        'FILE_DOMAIN', 'FILE_ARMOR_PROF', 'FILE_SHIELD_PROF', 'FILE_WEAPON_PROF',
        'FILE_EQUIP', 'FILE_SPELL', 'FILE_LANGUAGE', 'FILE_TEMPLATE',
        'FILE_EQUIP_MOD', 'FILE_KIT', 'FILE_BIO_SET', 'FILE_ALIGNMENT',
        'FILE_STAT', 'FILE_SAVE', 'FILE_SIZE', 'FILE_DATACTRL',
        'FILE_VARIABLE', 'FILE_DYNAMIC', 'FILE_DATATABLE', 'FILE_GLOBALMOD',
      ].map((n) => ListKey.getConstant<CampaignSourceEntry>(n)).toList();

  static final List<ListKey<CampaignSourceEntry>> otherFileListKeys =
      const ['FILE_LST_EXCLUDE', 'FILE_COVER']
          .map((n) => ListKey.getConstant<CampaignSourceEntry>(n))
          .toList();

  // Tracks campaigns already processed by initRecursivePccFiles to prevent loops.
  final List<Campaign> _inittedCampaigns = [];

  // ---------------------------------------------------------------------------
  // Primary loading entry point
  // ---------------------------------------------------------------------------

  /// Reads and parses the .pcc file at [filePath], creating a [Campaign] object
  /// and registering it in the global campaign list.
  ///
  /// Skips registration if a campaign for that URI is already loaded.
  Future<void> loadCampaignLstFile(Uri filePath) async {
    final content = await LstFileLoader.readFromURI(filePath.toString());
    if (content == null) return;

    final campaign = Campaign();
    campaign.setSourceUri(filePath);

    // Derive a key from the URI — last path segment without extension.
    final fileName = filePath.pathSegments.lastWhere((s) => s.isNotEmpty, orElse: () => '');
    final keyName = fileName.endsWith('.pcc')
        ? fileName.substring(0, fileName.length - 4)
        : fileName;
    campaign.setName(keyName);

    final lines = content.split(RegExp(LstFileLoader.lineSeparatorRegexp));
    for (int i = 0; i < lines.length; i++) {
      final raw = lines[i];
      final line = raw.trim();
      if (line.isEmpty || line.codeUnitAt(0) == LstFileLoader.lineCommentChar) continue;
      try {
        _parseLine(campaign, line, filePath);
      } catch (e) {
        print('CampaignLoader: error at $filePath line ${i + 1}: $e');
      }
    }

    if (Globals.getCampaignByUri(filePath) == null) {
      Globals.addCampaign(campaign);
    }
  }

  // ---------------------------------------------------------------------------
  // Line parser
  // ---------------------------------------------------------------------------

  void _parseLine(Campaign campaign, String line, Uri source) {
    // Each PCC line is a single TOKEN:value (no tab-separated multi-token rows).
    final (tag, value) = LstUtils.splitToken(line);
    if (tag.isEmpty) return;

    // File-list tokens
    final listKeyName = _fileTokenToListKey[tag];
    if (listKeyName != null) {
      _addFileEntry(campaign, listKeyName, value, source);
      return;
    }

    // Metadata tokens
    switch (tag) {
      case 'CAMPAIGN':
        campaign.setName(value);
        campaign.putString(StringKey.keyName, value);
        campaign.setDisplayName(value);

      case 'GAMEMODE':
        // Pipe-delimited list of compatible game modes.
        final lk = ListKey.getConstant<String>('GAMEMODES');
        for (final mode in value.split('|')) {
          final m = mode.trim();
          if (m.isNotEmpty) campaign.addToListFor(lk, m);
        }

      case 'TYPE':
        // Dot-delimited list of type strings stored on the campaign.
        final lk = ListKey.getConstant<String>('CAMPAIGN_TYPE');
        for (final t in value.split('.')) {
          final part = t.trim();
          if (part.isNotEmpty) campaign.addToListFor(lk, part);
        }

      case 'RANK':
        final rank = int.tryParse(value.trim());
        if (rank != null) campaign.putInt(IntegerKey.campaignRank, rank);

      case 'GENRE':
        campaign.putString(StringKey.genre, value);

      case 'SETTING':
        campaign.putString(StringKey.setting, value);

      case 'BOOKTYPE':
        campaign.addToListFor(ListKey.getConstant<String>('BOOK_TYPE'), value);

      case 'INFOTEXT':
        campaign.putString(StringKey.description, value);

      case 'HELP':
        campaign.putString(StringKey.help, value);

      case 'PUBNAMELONG':
        campaign.putString(StringKey.pubNameLong, value);

      case 'PUBNAMESHORT':
        campaign.putString(StringKey.pubNameShort, value);

      case 'PUBNAMEWEB':
        campaign.putString(StringKey.pubNameWeb, value);

      case 'SOURCELONG':
        campaign.putString(StringKey.sourceLong, value);

      case 'SOURCESHORT':
        campaign.putString(StringKey.sourceShort, value);

      case 'SOURCEWEB':
        campaign.putString(StringKey.sourceWeb, value);

      case 'SOURCEPAGE':
        campaign.putString(StringKey.sourcePage, value);

      case 'SOURCEDATE':
        campaign.putObject(CDOMObjectKey.getConstant<String>('SOURCE_DATE'), value);

      case 'SOURCELINK':
        campaign.putString(StringKey.sourceLink, value);

      case 'STATUS':
        campaign.putObject(CDOMObjectKey.getConstant<String>('STATUS'), value);

      case 'ISLICENSED':
        campaign.putObject(
            CDOMObjectKey.getConstant<bool>('IS_LICENSED'), _parseBool(value));

      case 'ISOGL':
        campaign.putObject(
            CDOMObjectKey.getConstant<bool>('IS_OGL'), _parseBool(value));

      case 'ISMATURE':
        campaign.putObject(
            CDOMObjectKey.getConstant<bool>('IS_MATURE'), _parseBool(value));

      case 'COPYRIGHT':
        campaign.addToListFor(
            ListKey.getConstant<String>('COPYRIGHT'), value);

      case 'LICENSE':
        campaign.addToListFor(
            ListKey.getConstant<String>('LICENSE'), value);

      case 'URL':
        // Format: WEBSITE|url|description  or  SURVEY|url|description
        campaign.addToListFor(
            ListKey.getConstant<String>('URL'), value);

      case 'INFO':
        campaign.addToListFor(
            ListKey.getConstant<String>('CAMPAIGN_INFO'), value);

      case 'LOGO':
        campaign.putObject(CDOMObjectKey.getConstant<String>('LOGO'), value);

      case 'MINVER':
        campaign.putString(StringKey.minver, value);

      case 'MINDEVVER':
        campaign.putString(StringKey.mindevver, value);

      // Skip PCGen-version prerequisites — not applicable in the Flutter port.
      case 'PREVERGE':
      case 'PREFILETYPE':
        break;

      default:
        // Unrecognised token — silently skip (matches Java behaviour).
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _addFileEntry(
      Campaign campaign, String listKeyName, String value, Uri source) {
    final cse = CampaignSourceEntry.getNewCSE(
        campaign, source.toString(), value.trim());
    if (cse == null) return;
    campaign.addToListFor(
        ListKey.getConstant<CampaignSourceEntry>(listKeyName), cse);
  }

  bool _parseBool(String value) =>
      value.trim().toLowerCase() == 'yes';

  // ---------------------------------------------------------------------------
  // Sub-campaign resolution
  // ---------------------------------------------------------------------------

  /// Resolves PCC sub-campaign references on [baseCampaign], loads any not yet
  /// in the global registry, and merges their file lists into [baseCampaign].
  void initRecursivePccFiles(Campaign baseCampaign) {
    if (_inittedCampaigns.contains(baseCampaign)) return;
    _inittedCampaigns.add(baseCampaign);

    final pccKey = ListKey.getConstant<CampaignSourceEntry>(_fileTokenToListKey[_pccToken]!);
    final subEntries = baseCampaign.getSafeListFor<CampaignSourceEntry>(pccKey);

    for (final entry in subEntries) {
      final subUri = Uri.tryParse(entry.getURI());
      if (subUri == null) continue;
      if (!subUri.path.toLowerCase().endsWith('.pcc')) continue;

      Campaign? subCampaign = Globals.getCampaignByUri(subUri);
      if (subCampaign == null) {
        // Load synchronously — initRecursivePccFiles is called after the async
        // discovery pass so files should already be on disk.
        _loadCampaignLstFileSync(subUri);
        subCampaign = Globals.getCampaignByUri(subUri);
      }

      if (subCampaign == null) continue;

      // Recurse into the sub-campaign first.
      initRecursivePccFiles(subCampaign);

      // Merge the sub-campaign's file lists up into the base.
      _mergeSubCampaign(baseCampaign, subCampaign);
    }
  }

  /// Synchronous fallback loader used inside [initRecursivePccFiles].
  void _loadCampaignLstFileSync(Uri filePath) {
    final content = LstFileLoader.readFromURISync(filePath.toString());
    if (content == null) return;

    final campaign = Campaign();
    campaign.setSourceUri(filePath);

    final fileName = filePath.pathSegments.lastWhere((s) => s.isNotEmpty, orElse: () => '');
    final keyName = fileName.endsWith('.pcc')
        ? fileName.substring(0, fileName.length - 4)
        : fileName;
    campaign.setName(keyName);

    final lines = content.split(RegExp(LstFileLoader.lineSeparatorRegexp));
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.codeUnitAt(0) == LstFileLoader.lineCommentChar) continue;
      try {
        _parseLine(campaign, line, filePath);
      } catch (_) {}
    }

    if (Globals.getCampaignByUri(filePath) == null) {
      Globals.addCampaign(campaign);
    }
  }

  /// Copies all file-list entries from [sub] into [base].
  void _mergeSubCampaign(Campaign base, Campaign sub) {
    for (final lk in objectFileListKeys) {
      base.addAllToListFor(lk, sub.getSafeListFor<CampaignSourceEntry>(lk));
    }
    for (final lk in otherFileListKeys) {
      base.addAllToListFor(lk, sub.getSafeListFor<CampaignSourceEntry>(lk));
    }
  }
}
