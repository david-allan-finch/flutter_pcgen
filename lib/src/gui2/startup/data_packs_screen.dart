// Data Packs management screen.
// Shows installed packs, available catalogue packs to download,
// and an option to import a .pcglst file directly.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pcgen/src/gui2/startup/data_manager.dart';
import 'package:flutter_pcgen/src/gui2/startup/pack_metadata.dart';

class DataPacksScreen extends StatefulWidget {
  const DataPacksScreen({super.key});

  @override
  State<DataPacksScreen> createState() => _DataPacksScreenState();
}

class _DataPacksScreenState extends State<DataPacksScreen> {
  final _mgr = DataManager();
  List<InstalledPack> _installed = [];
  bool _loading = true;

  // Per-entry download state: packId → progress (null=indeterminate, 1.0=done)
  final Map<String, _DownloadState> _downloadStates = {};

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    _installed = await _mgr.getInstalledPacks();
    if (mounted) setState(() => _loading = false);
  }

  bool _isInstalled(String id) => _installed.any((p) => p.metadata.id == id);

  Future<void> _download(CatalogueEntry entry) async {
    setState(() => _downloadStates[entry.metadata.id] = _DownloadState(null, 'Starting…'));
    try {
      await _mgr.downloadAndInstall(
        entry.url,
        onProgress: (p, s) {
          if (mounted) setState(() => _downloadStates[entry.metadata.id] = _DownloadState(p, s));
        },
      );
      await _reload();
    } catch (e) {
      if (mounted) {
        setState(() => _downloadStates.remove(entry.metadata.id));
        _showError('Download failed: $e');
      }
    }
  }

  Future<void> _importFile() async {
    // On desktop use a file picker; on mobile handle via share intent.
    // For now show a path input dialog.
    final path = await _showPathDialog();
    if (path == null || path.isEmpty) return;
    final f = File(path);
    if (!f.existsSync()) { _showError('File not found: $path'); return; }

    setState(() => _downloadStates['_import'] = _DownloadState(null, 'Reading…'));
    try {
      await _mgr.installFromFile(path, onProgress: (p, s) {
        if (mounted) setState(() => _downloadStates['_import'] = _DownloadState(p, s));
      });
      _downloadStates.remove('_import');
      await _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pack installed successfully')));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _downloadStates.remove('_import'));
        _showError('Import failed: $e');
      }
    }
  }

  Future<void> _removePack(InstalledPack pack) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Pack'),
        content: Text('Remove "${pack.metadata.name}"?\n\n'
            'Note: extracted files are kept — reinstall to refresh them.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text('Remove', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    await _mgr.removePack(pack.metadata.id);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Packs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: 'Import .pcglst file',
            onPressed: _importFile,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                if (_installed.isNotEmpty) ...[
                  _sectionHeader('Installed Packs'),
                  ..._installed.map(_buildInstalledTile),
                ],
                _sectionHeader('Available Packs'),
                ...DataManager.catalogue.map(_buildCatalogueTile),
                if (_downloadStates.containsKey('_import'))
                  _buildProgressTile('Importing…', _downloadStates['_import']!),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13,
                color: Colors.grey)),
      );

  Widget _buildInstalledTile(InstalledPack pack) {
    final m = pack.metadata;
    return ListTile(
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(m.name),
      subtitle: Text('v${m.version}  •  installed ${_fmtDate(pack.installedAt)}'),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        tooltip: 'Remove',
        onPressed: () => _removePack(pack),
      ),
    );
  }

  Widget _buildCatalogueTile(CatalogueEntry entry) {
    final m = entry.metadata;
    final ds = _downloadStates[m.id];
    final installed = _isInstalled(m.id);

    if (ds != null) return _buildProgressTile(m.name, ds);

    return ListTile(
      leading: Icon(
        installed ? Icons.refresh : Icons.download_outlined,
        color: installed ? Colors.orange : Colors.blue,
      ),
      title: Text(m.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (m.description != null) Text(m.description!, maxLines: 2),
          Text('${entry.sizeMb}  •  v${m.version}',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
      isThreeLine: m.description != null,
      trailing: TextButton(
        onPressed: () => _download(entry),
        child: Text(installed ? 'Update' : 'Install'),
      ),
    );
  }

  Widget _buildProgressTile(String name, _DownloadState ds) => ListTile(
        leading: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ds.status, style: const TextStyle(fontSize: 11)),
            const SizedBox(height: 4),
            ds.progress != null
                ? LinearProgressIndicator(value: ds.progress)
                : const LinearProgressIndicator(),
          ],
        ),
        isThreeLine: true,
      );

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<String?> _showPathDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Import .pcglst File'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(
            labelText: 'File path',
            hintText: '/path/to/pack.pcglst',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text),
              child: const Text('Import')),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2,'0')}-${dt.day.toString().padLeft(2,'0')}';
}

class _DownloadState {
  final double? progress;
  final String status;
  const _DownloadState(this.progress, this.status);
}
