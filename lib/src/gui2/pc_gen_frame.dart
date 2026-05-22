//
// Copyright 2008 Connor Petty <cpmeister@users.sourceforge.net>
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
// Translation of pcgen.gui2.PCGenFrame

import 'dart:convert' show JsonEncoder;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_pcgen/src/gui2/startup/data_packs_screen.dart';
import 'package:flutter_pcgen/src/gui2/startup/character_archive_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pcgen/src/gui2/ui_context.dart';
import 'package:flutter_pcgen/src/gui2/ui_property_context.dart';
import 'package:flutter_pcgen/src/gui2/pc_gen_action_map.dart';
import 'package:flutter_pcgen/src/gui2/pc_gen_menu_bar.dart';
import 'package:flutter_pcgen/src/gui2/pc_gen_status_bar.dart';
import 'package:flutter_pcgen/src/gui2/character_tabs.dart';
import 'package:flutter_pcgen/src/gui2/info_guide_pane.dart';
import 'package:flutter_pcgen/src/core/campaign.dart';
import 'package:flutter_pcgen/src/facade/core/character_facade.dart';
import 'package:flutter_pcgen/src/facade/core/source_selection_facade.dart';
import 'package:flutter_pcgen/src/facade/core/data_set_facade.dart';
import 'package:flutter_pcgen/src/facade/core/ui_delegate.dart';
import 'package:flutter_pcgen/src/facade/util/default_reference_facade.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/sources/source_selection_dialog.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';
import 'package:flutter_pcgen/src/persistence/lst/generic_loader.dart';
import 'package:flutter_pcgen/src/io/character_file_io.dart';
import 'package:flutter_pcgen/src/io/character_text_export.dart';
import 'package:flutter_pcgen/src/io/pcg_character_io.dart';

import 'package:flutter_pcgen/src/persistence/source_file_loader.dart';
import 'package:flutter_pcgen/src/system/character_manager.dart';
import 'package:flutter_pcgen/src/core/globals.dart';
import 'package:flutter_pcgen/src/cdom/enumeration/list_key.dart';
import 'package:flutter_pcgen/src/version.dart';

/// The main window for PCGen. Also responsible for global UI functions
/// such as message dialogs.
class PCGenFrame extends StatefulWidget {
  final UIContext uiContext;

  const PCGenFrame(this.uiContext, {super.key});

  @override
  State<PCGenFrame> createState() => PCGenFrameState();
}

class PCGenFrameState extends State<PCGenFrame> {
  late final PCGenActionMap actionMap;
  late final GlobalKey<PCGenStatusBarState> _statusBarKey;
  late final GlobalKey<CharacterTabsState> _characterTabsKey;

  final DefaultReferenceFacade<CharacterFacade> _currentCharacterRef =
      DefaultReferenceFacade();
  final DefaultReferenceFacade<DataSetFacade> _currentDataSetRef =
      DefaultReferenceFacade();

  String? _title;

  @override
  void initState() {
    super.initState();
    _statusBarKey = GlobalKey();
    _characterTabsKey = GlobalKey();
    actionMap = PCGenActionMap(this, widget.uiContext);
    _updateTitle();
    // Reactively update the window title whenever the current character's name changes.
    currentCharacter.addListener(_updateTitle);
    WidgetsBinding.instance.addPostFrameCallback((_) => startPCGenFrame());
  }

  @override
  void dispose() {
    currentCharacter.removeListener(_updateTitle);
    super.dispose();
  }

  void startPCGenFrame() {
    // Perform startup tasks: maybe load campaign, character, or sources
    _doStartup();
  }

  void _doStartup() {
    // Delay so the OS window is fully focused before we show a dialog.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _CharacterLauncherDialog(
          onLoadCharacter: _loadCharacterWithSources,
          onNewCharacter: showSourceSelectionDialog,
        ),
      );
    });
  }

  /// Load sources matching the PCG file's CAMPAIGN header then load the character.
  Future<void> _loadCharacterWithSources(String path, Map<String, String> header) async {
    if (!mounted) return;
    final gameModeName  = header['gameMode'] ?? '35e';
    final gameModeKey   = gameModeName.toLowerCase();
    final campaignNames = (header['campaigns'] ?? '').split('|')
        .map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    // Match the character's CAMPAIGN: lines to locally available PCC files.
    final allCampaigns = Globals.getCampaignList();
    final matched = <Campaign>[];
    for (final name in campaignNames) {
      final nameLower = name.toLowerCase();
      final found = allCampaigns.where((c) =>
          c.getDisplayName().toLowerCase() == nameLower ||
          c.getKeyName().toLowerCase() == nameLower).firstOrNull;
      if (found != null) matched.add(found);
    }

    // Check if the cached dataset for this game mode was built from the same
    // campaigns.  If so, reuse it; if not, reload with the correct sources.
    final cachedCampaigns = datasetRegistryCampaigns[gameModeKey];
    final neededCampaigns = matched.map((c) => c.getDisplayName().toLowerCase()).toSet();
    final cacheMatches = cachedCampaigns != null &&
        (neededCampaigns.isEmpty || neededCampaigns == cachedCampaigns);

    if (datasetRegistry.containsKey(gameModeKey) && cacheMatches) {
      // 1. Correct dataset already loaded — reuse instantly.
      loadedDataSet.value = datasetRegistry[gameModeKey];
    } else {
      // 2. Need to load (or reload) sources for this character.
      if (matched.isNotEmpty) {
        await _loadSourcesWithOverlay(matched, gameModeName);
        // _loadSources stores the result in the registry and updates loadedDataSet.
      } else {
        // Named campaigns not found locally — try the best available fallback
        // for this game mode (e.g. proprietary "Dungeons & Dragons - Core Books"
        // maps to the nearest RSRD equivalent we have).
        final fallback = _bestFallbackCampaign(allCampaigns, gameModeName);
        if (fallback != null) {
          await _loadSourcesWithOverlay([fallback], gameModeName);
          if (mounted && campaignNames.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                'Source "${campaignNames.first}" not found locally — '
                'loaded "${fallback.getDisplayName()}" as fallback.',
              ),
              duration: const Duration(seconds: 5),
            ));
          }
        } else if (campaignNames.isNotEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              'Could not find source data for "$gameModeName". '
              'The character may not display correctly.\n'
              'Missing: ${campaignNames.take(3).join(', ')}'
              '${campaignNames.length > 3 ? ' (+${campaignNames.length - 3} more)' : ''}',
            ),
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Load Sources',
              onPressed: showSourceSelectionDialog,
            ),
          ));
        }
      }
    }

    if (!mounted) return;
    final character = await CharacterFileIO.load(path);
    if (character != null) {
      CharacterManager.getCharacters().addElement(character);
      setCharacter(character);
    }
  }

  /// Returns the best available campaign for [gameModeName] when the character's
  /// own campaigns are not found locally (e.g. proprietary "Dungeons & Dragons -
  /// Core Books" → nearest RSRD equivalent).  Prefers TYPE=Complete sets.
  Campaign? _bestFallbackCampaign(List<Campaign> allCampaigns, String gameModeName) {
    final modeLower = gameModeName.toLowerCase();
    final gmKey     = ListKey.getConstant<String>('GAMEMODES');
    final typeKey   = ListKey.getConstant<String>('CAMPAIGN_TYPE');

    final candidates = allCampaigns.where((c) {
      final modes = c.getListFor(gmKey)?.cast<String>() ?? [];
      return modes.any((m) => m.toLowerCase() == modeLower);
    }).toList();

    if (candidates.isEmpty) return null;

    // Prefer a campaign explicitly typed as "Complete" (the full game-mode set).
    final complete = candidates.where((c) {
      final types = c.getListFor(typeKey)?.cast<String>() ?? [];
      return types.any((t) => t.toLowerCase().contains('complete'));
    }).toList();

    return complete.isNotEmpty ? complete.first : candidates.first;
  }

  /// Load sources with a modal progress overlay so the user sees that work
  /// is happening rather than the UI appearing frozen.
  Future<void> _loadSourcesWithOverlay(
      List<Campaign> campaigns, String gameModeName) async {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text('Loading $gameModeName sources…')),
          ]),
        ),
      ),
    );
    await _loadSources(campaigns, gameModeName);
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }


  DefaultReferenceFacade<CharacterFacade> getSelectedCharacterRef() =>
      _currentCharacterRef;

  DefaultReferenceFacade<DataSetFacade> getLoadedDataSetRef() =>
      _currentDataSetRef;

  PCGenActionMap getActionMap() => actionMap;

  void setCharacter(CharacterFacade? character) {
    _currentCharacterRef.set(character);
    currentCharacter.value = character;
    // Switch loadedDataSet to this character's game mode dataset so all UI
    // tabs show data relevant to the character currently being viewed/edited.
    if (character is CharacterFacadeImpl) {
      final key = character.getGameMode().toLowerCase();
      if (datasetRegistry.containsKey(key)) {
        loadedDataSet.value = datasetRegistry[key];
      }
    }
    _updateTitle();
  }

  void _updateTitle() {
    if (!mounted) return;
    final char = currentCharacter.value;
    String? name;
    try { name = (char as dynamic)?.getName() as String?; } catch (_) {}
    setState(() {
      _title = (char != null && name != null && name.isNotEmpty)
          ? 'PCGen — $name'
          : 'PCGen';
    });
  }

  void createNewCharacter(dynamic dataset) {
    // Use loadedDataSet if no explicit dataset given.
    final ds = dataset ?? loadedDataSet.value;
    if (ds == null) {
      _showInfo('Load sources before creating a character.');
      return;
    }
    final character = CharacterManager.createNewCharacter(null, ds);
    if (character != null) {
      setCharacter(character);
    }
  }

  void showOpenCharacterChooser() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => _LoadCharacterDialog(
        onLoad: (path, header) => _loadCharacterWithSources(path, header),
      ),
    );
  }

  bool closeCharacter(CharacterFacade? character) {
    if (character == null) return false;
    if (character.isDirty()) {
      // Ask to save
    }
    CharacterManager.removeCharacter(character);
    return true;
  }

  bool closeAllCharacters() {
    final chars = List.from(CharacterManager.getCharacters());
    for (final c in chars) {
      if (!closeCharacter(c as CharacterFacade)) return false;
    }
    return true;
  }

  void saveCharacter(CharacterFacade character) {
    if (character is CharacterFacadeImpl) {
      CharacterFileIO.save(character).then((path) {
        if (path != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved to $path'),
                duration: const Duration(seconds: 3)),
          );
        }
      });
    }
  }

  void showSaveCharacterChooser(CharacterFacade? character) {
    if (character != null) saveCharacter(character);
  }

  /// Show a dialog to save the character as a new file (checkpoint save).
  /// Keeps the same UUID so the browser groups it with existing saves.
  void showSaveNewVersionDialog(CharacterFacade? character) {
    if (character is! CharacterFacadeImpl || !mounted) return;
    final impl = character;

    // Build a suggested filename: Name_Lx or Name_vN
    final charName  = impl.getName().trim().isEmpty ? 'unnamed' : impl.getName().trim();
    final level     = impl.getTotalCharacterLevel();
    final nextVer   = impl.getSaveVersion() + 1;
    final suggested = level > 0 ? '${charName}_L$level' : '${charName}_v$nextVer';

    // Use a post-frame callback so the popup menu has fully closed before the
    // dialog is pushed — calling showDialog inside onSelected can otherwise
    // race with the menu's navigator pop on some platforms.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final controller = TextEditingController(text: suggested);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Save New Version'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Creates a new save file for this character.\n'
                'The original file is kept unchanged.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Filename (without .pcg)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => Navigator.pop(ctx, true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      final name = controller.text.trim();
      controller.dispose();
      if (confirmed != true || name.isEmpty) return;
      if (!mounted) return;
      final path = await CharacterFileIO.saveNewVersion(impl, name);
      if (!mounted) return;
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Saved: ${path.split(r'\').last.split('/').last}'),
          duration: const Duration(seconds: 3),
        ));
      }
    });
  }

  bool saveAllCharacters() {
    final chars = CharacterManager.getCharacters();
    for (int i = 0; i < chars.getSize(); i++) {
      saveCharacter(chars.getElementAt(i));
    }
    return true;
  }

  /// Re-save all character files on disk to update their CAMPAIGN: headers.
  /// Use this once after loading the correct sources to fix pre-build-103 saves.
  void migrateCharacterFiles() {
    if (!mounted) return;
    final dataset = loadedDataSet.value;
    if (dataset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Load sources first before migrating character files.')));
      return;
    }
    CharacterFileIO.migrateAllCharacters().then((result) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Migration complete: ${result.migrated} updated, '
            '${result.skipped} skipped (wrong game mode), '
            '${result.failed} failed.'),
        duration: const Duration(seconds: 5),
      ));
    });
  }

  void revertCharacter(CharacterFacade? character) {
    if (character == null) return;
    // Reload from file
  }

  void showOpenPartyChooser() {
    _showInfo('Open party file');
  }

  void showSavePartyChooser() {
    _showInfo('Save party as...');
  }

  void showPrintPreviewDialog() {
    _showInfo('Print preview');
  }

  void showExportDialog() {
    final character = currentCharacter.value;
    if (character == null) { _showInfo('No character open.'); return; }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => _ExportDialog(character: character, frame: this),
    );
  }

  void saveCharacterAsJson(CharacterFacade character) {
    if (character is CharacterFacadeImpl) {
      CharacterFileIO.saveJson(character).then((path) {
        if (path != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved JSON to $path'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      });
    }
  }

  void closePCGen() {
    if (closeAllCharacters()) {
      dispose();
    }
  }

  void showKitSelectionDialog() {
    _showInfo('Kit selection');
  }

  void showPreferencesDialog() => displayPreferencesDialog();

  void displayPreferencesDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Preferences'),
        content: const SizedBox(
          width: 400,
          height: 200,
          child: Center(child: Text('Preferences dialog — not yet implemented.')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void showDebugDialog() {
    _showInfo('Debug log');
  }

  void showCalculatorDialog() {
    _showInfo('Calculator');
  }

  void showCoreViewDialog() {
    _showInfo('Core View');
  }

  void showSolverViewDialog() {
    _showInfo('Solver View');
  }

  void showDataInstallerDialog() {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DataPacksScreen()),
    );
  }

  void showCharacterArchiveDialog() {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CharacterArchiveScreen(
          onImportComplete: () => setState(() {}),
        ),
      ),
    );
  }

  void showSourceSelectionDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SourceSelectionDialog(
        uiContext: widget.uiContext,
        onLoad: _loadSources,
      ),
    );
  }

  Future<void> _loadSources(
      List<Campaign> campaigns, String gameModeName) async {
    final delegate = _FrameUIDelegate(context);
    final loader = SourceFileLoader(delegate, campaigns, gameModeName);
    await loader.run();
    final dataset = loader.getDataSetFacade();
    if (dataset != null) {
      final key = gameModeName.toLowerCase();
      datasetRegistry[key] = dataset;
      datasetRegistryCampaigns[key] =
          campaigns.map((c) => c.getDisplayName().toLowerCase()).toSet();
      loadedDataSet.value = dataset;
      GenericLoader.flushUnknownTagReport();
    }
  }

  bool loadSourceSelection(SourceSelectionFacade sources) {
    widget.uiContext.getCurrentSourceSelectionRef().set(sources);
    return true;
  }

  void reloadSources() {
    final sources = widget.uiContext.getCurrentSourceSelectionRef().get();
    if (sources != null) {
      unloadSources();
      loadSourceSelection(sources);
    }
  }

  void unloadSources() {
    widget.uiContext.getCurrentSourceSelectionRef().set(null);
    _currentDataSetRef.set(null);
  }

  void showHelpDocs() {
    _showInfo('Opening documentation...');
  }

  void showOGLDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Open Game License v1.0a',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                const Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      'This application is built using content released under the '
                      'Open Game License v1.0a (OGL). The PCGen data files '
                      'contain SECTION 15 copyright notices in each .pcc file. '
                      '\n\nPCGen and its contributors are not affiliated with Wizards '
                      'of the Coast or Paizo Publishing.',
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showTipsOfTheDay() {
    if (!mounted) return;
    final tips = [
      'Use the Point Buy tab to set ability scores using the standard 28-point system.',
      'Save your character with Ctrl+S. Files are stored in Documents/PCGen/characters/',
      'The Race tab shows Size, Speed, and CR for each race.',
      'Class skills are highlighted with ★ in the Skills tab.',
      'Use File > Export to copy a formatted character sheet to the clipboard.',
      'Add class levels in the Class tab, then check the Summary for HP.',
    ];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tip of the Day'),
        content: Text(tips[(DateTime.now().day % tips.length)]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showAboutDialog() {
    if (!mounted) return;
    final ds = loadedDataSet.value;
    final dataLine = ds != null
        ? '${ds.races.length} races • ${ds.classes.length} classes • '
          '${ds.skills.length} skills • ${ds.spells.length} spells'
        : 'No sources loaded';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About PCGen Flutter'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('assets/images/pcgen_logo.png', height: 64, width: 64),
                const SizedBox(width: 12),
                const Text('PCGen — Character Generator',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 4),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  border: Border.all(color: Colors.amber.shade600),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(kVersionString,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    )),
              ),
            ]),
            const SizedBox(height: 8),
            const Text('Flutter/Dart port of the Java PCGen application.\n'
                'Based on PCGen 6.09.08 (Java).'),
            const SizedBox(height: 8),
            Text(dataLine),
            const SizedBox(height: 8),
            const Text('Original PCGen: https://pcgen.org',
                style: TextStyle(color: Colors.blue)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void loadCharacterFromFile(String path) {
    final character = CharacterManager.loadCharacterFromFile(path);
    if (character != null) _currentCharacterRef.set(character);
  }

  void loadPartyFromFile(String path) {
    CharacterManager.loadPartyFromFile(path);
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            const _SaveIntent(),
        const SingleActivator(LogicalKeyboardKey.keyN, control: true):
            const _NewIntent(),
        const SingleActivator(LogicalKeyboardKey.keyO, control: true):
            const _OpenIntent(),
      },
      child: Actions(
        actions: {
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) {
              final pc = getSelectedCharacterRef().get();
              if (pc != null) saveCharacter(pc);
              return null;
            },
          ),
          _NewIntent: CallbackAction<_NewIntent>(
            onInvoke: (_) { createNewCharacter(null); return null; },
          ),
          _OpenIntent: CallbackAction<_OpenIntent>(
            onInvoke: (_) { showOpenCharacterChooser(); return null; },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  Image.asset('assets/images/pcgen_logo.png', height: 28, width: 28),
                  const SizedBox(width: 8),
                  Text(_title ?? 'PCGen 7 α'),
                  const SizedBox(width: 8),
                  Text(kVersionBadge, style: const TextStyle(fontSize: 10, color: Colors.white54)),
                ],
              ),
              actions: [
                PCGenMenuBar(frame: this, uiContext: widget.uiContext),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: CharacterTabs(
                    key: _characterTabsKey,
                    frame: this,
                  ),
                ),
                PCGenStatusBar(key: _statusBarKey, frame: this),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// UIDelegate implementation backed by the current BuildContext
// ---------------------------------------------------------------------------

class _FrameUIDelegate implements UIDelegate {
  final BuildContext _context;
  _FrameUIDelegate(this._context);

  @override
  bool showWarningConfirm(String title, String message) => true;

  @override
  void showWarningMessage(String title, String message) {
    if (!_context.mounted) return;
    ScaffoldMessenger.of(_context).showSnackBar(
      SnackBar(content: Text('$title: $message')),
    );
  }

  @override
  void showErrorMessage(String title, String message) {
    if (!_context.mounted) return;
    showDialog(
      context: _context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void showInfoMessage(String title, String message) => showWarningMessage(title, message);

  @override
  void showLevelUpInfo(dynamic character, int oldLevel) {}

  @override
  bool showGeneralChooser(dynamic chooserFacade) => false;

  @override
  CustomEquipResult showCustomEquipDialog(dynamic character, dynamic equipBuilder) =>
      CustomEquipResult.cancelled;

  @override
  bool showCustomSpellDialog(dynamic spellBuilderFacade) => false;
}

// ---------------------------------------------------------------------------
// Export dialog — shows plaintext character sheet, copy to clipboard
// ---------------------------------------------------------------------------

class _ExportDialog extends StatefulWidget {
  final dynamic character;
  final dynamic frame; // PCGenFrameState
  const _ExportDialog({required this.character, required this.frame});

  @override
  State<_ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<_ExportDialog> {
  // 0 = plain text, 1 = PCG, 2 = JSON
  int _tab = 0;

  String get _textContent => widget.character is CharacterFacadeImpl
      ? CharacterTextExport.export(widget.character as CharacterFacadeImpl)
      : 'Cannot export: unsupported character type.';

  String get _pcgContent => widget.character is CharacterFacadeImpl
      ? PCGCharacterIO.write(widget.character as CharacterFacadeImpl)
      : '';

  String get _jsonContent {
    if (widget.character is! CharacterFacadeImpl) return '';
    try {
      return const JsonEncoder.withIndent('  ').convert(
          CharacterFileIO.sanitiseForJson(
              (widget.character as CharacterFacadeImpl).toJson()));
    } catch (e) {
      return 'JSON error: $e';
    }
  }

  String get _currentContent =>
      _tab == 0 ? _textContent : _tab == 1 ? _pcgContent : _jsonContent;

  String get _currentLabel =>
      _tab == 0 ? 'Text' : _tab == 1 ? 'PCG' : 'JSON';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Export Character',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              // Format tabs
              Row(
                children: [
                  _fmtBtn('Plain Text', 0),
                  const SizedBox(width: 8),
                  _fmtBtn('PCG (Java PCGen)', 1),
                  const SizedBox(width: 8),
                  _fmtBtn('JSON', 2),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(8),
                    child: SelectableText(
                      _currentContent,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Save to file
                  if (widget.character is CharacterFacadeImpl) ...[
                    OutlinedButton.icon(
                      icon: const Icon(Icons.save, size: 16),
                      label: Text('Save as $_currentLabel'),
                      onPressed: () {
                        Navigator.pop(context);
                        if (_tab == 1) {
                          widget.frame.saveCharacter(widget.character);
                        } else if (_tab == 2) {
                          widget.frame.saveCharacterAsJson(widget.character);
                        } else {
                          // Plain text — just copy
                          Clipboard.setData(ClipboardData(text: _currentContent));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied to clipboard')),
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy to Clipboard'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _currentContent));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fmtBtn(String label, int idx) {
    final selected = _tab == idx;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? Theme.of(context).colorScheme.primaryContainer : null,
        side: selected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : null,
      ),
      onPressed: () => setState(() => _tab = idx),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

// ---------------------------------------------------------------------------
// Load Character dialog — lists saved .pcg files
// ---------------------------------------------------------------------------

class _LoadCharacterDialog extends StatefulWidget {
  final Future<void> Function(String path, Map<String, String> header) onLoad;
  const _LoadCharacterDialog({required this.onLoad});

  @override
  State<_LoadCharacterDialog> createState() => _LoadCharacterDialogState();
}

class _LoadCharacterDialogState extends State<_LoadCharacterDialog> {
  List<File> _allFiles = [];
  // Cache of file path → {name, gameMode, race, primaryClass, totalLevel}
  final Map<String, Map<String, String>> _headerCache = {};
  // Groups expanded by character name
  final Set<String> _expanded = {};
  bool _loading = false;
  bool _scanning = true;
  String _dir = '';
  final TextEditingController _dirController = TextEditingController();
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFromDir(null);
  }

  @override
  void dispose() {
    _dirController.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadFromDir(String? override) async {
    setState(() { _scanning = true; _allFiles = []; _headerCache.clear(); });
    try {
      final dirPath = override ?? await CharacterFileIO.getCharDir();
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        final files = dir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.endsWith('.pcg') || f.path.endsWith('.json'))
            .toList()
          ..sort((a, b) {
            final an = p.basenameWithoutExtension(a.path).toLowerCase();
            final bn = p.basenameWithoutExtension(b.path).toLowerCase();
            return an.compareTo(bn);
          });
        setState(() {
          _dir = dirPath;
          _dirController.text = dirPath;
          _allFiles = files;
        });
        // Peek headers asynchronously so the list appears immediately
        for (final file in files) {
          try {
            final content = await file.readAsString();
            final header = PCGCharacterIO.peekHeader(content);
            if (mounted) {
              setState(() => _headerCache[file.path] = header);
            }
          } catch (_) {}
        }
      } else {
        setState(() {
          _dir = dirPath;
          _dirController.text = dirPath;
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _scanning = false);
  }

  // Group files by character UUID (FLUTTERPCG_UUID) when available, otherwise
  // by character name. Within each group, sort newest-first by:
  //   1. FLUTTERPCG_SAVEVERSION (highest = most recent) when present
  //   2. FLUTTERPCG_SAVED timestamp when present
  //   3. File system modification time as final fallback
  Map<String, List<File>> get _groups {
    final q = _search.text.trim().toLowerCase();
    // uuid/name → files
    final byId  = <String, List<File>>{};
    // uuid → display name (use the name from the newest file in the group)
    final names = <String, String>{};

    for (final file in _allFiles) {
      final header = _headerCache[file.path];
      final name   = header?['name']?.isNotEmpty == true
          ? header!['name']! : p.basenameWithoutExtension(file.path);
      if (q.isNotEmpty && !name.toLowerCase().contains(q)) continue;

      // Group key priority:
      // 1. FLUTTERPCG_UUID — definitive; copies get a new UUID so stay separate.
      // 2. name + race + firstClass — two characters can share a name but differ
      //    in race or starting class; require all three to match before grouping.
      // 3. name only — no class data at all (empty character, pre-class file).
      final uuid       = header?['charUuid'] ?? '';
      final race       = header?['race'] ?? '';
      final firstClass = header?['firstClass'] ?? '';
      final String key;
      if (uuid.isNotEmpty) {
        key = uuid;
      } else if (race.isNotEmpty || firstClass.isNotEmpty) {
        // Composite identity: name + race + firstClass (all lower-case for comparison)
        key = '${name.toLowerCase()}|${race.toLowerCase()}|${firstClass.toLowerCase()}';
      } else {
        key = name; // fallback for files with no header data yet
      }
      byId.putIfAbsent(key, () => []).add(file);
      names[key] = name;
    }

    // Sort each group: highest saveVersion first, then savedAt desc, then mtime desc
    for (final files in byId.values) {
      files.sort((a, b) {
        final ha = _headerCache[a.path];
        final hb = _headerCache[b.path];
        final va = int.tryParse(ha?['saveVersion'] ?? '') ?? -1;
        final vb = int.tryParse(hb?['saveVersion'] ?? '') ?? -1;
        if (va != vb) return vb.compareTo(va);
        final ta = ha?['savedAt'] ?? '';
        final tb = hb?['savedAt'] ?? '';
        if (ta.isNotEmpty && tb.isNotEmpty) return tb.compareTo(ta);
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      });
    }

    // Re-key by display name for the UI.
    // After sorting newest-first, use the name from the newest save so the
    // group always shows the character's most recent name (e.g. if renamed).
    final result = <String, List<File>>{};
    for (final entry in byId.entries) {
      final files    = entry.value; // already sorted newest-first
      final newest   = _headerCache[files.first.path];
      final dispName = newest?['name']?.isNotEmpty == true
          ? newest!['name']!
          : names[entry.key]!;
      result[dispName] = files;
    }

    // Sort groups alphabetically by character name (case-insensitive).
    final sorted = Map.fromEntries(
      result.entries.toList()
        ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase())),
    );
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text('Open Character',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),

              // Folder row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dirController,
                      style: const TextStyle(fontSize: 12),
                      decoration: const InputDecoration(
                        labelText: 'Folder',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      onSubmitted: (v) => _loadFromDir(v.trim()),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    tooltip: 'Reload folder',
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _loadFromDir(_dirController.text.trim()),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Search
              TextField(
                controller: _search,
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, size: 18),
                  hintText: 'Search characters…',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 6),

              // Count label
              Builder(builder: (context) {
                final g = _groups;
                final total = g.values.fold(0, (s, v) => s + v.length);
                return Text(
                  _scanning
                      ? 'Scanning…'
                      : '${g.length} character${g.length == 1 ? '' : 's'}'
                        '${total != g.length ? ' · $total files' : ''}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                );
              }),
              const SizedBox(height: 4),

              // Character tree
              Expanded(
                child: _scanning
                    ? const Center(child: CircularProgressIndicator())
                    : _groups.isEmpty
                        ? Center(
                            child: Text(
                              _allFiles.isEmpty
                                  ? 'No characters found in this folder.'
                                  : 'No matches for "${_search.text}".',
                              style: const TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView(
                            children: _groups.entries.map((entry) =>
                                _buildGroup(entry.key, entry.value)).toList(),
                          ),
              ),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Tree helpers ────────────────────────────────────────────────────────

  Widget _buildGroup(String charName, List<File> files) {
    if (files.length == 1) {
      return _buildFileTile(files.first, charName: charName);
    }
    // Primary: most recently modified (already sorted newest-first by _groups getter)
    final primary      = files.first;
    final header       = _headerCache[primary.path];
    final race         = header?['race'] ?? '';
    final primaryClass = header?['primaryClass'] ?? '';
    final totalLevel   = header?['totalLevel'] ?? '';
    final gameMode     = header?['gameMode'] ?? '';
    // Check the registry — any loaded game mode shows green, not just the active one.
    final modeMatch  = gameMode.isNotEmpty &&
        datasetRegistry.containsKey(gameMode.toLowerCase());
    final noSources  = gameMode.isNotEmpty && datasetRegistry.isEmpty;
    final mismatched = gameMode.isNotEmpty && !modeMatch && !noSources;
    final summaryParts = <String>[
      if (race.isNotEmpty) race,
      if (primaryClass.isNotEmpty && totalLevel.isNotEmpty) '$primaryClass $totalLevel'
      else if (primaryClass.isNotEmpty) primaryClass,
    ];
    final summary = summaryParts.join(' · ');
    final isOpen  = _expanded.contains(charName);
    final modLabel = _fmtDate(primary.lastModifiedSync());

    // Tapping the group header opens the newest file directly.
    // The expand button (chevron) is a separate hit target.
    Future<void> openNewest() => _openFile(primary, header ?? {});

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: mismatched || noSources
            ? Colors.orange.shade300 : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Group header row
          InkWell(
            borderRadius: BorderRadius.vertical(
                top: const Radius.circular(6),
                bottom: isOpen ? Radius.zero : const Radius.circular(6)),
            onTap: _loading ? null : openNewest,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              child: Row(
                children: [
                  Icon(Icons.people,
                      size: 20,
                      color: mismatched || noSources
                          ? Colors.orange.shade400
                          : Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(charName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        if (summary.isNotEmpty)
                          Text(summary,
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                        Row(children: [
                          if (gameMode.isNotEmpty) ...[
                            Icon(
                              mismatched || noSources
                                  ? Icons.warning_amber_rounded
                                  : modeMatch ? Icons.check_circle : Icons.circle_outlined,
                              size: 10,
                              color: mismatched || noSources ? Colors.orange.shade600
                                  : modeMatch ? Colors.green.shade600 : Colors.grey.shade500,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              mismatched ? '$gameMode  ⚠ not loaded' : gameMode,
                              style: TextStyle(
                                fontSize: 10,
                                color: mismatched || noSources ? Colors.orange.shade700
                                    : modeMatch ? Colors.green.shade700 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(modLabel,
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ]),
                      ],
                    ),
                  ),
                  // Expand/collapse button — separate from the load tap target
                  IconButton(
                    tooltip: isOpen ? 'Hide saves' : '${files.length} saves — show all',
                    icon: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('${files.length}',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                      Icon(isOpen ? Icons.expand_less : Icons.expand_more,
                          size: 18, color: Colors.grey.shade600),
                    ]),
                    onPressed: () => setState(() {
                      if (isOpen) _expanded.remove(charName);
                      else _expanded.add(charName);
                    }),
                  ),
                ],
              ),
            ),
          ),
          // Save list — shown when expanded
          if (isOpen) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            Column(
              children: files.map((f) => _buildFileTile(f, indented: true)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// Open a file — sources are auto-loaded by _loadCharacterWithSources if
  /// the required campaigns are discoverable. No blocking dialog needed here.
  Future<void> _openFile(File file, Map<String, String> header) async {
    setState(() => _loading = true);
    await widget.onLoad(file.path, header);
    if (mounted) Navigator.pop(context);
  }

  Widget _buildFileTile(File file, {String? charName, bool indented = false}) {
    final header       = _headerCache[file.path];
    final name         = charName ?? (header?['name']?.isNotEmpty == true
        ? header!['name']! : p.basenameWithoutExtension(file.path));
    final fileName     = p.basename(file.path);
    final gameMode     = header?['gameMode'] ?? '';
    final race         = header?['race'] ?? '';
    final primaryClass = header?['primaryClass'] ?? '';
    final totalLevel   = header?['totalLevel'] ?? '';
    final ext          = p.extension(file.path);
    final modified     = file.lastModifiedSync();

    // Check the registry — any loaded game mode shows green, not just the active one.
    final modeMatch  = gameMode.isNotEmpty &&
        datasetRegistry.containsKey(gameMode.toLowerCase());
    final noSources  = gameMode.isNotEmpty && datasetRegistry.isEmpty;
    final mismatched = gameMode.isNotEmpty && !modeMatch && !noSources;

    final summaryParts = <String>[
      if (!indented && race.isNotEmpty) race,
      if (primaryClass.isNotEmpty && totalLevel.isNotEmpty) '$primaryClass $totalLevel'
      else if (primaryClass.isNotEmpty) primaryClass,
    ];
    final summary     = summaryParts.join(' · ');
    final saveVersion = header?['saveVersion'] ?? '';
    final savedAt     = header?['savedAt'] ?? '';
    // Prefer embedded save timestamp over filesystem mtime
    final modLabel = savedAt.isNotEmpty
        ? _fmtDate(DateTime.tryParse(savedAt)?.toLocal() ?? modified)
        : _fmtDate(modified);
    final versionLabel = saveVersion.isNotEmpty ? 'v$saveVersion' : '';

    final tile = ListTile(
      dense: true,
      contentPadding: EdgeInsets.only(
          left: indented ? 36 : 12, right: 12, top: 2, bottom: 2),
      leading: Icon(
        ext == '.json' ? Icons.data_object : Icons.description,
        size: indented ? 18 : 22,
        color: mismatched ? Colors.orange.shade400
            : indented ? Colors.grey.shade500 : null,
      ),
      title: Text(indented ? fileName : name,
          style: TextStyle(
              fontSize: indented ? 12 : 13,
              fontWeight: indented ? FontWeight.normal : FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (summary.isNotEmpty)
            Text(summary,
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
          Row(children: [
            if (gameMode.isNotEmpty) ...[
              Icon(
                mismatched || noSources ? Icons.warning_amber_rounded
                    : modeMatch ? Icons.check_circle : Icons.circle_outlined,
                size: 10,
                color: mismatched || noSources ? Colors.orange.shade600
                    : modeMatch ? Colors.green.shade600 : Colors.grey.shade500,
              ),
              const SizedBox(width: 3),
              Text(
                mismatched ? '$gameMode  ⚠ not loaded' : gameMode,
                style: TextStyle(
                  fontSize: 10,
                  color: mismatched || noSources ? Colors.orange.shade700
                      : modeMatch ? Colors.green.shade700 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(modLabel,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            if (versionLabel.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(versionLabel,
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade700)),
              ),
            ],
          ]),
        ],
      ),
      trailing: _loading
          ? const SizedBox(width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
          : null,
      onTap: _loading ? null : () => _openFile(file, header ?? {}),
    );

    if (indented) return tile;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: tile,
    );
  }

  String _fmtDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7)  return '${diff.inDays} days ago';
    return '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
  }
}

// ---------------------------------------------------------------------------
// Keyboard shortcut intents
// ---------------------------------------------------------------------------

class _SaveIntent extends Intent { const _SaveIntent(); }
class _NewIntent  extends Intent { const _NewIntent(); }
class _OpenIntent extends Intent { const _OpenIntent(); }

// ---------------------------------------------------------------------------
// Character Launcher — startup dialog replacing source selection
// ---------------------------------------------------------------------------

class _CharacterLauncherDialog extends StatefulWidget {
  /// Called when user selects a character to load.
  final Future<void> Function(String path, Map<String, String> header) onLoadCharacter;
  /// Called when user wants to create a new character (shows source selection).
  final VoidCallback onNewCharacter;

  const _CharacterLauncherDialog({
    required this.onLoadCharacter,
    required this.onNewCharacter,
  });

  @override
  State<_CharacterLauncherDialog> createState() => _CharacterLauncherDialogState();
}

class _CharacterLauncherDialogState extends State<_CharacterLauncherDialog> {
  List<File> _files = [];
  final Map<String, Map<String, String>> _headers = {};
  bool _scanning = true;
  bool _loading  = false;
  String _loadingMsg = '';
  final _search = TextEditingController();
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _scan();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    setState(() { _scanning = true; _files = []; _headers.clear(); });
    try {
      final dir = Directory(await CharacterFileIO.getCharDir());
      if (await dir.exists()) {
        final files = dir.listSync().whereType<File>()
            .where((f) => f.path.endsWith('.pcg') || f.path.endsWith('.json'))
            .toList()
          ..sort((a, b) => p.basenameWithoutExtension(a.path)
              .toLowerCase()
              .compareTo(p.basenameWithoutExtension(b.path).toLowerCase()));
        if (mounted) setState(() => _files = files);
        for (final file in files) {
          try {
            final h = PCGCharacterIO.peekHeader(await file.readAsString());
            if (mounted) setState(() => _headers[file.path] = h);
          } catch (_) {}
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _scanning = false);
  }

  Map<String, List<File>> get _groups {
    final q = _search.text.trim().toLowerCase();
    final byId  = <String, List<File>>{};
    final names = <String, String>{};

    for (final file in _files) {
      final header = _headers[file.path];
      final name   = header?['name']?.isNotEmpty == true
          ? header!['name']! : p.basenameWithoutExtension(file.path);
      if (q.isNotEmpty && !name.toLowerCase().contains(q)) continue;

      final uuid       = header?['charUuid'] ?? '';
      final race       = header?['race'] ?? '';
      final firstClass = header?['firstClass'] ?? '';
      final String key;
      if (uuid.isNotEmpty) {
        key = uuid;
      } else if (race.isNotEmpty || firstClass.isNotEmpty) {
        key = '${name.toLowerCase()}|${race.toLowerCase()}|${firstClass.toLowerCase()}';
      } else {
        key = name;
      }
      byId.putIfAbsent(key, () => []).add(file);
      names[key] = name;
    }

    for (final files in byId.values) {
      files.sort((a, b) {
        final ha = _headers[a.path];
        final hb = _headers[b.path];
        final va = int.tryParse(ha?['saveVersion'] ?? '') ?? -1;
        final vb = int.tryParse(hb?['saveVersion'] ?? '') ?? -1;
        if (va != vb) return vb.compareTo(va);
        final ta = ha?['savedAt'] ?? '';
        final tb = hb?['savedAt'] ?? '';
        if (ta.isNotEmpty && tb.isNotEmpty) return tb.compareTo(ta);
        return b.lastModifiedSync().compareTo(a.lastModifiedSync());
      });
    }

    final result = <String, List<File>>{};
    for (final entry in byId.entries) {
      final files    = entry.value;
      final newest   = _headers[files.first.path];
      final dispName = newest?['name']?.isNotEmpty == true
          ? newest!['name']! : names[entry.key]!;
      result[dispName] = files;
    }

    return Map.fromEntries(
      result.entries.toList()
        ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase())),
    );
  }

  Future<void> _select(File file) async {
    final header = _headers[file.path] ?? {};
    final name = header['name'] ?? p.basenameWithoutExtension(file.path);
    final campaigns = header['campaigns'] ?? '';
    final gameMode  = header['gameMode']  ?? '';
    setState(() {
      _loading = true;
      _loadingMsg = 'Loading sources for $name…';
    });
    Navigator.of(context).pop();
    await widget.onLoadCharacter(file.path, header);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              color: theme.colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PCGen', style: theme.textTheme.headlineSmall),
                        Text('Open a character or create a new one',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // New Character button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Character…'),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onNewCharacter();
                },
              ),
            ),

            const Divider(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Recent Characters',
                  style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey)),
            ),
            const SizedBox(height: 6),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _search,
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: 'Filter…',
                  prefixIcon: Icon(Icons.search, size: 18),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 8),

            // Character list
            Expanded(
              child: Builder(builder: (context) {
                if (_scanning) return const Center(child: CircularProgressIndicator());
                final g = _groups;
                if (g.isEmpty) {
                  return Center(
                    child: Text(
                      _files.isEmpty ? 'No saved characters found.' : 'No matches.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: g.entries.map((e) => _buildGroup(e.key, e.value)).toList(),
                );
              }),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup(String charName, List<File> files) {
    if (files.length == 1) {
      return _buildFileTile(files.first, charName: charName);
    }
    final primary      = files.first;
    final header       = _headers[primary.path];
    final race         = header?['race'] ?? '';
    final primaryClass = header?['primaryClass'] ?? '';
    final totalLevel   = header?['totalLevel'] ?? '';
    final gameMode     = header?['gameMode'] ?? '';
    final modeMatch    = gameMode.isNotEmpty &&
        datasetRegistry.containsKey(gameMode.toLowerCase());
    final noSources    = gameMode.isNotEmpty && datasetRegistry.isEmpty;
    final mismatched   = gameMode.isNotEmpty && !modeMatch && !noSources;
    final summaryParts = <String>[
      if (race.isNotEmpty) race,
      if (primaryClass.isNotEmpty && totalLevel.isNotEmpty) '$primaryClass $totalLevel'
      else if (primaryClass.isNotEmpty) primaryClass,
    ];
    final summary  = summaryParts.join(' · ');
    final isOpen   = _expanded.contains(charName);
    final modLabel = _fmtDate(primary.lastModifiedSync());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: mismatched || noSources
            ? Colors.orange.shade300 : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.vertical(
                top: const Radius.circular(6),
                bottom: isOpen ? Radius.zero : const Radius.circular(6)),
            onTap: _loading ? null : () => _select(primary),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
              child: Row(
                children: [
                  Icon(Icons.people,
                      size: 20,
                      color: mismatched || noSources
                          ? Colors.orange.shade400
                          : Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(charName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        if (summary.isNotEmpty)
                          Text(summary,
                              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                        Row(children: [
                          if (gameMode.isNotEmpty) ...[
                            Icon(
                              mismatched || noSources
                                  ? Icons.warning_amber_rounded
                                  : modeMatch ? Icons.check_circle : Icons.circle_outlined,
                              size: 10,
                              color: mismatched || noSources ? Colors.orange.shade600
                                  : modeMatch ? Colors.green.shade600 : Colors.grey.shade500,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              mismatched ? '$gameMode  ⚠ not loaded' : gameMode,
                              style: TextStyle(
                                fontSize: 10,
                                color: mismatched || noSources ? Colors.orange.shade700
                                    : modeMatch ? Colors.green.shade700 : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(modLabel,
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ]),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: isOpen ? 'Hide saves' : '${files.length} saves — show all',
                    icon: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('${files.length}',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                      Icon(isOpen ? Icons.expand_less : Icons.expand_more,
                          size: 18, color: Colors.grey.shade600),
                    ]),
                    onPressed: () => setState(() {
                      if (isOpen) _expanded.remove(charName);
                      else _expanded.add(charName);
                    }),
                  ),
                ],
              ),
            ),
          ),
          if (isOpen) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            Column(
              children: files.map((f) => _buildFileTile(f, indented: true)).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFileTile(File file, {String? charName, bool indented = false}) {
    final header       = _headers[file.path];
    final name         = charName ?? (header?['name']?.isNotEmpty == true
        ? header!['name']! : p.basenameWithoutExtension(file.path));
    final fileName     = p.basename(file.path);
    final gameMode     = header?['gameMode'] ?? '';
    final race         = header?['race'] ?? '';
    final primaryClass = header?['primaryClass'] ?? '';
    final totalLevel   = header?['totalLevel'] ?? '';
    final ext          = p.extension(file.path);
    final modified     = file.lastModifiedSync();
    final modeMatch    = gameMode.isNotEmpty &&
        datasetRegistry.containsKey(gameMode.toLowerCase());
    final noSources    = gameMode.isNotEmpty && datasetRegistry.isEmpty;
    final mismatched   = gameMode.isNotEmpty && !modeMatch && !noSources;

    final summaryParts = <String>[
      if (!indented && race.isNotEmpty) race,
      if (primaryClass.isNotEmpty && totalLevel.isNotEmpty) '$primaryClass $totalLevel'
      else if (primaryClass.isNotEmpty) primaryClass,
    ];
    final summary      = summaryParts.join(' · ');
    final saveVersion  = header?['saveVersion'] ?? '';
    final savedAt      = header?['savedAt'] ?? '';
    final modLabel = savedAt.isNotEmpty
        ? _fmtDate(DateTime.tryParse(savedAt)?.toLocal() ?? modified)
        : _fmtDate(modified);
    final versionLabel = saveVersion.isNotEmpty ? 'v$saveVersion' : '';

    final tile = ListTile(
      dense: true,
      contentPadding: EdgeInsets.only(
          left: indented ? 36 : 12, right: 12, top: 2, bottom: 2),
      leading: Icon(
        ext == '.json' ? Icons.data_object : Icons.description,
        size: indented ? 18 : 22,
        color: mismatched ? Colors.orange.shade400
            : indented ? Colors.grey.shade500 : null,
      ),
      title: Text(indented ? fileName : name,
          style: TextStyle(
              fontSize: indented ? 12 : 13,
              fontWeight: indented ? FontWeight.normal : FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (summary.isNotEmpty)
            Text(summary,
                style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
          Row(children: [
            if (gameMode.isNotEmpty) ...[
              Icon(
                mismatched || noSources ? Icons.warning_amber_rounded
                    : modeMatch ? Icons.check_circle : Icons.circle_outlined,
                size: 10,
                color: mismatched || noSources ? Colors.orange.shade600
                    : modeMatch ? Colors.green.shade600 : Colors.grey.shade500,
              ),
              const SizedBox(width: 3),
              Text(
                mismatched ? '$gameMode  ⚠ not loaded' : gameMode,
                style: TextStyle(
                  fontSize: 10,
                  color: mismatched || noSources ? Colors.orange.shade700
                      : modeMatch ? Colors.green.shade700 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(modLabel,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            if (versionLabel.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(versionLabel,
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade700)),
              ),
            ],
          ]),
        ],
      ),
      trailing: _loading
          ? const SizedBox(width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
          : null,
      onTap: _loading || header == null ? null : () => _select(file),
    );

    if (indented) return tile;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: tile,
    );
  }

  String _fmtDate(DateTime dt) {
    final now  = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7)  return '${diff.inDays} days ago';
    return '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
  }
}
