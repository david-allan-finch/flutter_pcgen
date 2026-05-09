// Character Archive screen — export all characters to .pcgch or import one.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/startup/character_archive_manager.dart';
import 'package:flutter_pcgen/src/gui2/startup/pack_metadata.dart';

class CharacterArchiveScreen extends StatefulWidget {
  /// Called after a successful import so the character list can refresh.
  final VoidCallback? onImportComplete;
  const CharacterArchiveScreen({super.key, this.onImportComplete});

  @override
  State<CharacterArchiveScreen> createState() => _CharacterArchiveScreenState();
}

class _CharacterArchiveScreenState extends State<CharacterArchiveScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _mgr = CharacterArchiveManager();

  // Export state
  List<File> _pcgFiles = [];
  Set<String> _selected = {};
  bool _loadingFiles = true;
  double? _exportProgress;
  String _exportStatus = '';
  String? _lastExportPath;

  // Import state
  CharacterArchiveMetadata? _previewMeta;
  String? _importPath;
  double? _importProgress;
  String _importStatus = '';
  bool _overwrite = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _loadFiles();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    setState(() => _loadingFiles = true);
    final dir = await CharacterArchiveManager.charDir;
    _pcgFiles = dir.listSync().whereType<File>()
        .where((f) => f.path.endsWith('.pcg')).toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    _selected = _pcgFiles.map((f) => f.path).toSet();
    if (mounted) setState(() => _loadingFiles = false);
  }

  // ── Export ─────────────────────────────────────────────────────────────────

  Future<void> _export() async {
    final files = _pcgFiles.where((f) => _selected.contains(f.path)).toList();
    if (files.isEmpty) { _showError('No characters selected'); return; }

    setState(() { _exportProgress = 0; _exportStatus = 'Starting…'; _lastExportPath = null; });
    try {
      final path = await _mgr.export(
        pcgFiles: files,
        onProgress: (p, s) {
          if (mounted) setState(() { _exportProgress = p; _exportStatus = s; });
        },
      );
      setState(() { _exportProgress = 1.0; _exportStatus = 'Saved to $path'; _lastExportPath = path; });
    } catch (e) {
      setState(() { _exportProgress = null; _exportStatus = ''; });
      _showError('Export failed: $e');
    }
  }

  // ── Import ─────────────────────────────────────────────────────────────────

  Future<void> _pickImportFile() async {
    final path = await _showPathDialog('Import .pcgch File',
        '/path/to/characters.pcgch');
    if (path == null || path.isEmpty) return;
    if (!File(path).existsSync()) { _showError('File not found'); return; }
    setState(() { _importPath = path; _previewMeta = null; });
    final meta = await _mgr.readMetadata(path);
    if (mounted) setState(() => _previewMeta = meta);
  }

  Future<void> _doImport() async {
    if (_importPath == null) return;
    setState(() { _importProgress = null; _importStatus = 'Importing…'; });
    try {
      final names = await _mgr.import(
        _importPath!,
        overwrite: _overwrite,
        onProgress: (p, s) {
          if (mounted) setState(() { _importProgress = p; _importStatus = s; });
        },
      );
      setState(() { _importProgress = 1.0; _importStatus = 'Imported ${names.length} character(s)'; });
      await _loadFiles();
      widget.onImportComplete?.call();
    } catch (e) {
      setState(() { _importProgress = null; _importStatus = ''; });
      _showError('Import failed: $e');
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Character Archives'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'Export'), Tab(text: 'Import')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [_buildExport(), _buildImport()],
      ),
    );
  }

  Widget _buildExport() {
    if (_loadingFiles) return const Center(child: CircularProgressIndicator());
    if (_pcgFiles.isEmpty) {
      return const Center(child: Text('No saved characters found.',
          style: TextStyle(color: Colors.grey)));
    }

    return Column(
      children: [
        // Select all / none
        CheckboxListTile(
          value: _selected.length == _pcgFiles.length,
          tristate: _selected.isNotEmpty && _selected.length < _pcgFiles.length,
          title: Text('${_selected.length} / ${_pcgFiles.length} selected'),
          onChanged: (v) => setState(() {
            if (v == true) _selected = _pcgFiles.map((f) => f.path).toSet();
            else _selected = {};
          }),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: _pcgFiles.length,
            itemBuilder: (_, i) {
              final f = _pcgFiles[i];
              final name = f.path.split(RegExp(r'[\\/]')).last
                  .replaceAll('.pcg', '');
              return CheckboxListTile(
                value: _selected.contains(f.path),
                title: Text(name),
                subtitle: Text(_fmtSize(f.lengthSync())),
                onChanged: (v) => setState(() {
                  if (v == true) _selected.add(f.path);
                  else _selected.remove(f.path);
                }),
              );
            },
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_exportProgress != null) ...[
                LinearProgressIndicator(value: _exportProgress == 1.0 ? 1.0 : _exportProgress),
                const SizedBox(height: 8),
                Text(_exportStatus, style: const TextStyle(fontSize: 12)),
                if (_lastExportPath != null) ...[
                  const SizedBox(height: 4),
                  SelectableText(_lastExportPath!,
                      style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
                const SizedBox(height: 8),
              ],
              ElevatedButton.icon(
                icon: const Icon(Icons.archive),
                label: const Text('Export to .pcgch'),
                onPressed: _exportProgress != null && _exportProgress! < 1.0
                    ? null
                    : _export,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImport() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File selection
          OutlinedButton.icon(
            icon: const Icon(Icons.folder_open),
            label: const Text('Choose .pcgch file…'),
            onPressed: _pickImportFile,
          ),
          if (_importPath != null) ...[
            const SizedBox(height: 12),
            Text('File: $_importPath',
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],

          // Preview
          if (_previewMeta != null) ...[
            const SizedBox(height: 16),
            _buildPreview(_previewMeta!),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _overwrite,
              contentPadding: EdgeInsets.zero,
              title: const Text('Overwrite existing characters'),
              onChanged: (v) => setState(() => _overwrite = v ?? false),
            ),
          ],

          // Progress
          if (_importProgress != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(value: _importProgress == 1.0 ? 1.0 : _importProgress),
            const SizedBox(height: 6),
            Text(_importStatus, style: const TextStyle(fontSize: 12)),
          ],

          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.unarchive),
              label: const Text('Import Characters'),
              onPressed: _importPath != null && _previewMeta != null &&
                      (_importProgress == null || _importProgress == 1.0)
                  ? _doImport
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(CharacterArchiveMetadata meta) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${meta.characterCount} character(s)  •  ${meta.exportDate}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...meta.characters.map((c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(children: [
                    const Icon(Icons.person_outline, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text('${c.name}  —  ${c.classes}',
                        style: const TextStyle(fontSize: 12))),
                    Text('Lv ${c.level}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                )),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<String?> _showPathDialog(String title, String hint) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(controller: ctrl,
            decoration: InputDecoration(labelText: 'File path', hintText: hint)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text),
              child: const Text('Open')),
        ],
      ),
    );
  }

  String _fmtSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  String _fmtDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
}
