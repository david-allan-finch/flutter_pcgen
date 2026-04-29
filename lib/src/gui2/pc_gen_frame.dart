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
import 'package:flutter/services.dart';
import 'package:flutter_pcgen/src/gui2/app_state.dart';
import 'package:flutter_pcgen/src/gui2/sources/source_selection_dialog.dart';
import 'package:flutter_pcgen/src/gui2/facade/character_facade_impl.dart';
import 'package:flutter_pcgen/src/io/character_file_io.dart';
import 'package:flutter_pcgen/src/io/character_text_export.dart';
import 'package:flutter_pcgen/src/io/pcg_character_io.dart';
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
    final skipSources = UIPropertyContext.getInstance()
        .getBoolean(UIPropertyContext.skipSourceSelection);
    if (!skipSources) {
      // Small delay so the OS window is fully focused before we show the dialog.
      // Without this Flutter Windows renders the dialog blank until the user
      // clicks the main window.
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) showSourceSelectionDialog();
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
    currentCharacter.value = character;
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
        onLoad: (path) async {
          final character = await CharacterFileIO.load(path);
          if (character != null) {
            CharacterManager.getCharacters().addElement(character);
            setCharacter(character);
          }
        },
        onLoadSources: () {
          // Called when user wants to load sources before opening a character.
          showSourceSelectionDialog();
        },
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
    final dataset = loader.getDataSetFacade();
    if (dataset != null) {
      loadedDataSet.value = dataset;
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
            const Text('PCGen — Character Generator',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  border: Border.all(color: Colors.amber.shade600),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Version 7.0.0-alpha.1',
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
              title: Text(_title ?? 'PCGen 7 α'),
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
  final Future<void> Function(String path) onLoad;
  final VoidCallback? onLoadSources;
  const _LoadCharacterDialog({required this.onLoad, this.onLoadSources});

  @override
  State<_LoadCharacterDialog> createState() => _LoadCharacterDialogState();
}

class _LoadCharacterDialogState extends State<_LoadCharacterDialog> {
  List<File> _allFiles = [];
  // Cache of file path → {name, gameMode}
  final Map<String, Map<String, String>> _headerCache = {};
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

  List<File> get _filtered {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _allFiles;
    return _allFiles
        .where((f) => p.basenameWithoutExtension(f.path).toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

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
              Text(
                _scanning
                    ? 'Scanning…'
                    : '${filtered.length} character${filtered.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 4),

              // File list
              Expanded(
                child: _scanning
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? Center(
                            child: Text(
                              _allFiles.isEmpty
                                  ? 'No characters found in this folder.'
                                  : 'No matches for "${_search.text}".',
                              style: const TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final file = filtered[i];
                              final header = _headerCache[file.path];
                              final charName = header?['name']?.isNotEmpty == true
                                  ? header!['name']!
                                  : p.basenameWithoutExtension(file.path);
                              final fileName   = p.basename(file.path);
                              final gameMode     = header?['gameMode'] ?? '';
                              final race         = header?['race'] ?? '';
                              final primaryClass = header?['primaryClass'] ?? '';
                              final totalLevel   = header?['totalLevel'] ?? '';
                              final ext = p.extension(file.path);

                              // Match against loaded dataset
                              final loadedMode =
                                  loadedDataSet.value?.gameModeStr ?? '';
                              final matched = gameMode.isNotEmpty &&
                                  loadedMode.isNotEmpty &&
                                  gameMode.toLowerCase() ==
                                      loadedMode.toLowerCase();
                              final mismatched = gameMode.isNotEmpty &&
                                  loadedMode.isNotEmpty && !matched;
                              final noSources = gameMode.isNotEmpty &&
                                  loadedMode.isEmpty;

                              // Character summary: Race · Class Level
                              final summaryParts = <String>[
                                if (race.isNotEmpty) race,
                                if (primaryClass.isNotEmpty && totalLevel.isNotEmpty)
                                  '$primaryClass $totalLevel'
                                else if (primaryClass.isNotEmpty)
                                  primaryClass,
                              ];
                              final summary = summaryParts.join(' · ');

                              // Tap handler — prompt on mismatch/no sources
                              Future<void> doLoad() async {
                                setState(() => _loading = true);
                                await widget.onLoad(file.path);
                                if (mounted) Navigator.pop(context);
                              }

                              Future<void> handleTap() async {
                                if (mismatched || noSources) {
                                  final action = await showDialog<String>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Row(children: [
                                        Icon(Icons.warning_amber_rounded,
                                            color: Colors.orange.shade700, size: 20),
                                        const SizedBox(width: 8),
                                        const Text('Sources Not Loaded'),
                                      ]),
                                      content: Text(
                                        mismatched
                                            ? 'This character requires the "$gameMode" '
                                              'game mode, but "$loadedMode" is currently '
                                              'loaded.\n\nWould you like to load sources '
                                              'for "$gameMode" first?'
                                            : 'This character requires the "$gameMode" '
                                              'game mode but no sources are loaded.\n\n'
                                              'Would you like to load sources first?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'cancel'),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'open'),
                                          child: const Text('Open Anyway'),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, 'sources'),
                                          child: const Text('Load Sources First'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (action == 'sources') {
                                    if (mounted) Navigator.pop(context);
                                    widget.onLoadSources?.call();
                                    return;
                                  }
                                  if (action != 'open') return;
                                }
                                await doLoad();
                              }

                              return ListTile(
                                dense: false,
                                leading: Icon(
                                  ext == '.json'
                                      ? Icons.data_object
                                      : Icons.person,
                                  size: 22,
                                  color: mismatched
                                      ? Colors.orange.shade400
                                      : null,
                                ),
                                title: Text(charName,
                                    style: const TextStyle(fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Race · Class Level
                                    if (summary.isNotEmpty)
                                      Text(summary,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontStyle: FontStyle.italic)),
                                    // Filename
                                    Text(fileName,
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade500)),
                                    // Gamemode + match indicator
                                    if (gameMode.isNotEmpty)
                                      Row(children: [
                                        Icon(
                                          mismatched || noSources
                                              ? Icons.warning_amber_rounded
                                              : matched
                                                  ? Icons.check_circle
                                                  : Icons.circle_outlined,
                                          size: 10,
                                          color: mismatched || noSources
                                              ? Colors.orange.shade600
                                              : matched
                                                  ? Colors.green.shade600
                                                  : Colors.grey.shade500,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          mismatched
                                              ? '$gameMode  ⚠ loaded: $loadedMode'
                                              : gameMode,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: mismatched || noSources
                                                ? Colors.orange.shade700
                                                : matched
                                                    ? Colors.green.shade700
                                                    : Colors.grey.shade600,
                                          ),
                                        ),
                                      ]),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: _loading
                                    ? const SizedBox(
                                        width: 16, height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2))
                                    : null,
                                onTap: _loading ? null : handleTap,
                              );
                            },
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
}

// ---------------------------------------------------------------------------
// Keyboard shortcut intents
// ---------------------------------------------------------------------------

class _SaveIntent extends Intent { const _SaveIntent(); }
class _NewIntent  extends Intent { const _NewIntent(); }
class _OpenIntent extends Intent { const _OpenIntent(); }
