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

import 'package:flutter/material.dart';
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
import 'package:flutter_pcgen/src/gui2/sources/source_selection_dialog.dart';
import 'package:flutter_pcgen/src/persistence/source_file_loader.dart';
import 'package:flutter_pcgen/src/system/character_manager.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => startPCGenFrame());
  }

  void startPCGenFrame() {
    // Perform startup tasks: maybe load campaign, character, or sources
    _doStartup();
  }

  void _doStartup() {
    // Check preferences for auto-load sources, etc.
    // For now just show source selection if needed
    final skipSources = UIPropertyContext.getInstance()
        .getBoolean(UIPropertyContext.skipSourceSelection);
    if (!skipSources) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showSourceSelectionDialog();
      });
    }
  }

  DefaultReferenceFacade<CharacterFacade> getSelectedCharacterRef() =>
      _currentCharacterRef;

  DefaultReferenceFacade<DataSetFacade> getLoadedDataSetRef() =>
      _currentDataSetRef;

  PCGenActionMap getActionMap() => actionMap;

  void setCharacter(CharacterFacade? character) {
    _currentCharacterRef.set(character);
    _updateTitle();
  }

  void _updateTitle() {
    final char = _currentCharacterRef.get();
    setState(() {
      _title = char != null
          ? 'PCGen - ${char.getNameRef().get() ?? "Character"}'
          : 'PCGen';
    });
  }

  void createNewCharacter(dynamic dataset) {
    final ds = (dataset ?? _currentDataSetRef.get()) as DataSetFacade?;
    if (ds == null) return;
    final character = CharacterManager.createNewCharacter(null, ds);
    if (character != null) {
      _currentCharacterRef.set(character);
    }
  }

  void showOpenCharacterChooser() {
    // Show file picker for character files
    _showInfo('Open character file');
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
    final file = character.getFileRef().get();
    if (file == null) {
      showSaveCharacterChooser(character);
    } else {
      CharacterManager.saveCharacter(character);
    }
  }

  void showSaveCharacterChooser(CharacterFacade? character) {
    // Show file picker for saving
    _showInfo('Save character as...');
  }

  bool saveAllCharacters() {
    final chars = CharacterManager.getCharacters();
    for (int i = 0; i < chars.getSize(); i++) {
      saveCharacter(chars.getElementAt(i));
    }
    return true;
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
    _showInfo('Export character');
  }

  void closePCGen() {
    if (closeAllCharacters()) {
      dispose();
    }
  }

  void showKitSelectionDialog() {
    _showInfo('Kit selection');
  }

  void showPreferencesDialog() {
    _showInfo('Preferences');
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
    _showInfo('Install Data');
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
    // DataSetFacade wiring deferred until DataSet implements DataSetFacade.
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
    _showInfo('OGL License');
  }

  void showTipsOfTheDay() {
    _showInfo('Tips of the Day');
  }

  void showAboutDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('About PCGen'),
        content: const Text('PCGen - Character Generator\nFlutter Edition'),
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

  void dispose() {
    super.dispose();
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title ?? 'PCGen'),
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
